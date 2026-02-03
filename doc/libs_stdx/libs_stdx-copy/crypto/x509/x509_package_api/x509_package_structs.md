# 结构体

## struct ExtKeyUsage

```cangjie
public struct ExtKeyUsage <: ToString {
    public static let AnyKey: UInt16 = 0
    public static let ServerAuth: UInt16 = 1
    public static let ClientAuth: UInt16 = 2
    public static let EmailProtection: UInt16 = 3
    public static let CodeSigning: UInt16 = 4
    public static let OCSPSigning: UInt16 = 5
    public static let TimeStamping: UInt16 = 6
    public init(keys: Array<UInt16>)
}
```

功能：数字证书扩展字段中通常会包含携带扩展密钥用法说明，目前支持的用途有：ServerAuth、ClientAuth、EmailProtection、CodeSigning、OCSPSigning、TimeStamping。

父类型：

- ToString

### static let AnyKey

```cangjie
public static let AnyKey: UInt16 = 0
```

功能：表示应用于任意用途。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取AnyKey常量值
    let anyKeyValue = ExtKeyUsage.AnyKey
    println("AnyKey Value: ${anyKeyValue}")
}
```

运行结果：

```text
AnyKey Value: 0
```

### static let ClientAuth

```cangjie
public static let ClientAuth: UInt16 = 2
```

功能：表示用于 SSL 的客户端验证。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取ClientAuth常量值
    let clientAuthValue = ExtKeyUsage.ClientAuth
    println("ClientAuth Value: ${clientAuthValue}")
}
```

运行结果：

```text
ClientAuth Value: 2
```

### static let CodeSigning

```cangjie
public static let CodeSigning: UInt16 = 4
```

功能：表示用于代码签名。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取CodeSigning常量值
    let codeSigningValue = ExtKeyUsage.CodeSigning
    println("CodeSigning Value: ${codeSigningValue}")
}
```

运行结果：

```text
CodeSigning Value: 4
```

### static let EmailProtection

```cangjie
public static let EmailProtection: UInt16 = 3
```

功能：表示用于电子邮件的加解密、签名等。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取EmailProtection常量值
    let emailProtectionValue = ExtKeyUsage.EmailProtection
    println("EmailProtection Value: ${emailProtectionValue}")
}
```

运行结果：

```text
EmailProtection Value: 3
```

### static let OCSPSigning

```cangjie
public static let OCSPSigning: UInt16 = 5
```

功能：用于对 OCSP 响应包进行签名。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取OCSPSigning常量值
    let ocspSigningValue = ExtKeyUsage.OCSPSigning
    println("OCSPSigning Value: ${ocspSigningValue}")
}
```

运行结果：

```text
OCSPSigning Value: 5
```

### static let ServerAuth

```cangjie
public static let ServerAuth: UInt16 = 1
```

功能：表示用于 SSL 的服务端验证。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取ServerAuth常量值
    let serverAuthValue = ExtKeyUsage.ServerAuth
    println("ServerAuth Value: ${serverAuthValue}")
}
```

运行结果：

```text
ServerAuth Value: 1
```

### static let TimeStamping

```cangjie
public static let TimeStamping: UInt16 = 6
```

功能：用于将对象摘要值与时间绑定。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取TimeStamping常量值
    let timeStampingValue = ExtKeyUsage.TimeStamping
    println("TimeStamping Value: ${timeStampingValue}")
}
```

运行结果：

```text
TimeStamping Value: 6
```

### init(Array\<UInt16>)

```cangjie
public init(keys: Array<UInt16>)
```

功能：构造指定用途的扩展密钥用法，需要注意同一个密钥可以有多种用途。

参数：

- keys: Array\<UInt16> - 密钥。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建包含多个扩展密钥用途的数组
    let keyUsages = [ExtKeyUsage.ServerAuth, ExtKeyUsage.ClientAuth, ExtKeyUsage.CodeSigning]

    // 使用数组创建ExtKeyUsage对象
    let extKeyUsage = ExtKeyUsage(keyUsages)

    // 输出ExtKeyUsage对象信息
    println("ExtKeyUsage: ${extKeyUsage}")
}
```

运行结果：

```text
ExtKeyUsage: ServerAuth, ClientAuth, CodeSigning
```

### func toString()

```cangjie
public override func toString(): String
```

功能：生成扩展密钥用途字符串。

返回值：

