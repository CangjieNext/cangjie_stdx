# 异常类

## class ConnectionException

```cangjie
public class ConnectionException <: IOException {
    public init(message: String)
}
```

功能：Http 的 tcp 连接异常类。

父类型：

- IOException

### init(String)

```cangjie
public init(message: String)
```

功能：创建 [ConnectionException](http_package_exceptions.md#class-connectionexception) 实例。

参数：

- message: String - 异常提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*

main() {
    try {
        throw ConnectionException("connect failed")
    } catch (e: ConnectionException) {
        println("message: ${e.message}")
    }
}
```

运行结果：

```text
message: connect failed
```

## class CoroutinePoolRejectException

```cangjie
public class CoroutinePoolRejectException <: Exception {
    public init(message: String)
}
```

功能：Http 的协程池拒绝请求处理异常类。

父类型：

- Exception

### init(String)

```cangjie
public init(message: String)
```

功能：创建 [CoroutinePoolRejectException](http_package_exceptions.md#class-coroutinepoolrejectexception) 实例。

参数：

- message: String - 异常提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*

main() {
    try {
        throw CoroutinePoolRejectException("pool rejected")
    } catch (e: CoroutinePoolRejectException) {
        println("message: ${e.message}")
    }
}
```

运行结果：

```text
message: pool rejected
```

## class HttpException

```cangjie
public class HttpException <: Exception {
    public init(message: String)
}
```

功能：Http 的通用异常类。

父类型：

- Exception

### init(String)

```cangjie
public init(message: String)
```

功能：创建 [HttpException](http_package_exceptions.md#class-httpexception) 实例。

参数：

- message: String - 异常提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*

main() {
    try {
        throw HttpException("bad request")
    } catch (e: HttpException) {
        println("message: ${e.message}")
    }
}
```

运行结果：

```text
message: bad request
```

## class HttpStatusException

```cangjie
public class HttpStatusException <: Exception {
    public init(statusCode: UInt16, message: String)
}
```

功能：Http 的响应状态异常类。

父类型：

- Exception

### init(UInt16, String)

```cangjie
public init(statusCode: UInt16, message: String)
```

功能：创建 [HttpStatusException](http_package_exceptions.md#class-httpstatusexception) 实例。

参数：

- statusCode: UInt16 - 状态码。
- message: String - 异常提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*

main() {
    try {
        throw HttpStatusException(404, "not found")
    } catch (e: HttpStatusException) {
        // statusCode 在实现中为非 public 字段，此处只演示 message
        println("message: ${e.message}")
    }
}
```

运行结果：

```text
message: not found
```

## class HttpTimeoutException

```cangjie
public class HttpTimeoutException <: Exception {
    public init(message: String)
}
```

功能：Http 的超时异常类。

父类型：

- Exception

### init(String)

```cangjie
public init(message: String)
```

功能：创建 [HttpTimeoutException](http_package_exceptions.md#class-httptimeoutexception) 实例。

参数：

- message: String - 异常提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*

main() {
    try {
        throw HttpTimeoutException("read timeout")
    } catch (e: HttpTimeoutException) {
        println("message: ${e.message}")
    }
}
```

运行结果：

```text
message: read timeout
```

## class WebSocketException

```cangjie
public class WebSocketException <: Exception {
    public init(message: String)
}
```

功能：[WebSocket](http_package_classes.md#class-websocket) 的通用异常类。

父类型：

- Exception

### init(String)

```cangjie
public init(message: String)
```

功能：创建 [WebSocketException](http_package_exceptions.md#class-websocketexception) 实例。

参数：

- message: String - 异常提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*

main() {
    try {
        throw WebSocketException("ws error")
    } catch (e: WebSocketException) {
        println("message: ${e.message}")
    }
}
```

运行结果：

```text
message: ws error
```
