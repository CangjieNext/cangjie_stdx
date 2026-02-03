# stdx.net.tls.common

## 功能介绍

tls.common 包提供了 TLS 相关的抽象接口，用于适配多种 TLS 实现。

通过实现 [TlsKit](./tls_common_package_api/tls_common_package_interfaces.md#interface-tlskit) 及相关接口，可以自定义 [stdx.net.http](../../http/http_package_overview.md) 包中所使用的 TLS 实现。

[stdx.net.tls](../tls_package_overview.md) 包提供了一种基于 OpenSSL 的默认实现，详见 [stdx.net.tls](../tls_package_overview.md) 包。若要使用默认实现，需要显式导入 [stdx.net.tls](../tls_package_overview.md) 包。

## API 列表

### 函数

| 函数名                                                                                                     | 功能                          |
| ---------------------------------------------------------------------------------------------------------- | ----------------------------- |
| [getGlobalTlsKit()](./tls_common_package_api/tls_common_package_funcs.md#func-getglobaltlskit)             | 获取当前全局使用的 TLS 套件。 |
| [setGlobalTlsKit(TlsKit)](./tls_common_package_api/tls_common_package_funcs.md#func-setglobaltlskittlskit) | 设置全局使用的 TLS 套件。     |

### 接口

| 接口名                                                                                               | 功能                                                                             |
| ---------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| [TlsConfig](./tls_common_package_api/tls_common_package_interfaces.md#interface-tlsconfig)           | TLS 配置接口，用于适配不同的 TLS 实现。                                          |
| [TlsConnection](./tls_common_package_api/tls_common_package_interfaces.md#interface-tlsconnection)   | TLS 连接接口，用于适配不同的 TLS 实现。                                          |
| [TlsHandshakeResult](./tls_common_package_api/tls_common_package_interfaces.md#prop-handshakeresult) | TLS 握手结果接口。用于获取 TLS 握手过程中协商得到的信息。                        |
| [TlsKit](./tls_common_package_api/tls_common_package_interfaces.md#interface-tlskit)                 | TLS 套件接口。由具体 TLS 实现提供，用于获取 TLS 服务端、客户端连接和服务端会话。 |
| [TlsSession](./tls_common_package_api/tls_common_package_interfaces.md#interface-tlssession)         | TLS 会话接口。用于记录 TLS 会话信息，由具体 TLS 实现提供和使用。                 |

### 枚举

| 枚举名                                                                                                   | 功能                   |
| -------------------------------------------------------------------------------------------------------- | ---------------------- |
| [CertificateVerifyMode](./tls_common_package_api/tls_common_package_enums.md#enum-certificateverifymode) | 对证书验证的处理模式。 |
| [TlsVersion](./tls_common_package_api/tls_common_package_enums.md#enum-tlsversion)                       | TLS 协议版本。         |

### 异常类

| 类名                                                                                         | 功能                               |
| -------------------------------------------------------------------------------------------- | ---------------------------------- |
| [TlsException](./tls_common_package_api/tls_common_package_exceptions.md#class-tlsexception) | TLS 处理出现错误时抛出的异常类型。 |
