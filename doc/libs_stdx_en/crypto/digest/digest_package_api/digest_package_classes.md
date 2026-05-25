# Classes

## class HMAC

```cangjie
public class HMAC <: Digest {
    public init(key: Array<Byte>, digest: () -> Digest)
    public init(key: Array<Byte>, algorithm: HashType)
}
```

Function: Provides implementation of the [HMAC](digest_package_classes.md#class-hmac) algorithm. Currently supported digest algorithms include MD5, SHA1, SHA224, SHA256, SHA384, SHA512, SM3.

Parent Type:

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

Function: The algorithm name of the selected Hash algorithm for [HMAC](digest_package_classes.md#class-hmac).

Type: String

### prop blockSize

```cangjie
public prop blockSize: Int64
```

Function: Block size of the selected Hash algorithm for [HMAC](digest_package_classes.md#class-hmac), in bytes.

Type: Int64

### prop size

```cangjie
public prop size: Int64
```

Function: Digest length of the selected Hash algorithm for [HMAC](digest_package_classes.md#class-hmac), in bytes.

Type: Int64

### init(Array\<Byte>, () -> Digest)

```cangjie
public init(key: Array<Byte>, digest: () -> Digest)
```

Function: Constructor, creates an [HMAC](digest_package_classes.md#class-hmac) object.

Parameters:

- key: Array\<Byte> - The secret key. It is recommended that this parameter should not be smaller than the digest length of the selected Hash algorithm.
- digest: () -> Digest - The hash algorithm.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when the key value is empty.

### init(Array\<Byte>, HashType)

```cangjie
public init(key: Array<Byte>, algorithm: HashType)
```

Function: Constructor, creates an [HMAC](digest_package_classes.md#class-hmac) object.

Parameters:

- key: Array\<Byte> - The secret key. It is recommended that this parameter should not be smaller than the digest length of the selected Hash algorithm.
- algorithm: [HashType](digest_package_structs.md#struct-hashtype) - The hash algorithm.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when the key value is empty.

### static func equal(Array\<Byte>, Array\<Byte>)

```cangjie
public static func equal(mac1: Array<Byte>, mac2: Array<Byte>): Bool
```

Function: Compares whether two digests are equal without leaking comparison time. The comparison does not use the traditional short-circuit principle to prevent timing attack type vulnerabilities.

Parameters:

- mac1: Array\<Byte> - The first digest sequence to compare.
- mac2: Array\<Byte> - The second digest sequence to compare.

Return Value:

- Bool - Whether the digests are identical. true means identical, false means different.

### func finish()

```cangjie
public func finish(): Array<Byte>
```

Function: Returns the generated digest value. Note that after calling finish(), no further digest calculations can be performed. To recalculate, the context must be reset using reset().

Return Value:

- Array\<Byte> - The generated digest byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when finish() is called again for digest calculation without resetting the context.

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

Function: Gets the generated digest value. Note that after calling finish(), no further digest calculations can be performed. To recalculate, the context must be reset using reset().

Parameters:

- to!: Array\<Byte> - The target array.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when finish() is called again for digest calculation without resetting the context, or when the specified output array size does not match the digest algorithm's length.

### func reset()

```cangjie
public func reset(): Unit
```

Function: Resets the [HMAC](digest_package_classes.md#class-hmac) object to its initial state, clearing the [HMAC](digest_package_classes.md#class-hmac) context.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when an internal error occurs and the reset fails.

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit 
```

Function: Updates the [HMAC](digest_package_classes.md#class-hmac) object with the given buffer. Can be updated multiple times before calling finish().

Parameters:

- buffer: Array\<Byte> - The byte sequence to append.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when the buffer is empty or when finish() has already been called to generate the digest.

## class MD5

```cangjie
public class MD5 <: Digest {
    public init()
}
```

Function: Provides the implementation interface for the [MD5](digest_package_classes.md#class-md5) algorithm. For usage examples, see [MD5 Algorithm Example](../digest_samples/sample_digest.md#md5-algorithm-example).

Parent Type:

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

Function: The algorithm name of the [MD5](digest_package_classes.md#class-md5) digest algorithm.

Type: String

### prop blockSize

```cangjie
public prop blockSize: Int64
```

Function: Block size of [MD5](digest_package_classes.md#class-md5), in bytes.

Type: Int64

### prop size

```cangjie
public prop size: Int64
```

Function: Digest length of [MD5](digest_package_classes.md#class-md5), in bytes.

Type: Int64

### init()

```cangjie
public init()
```

Function: Parameterless constructor, creates an [MD5](digest_package_classes.md#class-md5) object.

### func finish()

```cangjie
public func finish(): Array<Byte>
```

Function: Returns the generated [MD5](digest_package_classes.md#class-md5) value. Note that after calling finish(), the [MD5](digest_package_classes.md#class-md5) context will change, and no further digest calculations can be performed. To recalculate, the context must be reset using reset().

Return Value:

- Array\<Byte> - The generated [MD5](digest_package_classes.md#class-md5) byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when finish() is called again for digest calculation without resetting the context.

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

Function: Gets the generated digest value. Note that after calling finish(), no further digest calculations can be performed. To recalculate, the context must be reset using reset().

Parameters:

- to!: Array\<Byte> - The target array.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when finish() is called again for digest calculation without resetting the context, or when the specified output array size does not match the digest algorithm's length.

### func reset()

```cangjie
public func reset(): Unit
```

Function: Resets the [MD5](digest_package_classes.md#class-md5) object to its initial state, clearing the [MD5](digest_package_classes.md#class-md5) context.

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

Function: Updates the [MD5](digest_package_classes.md#class-md5) object with the given buffer. Can be updated multiple times before calling finish().

Parameters:

- buffer: Array\<Byte> - The input byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when finish() has already been called for digest calculation without resetting the context.

## class SHA1

```cangjie
public class SHA1 <: Digest {
    public init()
}
```

Function: Provides the implementation interface for the [SHA1](digest_package_classes.md#class-sha1) algorithm. For usage examples, see [SHA1 Algorithm Example](../digest_samples/sample_digest.md#sha1-algorithm-example).

Parent Type:

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

Function: The algorithm name of the [SHA1](digest_package_classes.md#class-sha1) digest algorithm.

Type: String

### prop blockSize

```cangjie
public prop blockSize: Int64
```

Function: Block size of [SHA1](digest_package_classes.md#class-sha1), in bytes.

Type: Int64

### prop size

```cangjie
public prop size: Int64
```

Function: The length of [SHA1](digest_package_classes.md#class-sha1) digest information, in bytes.

Type: Int64

### init()

```cangjie
public init()
```

Function: Parameterless constructor, creates a [SHA1](digest_package_classes.md#class-sha1) object.

### func finish()

```cangjie
public func finish(): Array<Byte>
```

Function: Returns the generated [SHA1](digest_package_classes.md#class-sha1) value. Note that after calling finish, the [SHA1](digest_package_classes.md#class-sha1) context will change. No further digest computation is allowed after finish. To recompute, the context must be reset via reset.

Return value:

- Array\<Byte> - The generated [SHA1](digest_package_classes.md#class-sha1) byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if finish is called again for digest computation without resetting the context.

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

Function: Retrieves the generated digest value. Note that no further digest computation is allowed after calling finish. To recompute, the context must be reset via reset.

Parameters:

- to!: Array\<Byte> - Target array.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if finish is called again for digest computation without resetting the context, or if the specified output array size does not match the digest algorithm's information length.

### func reset()

```cangjie
public func reset(): Unit
```

Function: Resets the [SHA1](digest_package_classes.md#class-sha1) object to its initial state, clearing the [SHA1](digest_package_classes.md#class-sha1) context.

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

Function: Updates the [SHA1](digest_package_classes.md#class-sha1) object with the given buffer. Can be updated multiple times before calling finish.

Parameters:

- buffer: Array\<Byte> - Input byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if digest computation has already been performed via finish without resetting the context.

## class SHA224

```cangjie
public class SHA224 <: Digest {
    public init()
}
```

Function: Provides the implementation interface for the [SHA224](digest_package_classes.md#class-sha224) algorithm. Usage examples can be found in [SHA224 Algorithm Example](../digest_samples/sample_digest.md#sha224-algorithm-example).

Parent type:

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

Function: The algorithm name of the [SHA224](digest_package_classes.md#class-sha224) digest algorithm.

Type: String

### prop blockSize

```cangjie
public prop blockSize: Int64
```

Function: The block length of [SHA224](digest_package_classes.md#class-sha224) information, in bytes.

Type: Int64

### prop size

```cangjie
public prop size: Int64
```

Function: The length of [SHA224](digest_package_classes.md#class-sha224) digest information, in bytes.

Type: Int64

### init()

```cangjie
public init()
```

Function: Parameterless constructor, creates a [SHA224](digest_package_classes.md#class-sha224) object.

### func finish()

```cangjie
public func finish(): Array<Byte>
```

Function: Returns the generated [SHA224](digest_package_classes.md#class-sha224) value. Note that after calling finish, the [SHA224](digest_package_classes.md#class-sha224) context will change. No further digest computation is allowed after finish. To recompute, the context must be reset via reset.

Return value:

- Array\<Byte> - The generated [SHA224](digest_package_classes.md#class-sha224) byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if finish is called again for digest computation without resetting the context.

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

Function: Retrieves the generated digest value. Note that no further digest computation is allowed after calling finish. To recompute, the context must be reset via reset.

Parameters:

- to!: Array\<Byte> - Target array.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if finish is called again for digest computation without resetting the context, or if the specified output array size does not match the digest algorithm's information length.

### func reset()

```cangjie
public func reset(): Unit
```

Function: Resets the [SHA224](digest_package_classes.md#class-sha224) object to its initial state, clearing the [SHA224](digest_package_classes.md#class-sha224) context.

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

Function: Updates the [SHA224](digest_package_classes.md#class-sha224) object with the given buffer. Can be updated multiple times before calling finish.

Parameters:

- buffer: Array\<Byte> - Input byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if digest computation has already been performed via finish without resetting the context.

## class SHA256

```cangjie
public class SHA256 <: Digest {
    public init()
}
```

Function: Provides the implementation interface for the [SHA256](digest_package_classes.md#class-sha256) algorithm. Usage examples can be found in [SHA256 Algorithm Example](../digest_samples/sample_digest.md#sha256-algorithm-example).

Parent type:

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

Function: The algorithm name of the [SHA256](digest_package_classes.md#class-sha256) digest algorithm.

Type: String

### prop blockSize

```cangjie
public prop blockSize: Int64
```

Function: The block length of [SHA256](digest_package_classes.md#class-sha256) information, in bytes.

Type: Int64

### prop size

```cangjie
public prop size: Int64
```

Function: The length of [SHA256](digest_package_classes.md#class-sha256) digest information, in bytes.

Type: Int64

### init()

```cangjie
public init()
```

Function: Parameterless constructor, creates a [SHA256](digest_package_classes.md#class-sha256) object.

### func finish()

```cangjie
public func finish(): Array<Byte>
```

Function: Returns the generated [SHA256](digest_package_classes.md#class-sha256) value. Note that after calling finish, the [SHA256](digest_package_classes.md#class-sha256) context will change. No further digest computation is allowed after finish. To recompute, the context must be reset via reset.

Return value:

- Array\<Byte> - The generated [SHA256](digest_package_classes.md#class-sha256) byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if finish is called again for digest computation without resetting the context.

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

Function: Retrieves the generated digest value. Note that no further digest computation is allowed after calling finish. To recompute, the context must be reset via reset.

Parameters:

- to!: Array\<Byte> - Target array.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if finish is called again for digest computation without resetting the context, or if the specified output array size does not match the digest algorithm's information length.

### func reset()

```cangjie
public func reset(): Unit
```

Function: Resets the [SHA256](digest_package_classes.md#class-sha256) object to its initial state, clearing the [SHA256](digest_package_classes.md#class-sha256) context.

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

Function: Updates the [SHA256](digest_package_classes.md#class-sha256) object with the given buffer. Can be updated multiple times before calling finish.

Parameters:

- buffer: Array\<Byte> - Input byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if digest computation has already been performed via finish without resetting the context.

## class SHA384

```cangjie
public class SHA384 <: Digest {
    public init()
}
```

Function: Provides the implementation interface for the [SHA384](digest_package_classes.md#class-sha384) algorithm. Usage examples can be found in [SHA384 Algorithm Example](../digest_samples/sample_digest.md#sha384-algorithm-example).

Parent Type:

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

Function: Algorithm name for the [SHA384](digest_package_classes.md#class-sha384) digest algorithm.

Type: String

### prop blockSize

```cangjie
public prop blockSize: Int64
```

Function: Block size of [SHA384](digest_package_classes.md#class-sha384) in bytes.

Type: Int64

### prop size

```cangjie
public prop size: Int64
```

Function: Digest length of [SHA384](digest_package_classes.md#class-sha384) in bytes.

Type: Int64

### init()

```cangjie
public init()
```

Function: Parameterless constructor to create a [SHA384](digest_package_classes.md#class-sha384) object.

### func finish()

```cangjie
public func finish(): Array<Byte>
```

Function: Returns the generated [SHA384](digest_package_classes.md#class-sha384) value. Note that the [SHA384](digest_package_classes.md#class-sha384) context will change after calling finish(), and no further digest calculations can be performed. To recalculate, the context must be reset using reset().

Return Value:

- Array\<Byte> - Generated [SHA384](digest_package_classes.md#class-sha384) byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if finish() is called again for digest calculation without resetting the context.

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

Function: Retrieves the generated message digest value. Note that no further digest calculations can be performed after calling finish(). To recalculate, the context must be reset using reset().

Parameters:

- to!: Array\<Byte> - Target array.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if finish() is called again for digest calculation without resetting the context, or if the specified output array size does not match the digest algorithm's message length.

### func reset()

```cangjie
public func reset(): Unit
```

Function: Resets the [SHA384](digest_package_classes.md#class-sha384) object to its initial state, clearing the [SHA384](digest_package_classes.md#class-sha384) context.

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

Function: Updates the [SHA384](digest_package_classes.md#class-sha384) object with the given buffer. Can be updated multiple times before calling finish().

Parameters:

- buffer: Array\<Byte> - Input byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if finish() has been called for digest calculation without resetting the context.

## class SHA512

```cangjie
public class SHA512 <: Digest {
    public init()
}
```

Function: Provides implementation interface for the [SHA512](digest_package_classes.md#class-sha512) algorithm. See [SHA512 Algorithm Example](../digest_samples/sample_digest.md#sha512-algorithm-example) for usage.

Parent Type:

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

Function: Algorithm name for the [SHA512](digest_package_classes.md#class-sha512) digest algorithm.

Type: String

### prop blockSize

```cangjie
public prop blockSize: Int64
```

Function: Block size of [SHA512](digest_package_classes.md#class-sha512) in bytes.

Type: Int64

### prop size

```cangjie
public prop size: Int64
```

Function: Digest length of [SHA512](digest_package_classes.md#class-sha512) in bytes.

Type: Int64

### init()

```cangjie
public init()
```

Function: Parameterless constructor to create a [SHA512](digest_package_classes.md#class-sha512) object.

### func finish()

```cangjie
public func finish(): Array<Byte>
```

Function: Returns the generated [SHA512](digest_package_classes.md#class-sha512) value. Note that the [SHA512](digest_package_classes.md#class-sha512) context will change after calling finish(), and no further digest calculations can be performed. To recalculate, the context must be reset using reset().

Return Value:

- Array\<Byte> - Generated [SHA512](digest_package_classes.md#class-sha512) byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if finish() is called again for digest calculation without resetting the context.

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

Function: Retrieves the generated message digest value. Note that no further digest calculations can be performed after calling finish(). To recalculate, the context must be reset using reset().

Parameters:

- to!: Array\<Byte> - Target array.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if finish() is called again for digest calculation without resetting the context, or if the specified output array size does not match the digest algorithm's message length.

### func reset()

```cangjie
public func reset(): Unit
```

Function: Resets the [SHA512](digest_package_classes.md#class-sha512) object to its initial state, clearing the [SHA512](digest_package_classes.md#class-sha512) context.

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

Function: Updates the [SHA512](digest_package_classes.md#class-sha512) object with the given buffer. Can be updated multiple times before calling finish().

Parameters:

- buffer: Array\<Byte> - Input byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if finish() has been called for digest calculation without resetting the context.

## class SM3

```cangjie
public class SM3 <: Digest {
    public init()
}
```

Function: Provides implementation interface for the [SM3](digest_package_classes.md#class-sm3) algorithm. See [SM3 Algorithm Example](../digest_samples/sample_digest.md#sm3-algorithm-example) for usage.

Parent Type:

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

Function: Algorithm name for the [SM3](digest_package_classes.md#class-sm3) digest algorithm.

Type: String

### prop blockSize

```cangjie
public prop blockSize: Int64
```

Function: Block size of [SM3](digest_package_classes.md#class-sm3) in bytes.

Type: Int64

### prop size

```cangjie
public prop size: Int64
```

Function: Digest length of [SM3](digest_package_classes.md#class-sm3) in bytes.

Type: Int64

### init()

```cangjie
public init()
```

Function: Parameterless constructor to create a [SM3](digest_package_classes.md#class-sm3) object.

### func finish()

```cangjie
public func finish(): Array<Byte>
```

Function: Returns the generated [SM3](digest_package_classes.md#class-sm3) value. Note that the [SM3](digest_package_classes.md#class-sm3) context will change after calling finish(), and no further digest calculations can be performed. To recalculate, the context must be reset using reset().

Return Value:

- Array\<Byte> - Generated [SM3](digest_package_classes.md#class-sm3) byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if finish() is called again for digest calculation without resetting the context.

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

Function: Retrieves the generated message digest value. Note that no further digest calculations can be performed after calling finish(). To recalculate, the context must be reset using reset().

Parameters:

- to!: Array\<Byte> - Target array.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown if finish() is called again for digest calculation without resetting the context, or if the specified output array size does not match the digest algorithm's message length.

### func reset()

```cangjie
public func reset(): Unit
```

Function: Resets the [SM3](digest_package_classes.md#class-sm3) object to its initial state, clearing the [SM3](digest_package_classes.md#class-sm3) context.

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

Function: Updates the [SM3](digest_package_classes.md#class-sm3) object with the given buffer. Can be called multiple times before invoking finish.

Parameters:

- buffer: Array\<Byte> - Input byte sequence.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Throws this exception if the context has not been reset after calling finish for digest computation.
