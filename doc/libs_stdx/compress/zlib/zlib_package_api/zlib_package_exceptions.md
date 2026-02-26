# 异常类

## class ZlibException

```cangjie
public class ZlibException <: Exception {
    public init(message: String)
}
```

功能：zlib 包的异常类。

父类型：

- Exception

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息创建 [ZlibException](zlib_package_exceptions.md#class-zlibexception) 实例。

参数：

- message: String - 异常提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.compress.zlib.*

main(): Unit {
    try {
        throw ZlibException("This is a test exception.")
    } catch (e: ZlibException) {
        println("捕获到 ZlibException: ${e.message}")
    }
}
```

运行结果：

```text
捕获到 ZlibException: This is a test exception.
```
