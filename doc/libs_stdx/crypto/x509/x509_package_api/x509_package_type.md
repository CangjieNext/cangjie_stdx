# 类型别名

## type IP

```cangjie
public type IP = Array<Byte>
```

功能：x509 包用 Array\<Byte> 来记录 [IP](x509_package_type.md#type-ip)。

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
