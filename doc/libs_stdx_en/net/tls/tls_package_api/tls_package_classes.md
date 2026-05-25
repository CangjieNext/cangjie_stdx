# Classes

## class DefaultTlsKit

```cangjie
public class DefaultTlsKit <: TlsKit
```

Function: Default implementation of [TlsKit](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlskit). Used to obtain TLS server/client connections and server sessions.

Parent Types:

- [TlsKit](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlskit)

### func getTlsClient(StreamingSocket, TlsConfig, ?TlsSession)

```cangjie
public func getTlsClient(socket: StreamingSocket, config: TlsConfig, session!: ?TlsSession): TlsConnection
```

Function: Creates a client TLS connection based on the provided StreamingSocket instance, which can be used for TLS handshake.

Parameters:

- socket: StreamingSocket - The socket obtained after TCP connection establishment.
- config: [TlsConfig](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlsconfig) - Client TLS configuration.
- session!: ?[TlsSession](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlssession) - TLS session. If an available TLS session exists, it can be used for session resumption to save TLS connection establishment time.

Return Value:

- [TlsConnection](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlsconnection) - The constructed client TLS connection.

### func getTlsServer(StreamingSocket, TlsConfig, ?TlsSession)

```cangjie
public func getTlsServer(socket: StreamingSocket, config: TlsConfig, session!: ?TlsSession): TlsConnection
```

Function: Creates a server TLS connection based on the provided StreamingSocket instance, which can be used for TLS handshake.

Parameters:

- socket: StreamingSocket - The socket obtained after TCP connection establishment.
- config: [TlsConfig](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlsconfig) - Server TLS configuration.
- session!: ?[TlsSession](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlssession) - TLS session. If an available TLS session exists, it can be used for session resumption to save TLS connection establishment time.

Return Value:

- [TlsConnection](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlsconnection) - The constructed server TLS connection.

### func getTlsServerSession(String)

```cangjie
public func getTlsServerSession(name: String): TlsSession
```

Function: Creates a [TlsSession](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlssession) instance by name, which is used to distinguish TLS servers.

Parameters:

- name: String - Session name.

Return Value:

- [TlsSession](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlssession) - The created [TlsSession](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlssession) instance.

## class KeylessTlsServerConfig

```cangjie
public class KeylessTlsServerConfig <: TlsConfig {
    public mut prop clientIdentityRequired: TlsClientIdentificationMode
    public mut prop keylogCallback: ?(TlsSocket, String) -> Unit
    public mut prop verifyMode: CertificateVerifyMode
    public init(certChain: Array<X509Certificate>, signCallback: KeylessSignFunc, decryptCallback!: ?KeylessDecryptFunc = None<KeylessDecryptFunc>)
}
```

Function: Provides server configuration for keyless handshake.

> **Note:**
>
> Currently only supports ECDHE-RSA-AES256-GCM-SHA384, TLS_AES_256_GCM_SHA384, TLS_CHACHA20_POLY1305_SHA256 cipher suites. Other cipher suites are not guaranteed to be available.

Parent Types:

- [TlsConfig](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlsconfig)

### var keylogCallback

```cangjie
public var keylogCallback: ?(TlsSocket, String) -> Unit = None
```

Function: Callback function during handshake process, provides TLS initial key data for debugging and decryption purposes.

