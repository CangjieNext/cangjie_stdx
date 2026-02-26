# 异常类

## class SecureRandomException

```cangjie
public class SecureRandomException <: Exception {
    public init()
    public init(message: String)
}
```

功能：crypto 包安全随机数的异常类。

父类型：

- Exception

### init()

```cangjie
public init()
```

功能：创建默认的 [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) 实例，异常提示消息为空。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.crypto.*

main(): Unit {
    try {
        // 抛出一个无参的SecureRandomException异常
        throw SecureRandomException()
    } catch (e: SecureRandomException) {
        println("捕获到安全随机数异常")
    }
}
```

运行结果：

```text
捕获到安全随机数异常
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息创建 [SecureRandomException](crypto_package_exceptions.md#class-securerandomexception) 实例。

参数：

- message: String - 异常提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.crypto.*

main(): Unit {
    try {
        // 抛出一个带消息的SecureRandomException异常
        throw SecureRandomException("安全随机数生成失败")
    } catch (e: SecureRandomException) {
        println("捕获到安全随机数异常: ${e.message}")
    }
}
```

运行结果：

```text
捕获到安全随机数异常: 安全随机数生成失败
```
