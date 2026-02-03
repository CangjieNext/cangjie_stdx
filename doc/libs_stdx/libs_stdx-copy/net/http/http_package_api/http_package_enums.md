# 枚举

## enum FileHandlerType

```cangjie
public enum FileHandlerType {
    | DownLoad
    | UpLoad
}
```

功能：用于设置 [FileHandler](http_package_classes.md#class-filehandler) 是上传还是下载模式。

### DownLoad

```cangjie
DownLoad
```

功能：设置 [FileHandler](http_package_classes.md#class-filehandler) 为下载模式。

### UpLoad

```cangjie
UpLoad
```

功能：设置 [FileHandler](http_package_classes.md#class-filehandler) 为上传模式。

## enum Protocol

```cangjie
public enum Protocol <: Equatable<Protocol> & ToString {
    | HTTP1_0
    | HTTP1_1
    | HTTP2_0
    | UnknownProtocol(String)
}
```

功能：定义 HTTP 协议类型枚举。

父类型：

- Equatable\<[Protocol](#enum-protocol)>
- ToString

### HTTP1_0

```cangjie
HTTP1_0
```

功能：定义 1.0 版本 HTTP 协议。

### HTTP1_1

```cangjie
HTTP1_1
```

功能：定义 1.1 版本 HTTP 协议。

### HTTP2_0

```cangjie
HTTP2_0
```

功能：定义 2.0 版本 HTTP 协议。

### UnknownProtocol(String)

```cangjie
UnknownProtocol(String)
```

功能：定义未知 HTTP 协议。

### func toString()

```cangjie
public override func toString(): String
```

功能：获取 Http 协议版本字符串。

返回值：

- String - Http 协议版本字符串。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*

main() {
    let protocol = Protocol.HTTP1_1
    let protocolStr = protocol.toString()
    println("协议版本字符串: ${protocolStr}")
    return 0
}
```

运行结果：

```text
协议版本字符串: HTTP/1.1
```

### operator func != (Protocol)

```cangjie
public override operator func !=(that: Protocol): Bool
```

功能：判断枚举值是否不相等。

参数：

- that: [Protocol](http_package_enums.md#enum-protocol) - 被比较的枚举值。

返回值：

- Bool - 当前实例与 `that` 不等，返回 `true`；否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*

main() {
    let protocol1 = Protocol.HTTP1_1
    let protocol2 = Protocol.HTTP2_0
    let isNotEqual = protocol1 != protocol2
    println("协议是否不相等: ${isNotEqual}")
    return 0
}
```

运行结果：

```text
协议是否不相等: true
```

### operator func == (Protocol)

```cangjie
public override operator func ==(that: Protocol): Bool
```

功能：判断枚举值是否相等。

参数：

- that: [Protocol](http_package_enums.md#enum-protocol) - 被比较的枚举值。

返回值：

- Bool - 当前实例与 `that` 相等，返回 `true`；否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*

main() {
    let protocol1 = Protocol.HTTP1_1
    let protocol2 = Protocol.HTTP1_1
    let isEqual = protocol1 == protocol2
    println("协议是否相等: ${isEqual}")
    return 0
}
```

运行结果：

```text
协议是否相等: true
```

## enum WebSocketFrameType

```cangjie
public enum WebSocketFrameType <: Equatable<WebSocketFrameType> & ToString {
    | ContinuationWebFrame
    | TextWebFrame
    | BinaryWebFrame
    | CloseWebFrame
    | PingWebFrame
    | PongWebFrame
    | UnknownWebFrame
}
```

功能：定义 [WebSocketFrame](http_package_classes.md#class-websocketframe) 的枚举类型。

父类型：

- Equatable\<[WebSocketFrameType](#enum-websocketframetype)>
- ToString

### BinaryWebFrame

```cangjie
BinaryWebFrame
```

功能：定义 websocket 协议中的数据帧。

### CloseWebFrame

```cangjie
CloseWebFrame
```

功能：定义 websocket 协议中的关闭帧。

### ContinuationWebFrame

```cangjie
ContinuationWebFrame
```

功能：定义 websocket 协议中的未结束的分片帧。

### PingWebFrame

```cangjie
PingWebFrame
```

功能：定义 websocket 协议中的心跳帧。

### PongWebFrame

```cangjie
PongWebFrame
```

功能：定义 websocket 协议中的心跳帧。

### TextWebFrame

```cangjie
TextWebFrame
```

功能：定义 websocket 协议中的文本帧。

### UnknownWebFrame

```cangjie
UnknownWebFrame
```

功能：定义 websocket 协议中的未知类型帧。

### func toString()

```cangjie
public override func toString(): String
```

功能：获取 [WebSocket](http_package_classes.md#class-websocket) 帧类型字符串。

返回值：

- String - [WebSocket](http_package_classes.md#class-websocket) 帧类型字符串。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*

main() {
    let frameType = WebSocketFrameType.TextWebFrame
    let frameTypeStr = frameType.toString()
    println("WebSocket帧类型字符串: ${frameTypeStr}")
    return 0
}
```

运行结果：

```text
WebSocket帧类型字符串: TextWebFrame
```

### operator func != (WebSocketFrameType)

```cangjie
public override operator func !=(that: WebSocketFrameType): Bool
```

功能：判断枚举值是否不相等。

参数：

- that: [WebSocketFrameType](http_package_enums.md#enum-websocketframetype) - 被比较的枚举值。

返回值：

- Bool - 当前实例与 `that` 不等返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*

main() {
    let frameType1 = WebSocketFrameType.TextWebFrame
    let frameType2 = WebSocketFrameType.BinaryWebFrame
    let isNotEqual = frameType1 != frameType2
    println("WebSocket帧类型是否不相等: ${isNotEqual}")
    return 0
}
```

运行结果：

```text
WebSocket帧类型是否不相等: true
```

### operator func == (WebSocketFrameType)

```cangjie
public override operator func ==(that: WebSocketFrameType): Bool
```

功能：判断枚举值是否相等。

参数：

- that: [WebSocketFrameType](http_package_enums.md#enum-websocketframetype) - 被比较的枚举值。

返回值：

- Bool - 当前实例与 `that` 相等返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.net.http.*

main() {
    let frameType1 = WebSocketFrameType.TextWebFrame
    let frameType2 = WebSocketFrameType.TextWebFrame
    let isEqual = frameType1 == frameType2
    println("WebSocket帧类型是否相等: ${isEqual}")
    return 0
}
```

运行结果：

```text
WebSocket帧类型是否相等: true
```
