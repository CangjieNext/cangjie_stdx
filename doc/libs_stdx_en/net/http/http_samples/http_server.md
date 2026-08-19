# server

> **Note:**
>
> The following examples only demonstrate server-side implementation. They can be compiled and run (some cases require users to provide valid certificate files), but cannot show request processing effects. To observe runtime behavior, users need to provide their own client to send requests to the example server.

## Hello Cangjie

Example:

<!-- compile -->
```cangjie
import stdx.net.http.ServerBuilder
import stdx.net.tls

main() {
    // 1. Create Server instance
    let server = ServerBuilder().addr("127.0.0.1").port(8080).build()
    // 2. Register HttpRequestHandler
    server.distributor.register("/index", {
        httpContext => httpContext.responseBuilder.body("Hello Cangjie!")
    })
    // 3. Start service
    server.serve()
}
```

## Registering Handlers via Request Distributor

Example:

<!-- compile -->
```cangjie
import stdx.net.http.{ServerBuilder, HttpRequestHandler, FuncHandler}

main() {
    // 1. Create Server instance
    let server = ServerBuilder().addr("127.0.0.1").port(8080).build()
    // Register three different HttpRequestHandlers. The server will automatically distribute and process requests based on paths.
    var a: HttpRequestHandler = FuncHandler({
        httpContext => httpContext.responseBuilder.body("index")
    })
    var b: HttpRequestHandler = FuncHandler({
        httpContext => httpContext.responseBuilder.body("id")
    })
    var c: HttpRequestHandler = FuncHandler({
        httpContext => httpContext.responseBuilder.body("help")
    })
    server.distributor.register("/index", a)
    server.distributor.register("/id", b)
    server.distributor.register("/help", c)
    // 2. Start service
    server.serve()
}
```

## Custom Request Distributor and Handlers

Example:

<!-- compile -->
```cangjie
import stdx.net.http.*
import stdx.net.tls.*
import std.collection.HashMap

// Custom request distributor
class NaiveDistributor <: HttpRequestDistributor {
    let map = HashMap<String, HttpRequestHandler>()
    public func register(path: String, handler: HttpRequestHandler): Unit {
        map.add(path, handler)
    }

    public func distribute(path: String): HttpRequestHandler {
        if (path == "/index") {
            return PageHandler()
        }
        return NotFoundHandler()
    }
}

// Returns a simple HTML page
class PageHandler <: HttpRequestHandler {
    public func handle(httpContext: HttpContext): Unit {
        httpContext.responseBuilder.body("<html></html>")
    }
}

main() {
    // 1. Create Server instance with custom distributor
    let server = ServerBuilder().addr("127.0.0.1").port(8080).distributor(NaiveDistributor()).build()
    // 2. Start service
    server.serve()
}
```

## Custom Server Network Configuration

Example:

<!-- compile -->
```cangjie
import std.io.*
import std.fs.*
import stdx.net.tls.*
import stdx.crypto.x509.X509Certificate
import stdx.crypto.keys.GeneralPrivateKey
import stdx.net.http.*

main() {
    // 1. Custom configurations
    // TCP configuration
    var transportCfg = TransportConfig()
    transportCfg.readBufferSize = 8192
    // TLS configuration requires certificate and private key file paths (users must provide these)
    let pem0 = String.fromUtf8(readToEnd(File("/certPath", Read)))
    let pem02 = String.fromUtf8(readToEnd(File("/keyPath", Read)))
    var tlsConfig = TlsServerConfig(X509Certificate.decodeFromPem(pem0), GeneralPrivateKey.decodeFromPem(pem02))
    tlsConfig.supportedAlpnProtocols = ["h2"]
    // 2. Create Server instance
    let server = ServerBuilder()
        .addr("127.0.0.1")
        .port(8080)
        .transportConfig(transportCfg)
        .tlsConfig(tlsConfig)
        .headerTableSize(10 * 1024)
        .maxRequestHeaderSize(1024 * 1024)
        .build()
    // 3. Register HttpRequestHandler
    server.distributor.register("/index", {
        httpContext => httpContext.responseBuilder.body("Hello Cangjie!")
    })
    // 4. Start service
    server.serve()
}
```

## Chunked Encoding and Trailers in Response

Example:

<!-- compile -->
```cangjie
import stdx.net.http.*
import stdx.net.tls

func checksum(chunk: Array<UInt8>): Int64 {
    var sum = 0
    for (i in chunk) {
        if (i == UInt8(UInt32(r'\n'))) {
            sum += 1
        }
    }
    return sum / 2
}

main() {
    // 1. Create Server instance
    let server = ServerBuilder().addr("127.0.0.1").port(8080).build()
    // 2. Register HttpRequestHandler
    server
        .distributor
        .register(
            "/index",
            {
                httpContext =>
                let responseBuilder = httpContext.responseBuilder
                // Set response headers for transfer-encoding and trailer
                responseBuilder.header("transfer-encoding", "chunked")
                responseBuilder.header("trailer", "checkSum")
                // Use HttpResponseWriter to send response body in chunks
                let writer = HttpResponseWriter(httpContext)
                var sum = 0
                for (_ in 0..10) {
                    let chunk = Array<UInt8>(10, repeat: 0)
                    sum += checksum(chunk)
                    writer.write(chunk)
                }
                // Send response trailer (sent after the response body)
                responseBuilder.trailer("checkSum", "${sum}")
            }
        )
    // 3. Start service
    server.serve()
}
```