- String - 证书扩展密钥用途字符串。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建包含多个扩展密钥用途的数组
    let keyUsages = [ExtKeyUsage.ServerAuth, ExtKeyUsage.EmailProtection]

    // 使用数组创建ExtKeyUsage对象
    let extKeyUsage = ExtKeyUsage(keyUsages)

    // 获取ExtKeyUsage的字符串表示
    let str = extKeyUsage.toString()
    println("ExtKeyUsage String: ${str}")
}
```

运行结果：

```text
ExtKeyUsage String: ServerAuth, EmailProtection
```

## struct KeyUsage

```cangjie
public struct KeyUsage <: ToString {
    public static let DigitalSignature: UInt16 = 0x0080
    public static let NonRepudiation: UInt16 = 0x0040
    public static let KeyEncipherment: UInt16 = 0x0020
    public static let DataEncipherment: UInt16 = 0x0010
    public static let KeyAgreement: UInt16 = 0x0008
    public static let CertSign: UInt16 = 0x0004
    public static let CRLSign: UInt16 = 0x0002
    public static let EncipherOnly: UInt16 = 0x0001
    public static let DecipherOnly: UInt16 = 0x0100
    public init(keys: UInt16)
}
```

功能：数字证书扩展字段中通常会包含携带公钥的用法说明，目前支持的用途有：DigitalSignature、NonRepudiation、KeyEncipherment、DataEncipherment、KeyAgreement、CertSign、CRLSign、EncipherOnly、DecipherOnly。

父类型：

- ToString

### static let CertSign

```cangjie
public static let CertSign: UInt16 = 0x0004
```

功能：表示私钥用于证书签名，而公钥用于验证证书签名，专用于 CA 证书。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取CertSign常量值
    let certSignValue = KeyUsage.CertSign
    println("CertSign Value: ${certSignValue}")
}
```

运行结果：

```text
CertSign Value: 4
```

### static let CRLSign

```cangjie
public static let CRLSign: UInt16 = 0x0002
```

功能：表示私钥可用于对 CRL 签名，而公钥可用于验证 CRL 签名。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取CRLSign常量值
    let crlSignValue = KeyUsage.CRLSign
    println("CRLSign Value: ${crlSignValue}")
}
```

运行结果：

```text
CRLSign Value: 2
```

### static let DataEncipherment

```cangjie
public static let DataEncipherment: UInt16 = 0x0010
```

功能：表示公钥用于直接加密数据。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取DataEncipherment常量值
    let dataEnciphermentValue = KeyUsage.DataEncipherment
    println("DataEncipherment Value: ${dataEnciphermentValue}")
}
```

运行结果：

```text
DataEncipherment Value: 16
```

### static let DecipherOnly

```cangjie
public static let DecipherOnly: UInt16 = 0x0100
```

功能：表示证书中的公钥在密钥协商过程中，仅仅用于解密计算，配合 key Agreement 使用才有意义。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取DecipherOnly常量值
    let decipherOnlyValue = KeyUsage.DecipherOnly
    println("DecipherOnly Value: ${decipherOnlyValue}")
}
```

运行结果：

```text
DecipherOnly Value: 256
```

### static let DigitalSignature

```cangjie
public static let DigitalSignature: UInt16 = 0x0080
```

功能：表示私钥可以用于除了签发证书、签发 CRL 和非否认性服务的各种数字签名操作,而公钥用来验证这些签名。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取DigitalSignature常量值
    let digitalSignatureValue = KeyUsage.DigitalSignature
    println("DigitalSignature Value: ${digitalSignatureValue}")
}
```

运行结果：

```text
DigitalSignature Value: 128
```

### static let EncipherOnly

```cangjie
public static let EncipherOnly: UInt16 = 0x0001
```

功能：表示证书中的公钥在密钥协商过程中，仅仅用于加密计算，配合 key Agreement 使用才有意义。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取EncipherOnly常量值
    let encipherOnlyValue = KeyUsage.EncipherOnly
    println("EncipherOnly Value: ${encipherOnlyValue}")
}
```

运行结果：

```text
EncipherOnly Value: 1
```

### static let KeyAgreement

```cangjie
public static let KeyAgreement: UInt16 = 0x0008
```

功能：表示密钥用于密钥协商。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取KeyAgreement常量值
    let keyAgreementValue = KeyUsage.KeyAgreement
    println("KeyAgreement Value: ${keyAgreementValue}")
}
```

运行结果：

```text
KeyAgreement Value: 8
```

### static let KeyEncipherment

```cangjie
public static let KeyEncipherment: UInt16 = 0x0020
```

功能：表示密钥用来加密传输其他的密钥。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取KeyEncipherment常量值
    let keyEnciphermentValue = KeyUsage.KeyEncipherment
    println("KeyEncipherment Value: ${keyEnciphermentValue}")
}
```

运行结果：

```text
KeyEncipherment Value: 32
```

### static let NonRepudiation

```cangjie
public static let NonRepudiation: UInt16 = 0x0040
```

功能：表示私钥可以用于进行非否认性服务中的签名,而公钥用来验证签名。

类型：UInt16

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取NonRepudiation常量值
    let nonRepudiationValue = KeyUsage.NonRepudiation
    println("NonRepudiation Value: ${nonRepudiationValue}")
}
```

运行结果：

```text
NonRepudiation Value: 64
```

### init(UInt16)

```cangjie
public init(keys: UInt16)
```

功能：构造指定用途的扩展密钥用法，需要注意同一个密钥可以有多种用途。

参数：

