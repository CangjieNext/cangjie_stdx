# stdx.crypto.common

## Feature Description

The crypto.common package provides interfaces related to encryption and decryption.

## API List

### Functions

| Function Name                                                                                                                       | Description                         |
| ------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------- |
| [getGlobalCryptoKit()](./crypto_common_package_api/crypto_common_package_funcs.md#func-getglobalcryptokit)                           | Gets the currently globally used cryptographic suite. |
| [setGlobalCryptoKit(CryptoKit)](./crypto_common_package_api/crypto_common_package_funcs.md#func-setglobalcryptokitcryptokit)         | Sets the globally used cryptographic suite.          |

### Interfaces

| Interface Name                                                                                                       | Description                                                   |
| -------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| [Certificate](./crypto_common_package_api/crypto_common_package_interfaces.md#interface-certificate)                 | Certificate interface for adapting different cryptographic suites. |
| [CryptoKit](./crypto_common_package_api/crypto_common_package_interfaces.md#interface-cryptokit)                     | Cryptographic suite interface. Provides random number generator and DER/PEM decoding capabilities. |
| [DHParameters](./crypto_common_package_api/crypto_common_package_interfaces.md#interface-dhparameters)               | DH key parameters interface.                                   |
| [Key](./crypto_common_package_api/crypto_common_package_interfaces.md#interface-key)                                 | Key interface.                                                 |
| [PrivateKey](./crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey)                   | Private key interface.                                         |
| [PublicKey](./crypto_common_package_api/crypto_common_package_interfaces.md#interface-publickey)                     | Public key interface.                                          |
| [RandomGenerator](./crypto_common_package_api/crypto_common_package_interfaces.md#interface-randomgenerator)         | Secure random number generator interface.                      |

### Structs

| Struct Name                                                                                 | Description                          |
| ------------------------------------------------------------------------------------------- | ------------------------------------- |
| [DerBlob](./crypto_common_package_api/crypto_common_package_structs.md#struct-derblob)       | Crypto-supported configuration for binary certificate streams. |
| [Pem](./crypto_common_package_api/crypto_common_package_structs.md#struct-pem)              | Pem structure.                       |
| [PemEntry](./crypto_common_package_api/crypto_common_package_structs.md#struct-pementry)     | PEM text format.                     |

### Exception Classes

| Exception Class Name                                                                                                 | Description                               |
| -------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| [CryptoException](./crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception)             | This exception is thrown when encryption/decryption errors occur. |
