# 客户端示例

示例：

<!-- compile -->
```cangjie
import std.net.TcpSocket
import stdx.crypto.x509.X509Certificate
import stdx.net.tls.*
import stdx.net.tls.common.*

main() {
    var config = TlsClientConfig()
    config.verifyMode = TrustAll
    config.supportedAlpnProtocols = ["h2"]

    // 用于恢复会话
    var lastSession: ?TlsClientSession = None
    // 重新连接环路
    while (true) {
        try (socket = TcpSocket("127.0.0.1", 8443)) {
            // 首先进行 TCP 连接
            socket.connect()
            try (tls = TlsSocket.client(socket, clientConfig: config, session: lastSession)) {
                try {
                    tls.handshake()
                    // 如果成功协商下一次重新连接，将记住会话
                    lastSession = match (tls.handshakeResult) {
                        case Some(r) => r.session as TlsClientSession
                        case None => None
                    }
                } catch (e: Exception) {
                    // 如果协商失败，将删除会话
                    lastSession = None
                    throw e
                }
                // tls 实例已完成
                tls.write("Hello, peer! Let's discuss our personal secrets.\n".toArray())
            }
        } catch (e: Exception) {
            println("client connection failed ${e}, retrying...")
        }
    }
}
```