- keys: UInt16 - 密钥的用法，建议使用本结构中所提供的密钥用法变量通过按位或的方式传入参数。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 使用按位或运算组合多个密钥用途
    let combinedKeys = KeyUsage.DigitalSignature | KeyUsage.KeyEncipherment

    // 使用组合的密钥用途创建KeyUsage对象
    let keyUsage = KeyUsage(combinedKeys)

    // 输出KeyUsage对象信息
    println("KeyUsage: ${keyUsage}")
}
```

运行结果：

```text
KeyUsage: KeyEncipherment, DigitalSignature
```

### func toString()

```cangjie
public override func toString(): String
```

功能：生成密钥用途字符串。

返回值：

- String - 证书密钥用途字符串。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建包含多个密钥用途的组合
    let combinedKeys = KeyUsage.CertSign | KeyUsage.CRLSign | KeyUsage.DataEncipherment

    // 使用组合的密钥用途创建KeyUsage对象
    let keyUsage = KeyUsage(combinedKeys)

    // 获取KeyUsage的字符串表示
    let str = keyUsage.toString()
    println("KeyUsage String: ${str}")
}
```

运行结果：

```text
KeyUsage String: CRLSign, CertSign, DataEncipherment
```

## struct SerialNumber

```cangjie
public struct SerialNumber <: Equatable<SerialNumber> & Hashable & ToString {
    public init(length!: UInt8 = 16)
}
```

功能：结构体 [SerialNumber](x509_package_structs.md#struct-serialnumber) 为数字证书的序列号，是数字证书中的一个唯一标识符，用于标识数字证书的唯一性。根据规范，证书序列号的长度不应超过 20 字节。详见[rfc5280](https://www.rfc-editor.org/rfc/rfc5280)。

父类型：

- Equatable\<[SerialNumber](#struct-serialnumber)>
- Hashable
- ToString

### init(UInt8)

```cangjie
public init(length!: UInt8 = 16)
```

功能：生成指定长度的随机序列号。

参数：

- length!: UInt8 - 序列号长度，单位为字节，类型为 UInt8，默认值为 16。

异常：

- [X509Exception](./x509_package_exceptions.md#class-x509exception) - length 等于 0 或大于 20 时，抛出异常。

示例：

<!-- run -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建一个默认长度为16字节的序列号
    let serialNumber = SerialNumber()
    println("Serial Number: ${serialNumber}")
}
```

可能的运行结果：

```text
Serial Number: 74F81AD0DC4DBF5957BFD8BFE62011BD
```

### func hashCode()

```cangjie
public override func hashCode(): Int64
```

功能：返回证书序列号哈希值。

返回值：

- Int64 - 对证书序列号对象进行哈希计算后得到的结果。

示例：

<!-- run -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建一个序列号对象
    let serialNumber = SerialNumber()

    // 获取序列号的哈希值
    let hashCode = serialNumber.hashCode()
    println("Serial Number HashCode: ${hashCode}")
}
```

可能的运行结果：

```text
Serial Number HashCode: -5281749894544737892
```

### func toString()

```cangjie
public override func toString(): String
```

功能：生成证书序列号字符串，格式为 16 进制。

返回值：

- String - 证书序列号字符串。

示例：

<!-- run -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建一个序列号对象
    let serialNumber = SerialNumber()

    // 获取序列号的字符串表示
    let str = serialNumber.toString()
    println("Serial Number String: ${str}")
}
```

可能的运行结果：

```text
Serial Number String: D2377B71EDD485F1D7C458B72A73E446
```

### operator func !=(SerialNumber)

```cangjie
public override operator func !=(other: SerialNumber): Bool
```

功能：判不等。

参数：

- other: [SerialNumber](x509_package_structs.md#struct-serialnumber) - 被比较的证书序列号对象。

返回值：

- Bool - 若序列号不同，返回 true；否则，返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建两个不同的序列号对象
    let serialNumber1 = SerialNumber()
    let serialNumber2 = SerialNumber()

    // 比较两个序列号是否不相等
    let isNotEqual = serialNumber1 != serialNumber2
    println("Serial Numbers Not Equal: ${isNotEqual}")
}
```

运行结果：

```text
Serial Numbers Not Equal: true
```

### operator func ==(SerialNumber)

```cangjie
public override operator func ==(other: SerialNumber): Bool
```

功能：判等。

参数：

- other: [SerialNumber](x509_package_structs.md#struct-serialnumber) - 被比较的证书序列号对象。

返回值：

- Bool - 若序列号相同，返回 true；否则，返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建两个相同的序列号对象（使用相同长度）
    let serialNumber1 = SerialNumber(length: 8)
    let serialNumber2 = SerialNumber(length: 8)

    // 比较两个序列号是否相等
    let isEqual = serialNumber1 == serialNumber2
    println("Serial Numbers Equal: ${isEqual}")
}
```

运行结果：

```text
Serial Numbers Equal: false
```

## struct Signature

```cangjie
public struct Signature <: Equatable<Signature> & Hashable {
}
```

功能：数字证书的签名，用来验证身份的正确性。

父类型：

- Equatable\<[Signature](#struct-signature)>
- Hashable

### prop signatureValue

```cangjie
public prop signatureValue: DerBlob
```

功能：返回证书签名的二进制。

类型：[DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob)

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 找到系统根证书中的ISRG Root X1证书用作演示
    var signatureOpt: ?Signature = None
    let certs = X509Certificate.systemRootCerts()
    for (cert in certs) {
        // 如果找不到ISRG Root X1可以选择其他证书作演示
        if (cert.issuer.commonName == "ISRG Root X1") {
            let x509Certificate: X509Certificate = cert
            // 获取证书的签名
            signatureOpt = x509Certificate.signature
            break
        }
    }

    // 核心演示：获得证书签名的二进制
    let signatureValue = signatureOpt?.signatureValue
    println("Signature DerBlob size: ${signatureValue?.size ?? 0}")
}
```

运行结果：

```text
Signature DerBlob size: 512
```

### func hashCode()

```cangjie
public override func hashCode(): Int64
```

功能：返回证书签名哈希值。

返回值：

- Int64 - 对证书签名对象进行哈希计算后得到的结果。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 找到系统根证书中的ISRG Root X1证书用作演示
    var signatureOpt: ?Signature = None
    let certs = X509Certificate.systemRootCerts()
    for (cert in certs) {
        // 如果找不到ISRG Root X1可以选择其他证书作演示
        if (cert.issuer.commonName == "ISRG Root X1") {
            let x509Certificate: X509Certificate = cert
            // 获取证书的签名
            signatureOpt = x509Certificate.signature
            break
        }
    }

    // 获取签名的哈希值
    let hashCode = signatureOpt?.hashCode()
    println("Signature HashCode: ${hashCode ?? 0}")
}
```

运行结果：

```text
Signature HashCode: -3222683054313786172
```

### operator func !=(Signature)

```cangjie
public override operator func !=(other: Signature): Bool
```

功能：判不等。

参数：

- other: [Signature](x509_package_structs.md#struct-signature) - 被比较的证书签名。

返回值：

- Bool - 若证书签名不同，返回 true；否则，返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取两个不同的系统根证书
    var sig1Opt: ?Signature = None
    var sig2Opt: ?Signature = None
    let certs = X509Certificate.systemRootCerts()
    var count = 0
    for (cert in certs) {
        if (count == 0) {
            sig1Opt = cert.signature
        } else if (count == 1) {
            sig2Opt = cert.signature
            break
        }
        count = count + 1
    }

    // 比较两个签名是否不相等
    let isNotEqual = sig1Opt != sig2Opt
    println("两个签名是否不相等: ${isNotEqual}")
}
```

