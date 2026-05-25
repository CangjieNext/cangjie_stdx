# Functions

## func getGlobalCryptoKit()

```cangjie
public func getGlobalCryptoKit(): CryptoKit
```

Function: Gets the currently globally used cryptographic suite.

Return Value:

- [CryptoKit](./crypto_common_package_interfaces.md#interface-cryptokit) - The currently globally used cryptographic suite.

Exceptions:

- [CryptoException](./crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if no global cryptographic suite is set.

## func setGlobalCryptoKit(CryptoKit)

```cangjie
public func setGlobalCryptoKit(kit: CryptoKit): Unit
```

Function: Sets the globally used cryptographic suite.

Parameters:

- kit: [CryptoKit](./crypto_common_package_interfaces.md#interface-cryptokit) - The global cryptographic suite.