## Handling Redirect Requests

Example:

<!-- compile -->
```cangjie
import stdx.net.http.*
import stdx.net.tls

main() {
    // 1. Create Server instance
    let server = ServerBuilder().addr("127.0.0.1").port(8080).build()
    // 2. Register redirect HttpRequestHandlers
    server.distributor.register("/redirecta", RedirectHandler("/movedsource", 308))
    server.distributor.register("/redirectb", RedirectHandler("http://www.example.com", 308))
    // 3. Start service
    server.serve()
}
```

## Hot Reloading TLS Certificates

Example:

<!-- compile -->
```cangjie
import std.io.*
import std.fs.*
import stdx.net.tls.*
import stdx.net.tls.common.*
import stdx.crypto.x509.X509Certificate
import stdx.crypto.keys.GeneralPrivateKey
import stdx.net.http.*

// Users must provide valid file paths for this program to execute
main() {
    // 1. TLS configuration (users must provide certificate and private key files)
    let pem0 = String.fromUtf8(readToEnd(File("/certPath", Read)))
    let pem02 = String.fromUtf8(readToEnd(File("/keyPath", Read)))
    var tlsConfig = TlsServerConfig(X509Certificate.decodeFromPem(pem0), GeneralPrivateKey.decodeFromPem(pem02))
    tlsConfig.supportedAlpnProtocols = ["http/1.1"]
    let pem = String.fromUtf8(readToEnd(File("/rootCerPath", Read)))
    tlsConfig.verifyMode = CustomCA(X509Certificate.decodeFromPem(pem).map({certificate => certificate}))
    // 2. Create Server instance and start service
    let server = ServerBuilder().addr("127.0.0.1").port(8080).tlsConfig(tlsConfig).build()
    spawn {
        server.serve()
    }
    // 3. Update TLS certificate and private key (new connections will use updated credentials)
    server.updateCert("/newCerPath", "/newKeyPath")
    // 4. Update CA (for mutual TLS authentication)
    server.updateCA("/newRootCerPath")
}
```

## Server Push

For HTTP/2 only

Client:

Example:

<!-- compile -->
```cangjie
import std.io.*
import std.fs.*
import std.collection.ArrayList
import stdx.net.tls.*
import stdx.net.tls.common.*
import stdx.crypto.x509.X509Certificate
import stdx.net.http.*

main() {
    // 1. TLS configuration (users must provide certificate files)
    var tlsConfig = TlsClientConfig()
    let pem = String.fromUtf8(readToEnd(File("/rootCerPath", Read)))
    tlsConfig.verifyMode = CustomCA(X509Certificate.decodeFromPem(pem).map({certificate => certificate}))
    tlsConfig.supportedAlpnProtocols = ["h2"]
    // 2. Create Client instance
    let client = ClientBuilder().tlsConfig(tlsConfig).build()
    // 3. Send request and receive response
    let response = client.get("https://127.0.0.1.8080/index.html")
    // 4. Receive server-pushed responses (equivalent to client.get("http://127.0.0.1.8080/picture.png"))
    let pushResponses: Option<ArrayList<HttpResponse>> = response.getPush()
    client.close()
}
```

Server:

Example:

<!-- compile -->
```cangjie
import std.io.*
import std.fs.*
import stdx.net.tls.*
import stdx.crypto.x509.X509Certificate
import stdx.crypto.keys.GeneralPrivateKey
import stdx.net.http.*

main() {
    // 1. TLS configuration (users must provide certificate files)
    let pem0 = String.fromUtf8(readToEnd(File("/certPath", Read)))
    let pem02 = String.fromUtf8(readToEnd(File("/keyPath", Read)))
    var tlsConfig = TlsServerConfig(X509Certificate.decodeFromPem(pem0), GeneralPrivateKey.decodeFromPem(pem02))
    tlsConfig.supportedAlpnProtocols = ["h2"]
    // 2. Create Server instance
    let server = ServerBuilder().addr("127.0.0.1").port(8080).tlsConfig(tlsConfig).build()
    // 3. Register original request handler
    server
        .distributor
        .register(
            "/index.html",
            {
                httpContext =>
                let pusher = HttpResponsePusher.getPusher(httpContext)
                match (pusher) {
                    case Some(pusher) => pusher.push("/picture.png", "GET", httpContext.request.headers)
                    case None => ()
                }
            }
        )
    // 4. Register the handler for server push requests
    server.distributor.register("/picture.png", {
        httpContext => httpContext.responseBuilder.body("picture.png")
    })
    // 4. Start the service
    server.serve()
}
```