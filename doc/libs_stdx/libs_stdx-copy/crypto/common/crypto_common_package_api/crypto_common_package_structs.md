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

### prop size

```cangjie
public prop size: Int64
```

功能：[DerBlob](#struct-derblob) 对象中字符序列的大小。

类型：Int64

### init(Array\<Byte>)

```cangjie
public init(content: Array<Byte>)
```

功能：构造 [DerBlob](#struct-derblob) 对象。

参数：

- content: Array\<Byte> - 二进制字符序列。

### func hashCode()

```cangjie
public override func hashCode(): Int64
```

功能：返回 [DerBlob](#struct-derblob) 对象哈希值。

返回值：

- Int64 - 对 [DerBlob](#struct-derblob) 对象进行哈希计算后得到的结果。

### operator func !=(DerBlob)

```cangjie
public override operator func !=(other: DerBlob): Bool
```

功能：判不等。

参数：

- other: [DerBlob](#struct-derblob) - 被比较的 [DerBlob](#struct-derblob) 对象。

返回值：

- Bool - 若对象不同，返回 true；否则，返回 false。

### operator func ==(DerBlob)

```cangjie
public override operator func ==(other: DerBlob): Bool
```

功能：判等。

参数：

- other: [DerBlob](#struct-derblob) - 被比较的 [DerBlob](#struct-derblob) 对象。

返回值：

- Bool - 若对象相同，返回 true；否则，返回 false。

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

### prop size

```cangjie
public override prop size: Int64
```

功能：条目序列的数量。

类型：Int64

### Pem(Array\<PemEntry>)

```cangjie
public Pem(private let items: Array<PemEntry>)
```

功能：构造 [Pem](#struct-pem) 对象。

参数：

- items: Array\<[PemEntry](#struct-pementry)> - 多个 [PemEntry](#struct-pementry) 对象。

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

### func encode()

```cangjie
public func encode(): String
```

功能：返回 PEM 格式的字符串。行结束符将根据当前操作系统生成。

返回值：

- String - PEM 格式的字符串。

### func isEmpty()

```cangjie
public override func isEmpty(): Bool
```

功能：判断 PEM 文本解码为条目序列是否为空。

返回值：

- Bool - PEM 文本解码为条目序列为空返回 true；否则，返回 false。

### func iterator()

```cangjie
public override func iterator(): Iterator<PemEntry>
```

功能：生成 PEM 文本解码为条目序列的迭代器。

返回值：

- Iterator\<[PemEntry](#struct-pementry)> - PEM 文本解码为条目序列的迭代器。

### func toString()

```cangjie
public override func toString(): String
```

功能：返回一个字符串，字符串内容是包含每个条目序列的标签。

返回值：

- String - 包含每个条目序列的标签的字符串。

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

### static let LABEL_CERTIFICATE

```cangjie
public static let LABEL_CERTIFICATE: String = "CERTIFICATE"
```

功能：记录条目类型为证书。

类型：String

### static let LABEL_CERTIFICATE_REQUEST

```cangjie
public static let LABEL_CERTIFICATE_REQUEST: String = "CERTIFICATE REQUEST"
```

功能：记录条目类型为证书签名请求。

类型：String

### static let LABEL_DH_PARAMETERS

```cangjie
public static let LABEL_DH_PARAMETERS: String = "DH PARAMETERS"
```

功能：记录条目类型为 DH 密钥参数。

类型：String

### static let LABEL_EC_PARAMETERS

```cangjie
public static let LABEL_EC_PARAMETERS: String = "EC PARAMETERS"
```

功能：记录条目类型为椭圆曲线参数。

类型：String

### static let LABEL_EC_PRIVATE_KEY

```cangjie
public static let LABEL_EC_PRIVATE_KEY: String = "EC PRIVATE KEY"
```

功能：记录条目类型为椭圆曲线私钥。

类型：String

### static let LABEL_ENCRYPTED_PRIVATE_KEY

```cangjie
public static let LABEL_ENCRYPTED_PRIVATE_KEY: String = "ENCRYPTED PRIVATE KEY"
```

功能：记录条目类型为 PKCS #8 标准加密的私钥。

类型：String

### static let LABEL_PRIVATE_KEY

```cangjie
public static let LABEL_PRIVATE_KEY: String = "PRIVATE KEY"
```

功能：记录条目类型为 PKCS #8 标准未加密的私钥。

类型：String

### static let LABEL_PUBLIC_KEY

```cangjie
public static let LABEL_PUBLIC_KEY: String = "PUBLIC KEY"
```

功能：记录条目类型为公钥。

类型：String

### static let LABEL_RSA_PRIVATE_KEY

```cangjie
public static let LABEL_RSA_PRIVATE_KEY: String = "RSA PRIVATE KEY"
```

功能：记录条目类型为 RSA 私钥。

类型：String

### static let LABEL_SM2_PRIVATE_KEY

```cangjie
public static let LABEL_SM2_PRIVATE_KEY: String = "SM2 PRIVATE KEY"
```

功能：记录条目类型为 SM2 私钥。

类型：String

### static let LABEL_X509_CRL

```cangjie
public static let LABEL_X509_CRL: String = "X509 CRL"
```

功能：记录条目类型为证书吊销列表。

类型：String

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

### let body

```cangjie
public let body: ?DerBlob
```

功能：[PemEntry](#struct-pementry) 实例的二进制内容。

类型：?[DerBlob](#struct-derblob)

### let headers

```cangjie
public let headers: Array<(String, String)>
```

功能：[PemEntry](#struct-pementry) 实例的条目头。

类型：Array\<(String, String)>

### let label

```cangjie
public let label: String
```

功能：[PemEntry](#struct-pementry) 实例的标签。

类型：String

### init(String, DerBlob)

```cangjie
public init(label: String, body: DerBlob)
```

功能：构造 [PemEntry](#struct-pementry) 对象。

参数：

- label: String - 标签
- body: [DerBlob](#struct-derblob) - 二进制内容

### func encode()

```cangjie
public func encode(): String
```

功能：返回 PEM 格式的字符串。行结束符将根据当前操作系统生成。

返回值：

- String - PEM 格式的字符串。

### func header(String)

```cangjie
public func header(name: String): Iterator<String>
```

功能：通过条目头名称，找到对应条目内容。

参数：

- name: String - 条目头名称。

返回值：

- Iterator\<String> - 条目头名称对应内容的迭代器。

### func toString()

```cangjie
public override func toString(): String
```

功能：返回 PEM 对象的标签和二进制内容的长度。

返回值：

- String - PEM 对象的标签和二进制内容的长度。
