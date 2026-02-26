# 异常类

## class LogException

```cangjie
public open class LogException <: Exception {
    public init()
    public init(message: String)
}
```

功能：用于处理 log 相关的异常。

父类型：

- Exception

### init()

```cangjie
public init()
```

功能：无参构造函数。

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main(): Unit {
    try {
        // 抛出一个无参的LogException异常
        throw LogException()
    } catch (e: LogException) {
        println("异常信息：${e.message}")
    }
}
```

运行结果：

```text
异常信息：
```

### init(String)

```cangjie
public init(message: String)
```

功能：根据异常信息创建 [LogException](log_package_exceptions.md#class-logexception) 实例。

参数：

- message: String - 异常信息。

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main(): Unit {
    try {
        // 抛出一个带消息的LogException异常
        throw LogException("日志异常")
    } catch (e: LogException) {
        println("异常信息: ${e.message}")
    }
}
```

运行结果：

```text
异常信息: 日志异常
```

### func getClassName()

```cangjie
protected override func getClassName(): String
```

功能：获得类名。

返回值：

- String - 类名。

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 创建一个MyException实例
    let exception = MyException()

    // 调用getClassName函数获取类名
    let className = exception.myGetClassName()
    println("类名: ${className}")
}

// 子类可以调用父类的保护方法
class MyException <: LogException {
    func myGetClassName(): String {
        return getClassName()
    }
}
```

运行结果：

```text
类名: LogException
```
