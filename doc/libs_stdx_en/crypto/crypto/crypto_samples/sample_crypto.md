# SM4 Usage

SM4 encrypts and decrypts data.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::crypto.crypto.*

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

Execution Result:

```text
hello cangjie!
```