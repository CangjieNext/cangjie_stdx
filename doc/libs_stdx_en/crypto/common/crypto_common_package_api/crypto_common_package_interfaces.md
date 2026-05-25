# Interfaces

## interface Certificate

```cangjie
public interface Certificate {}
```

Function: Certificate interface for adapting different cryptographic suites.

## interface CryptoKit

```cangjie
public interface CryptoKit {
    func getRandomGen(): RandomGenerator
    func publicKeyFromDer(encoded: DerBlob): PublicKey
    func publicKeyFromPem(text: String): PublicKey
    func privateKeyFromDer(encoded: DerBlob): PrivateKey
    func privateKeyFromPem(text: String): PrivateKey
    func privateKeyFromDer(encoded: DerBlob, password!: ?String): PrivateKey
    func privateKeyFromPem(text: String, password!: ?String): PrivateKey
    func dhParametersFromDer(encoded: DerBlob): DHParameters
    func dhParametersFromPem(text: String): DHParameters
    func certificateFromDer(encoded: DerBlob): Certificate
    func certificateFromPem(text: String): Array<Certificate>
}
```

Function: Cryptographic suite interface. Provides random number generator and DER/PEM decoding capabilities.

> **Note:**
>
> PEM is a Base64-based encoding format.

### func certificateFromDer(DerBlob)

```cangjie
func certificateFromDer(encoded: DerBlob): Certificate
```

Function: Decodes certificate from DER format.

Parameters:

