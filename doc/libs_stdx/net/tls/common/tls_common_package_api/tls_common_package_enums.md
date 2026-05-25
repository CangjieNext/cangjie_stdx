# 枚举

## enum CertificateVerifyMode

```cangjie
public enum CertificateVerifyMode {
    | Default
    | TrustAll
    | CustomCA(Array<Certificate>)
    | CustomVerify((Array<Certificate>) -> Bool)
}
```

功能：对证书验证的处理模式。

> **说明：**
>
> CustomCA 模式可使用用户配置的证书地址，适用于用户证书无法设置为系统证书的场景。
>
> 证书认证模式，TCP 连接建立成功后，客户端和服务端可交换证书，Default 模式使用系统证书。
>
> 在开发测试阶段，可使用 TrustAll 模式，该模式表示本端不作对对端证书的校验。此模式本端信任任意建立连接对象，一般仅在开发测试阶段使用。

### CustomCA(Array\<Certificate>)

```cangjie
CustomCA(Array<Certificate>)
```

功能：表示根据提供的 CA 列表与系统 CA 进行验证。

### CustomVerify((Array\<Certificate>) -> Bool)

```cangjie
CustomVerify((Array<Certificate>) -> Bool)
```

功能：表示自定义验证规则。需要提供一个证书校验函数，根据传入的证书返回是否校验通过。

### Default

```cangjie
Default
```

功能：表示默认验证模式，根据系统 CA 验证证书。

### TrustAll

```cangjie
TrustAll
```

功能：表示信任所有证书。

## enum TlsVersion

```cangjie
public enum TlsVersion <: ToString & Hashable & Equatable<TlsVersion>{
    V1_2 | V1_3 | TLCP | ...
}
```

功能：TLS 协议版本。

父类型：

- ToString
- Hashable
- Equatable\<[TlsVersion](#enum-tlsversion)>

### TLCP

```cangjie
TLCP
```

功能：表示 TLCP 版本。

### V1_2

```cangjie
V1_2
```

功能：表示 TLS 1.2 版本。

### V1_3

```cangjie
V1_3
```

功能：表示 TLS 1.3 版本。

### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：返回当前 [TlsVersion](#enum-tlsversion) 的哈希值。

返回值：

- Int64 - 当前 [TlsVersion](#enum-tlsversion) 的哈希值。

示例：

<!-- verify -->
```cangjie
import stdx.net.tls.common.*

main() {
    let tlsVersion = TlsVersion.V1_3
    let hashValue = tlsVersion.hashCode()
    println("TLS版本 ${tlsVersion} 的哈希值: ${hashValue}")

    return 0
}
```

运行结果：

```text
TLS版本 TlsVersion.V1_3 的哈希值: -7046029254386353130
```

### func toString()

```cangjie
public override func toString(): String
```

功能：返回当前 [TlsVersion](#enum-tlsversion) 的字符串表示。

返回值：

- String - 当前 [TlsVersion](#enum-tlsversion) 的字符串表示。

示例：

<!-- verify -->
```cangjie
import stdx.net.tls.common.*

main() {
    let tlsVersion = TlsVersion.V1_2
    let strValue = tlsVersion.toString()
    println("TLS版本的字符串表示: ${strValue}")

    return 0
}
```

运行结果：

```text
TLS版本的字符串表示: TlsVersion.V1_2
```

### operator func !=(TlsVersion)

```cangjie
public operator func !=(that: TlsVersion): Bool
```

功能：比较两个 [TlsVersion](#enum-tlsversion) 是否不等。

参数：

- that: [TlsVersion](#enum-tlsversion) - 待比较的 TLS 版本。

返回值：

- Bool - 若不等返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.net.tls.common.*

main() {
    let tlsVersion1 = TlsVersion.V1_2
    let tlsVersion2 = TlsVersion.V1_3

    let isNotEqual = tlsVersion1 != tlsVersion2
    println("${tlsVersion1} != ${tlsVersion2}: ${isNotEqual}")

    let isEqual = tlsVersion1 != tlsVersion1
    println("${tlsVersion1} != ${tlsVersion1}: ${isEqual}")

    return 0
}
```

运行结果：

```text
TlsVersion.V1_2 != TlsVersion.V1_3: true
TlsVersion.V1_2 != TlsVersion.V1_2: false
```

### operator func ==(TlsVersion)

```cangjie
public operator func ==(that: TlsVersion): Bool
```

功能：比较两个 [TlsVersion](#enum-tlsversion) 是否相同。

参数：

- that: [TlsVersion](#enum-tlsversion) - 待比较的 TLS 版本。

返回值：

- Bool - 相同时返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.net.tls.common.*

main() {
    let tlsVersion1 = TlsVersion.V1_2
    let tlsVersion2 = TlsVersion.V1_2
    let tlsVersion3 = TlsVersion.V1_3

    let isEqual = tlsVersion1 == tlsVersion2
    println("${tlsVersion1} == ${tlsVersion2}: ${isEqual}")

    let isNotEqual = tlsVersion1 == tlsVersion3
    println("${tlsVersion1} == ${tlsVersion3}: ${isNotEqual}")

    return 0
}
```

运行结果：

```text
TlsVersion.V1_2 == TlsVersion.V1_2: true
TlsVersion.V1_2 == TlsVersion.V1_3: false
```
