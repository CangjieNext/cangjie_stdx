# 异常类

## class X509Exception

```cangjie
public class X509Exception <: Exception {
    public init()
    public init(message: String)
}
```

功能：此异常为 X509 包抛出的异常类型。

父类型：

- Exception

### init()

```cangjie
public init()
```

功能：构造 [X509Exception](x509_package_exceptions.md#class-x509exception) 对象。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    try {
        // 抛出一个无参的X509Exception异常
        throw X509Exception()
    } catch (e: X509Exception) {
        println("捕获到X509异常: ${e}")
    }
}
```

运行结果：

```text
捕获到X509异常: X509Exception
```

### init(String)

```cangjie
public init(message: String)
```

功能：构造 [X509Exception](x509_package_exceptions.md#class-x509exception) 对象。

参数：

- message: String - 异常的信息。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.x509.*

main() {
    try {
        // 抛出一个带消息的X509Exception异常
        throw X509Exception("证书验证失败")
    } catch (e: X509Exception) {
        println("捕获到X509异常: ${e}")
    }
}
```

运行结果：

```text
捕获到X509异常: X509Exception: 证书验证失败
```
