# Classes

## class ECDSAPrivateKey

```cangjie
public class ECDSAPrivateKey <: PrivateKey {
    public init(curve: Curve)
}
```

Functionality: ECDSA private key class that provides the capability to generate ECDSA private keys. ECDSA private keys support signing operations and can be encoded/decoded in PEM and DER formats. For usage examples, see [ECDSA Key Samples](../keys_samples/sample_keys.md#ecdsa-key-samples).

Parent Types:

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey)

### init(Curve)

```cangjie
public init(curve: Curve)
```

Functionality: Initializes and generates a private key.

Parameters:

- curve: [Curve](keys_package_enums.md#enum-curve) - The elliptic curve type.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if initialization fails.

### static func decodeDer(DerBlob)

```cangjie
public static func decodeDer(blob: DerBlob): ECDSAPrivateKey
```

Functionality: Decodes a private key from DER format.

Parameters:

- blob: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The private key object in binary format.

Return Value:

- [ECDSAPrivateKey](keys_package_classes.md#class-ecdsaprivatekey) - The decoded ECDSA private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if decoding fails.

### static func decodeDer(DerBlob, ?String)

```cangjie
public static func decodeDer(blob: DerBlob, password!: ?String): ECDSAPrivateKey
```

Functionality: Decodes an encrypted private key from DER format.

Parameters:

- blob: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The private key object in binary format.
- password!: ?String - The password required to decrypt the private key. If None, no decryption is performed.

Return Value:

- [ECDSAPrivateKey](keys_package_classes.md#class-ecdsaprivatekey) - The decoded ECDSA private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if decoding fails, decryption fails, or if the password parameter is an empty string.

### static func decodeFromPem(String)

```cangjie
public static func decodeFromPem(text: String): ECDSAPrivateKey
```

Functionality: Decodes a private key from PEM format.

Parameters:

- text: String - The private key character stream in PEM format.

Return Value:

- [ECDSAPrivateKey](keys_package_classes.md#class-ecdsaprivatekey) - The decoded ECDSA private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if decoding fails, the character stream does not conform to PEM format, or the file header does not meet private key header standards.

### static func decodeFromPem(String, ?String)

```cangjie
public static func decodeFromPem(text: String, password!: ?String): ECDSAPrivateKey
```

Functionality: Decodes a private key from PEM format.

Parameters:

- text: String - The private key character stream in PEM format.
- password!: ?String - The password required to decrypt the private key. If None, no decryption is performed.

Return Value:

- [ECDSAPrivateKey](keys_package_classes.md#class-ecdsaprivatekey) - The decoded ECDSA private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if decoding fails, decryption fails, the password parameter is an empty string, the character stream does not conform to PEM format, or the file header does not meet private key header standards.

### func encodeToDer()

```cangjie
public override func encodeToDer(): DerBlob
```

Functionality: Encodes the private key into DER format.

Return Value:

- [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The encoded private key in DER format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if encoding fails.

### func encodeToDer(?String)

```cangjie
public func encodeToDer(password!: ?String): DerBlob
```

Functionality: Encrypts the private key using AES-256-CBC and encodes it into DER format.

Parameters:

- password!: ?String - The password required to encrypt the private key. If None, no encryption is performed.

Return Value:

- [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The encoded private key in DER format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if encoding fails, encryption fails, or if the password parameter is an empty string.

### func encodeToPem()

```cangjie
public func encodeToPem(): PemEntry
```

Functionality: Encodes the private key into PEM format.

Return Value:

- [PemEntry](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-pementry) - The private key object in PEM format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if encoding fails.

### func encodeToPem(?String)

```cangjie
public func encodeToPem(password!: ?String): PemEntry
```

Functionality: Encodes the encrypted private key into PEM format.

Parameters:

- password!: ?String - The password required to encrypt the private key. If None, no encryption is performed.

Return Value:

- [PemEntry](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-pementry) - The private key object in PEM format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if encoding fails, encryption fails, or if the password parameter is an empty string.

### func sign(Array\<Byte>)

```cangjie
public func sign(digest: Array<Byte>): Array<Byte>
```

Functionality: Signs the digest result of the data.

Parameters:

- digest: Array\<Byte> - The digest result of the data.

Return Value:

- Array\<Byte> - The signed data.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if signing fails.

### func toString()

```cangjie
public override func toString(): String
```

Functionality: Outputs the private key type.

Return Value:

- String - The description of the key type.

## class ECDSAPublicKey

```cangjie
public class ECDSAPublicKey <: PublicKey {
    public init(pri: ECDSAPrivateKey)
}
```

Functionality: ECDSA public key class that provides the capability to generate ECDSA public keys. ECDSA public keys support signature verification and can be encoded/decoded in PEM and DER formats. For usage examples, see [ECDSA Key Samples](../keys_samples/sample_keys.md#ecdsa-key-samples).

Parent Types:

- [PublicKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-publickey)

### init(ECDSAPrivateKey)

```cangjie
public init(pri: ECDSAPrivateKey)
```

Functionality: Initializes the public key by extracting it from the corresponding private key.

Parameters:

- pri: [ECDSAPrivateKey](keys_package_classes.md#class-ecdsaprivatekey) - The ECDSA private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if initialization fails.

### static func decodeDer(DerBlob)

```cangjie
public static func decodeDer(blob: DerBlob): ECDSAPublicKey
```

Functionality: Decodes a public key from DER format.

Parameters:

- blob: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The public key object in binary format.

Return Value:

- [ECDSAPublicKey](keys_package_classes.md#class-ecdsapublickey) - The decoded ECDSA public key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if encoding fails.

### static func decodeFromPem(String)

```cangjie
public static func decodeFromPem(text: String): ECDSAPublicKey
```

Functionality: Decodes a public key from PEM format.

Parameters:

- text: String - The public key character stream in PEM format.

Return Value:

- [ECDSAPublicKey](keys_package_classes.md#class-ecdsapublickey) - The decoded ECDSA public key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if decoding fails, the character stream does not conform to PEM format, or the file header does not meet public key header standards.

### func encodeToDer()

```cangjie
public override func encodeToDer(): DerBlob
```

Functionality: Encodes the public key into DER format.

Return Value:

- [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The encoded public key in DER format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if encoding fails.

### func encodeToPem()

```cangjie
public func encodeToPem(): PemEntry
```

Functionality: Encodes the public key into PEM format.

Return Value:

- [PemEntry](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-pementry) - The public key object in PEM format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if encoding fails.

### func toString()

```cangjie
public override func toString(): String
```

Functionality: Outputs the public key type.

Return Value:

- String - The description of the key type.

### func verify(Array\<Byte>, Array\<Byte>)

```cangjie
public func verify(digest: Array<Byte>, sig: Array<Byte>): Bool
```

Functionality: Verifies the signature result.

Parameters:

- digest: Array\<Byte> - The digest result of the data.
- sig: Array\<Byte> - The signature result of the data.

Return Value:

- Bool - Returns true if verification succeeds, false otherwise.

## class GeneralPrivateKey

```cangjie
public class GeneralPrivateKey <: PrivateKey
```

Functionality: Implements general private key parameter encryption and decryption.

Parent Types:

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey)

### static func decodeDer(DerBlob)

```cangjie
static func decodeDer(encoded: DerBlob): PrivateKey
```

Functionality: Decodes a private key from DER format.

Parameters:

- encoded: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The private key object in DER format.

Return Value:

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey) - The decoded private key from DER format.

### static func decodeDer(DerBlob, ?String)

```cangjie
static func decodeDer(encoded: DerBlob, password!: ?String): PrivateKey
```

Functionality: Decrypts and decodes a private key in DER format into a [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey) object. If the password is None, no decryption is performed.

Parameters:

- encoded: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The private key in DER format.
- password!: ?String - The decryption password.

Return Value:

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey) - The decrypted and decoded private key object.

### static func decodeFromPem(String)

```cangjie
static func decodeFromPem(text: String): PrivateKey
```

Functionality: Decodes a private key from PEM format.

Parameters:

- text: String - The private key character stream in PEM format.

Return Value:

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey) - The decoded private key from PEM format.

### static func decodeFromPem(String, ?String)

```cangjie
static func decodeFromPem(text: String, password!: ?String): PrivateKey
```

Functionality: Decrypts and decodes a private key in PEM format into a [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey) object. If the password is None, no decryption is performed.

Parameters:

- text: String - The private key in PEM format.
- password!: ?String - The decryption password.

Return Value:

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey) - The decrypted and decoded private key object.

### func encodeToDer()

```cangjie
func encodeToDer(): DerBlob
```

Functionality: Encodes the private key into DER format.

Return Value:

- [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The private key in DER format.

### func encodeToDer(?String)

```cangjie
func encodeToDer(password!: ?String): DerBlob
```

Functionality: Encrypts and encodes the private key into DER format. If the password is None, no encryption is performed.

Parameters:

- password!: ?String - The encryption password.

Return Value:

- [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The encrypted private key in DER format.

### func encodeToPem()

```cangjie
func encodeToPem(): PemEntry
```

Functionality: Encodes the private key into PEM format.

Return Value:

- [PemEntry](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-pementry) - The encoded private key in PEM format.

### func encodeToPem(?String)

```cangjie
func encodeToPem(password!: ?String): PemEntry
```

Functionality: Encrypts and encodes the private key into PEM format. If the password is None, no encryption is performed.

Parameters:

- password!: ?String - The encryption password.

Return Value:

- [PemEntry](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-pementry) - The encrypted private key in PEM format.

### func toString()

```cangjie
public func toString(): String
```

Functionality: Converts to string format.

Return Value:

- String - The string representation.

## class GeneralPublicKey

```cangjie
public class GeneralPublicKey <: PublicKey
```

Function: Provides generic public key parameter encryption/decryption functionality.

Parent Types:

- [PublicKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-publickey)

### static func decodeDer(DerBlob)

```cangjie
static func decodeDer(encoded: DerBlob): PublicKey
```

Function: Decodes a public key from DER format.

Parameters:

- encoded: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - Public key object in DER format.

Return Value:

- [PublicKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-publickey) - Public key decoded from DER format.

### static func decodeFromPem(String)

```cangjie
static func decodeFromPem(text: String): PublicKey
```

Function: Decodes a public key from PEM format.

Parameters:

- text: String - Public key character stream in PEM format.

Return Value:

- [PublicKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-publickey) - Public key decoded from PEM format.

### func encodeToDer()

```cangjie
func encodeToDer(): DerBlob
```

Function: Encodes the public key into DER format.

Return Value:

- [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - Public key in DER format.

### func encodeToPem()

```cangjie
func encodeToPem(): PemEntry
```

Function: Encodes the public key into PEM format.

Return Value:

- [PemEntry](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-pementry) - Object generated from PEM format encoding of public key data.

### func toString()

```cangjie
public func toString(): String
```

Function: Converts to string format.

Return Value:

- String - String representation.

## class RSAPrivateKey

```cangjie
public class RSAPrivateKey <: PrivateKey{
    public init(bits: Int32)
    public init(bits: Int32, e: BigInt)
}
```

Function: RSA private key class providing RSA private key generation capability. RSA private keys support signing and decryption operations, with encoding/decoding in PEM and DER formats compliant with PKCS1 standard. Usage examples see [RSA Key Examples](../keys_samples/sample_keys.md#rsa-密钥示例).

> **Note:**
>
> - Recommended length is not less than 3072 bits. Keys shorter than 3072 bits may be insecure.

Parent Types:

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey)

### init(Int32)

```cangjie
public init(bits: Int32)
```

Function: Initializes and generates a private key with default public exponent value of 65537 (industry recommendation). The size of public exponent e directly affects RSA algorithm security and encryption efficiency. Generally, smaller e values result in faster encryption but lower security.

Parameters:

- bits: Int32 - Key length, must be ≥512 bits and ≤16384 bits.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if key length is invalid or initialization fails.

### init(Int32, BigInt)

```cangjie
public init(bits: Int32, e: BigInt)
```

Function: Initializes and generates a private key allowing custom public exponent specification.

Parameters:

- bits: Int32 - Key length, must be ≥512 bits and ≤16384 bits (recommended ≥3072 bits).
- e: BigInt - Public exponent, must be an odd number in range [3, 2^256-1].

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if key length is invalid, public exponent is invalid, or initialization fails.

### static func decodeDer(DerBlob)

```cangjie
public static func decodeDer(blob: DerBlob): RSAPrivateKey
```

Function: Decodes a private key from DER format.

Parameters:

- blob: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - Private key object in binary format.

Return Value:

- [RSAPrivateKey](keys_package_classes.md#class-rsaprivatekey) - Decoded RSA private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if decoding fails.

### static func decodeDer(DerBlob, ?String)

```cangjie
public static func decodeDer(blob: DerBlob, password!: ?String): RSAPrivateKey
```

Function: Decodes an encrypted private key from DER format.

Parameters:

- blob: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - Private key object in binary format.
- password!: ?String - Password required for decryption (None means no decryption).

Return Value:

- [RSAPrivateKey](keys_package_classes.md#class-rsaprivatekey) - Decoded RSA private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if decoding fails, decryption fails, or password is empty string.

### static func decodeFromPem(String)

```cangjie
public static func decodeFromPem(text: String): RSAPrivateKey
```

Function: Decodes a private key from PEM format.

Parameters:

- text: String - Private key character stream in PEM format.

Return Value:

- [RSAPrivateKey](keys_package_classes.md#class-rsaprivatekey) - Decoded RSA private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if decoding fails, decryption fails, stream doesn't match PEM format, or header doesn't match private key standard.

### static func decodeFromPem(String, ?String)

```cangjie
public static func decodeFromPem(text: String, password!: ?String): RSAPrivateKey
```

Function: Decodes a private key from PEM format.

Parameters:

- text: String - Private key character stream in PEM format.
- password!: ?String - Password required for decryption (None means no decryption).

Return Value:

- [RSAPrivateKey](keys_package_classes.md#class-rsaprivatekey) - Decoded RSA private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if decoding fails, decryption fails, password is empty string, stream doesn't match PEM format, or header doesn't match private key standard.

### func decrypt(InputStream, OutputStream, PadOption)

```cangjie
public func decrypt(input: InputStream, output: OutputStream, padType!: PadOption): Unit
```

Function: Decrypts original data.

Parameters:

- input: InputStream - Encrypted data.
- output: OutputStream - Decrypted data.
- padType!: [PadOption](keys_package_enums.md#enum-padoption) - Padding mode (PKCS1 or OAEP; PSS not supported). OAEP is recommended for higher security scenarios.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if padding mode setting fails or decryption fails.

### func encodeToDer()

```cangjie
public override func encodeToDer(): DerBlob
```

Function: Encodes the private key into DER format.

Return Value:

- [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - Encoded private key in DER format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if encoding fails.

### func encodeToDer(?String)

```cangjie
public func encodeToDer(password!: ?String): DerBlob
```

Function: Encrypts private key using AES-256-CBC and encodes into DER format.

Parameters:

- password!: ?String - Password required for encryption (None means no encryption).

Return Value:

- [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - Encoded private key in DER format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if encoding fails, encryption fails, or password is empty string.

### func encodeToPem()

```cangjie
public func encodeToPem(): PemEntry
```

Function: Encodes the private key into PEM format.

Return Value:

- [PemEntry](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-pementry) - Private key object in PEM format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if encoding fails.

### func encodeToPem(?String)

```cangjie
public func encodeToPem(password!: ?String): PemEntry
```

Function: Encodes an encrypted private key into PEM format.

Parameters:

- password!: ?String - Password required for encryption (None means no encryption).

Return Value:

- [PemEntry](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-pementry) - Private key object in PEM format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if encoding fails, encryption fails, or password is empty string.

### func sign(Digest, Array\<Byte>, PadOption)

```cangjie
public func sign(hash: Digest, digest: Array<Byte>, padType!: PadOption): Array<Byte>
```

Function: Signs the digest result of data.

Parameters:

- hash: Digest - Digest method used to obtain digest result.
- digest: Array\<Byte> - Digest result of data.
- padType!: [PadOption](keys_package_enums.md#enum-padoption) - Padding mode (PKCS1 or PSS; OAEP not supported). PSS is recommended for higher security scenarios.

Return Value:

- Array\<Byte> - Signed data.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if digest method setting fails, padding mode setting fails, or signing fails.

### func toString()

```cangjie
public override func toString(): String
```

Function: Outputs private key type.

Return Value:

- String - Key type description.

## class RSAPublicKey

```cangjie
public class RSAPublicKey <: PublicKey {
    public init(pri: RSAPrivateKey)
}
```

Function: RSA public key class providing RSA public key generation capability. RSA public keys support signature verification and encryption operations, with encoding/decoding in PEM and DER formats. Usage examples see [RSA Key Examples](../keys_samples/sample_keys.md#rsa-密钥示例).

Parent Types:

- [PublicKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-publickey)

### init(RSAPrivateKey)

```cangjie
public init(pri: RSAPrivateKey)
```

Function: Initializes public key by extracting corresponding public key from private key.

Parameters:

- pri: [RSAPrivateKey](keys_package_classes.md#class-rsaprivatekey) - RSA private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if initialization fails.

### static func decodeDer(DerBlob)

```cangjie
public static func decodeDer(blob: DerBlob): RSAPublicKey
```

Function: Decodes a public key from DER format.

Parameters:

- blob: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - Public key object in binary format.

Return Value:

- [RSAPublicKey](keys_package_classes.md#class-rsapublickey) - Decoded RSA public key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if decoding fails.

### static func decodeFromPem(String)

```cangjie
public static func decodeFromPem(text: String): RSAPublicKey
```

Function: Decodes a public key from PEM format.

Parameters:

- text: String - Public key character stream in PEM format.

Return Value:

- [RSAPublicKey](keys_package_classes.md#class-rsapublickey) - Decoded RSA public key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if decoding fails, stream doesn't match PEM format, or header doesn't match public key standard.

### func encodeToDer()

```cangjie
public override func encodeToDer(): DerBlob
```

Function: Encodes the public key into DER format.

Return Value:

- [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - Encoded public key in DER format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if encoding fails.

### func encodeToPem()

```cangjie
public func encodeToPem(): PemEntry
```

Function: Encodes the public key into PEM format.

Return Value:

- [PemEntry](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-pementry) object.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if encoding fails.

### func encrypt(InputStream, OutputStream, PadOption)

```cangjie
public func encrypt(input: InputStream, output: OutputStream, padType!: PadOption): Unit
```

Function: Encrypts data.

Parameters:

- input: InputStream - Data to be encrypted.
- output: OutputStream - Encrypted data.
- padType!: [PadOption](keys_package_enums.md#enum-padoption) - Padding mode (PKCS1 or OAEP; PSS not supported). OAEP is recommended for higher security scenarios.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if padding mode setting fails or encryption fails.

### func toString()

```cangjie
public override func toString(): String
```

Function: Outputs public key type.

Return Value:

- String - Key type description.

### func verify(Digest, Array\<Byte>, Array\<Byte>, PadOption)

```cangjie
public func verify(hash: Digest, digest: Array<Byte>, sig: Array<Byte>, padType!: PadOption): Bool
```

Function: Verifies signature result.

Parameters:

- hash: Digest - Digest method used to obtain digest result.
- digest: Array\<Byte> - Digest result of data.
- sig: Array\<Byte> - Signature result of data.
- padType!: [PadOption](keys_package_enums.md#enum-padoption) - Padding mode (PKCS1 or PSS; OAEP not supported). PSS is recommended for higher security scenarios.

Return Value:

- Bool - Returns true if verification succeeds, false otherwise.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws exception if padding mode setting fails or verification fails.

## class SM2PrivateKey

```cangjie
public class SM2PrivateKey <: PrivateKey {
    public init()
}
```

Function: SM2 private key class, providing the capability to generate SM2 private keys. SM2 private keys support signing and decryption operations, and can be encoded/decoded in PEM and DER formats, compliant with PKCS1 standard. For usage examples, see [SM2 Key Samples](../keys_samples/sample_keys.md#sm2-key-samples).

Parent Types:

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey)

### init()

```cangjie
public init()
```

Function: Initializes and generates a private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if initialization fails.

### static func decodeDer(DerBlob)

```cangjie
public static func decodeDer(blob: DerBlob): SM2PrivateKey
```

Function: Decodes a private key from DER format.

Parameters:

- blob: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - Private key object in binary format.

Return Value:

- [SM2PrivateKey](keys_package_classes.md#class-sm2privatekey) - The decoded SM2 private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if decoding fails.

### static func decodeDer(DerBlob, ?String)

```cangjie
public static func decodeDer(blob: DerBlob, password!: ?String): SM2PrivateKey
```

Function: Decodes an encrypted private key from DER format.

Parameters:

- blob: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - Private key object in binary format.
- password!: ?String - Password required to decrypt the private key. If None, no decryption is performed.

Return Value:

- [SM2PrivateKey](keys_package_classes.md#class-sm2privatekey) - The decoded SM2 private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if decoding fails, decryption fails, or the password parameter is an empty string.

### static func decodeFromPem(String)

```cangjie
public static func decodeFromPem(text: String): SM2PrivateKey
```

Function: Decodes a private key from PEM format.

Parameters:

- text: String - Private key character stream in PEM format.

Return Value:

- [SM2PrivateKey](keys_package_classes.md#class-sm2privatekey) - The decoded SM2 private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if decoding fails, decryption fails, the character stream does not conform to PEM format, or the file header does not meet private key header standards.

### static func decodeFromPem(String, ?String)

```cangjie
public static func decodeFromPem(text: String, password!: ?String): SM2PrivateKey
```

Function: Decodes a private key from PEM format.

Parameters:

- text: String - Private key character stream in PEM format.
- password!: ?String - Password required to decrypt the private key. If None, no decryption is performed.

Return Value:

- [SM2PrivateKey](keys_package_classes.md#class-sm2privatekey) - The decoded SM2 private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if decoding fails, decryption fails, the password parameter is an empty string, the character stream does not conform to PEM format, or the file header does not meet private key header standards.

### func decrypt(Array\<Byte>)

```cangjie
public func decrypt(input: Array<Byte>): Array<Byte>
```

Function: Decrypts the original data. The ciphertext to be decrypted must follow ASN.1 encoding rules.

Parameters:

- input: Array\<Byte> - Encrypted data.

Return Value:

- Array\<Byte> - Decrypted data.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if decryption fails.

### func encodeToDer()

```cangjie
public func encodeToDer(): DerBlob
```

Function: Encodes the private key into DER format.

Return Value:

- [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The encoded private key in DER format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if encoding fails.

### func encodeToDer(?String)

```cangjie
public func encodeToDer(password!: ?String): DerBlob
```

Function: Encrypts the private key using AES-256-CBC and encodes it into DER format.

Parameters:

- password!: ?String - Password required to encrypt the private key. If None, no encryption is performed.

Return Value:

- [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The encoded public key in DER format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if encoding fails, encryption fails, or the password parameter is an empty string.

### func encodeToPem(?String)

```cangjie
public func encodeToPem(password!: ?String): PemEntry
```

Function: Encodes the encrypted private key into PEM format.

Parameters:

- password!: ?String - Password required to encrypt the private key. If None, no encryption is performed.

Return Value:

- [PemEntry](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-pementry) - The private key object in PEM format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if encoding fails, encryption fails, or the password parameter is an empty string.

### func encodeToPem()

```cangjie
public func encodeToPem(): PemEntry
```

Function: Encodes the private key into PEM format.

Return Value:

- [PemEntry](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-pementry) - The private key object in PEM format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if encoding fails.

### func sign(Array\<Byte>)

```cangjie
public func sign(data: Array<Byte>): Array<Byte>
```

Function: Signs the data. SM2 uses the [SM3](../../digest/digest_package_api/digest_package_classes.md#class-sm3) digest algorithm.

Parameters:

- data: Array\<Byte> - Data to be signed.

Return Value:

- Array\<Byte> - Signed data.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if signing fails.

### func toString()

```cangjie
public override func toString(): String
```

Function: Outputs the private key type.

Return Value:

- String - Description of the key type.

## class SM2PublicKey

```cangjie
public class SM2PublicKey <: PublicKey {
    public init(pri: SM2PrivateKey)
}
```

Function: SM2 public key class, providing the capability to generate SM2 public keys. SM2 public keys support signature verification and encryption operations, and can be encoded/decoded in PEM and DER formats. For usage examples, see [SM2 Key Samples](../keys_samples/sample_keys.md#sm2-key-samples).

Parent Types:

- [PublicKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-publickey)

### init(SM2PrivateKey)

```cangjie
public init(pri: SM2PrivateKey)
```

Function: Initializes the public key by extracting it from the corresponding private key.

Parameters:

- pri: [SM2PrivateKey](keys_package_classes.md#class-sm2privatekey) - SM2 private key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if initialization fails.

### static func decodeDer(DerBlob)

```cangjie
public static func decodeDer(blob: DerBlob): SM2PublicKey
```

Function: Decodes a public key from DER format.

Parameters:

- blob: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - Public key object in binary format.

Return Value:

- [SM2PublicKey](keys_package_classes.md#class-sm2publickey) - The decoded SM2 public key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if decoding fails.

### static func decodeFromPem(String)

```cangjie
public static func decodeFromPem(text: String): SM2PublicKey
```

Function: Decodes a public key from PEM format.

Parameters:

- text: String - Public key character stream in PEM format.

Return Value:

- [SM2PublicKey](keys_package_classes.md#class-sm2publickey) - The decoded SM2 public key.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if decoding fails, the character stream does not conform to PEM format, or the file header does not meet public key header standards.

### func encodeToDer()

```cangjie
public func encodeToDer(): DerBlob
```

Function: Encodes the public key into DER format.

Return Value:

- [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - The encoded public key in DER format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if encoding fails.

### func encodeToPem()

```cangjie
public func encodeToPem(): PemEntry
```

Function: Encodes the public key into PEM format.

Return Value:

- [PemEntry](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-pementry) - The public key object in PEM format.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if encoding fails.

### func encrypt(Array\<Byte>)

```cangjie
public func encrypt(input: Array<Byte>): Array<Byte>
```

Function: Encrypts a piece of data. The output ciphertext follows ASN.1 encoding rules.

Parameters:

- input: Array\<Byte> - Data to be encrypted.

Return Value:

- Array\<Byte> - Encrypted data.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if encryption fails.

### func toString()

```cangjie
public override func toString(): String
```

Function: Outputs the public key type.

Return Value:

- String - Description of the key type.

### func verify(Array\<Byte>, Array\<Byte>)

```cangjie
public func verify(data: Array<Byte>, sig: Array<Byte>): Bool
```

Function: Verifies the signature result.

Parameters:

- data: Array\<Byte> - Data.
- sig: Array\<Byte> - Signature result of the data.

Return Value:

- Bool - Returns true if verification succeeds, false otherwise.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws an exception if setting the padding mode fails or verification fails.
