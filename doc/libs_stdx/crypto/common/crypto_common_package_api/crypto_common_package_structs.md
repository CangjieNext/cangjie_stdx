# 结构体

## struct DerBlob

```cangjie
public struct DerBlob <: Equatable<DerBlob> & Hashable {
    public init(content: Array<Byte>)
}
```

功能：Crypto 支持配置二进制证书流，用户读取二进制证书数据并创建 [DerBlob](#struct-derblob) 对象后可将其解析成 [X509Certificate](../../x509/x509_package_api/x509_package_classes.md#class-x509certificate) / [X509CertificateRequest](../../x509/x509_package_api/x509_package_classes.md#class-x509certificaterequest) / [PublicKey](./crypto_common_package_interfaces.md#interface-publickey) / [PrivateKey](./crypto_common_package_interfaces.md#interface-privatekey) 对象。

父类型：

- Equatable\<[DerBlob](#struct-derblob)>
- Hashable

### prop body

```cangjie
public prop body: Array<Byte>
```

功能：[DerBlob](#struct-derblob) 对象中的字符序列。

类型：Array\<Byte>

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 DerBlob 对象（仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let content = "Hello, DerBlob!".toArray()
    let derBlob = DerBlob(content)

    // 访问 body 属性
    let body = derBlob.body
    println("DerBlob body UTF-8: ${String.fromUtf8(body)}")
    println("DerBlob body: ${body}")
}
```

运行结果：

```text
DerBlob body UTF-8: Hello, DerBlob!
DerBlob body: [72, 101, 108, 108, 111, 44, 32, 68, 101, 114, 66, 108, 111, 98, 33]
```

### prop size

```cangjie
public prop size: Int64
```

功能：[DerBlob](#struct-derblob) 对象中字符序列的大小。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 DerBlob 对象（仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let content = "Hello, DerBlob!".toArray()
    let derBlob = DerBlob(content)

    // 访问 size 属性
    let size = derBlob.size
    println("DerBlob size: ${size}")
}
```

运行结果：

```text
DerBlob size: 15
```

### init(Array\<Byte>)

```cangjie
public init(content: Array<Byte>)
```

功能：构造 [DerBlob](#struct-derblob) 对象。

参数：

- content: Array\<Byte> - 二进制字符序列。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 DerBlob 对象（仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let content = "Hello, DerBlob!".toArray()
    let derBlob = DerBlob(content)

    println("DerBlob对象创建成功")
}
```

运行结果：

```text
DerBlob对象创建成功
```

### func hashCode()

```cangjie
public override func hashCode(): Int64
```

功能：返回 [DerBlob](#struct-derblob) 对象哈希值。

返回值：

- Int64 - 对 [DerBlob](#struct-derblob) 对象进行哈希计算后得到的结果。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 DerBlob 对象（仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let content = "Hello, DerBlob!".toArray()
    let derBlob = DerBlob(content)

    // 获取哈希值
    let hashCode = derBlob.hashCode()
    println("DerBlob hashCode: ${hashCode}")
}
```

运行结果：

```text
DerBlob hashCode: -1740040550816916903
```

### operator func !=(DerBlob)

```cangjie
public override operator func !=(other: DerBlob): Bool
```

功能：判不等。

参数：

- other: [DerBlob](#struct-derblob) - 被比较的 [DerBlob](#struct-derblob) 对象。

返回值：

- Bool - 若对象不同，返回 true；否则，返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建两个不同的 DerBlob 对象（仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let content1 = "Hello, DerBlob1!".toArray()
    let content2 = "Hello, DerBlob2!".toArray()
    let derBlob1 = DerBlob(content1)
    let derBlob2 = DerBlob(content2)

    // 测试不等操作符
    let notEqual = derBlob1 != derBlob2
    println("DerBlob1 != DerBlob2: ${notEqual}")

    // 测试相同对象
    let derBlob3 = DerBlob(content1)
    let notEqual2 = derBlob1 != derBlob3
    println("DerBlob1 != DerBlob3: ${notEqual2}")
}
```

运行结果：

```text
DerBlob1 != DerBlob2: true
DerBlob1 != DerBlob3: false
```

### operator func ==(DerBlob)

```cangjie
public override operator func ==(other: DerBlob): Bool
```

功能：判等。

参数：

- other: [DerBlob](#struct-derblob) - 被比较的 [DerBlob](#struct-derblob) 对象。

返回值：

- Bool - 若对象相同，返回 true；否则，返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建两个相同的 DerBlob 对象（仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let content1 = "Hello, DerBlob!".toArray()
    let content2 = "Hello, DerBlob!".toArray()
    let derBlob1 = DerBlob(content1)
    let derBlob2 = DerBlob(content2)

    // 测试相等操作符
    let equal = derBlob1 == derBlob2
    println("DerBlob1 == DerBlob2: ${equal}")

    // 测试不同对象
    let derBlob3 = DerBlob("Hello, DerBlob3!".toArray())
    let equal2 = derBlob1 == derBlob3
    println("DerBlob1 == DerBlob3: ${equal2}")
}
```

运行结果：

```text
DerBlob1 == DerBlob2: true
DerBlob1 == DerBlob3: false
```

## struct Pem

```cangjie
public struct Pem <: Collection<PemEntry> & ToString {
    public Pem(private let items: Array<PemEntry>)
}
```

功能：结构体 [Pem](#struct-pem) 为条目序列，可以包含多个 [PemEntry](#struct-pementry)。

父类型：

- Collection\<[PemEntry](#struct-pementry)>
- ToString

### Pem(Array\<PemEntry>)

```cangjie
public Pem(private let items: Array<PemEntry>)
```

功能：构造 [Pem](#struct-pem) 对象。

参数：

- items: Array\<[PemEntry](#struct-pementry)> - 多个 [PemEntry](#struct-pementry) 对象。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 PemEntry 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob = DerBlob("Hello, PEM!".toArray())
    let pemEntry = PemEntry(PemEntry.LABEL_CERTIFICATE, [("HeaderKey", "HeaderValue")], derBlob)

    // 创建 Pem 对象
    let pem = Pem([pemEntry])

    println("Pem对象创建成功")
}
```

运行结果：

```text
Pem对象创建成功
```

### prop size

```cangjie
public override prop size: Int64
```

功能：条目序列的数量。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 PemEntry 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob = DerBlob("Hello, PEM!".toArray())
    let pemEntry = PemEntry(PemEntry.LABEL_CERTIFICATE, [("HeaderKey", "HeaderValue")], derBlob)

    // 创建 Pem 对象
    let pem = Pem([pemEntry])

    // 访问 size 属性
    println("Pem对象大小: ${pem.size}")
}
```

运行结果：

```text
Pem对象大小: 1
```

### static func decode(String)

```cangjie
public static func decode(text: String): Pem
```

功能：将 PEM 文本解码为条目序列。

参数：

- text: String - PEM 字符串。

返回值：

- [Pem](#struct-pem) - PEM 条目序列。

异常：

- [X509Exception](./../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - 数据为空时，或解码失败抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 PemEntry 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob = DerBlob("Hello, PEM!".toArray())
    let pemEntry = PemEntry(PemEntry.LABEL_CERTIFICATE, [("HeaderKey", "HeaderValue")], derBlob)

    // 创建 Pem 对象
    let pem = Pem([pemEntry])

    // 编码为 PEM 格式
    let encoded = pem.encode()
    println("编码后的PEM字符串: \n${encoded}")

    println("解码PEM字符串，获得Pem对象")
    let decoded = Pem.decode(encoded)
    println("解码后的Pem对象大小: ${decoded.size}")
}
```

运行结果：

```text
编码后的PEM字符串: 
-----BEGIN CERTIFICATE-----
HeaderKey: HeaderValue

SGVsbG8sIFBFTSE=
-----END CERTIFICATE-----

解码PEM字符串，获得Pem对象
解码后的Pem对象大小: 1
```

### func encode()

```cangjie
public func encode(): String
```

功能：返回 PEM 格式的字符串。行结束符将根据当前操作系统生成。

返回值：

- String - PEM 格式的字符串。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 PemEntry 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob = DerBlob("Hello, PEM!".toArray())
    let pemEntry = PemEntry(PemEntry.LABEL_CERTIFICATE, [("HeaderKey", "HeaderValue")], derBlob)

    // 创建 Pem 对象
    let pem = Pem([pemEntry])

    // 编码为 PEM 格式
    let encoded = pem.encode()
    println("编码后的PEM字符串: \n${encoded}")
}
```

运行结果：

```text
编码后的PEM字符串: 
-----BEGIN CERTIFICATE-----
HeaderKey: HeaderValue

SGVsbG8sIFBFTSE=
-----END CERTIFICATE-----

```

### func isEmpty()

```cangjie
public override func isEmpty(): Bool
```

功能：判断 PEM 文本解码为条目序列是否为空。

返回值：

- Bool - PEM 文本解码为条目序列为空返回 true；否则，返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 PemEntry 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob = DerBlob("Hello, PEM!".toArray())
    let pemEntry = PemEntry(PemEntry.LABEL_CERTIFICATE, [("HeaderKey", "HeaderValue")], derBlob)

    // 创建 Pem 对象
    let pem = Pem([pemEntry])

    // 检查是否为空
    println("Pem对象是否为空: ${pem.isEmpty()}")

    // 创建 Pem 对象
    let pemEmpty = Pem([])
    // 检查是否为空
    println("Pem对象是否为空: ${pemEmpty.isEmpty()}")
}
```

运行结果：

```text
Pem对象是否为空: false
Pem对象是否为空: true
```

### func iterator()

```cangjie
public override func iterator(): Iterator<PemEntry>
```

功能：生成 PEM 文本解码为条目序列的迭代器。

返回值：

- Iterator\<[PemEntry](#struct-pementry)> - PEM 文本解码为条目序列的迭代器。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 PemEntry 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob01 = DerBlob("Hello, PEM01!".toArray())
    let pemEntry01 = PemEntry("CERTIFICATE01", [("HeaderKey01", "HeaderValue01"), ("HeaderKey02", "HeaderValue02")],
        derBlob01)

    // 创建另一个 PemEntry 对象
    let derBlob02 = DerBlob("Hello!!, PEM02!".toArray())
    let pemEntry02 = PemEntry("CERTIFICATE02", [("HeaderKey03", "HeaderValue03"), ("HeaderKey04", "HeaderValue04")],
        derBlob02)

    // 创建 Pem 对象
    let pem = Pem([pemEntry01, pemEntry02])

    // 获取迭代器
    let iter = pem.iterator()
    for (entry in iter) {
        println("PemEntry: ${entry}")
        println("PemEntry.headers: ")
        for (header in entry.headers) {
            println("  ${header[0]}: ${header[1]}")
        }
        println("PemEntry.body: ${entry.body?.body ?? []}")
    }
    println("Pem迭代器获取成功")
}
```

运行结果：

```text
PemEntry: PEM CERTIFICATE01 (13 bytes)
PemEntry.headers: 
  HeaderKey01: HeaderValue01
  HeaderKey02: HeaderValue02
PemEntry.body: [72, 101, 108, 108, 111, 44, 32, 80, 69, 77, 48, 49, 33]
PemEntry: PEM CERTIFICATE02 (15 bytes)
PemEntry.headers: 
  HeaderKey03: HeaderValue03
  HeaderKey04: HeaderValue04
PemEntry.body: [72, 101, 108, 108, 111, 33, 33, 44, 32, 80, 69, 77, 48, 50, 33]
Pem迭代器获取成功
```

### func toString()

```cangjie
public override func toString(): String
```

功能：返回一个字符串，字符串内容是包含每个条目序列的标签。

返回值：

- String - 包含每个条目序列的标签的字符串。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 PemEntry 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob = DerBlob("Hello, PEM!".toArray())
    let pemEntry = PemEntry(PemEntry.LABEL_CERTIFICATE, [("HeaderKey", "HeaderValue")], derBlob)

    // 创建 Pem 对象
    let pem = Pem([pemEntry])

    // 转换为字符串
    let str = pem.toString()
    println("Pem对象字符串表示: ${str}")
}
```

运行结果：

```text
Pem对象字符串表示: CERTIFICATE
```

## struct PemEntry

```cangjie
public struct PemEntry <: ToString {
    public static let LABEL_CERTIFICATE = "CERTIFICATE"
    public static let LABEL_X509_CRL = "X509 CRL"
    public static let LABEL_CERTIFICATE_REQUEST = "CERTIFICATE REQUEST"
    public static let LABEL_PRIVATE_KEY = "PRIVATE KEY"
    public static let LABEL_EC_PRIVATE_KEY = "EC PRIVATE KEY"
    public static let LABEL_ENCRYPTED_PRIVATE_KEY = "ENCRYPTED PRIVATE KEY"
    public static let LABEL_RSA_PRIVATE_KEY = "RSA PRIVATE KEY"
    public static let LABEL_SM2_PRIVATE_KEY = "SM2 PRIVATE KEY"
    public static let LABEL_PUBLIC_KEY = "PUBLIC KEY"
    public static let LABEL_EC_PARAMETERS = "EC PARAMETERS"
    public static let LABEL_DH_PARAMETERS = "DH PARAMETERS"
    public PemEntry(
        public let label: String,
        public let headers: Array<(String, String)>,
        public let body: ?DerBlob
    )
    public init(label: String, body: DerBlob)
}
```

功能：PEM 文本格式经常用于存储证书和密钥，PEM 编码结构包含以下几个部分：

第一行是 “-----BEGIN”，标签和 “-----” 组成的 utf8 编码的字符串；
中间是正文，是实际二进制内容经过 base64 编码得到的可打印字符串，详细的 PEM 编码规范可参考 [RFC 7468](https://www.rfc-editor.org/rfc/rfc7468.html)；
最后一行是 “-----END”，标签和 “-----” 组成的 utf8 编码的字符串，详见 [RFC 1421](https://www.rfc-editor.org/rfc/rfc1421.html)。
在旧版的 PEM 编码标准中在第一行和正文之间还包含条目头。

为了支持不同的用户场景，我们提供了 [PemEntry](#struct-pementry) 和 [Pem](#struct-pem) 类型，[PemEntry](#struct-pementry) 用于存储单个 PEM 基础结构。

父类型：

- ToString

### PemEntry(String, Array\<(String, String)>, ?DerBlob)

```cangjie
public PemEntry(
    public let label: String,
    public let headers: Array<(String, String)>,
    public let body: ?DerBlob
)
```

功能：构造 [PemEntry](#struct-pementry) 对象。

参数：

- label: String - 标签。
- headers: Array\<(String, String)> - 条目头。
- body: ?[DerBlob](#struct-derblob) - 二进制内容。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 DerBlob 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob = DerBlob("Hello, PEM Entry!".toArray())

    // 创建一个 PemEntry 对象
    let pemEntry = PemEntry(PemEntry.LABEL_CERTIFICATE, [("HeaderKey", "HeaderValue")], derBlob)

    println("PemEntry对象创建成功")
}
```

运行结果：

```text
PemEntry对象创建成功
```

### static let LABEL_CERTIFICATE

```cangjie
public static let LABEL_CERTIFICATE: String = "CERTIFICATE"
```

功能：记录条目类型为证书。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 使用预定义的标签常量
    let label = PemEntry.LABEL_CERTIFICATE
    println("证书标签: ${label}")
}
```

运行结果：

```text
证书标签: CERTIFICATE
```

### static let LABEL_CERTIFICATE_REQUEST

```cangjie
public static let LABEL_CERTIFICATE_REQUEST: String = "CERTIFICATE REQUEST"
```

功能：记录条目类型为证书签名请求。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 使用预定义的标签常量
    let label = PemEntry.LABEL_CERTIFICATE_REQUEST
    println("证书请求标签: ${label}")
}
```

运行结果：

```text
证书请求标签: CERTIFICATE REQUEST
```

### static let LABEL_DH_PARAMETERS

```cangjie
public static let LABEL_DH_PARAMETERS: String = "DH PARAMETERS"
```

功能：记录条目类型为 DH 密钥参数。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 使用预定义的标签常量
    let label = PemEntry.LABEL_DH_PARAMETERS
    println("DH参数标签: ${label}")
}
```

运行结果：

```text
DH参数标签: DH PARAMETERS
```

### static let LABEL_EC_PARAMETERS

```cangjie
public static let LABEL_EC_PARAMETERS: String = "EC PARAMETERS"
```

功能：记录条目类型为椭圆曲线参数。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 使用预定义的标签常量
    let label = PemEntry.LABEL_EC_PARAMETERS
    println("椭圆曲线参数标签: ${label}")
}
```

运行结果：

```text
椭圆曲线参数标签: EC PARAMETERS
```

### static let LABEL_EC_PRIVATE_KEY

```cangjie
public static let LABEL_EC_PRIVATE_KEY: String = "EC PRIVATE KEY"
```

功能：记录条目类型为椭圆曲线私钥。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 使用预定义的标签常量
    let label = PemEntry.LABEL_EC_PRIVATE_KEY
    println("椭圆曲线私钥标签: ${label}")
}
```

运行结果：

```text
椭圆曲线私钥标签: EC PRIVATE KEY
```

### static let LABEL_ENCRYPTED_PRIVATE_KEY

```cangjie
public static let LABEL_ENCRYPTED_PRIVATE_KEY: String = "ENCRYPTED PRIVATE KEY"
```

功能：记录条目类型为 PKCS #8 标准加密的私钥。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 使用预定义的标签常量
    let label = PemEntry.LABEL_ENCRYPTED_PRIVATE_KEY
    println("加密私钥标签: ${label}")
}
```

运行结果：

```text
加密私钥标签: ENCRYPTED PRIVATE KEY
```

### static let LABEL_PRIVATE_KEY

```cangjie
public static let LABEL_PRIVATE_KEY: String = "PRIVATE KEY"
```

功能：记录条目类型为 PKCS #8 标准未加密的私钥。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 使用预定义的标签常量
    let label = PemEntry.LABEL_PRIVATE_KEY
    println("私钥标签: ${label}")
}
```

运行结果：

```text
私钥标签: PRIVATE KEY
```

### static let LABEL_PUBLIC_KEY

```cangjie
public static let LABEL_PUBLIC_KEY: String = "PUBLIC KEY"
```

功能：记录条目类型为公钥。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 使用预定义的标签常量
    let label = PemEntry.LABEL_PUBLIC_KEY
    println("公钥标签: ${label}")
}
```

