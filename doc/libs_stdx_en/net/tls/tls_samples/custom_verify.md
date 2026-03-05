# Custom Certificate Validation Example

The `verifyMode` in the TLS configuration uses the `CustomVerify` mode. By configuring a custom certificate validation function, a customized certificate verification process is applied during the TLS handshake.

> **Note:**
>
> The following examples are for demonstration purposes only. They can be compiled but will not run successfully. To see actual execution results, users need to provide their own server-side implementation and valid certificate files.

Example:

<!-- compile -->
```cangjie
import std.net.TcpSocket
import cangjie_stdx::crypto.x509.X509Certificate
import cangjie_stdx::net.tls.*
import cangjie_stdx::net.tls.common.*

main() {
    var config = TlsClientConfig()
    config.supportedAlpnProtocols = ["h2"]

    // Custom validation
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
