# Certificate Hot Reloading

Example:

<!-- run -->
```cangjie
import std.net.StreamingSocket
import stdx.crypto.common.{Certificate, PrivateKey}
import stdx.net.tls.*

class MyServer {
    private var currentConfig: TlsServerConfig

    init(initialConfig: TlsServerConfig) {
        currentConfig = initialConfig
    }

    // Changing certificates with keys only affects new connections
    public mut prop certificate: ?(Array<Certificate>, PrivateKey) {
        get() {
            currentConfig.certificate
        }
        set(newCertificate) {
            currentConfig.certificate = newCertificate
        }
    }

    public func onAcceptedConnection(client: StreamingSocket) {
        try (tls = TlsSocket.server(client, serverConfig: currentConfig)) {
            tls.handshake()
        }
    }
}

main() {}
```