运行结果：

```text
公钥标签: PUBLIC KEY
```

### static let LABEL_RSA_PRIVATE_KEY

```cangjie
public static let LABEL_RSA_PRIVATE_KEY: String = "RSA PRIVATE KEY"
```

功能：记录条目类型为 RSA 私钥。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 使用预定义的标签常量
    let label = PemEntry.LABEL_RSA_PRIVATE_KEY
    println("RSA私钥标签: ${label}")
}
```

运行结果：

```text
RSA私钥标签: RSA PRIVATE KEY
```

### static let LABEL_SM2_PRIVATE_KEY

```cangjie
public static let LABEL_SM2_PRIVATE_KEY: String = "SM2 PRIVATE KEY"
```

功能：记录条目类型为 SM2 私钥。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 使用预定义的标签常量
    let label = PemEntry.LABEL_SM2_PRIVATE_KEY
    println("SM2私钥标签: ${label}")
}
```

运行结果：

```text
SM2私钥标签: SM2 PRIVATE KEY
```

### static let LABEL_X509_CRL

```cangjie
public static let LABEL_X509_CRL: String = "X509 CRL"
```

功能：记录条目类型为证书吊销列表。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 使用预定义的标签常量
    let label = PemEntry.LABEL_X509_CRL
    println("证书吊销列表标签: ${label}")
}
```

运行结果：

```text
证书吊销列表标签: X509 CRL
```

### let body

```cangjie
public let body: ?DerBlob
```

功能：[PemEntry](#struct-pementry) 实例的二进制内容。

类型：?[DerBlob](#struct-derblob)

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 DerBlob 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob = DerBlob("Hello, PEM Entry!".toArray())

    // 创建一个 PemEntry 对象
    let pemEntry = PemEntry(PemEntry.LABEL_CERTIFICATE, derBlob)

    // 访问 body 属性
    match (pemEntry.body) {
        case Some(blob) => println("PemEntry包含二进制内容，大小: ${blob.size}")
        case None => println("PemEntry不包含二进制内容")
    }
}
```

