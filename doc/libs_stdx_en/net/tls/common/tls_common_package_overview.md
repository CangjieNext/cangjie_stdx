# stdx.net.tls.common

## Feature Overview

The tls.common package provides abstract interfaces related to TLS for adapting various TLS implementations.

By implementing the [TlsKit](./tls_common_package_api/tls_common_package_interfaces.md#interface-tlskit) interface and related interfaces, you can customize the TLS implementation used in the [stdx.net.http](../../http/http_package_overview.md) package.

The [stdx.net.tls](../tls_package_overview.md) package provides a default OpenSSL-based implementation. For details, refer to the [stdx.net.tls](../tls_package_overview.md) package. To use the default implementation, you need to explicitly import the [stdx.net.tls](../tls_package_overview.md) package.

## API List

### Functions

| Function Name                                                                                                     | Description                          |
| ---------------------------------------------------------------------------------------------------------- | ----------------------------- |
| [getGlobalTlsKit()](./tls_common_package_api/tls_common_package_funcs.md#func-getglobaltlskit)             | Gets the currently globally used TLS kit. |
| [setGlobalTlsKit(TlsKit)](./tls_common_package_api/tls_common_package_funcs.md#func-setglobaltlskittlskit) | Sets the globally used TLS kit.     |

### Interfaces

| Interface Name                                                                                               | Description                                                                             |
| ---------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| [TlsConfig](./tls_common_package_api/tls_common_package_interfaces.md#interface-tlsconfig)           | TLS configuration interface for adapting different TLS implementations.                                          |
| [TlsConnection](./tls_common_package_api/tls_common_package_interfaces.md#interface-tlsconnection)   | TLS connection interface for adapting different TLS implementations.                                          |
| [TlsHandshakeResult](./tls_common_package_api/tls_common_package_interfaces.md#prop-handshakeresult) | TLS handshake result interface. Used to obtain information negotiated during the TLS handshake process.                        |
| [TlsKit](./tls_common_package_api/tls_common_package_interfaces.md#interface-tlskit)                 | TLS kit interface. Provided by specific TLS implementations to obtain TLS server/client connections and server sessions. |
| [TlsSession](./tls_common_package_api/tls_common_package_interfaces.md#interface-tlssession)         | TLS session interface. Used to record TLS session information, provided and used by specific TLS implementations.                 |

### Enums

| Enum Name                                                                                                   | Description                   |
| -------------------------------------------------------------------------------------------------------- | ---------------------- |
| [CertificateVerifyMode](./tls_common_package_api/tls_common_package_enums.md#enum-certificateverifymode) | Certificate verification handling modes. |
| [TlsVersion](./tls_common_package_api/tls_common_package_enums.md#enum-tlsversion)                       | TLS protocol versions.         |

### Exception Classes

| Class Name                                                                                         | Description                               |
| -------------------------------------------------------------------------------------------- | ---------------------------------- |
| [TlsException](./tls_common_package_api/tls_common_package_exceptions.md#class-tlsexception) | Exception type thrown when TLS processing encounters errors. |
