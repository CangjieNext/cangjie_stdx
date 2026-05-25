# Interfaces

## interface TlsConfig

```cangjie
public interface TlsConfig {
    mut prop verifyMode: CertificateVerifyMode
    mut prop supportedAlpnProtocols: Array<String>
    mut prop supportedVersions: Array<TlsVersion>
    mut prop supportedCipherSuites: Map<TlsVersion, Array<String>>
    mut prop certificate: ?(Array<Certificate>, PrivateKey)
}
```

Function: TLS configuration interface for adapting different TLS implementations.

### prop certificate

```cangjie
mut prop certificate: ?(Array<Certificate>, PrivateKey)
```

Function: Certificate for TLS server or client, including certificate chain and private key.

Type: ?(Array\<[Certificate](../../../../crypto/common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-certificate)>, [PrivateKey](../../../../crypto/common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey))

### prop supportedAlpnProtocols

```cangjie
mut prop supportedAlpnProtocols: Array<String>
```

Function: List of supported application-layer protocols.

Type: Array\<String>

### prop supportedCipherSuites

```cangjie
mut prop supportedCipherSuites: Map<TlsVersion, Array<String>>
```

Function: Supported cipher suites.

Type: Map\<[TlsVersion](./tls_common_package_enums.md#enum-tlsversion), Array\<String>>

### prop supportedVersions

```cangjie
mut prop supportedVersions: Array<TlsVersion>
```

Function: Supported TLS versions.

Type: Array\<[TlsVersion](./tls_common_package_enums.md#enum-tlsversion)>

### prop verifyMode

```cangjie
mut prop verifyMode: CertificateVerifyMode
```

Function: Certificate verification mode.

Type: [CertificateVerifyMode](./tls_common_package_enums.md#enum-certificateverifymode)

## interface TlsConnection

```cangjie
public interface TlsConnection <: StreamingSocket {
    func handshake(timeout!: ?Duration): TlsHandshakeResult
    prop handshakeResult: ?TlsHandshakeResult
}
```

Function: TLS connection interface for adapting different TLS implementations.

Parent Types:

- StreamingSocket

### prop handshakeResult

```cangjie
prop handshakeResult: ?TlsHandshakeResult
```

Function: Get TLS handshake result.

Type: ?[TlsHandshakeResult](#interface-tlshandshakeresult)

### func handshake(?Duration)

```cangjie
func handshake(timeout!: ?Duration): TlsHandshakeResult
```

Function: Perform TLS handshake and return the handshake result.

Parameters:

- timeout!: ?Duration - Handshake timeout duration.

Return Value:

- [TlsHandshakeResult](#interface-tlshandshakeresult) - Handshake result.

## interface TlsHandshakeResult

```cangjie
public interface TlsHandshakeResult {
    prop version: TlsVersion
    prop cipherSuite: String
    prop peerCertificate: Array<Certificate>
    prop session: ?TlsSession
    prop alpnProtocol: String
    prop serverName: String
}
```

Function: TLS handshake result interface. Used to obtain information negotiated during the TLS handshake process.

### prop alpnProtocol

```cangjie
prop alpnProtocol: String
```

Function: Get the application-layer protocol. For example, "http/1.1", "h2".

Type: String

### prop cipherSuite

```cangjie
prop cipherSuite: String
```

Function: Get the TLS cipher suite.

Type: String

### prop peerCertificate

```cangjie
prop peerCertificate: Array<Certificate>
```

Function: Get the peer certificate.

Type: [Certificate](../../../../crypto/common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-certificate)

### prop serverName

```cangjie
prop serverName: String
```

Function: Get the server hostname.

Type: String

### prop session

```cangjie
prop session: ?TlsSession
```

Function: Get the TLS session. Clients can capture the current session after a successful handshake for subsequent reuse.

Type: ?[TlsSession](#interface-tlssession)

### prop version

```cangjie
prop version: TlsVersion
```

Function: Get the TLS version.

Type: [TlsVersion](tls_common_package_enums.md#enum-tlsversion)

## interface TlsKit

```cangjie
public interface TlsKit {
    func getTlsServer(socket: StreamingSocket, config: TlsConfig, session!: ?TlsSession): TlsConnection
    func getTlsClient(socket: StreamingSocket, config: TlsConfig, session!: ?TlsSession): TlsConnection
    func getTlsServerSession(name: String): TlsSession
}
```

Function: TLS kit interface. Provided by specific TLS implementations for obtaining TLS server/client connections and server sessions.

### func getTlsClient(StreamingSocket, TlsConfig, ?TlsSession)

```cangjie
func getTlsClient(socket: StreamingSocket, config: TlsConfig, session!: ?TlsSession): TlsConnection
```

Function: Create a client TLS connection based on the provided StreamingSocket instance, which can be used for TLS handshake.

Parameters:

- socket: StreamingSocket - Socket obtained after TCP connection establishment.
- config: [TlsConfig](#interface-tlsconfig) - Client TLS configuration.
- session!: ?[TlsSession](#interface-tlssession) - TLS session. If an available TLS session exists, it can be used for session resumption to save TLS connection establishment time.

Return Value:

- [TlsConnection](#interface-tlsconnection) - Constructed client TLS connection.

### func getTlsServer(StreamingSocket, TlsConfig, ?TlsSession)

```cangjie
func getTlsServer(socket: StreamingSocket, config: TlsConfig, session!: ?TlsSession): TlsConnection
```

Function: Create a server TLS connection based on the provided StreamingSocket instance, which can be used for TLS handshake.

Parameters:

- socket: StreamingSocket - Socket obtained after TCP connection establishment.
- config: [TlsConfig](#interface-tlsconfig) - Server TLS configuration.
- session!: ?[TlsSession](#interface-tlssession) - TLS session. If an available TLS session exists, it can be used for session resumption to save TLS connection establishment time.

Return Value:

- [TlsConnection](#interface-tlsconnection) - Constructed server TLS connection.

### func getTlsServerSession(String)

```cangjie
func getTlsServerSession(name: String): TlsSession
```

Function: Create a [TlsSession](#interface-tlssession) instance by name, where the name is used to distinguish TLS servers.

Parameters:

- name: String - Session name.

Return Value:

- [TlsSession](#interface-tlssession) - Created [TlsSession](#interface-tlssession) instance.

## interface TlsSession

```cangjie
public interface TlsSession {}
```

Function: TLS session interface. Used to record TLS session information, provided and used by specific TLS implementations.