运行结果：

```text
PemEntry包含二进制内容，大小: 17
```

### let headers

```cangjie
public let headers: Array<(String, String)>
```

功能：[PemEntry](#struct-pementry) 实例的条目头。

类型：Array\<(String, String)>

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 DerBlob 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob = DerBlob("Hello, PEM Entry!".toArray())

    // 创建一个 PemEntry 对象，包含头部信息
    let pemEntry = PemEntry(PemEntry.LABEL_CERTIFICATE, [("HeaderKey", "HeaderValue"), ("AnotherKey", "AnotherValue")],
        derBlob)

    // 访问 headers 属性
    println("PemEntry头部数量: ${pemEntry.headers.size}")

    // 遍历头部
    for (header in pemEntry.headers) {
        println("头部: ${header[0]} = ${header[1]}")
    }
}
```

运行结果：

```text
PemEntry头部数量: 2
头部: HeaderKey = HeaderValue
头部: AnotherKey = AnotherValue
```

### let label

```cangjie
public let label: String
```

功能：[PemEntry](#struct-pementry) 实例的标签。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 DerBlob 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob = DerBlob("Hello, PEM Entry!".toArray())

    // 创建一个 PemEntry 对象
    let pemEntry = PemEntry(PemEntry.LABEL_CERTIFICATE, derBlob)

    // 访问 label 属性
    println("PemEntry标签: ${pemEntry.label}")
}
```

