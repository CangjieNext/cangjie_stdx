# log

Example:

<!-- compile -->
```cangjie
import stdx.log.*
import stdx.net.http.*
import stdx.net.tls

main() {
    // 1. Create a Server instance
    let server = ServerBuilder().addr("127.0.0.1").port(8080).build()
    // 2. Register HttpRequestHandler
    server.distributor.register("/index", {
        httpContext => httpContext.responseBuilder.body("Hello Cangjie!")
    })
    // 3. Enable logging
    server.logger.level = LogLevel.DEBUG
    // Client-side can enable logging via client.logger.level = DEBUG
    // 4. Start the service
    server.serve()
}
```

Execution result:

```text
2025-05-24T23:55:12.779407244+08:00 DEBUG [thread#1] [Server#serve] bindAndListen(127.0.0.1, 8080)
```