运行结果：

```text
两个签名是否不相等: true
```

### operator func ==(Signature)

```cangjie
public override operator func ==(other: Signature): Bool
```

功能：判等。

参数：

- other: [Signature](x509_package_structs.md#struct-signature) - 被比较的证书签名。

返回值：

- Bool - 若证书签名相同，返回 true；否则，返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取同一个证书的两个引用进行相等性比较
    var signatureOpt1: ?Signature = None
    var signatureOpt2: ?Signature = None
    let certs = X509Certificate.systemRootCerts()
    for (cert in certs) {
        if (cert.issuer.commonName == "ISRG Root X1") {
            let x509Certificate: X509Certificate = cert
            signatureOpt1 = x509Certificate.signature
            break
        }
    }
    // 重新获取同一个证书的签名
    for (cert in certs) {
        if (cert.issuer.commonName == "ISRG Root X1") {
            let x509Certificate: X509Certificate = cert
            signatureOpt2 = x509Certificate.signature
            break
        }
    }

    // 比较两个签名是否相等
    let isEqual = signatureOpt1 == signatureOpt2
    println("两个签名是否相等: ${isEqual}")
}
```

运行结果：

```text
两个签名是否相等: true
```

## struct VerifyOption

```cangjie
public struct VerifyOption {
    public var time: DateTime = DateTime.now()
    public var dnsName: String = ""
    public var roots: Array<X509Certificate> = X509Certificate.systemRootCerts()
    public var intermediates: Array<X509Certificate> = Array<X509Certificate>()
}
```

功能：用于为 `x509` 证书验证函数 [verify](./x509_package_classes.md#func-verifyverifyoption) 提供配置选项。

### var dnsName

```cangjie
public var dnsName: String = ""
```

功能：校验域名，默认为空，只有设置域名时才会进行此处校验。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 模拟场景：已有的X509证书对象（此处通过系统根证书ISRG Root X1模拟）
    var certOpt: ?X509Certificate = None
    let certs = X509Certificate.systemRootCerts()
    for (cert in certs) {
        if (cert.issuer.commonName == "ISRG Root X1") {
            certOpt = cert
            break
        }
    }
    // 创建验证选项
    var verifyOpt = VerifyOption()
    // 设置验证域名
    verifyOpt.dnsName = "example.com"
    // 验证证书
    let isValid = certOpt?.verify(verifyOpt)

    println("证书是否有效: ${isValid ?? false}")

    // 创建另一个验证选项
    var verifyOpt2 = VerifyOption()
    // 设置验证域名，因为根证书没有绑定域名，所以设置为空
    verifyOpt2.dnsName = ""
    // 验证证书
    let isValid2 = certOpt?.verify(verifyOpt2)

    println("证书是否有效: ${isValid2 ?? false}")
}
```

