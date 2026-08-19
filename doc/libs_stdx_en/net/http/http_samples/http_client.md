# client

> **Note:**
>
> The following examples are for demonstration purposes only. They can be compiled but will not run successfully. To see actual execution results, users need to provide their own server-side implementation. Some use cases require users to supply valid certificate files.

## Hello World

Example:

<!-- compile -->
```cangjie
import stdx.net.http.*

main() {
    // 1. Create client instance
    let client = ClientBuilder().build()
    // 2. Send request and receive response (request URL can be modified as needed)
    let rsp = client.get("http://example.com/hello")
    // 3. Print response content
    println(rsp)
    // 4. Close connection
    client.close()
}
```

## Custom Client Network Configuration

Example:

<!-- compile -->
```cangjie
import std.net.{TcpSocket, SocketAddress}
import std.fs.*
import stdx.net.tls.*
import stdx.net.tls.common.*
import stdx.crypto.x509.X509Certificate
import stdx.net.http.*
import std.io.*

main() {
    // 1. Custom configuration
    // TLS configuration
    var tlsConfig = TlsClientConfig()
    // Users must provide their own TLS certificate files
    let pem = String.fromUtf8(readToEnd(File("/rootCerPath", Read)))
    tlsConfig.verifyMode = CustomCA(X509Certificate.decodeFromPem(pem).map({certificate => certificate}))
    tlsConfig.supportedAlpnProtocols = ["h2"]
    // TCP connection configuration
    let TcpSocketConnector = {
        sa: SocketAddress =>
        let socket = TcpSocket(sa)
        socket.connect()
        return socket
    }
    // 2. Create client instance
    let client = ClientBuilder().tlsConfig(tlsConfig).enablePush(false).connector(TcpSocketConnector).build()
    // 3. Send request (URL can be modified as needed)
    let rsp = client.get("https://example.com/hello")
    // 4. Read response body
    let buf = Array<UInt8>(1024, repeat: 0)
    let len = rsp.body.read(buf)
    println(String.fromUtf8(buf.slice(0, len)))
    // 5. Close connection
    client.close()
}
```

## Chunked and Trailer in Request

Example:

<!-- compile -->
```cangjie
import std.io.*
import std.fs.*
import stdx.net.http.*
import stdx.net.tls.*

func checksum(chunk: Array<UInt8>): Int64 {
    var sum = 0
    for (i in chunk) {
        if (i == b'\n') {
            sum += 1
        }
    }
    return sum / 2
}

main() {
    // 1. Create client instance
    let client = ClientBuilder().build()
    var requestBuilder = HttpRequestBuilder()
    // Users must provide their own file for upload
    let file = File("./res.jpg", Read)
    let sum = checksum(readToEnd(file))
    let req = requestBuilder
        .method("PUT")
        .url("https://example.com/src/")
        .header("Transfer-Encoding", "chunked")
        .header("Trailer", "checksum")
        .body(FileBody("./res.jpg"))
        .trailer("checksum", sum.toString())
        .build()
    let rsp = client.send(req)
    println(rsp)
    client.close()
}

class FileBody <: InputStream {
    var file: File
    init(path: String) {
        file = File(path, Read)
    }
    public func read(buf: Array<UInt8>): Int64 {
        file.read(buf)
    }
}
```

## Proxy Configuration

Example:

<!-- compile -->
```cangjie
import stdx.net.http.*

main() {
    // 1. Create client instance
    let client = ClientBuilder().httpProxy("http://127.0.0.1:8080").build()
    // 2. All requests will be sent to port 8080 at 127.0.0.1 instead of example.com
    // Users can modify proxy settings and request URL as needed
    let rsp = client.get("http://example.com/hello")
    // 3. Print response
    println(rsp)
    // 4. Close connection
    client.close()
}
```
