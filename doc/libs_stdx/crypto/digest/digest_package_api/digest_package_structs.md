# 结构体

## struct HashType

```cangjie
public struct HashType <: ToString & Equatable<HashType>
```

功能：此类为 Hash 算法类别结构体，[MD5](digest_package_classes.md#class-md5)、[SHA1](digest_package_classes.md#class-sha1)、[SHA224](digest_package_classes.md#class-sha224)、[SHA256](digest_package_classes.md#class-sha256)、[SHA384](digest_package_classes.md#class-sha384)、[SHA512](digest_package_classes.md#class-sha512) 均为常用摘要算法。

父类型：

- ToString
- Equatable\<[HashType](#struct-hashtype)>

### prop MD5

```cangjie
public static prop MD5: HashType
```

功能：返回 [MD5](digest_package_classes.md#class-md5) 类型。

类型：[HashType](digest_package_structs.md#struct-hashtype)

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let md5Type = HashType.MD5
    println("MD5类型: ${md5Type}")

    return 0
}
```

运行结果：

```text
MD5类型: MD5
```

### prop SHA1

```cangjie
public static prop SHA1: HashType
```

功能：返回 [SHA1](digest_package_classes.md#class-sha1) 类型。

类型：[HashType](digest_package_structs.md#struct-hashtype)

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha1Type = HashType.SHA1
    println("SHA1类型: ${sha1Type}")

    return 0
}
```

运行结果：

```text
SHA1类型: SHA1
```

### prop SHA224

```cangjie
public static prop SHA224: HashType
```

功能：返回 [SHA224](digest_package_classes.md#class-sha224) 类型。

类型：[HashType](digest_package_structs.md#struct-hashtype)

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha224Type = HashType.SHA224
    println("SHA224类型: ${sha224Type}")

    return 0
}
```

运行结果：

```text
SHA224类型: SHA224
```

### prop SHA256

```cangjie
public static prop SHA256: HashType
```

功能：返回 [SHA256](digest_package_classes.md#class-sha256) 类型。

类型：[HashType](digest_package_structs.md#struct-hashtype)

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha256Type = HashType.SHA256
    println("SHA256类型: ${sha256Type}")

    return 0
}
```

运行结果：

```text
SHA256类型: SHA256
```

### prop SHA384

```cangjie
public static prop SHA384: HashType
```

功能：返回 [SHA384](digest_package_classes.md#class-sha384) 类型。

类型：[HashType](digest_package_structs.md#struct-hashtype)

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha384Type = HashType.SHA384
    println("SHA384类型: ${sha384Type}")

    return 0
}
```

运行结果：

```text
SHA384类型: SHA384
```

### prop SHA512

```cangjie
public static prop SHA512: HashType
```

功能：返回 [SHA512](digest_package_classes.md#class-sha512) 类型。

类型：[HashType](digest_package_structs.md#struct-hashtype)

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sha512Type = HashType.SHA512
    println("SHA512类型: ${sha512Type}")

    return 0
}
```

运行结果：

```text
SHA512类型: SHA512
```

### prop SM3

```cangjie
public static prop SM3: HashType
```

功能：返回 [SM3](digest_package_classes.md#class-sm3) 类型。

类型：[HashType](digest_package_structs.md#struct-hashtype)

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let sm3Type = HashType.SM3
    println("SM3类型: ${sm3Type}")

    return 0
}
```

运行结果：

```text
SM3类型: SM3
```

### func toString()

```cangjie
public func toString(): String
```

功能：获取 Hash 算法名称。

返回值：

- String - Hash 算法名称。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let md5Type = HashType.MD5
    let sha1Type = HashType.SHA1

    let md5Name = md5Type.toString()
    let sha1Name = sha1Type.toString()

    println("MD5名称: ${md5Name}")
    println("SHA1名称: ${sha1Name}")

    return 0
}
```

运行结果：

```text
MD5名称: MD5
SHA1名称: SHA1
```

### operator func !=(HashType)

```cangjie
public override operator func !=(other: HashType): Bool
```

功能：判断两 [HashType](digest_package_structs.md#struct-hashtype) 是否引用不同实例。

参数：

- other: [HashType](digest_package_structs.md#struct-hashtype) - 对比的 HashType。

返回值：

- Bool - 不相同返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let md5Type = HashType.MD5
    let sha1Type = HashType.SHA1
    let anotherMd5Type = HashType.MD5

    let isNotEqual1 = md5Type != sha1Type
    let isNotEqual2 = md5Type != anotherMd5Type

    println("MD5 != SHA1: ${isNotEqual1}")
    println("MD5 != MD5: ${isNotEqual2}")

    return 0
}
```

运行结果：

```text
MD5 != SHA1: true
MD5 != MD5: false
```

### operator func ==(HashType)

```cangjie
public override operator func ==(other: HashType): Bool
```

功能：判断两 [HashType](digest_package_structs.md#struct-hashtype) 是否引用同一实例。

参数：

- other: [HashType](digest_package_structs.md#struct-hashtype) - 对比的 HashType。

返回值：

- Bool - 相同返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.digest.*

main() {
    let md5Type = HashType.MD5
    let sha1Type = HashType.SHA1
    let anotherMd5Type = HashType.MD5

    let isEqual1 = md5Type == sha1Type
    let isEqual2 = md5Type == anotherMd5Type

    println("MD5 == SHA1: ${isEqual1}")
    println("MD5 == MD5: ${isEqual2}")

    return 0
}
```

运行结果：

```text
MD5 == SHA1: false
MD5 == MD5: true
```