运行结果：

```text
证书是否有效: false
证书是否有效: true
```

### var intermediates

```cangjie
public var intermediates: Array<X509Certificate> = Array<X509Certificate>()
```

功能：中间证书链，默认为空。

类型：Array\<[X509Certificate](x509_package_classes.md#class-x509certificate)>

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 模拟场景：已有的X509证书对象（此处通过系统根证书ISRG Root X1模拟）
    var certOpt: ?X509Certificate = None
    let certs = X509Certificate.systemRootCerts()
    for (cert in certs) {
        if (cert.issuer.commonName == "ISRG Root X1") {
            certOpt = cert
            break
        }
    }
    // 创建验证选项
    var verifyOpt = VerifyOption()
    // 设置中间证书链
    verifyOpt.intermediates = []
    // 验证证书
    let isValid = certOpt?.verify(verifyOpt)

    println("证书是否有效: ${isValid ?? false}")
}
```

运行结果：

```text
证书是否有效: true
```

### var roots

```cangjie
public var roots: Array<X509Certificate> = X509Certificate.systemRootCerts()
```

功能：根证书链，默认为系统根证书链。

类型：Array\<[X509Certificate](x509_package_classes.md#class-x509certificate)>

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 获取两个不同的系统根证书
    var cert1Opt: ?X509Certificate = None
    var cert2Opt: ?X509Certificate = None
    let certs = X509Certificate.systemRootCerts()
    var count = 0
    for (cert in certs) {
        if (count == 0) {
            cert1Opt = cert
        } else if (count == 1) {
            cert2Opt = cert
            break
        }
        count = count + 1
    }
    let cert1 = cert1Opt.getOrThrow()
    let cert2 = cert2Opt.getOrThrow()

    // 创建验证选项
    var verifyOpt = VerifyOption()
    // 核心演示：设置信任根证书集合，不设置默认为系统根证书链
    verifyOpt.roots = [cert1, cert2]
    // 验证证书，因为cert1在信任根证书集合中，所以有效
    let isValid = cert1.verify(verifyOpt)

    println("证书cert1是否有效: ${isValid}")

    // 核心演示：设置信任根证书集合，不设置默认为系统根证书链
    var verifyOpt2 = VerifyOption()
    verifyOpt2.roots = [cert2]
    // 验证证书，因为cert1不在信任根证书集合中，所以无效
    let isValid2 = cert1.verify(verifyOpt2)

    println("证书cert1是否有效: ${isValid2}")
}
```

运行结果：

```text
证书cert1是否有效: true
证书cert1是否有效: false
```

### var time

```cangjie
public var time: DateTime = DateTime.now()
```

功能：校验时间，默认为创建选项的时间。

类型：DateTime

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*
import std.time.*

main() {
    // 模拟场景：已有的X509证书对象（此处通过系统根证书ISRG Root X1模拟）
    var certOpt: ?X509Certificate = None
    let certs = X509Certificate.systemRootCerts()
    for (cert in certs) {
        if (cert.issuer.commonName == "ISRG Root X1") {
            certOpt = cert
            break
        }
    }
    // 创建验证选项
    var verifyOpt = VerifyOption()
    // 核心演示：设置验证时间
    verifyOpt.time = DateTime.of(year: 2036, month: 1, dayOfMonth: 1)
    // 验证证书
    let isValid = certOpt?.verify(verifyOpt)

    println("证书是否有效: ${isValid ?? false}")

    // 核心演示：创建另一个验证时间
    var verifyOpt2 = VerifyOption()
    verifyOpt2.time = DateTime.of(year: 2026, month: 1, dayOfMonth: 1)
    // 验证证书
    let isValid2 = certOpt?.verify(verifyOpt2)

    println("证书是否有效: ${isValid2 ?? false}")
}
```

运行结果：

```text
证书是否有效: false
证书是否有效: true
```

## struct X509CertificateInfo

```cangjie
public struct X509CertificateInfo {
    public var serialNumber: SerialNumber
    public var notBefore: DateTime
    public var notAfter: DateTime
    public var subject: ?X509Name
    public var dnsNames: Array<String>
    public var emailAddresses: Array<String>
    public var IPAddresses: Array<IP>
    public var keyUsage: ?KeyUsage
    public var extKeyUsage: ?ExtKeyUsage

    public init(
        serialNumber!: ?SerialNumber = None,
        notBefore!: ?DateTime = None,
        notAfter!: ?DateTime = None,
        subject!: ?X509Name = None,
        dnsNames!: Array<String> = Array<String>(),
        emailAddresses!: Array<String> = Array<String>(),
        IPAddresses!: Array<IP> = Array<IP>(),
        keyUsage!: ?KeyUsage = None,
        extKeyUsage!: ?ExtKeyUsage = None
    )
}
```

功能：[X509CertificateInfo](x509_package_structs.md#struct-x509certificateinfo) 结构包含了证书信息，包括证书序列号、有效期、实体可辨识名称、域名、email 地址、[IP](x509_package_type.md#type-ip) 地址、密钥用法和扩展密钥用法。

### var dnsNames

```cangjie
public var dnsNames: Array<String>
```

功能：记录证书的 DNS 域名。

类型：Array\<String>

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建一个X509CertificateInfo对象
    let certInfo = X509CertificateInfo(dnsNames: ["example.com", "test.com"])

    // 输出DNS域名列表
    println("DNS Names: ${certInfo.dnsNames}")
}
```

