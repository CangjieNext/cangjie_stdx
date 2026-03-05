# cangjie_stdx::crypto

## Introduction

The `cangjie_stdx::crypto` module provides a comprehensive utility library for cryptographic operations. It includes secure encryption capabilities, message digest algorithms, asymmetric encryption and decryption, signature algorithms, and digital certificate processing functions.

## Features

- **Symmetric Encryption**: Supports various symmetric encryption algorithms
- **Asymmetric Cryptography**: Provides public-key cryptography operations
- **Message Digest**: Implements hash algorithms for data integrity verification
- **Digital Signatures**: Enables signing and verification of digital signatures
- **Certificate Processing**: Handles digital certificates for secure communication
- **Key Management**: Provides utilities for cryptographic key generation and management

## Submodules

- **cangjie_stdx::crypto.common**: Common cryptographic utilities and constants
- **cangjie_stdx::crypto.crypto**: Core cryptographic operations
- **cangjie_stdx::crypto.digest**: Message digest and hash algorithms
- **cangjie_stdx::crypto.keys**: Cryptographic key management
- **cangjie_stdx::crypto.kit**: Additional cryptographic toolkits

## Usage

To use the crypto module in your project, add the following dependency to your `cjpm.toml`:

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

Then import the crypto module:

```cj
import cangjie_stdx::crypto
```

## Documentation

For detailed API documentation, please refer to the [stdx API Documentation](../../doc/summary_cjnative_EN.md).

## Security Notice

This module uses OpenSSL for cryptographic operations. Ensure that you are using a secure and up-to-date version of OpenSSL.

## License

This module is part of the Cangjie stdx project and follows the same license terms.
