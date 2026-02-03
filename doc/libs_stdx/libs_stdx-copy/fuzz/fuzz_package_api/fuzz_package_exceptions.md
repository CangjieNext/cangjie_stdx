# 异常类

## class ExhaustedException

```cangjie
public class ExhaustedException <: Exception {
    public init()
    public init(message: String)
}
```

功能：此异常为转换数据时，剩余数据不足以转换时抛出的异常。

> **注意：**
>
> 不支持平台：Windows。

父类型：

- Exception

### init()

```cangjie
public init()
```

功能：创建 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception) 实例。

> **注意：**
>
> 不支持平台：Windows。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main(): Unit {
    try {
        throw ExhaustedException()
    } catch (e: ExhaustedException) {
        println("捕获到无参构造的 ExhaustedException: ${e.message}")
    }
}
```

运行结果：

```text
捕获到无参构造的 ExhaustedException:
```

### init(String)

```cangjie
public init(message: String)
```

功能：创建 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception) 实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- message: String - 异常提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main(): Unit {
    try {
        throw ExhaustedException("剩余数据不足")
    } catch (e: ExhaustedException) {
        println("捕获到 ExhaustedException: ${e.message}")
    }
}
```

运行结果：

```text
捕获到 ExhaustedException: 剩余数据不足
```
