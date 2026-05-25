# h1_gzip

Example of Server-Side Gzip Compression for HTTP Messages

Example:

<!-- verify -->
```cangjie
import stdx.compress.zlib.*
import stdx.net.http.*
import stdx.net.tls.*
import std.collection.*
import std.io.*
import std.sync.*

main() {
    // 1. Start server listener
    let port = startServer()

    // 2. Construct HTTP request
    let request = HttpRequestBuilder()
        .get()
        .url("http://127.0.0.1:${port}/hello")
        .header("Accept-Encoding", "gzip")
        .build()

    // 3. Send HTTP request and get response
    let client = ClientBuilder().build()
    let rsp = client.send(request)

    // 4. Decompress body using gzip
    let body = DecompressInputStream(rsp.body, wrap: GzipFormat)
    println("Rsp body: ${String.fromUtf8(readToEnd(body))}")

    0
}

func startServer(): UInt16 {
    let server = ServerBuilder().addr("127.0.0.1").port(0).build()
    server
        .distributor
        .register("/hello") {
            ctx =>
            // 1. Set response headers
            ctx.responseBuilder.header("Transfer-Encoding", "chunked")
            ctx.responseBuilder.header("Content-Encoding", "gzip")

            // 2. Get body input stream
            let rawBody = ByteBuffer()
            "hello gzip".toArray() |> rawBody.write

            // 3. Compress input stream using gzip
            let body = CompressInputStream(rawBody, wrap: GzipFormat)
            ctx.responseBuilder.body(body)
        }
    let serverOn = SyncCounter(1)
    server.afterBind({=> serverOn.dec()})

    spawn {server.serve()}
    serverOn.waitUntilZero()
    return server.port
}

func readToEnd(input: InputStream): Array<Byte> {
    let buf = Array<Byte>(200, repeat: 0)
    let result = ArrayList<Byte>()
    var len = input.read(buf)
    while (len > 0) {
        result.add(all: buf[0..len])
        len = input.read(buf)
    }
    return result.toArray()
}
```

Execution Result:

```text
Rsp body: hello gzip
```
