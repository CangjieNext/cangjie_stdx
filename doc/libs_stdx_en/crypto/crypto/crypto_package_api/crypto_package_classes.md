# Class

## class SecureRandom

```cangjie
public class SecureRandom {
    public init(priv!: Bool = false)
}
```

Function: Used to generate cryptographically secure pseudo-random numbers.

Compared with Random, there are three main differences:

- Random seed: Random uses the system clock as the default seed, resulting in identical outputs when timestamps are the same; [SecureRandom](crypto_package_classes.md#class-securerandom) utilizes random seeds provided by the operating system or hardware to generate true random numbers.

- Random number generation: Random employs the Mersenne Twister pseudo-random number generator; [SecureRandom](crypto_package_classes.md#class-securerandom) uses random algorithms like [MD5](../../digest/digest_package_api/digest_package_classes.md#class-md5) provided by the OpenSSL library, generating true random numbers using entropy sources. If hardware supports it, hardware random number generators can be used to produce even more secure random numbers.

- Security: Random should not be used for cryptographic security applications or privacy data protection, whereas [SecureRandom](crypto_package_classes.md#class-securerandom) can be used for such purposes.

For usage examples, see [SecureRandom Usage](../crypto_samples/sample_secure_random.md).

### init(Bool)

```cangjie
public init(priv!: Bool = false)
```

Function: Creates a [SecureRandom](crypto_package_classes.md#class-securerandom) instance, with an option to specify whether to use a more secure cryptographically secure pseudo-random number generator, which can be used for cryptographic scenarios such as session keys and certificate private keys.

Parameters:

- priv!: Bool - Set to true to use the cryptographically secure pseudo-random number generator.

### func nextBits(UInt64)

```cangjie
public func nextBits(bits: UInt64): UInt64
```

Function: Generates a random integer with a specified bit length.

Parameters:

- bits: UInt64 - The number of bits for the random number to generate, range (0, 64].

Return value:

- UInt64 - The generated random number with the specified bit length.

Exceptions:

- IllegalArgumentException - Thrown if `bits` equals 0 or exceeds 64, which is beyond the maximum length that can be extracted from UInt64.
- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate random numbers or encounters an error during generation.

### func nextBool()

```cangjie
public func nextBool(): Bool
```

Function: Obtains a random Bool type instance.

Return value:

- Bool - A random Bool type instance.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate random numbers or encounters an error during generation.

### func nextBytes(Array\<Byte>)

```cangjie
public func nextBytes(bytes: Array<Byte>): Unit
```

Function: Generates random numbers to replace each element in the input array.

Parameters:

- bytes: Array\<Byte> - The array to be replaced.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate random numbers or encounters an error during generation.

### func nextBytes(Int32)

```cangjie
public func nextBytes(length: Int32): Array<Byte>
```

Function: Obtains a random byte array of specified length.

Parameters:

- length: Int32 - The length of the random byte array to generate.

Return value:

- Array\<Byte> - A random byte array.

Exceptions:

- IllegalArgumentException - Thrown when the parameter `length` is less than or equal to 0.
- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate random numbers or encounters an error during generation.

### func nextFloat16()

```cangjie
public func nextFloat16(): Float16
```

Function: Obtains a Float16 type random number within the range [0.0, 1.0).

Return value:

- Float16 - A Float16 type random number.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate random numbers or encounters an error during generation.

### func nextFloat32()

```cangjie
public func nextFloat32(): Float32
```

Function: Obtains a Float32 type random number within the range [0.0, 1.0).

Return value:

- Float32 - A Float32 type random number.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate random numbers or encounters an error during generation.

### func nextFloat64()

```cangjie
public func nextFloat64(): Float64
```

Function: Obtains a Float64 type random number within the range [0.0, 1.0).

Return value:

- Float64 - A Float64 type random number.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate random numbers or encounters an error during generation.

### func nextGaussianFloat16(Float16, Float16)

```cangjie
public func nextGaussianFloat16(mean!: Float16 = 0.0, sigma!: Float16 = 1.0): Float16
```

Function: By default, obtains a Float16 type random number that follows a Gaussian distribution with a mean of 0.0 and standard deviation of 1.0. The mean represents the expected value and acts as a location parameter determining the distribution's position, while the standard deviation acts as a scale parameter determining the distribution's amplitude.

Parameters:

- mean!: Float16 - The mean.
- sigma!: Float16 - The standard deviation.

Return value:

- Float16 - A Float16 type random number.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate random numbers or encounters an error during generation.

### func nextGaussianFloat32(Float32, Float32)

```cangjie
public func nextGaussianFloat32(mean!: Float32 = 0.0, sigma!: Float32 = 1.0): Float32
```

Function: By default, obtains a Float32 type random number that follows a Gaussian distribution with a mean of 0.0 and standard deviation of 1.0. The mean represents the expected value and acts as a location parameter determining the distribution's position, while the standard deviation acts as a scale parameter determining the distribution's amplitude.

Parameters:

- mean!: Float32 - The mean.
- sigma!: Float32 - The standard deviation.

Return value:

- Float32 - A Float32 type random number.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate random numbers or encounters an error during generation.

### func nextGaussianFloat64(Float64, Float64)

```cangjie
public func nextGaussianFloat64(mean!: Float64 = 0.0, sigma!: Float64 = 1.0): Float64
```

Function: By default, obtains a Float64 type random number that follows a Gaussian distribution with a mean of 0.0 and standard deviation of 1.0. The mean represents the expected value and acts as a location parameter determining the distribution's position, while the standard deviation acts as a scale parameter determining the distribution's amplitude.

Parameters:

- mean!: Float64 - The mean.
- sigma!: Float64 - The standard deviation.

Return value:

- Float64 - A Float64 type random number.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate random numbers or encounters an error during generation.

### func nextInt16()

```cangjie
public func nextInt16(): Int16
```

Function: Obtains a random Int16 type number.

Return value:

- Int16 - A random Int16 type number.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate random numbers or encounters an error during generation.

### func nextInt32()

```cangjie
public func nextInt32(): Int32
```

Function: Obtains a random Int32 type number.

Return value:

- Int32 - A random Int32 type number.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate random numbers or encounters an error during generation.

### func nextInt16(Int16)

```cangjie
public func nextInt16(max: Int16): Int16
```

Function: Obtains a random Int16 type number within the range [0, max).

Parameters:

- max: Int16 - The upper bound of the range.

Return value:

- Int16 - A random Int16 type number.

Exceptions:

- IllegalArgumentException - Thrown when `max` is non-positive.
- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate random numbers or encounters an error during generation.

### func nextInt32(Int32)

```cangjie
public func nextInt32(max: Int32): Int32
```

Function: Obtains a random Int32 type number within the range [0, max).

Parameters:

- max: Int32 - The upper bound of the range.

Return value:

- Int32 - A random Int32 type number.

Exceptions:

- IllegalArgumentException - Thrown when `max` is non-positive.
- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate random numbers or encounters an error during generation.

### func nextInt64()

```cangjie
public func nextInt64(): Int64
```

Function: Obtains a random Int64 type number.

Return Value:

- Int64 - A random number of type Int64.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate a random number or encounters an error during generation.

### func nextInt64(Int64)

```cangjie
public func nextInt64(max: Int64): Int64
```

Function: Obtains a random number of type Int64 within the range [0, max).

Parameters:

- max: Int64 - The upper bound of the range.

Return Value:

- Int64 - A random number of type Int64.

Exceptions:

- IllegalArgumentException - Thrown when max is non-positive.
- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate a random number or encounters an error during generation.

### func nextInt8()

```cangjie
public func nextInt8(): Int8
```

Function: Obtains a random number of type Int8.

Return Value:

- Int8 - A random number of type Int8.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate a random number or encounters an error during generation.

### func nextInt8(Int8)

```cangjie
public func nextInt8(max: Int8): Int8
```

Function: Obtains a random number of type Int8 within the range [0, max).

Parameters:

- max: Int8 - The upper bound of the range.

Return Value:

- Int8 - A random number of type Int8.

Exceptions:

- IllegalArgumentException - Thrown when max is non-positive.
- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate a random number or encounters an error during generation.

### func nextUInt16()

```cangjie
public func nextUInt16(): UInt16
```

Function: Obtains a random number of type UInt16.

Return Value:

- UInt16 - A random number of type UInt16.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate a random number or encounters an error during generation.

### func nextUInt16(UInt16)

```cangjie
public func nextUInt16(max: UInt16): UInt16
```

Function: Obtains a random number of type UInt16 within the range [0, max).

Parameters:

- max: UInt16 - The upper bound of the range.

Return Value:

- UInt16 - A random number of type UInt16.

Exceptions:

- IllegalArgumentException - Thrown when max is 0.
- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate a random number or encounters an error during generation.

### func nextUInt32()

```cangjie
public func nextUInt32(): UInt32
```

Function: Obtains a random number of type UInt32.

Return Value:

- UInt32 - A random number of type UInt32.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate a random number or encounters an error during generation.

### func nextUInt32(UInt32)

```cangjie
public func nextUInt32(max: UInt32): UInt32
```

Function: Obtains a random number of type UInt32 within the range [0, max).

Parameters:

- max: UInt32 - The upper bound of the range.

Return Value:

- UInt32 - A random number of type UInt32.

Exceptions:

- IllegalArgumentException - Thrown when max is 0.
- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate a random number or encounters an error during generation.

### func nextUInt64()

```cangjie
public func nextUInt64(): UInt64
```

Function: Obtains a random number of type UInt64.

Return Value:

- UInt64 - A random number of type UInt64.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate a random number or encounters an error during generation.

### func nextUInt64(UInt64)

```cangjie
public func nextUInt64(max: UInt64): UInt64
```

Function: Obtains a random number of type UInt64 within the range [0, max).

Parameters:

- max: UInt64 - The upper bound of the range.

Return Value:

- UInt64 - A random number of type UInt64.

Exceptions:

- IllegalArgumentException - Thrown when max is 0.
- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate a random number or encounters an error during generation.

### func nextUInt8()

```cangjie
public func nextUInt8(): UInt8
```

Function: Obtains a random number of type UInt8.

Return Value:

- UInt8 - A random number of type UInt8.

Exceptions:

- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate a random number or encounters an error during generation.

### func nextUInt8(UInt8)

```cangjie
public func nextUInt8(max: UInt8): UInt8
```

Function: Obtains a random number of type UInt8 within the range [0, max).

Parameters:

- max: UInt8 - The upper bound of the range.

Return Value:

- UInt8 - A random number of type UInt8.

Exceptions:

- IllegalArgumentException - Thrown when max is 0.
- [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) - Thrown when the generator fails to correctly generate a random number or encounters an error during generation.

## class SM4

```cangjie
public class SM4 <: BlockCipher {
    public init(
        optMode: OperationMode,
        key: Array<Byte>,
        iv!: Array<Byte> = Array<Byte>(),
        paddingMode!: PaddingMode = PaddingMode.PKCS7Padding,
        aad!: Array<Byte> = Array<Byte>(),
        tagSize!: Int64 = 16
    )
}
```

Function: Provides SM4 symmetric encryption and decryption, a Chinese national cryptographic standard.

Currently, SM4 supports encryption and decryption modes defined by [OperationMode](crypto_package_structs.md#struct-operationmode), including ECB, CBC, OFB, CFB, CTR, and GCM modes.

Different operation modes may have varying implementations and security levels. It is essential to choose the appropriate mode for the specific scenario.

- **iv (Initialization Vector)**:
    - Recommended length is 12 bytes in GCM mode.
    - Length must be 16 bytes in CBC, OFB, CFB, and CTR modes.
    - Optional in ECB mode.

- **paddingMode**: Defined by [PaddingMode](crypto_package_structs.md#struct-paddingmode), currently supporting:
    - `NoPadding`: No padding.
    - `PKCS7Padding`: PKCS7 padding (default).

Padding mode is effective only for ECB and CBC modes, where block length must equal `blockSize`. Padding is applied accordingly. Padding mode settings are irrelevant for OFB, CFB, CTR, and GCM modes, as these modes do not require padding.

If `NoPadding` is selected, the user is responsible for ensuring data can be divided into blocks. If data cannot be divided or the last block is shorter than `blockSize`, an error will occur.

- **aad (Additional Authenticated Data)**: Used only in GCM mode, provided by the user for digest calculation (default is empty).
- **tagSize**: Digest length, used only in GCM mode. Default is `SM4_GCM_TAG_SIZE` (16 bytes). Minimum is 12 bytes; maximum is 16 bytes.

In GCM mode, the last `tagSize` bytes of the encrypted result are the digest data.

For usage examples, see [SM4 Usage](../crypto_samples/sample_crypto.md).

> **Note:**
>
> GCM mode requires OpenSSL 3.2 or higher.

Parent Type:

- BlockCipher

### init(OperationMode, Array\<Byte>, Array\<Byte>, PaddingMode, Array\<Byte>, Int64)

```cangjie
public init(
    optMode: OperationMode,
    key: Array<Byte>,
    iv!: Array<Byte> = Array<Byte>(),
    paddingMode!: PaddingMode = PaddingMode.PKCS7Padding,
    aad!: Array<Byte> = Array<Byte>(),
    tagSize!: Int64 = 16
)
```

Function: Creates an [SM4](crypto_package_classes.md#class-sm4) instance with specified parameters for different operation modes.

Parameters:

- optMode: [OperationMode](crypto_package_structs.md#struct-operationmode) - Sets the encryption/decryption operation mode.
- key: Array\<Byte> - The encryption key (16 bytes).
- iv!: Array\<Byte> - The initialization vector.
- paddingMode!: [PaddingMode](crypto_package_structs.md#struct-paddingmode) - Sets the padding mode.
- aad!: Array\<Byte> - Sets additional authenticated data.
- tagSize!: Int64 - Sets the digest length.

Exceptions:

- [CryptoException](../../digest/digest_package_api/digest_package_exceptions.md#class-cryptoexception) - Thrown if parameter settings are incorrect, causing instantiation to fail.

### prop aad

```cangjie
public prop aad: Array<Byte>
```

Function: Additional authenticated data.

Type: Array\<Byte>

### prop algorithm

```cangjie
public prop algorithm: String
```

Function: Gets the algorithm name for block cipher encryption/decryption.

Type: String

### prop blockSize

```cangjie
public prop blockSize: Int64
```

Function: Block size in bytes.

Type: Int64

### prop keySize

```cangjie
public prop keySize: Int64
```

Function: Key length.

Type: Int64

### prop key

```cangjie
public prop key: Array<Byte>
```

Function: Encryption key.

Type: Array\<Byte>

### prop optMode

```cangjie
public prop optMode: OperationMode
```

Function: Cipher operation mode.

Type: [OperationMode](crypto_package_structs.md#struct-operationmode)

### prop paddingMode

```cangjie
public prop paddingMode: PaddingMode
```

Function: Padding mode.

Type: [PaddingMode](crypto_package_structs.md#struct-paddingmode)

### prop iv

```cangjie
public prop iv: Array<Byte>
```

Function: Initialization vector.

Type: Array\<Byte>

### prop ivSize

```cangjie
public prop ivSize: Int64
```

Function: Initialization vector length.

Type: Int64

### prop tagSize

```cangjie
public prop tagSize: Int64
```

Function: Authentication tag length.

Type: Int64

### func encrypt(Array\<Byte>)

```cangjie
public func encrypt(input: Array<Byte>): Array<Byte>
```

Function: Encrypts input data.

Parameters:

- input: Array\<Byte> - Input byte sequence.

Return value:

- Array\<Byte> - Encrypted result.

Exceptions:

- [CryptoException](../../digest/digest_package_api/digest_package_exceptions.md#class-cryptoexception) - Thrown when encryption fails.

### func encrypt(Array\<Byte>, Array\<Byte>)

```cangjie
public func encrypt(input: Array<Byte>, to!: Array<Byte>): Int64
```

Function: Encrypts input data with specified output array length (affects result). For padding modes, output array length must not be less than plaintext length plus one blockSize.

Parameters:

- input: Array\<Byte> - Data to be encrypted.
- to!: Array\<Byte> - Output array.

Return value:

- Int64 - Output length.

Exceptions:

- [CryptoException](../../digest/digest_package_api/digest_package_exceptions.md#class-cryptoexception) - Thrown when encryption fails.
- IllegalArgumentException - Thrown when 'to' array size is 0.

### func encrypt(InputStream, OutputStream)

```cangjie
public func encrypt(input: InputStream, output: OutputStream): Unit
```

Function: Encrypts input stream (for large data that cannot be processed at once).

Parameters:

- input:InputStream - Input stream to be encrypted.
- output: OutputStream - Output stream for encrypted data.

Exceptions:

- [CryptoException](../../digest/digest_package_api/digest_package_exceptions.md#class-cryptoexception) - Thrown when encryption fails.

### func decrypt(Array\<Byte>)

```cangjie
public func decrypt(input: Array<Byte>): Array<Byte>
```

Function: Decrypts input data.

Parameters:

- input: Array\<Byte> - Input byte sequence.

Return value:

- Array\<Byte> - Decrypted result.

Exceptions:

- [CryptoException](../../digest/digest_package_api/digest_package_exceptions.md#class-cryptoexception) - Thrown when decryption fails.

### func decrypt(Array\<Byte>, Array\<Byte>)

```cangjie
public func decrypt(input: Array<Byte>,  to!: Array<Byte>): Int64
```

Function: Decrypts input data with specified output array length (affects result). Plaintext array length must not be less than ciphertext length minus one blockSize.

Parameters:

- input: Array\<Byte> - Data to be decrypted.
- to!: Array\<Byte> - Output array.

Return value:

- Int64 - Output length.

Exceptions:

- [CryptoException](../../digest/digest_package_api/digest_package_exceptions.md#class-cryptoexception) - Thrown when decryption fails.
- IllegalArgumentException - Thrown when 'to' array size is 0.

### func decrypt(InputStream, OutputStream)

```cangjie
public func decrypt(input: InputStream, output: OutputStream): Unit
```

Function: Decrypts input stream (for large data that cannot be processed at once).

Parameters:

- input: InputStream - Input stream to be decrypted.
- output: OutputStream - Output stream for decrypted data.

Exceptions:

- [CryptoException](../../digest/digest_package_api/digest_package_exceptions.md#class-cryptoexception) - Thrown when decryption fails.
