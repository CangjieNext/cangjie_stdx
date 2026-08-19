# Client Example

Example:

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

    // For session resumption
    var lastSession: ?TlsClientSession = None
    // Reconnection loop
    while (true) {
        try (socket = TcpSocket("127.0.0.1", 8443)) {
            // First establish TCP connection
            socket.connect()
            try (tls = TlsSocket.client(socket, clientConfig: config, session: lastSession)) {
                try {
                    tls.handshake()
                    // If successful, remember session for next reconnection
                    lastSession = match (tls.handshakeResult) {
                        case Some(r) => r.session as TlsClientSession
                        case None => None
                    }
                } catch (e: Exception) {
                    // If negotiation fails, clear the session
                    lastSession = None
                    throw e
                }
                // TLS instance is ready
                tls.write("Hello, peer! Let's discuss our personal secrets.\n".toArray())
            }
        } catch (e: Exception) {
            println("client connection failed ${e}, retrying...")
        }
    }
}
```
