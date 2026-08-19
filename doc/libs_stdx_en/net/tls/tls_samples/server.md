# Server-Side Example

> **Note:**
>
> You need to prepare the certificate files yourself.

Example:

<!-- compile -->
```cangjie
import std.io.*
import std.fs.{File, OpenMode}
import std.net.{TcpServerSocket, TcpSocket}
import stdx.crypto.x509.X509Certificate
import stdx.crypto.keys.GeneralPrivateKey
import stdx.net.tls.*

// Paths to certificate and private key (user must provide these)
let certificatePath = "./files/apiserver.crt"
let certificateKeyPath = "./files/apiserver.key"

main() {
    // Parse certificate and private key
    let pem = readTextFromFile(certificatePath)
    let keyText = readTextFromFile(certificateKeyPath)

    let certificate = X509Certificate.decodeFromPem(pem)
    let privateKey = GeneralPrivateKey.decodeFromPem(keyText)

    let config = TlsServerConfig(certificate, privateKey)

    // Optional: Enable TLS session resumption
    let sessions = TlsServerSession.fromName("my-server")

    try (server = TcpServerSocket(bindAt: 8443)) {
        server.bind()

        server.acceptLoop {
            clientSocket => try (tls = TlsSocket.server(clientSocket, serverConfig: config, session: sessions)) {
                tls.handshake()
                let buffer = Array<Byte>(100, repeat: 0)
                tls.read(buffer)
                println(buffer)
            }
        }
    }
}

extend TcpServerSocket {
    func acceptLoop(handler: (TcpSocket) -> Unit) {
        while (true) {
            let client = accept()
            spawn {
                try {
                    handler(client)
                } finally {
                    client.close()
                }
            }
        }
    }
}

func readTextFromFile(path: String): String {
    var str = ""
    try (file = File(path, Read)) {
        str = String.fromUtf8(readToEnd(file))
    }
    str
}
```
