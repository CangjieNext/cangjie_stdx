# cangjie_stdx::net

## Introduction

The `cangjie_stdx::net` module provides network communication and secure transmission functions. It includes support for HTTP and TLS protocols for building networked applications.

## Features

- **HTTP Client/Server**: Provides HTTP client and server functionality
- **TLS Support**: Offers secure communication through TLS/SSL
- **Network Utilities**: Includes common network utility functions
- **Secure Transmission**: Enables encrypted data transmission over networks

## Submodules

- **cangjie_stdx::net.http**: HTTP client and server implementation
- **cangjie_stdx::net.tls**: TLS/SSL support for secure communication
- **cangjie_stdx::net.tls.common**: Common TLS utilities and constants

## Usage

To use the net module in your project, add the following dependency to your `cjpm.toml`:

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

Then import the net module:

```cj
import cangjie_stdx::net
```

## Documentation

For detailed API documentation, please refer to the [stdx API Documentation](../../doc/summary_cjnative_EN.md).

## License

This module is part of the Cangjie stdx project and follows the same license terms.
