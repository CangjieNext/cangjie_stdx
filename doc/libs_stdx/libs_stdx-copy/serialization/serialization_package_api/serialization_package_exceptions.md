# 异常类

## class DataModelException

```cangjie
public class DataModelException <: Exception {
    public init()
    public init(message: String)
}
```

功能：[DataModel](serialization_package_classes.md#class-datamodel) 的异常类。

父类型：

- Exception

### init()

```cangjie
public init()
```

功能：创建 [DataModelException](serialization_package_exceptions.md#class-datamodelexception) 实例。

示例：

<!-- verify -->
```cangjie
import stdx.serialization.serialization.*

main() {
    try {
        // 抛出无参异常
        throw DataModelException()
    } catch (e: DataModelException) {
        println("捕获到 DataModelException: ${e.message}")
    }

    return 0
}
```

运行结果：

```text
捕获到 DataModelException: 
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息创建 [DataModelException](serialization_package_exceptions.md#class-datamodelexception) 实例。

参数：

- message: String - 异常信息提示字符串。

示例：

<!-- verify -->
```cangjie
import stdx.serialization.serialization.*

main() {
    try {
        // 抛出带消息的异常
        throw DataModelException("这是一个异常信息")
    } catch (e: DataModelException) {
        println("捕获到 DataModelException: ${e.message}")
    }
    return 0
}
```

运行结果：

```text
捕获到 DataModelException: 这是一个异常信息
```
