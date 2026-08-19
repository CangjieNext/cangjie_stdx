# 异常类

## class TarException

```cangjie
public class TarException <: Exception {
    public init(message: String)
}
```

功能：tar 包的异常类。

父类型：

- Exception

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息创建 [TarException](tar_package_exceptions.md#class-tarexception) 实例。

参数：

- message: String - 异常提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.compress.tar.*

main(): Unit {
    try {
        throw TarException("This is a test exception")
    } catch (e: TarException) {
        println("捕获到 TarException: ${e.message}")
    }
}
```

运行结果：

```text
捕获到 TarException: This is a test exception
```
