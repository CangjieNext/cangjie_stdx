# 自定义证书校验

TLS 配置的 `verifyMode` 使用 `CustomVerify` 模式。通过配置证书校验函数，使 TLS 握手时使用定制的证书校验流程。

> **注意：**
>
> 以下示例仅用于展示客户端写法，可通过编译但无法运行成功。如需查看运行效果，需用户自行提供服务端和有效证书文件。

示例：

<!-- compile -->
```cangjie
import std.net.TcpSocket
import stdx.crypto.x509.X509Certificate
import stdx.net.tls.*
import stdx.net.tls.common.*

main() {
    var config = TlsClientConfig()
    config.supportedAlpnProtocols = ["h2"]

    // 自定义校验逻辑
    config.verifyMode = CustomVerify({
        certificates =>
            if (certificates.size == 0) {
                return false
            }
            for (certificate in certificates) {
                match (certificate as X509Certificate) {
                    case Some(c) =>
                        if (c.issuer.organizationName != "example") {
                            return false
                        }
                    case None => return false
                }
            }
            return true
    })

    try (socket = TcpSocket("127.0.0.1", 8443)) {
        socket.connect()
        let client = TlsSocket.client(socket, clientConfig: config, session: None)
        client.handshake()
    }
}
```