Type: ?([TlsSocket](tls_package_classes.md#class-tlssocket), String) -> Unit

### prop certificate

```cangjie
public mut prop certificate: ?(Array<Certificate>, PrivateKey)
```

Function: Sets or gets the server certificate and corresponding private key file. The certificate must be of [X509Certificate](../../../crypto/x509/x509_package_api/x509_package_classes.md#class-x509certificate) type. Cannot be set to None.

> **Note:**
>
> The `PrivateKey` returned by this property is a meaningless dummy key, unrelated to `Array<Certificate>`.

Type: ?(Array\<[Certificate](../../../crypto/common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-certificate)>, [PrivateKey](../../../crypto/common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey))

Exceptions:

- [TlsException](../common/tls_common_package_api/tls_common_package_exceptions.md#class-tlsexception) - Thrown when the server certificate is not of [X509Certificate](../../../crypto/x509/x509_package_api/x509_package_classes.md#class-x509certificate) type, or when the server certificate and corresponding private key file are set to None.

### prop clientIdentityRequired

```cangjie
public mut prop clientIdentityRequired: TlsClientIdentificationMode
```

Function: Sets or gets the client authentication mode required by the server. Default value is [TlsClientIdentificationMode](tls_package_enums.md#enum-tlsclientidentificationmode).Disable, which means no client authentication of server certificate is required, and no client certificate is required.

Type: [TlsClientIdentificationMode](tls_package_enums.md#enum-tlsclientidentificationmode)

### prop dhParameters

```cangjie
public mut prop dhParameters: ?DHParameters
```

Function: Specifies the server's DH key parameters. Default is `None`, where OpenSSL automatically generated parameter values are used by default.

Type: ?[DHParameters](../../../crypto/common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-dhparameters)

### prop securityLevel

```cangjie
public mut prop securityLevel: Int32
```

Function: Specifies the server's security level. Default value is 2, with optional parameter values in the range [0,5]. For parameter value meanings, refer to [openssl-SSL_CTX_set_security_level](https://www.openssl.org/docs/man1.1.1/man3/SSL_CTX_set_security_level.html) documentation.

Type: Int32

Exceptions:

- IllegalArgumentException - Thrown when the configuration value is not in the 0-5 range.

### prop supportedAlpnProtocols

```cangjie
public mut prop supportedAlpnProtocols: Array<String>
```

Function: Application Layer Protocol Negotiation protocols. If the client attempts to negotiate these protocols, the server will select intersecting protocol names. If the client does not attempt to negotiate protocols, this configuration will be ignored.

Type: Array\<String>

Exceptions:

- IllegalArgumentException - Thrown when list elements contain '\0' character.

### prop supportedCipherSuites

```cangjie
public mut prop supportedCipherSuites: Map<TlsVersion, Array<String>>
```

Function: Sets or gets the cipher suites corresponding to each TLS version.

Type: Map\<[TlsVersion](../common/tls_common_package_api/tls_common_package_enums.md#enum-tlsversion), Array\<String>>

Exceptions:

- IllegalArgumentException - Thrown when setting cipher suites through the `Map` parameter, if any TLS version's corresponding cipher suite string contains null character `\0`.

### prop supportedVersions

```cangjie
public mut prop supportedVersions: Array<TlsVersion>
```

Function: Sets or gets the supported TLS versions.

Type: Array\<[TlsVersion](../common/tls_common_package_api/tls_common_package_enums.md#enum-tlsversion)>

### prop verifyMode

```cangjie
public mut prop verifyMode: CertificateVerifyMode
```

Function: Sets or gets the verification mode. Default value is [CertificateVerifyMode](../common/tls_common_package_api/tls_common_package_enums.md#enum-certificateverifymode).Default, which verifies system certificates.

Type: [CertificateVerifyMode](../common/tls_common_package_api/tls_common_package_enums.md#enum-certificateverifymode)

### init(Array\<X509Certificate>, KeylessSignFunc, ?KeylessDecryptFunc)

```cangjie
public init(certChain: Array<X509Certificate>, signCallback: KeylessSignFunc, decryptCallback!: ?KeylessDecryptFunc = None<KeylessDecryptFunc>)
```

Function: Constructs a [KeylessTlsServerConfig](./tls_package_classes.md#class-keylesstlsserverconfig) object.

Parameters:

- certChain: Array\<[X509Certificate](../../../crypto/x509/x509_package_api/x509_package_classes.md#class-x509certificate)> - Certificate object.
- signCallback: [KeylessSignFunc](./tls_package_type.md#type-keylesssignfunc) - Signing callback function.
- decryptCallback!: ?[KeylessDecryptFunc](./tls_package_type.md#type-keylessdecryptfunc) - Decryption callback function. Defaults to None\<[KeylessDecryptFunc](./tls_package_type.md#type-keylessdecryptfunc)>.

Exceptions:

- IllegalArgumentException - Thrown when `certChain` is empty.

## class TlsClientSession

```cangjie
public class TlsClientSession <: TlsSession & Equatable<TlsClientSession> & ToString & Hashable
```

Function: This struct represents an established client session. Users cannot create instances of this struct, and its internal structure is not visible to users.

When a client TLS handshake succeeds, a session is generated. If the connection is lost for some reason, the client can reuse this session through the session ID, omitting the handshake process.

Parent Types:

- [TlsSession](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlssession)
- Equatable\<[TlsClientSession](#class-tlsclientsession)>
- ToString
- Hashable

### func hashCode()

```cangjie
public override func hashCode(): Int64
```

Function: Generates a hash value for the session ID.

Return Value:

- Int64 - The hash value of the session ID.

### func toString()

```cangjie
public override func toString(): String
```

Function: Generates a string representation of the session ID.

Return Value:

- String - [TlsClientSession](tls_package_classes.md#class-tlsclientsession)(session ID string).

### operator func !=(TlsClientSession)

```cangjie
public override operator func !=(other: TlsClientSession): Bool
```

Function: Determines whether the session IDs are different.

Parameters:

- other: [TlsClientSession](tls_package_classes.md#class-tlsclientsession) - The session object to compare.

Return Value:

- Bool - Returns `true` if the session objects are different; otherwise, returns `false`.

### operator func ==(TlsClientSession)

```cangjie
public override operator func ==(other: TlsClientSession): Bool
```

Function: Determines whether the session IDs are the same.

Parameters:

- other: [TlsClientSession](tls_package_classes.md#class-tlsclientsession) - The session object to compare.

Return Value:

- Bool - Returns `true` if the session objects are the same; otherwise, returns `false`.

## class TlsServerSession

```cangjie
public class TlsServerSession <: TlsSession & Equatable<TlsServerSession> & ToString
```

Function: This class represents the TLS session context, providing information to clients to ensure they are connecting to the same server instance. It is used to validate client legitimacy during connection resumption.

> **Note:**
>
> When a client attempts to resume a session, both parties must ensure they are resuming the session with a legitimate peer.

Parent Types:

- [TlsSession](./../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlssession)
- Equatable\<[TlsServerSession](#class-tlsserversession)>
- ToString

### static func fromName(String)

```cangjie
public static func fromName(name: String): TlsServerSession
```

Function: Creates a [TlsServerSession](tls_package_classes.md#class-tlsserversession) instance by name.

Retrieves a [TlsServerSession](tls_package_classes.md#class-tlsserversession) object using the name stored in [TlsServerSession](tls_package_classes.md#class-tlsserversession). This name is used to distinguish TLS servers, so clients rely on this name to avoid accidentally attempting to resume connections with the wrong server. The name does not necessarily need to be cryptographically secure, as the underlying implementation can handle this. Two TlsServerSession instances returned from this function with the same name may not be equal and are not guaranteed to be interchangeable. Although they are created from the same name, the server instance should create a single TlsServerSession throughout its lifecycle and use it in every [TlsSocket](tls_package_classes.md#class-tlssocket).[server](tls_package_classes.md#static-func-serverstreamingsocket-tlsserversession-tlsserverconfig)() call.

Parameters:

- name: String - The session context name.

Return Value:

- [TlsServerSession](tls_package_classes.md#class-tlsserversession) - The session context.

### func toString()

```cangjie
public override func toString(): String
```

Function: Generates a string representation of the session context name.

Return Value:

- String - [TlsServerSession](tls_package_classes.md#class-tlsserversession)(session context name string).

### operator func !=(TlsServerSession)

```cangjie
public override operator func !=(other: TlsServerSession): Bool
```

Function: Determines whether the names of two [TlsServerSession](tls_package_classes.md#class-tlsserversession) instances are different.

Parameters:

- other: [TlsServerSession](tls_package_classes.md#class-tlsserversession) - The session context object to compare.

Return Value:

- Bool - Returns `true` if the [TlsServerSession](tls_package_classes.md#class-tlsserversession) objects are different; otherwise, returns `false`.

### operator func ==(TlsServerSession)

```cangjie
public override operator func ==(other: TlsServerSession): Bool
```

Function: Determines whether the names of two [TlsServerSession](tls_package_classes.md#class-tlsserversession) instances are the same.

Parameters:

- other: [TlsServerSession](tls_package_classes.md#class-tlsserversession) - The session context object to compare.

Return Value:

- Bool - Returns `true` if the [TlsServerSession](tls_package_classes.md#class-tlsserversession) objects are the same; otherwise, returns `false`.

## class TlsSocket

```cangjie
public class TlsSocket <: TlsConnection & Equatable<TlsSocket> & Hashable
```

Function: [TlsSocket](tls_package_classes.md#class-tlssocket) is used to create an encrypted transmission channel between clients and servers.

Parent Types:

- [TlsConnection](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlsconnection)
- Equatable\<[TlsSocket](#class-tlssocket)>
- Hashable

### prop certificate

```cangjie
public prop certificate: Array<X509Certificate>
```

Function: Gets the local certificate.

Type: ?Array\<[X509Certificate](../../../crypto/x509/x509_package_api/x509_package_classes.md#class-x509certificate)>

Exceptions:

- [TlsException](../common/tls_common_package_api/tls_common_package_exceptions.md#class-tlsexception) - Thrown when the socket has not completed TLS handshake or the local TLS socket is closed.

### prop handshakeResult

```cangjie
public prop handshakeResult: ?TlsHandshakeResult
```

Function: Gets the TLS handshake result.

Type: [TlsHandshakeResult](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlshandshakeresult)

### prop localAddress

```cangjie
public override prop localAddress: SocketAddress
```

Function: Reads the local address of [TlsSocket](tls_package_classes.md#class-tlssocket).

Type: SocketAddress

Exceptions:

- SocketException - Thrown when the underlying TCP socket for local connection is closed.
- [TlsException](../common/tls_common_package_api/tls_common_package_exceptions.md#class-tlsexception) - Thrown when the local TLS socket is closed.

### prop readTimeout

```cangjie
public override mut prop readTimeout: ?Duration
```

Function: Reads/writes the read timeout of [TlsSocket](tls_package_classes.md#class-tlssocket).

Type: ?Duration

Exceptions:

- SocketException - Thrown when the underlying TCP socket for local connection is closed.
- [TlsException](../common/tls_common_package_api/tls_common_package_exceptions.md#class-tlsexception) - Thrown when the local TLS socket is closed.
- IllegalArgumentException - Thrown when the set read timeout is negative.

### prop remoteAddress

```cangjie
public override prop remoteAddress: SocketAddress
```

Function: Reads the remote address of [TlsSocket](tls_package_classes.md#class-tlssocket).

Type: SocketAddress

Exceptions:

- SocketException - Thrown when the underlying TCP socket for local connection is closed.
- [TlsException](../common/tls_common_package_api/tls_common_package_exceptions.md#class-tlsexception) - Thrown when the local TLS socket is closed.

### prop socket

```cangjie
public prop socket: StreamingSocket
```

Function: The StreamingSocket used to create [TlsSocket](tls_package_classes.md#class-tlssocket).

Type: StreamingSocket

Exceptions:

- [TlsException](../common/tls_common_package_api/tls_common_package_exceptions.md#class-tlsexception) - Thrown when the local TLS socket is closed.

### prop writeTimeout

```cangjie
public override mut prop writeTimeout: ?Duration
```

Function: Reads/writes the write timeout of [TlsSocket](tls_package_classes.md#class-tlssocket).

Type: ?Duration

Exceptions:

- SocketException - Thrown when the underlying TCP socket for local connection is closed.
- [TlsException](../common/tls_common_package_api/tls_common_package_exceptions.md#class-tlsexception) - Thrown when the local TLS socket is closed.
- IllegalArgumentException - Thrown when the set write timeout is negative.

### static func client(StreamingSocket, ?TlsClientSession, TlsClientConfig)

```cangjie
public static func client(
    socket: StreamingSocket,
    session!: ?TlsClientSession = None,
    clientConfig!: TlsClientConfig = TlsClientConfig()
): TlsSocket
```

Function: Creates a client TLS socket for the specified address based on the provided StreamingSocket instance, which can be used for client TLS handshake and session.

Parameters:

- socket: StreamingSocket - The client TCP socket connected to the server.
- session!: ?[TlsClientSession](tls_package_classes.md#class-tlsclientsession) - TLS session ID. If an available TLS session exists, it can be used to resume the historical TLS session, saving TLS connection establishment time, although the negotiation may still fail. Defaults to `None`.
- clientConfig!: [TlsClientConfig](tls_package_structs.md#struct-tlsclientconfig) - Client configuration. Defaults to [TlsClientConfig](tls_package_structs.md#struct-tlsclientconfig)().

Return Value:

- [TlsSocket](tls_package_classes.md#class-tlssocket) - The constructed [TlsSocket](tls_package_classes.md#class-tlssocket) instance.

### static func server(StreamingSocket, ?TlsServerSession, KeylessTlsServerConfig)

```cangjie
public static func server(
    socket: StreamingSocket,
    session!: ?TlsServerSession = None,
    serverConfig!: KeylessTlsServerConfig
): TlsSocket
```

Function: Creates a server TLS socket for the specified address based on the provided StreamingSocket instance, which can be used for server TLS handshake and session in keyless scenarios.

Parameters:

- socket: StreamingSocket - The socket accepted after TCP connection establishment.
- session!: ?[TlsServerSession](tls_package_classes.md#class-tlsserversession) - TLS session ID. If an available TLS session exists, it can be used to resume the historical TLS session, saving TLS connection establishment time, although the negotiation may still fail. Defaults to None.
- serverConfig!: [KeylessTlsServerConfig](./tls_package_classes.md#class-keylesstlsserverconfig) - Server configuration.

Return Value:

- [TlsSocket](tls_package_classes.md#class-tlssocket) - The constructed [TlsSocket](tls_package_classes.md#class-tlssocket) instance.

### static func server(StreamingSocket, ?TlsServerSession, TlsServerConfig)

```cangjie
public static func server(
    socket: StreamingSocket,
    session!: ?TlsServerSession = None,
    serverConfig!: TlsServerConfig
): TlsSocket
```

Function: Creates a server TLS socket for the specified address based on the provided StreamingSocket instance, which can be used for server TLS handshake and session.

Parameters:

- socket: StreamingSocket - The socket accepted after TCP connection establishment.
- session!: ?[TlsServerSession](tls_package_classes.md#class-tlsserversession) - TLS session ID. If an available TLS session exists, it can be used to resume the historical TLS session, saving TLS connection establishment time, although the negotiation may still fail. Defaults to None.
- serverConfig!: [TlsServerConfig](tls_package_structs.md#struct-tlsserverconfig) - Server configuration. Defaults to [TlsServerConfig](tls_package_structs.md#struct-tlsserverconfig)().

Return Value:

- [TlsSocket](tls_package_classes.md#class-tlssocket) - The constructed [TlsSocket](tls_package_classes.md#class-tlssocket) instance.

### func close()

```cangjie
public func close(): Unit
```

Function: Closes the socket.

Exceptions:

- SocketException - Thrown when the underlying connection cannot be closed.

### func handshake(?Duration)

```cangjie
public func handshake(timeout!: ?Duration = None): TlsHandshakeResult
```

Function: Performs TLS handshake. Does not support renegotiation and can only be called once. The calling object can be either a client or server [TlsSocket](tls_package_classes.md#class-tlssocket).

Parameters:

- timeout!: ?Duration - Handshake timeout. Defaults to None, meaning no timeout is set, and the default 30s timeout is used.

Return Value:

- [TlsHandshakeResult](../common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlshandshakeresult) - The handshake result.

Exceptions:

- SocketException - Thrown when the underlying TCP socket for local connection is closed.
- SocketTimeoutException - Thrown when the underlying TCP socket connection times out.
- [TlsException](../common/tls_common_package_api/tls_common_package_exceptions.md#class-tlsexception) - Thrown when the handshake has already started or completed, or when a system error occurs during the handshake phase.
- IllegalArgumentException - Thrown when the set handshake timeout is negative.

### func hashCode()

```cangjie
public override func hashCode(): Int64
```

Function: Returns the hash value of the TLS socket object.

Return Value:

- Int64 - The result obtained after hashing the TLS socket object.

### func isClosed()

```cangjie
public func isClosed(): Bool
```

Function: Returns the closed state of the socket.

Return Value:

- Bool - Returns `true` if the connection is closed; otherwise, returns `false`.

### func read(Array\<Byte>)

```cangjie
public override func read(buffer: Array<Byte>): Int64
```

Function: [TlsSocket](tls_package_classes.md#class-tlssocket) reads data.

Parameters:

- buffer: Array\<Byte> - The array storing the read data content.

Return Value:

- Int64 - The number of bytes of the read data content.

Exceptions:

- SocketException - Throws an exception if the underlying TCP socket of the local connection is closed.
- [TlsException](../common/tls_common_package_api/tls_common_package_exceptions.md#class-tlsexception) - Throws an exception if `buffer` is empty, or if [TlsSocket](tls_package_classes.md#class-tlssocket) is not connected, or if a system error occurs during data reading.

### func toString()

```cangjie
public func toString(): String
```

Function: String representation of the socket, where the string content reflects the current socket state.

> **Note:**
>
> For example: When the socket is ready to start a handshake, this interface will return the string "[TlsSocket](tls_package_classes.md#class-tlssocket)(TcpSocket(\${local address} -> \${remote address}), ready for handshake)".

Return Value:

- String - The string representation of this TLS connection.

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

Function: [TlsSocket](tls_package_classes.md#class-tlssocket) sends data.

Parameters:

- buffer: Array\<Byte> - The array storing the data content to be sent.

Exceptions:

- SocketException - Throws an exception if the underlying TCP socket of the local connection is closed.
- [TlsException](../common/tls_common_package_api/tls_common_package_exceptions.md#class-tlsexception) - Throws an exception if the socket is closed, or if [TlsSocket](tls_package_classes.md#class-tlssocket) is not connected, or if a system error occurs during data writing.

### operator func !=(TlsSocket)

```cangjie
public override operator func !=(other: TlsSocket): Bool
```

Function: Determines whether two [TlsSocket](tls_package_classes.md#class-tlssocket) instances reference different objects.

Parameters:

- other: [TlsSocket](tls_package_classes.md#class-tlssocket) - The TLS socket to compare.

Return Value:

- Bool - Returns `true` if the compared sockets are different; otherwise, returns `false`.

### operator func ==(TlsSocket)

```cangjie
public override operator func ==(other: TlsSocket): Bool
```

Function: Determines whether two [TlsSocket](tls_package_classes.md#class-tlssocket) instances reference the same object.

Parameters:

- other: [TlsSocket](tls_package_classes.md#class-tlssocket) - The TLS socket to compare.

Return Value:

- Bool - Returns `true` if the compared sockets are the same; otherwise, returns `false`.
