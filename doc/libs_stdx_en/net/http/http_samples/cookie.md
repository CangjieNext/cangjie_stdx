# cookie

## Client

Example:

<!-- run -->
```cangjie
import stdx.net.http.*
import stdx.encoding.url.*
import std.net.*
import std.time.*
import std.sync.*

main() {
    // 1. Start socket server
    let serverSocket = TcpServerSocket(bindAt: 0)
    serverSocket.bind()
    let fut = spawn {
        serverPacketCapture(serverSocket)
    }
    // Clients typically read cookies from the Set-Cookie header in responses and store them in cookieJar,
    // then include them in the Cookie header of subsequent requests
    // 2. Start client
    let client = ClientBuilder().build()
    let port = (serverSocket.localAddress as IPSocketAddress)?.port ?? throw Exception("Port not found.")
    var u = URL.parse("http://127.0.0.1:${port}/a/b/c")
    var r = HttpRequestBuilder().url(u).build()
    // 3. Send request
    client.send(r)
    r = HttpRequestBuilder().url(u).build()
    // 4. Send new request, retrieve cookies from CookieJar and convert them into Cookie header values
    // At this point cookie 2=2 has expired, so only cookie 1=1 is sent
    client.send(r)
    // 5. Close client
    client.close()
    fut.get()
    serverSocket.close()
}

func serverPacketCapture(serverSocket: TcpServerSocket) {
    let server = serverSocket.accept()
    let buf = Array<UInt8>(500, repeat: 0)
    var i = server.read(buf)
    println(String.fromUtf8(buf[..i]))
    // GET /a/b/c HTTP/1.1
    // host: 127.0.0.1:44649
    // user-agent: CANGJIEUSERAGENT_1_1
    // connection: keep-alive
    // content-length: 0
    //
    // Cookie1 with 4-second expiration
    let cookie1 = Cookie("1", "1", maxAge: 4, domain: "127.0.0.1", path: "/a/b/")
    let setCookie1 = cookie1.toSetCookieString()
    // Cookie2 with 2-second expiration
    let cookie2 = Cookie("2", "2", maxAge: 2, path: "/a/")
    let setCookie2 = cookie2.toSetCookieString()
    // Server sends Set-Cookie headers, client parses and stores them in CookieJar
    server.write(
        "HTTP/1.1 204 ok\r\nSet-Cookie: ${setCookie1}\r\nSet-Cookie: ${setCookie2}\r\nConnection: close\r\n\r\n"
            .toArray())

    let server2 = serverSocket.accept()
    i = server2.read(buf)
    // Receive client request with cookies
    println(String.fromUtf8(buf[..i]))
    // GET /a/b/c HTTP/1.1
    // host: 127.0.0.1:xxxx
    // cookie: 1=1
    // user-agent: CANGJIEUSERAGENT_1_1
    // connection: keep-alive
    // content-length: 0
    //
    server2.write("HTTP/1.1 204 ok\r\nConnection: close\r\n\r\n".toArray())
    server2.close()
}
```

Execution result:

> **Note:**
>
> The port number in the host field is randomly assigned and will differ with each execution.

```text
GET /a/b/c HTTP/1.1
host: 127.0.0.1:xxxx
user-agent: CANGJIEUSERAGENT_1_1
connection: keep-alive
content-length: 0


GET /a/b/c HTTP/1.1
host: 127.0.0.1:xxxx
cookie: 1=1
user-agent: CANGJIEUSERAGENT_1_1
connection: keep-alive
content-length: 0
```

## Server

Example:

<!-- run -->
```cangjie
import stdx.net.http.*
import stdx.net.tls.*
import std.net.*
import std.sync.*

main(): Unit {
    let serverOn = SyncCounter(1)
    spawn {
        serverSetCookie(serverOn)
    }
    serverOn.waitUntilZero()
    clientPacketCapture()
}

func serverSetCookie(serverOn: SyncCounter): Unit {
    // Server sends cookies to client via Set-Cookie headers
    // 1. Create Server instance
    let server = ServerBuilder().addr("127.0.0.1").port(8080).build()
    server.afterBind({=> serverOn.dec()})
    // 2. Register HttpRequestHandler
    server
        .distributor
        .register(
            "/index",
            {
                httpContext =>
                let cookie = Cookie("name", "value")
                httpContext.responseBuilder.header("Set-Cookie", cookie.toSetCookieString()).body("Hello Cangjie!")
            }
        )
    // 3. Start service
    server.serve()
}

func clientPacketCapture(): Unit {
    // Create client socket and connect to server
    let client = TcpSocket("127.0.0.1", 8080)
    client.connect()
    // Send request
    let request = "GET /index HTTP/1.1\r\nHost: 127.0.0.1:8080\r\n\r\n".toArray()
    client.write(request)
    // Read response, expected to contain "set-cookie: name=value"
    let buf = Array<UInt8>(500, repeat: 0)
    var len = client.read(buf)
    println(String.fromUtf8(buf[..len]))
}
```

Execution result:

> **Note:**
>
> The date field in the response represents the current date and will differ with each execution.

```text
HTTP/1.1 200 OK
set-cookie: name=value
connection: keep-alive
date: xxxx
content-length: 13

Hello Cangjie!
```
