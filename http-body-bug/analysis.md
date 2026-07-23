# HTTP/1.1 Client 重试时 Body 内容错误

## 现象

从连接池取出连接发送请求时，如果该连接已被服务端关闭（如服务端 keep-alive 超时关闭空闲连接），客户端会检测到连接异常，自动重连并重新发送请求。此时出现如下报错：

```
[ConnNode#sendBody] the content-length is wrong
```

服务端实际收到的请求 body 为空或截断，与客户端期望发送的内容不一致。

## 根因分析

### 整体调用链路

用户通过 `Client.send()` 发送请求时，调用链路如下：

```
Client.send(req)
  → Client.doRequest(req)
    → Client.checkReq(req)         // 将 InputStream body 封装为 HttpBufferedBody
    → Client.requestWithNegotiateRetry(req)
      → HttpClient1.request(req)
        → HttpEngine1.sendRequest(req, ...)
          → connNode.sendRequest(req)
            → ConnNode.sendRequestTimeout(req)
```

### 三个关键机制

**1. Body 缓存机制（`Client.checkReq`，`client.cj:580-584`）**

```cangjie
match (req._body) {
    case _: HttpRawBody => ()
    case _: HttpEmptyBody => ()
    case _ => req._body = HttpBufferedBody(req._body)
}
```

对于非 `HttpRawBody`、非 `HttpEmptyBody` 的 InputStream body，`checkReq` 会将其封装为 `HttpBufferedBody`。`HttpBufferedBody` 在每次 `read()` 时缓存已读出的数据：

```cangjie
// http_body.cj:97-103
public func read(buf: Array<Byte>): Int64 {
    let len = body.read(buf)       // 从底层 InputStream 继续往前读
    if (len > 0) {
        data.add(all: buf[..len])  // 将读出的数据追加到内部缓存 ArrayList<UInt8>
    }
    return len
}
```

重试发送 body 时，`writeBodyByCT`/`writeBodyByChunk` 会先发缓存数据（`bb.bytes`），再通过 `body.read()` 读剩余数据：

```cangjie
// writeBodyByCT (http_client1_1.cj:1130-1137)
if (let Some(bb) <- (body as HttpBufferedBody)) {
    conn.write(bb.bytes)          // 发出缓存数据
    remainLen -= bb.length
    if (remainLen == 0) { return }
}
// 然后 body.read() 从底层流当前位置继续读
```

这一机制的设计意图是：即使底层 InputStream 已经被部分消费，缓存在 `data` 中的数据仍可通过 `bb.bytes` 重新发出，避免数据丢失。

**2. Body 并发发送机制（`ConnNode.sendRequestTimeout`，`http_client1_1.cj:640-698`）**

```cangjie
func sendRequestTimeout(request: HttpRequest): HttpResponse {
    sendRequestHeaderTimeout(request)   // 主线程：发 header
    let fut = spawn {sendRequestBodyTimeout(request, ...)}  // 子协程：发 body
    var response = readResponse(request)   // 主线程：读响应
    ...
    try { fut.get() } catch (e: SocketException) {}  // 等子协程完成
    ...
    return response
}
```

请求的 header 和 body 分别在**主线程**和**子协程**中并发执行。主线程负责发送 header 和读取响应，子协程负责发送 body。

**3. 重试机制（`HttpEngine1.sendRequest`，`http_client1_1.cj:267-275`）**

```cangjie
catch (e: ConnectionException) {
    closeConnInUse(connNode)
    if (isIdempotentMethod(request.method)) {
        return reconnectSendRequest(request, isToProxy)  // 用同一个 request 对象重试
    }
}
```

当检测到 `ConnectionException`/`SocketException` 时（如 stale 连接），对幂等方法（GET、HEAD、OPTIONS、PUT、DELETE、TRACE）会使用**同一个 `request` 对象**创建新连接重试。

### Bug：两个协程并发访问同一个 HttpBufferedBody

**问题发生的时序如下**：

1. 从连接池取出一个 stale 连接（服务端已关闭，但客户端不知道）
2. `sendRequestTimeout` 开始执行：
   - `sendRequestHeaderTimeout()` — 写 header（可能进入 TCP 发送缓冲区）
   - `spawn` 子协程 A — 开始发送 body，调用 `HttpBufferedBody.read()` 从底层流读数据并缓存
   - 主线程 `readResponse()` — 从 stale 连接读响应 → **抛出 ConnectionException**
3. ConnectionException 从 `sendRequestTimeout` 向上传播：
   - 经过 `ConnNode.sendRequest()` → `HttpEngine1.sendRequest()`
   - 在 `HttpEngine1.sendRequest()` 的 catch 中触发 `reconnectSendRequest(request)`
   - **但此时子协程 A 可能仍在执行 `HttpBufferedBody.read()`**
4. `reconnectSendRequest` 创建新连接，再次调用 `connNode.sendRequest(request)`：
   - `sendRequestTimeout` 再次 `spawn` **子协程 B** — 发送同一个 `request._body`（`HttpBufferedBody`）
   - **子协程 A 和子协程 B 并发调用同一个 `HttpBufferedBody.read()`**

