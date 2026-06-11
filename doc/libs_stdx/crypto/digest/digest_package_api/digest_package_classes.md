# 类

## class HMAC

```cangjie
public class HMAC <: Digest {
    public init(key: Array<Byte>, digest: () -> Digest)
    public init(key: Array<Byte>, algorithm: HashType)
}
```

功能：提供 [HMAC](digest_package_classes.md#class-hmac) 算法的实现。目前支持的摘要算法包括 MD5、SHA1、SHA224、SHA256、SHA384、SHA512、SM3。

父类型：

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

功能：[HMAC](digest_package_classes.md#class-hmac) 所选 Hash 算法的算法名称。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.crypto.crypto.*

main() {
    let random = SecureRandom(priv: true)
    let key = random.nextBytes(32)

    let hmac = HMAC(key, HashType.SHA256)

    let algorithm = hmac.algorithm
    println("HMAC算法: ${algorithm}")

    return 0
}
```

运行结果：

```text
HMAC算法: HMAC-SHA256
```

### prop blockSize

```cangjie
public prop blockSize: Int64
```

功能：[HMAC](digest_package_classes.md#class-hmac) 所选 Hash 算法信息块长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.crypto.crypto.*

main() {
    let random = SecureRandom(priv: true)
    let key = random.nextBytes(32)

    let hmac = HMAC(key, HashType.SHA256)

    let blockSize = hmac.blockSize
    println("块大小: ${blockSize}")

    return 0
}
```

运行结果：

```text
块大小: 64
```

### prop size

```cangjie
public prop size: Int64
```

功能：[HMAC](digest_package_classes.md#class-hmac) 所选 Hash 算法的摘要信息长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.crypto.crypto.*

main() {
    let random = SecureRandom(priv: true)
    let key = random.nextBytes(32)

    let hmac = HMAC(key, HashType.SHA256)

    let size = hmac.size
    println("摘要长度: ${size}")

    return 0
}
```

运行结果：

```text
摘要长度: 32
```

### init(Array\<Byte>, () -> Digest)

```cangjie
public init(key: Array<Byte>, digest: () -> Digest)
```

功能：构造函数，创建 [HMAC](digest_package_classes.md#class-hmac) 对象。

参数：

- key: Array\<Byte> - 密钥，建议该参数不小于所选 Hash 算法摘要的长度。
- digest: () -> Digest - hash 算法。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - key 值为空时，抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.crypto.crypto.*

main() {
    let random = SecureRandom(priv: true)
    let key = random.nextBytes(32)
    let hmac = HMAC(key, {=> SHA256()})

    println("HMAC算法: ${hmac.algorithm}")
    println("摘要长度: ${hmac.size}")
    println("密钥长度: ${key.size}")
    println("密钥长度不小于摘要长度: ${key.size >= hmac.size}")
    return 0
}
```

运行结果：

```text
HMAC算法: HMAC-SHA256
摘要长度: 32
密钥长度: 32
密钥长度不小于摘要长度: true
```

### init(Array\<Byte>, HashType)

```cangjie
public init(key: Array<Byte>, algorithm: HashType)
```

功能：构造函数，创建 [HMAC](digest_package_classes.md#class-hmac) 对象。

参数：

- key: Array\<Byte> - 密钥，建议该参数不小于所选 Hash 算法摘要的长度。
- algorithm: [HashType](digest_package_structs.md#struct-hashtype) - hash 算法。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - key 值为空时，抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.crypto.crypto.*

main() {
    let random = SecureRandom(priv: true)
    let key = random.nextBytes(32)
    let hmac = HMAC(key, HashType.SHA256)

    println("HMAC算法: ${hmac.algorithm}")
    println("摘要长度: ${hmac.size}")
    println("密钥长度: ${key.size}")
    println("密钥长度不小于摘要长度: ${key.size >= hmac.size}")
    return 0
}
```

运行结果：

```text
HMAC算法: HMAC-SHA256
摘要长度: 32
密钥长度: 32
密钥长度不小于摘要长度: true
```

### static func equal(Array\<Byte>, Array\<Byte>)

```cangjie
public static func equal(mac1: Array<Byte>, mac2: Array<Byte>): Bool
```

功能：比较两个信息摘要是否相等，且不泄露比较时间，即比较不采用传统短路原则，从而防止 timing attack 类型的攻击。

参数：

- mac1: Array\<Byte> - 需要比较的信息摘要序列。
- mac2: Array\<Byte> - 需要比较的信息摘要序列。

返回值：

- Bool - 信息摘要是否相同，true 相同，false 不相同。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.crypto.crypto.*

main() {
    let key1 = "mySecretKey".toArray()
    let key2 = "mySecretKey".toArray()
    let data1 = "Hello, World!".toArray()
    let data2 = "Hello, World!".toArray()

    let hmac1 = HMAC(key1, HashType.SHA256)
    let hmac2 = HMAC(key2, HashType.SHA256)

    hmac1.write(data1)
    hmac2.write(data2)

    let mac1 = hmac1.finish()
    let mac2 = hmac2.finish()

    let isEqual = HMAC.equal(mac1, mac2)
    println("摘要是否相同: ${isEqual}")

    return 0
}
```

运行结果：

```text
摘要是否相同: true
```

### func finish()

```cangjie
public func finish(): Array<Byte>
```

功能：返回生成的信息摘要值，注意调用 finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

返回值：

- Array\<Byte> - 生成的信息摘要字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算，抛此异常。

示例：

<!-- run -->
```cangjie
import stdx.crypto.digest.*
import stdx.crypto.crypto.*

main() {
    let random = SecureRandom(priv: true)
    let key = random.nextBytes(32)
    let data = "Hello, World!".toArray()

    let hmac = HMAC(key, HashType.MD5)
    hmac.write(data)

    let result = hmac.finish()
    println("${hmac.algorithm}摘要: ${result}")

    return 0
}
```

可能的运行结果：

```text
HMAC-MD5摘要: [22, 198, 33, 44, 225, 231, 29, 141, 214, 143, 8, 188, 108, 114, 150, 21]
```

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

功能：获取生成的信息摘要值，注意调用 finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

参数：

- to!: Array\<Byte> - 目标数组。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算或者指定输出数组大小不等于摘要算法信息长度，抛此异常。

示例：

<!-- run -->
```cangjie
import stdx.crypto.digest.*
import stdx.crypto.crypto.*

main() {
    let random = SecureRandom(priv: true)
    let key = random.nextBytes(32)
    let data = "Hello, World!".toArray()

    let hmac = HMAC(key, HashType.MD5)
    hmac.write(data)

    let output = Array<Byte>(hmac.size, repeat: 0)
    hmac.finish(to: output)
    println("输出数组: ${output}")

    return 0
}
```

可能的运行结果：

```text
输出数组: [253, 224, 17, 238, 0, 31, 114, 118, 132, 239, 222, 219, 11, 248, 114, 169]
```

### func reset()

```cangjie
public func reset(): Unit
```

功能：重置 [HMAC](digest_package_classes.md#class-hmac) 对象到初始状态，清理 [HMAC](digest_package_classes.md#class-hmac) 上下文。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 当内部错误，重置失败，抛此异常。

示例：

<!-- run -->
```cangjie
import stdx.crypto.digest.*
import stdx.crypto.crypto.*

main() {
    let random = SecureRandom(priv: true)
    let key = random.nextBytes(32)
    let data1 = "Hello".toArray()
    let data2 = "World".toArray()

    let hmac = HMAC(key, HashType.MD5)
    hmac.write(data1)

    let result1 = hmac.finish()
    println("${hmac.algorithm}第一次摘要: ${result1}")

    hmac.reset() // 重置HMAC对象
    println("保留密钥和算法，可重新计算新数据的摘要")

    hmac.write(data2)

    let result2 = hmac.finish()
    println("${hmac.algorithm}重置后摘要: ${result2}")

    return 0
}
```

运行结果：

```text
HMAC-MD5第一次摘要: [138, 105, 2, 119, 31, 115, 202, 188, 146, 122, 244, 175, 173, 233, 58, 189]
保留密钥和算法，可重新计算新数据的摘要
HMAC-MD5重置后摘要: [108, 167, 54, 164, 167, 9, 223, 48, 21, 26, 111, 32, 217, 239, 25, 57]
```

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

功能：使用给定的 buffer 更新 [HMAC](digest_package_classes.md#class-hmac) 对象，在调用 finish 前可以多次更新。

参数：

- buffer: Array\<Byte> - 需要追加的字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 当 buffer 为空、finish 已经调用生成信息摘要场景，抛此异常。

示例：

<!-- run -->
```cangjie
import stdx.crypto.digest.*
import stdx.crypto.crypto.*

main() {
    let random = SecureRandom(priv: true)
    let key = random.nextBytes(32)
    let data1 = "Hello".toArray()
    let data2 = " ".toArray()
    let data3 = "World".toArray()

    let hmac = HMAC(key, HashType.MD5)
    hmac.write(data1) // 写入第一部分数据
    hmac.write(data2) // 写入第二部分数据
    hmac.write(data3) // 写入第三部分数据

    let result = hmac.finish()
    println("${hmac.algorithm}摘要: ${result}")

    return 0
}
```

可能的运行结果：

```text
HMAC-MD5摘要: [99, 114, 182, 143, 83, 216, 88, 65, 50, 42, 136, 210, 128, 83, 39, 229]
```

## class MD5

```cangjie
public class MD5 <: Digest {
    public init()
}
```

功能：提供 [MD5](digest_package_classes.md#class-md5) 算法的实现接口。使用示例见 [MD5 算法示例](../digest_samples/sample_digest.md#md5-算法示例)。

父类型：

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

功能：[MD5](digest_package_classes.md#class-md5) 摘要算法的算法名称。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let md5 = MD5()

    let algorithm = md5.algorithm
    println("MD5算法: ${algorithm}")

    return 0
}
```

运行结果：

```text
MD5算法: MD5
```

### prop blockSize

```cangjie
public prop blockSize: Int64
```

功能：[MD5](digest_package_classes.md#class-md5) 信息块长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let md5 = MD5()

    let blockSize = md5.blockSize
    println("块大小: ${blockSize}")

    return 0
}
```

运行结果：

```text
块大小: 64
```

### prop size

```cangjie
public prop size: Int64
```

功能：[MD5](digest_package_classes.md#class-md5) 摘要信息长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let md5 = MD5()

    let size = md5.size
    println("摘要长度: ${size}")

    return 0
}
```

运行结果：

```text
摘要长度: 16
```

### init()

```cangjie
public init()
```

功能：无参构造函数，创建 [MD5](digest_package_classes.md#class-md5) 对象。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let md5 = MD5()

    println("MD5对象创建成功")
    println("算法: ${md5.algorithm}")
    println("块大小: ${md5.blockSize}")
    println("摘要长度: ${md5.size}")

    return 0
}
```

运行结果：

```text
MD5对象创建成功
算法: MD5
块大小: 64
摘要长度: 16
```

### func finish()

```cangjie
public func finish(): Array<Byte>
```

功能：返回生成的 [MD5](digest_package_classes.md#class-md5) 值，注意调用 finish 后 [MD5](digest_package_classes.md#class-md5) 上下文会发生改变，finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

返回值：

- Array\<Byte> - 生成的 [MD5](digest_package_classes.md#class-md5) 字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let md5 = MD5()
    let data = "Hello, World!".toArray()

    md5.write(data)

    let result = md5.finish()
    println("MD5摘要: ${result}")

    return 0
}
```

运行结果：

```text
MD5摘要: [101, 168, 226, 125, 136, 121, 40, 56, 49, 182, 100, 189, 139, 127, 10, 212]
```

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

功能：获取生成的信息摘要值，注意调用 finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

参数：

- to!: Array\<Byte> - 目标数组。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算或者指定输出数组大小不等于摘要算法信息长度，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let md5 = MD5()
    let data = "Hello, World!".toArray()

    md5.write(data)

    var output = Array<Byte>(md5.size, repeat: 0)
    md5.finish(to: output)
    println("输出数组: ${output}")

    return 0
}
```

运行结果：

```text
输出数组: [101, 168, 226, 125, 136, 121, 40, 56, 49, 182, 100, 189, 139, 127, 10, 212]
```

### func reset()

```cangjie
public func reset(): Unit
```

功能：重置 [MD5](digest_package_classes.md#class-md5) 对象到初始状态，清理 [MD5](digest_package_classes.md#class-md5) 上下文。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let md5 = MD5()
    let data1 = "Hello".toArray()
    let data2 = "World".toArray()

    md5.write(data1)
    let result1 = md5.finish()
    println("第一次摘要: ${result1}")

    md5.reset() // 重置MD5对象
    md5.write(data2)
    let result2 = md5.finish()
    println("重置后摘要: ${result2}")

    return 0
}
```

运行结果：

```text
第一次摘要: [139, 26, 153, 83, 196, 97, 18, 150, 168, 39, 171, 248, 196, 120, 4, 215]
重置后摘要: [245, 167, 146, 78, 98, 30, 132, 201, 40, 10, 154, 39, 225, 188, 183, 246]
```

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

功能：使用给定的 buffer 更新 [MD5](digest_package_classes.md#class-md5) 对象，在调用 finish 前可以多次更新。

参数：

- buffer: Array\<Byte> - 输入字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 已经调用 finish 进行摘要计算后未重置上下文，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let md5 = MD5()
    let data1 = "Hello".toArray()
    let data2 = " ".toArray()
    let data3 = "World".toArray()

    md5.write(data1) // 写入第一部分数据
    md5.write(data2) // 写入第二部分数据
    md5.write(data3) // 写入第三部分数据

    let result = md5.finish()
    println("MD5摘要: ${result}")

    return 0
}
```

运行结果：

```text
MD5摘要: [177, 10, 141, 177, 100, 224, 117, 65, 5, 183, 169, 155, 231, 46, 63, 229]
```

## class SHA1

```cangjie
public class SHA1 <: Digest {
    public init()
}
```

功能：提供 [SHA1](digest_package_classes.md#class-sha1) 算法的实现接口。使用示例见 [SHA1 算法示例](../digest_samples/sample_digest.md#sha1-算法示例)。

父类型：

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

功能：[SHA1](digest_package_classes.md#class-sha1) 摘要算法的算法名称。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha1 = SHA1()

    let algorithm = sha1.algorithm
    println("SHA1算法: ${algorithm}")

    return 0
}
```

运行结果：

```text
SHA1算法: SHA1
```

### prop blockSize

```cangjie
public prop blockSize: Int64
```

功能：[SHA1](digest_package_classes.md#class-sha1) 信息块长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha1 = SHA1()

    let blockSize = sha1.blockSize
    println("块大小: ${blockSize}")

    return 0
}
```

运行结果：

```text
块大小: 64
```

### prop size

```cangjie
public prop size: Int64
```

功能：[SHA1](digest_package_classes.md#class-sha1) 摘要信息长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha1 = SHA1()

    let size = sha1.size
    println("摘要长度: ${size}")

    return 0
}
```

运行结果：

```text
摘要长度: 20
```

### init()

```cangjie
public init()
```

功能：无参构造函数，创建 [SHA1](digest_package_classes.md#class-sha1) 对象。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha1 = SHA1()

    println("SHA1对象创建成功")
    println("算法: ${sha1.algorithm}")
    println("块大小: ${sha1.blockSize}")
    println("摘要长度: ${sha1.size}")

    return 0
}
```

运行结果：

```text
SHA1对象创建成功
算法: SHA1
块大小: 64
摘要长度: 20
```

### func finish()

```cangjie
public func finish(): Array<Byte>
```

功能：返回生成的 [SHA1](digest_package_classes.md#class-sha1) 值，注意调用 finish 后 [SHA1](digest_package_classes.md#class-sha1) 上下文会发生改变，finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

返回值：

- Array\<Byte> - 生成的 [SHA1](digest_package_classes.md#class-sha1) 字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha1 = SHA1()
    let data = "Hello, World!".toArray()

    sha1.write(data)

    let result = sha1.finish()
    let hexResult = toHexString(result)
    println("SHA1摘要: ${hexResult}")

    return 0
}
```

运行结果：

```text
SHA1摘要: 0a0a9f2a6772942557ab5355d76af442f8f65e01
```

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

功能：获取生成的信息摘要值，注意调用 finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

参数：

- to!: Array\<Byte> - 目标数组。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算或者指定输出数组大小不等于摘要算法信息长度，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha1 = SHA1()
    let data = "Hello, World!".toArray()

    sha1.write(data)

    var output = Array<Byte>(sha1.size, repeat: 0)
    sha1.finish(to: output)
    let hexOutput = toHexString(output)
    println("输出摘要: ${hexOutput}")

    return 0
}
```

运行结果：

```text
输出摘要: 0a0a9f2a6772942557ab5355d76af442f8f65e01
```

### func reset()

```cangjie
public func reset(): Unit
```

功能：重置 [SHA1](digest_package_classes.md#class-sha1) 对象到初始状态，清理 [SHA1](digest_package_classes.md#class-sha1) 上下文。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha1 = SHA1()
    let data1 = "Hello".toArray()
    let data2 = "World".toArray()

    sha1.write(data1)
    let result1 = sha1.finish()
    let hexResult1 = toHexString(result1)
    println("第一次摘要: ${hexResult1}")

    sha1.reset() // 重置SHA1对象
    sha1.write(data2)
    let result2 = sha1.finish()
    let hexResult2 = toHexString(result2)
    println("重置后摘要: ${hexResult2}")

    return 0
}
```

运行结果：

```text
第一次摘要: f7ff9e8b7bb2e09b70935a5d785e0cc5d9d0abf0
重置后摘要: 70c07ec18ef89c5309bbb0937f3a6342411e1fdd
```

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

功能：使用给定的 buffer 更新 [SHA1](digest_package_classes.md#class-sha1) 对象，在调用 finish 前可以多次更新。

参数：

- buffer: Array\<Byte> - 输入字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 已经调用 finish 进行摘要计算后未重置上下文，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha1 = SHA1()
    let data1 = "Hello".toArray()
    let data2 = " ".toArray()
    let data3 = "World".toArray()

    sha1.write(data1) // 写入第一部分数据
    sha1.write(data2) // 写入第二部分数据
    sha1.write(data3) // 写入第三部分数据

    let result = sha1.finish()
    let hexResult = toHexString(result)
    println("SHA1摘要: ${hexResult}")

    return 0
}
```

运行结果：

```text
SHA1摘要: 0a4d55a8d778e5022fab701977c5d840bbc486d0
```

## class SHA224

```cangjie
public class SHA224 <: Digest {
    public init()
}
```

功能：提供 [SHA224](digest_package_classes.md#class-sha224) 算法的实现接口。使用示例见 [SHA224 算法示例](../digest_samples/sample_digest.md#sha224-算法示例)。

父类型：

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

功能：[SHA224](digest_package_classes.md#class-sha224) 摘要算法的算法名称。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha224 = SHA224()

    let algorithm = sha224.algorithm
    println("SHA224算法: ${algorithm}")

    return 0
}
```

运行结果：

```text
SHA224算法: SHA224
```

### prop blockSize

```cangjie
public prop blockSize: Int64
```

功能：[SHA224](digest_package_classes.md#class-sha224) 信息块长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha224 = SHA224()

    let blockSize = sha224.blockSize
    println("块大小: ${blockSize}")

    return 0
}
```

运行结果：

```text
块大小: 64
```

### prop size

```cangjie
public prop size: Int64
```

功能：[SHA224](digest_package_classes.md#class-sha224) 摘要信息长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha224 = SHA224()

    let size = sha224.size
    println("摘要长度: ${size}")

    return 0
}
```

运行结果：

```text
摘要长度: 28
```

### init()

```cangjie
public init()
```

功能：无参构造函数，创建 [SHA224](digest_package_classes.md#class-sha224) 对象。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha224 = SHA224()

    println("SHA224对象创建成功")
    println("算法: ${sha224.algorithm}")
    println("块大小: ${sha224.blockSize}")
    println("摘要长度: ${sha224.size}")

    return 0
}
```

运行结果：

```text
SHA224对象创建成功
算法: SHA224
块大小: 64
摘要长度: 28
```

### func finish()

```cangjie
public func finish(): Array<Byte>
```

功能：返回生成的 [SHA224](digest_package_classes.md#class-sha224) 值，注意调用 finish 后 [SHA224](digest_package_classes.md#class-sha224) 上下文会发生改变，finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

返回值：

- Array\<Byte> - 生成的 [SHA224](digest_package_classes.md#class-sha224) 字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha224 = SHA224()
    let data = "Hello, World!".toArray()

    sha224.write(data)

    let result = sha224.finish()
    let hexResult = toHexString(result)
    println("SHA224摘要: ${hexResult}")

    return 0
}
```

运行结果：

```text
SHA224摘要: 72a23dfa411ba6fde01dbfabf3b00a709c93ebf273dc29e2d8b261ff
```

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

功能：获取生成的信息摘要值，注意调用 finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

参数：

- to!: Array\<Byte> - 目标数组。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算或者指定输出数组大小不等于摘要算法信息长度，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha224 = SHA224()
    let data = "Hello, World!".toArray()

    sha224.write(data)

    var output = Array<Byte>(sha224.size, repeat: 0)
    sha224.finish(to: output)
    let hexOutput = toHexString(output)
    println("输出摘要: ${hexOutput}")

    return 0
}
```

运行结果：

```text
输出摘要: 72a23dfa411ba6fde01dbfabf3b00a709c93ebf273dc29e2d8b261ff
```

### func reset()

```cangjie
public func reset(): Unit
```

功能：重置 [SHA224](digest_package_classes.md#class-sha224) 对象到初始状态，清理 [SHA224](digest_package_classes.md#class-sha224) 上下文。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha224 = SHA224()
    let data1 = "Hello".toArray()
    let data2 = "World".toArray()

    sha224.write(data1)
    let result1 = sha224.finish()
    let hexResult1 = toHexString(result1)
    println("第一次摘要: ${hexResult1}")

    sha224.reset() // 重置SHA224对象
    sha224.write(data2)
    let result2 = sha224.finish()
    let hexResult2 = toHexString(result2)
    println("重置后摘要: ${hexResult2}")

    return 0
}
```

运行结果：

```text
第一次摘要: 4149da18aa8bfc2b1e382c6c26556d01a92c261b6436dad5e3be3fcc
重置后摘要: 12972632b6d3b6aa52bd6434552f08c1303d56b817119406466e9236
```

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

功能：使用给定的 buffer 更新 [SHA224](digest_package_classes.md#class-sha224) 对象，在调用 finish 前可以多次更新。

参数：

- buffer: Array\<Byte> - 输入字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 已经调用 finish 进行摘要计算后未重置上下文，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha224 = SHA224()
    let data1 = "Hello".toArray()
    let data2 = " ".toArray()
    let data3 = "World".toArray()

    sha224.write(data1) // 写入第一部分数据
    sha224.write(data2) // 写入第二部分数据
    sha224.write(data3) // 写入第三部分数据

    let result = sha224.finish()
    let hexResult = toHexString(result)
    println("SHA224摘要: ${hexResult}")

    return 0
}
```

运行结果：

```text
SHA224摘要: c4890faffdb0105d991a461e668e276685401b02eab1ef4372795047
```

## class SHA256

```cangjie
public class SHA256 <: Digest {
    public init()
}
```

功能：提供 [SHA256](digest_package_classes.md#class-sha256) 算法的实现接口。使用示例见 [SHA256 算法示例](../digest_samples/sample_digest.md#sha256-算法示例)。

父类型：

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

功能：[SHA256](digest_package_classes.md#class-sha256) 摘要算法的算法名称。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha256 = SHA256()

    let algorithm = sha256.algorithm
    println("SHA256算法: ${algorithm}")

    return 0
}
```

运行结果：

```text
SHA256算法: SHA256
```

### prop blockSize

```cangjie
public prop blockSize: Int64
```

功能：[SHA256](digest_package_classes.md#class-sha256) 信息块长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha256 = SHA256()

    let blockSize = sha256.blockSize
    println("块大小: ${blockSize}")

    return 0
}
```

运行结果：

```text
块大小: 64
```

### prop size

```cangjie
public prop size: Int64
```

功能：[SHA256](digest_package_classes.md#class-sha256) 摘要信息长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha256 = SHA256()

    let size = sha256.size
    println("摘要长度: ${size}")

    return 0
}
```

运行结果：

```text
摘要长度: 32
```

### init()

```cangjie
public init()
```

功能：无参构造函数，创建 [SHA256](digest_package_classes.md#class-sha256) 对象。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha256 = SHA256()

    println("SHA256对象创建成功")
    println("算法: ${sha256.algorithm}")
    println("块大小: ${sha256.blockSize}")
    println("摘要长度: ${sha256.size}")

    return 0
}
```

运行结果：

```text
SHA256对象创建成功
算法: SHA256
块大小: 64
摘要长度: 32
```

### func finish()

```cangjie
public func finish(): Array<Byte>
```

功能：返回生成的 [SHA256](digest_package_classes.md#class-sha256) 值，注意调用 finish 后 [SHA256](digest_package_classes.md#class-sha256) 上下文会发生改变，finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

返回值：

- Array\<Byte> - 生成的 [SHA256](digest_package_classes.md#class-sha256) 字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha256 = SHA256()
    let data = "Hello, World!".toArray()

    sha256.write(data)

    let result = sha256.finish()
    let hexResult = toHexString(result)
    println("SHA256摘要: ${hexResult}")

    return 0
}
```

运行结果：

```text
SHA256摘要: dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f
```

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

功能：获取生成的信息摘要值，注意调用 finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

参数：

- to!: Array\<Byte> - 目标数组。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算或者指定输出数组大小不等于摘要算法信息长度，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha256 = SHA256()
    let data = "Hello, World!".toArray()

    sha256.write(data)

    var output = Array<Byte>(sha256.size, repeat: 0)
    sha256.finish(to: output)
    let hexOutput = toHexString(output)
    println("输出摘要: ${hexOutput}")

    return 0
}
```

运行结果：

```text
输出摘要: dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f
```

### func reset()

```cangjie
public func reset(): Unit
```

功能：重置 [SHA256](digest_package_classes.md#class-sha256) 对象到初始状态，清理 [SHA256](digest_package_classes.md#class-sha256) 上下文。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha256 = SHA256()
    let data1 = "Hello".toArray()
    let data2 = "World".toArray()

    sha256.write(data1)
    let result1 = sha256.finish()
    let hexResult1 = toHexString(result1)
    println("第一次摘要: ${hexResult1}")

    sha256.reset() // 重置SHA256对象
    sha256.write(data2)
    let result2 = sha256.finish()
    let hexResult2 = toHexString(result2)
    println("重置后摘要: ${hexResult2}")

    return 0
}
```

运行结果：

```text
第一次摘要: 185f8db32271fe25f561a6fc938b2e264306ec304eda518007d1764826381969
重置后摘要: 78ae647dc5544d227130a0682a51e30bc7777fbb6d8a8f17007463a3ecd1d524
```

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

功能：使用给定的 buffer 更新 [SHA256](digest_package_classes.md#class-sha256) 对象，在调用 finish 前可以多次更新。

参数：

- buffer: Array\<Byte> - 输入字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 已经调用 finish 进行摘要计算后未重置上下文，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha256 = SHA256()
    let data1 = "Hello".toArray()
    let data2 = " ".toArray()
    let data3 = "World".toArray()

    sha256.write(data1) // 写入第一部分数据
    sha256.write(data2) // 写入第二部分数据
    sha256.write(data3) // 写入第三部分数据

    let result = sha256.finish()
    let hexResult = toHexString(result)
    println("SHA256摘要: ${hexResult}")

    return 0
}
```

运行结果：

```text
SHA256摘要: a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e
```

## class SHA384

```cangjie
public class SHA384 <: Digest {
    public init()
}
```

功能：提供 [SHA384](digest_package_classes.md#class-sha384) 算法的实现接口。使用示例见 [SHA384 算法示例](../digest_samples/sample_digest.md#sha384-算法示例)。

父类型：

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

功能：[SHA384](digest_package_classes.md#class-sha384) 摘要算法的算法名称。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha384 = SHA384()

    let algorithm = sha384.algorithm
    println("SHA384算法: ${algorithm}")

    return 0
}
```

运行结果：

```text
SHA384算法: SHA384
```

### prop blockSize

```cangjie
public prop blockSize: Int64
```

功能：[SHA384](digest_package_classes.md#class-sha384) 信息块长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha384 = SHA384()

    let blockSize = sha384.blockSize
    println("块大小: ${blockSize}")

    return 0
}
```

运行结果：

```text
块大小: 128
```

### prop size

```cangjie
public prop size: Int64
```

功能：[SHA384](digest_package_classes.md#class-sha384) 摘要信息长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha384 = SHA384()

    let size = sha384.size
    println("摘要长度: ${size}")

    return 0
}
```

运行结果：

```text
摘要长度: 48
```

### init()

```cangjie
public init()
```

功能：无参构造函数，创建 [SHA384](digest_package_classes.md#class-sha384) 对象。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha384 = SHA384()

    println("SHA384对象创建成功")
    println("算法: ${sha384.algorithm}")
    println("块大小: ${sha384.blockSize}")
    println("摘要长度: ${sha384.size}")

    return 0
}
```

运行结果：

```text
SHA384对象创建成功
算法: SHA384
块大小: 128
摘要长度: 48
```

### func finish()

```cangjie
public func finish(): Array<Byte>
```

功能：返回生成的 [SHA384](digest_package_classes.md#class-sha384) 值，注意调用 finish 后 [SHA384](digest_package_classes.md#class-sha384) 上下文会发生改变，finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

返回值：

- Array\<Byte> - 生成的 [SHA384](digest_package_classes.md#class-sha384) 字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha384 = SHA384()
    let data = "Hello, World!".toArray()

    sha384.write(data)

    let result = sha384.finish()
    let hexResult = toHexString(result)
    println("SHA384摘要: ${hexResult}")

    return 0
}
```

运行结果：

```text
SHA384摘要: 5485cc9b3365b4305dfb4e8337e0a598a574f8242bf17289e0dd6c20a3cd44a089de16ab4ab308f63e44b1170eb5f515
```

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

功能：获取生成的信息摘要值，注意调用 finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

参数：

- to!: Array\<Byte> - 目标数组。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算或者指定输出数组大小不等于摘要算法信息长度，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha384 = SHA384()
    let data = "Hello, World!".toArray()

    sha384.write(data)

    var output = Array<Byte>(sha384.size, repeat: 0)
    sha384.finish(to: output)
    let hexOutput = toHexString(output)
    println("输出摘要: ${hexOutput}")

    return 0
}
```

运行结果：

```text
输出摘要: 5485cc9b3365b4305dfb4e8337e0a598a574f8242bf17289e0dd6c20a3cd44a089de16ab4ab308f63e44b1170eb5f515
```

### func reset()

```cangjie
public func reset(): Unit
```

功能：重置 [SHA384](digest_package_classes.md#class-sha384) 对象到初始状态，清理 [SHA384](digest_package_classes.md#class-sha384) 上下文。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha384 = SHA384()
    let data1 = "Hello".toArray()
    let data2 = "World".toArray()

    sha384.write(data1)
    let result1 = sha384.finish()
    let hexResult1 = toHexString(result1)
    println("第一次摘要: ${hexResult1}")

    sha384.reset() // 重置SHA384对象
    sha384.write(data2)
    let result2 = sha384.finish()
    let hexResult2 = toHexString(result2)
    println("重置后摘要: ${hexResult2}")

    return 0
}
```

运行结果：

```text
第一次摘要: 3519fe5ad2c596efe3e276a6f351b8fc0b03db861782490d45f7598ebd0ab5fd5520ed102f38c4a5ec834e98668035fc
重置后摘要: ed7ced84875773603af90402e42c65f3b48a5e77f84adc7a19e8f3e8d310101022f552aec70e9e1087b225930c1d260a
```

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

功能：使用给定的 buffer 更新 [SHA384](digest_package_classes.md#class-sha384) 对象，在调用 finish 前可以多次更新。

参数：

- buffer: Array\<Byte> - 输入字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 已经调用 finish 进行摘要计算后未重置上下文，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha384 = SHA384()
    let data1 = "Hello".toArray()
    let data2 = " ".toArray()
    let data3 = "World".toArray()

    sha384.write(data1) // 写入第一部分数据
    sha384.write(data2) // 写入第二部分数据
    sha384.write(data3) // 写入第三部分数据

    let result = sha384.finish()
    let hexResult = toHexString(result)
    println("SHA384摘要: ${hexResult}")

    return 0
}
```

运行结果：

```text
SHA384摘要: 99514329186b2f6ae4a1329e7ee6c610a729636335174ac6b740f9028396fcc803d0e93863a7c3d90f86beee782f4f3f
```

## class SHA512

```cangjie
public class SHA512 <: Digest {
    public init()
}
```

功能：提供 [SHA512](digest_package_classes.md#class-sha512) 算法的实现接口。使用示例见 [SHA512 算法示例](../digest_samples/sample_digest.md#sha512-算法示例)。

父类型：

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

功能：[SHA512](digest_package_classes.md#class-sha512) 摘要算法的算法名称。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha512 = SHA512()

    let algorithm = sha512.algorithm
    println("SHA512算法: ${algorithm}")

    return 0
}
```

运行结果：

```text
SHA512算法: SHA512
```

### prop blockSize

```cangjie
public prop blockSize: Int64
```

功能：[SHA512](digest_package_classes.md#class-sha512) 信息块长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha512 = SHA512()

    let blockSize = sha512.blockSize
    println("块大小: ${blockSize}")

    return 0
}
```

运行结果：

```text
块大小: 128
```

### prop size

```cangjie
public prop size: Int64
```

功能：[SHA512](digest_package_classes.md#class-sha512) 摘要信息长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha512 = SHA512()

    let size = sha512.size
    println("摘要长度: ${size}")

    return 0
}
```

运行结果：

```text
摘要长度: 64
```

### init()

```cangjie
public init()
```

功能：无参构造函数，创建 [SHA512](digest_package_classes.md#class-sha512) 对象。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha512 = SHA512()

    println("SHA512对象创建成功")
    println("算法: ${sha512.algorithm}")
    println("块大小: ${sha512.blockSize}")
    println("摘要长度: ${sha512.size}")

    return 0
}
```

运行结果：

```text
SHA512对象创建成功
算法: SHA512
块大小: 128
摘要长度: 64
```

### func finish()

```cangjie
public func finish(): Array<Byte>
```

功能：返回生成的 [SHA512](digest_package_classes.md#class-sha512) 值，注意调用 finish 后 [SHA512](digest_package_classes.md#class-sha512) 上下文会发生改变，finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

返回值：

- Array\<Byte> - 生成的 [SHA512](digest_package_classes.md#class-sha512) 字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha512 = SHA512()
    let data = "Hello, World!".toArray()

    sha512.write(data)

    let result = sha512.finish()
    let hexResult = toHexString(result)
    println("SHA512摘要: ${hexResult}")

    return 0
}
```

运行结果：

```text
SHA512摘要: 374d794a95cdcfd8b35993185fef9ba368f160d8daf432d08ba9f1ed1e5abe6cc69291e0fa2fe0006a52570ef18c19def4e617c33ce52ef0a6e5fbe318cb0387
```

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

功能：获取生成的信息摘要值，注意调用 finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

参数：

- to!: Array\<Byte> - 目标数组。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算或者指定输出数组大小不等于摘要算法信息长度，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha512 = SHA512()
    let data = "Hello, World!".toArray()

    sha512.write(data)

    var output = Array<Byte>(sha512.size, repeat: 0)
    sha512.finish(to: output)
    let hexOutput = toHexString(output)
    println("输出摘要: ${hexOutput}")

    return 0
}
```

运行结果：

```text
输出摘要: 374d794a95cdcfd8b35993185fef9ba368f160d8daf432d08ba9f1ed1e5abe6cc69291e0fa2fe0006a52570ef18c19def4e617c33ce52ef0a6e5fbe318cb0387
```

### func reset()

```cangjie
public func reset(): Unit
```

功能：重置 [SHA512](digest_package_classes.md#class-sha512) 对象到初始状态，清理 [SHA512](digest_package_classes.md#class-sha512) 上下文。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha512 = SHA512()
    let data1 = "Hello".toArray()
    let data2 = "World".toArray()

    sha512.write(data1)
    let result1 = sha512.finish()
    let hexResult1 = toHexString(result1)
    println("第一次摘要: ${hexResult1}")

    sha512.reset() // 重置SHA512对象
    sha512.write(data2)
    let result2 = sha512.finish()
    let hexResult2 = toHexString(result2)
    println("重置后摘要: ${hexResult2}")

    return 0
}
```

运行结果：

```text
第一次摘要: 3615f80c9d293ed7402687f94b22d58e529b8cc7916f8fac7fddf7fbd5af4cf777d3d795a7a00a16bf7e7f3fb9561ee9baae480da9fe7a18769e71886b03f315
重置后摘要: 8ea77393a42ab8fa92500fb077a9509cc32bc95e72712efa116edaf2edfae34fbb682efdd6c5dd13c117e08bd4aaef71291d8aace2f890273081d0677c16df0f
```

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

功能：使用给定的 buffer 更新 [SHA512](digest_package_classes.md#class-sha512) 对象，在调用 finish 前可以多次更新。

参数：

- buffer: Array\<Byte> - 输入字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 已经调用 finish 进行摘要计算后未重置上下文，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sha512 = SHA512()
    let data1 = "Hello".toArray()
    let data2 = " ".toArray()
    let data3 = "World".toArray()

    sha512.write(data1) // 写入第一部分数据
    sha512.write(data2) // 写入第二部分数据
    sha512.write(data3) // 写入第三部分数据

    let result = sha512.finish()
    let hexResult = toHexString(result)
    println("SHA512摘要: ${hexResult}")

    return 0
}
```

运行结果：

```text
SHA512摘要: 2c74fd17edafd80e8447b0d46741ee243b7eb74dd2149a0ab1b9246fb30382f27e853d8585719e0e67cbda0daa8f51671064615d645ae27acb15bfb1447f459b
```

## class SM3

```cangjie
public class SM3 <: Digest {
    public init()
}
```

功能：提供 [SM3](digest_package_classes.md#class-sm3) 算法的实现接口。使用示例见 [SM3 算法示例](../digest_samples/sample_digest.md#sm3-算法示例)。

父类型：

- Digest

### prop algorithm

```cangjie
public prop algorithm: String
```

功能：[SM3](digest_package_classes.md#class-sm3) 摘要算法的算法名称。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sm3 = SM3()

    let algorithm = sm3.algorithm
    println("SM3算法: ${algorithm}")

    return 0
}
```

运行结果：

```text
SM3算法: SM3
```

### prop blockSize

```cangjie
public prop blockSize: Int64
```

功能：[SM3](digest_package_classes.md#class-sm3) 信息块长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sm3 = SM3()

    let blockSize = sm3.blockSize
    println("块大小: ${blockSize}")

    return 0
}
```

运行结果：

```text
块大小: 64
```

### prop size

```cangjie
public prop size: Int64
```

功能：[SM3](digest_package_classes.md#class-sm3) 摘要信息长度，单位字节。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sm3 = SM3()

    let size = sm3.size
    println("摘要长度: ${size}")

    return 0
}
```

运行结果：

```text
摘要长度: 32
```

### init()

```cangjie
public init()
```

功能：无参构造函数，创建 [SM3](digest_package_classes.md#class-sm3) 对象。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sm3 = SM3()

    println("SM3对象创建成功")
    println("算法: ${sm3.algorithm}")
    println("块大小: ${sm3.blockSize}")
    println("摘要长度: ${sm3.size}")

    return 0
}
```

运行结果：

```text
SM3对象创建成功
算法: SM3
块大小: 64
摘要长度: 32
```

### func finish()

```cangjie
public func finish(): Array<Byte>
```

功能：返回生成的 [SM3](digest_package_classes.md#class-sm3) 值，注意调用 finish 后 [SM3](digest_package_classes.md#class-sm3) 上下文会发生改变，finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

返回值：

- Array\<Byte> - 生成的 [SM3](digest_package_classes.md#class-sm3) 字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sm3 = SM3()
    let data = "Hello, World!".toArray()

    sm3.write(data)

    let result = sm3.finish()
    let hexResult = toHexString(result)
    println("SM3摘要: ${hexResult}")

    return 0
}
```

运行结果：

```text
SM3摘要: 7ed26cbf0bee4ca7d55c1e64714c4aa7d1f163089ef5ceb603cd102c81fbcbc5
```

### func finish(Array\<Byte>)

```cangjie
public func finish(to!: Array<Byte>): Unit
```

功能：获取生成的信息摘要值，注意调用 finish 后不可以再进行摘要计算，如重新计算需要 reset 重置上下文。

参数：

- to!: Array\<Byte> - 目标数组。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 未重置上下文再次调用 finish 进行摘要计算或者指定输出数组大小不等于摘要算法信息长度，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sm3 = SM3()
    let data = "Hello, World!".toArray()

    sm3.write(data)

    var output = Array<Byte>(sm3.size, repeat: 0)
    sm3.finish(to: output)
    let hexOutput = toHexString(output)
    println("输出摘要: ${hexOutput}")

    return 0
}
```

运行结果：

```text
输出摘要: 7ed26cbf0bee4ca7d55c1e64714c4aa7d1f163089ef5ceb603cd102c81fbcbc5
```

### func reset()

```cangjie
public func reset(): Unit
```

功能：重置 [SM3](digest_package_classes.md#class-sm3) 对象到初始状态，清理 [SM3](digest_package_classes.md#class-sm3) 上下文。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sm3 = SM3()
    let data1 = "Hello".toArray()
    let data2 = "World".toArray()

    sm3.write(data1)
    let result1 = sm3.finish()
    let hexResult1 = toHexString(result1)
    println("第一次摘要: ${hexResult1}")

    sm3.reset() // 重置SM3对象
    sm3.write(data2)
    let result2 = sm3.finish()
    let hexResult2 = toHexString(result2)
    println("重置后摘要: ${hexResult2}")

    return 0
}
```

运行结果：

```text
第一次摘要: dc74f051ad5bc19ba721bf0023e10de03bae29bbe013c43988bae55828bcebbc
重置后摘要: 5c54fe15f19a6b15bb0dcf4d1aef6b6c6439d95aacfea9e86bb7e6ba569b081a
```

### func write(Array\<Byte>)

```cangjie
public func write(buffer: Array<Byte>): Unit
```

功能：使用给定的 buffer 更新 [SM3](digest_package_classes.md#class-sm3) 对象，在调用 finish 前可以多次更新。

参数：

- buffer: Array\<Byte> - 输入字节序列。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 已经调用 finish 进行摘要计算后未重置上下文，抛此异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*
import stdx.encoding.hex.*

main() {
    let sm3 = SM3()
    let data1 = "Hello".toArray()
    let data2 = " ".toArray()
    let data3 = "World".toArray()

    sm3.write(data1) // 写入第一部分数据
    sm3.write(data2) // 写入第二部分数据
    sm3.write(data3) // 写入第三部分数据

    let result = sm3.finish()
    let hexResult = toHexString(result)
    println("SM3摘要: ${hexResult}")

    return 0
}
```

运行结果：

```text
SM3摘要: 77015816143ee627f4fa410b6dad2bdb9fcbdf1e061a452a686b8711a484c5d7
```
