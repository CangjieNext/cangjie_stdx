# Classes

## class DefaultCryptoKit

```cangjie
public class DefaultCryptoKit <: CryptoKit
```

Functionality: Default implementation of [CryptoKit](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-cryptokit). Provides random number generator and capabilities for decoding DER and PEM formats.

Parent Types:

- [CryptoKit](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-cryptokit)

> **Note:**
>
> PEM is a Base64-based encoding format.

### func certificateFromDer(DerBlob)

```cangjie
func certificateFromDer(encoded: DerBlob): Certificate
```

Functionality: Decodes a certificate from DER format.

Parameters:

- encoded: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The DerBlob object to be decoded.

Return Value:

- [Certificate](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-certificate) - The decoded certificate.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when the encoded file contains no valid information.
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - Thrown when decoding fails.

### func certificateFromPem(String)

```cangjie
func certificateFromPem(text: String): Array<Certificate>
```

Functionality: Decodes certificates from PEM format.

Parameters:

- text: String - The PEM format string to be decoded.

Return Value:

- Array\<[Certificate](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-certificate)> - The collection of decoded certificates.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when the encoded file contains no valid information.
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - Thrown when decoding fails.

### func dhParametersFromDer(DerBlob)

```cangjie
func dhParametersFromDer(encoded: DerBlob): DHParameters
```

Functionality: Decodes DH key parameters from DER format.

Parameters:

- encoded: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The DerBlob object to be decoded.

Return Value:

- [DHParameters](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-dhparameters) - The decoded DH key parameters.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when the encoded file contains no valid information.
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - Thrown when decoding fails.

### func dhParametersFromPem(String)

```cangjie
func dhParametersFromPem(text: String): DHParameters
```

Functionality: Decodes DH key parameters from PEM format.

Parameters:

- text: String - The PEM format string to be decoded.

Return Value:

- [DHParameters](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-dhparameters) - The decoded DH key parameters.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when the encoded file contains no valid information.
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - Thrown when decoding fails.

### func getRandomGen()

```cangjie
func getRandomGen(): RandomGenerator
```

Functionality: Gets a random number generator.

Return Value:

- [RandomGenerator](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-randomgenerator) - The random number generator.

### func privateKeyFromDer(DerBlob)

```cangjie
func privateKeyFromDer(encoded: DerBlob): PrivateKey
```

Functionality: Decodes a private key from DER format.

Parameters:

- encoded: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The DerBlob object to be decoded.

Return Value:

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey) - The decoded private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when the encoded file contains no valid information.
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - Thrown when decoding fails.

### func privateKeyFromDer(DerBlob, ?String)

```cangjie
func privateKeyFromDer(encoded: DerBlob, password!: ?String): PrivateKey
```

Functionality: Decrypts and decodes a private key from DER format. No decryption is performed when password is None.

Parameters:

- encoded: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The DerBlob object to be decrypted and decoded.
- password!: ?String - The decryption password.

Return Value:

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey) - The decrypted and decoded private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when the encoded file contains no valid information.
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - Thrown when decoding fails.

### func privateKeyFromPem(String)

```cangjie
func privateKeyFromPem(text: String): PrivateKey
```

Functionality: Decodes a private key from PEM format.

Parameters:

- text: String - The PEM format string to be decoded.

Return Value:

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey) - The decoded private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when the encoded file contains no valid information.
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - Thrown when decoding fails.

### func privateKeyFromPem(String, ?String)

```cangjie
func privateKeyFromPem(text: String, password!: ?String): PrivateKey
```

Functionality: Decrypts and decodes a private key from PEM format. No decryption is performed when password is `None`.

Parameters:

- text: String - The PEM format string to be decrypted and decoded.
- password!: ?String - The decryption password.

Return Value:

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey) - The decrypted and decoded private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when the encoded file contains no valid information.
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - Thrown when decoding fails.

### func publicKeyFromDer(DerBlob)

```cangjie
func publicKeyFromDer(encoded: DerBlob): PublicKey
```

Functionality: Decodes a public key from DER format.

Parameters:

- encoded: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The DerBlob object to be decoded.

Return Value:

- [PublicKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-publickey) - The decoded public key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when the encoded file contains no valid information.
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - Thrown when decoding fails.

### func publicKeyFromPem(String)

```cangjie
func publicKeyFromPem(text: String): PublicKey
```

Functionality: Decodes a public key from PEM format.

Parameters:

- text: String - The PEM format string to be decoded.

Return Value:

- [PublicKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-publickey) - The decoded public key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when the encoded file contains no valid information.
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - Thrown when decoding fails.