**并发竞争导致的后果**：

| 竞争点 | 问题 |
|--------|------|
| `body.read(buf)` — 底层 InputStream 的 `pos` 字段 | 两个协程并发推进 `pos`，可能跳过数据或重复读取同一块数据 |
| `data.add(all: buf[..len])` — `ArrayList<UInt8>` 非线程安全 | 并发 add 可能导致数据错位、丢失或 ArrayList 内部结构损坏 |
| `bb.bytes` / `bb.length` — 读取正在被并发修改的缓存 | `bytes` 和 `length` 可能返回不一致的值 |

最终，重试的 `writeBodyByCT` 检测到 `body.read()` 返回的数据量与 `contentLen` 不匹配（`readLen <= 0` 或 `remainLen < readLen`），触发：

```cangjie
shouldClose.store(true)
httpLogError(logger, "[ConnNode#sendBody] the content-length is wrong")
```

连接被标记关闭，body 发送中断，服务端收到截断或空的 body。

### 为什么 `fut.get()` 之前没有起到保护作用

原代码中 `fut.get()` 位于 `sendRequestTimeout` 的正常流程中（在 `readResponse` 之后）：

```cangjie
var response = readResponse(request)   // ← 如果这里抛异常，下面的 fut.get() 不会执行
...
try { fut.get() } catch (e: SocketException) {}
...
return response
```

如果 `readResponse()` 抛出 `ConnectionException`，异常会立即向上传播，**跳过 `fut.get()`**。子协程 A 继续运行，但主线程已经进入了重试流程。这就是并发竞争的直接原因。

## 修改方案

### 核心思路

确保在异常传播到 `HttpEngine1.sendRequest`（触发重试）之前，第一次尝试的 body 发送子协程已经完成。这样重试时 `HttpBufferedBody` 的状态是稳定的，不存在并发竞争。

### 具体修改

**修改文件**：`src/stdx/net/http/http_client1_1.cj`

**修改方法**：`ConnNode.sendRequestTimeout`

将 `spawn` 之后的代码用 **`try-finally`** 包裹，将 `fut.get()` 和 `writeTimer.cancel()` 移入 `finally` 块，确保无论是否发生异常，body 协程都会被等待完成。

**修改前**：

```cangjie
func sendRequestTimeout(request: HttpRequest): HttpResponse {
    checkUpgradeAndCloseInHeader(request)
    sendRequestHeaderTimeout(request)

    let expectContinuation = AtomicBool(request.expectContinuation)
    let shouldSendBody = AtomicBool(true)
    let fut = spawn {sendRequestBodyTimeout(request, expectContinuation, shouldSendBody)}

    setReadTimer(request.readTimeout ?? readTimeout)
    var response = readResponse(request)
    ...
    // 如果 readResponse 抛异常，fut.get() 不会被执行
    try {
        fut.get()
    } catch (e: SocketException) {}
    ...
    return response
}
```

**修改后**：

```cangjie
func sendRequestTimeout(request: HttpRequest): HttpResponse {
    checkUpgradeAndCloseInHeader(request)
    sendRequestHeaderTimeout(request)

    let expectContinuation = AtomicBool(request.expectContinuation)
    let shouldSendBody = AtomicBool(true)
    let fut = spawn {sendRequestBodyTimeout(request, expectContinuation, shouldSendBody)}

    try {
        setReadTimer(request.readTimeout ?? readTimeout)
        var response = readResponse(request)
        ...
        response = process1xxResponse(response, request, expectContinuation, shouldSendBody)
        shouldSendBody.swap(false)
        ...
        response.connNode = this
        if (response.body is HttpEmptyBody) {
            ...
            h1Engine.returnConn(this)
        }
        return response
    } finally {
        // 无论是否发生异常，都等待 body 协程完成后再传播异常。
        // 这防止了重试时两个协程并发访问同一个 HttpBufferedBody。
        try {
            fut.get()
        } catch (e: Exception) {
            httpLogWarn(logger, "[ConnNode#sendRequestTimeout] Client1.1 send body coroutine failed: ${e}")
        }
        writeTimer.cancel()
    }
}
```

### 修改原理

当 `readResponse()` 抛出 `ConnectionException` 时：

1. `finally` 块**先于异常传播**执行
2. `fut.get()` 等待子协程 A 完成（子协程 A 也会失败，但会正常退出）
3. `finally` 完成后，`ConnectionException` 才传播到 `HttpEngine1.sendRequest()`
4. `HttpEngine1.sendRequest()` 触发 `reconnectSendRequest(request)`
5. 此时子协程 A 已结束，`HttpBufferedBody` 状态稳定
6. 重试的子协程 B 可以安全地使用 `HttpBufferedBody`，无并发竞争

### 不受影响的场景

- **`sendRequestHeaderTimeout` 抛异常**：此时 `spawn` 还未执行，不存在子协程，`fut` 变量也未创建。异常直接传播，无需等待，不存在并发问题。
- **正常请求**：`try` 块正常执行到 `return response`，`finally` 块仍然执行 `fut.get()`（等子协程完成），行为与原来一致。
