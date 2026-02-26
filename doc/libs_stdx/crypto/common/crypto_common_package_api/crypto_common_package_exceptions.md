# 异常类

## class CryptoException

```cangjie
public class CryptoException <: Exception {
    public init()
    public init(message: String)
}
```

功能：此类为加解密出现错误时抛出的异常。

父类型：

- Exception

### init()

```cangjie
public init()
```

功能：无参构造函数，构造 [CryptoException](#class-cryptoexception) 异常。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    try {
        // 抛出一个无参的CryptoException异常
        throw CryptoException()
    } catch (e: CryptoException) {
        println("捕获到加解密异常")
    }
}
```

运行结果：

```text
捕获到加解密异常
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息构造 [CryptoException](#class-cryptoexception) 异常类对象。

参数：

- message: String - 异常信息。

示例：

<!-- verify -->
```cangjie
import stdx.crypto.common.*

main(): Unit {
    try {
        // 抛出一个带消息的CryptoException异常
        throw CryptoException("这是一个加密异常")
    } catch (e: CryptoException) {
        println("捕获到加密异常: ${e.message}")
    }
}
```

运行结果：

```text
捕获到加密异常: 这是一个加密异常
```