运行结果：

```text
DNS Names: [example.com, test.com]
```

### var emailAddresses

```cangjie
public var emailAddresses: Array<String>
```

功能：记录证书的 email 地址。

类型：Array\<String>

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建一个X509CertificateInfo对象
    let certInfo = X509CertificateInfo(emailAddresses: ["user@example.com", "admin@test.com"])

    // 输出Email地址列表
    println("Email Addresses: ${certInfo.emailAddresses}")
}
```

运行结果：

```text
Email Addresses: [user@example.com, admin@test.com]
```

### var extKeyUsage

```cangjie
public var extKeyUsage: ?ExtKeyUsage
```

功能：记录证书的扩展密钥用法。

类型：?[ExtKeyUsage](./x509_package_structs.md#struct-extkeyusage)

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建扩展密钥用法对象
    let keyUsages = [ExtKeyUsage.ServerAuth, ExtKeyUsage.ClientAuth]
    let extKeyUsage = ExtKeyUsage(keyUsages)

    // 创建一个X509CertificateInfo对象
    let certInfo = X509CertificateInfo(extKeyUsage: extKeyUsage)

    // 输出扩展密钥用法
    println("Ext Key Usage: ${certInfo.extKeyUsage}")
}
```

运行结果：

```text
Ext Key Usage: Some(ServerAuth, ClientAuth)
```

### var IPAddresses

```cangjie
public var IPAddresses: Array<IP>
```

