# 接口

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

功能：TLS 配置接口，用于适配不同的 TLS 实现。

### prop certificate

```cangjie
mut prop certificate: ?(Array<Certificate>, PrivateKey)
```

功能：TLS 服务端或客户端的证书，包括证书链和私钥。

类型：?(Array\<[Certificate](../../../../crypto/common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-certificate)>, [PrivateKey](../../../../crypto/common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey))

### prop supportedAlpnProtocols

```cangjie
mut prop supportedAlpnProtocols: Array<String>
```

功能：支持的应用层协议列表。

类型：Array\<String>

### prop supportedCipherSuites

```cangjie
mut prop supportedCipherSuites: Map<TlsVersion, Array<String>>
```

功能：支持的加密套件。

类型：Map\<[TlsVersion](./tls_common_package_enums.md#enum-tlsversion), Array\<String>>

### prop supportedVersions

```cangjie
mut prop supportedVersions: Array<TlsVersion>
```

功能：支持的 TLS 版本。

类型：Array\<[TlsVersion](./tls_common_package_enums.md#enum-tlsversion)>

### prop verifyMode

```cangjie
mut prop verifyMode: CertificateVerifyMode
```

功能：证书认证模式。

类型：[CertificateVerifyMode](./tls_common_package_enums.md#enum-certificateverifymode)

## interface TlsConnection

```cangjie
public interface TlsConnection <: StreamingSocket {
    func handshake(timeout!: ?Duration): TlsHandshakeResult
    prop handshakeResult: ?TlsHandshakeResult
}
```

功能：TLS 连接接口，用于适配不同的 TLS 实现。

父类型：

- StreamingSocket

### prop handshakeResult

```cangjie
prop handshakeResult: ?TlsHandshakeResult
```

功能：获取 TLS 握手结果。

类型：?[TlsHandshakeResult](#interface-tlshandshakeresult)

### func handshake(?Duration)

```cangjie
func handshake(timeout!: ?Duration): TlsHandshakeResult
```

功能：进行 TLS 握手，返回握手结果。

参数：

- timeout!: ?Duration - 握手超时时间。

返回值：

- [TlsHandshakeResult](#interface-tlshandshakeresult) - 握手结果。

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

功能：TLS 握手结果接口。用于获取 TLS 握手过程中协商得到的信息。

### prop alpnProtocol

```cangjie
prop alpnProtocol: String
```

功能：获取应用层协议。例如 “http/1.1"、"h2"。

类型：String

### prop cipherSuite

```cangjie
prop cipherSuite: String
```

功能：获取 TLS 加密套件。

类型：String

### prop peerCertificate

```cangjie
prop peerCertificate: Array<Certificate>
```

功能：获取对端证书。

类型：Array\<[Certificate](../../../../crypto/common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-certificate)>

### prop serverName

```cangjie
prop serverName: String
```

功能：获取服务端主机名称。

类型：String

### prop session

```cangjie
prop session: ?TlsSession
```

功能：获取 TLS 会话。客户端可在握手成功后捕获当前会话，后续可重用该会话。

类型：?[TlsSession](#interface-tlssession)

### prop version

```cangjie
prop version: TlsVersion
```

功能：获取 TLS 版本。

类型：[TlsVersion](tls_common_package_enums.md#enum-tlsversion)

## interface TlsKit

```cangjie
public interface TlsKit {
    func getTlsServer(socket: StreamingSocket, config: TlsConfig, session!: ?TlsSession): TlsConnection
    func getTlsClient(socket: StreamingSocket, config: TlsConfig, session!: ?TlsSession): TlsConnection
    func getTlsServerSession(name: String): TlsSession
}
```

功能：TLS 套件接口。由具体 TLS 实现提供，用于获取 TLS 服务端、客户端连接和服务端会话。

### func getTlsClient(StreamingSocket, TlsConfig, ?TlsSession)

```cangjie
func getTlsClient(socket: StreamingSocket, config: TlsConfig, session!: ?TlsSession): TlsConnection
```

功能：根据传入的 StreamingSocket 实例创建客户端 TLS 连接，该连接可用于 TLS 握手。

参数：

- socket: StreamingSocket - TCP 连接建立完成后得到的 socket。
- config: [TlsConfig](#interface-tlsconfig) - 客户端 TLS 配置。
- session!: ?[TlsSession](#interface-tlssession) - TLS 会话。若存在可用的 TLS 会话，则可通过该会话恢复，省去 TLS 建立连接时间。

返回值：

- [TlsConnection](#interface-tlsconnection) - 构造出的客户端 TLS 连接。

### func getTlsServer(StreamingSocket, TlsConfig, ?TlsSession)

```cangjie
func getTlsServer(socket: StreamingSocket, config: TlsConfig, session!: ?TlsSession): TlsConnection
```

功能：根据传入的 StreamingSocket 实例创建服务端 TLS 连接，该连接可用于 TLS 握手。

参数：

- socket: StreamingSocket - TCP 连接建立完成后得到的 socket。
- config: [TlsConfig](#interface-tlsconfig) - 服务端 TLS 配置。
- session!: ?[TlsSession](#interface-tlssession) - TLS 会话。若存在可用的 TLS 会话，则可通过该会话恢复，省去 TLS 建立连接时间。

返回值：

- [TlsConnection](#interface-tlsconnection) - 构造出的服务端 TLS 连接。

### func getTlsServerSession(String)

```cangjie
func getTlsServerSession(name: String): TlsSession
```

功能：通过名称创建 [TlsSession](#interface-tlssession) 实例，该名称用于区分 TLS 服务器。

参数：

- name: String - 会话名称。

返回值：

- [TlsSession](#interface-tlssession) - 创建的 [TlsSession](#interface-tlssession) 实例。

## interface TlsSession

```cangjie
public interface TlsSession {}
```

功能：TLS 会话接口。用于记录 TLS 会话信息，由具体 TLS 实现提供和使用。