运行结果：

```text
PemEntry标签: CERTIFICATE
```

### init(String, DerBlob)

```cangjie
public init(label: String, body: DerBlob)
```

功能：构造 [PemEntry](#struct-pementry) 对象。

参数：

- label: String - 标签
- body: [DerBlob](#struct-derblob) - 二进制内容

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 DerBlob 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob = DerBlob("Hello, PEM Entry!".toArray())

    // 创建一个 PemEntry 对象（使用简化构造函数）
    let pemEntry = PemEntry(PemEntry.LABEL_CERTIFICATE, derBlob)

    println("PemEntry对象创建成功")
}
```

运行结果：

```text
PemEntry对象创建成功
```

### func encode()

```cangjie
public func encode(): String
```

功能：返回 PEM 格式的字符串。行结束符将根据当前操作系统生成。

返回值：

- String - PEM 格式的字符串。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 DerBlob 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob = DerBlob("Hello, PEM Entry!".toArray())

    // 创建一个 PemEntry 对象
    let pemEntry = PemEntry(PemEntry.LABEL_CERTIFICATE, derBlob)

    // 编码为 PEM 格式
    let encoded = pemEntry.encode()
    println("编码后字符串长度: ${encoded.size}")
    print("编码后字符串: \n${encoded}")
}
```

运行结果：

```text
编码后字符串长度: 79
编码后字符串: 
-----BEGIN CERTIFICATE-----
SGVsbG8sIFBFTSBFbnRyeSE=
-----END CERTIFICATE-----
```

### func header(String)

```cangjie
public func header(name: String): Iterator<String>
```

功能：通过条目头名称，找到对应条目内容。

参数：

- name: String - 条目头名称。

返回值：

- Iterator\<String> - 条目头名称对应内容的迭代器。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 DerBlob 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob = DerBlob("Hello, PEM Entry!".toArray())

    // 创建一个 PemEntry 对象，包含头部信息
    let pemEntry = PemEntry(PemEntry.LABEL_CERTIFICATE, [("HeaderKey", "HeaderValue"), ("HeaderKey", "AnotherValue")],
        derBlob)

    // 获取特定头部
    let headerValueIter = pemEntry.header("HeaderKey")
    println("头部键迭代器获取成功")
    for (HeaderValue in headerValueIter) {
        println("头部键: ${HeaderValue}")
    }
}
```

运行结果：

```text
头部键迭代器获取成功
头部键: HeaderValue
头部键: AnotherValue
```

### func toString()

```cangjie
public override func toString(): String
```

功能：返回 PEM 对象的标签和二进制内容的长度。

返回值：

- String - PEM 对象的标签和二进制内容的长度。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    // 创建一个 DerBlob 对象（DerBlob 仅演示二进制容器能力，数据无 ASN.1/DER 加密规范格式）
    let derBlob = DerBlob("Hello, PEM Entry!".toArray())

    // 创建一个 PemEntry 对象
    let pemEntry = PemEntry(PemEntry.LABEL_CERTIFICATE, derBlob)

    // 转换为字符串
    let str = pemEntry.toString()
    println("PemEntry字符串表示: ${str}")
}
```

运行结果：

```text
PemEntry字符串表示: PEM CERTIFICATE (17 bytes)
```