功能：记录证书的 [IP](x509_package_type.md#type-ip) 地址。

类型：Array\<[IP](./x509_package_type.md#type-ip)>

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建IP地址列表
    let ipList = [[192u8, 168u8, 1u8, 1u8], [10u8, 0u8, 0u8, 1u8]]

    // 创建一个X509CertificateInfo对象
    let certInfo = X509CertificateInfo(IPAddresses: ipList)

    // 输出IP地址列表
    println("IP Addresses: ${certInfo.IPAddresses}")
}
```

运行结果：

```text
IP Addresses: [[192, 168, 1, 1], [10, 0, 0, 1]]
```

### var keyUsage

```cangjie
public var keyUsage: ?KeyUsage
```

功能：记录证书的密钥用法。

类型：?[KeyUsage](./x509_package_structs.md#struct-keyusage)

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建密钥用法对象
    let keyUsageValue = KeyUsage(KeyUsage.DigitalSignature | KeyUsage.KeyEncipherment)

    // 创建一个X509CertificateInfo对象
    let certInfo = X509CertificateInfo(keyUsage: keyUsageValue)

    // 输出密钥用法
    println("Key Usage: ${certInfo.keyUsage}")
}
```

运行结果：

```text
Key Usage: Some(KeyEncipherment, DigitalSignature)
```

### var notAfter

```cangjie
public var notAfter: DateTime
```

功能：记录证书有效期的结束日期。

类型：DateTime

示例：

<!-- run -->
```cangjie
import std.time.*
import stdx.crypto.x509.*

main() {
    // 创建一个DateTime对象表示结束日期
    let endDate = DateTime.now()

    // 创建一个X509CertificateInfo对象
    let certInfo = X509CertificateInfo(notAfter: endDate)

    // 输出证书有效期结束日期
    println("Not After: ${certInfo.notAfter}")
}
```

可能的运行结果：

```text
Not After: 2026-01-05T10:32:07.77851204+08:00
```

### var notBefore

```cangjie
public var notBefore: DateTime
```

功能：记录证书有效期的起始日期。

类型：DateTime

示例：

<!-- run -->
```cangjie
import stdx.crypto.x509.*
import std.time.DateTime

main() {
    // 创建一个DateTime对象表示起始日期
    let startDate = DateTime.now()

    // 创建一个X509CertificateInfo对象
    let certInfo = X509CertificateInfo(notBefore: startDate)

    // 输出证书有效期起始日期
    println("Not Before: ${certInfo.notBefore}")
}
```

可能的运行结果：

```text
Not Before: 2026-01-05T10:53:18.564805132+08:00
```

### var serialNumber

```cangjie
public var serialNumber: SerialNumber
```

功能：记录证书的序列号。

类型：[SerialNumber](x509_package_structs.md#struct-serialnumber)

示例：

<!-- run -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建一个序列号对象
    let serialNum = SerialNumber(length: 8)

    // 创建一个X509CertificateInfo对象
    let certInfo = X509CertificateInfo(serialNumber: serialNum)

    // 输出证书序列号
    println("Serial Number: ${certInfo.serialNumber}")
}
```

可能的运行结果：

```text
Serial Number: 8BF8AAB1A3B47073
```

### var subject

```cangjie
public var subject: ?X509Name
```

功能：记录证书实体可辨识名称。

类型：?[X509Name](x509_package_classes.md#class-x509name)

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建一个X509Name对象
    let x509Name = X509Name(
        countryName: "CN",
        provinceName: "Beijing",
        localityName: "Haidian",
        organizationName: "Huawei",
        organizationalUnitName: "Cloud",
        commonName: "example.com"
    )

    // 创建一个X509CertificateInfo对象
    let certInfo = X509CertificateInfo(subject: x509Name)

    // 输出证书实体可辨识名称
    println("Subject: ${certInfo.subject}")
}
```

运行结果：

```text
Subject: Some(c=CN,st=Beijing,l=Haidian,o=Huawei,ou=Cloud,cn=example.com)
```

### init(?SerialNumber, ?DateTime, ?DateTime, ?X509Name, Array\<String>, Array\<String>, Array\<IP>, ?KeyUsage, ?ExtKeyUsage)

```cangjie
public init(
    serialNumber!: ?SerialNumber = None,
    notBefore!: ?DateTime = None,
    notAfter!: ?DateTime = None,
    subject!: ?X509Name = None,
    dnsNames!: Array<String> = Array<String>(),
    emailAddresses!: Array<String> = Array<String>(),
    IPAddresses!: Array<IP> = Array<IP>(),
    keyUsage!: ?KeyUsage = None,
    extKeyUsage!: ?ExtKeyUsage = None
)
```

功能：构造 [X509CertificateInfo](x509_package_structs.md#struct-x509certificateinfo) 对象。

参数：

- serialNumber!: ?[SerialNumber](x509_package_structs.md#struct-serialnumber) - 数字证书序列号，默认值为 None，使用默认值时默认的序列号长度为 128 比特。
- notBefore!: ?DateTime - 数字证书有效期开始时间，默认值为 None，使用默认值时默认的时间为 [X509CertificateInfo](x509_package_structs.md#struct-x509certificateinfo) 创建的时间。
- notAfter!: ?DateTime - 数字证书有效期截止时间，默认值为 None，使用默认值时默认的时间为 notBefore 往后 1 年的时间。
- subject!: ?[X509Name](x509_package_classes.md#class-x509name) - 数字证书使用者信息，默认值为 None。
- dnsNames!: Array\<String> - 域名列表，需要用户保证输入域名的有效性，默认值为空的字符串数组。
- emailAddresses!: Array\<String> - email 地址列表，需要用户保证输入 email 的有效性，默认值为空的字符串数组。
- IPAddresses!: Array\<[IP](x509_package_type.md#type-ip)> - [IP](x509_package_type.md#type-ip) 地址列表，默认值为空的 [IP](x509_package_type.md#type-ip) 数组。
- keyUsage!: ?[KeyUsage](x509_package_structs.md#struct-keyusage) - 密钥用法，默认值为 None。
- extKeyUsage!: ?[ExtKeyUsage](x509_package_structs.md#struct-extkeyusage) - 扩展密钥用法，默认值为 None。

异常：

- [X509Exception](./x509_package_exceptions.md#class-x509exception) - 输入的 [IP](x509_package_type.md#type-ip) 地址列表中包含无效的 [IP](x509_package_type.md#type-ip) 地址，则抛出异常。

示例：

<!-- run -->
```cangjie
import stdx.crypto.x509.*
import std.time.DateTime

main() {
    // 创建X509Name对象
    let x509Name = X509Name(
        countryName: "CN",
        provinceName: "Beijing",
        localityName: "Haidian",
        organizationName: "Huawei",
        organizationalUnitName: "Cloud",
        commonName: "example.com"
    )

    // 创建IP地址列表
    let ipList = [[192u8, 168u8, 1u8, 1u8], [10u8, 0u8, 0u8, 1u8]]

    // 创建密钥用法对象
    let keyUsageValue = KeyUsage(KeyUsage.DigitalSignature | KeyUsage.KeyEncipherment)

    // 创建扩展密钥用法对象
    let keyUsages = [ExtKeyUsage.ServerAuth, ExtKeyUsage.ClientAuth]
    let extKeyUsage = ExtKeyUsage(keyUsages)

    // 使用所有参数构造X509CertificateInfo对象
    let certInfo = X509CertificateInfo(
        serialNumber: SerialNumber(length: 8),
        notBefore: DateTime.now(),
        notAfter: DateTime.now(),
        subject: x509Name,
        dnsNames: ["example.com", "test.com"],
        emailAddresses: ["user@example.com", "admin@test.com"],
        IPAddresses: ipList,
        keyUsage: keyUsageValue,
        extKeyUsage: extKeyUsage
    )
}
```

## struct X509CertificateRequestInfo

```cangjie
public struct X509CertificateRequestInfo {
    public var subject: ?X509Name
    public var dnsNames: Array<String>
    public var emailAddresses: Array<String>
    public var IPAddresses: Array<IP>

    public init(
        subject!: ?X509Name = None,
        dnsNames!: Array<String> = Array<String>(),
        emailAddresses!: Array<String> = Array<String>(),
        IPAddresses!: Array<IP> = Array<IP>()
    )
}
```

功能：[X509CertificateRequestInfo](x509_package_structs.md#struct-x509certificaterequestinfo) 结构包含了证书请求信息，包括证书实体可辨识名称、域名、email 地址和 [IP](x509_package_type.md#type-ip) 地址。

### var dnsNames

```cangjie
public var dnsNames: Array<String>
```

功能：记录证书签名请求的 DNS 域名。

类型：Array\<String>

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建一个X509CertificateRequestInfo对象
    let certRequestInfo = X509CertificateRequestInfo(dnsNames: ["example.com", "test.com"])

    // 输出DNS域名列表
    println("DNS Names: ${certRequestInfo.dnsNames}")
}
```

运行结果：

```text
DNS Names: [example.com, test.com]
```

### var emailAddresses

```cangjie
public var emailAddresses: Array<String>
```

功能：记录证书签名请求的 email 地址。

类型：Array\<String>

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建一个X509CertificateRequestInfo对象
    let certRequestInfo = X509CertificateRequestInfo(emailAddresses: ["user@example.com", "admin@test.com"])

    // 输出Email地址列表
    println("Email Addresses: ${certRequestInfo.emailAddresses}")
}
```

运行结果：

```text
Email Addresses: [user@example.com, admin@test.com]
```

### var IPAddresses

```cangjie
public var IPAddresses: Array<IP>
```

功能：记录证书签名请求的 [IP](x509_package_type.md#type-ip) 地址。

类型：Array\<[IP](./x509_package_type.md#type-ip)>

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建IP地址列表
    let ipList = [[192u8, 168u8, 1u8, 1u8], [10u8, 0u8, 0u8, 1u8]]

    // 创建一个X509CertificateRequestInfo对象
    let certRequestInfo = X509CertificateRequestInfo(IPAddresses: ipList)

    // 输出IP地址列表
    println("IP Addresses: ${certRequestInfo.IPAddresses}")
}
```

运行结果：

```text
IP Addresses: [[192, 168, 1, 1], [10, 0, 0, 1]]
```

### var subject

```cangjie
public var subject: ?X509Name
```

功能：记录证书签名请求的实体可辨识名称。

类型：?[X509Name](x509_package_classes.md#class-x509name)

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建一个X509Name对象
    let x509Name = X509Name(
        countryName: "CN",
        provinceName: "Beijing",
        localityName: "Haidian",
        organizationName: "Huawei",
        organizationalUnitName: "Cloud",
        commonName: "example.com"
    )

    // 创建一个X509CertificateRequestInfo对象
    let certRequestInfo = X509CertificateRequestInfo(subject: x509Name)

    // 输出证书请求的实体可辨识名称
    println("Subject: ${certRequestInfo.subject?.toString() ?? "None"}")
}
```

运行结果：

```text
Subject: c=CN,st=Beijing,l=Haidian,o=Huawei,ou=Cloud,cn=example.com
```

### init(?X509Name, Array\<String>, Array\<String>, Array\<IP>)

```cangjie
public init(
    subject!: ?X509Name = None,
    dnsNames!: Array<String> = Array<String>(),
    emailAddresses!: Array<String> = Array<String>(),
    IPAddresses!: Array<IP> = Array<IP>()
)
```

功能：构造 [X509CertificateRequestInfo](x509_package_structs.md#struct-x509certificaterequestinfo) 对象。

参数：

- subject!: ?[X509Name](x509_package_classes.md#class-x509name) - 数字证书的使用者信息，默认值为 None。
- dnsNames!: Array\<String> - 域名列表，需要用户保证输入域名的有效性，默认值为空的字符串数组。
- emailAddresses!: Array\<String> - email 地址列表，需要用户保证输入 email 的有效性，默认值为空的字符串数组。
- IPAddresses!: Array\<[IP](x509_package_type.md#type-ip)> - [IP](x509_package_type.md#type-ip) 地址列表，默认值为空的 [IP](x509_package_type.md#type-ip) 数组。

异常：

- [X509Exception](./x509_package_exceptions.md#class-x509exception) - 输入的 [IP](x509_package_type.md#type-ip) 地址列表中包含无效的 [IP](x509_package_type.md#type-ip) 地址，则抛出异常。

示例：

<!-- run -->
```cangjie
import stdx.crypto.x509.*

main() {
    // 创建一个X509Name对象
    let x509Name = X509Name(
        countryName: "CN",
        provinceName: "Beijing",
        localityName: "Haidian",
        organizationName: "Huawei",
        organizationalUnitName: "Cloud",
        commonName: "example.com"
    )

    // 创建IP地址列表
    let ipList = [[192u8, 168u8, 1u8, 1u8], [10u8, 0u8, 0u8, 1u8]]

    // 使用所有参数构造X509CertificateRequestInfo对象
    let certRequestInfo = X509CertificateRequestInfo(
        subject: x509Name,
        dnsNames: ["example.com", "test.com"],
        emailAddresses: ["user@example.com", "admin@test.com"],
        IPAddresses: ipList
    )
}
```
