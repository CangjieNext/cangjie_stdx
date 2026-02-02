# 证书热更新

示例：

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

    // 更改带有密钥的证书只会影响新的连接
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
