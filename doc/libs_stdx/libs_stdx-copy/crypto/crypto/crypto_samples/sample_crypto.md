# SM4 使用

SM4 加解密数据。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.crypto.*

main() {
    var plains = "hello cangjie!"
    var key = "YOUR_KEYYYYYYYYY" // 16 bytes key for SM4
    var iv = "YOUR_IVVVVVVVVVV" // 16 bytes IV for CBC mode
    var sm4 = SM4(OperationMode.CBC, key.toArray(), iv: iv.toArray())
    var enRe = sm4.encrypt(plains.toArray())
    var dd = sm4.decrypt(enRe)
    println(String.fromUtf8(dd))
}
```

运行结果：

```text
hello cangjie!
```
