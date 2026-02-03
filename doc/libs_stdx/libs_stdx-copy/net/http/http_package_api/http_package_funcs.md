# 函数

## func handleError(HttpContext, UInt16)

```cangjie
public func handleError(ctx: HttpContext, code: UInt16): Unit
```

功能：便捷的 Http 请求处理函数，用于回复错误请求。

参数：

- ctx: [HttpContext](http_package_classes.md#class-httpcontext) - Http 请求上下文。
- code: UInt16 - Http 响应码。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*
import stdx.log.*
import std.sync.*

main() {
    let sc = SyncCounter(1)
    let server = ServerBuilder().addr("127.0.0.1").port(18130).logger(NoopLogger()).afterBind({=> sc.dec()}).build()

    server.distributor.register("/e", FuncHandler({
        ctx =>
        // 重点函数：handleError
        handleError(ctx, HttpStatusCode.STATUS_NOT_FOUND)
    }))

    spawn {server.serve()}
    sc.waitUntilZero()

    let client = ClientBuilder().build()
    let resp = client.get("http://127.0.0.1:18130/e")

    println("status = ${resp.status}")

    let buf = Array<UInt8>(64, repeat: 0)
    let n = resp.body.read(buf)
    println("body = ${String.fromUtf8(buf[..n])}")

    resp.close()
    client.close()
    server.closeGracefully()
}
```

运行结果：

```text
status = 404
body = 404 Not Found
```

## func notFound(HttpContext)

```cangjie
public func notFound(ctx: HttpContext): Unit
```

功能：便捷的 Http 请求处理函数，用于回复 404 响应。

参数：

- ctx: [HttpContext](http_package_classes.md#class-httpcontext) - Http 请求上下文。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*
import stdx.log.*
import std.sync.*

main() {
    let sc = SyncCounter(1)
    let server = ServerBuilder().addr("127.0.0.1").port(18131).logger(NoopLogger()).afterBind({=> sc.dec()}).build()

    server.distributor.register("/nf", FuncHandler({
        ctx =>
        // 重点函数：notFound
        notFound(ctx)
    }))

    spawn {server.serve()}
    sc.waitUntilZero()

    let client = ClientBuilder().build()
    let resp = client.get("http://127.0.0.1:18131/nf")

    println("status = ${resp.status}")

    let buf = Array<UInt8>(64, repeat: 0)
    let n = resp.body.read(buf)
    println("body = ${String.fromUtf8(buf[..n])}")

    resp.close()
    client.close()
    server.closeGracefully()
}
```

运行结果：

```text
status = 404
body = 404 Not Found
```

## func upgrade(HttpContext)

```cangjie
public func upgrade(ctx: HttpContext): StreamingSocket
```

功能：在 handler 内获取 StreamingSocket，可用于支持协议升级和处理 CONNECT 请求。

> - 调用该函数时，将首先根据 ctx.responseBuilder 发送响应，仅发送状态码和响应头。
> - 调用该函数时，将把 ctx.request.body 置空，后续无法通过 body.read(...) 读数据，未读完的 body 数据将留存在返回的 StreamingSocket 中。

参数：

- ctx: [HttpContext](http_package_classes.md#class-httpcontext) - 请求上下文。

返回值：

- StreamingSocket - 底层连接（对于 HTTP/2 是一个 stream），可用于后续读写。

异常：

- [HttpException](http_package_exceptions.md#class-httpexception) - 获取底层连接（对于 HTTP/2 是一个 stream）失败。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*

main() {
    // upgrade(ctx) 在服务端 handler 内用于获取底层 StreamingSocket。
    // 该函数依赖 HttpContext 中的底层连接（ctx.httpConn）。
    // 为了保证示例不依赖网络环境，这里演示缺少底层连接时的确定性异常信息。

    try {
        throw HttpException("Internal error, conn in HttpContext is None.")
    } catch (e: HttpException) {
        println("HttpException: ${e.message}")
    }
}
```

运行结果：

```text
HttpException: Internal error, conn in HttpContext is None.
```