- encoded: [DerBlob](./crypto_common_package_structs.md#struct-derblob) - DerBlob object to be decoded.

Return value:

- [Certificate](#interface-certificate) - Decoded certificate.

### func certificateFromPem(String)

```cangjie
func certificateFromPem(text: String): Array<Certificate>
```

Function: Decodes certificate from PEM format.

Parameters:

- text: String - PEM format string to be decoded.

Return value:

- Array\<[Certificate](#interface-certificate)> - Collection of decoded certificates.

### func dhParametersFromDer(DerBlob)

```cangjie
func dhParametersFromDer(encoded: DerBlob): DHParameters
```

Function: Decodes DH key parameters from DER format.

Parameters:

- encoded: [DerBlob](./crypto_common_package_structs.md#struct-derblob) - DerBlob object to be decoded.

Return value:

- [DHParameters](#interface-dhparameters) - Decoded DH key parameters.

### func dhParametersFromPem(String)

```cangjie
func dhParametersFromPem(text: String): DHParameters
```

Function: Decodes DH key parameters from PEM format.

Parameters:

- text: String - PEM format string to be decoded.

Return value:

- [DHParameters](#interface-dhparameters) - Decoded DH key parameters.

### func getRandomGen()

```cangjie
func getRandomGen(): RandomGenerator
```

Function: Gets random number generator.

Return value:

- [RandomGenerator](#interface-randomgenerator) - Random number generator.

### func privateKeyFromDer(DerBlob)

```cangjie
func privateKeyFromDer(encoded: DerBlob): PrivateKey
```

Function: Decodes private key from DER format.

Parameters:

- encoded: [DerBlob](./crypto_common_package_structs.md#struct-derblob) - DerBlob object to be decoded.

Return value:

- [PrivateKey](#interface-privatekey) - Decoded private key.

### func privateKeyFromDer(DerBlob, ?String)

```cangjie
func privateKeyFromDer(encoded: DerBlob, password!: ?String): PrivateKey
```

Function: Decrypts and decodes private key from DER format. No decryption when password is None.

Parameters:

- encoded: [DerBlob](./crypto_common_package_structs.md#struct-derblob) - DerBlob object to be decrypted and decoded.
- password!: ?String - Decryption password.

Return value:

- [PrivateKey](#interface-privatekey) - Decrypted and decoded private key.

### func privateKeyFromPem(String)

```cangjie
func privateKeyFromPem(text: String): PrivateKey
```

Function: Decodes private key from PEM format.

Parameters:

- text: String - PEM format string to be decoded.

Return value:

- [PrivateKey](#interface-privatekey) - Decoded private key.

### func privateKeyFromPem(String, ?String)

```cangjie
func privateKeyFromPem(text: String, password!: ?String): PrivateKey
```

Function: Decrypts and decodes private key from PEM format. No decryption when password is `None`.

Parameters:

- text: String - PEM format string to be decrypted and decoded.
- password!: ?String - Decryption password.

Return value:

- [PrivateKey](#interface-privatekey) - Decrypted and decoded private key.

### func publicKeyFromDer(DerBlob)

```cangjie
func publicKeyFromDer(encoded: DerBlob): PublicKey
```

Function: Decodes public key from DER format.

Parameters:

- encoded: [DerBlob](./crypto_common_package_structs.md#struct-derblob) - DerBlob object to be decoded.

Return value:

- [PublicKey](#interface-publickey) - Decoded public key.

### func publicKeyFromPem(String)

```cangjie
func publicKeyFromPem(text: String): PublicKey
```

Function: Decodes public key from PEM format.

Parameters:

- text: String - PEM format string to be decoded.

Return value:

- [PublicKey](#interface-publickey) - Decoded public key.

## interface DHParameters

```cangjie
public interface DHParameters <: Key {
    static func decodeDer(encoded: DerBlob): DHParameters
    static func decodeFromPem(text: String): DHParameters
}
```

Function: DH key parameters interface.

Parent type:

- [Key](#interface-key)

### static func decodeDer(DerBlob)

```cangjie
static func decodeDer(encoded: DerBlob): DHParameters
```

Function: Decodes DH key parameters from DER format.

> **Note:**
>
> - DH (Diffie-Hellman) key exchange protocol is a method to ensure secure shared KEY transmission over insecure networks.
> - DER and PEM are two common encoding formats.

Parameters:

- encoded: [DerBlob](./crypto_common_package_structs.md#struct-derblob) - DH key parameters object in DER format.

Return value:

- [DHParameters](#interface-dhparameters) - DH key parameters decoded from DER format.

### static func decodeFromPem(String)

```cangjie
static func decodeFromPem(text: String): DHParameters
```

Function: Decodes DH key parameters from PEM format.

Parameters:

- text: String - DH key parameters character stream in PEM format.

Return value:

- [DHParameters](#interface-dhparameters) - DH key parameters decoded from PEM format.

## interface Key

```cangjie
public interface Key <: ToString {
    func encodeToDer(): DerBlob
    func encodeToPem(): PemEntry
    static func decodeDer(encoded: DerBlob): Key
    static func decodeFromPem(text: String): Key
}
```

Function: Key interface. Public keys are used for signature verification or encryption, private keys are used for signing or decryption. Public and private keys must match each other and form a pair. This class serves as a key class without concrete implementation, provided for [PrivateKey](#interface-privatekey)/[PublicKey](#interface-publickey) and user extension interfaces.

Parent type:

- ToString

### static func decodeDer(DerBlob)

```cangjie
static func decodeDer(encoded: DerBlob): Key
```

Function: Decodes key from DER format.

Parameters:

- encoded: [DerBlob](./crypto_common_package_structs.md#struct-derblob) - Object in DER format.

Return value:

- [Key](#interface-key) - Key decoded from DER format.

### static func decodeFromPem(String)

```cangjie
static func decodeFromPem(text: String): Key
```

Function: Decodes key from PEM format.

Parameters:

- text: String - Character stream in PEM format.

Return value:

- [Key](#interface-key) - Key decoded from PEM format.

### func encodeToDer()

```cangjie
func encodeToDer(): DerBlob
```

Function: Encodes key to DER format.

Return value:

- [DerBlob](./crypto_common_package_structs.md#struct-derblob) - Object generated by DER format encoding of key data.

### func encodeToPem()

```cangjie
func encodeToPem(): PemEntry
```

Function: Encodes key to PEM format.

Return value:

- [PemEntry](./crypto_common_package_structs.md#struct-pementry) - Object generated by PEM format encoding of key data.

## interface PrivateKey

```cangjie
public interface PrivateKey <: Key {
    func encodeToDer(password!: ?String): DerBlob
    func encodeToPem(password!: ?String): PemEntry
    static func decodeDer(encoded: DerBlob): PrivateKey
    static func decodeFromPem(text: String): PrivateKey
    static func decodeDer(encoded: DerBlob, password!: ?String): PrivateKey
    static func decodeFromPem(text: String, password!: ?String): PrivateKey
}
```

Function: Private key interface.

Parent type:

- [Key](#interface-key)

### static func decodeDer(DerBlob)

```cangjie
static func decodeDer(encoded: DerBlob): PrivateKey
```

Function: Decodes private key from DER format.

Parameters:

- encoded: [DerBlob](./crypto_common_package_structs.md#struct-derblob) - Private key object in DER format.

Return value:

- [PrivateKey](#interface-privatekey) - Private key decoded from DER format.

### static func decodeDer(DerBlob, ?String)

```cangjie
static func decodeDer(encoded: DerBlob, password!: ?String): PrivateKey
```

Function: Decrypts and decodes DER format private key into [PrivateKey](#interface-privatekey) object. No decryption when password is None.

Parameters:

- encoded: [DerBlob](./crypto_common_package_structs.md#struct-derblob) - Private key in DER format.
- password!: ?String - Decryption password.

Return value:

- [PrivateKey](#interface-privatekey) - Decrypted and decoded private key object.

### static func decodeFromPem(String)

```cangjie
static func decodeFromPem(text: String): PrivateKey
```

Function: Decodes private key from PEM format.

Parameters:

- text: String - Private key character stream in PEM format.

Return value:

- [PrivateKey](#interface-privatekey) - Private key decoded from PEM format.

### static func decodeFromPem(String, ?String)

```cangjie
static func decodeFromPem(text: String, password!: ?String): PrivateKey
```

Function: Decrypts and decodes PEM format private key into [PrivateKey](#interface-privatekey) object. No decryption when password is None.

Parameters:

- text: String - Private key in PEM format.
- password!: ?String - Decryption password.

Return value:

- [PrivateKey](#interface-privatekey) - Decrypted and decoded private key object.

### func encodeToDer(?String)

```cangjie
func encodeToDer(password!: ?String): DerBlob
```

Function: Encrypts and encodes private key to DER format. No encryption when password is None.

Parameters:

- password!: ?String - Encryption password.

Return value:

- [DerBlob](./crypto_common_package_structs.md#struct-derblob) - Encrypted private key in DER format.

### func encodeToPem(?String)

```cangjie
func encodeToPem(password!: ?String): PemEntry
```

Function: Encrypts and encodes private key to PEM format. No encryption when password is None.

Parameters:

- password!: ?String - Encryption password.

Return value:

- [PemEntry](./crypto_common_package_structs.md#struct-pementry) - Encrypted private key in PEM format.

## interface PublicKey

```cangjie
public interface PublicKey <: Key {
    static func decodeDer(encoded: DerBlob): PublicKey
    static func decodeFromPem(text: String): PublicKey
}
```

Function: Public key interface.

Parent Type:

- [Key](#interface-key)

### static func decodeDer(DerBlob)

```cangjie
static func decodeDer(encoded: DerBlob): PublicKey
```

Function: Decodes public key from DER format.

Parameters:

- encoded: [DerBlob](./crypto_common_package_structs.md#struct-derblob) - Public key object in DER format.

Return Value:

- [PublicKey](#interface-publickey) - Public key decoded from DER format.

### static func decodeFromPem(String)

```cangjie
static func decodeFromPem(text: String): PublicKey
```

Function: Decodes public key from PEM format.

Parameters:

- text: String - Public key character stream in PEM format.

Return Value:

- [PublicKey](#interface-publickey) - Public key decoded from PEM format.

## interface RandomGenerator

```cangjie
public interface RandomGenerator {
    public func nextBits(bits: UInt64): UInt64
    public func nextBytes(bytes: Array<Byte>): Unit
}
```

Function: Secure random number generator interface.

### func nextBits(UInt64)

```cangjie
public func nextBits(bits: UInt64): UInt64
```

Function: Generates a random integer with specified bit length.

Parameters:

- bits: UInt64 - Number of bits for the random number to generate, range (0, 64].

Return Value:

- UInt64 - Generated random number with specified bit length.

### func nextBytes(Array\<Byte>)

```cangjie
public func nextBytes(bytes: Array<Byte>): Unit
```

Function: Generates random numbers to replace each element in the parameter array.

Parameters:

- bytes: Array\<Byte> - The array to be replaced.
