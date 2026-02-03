# 结构体

## struct LogLevel

```cangjie
public struct LogLevel <: ToString & Comparable<LogLevel> {
    public static const OFF: LogLevel = LogLevel("OFF", 0x7FFF_FFFF)
    public static const FATAL: LogLevel = LogLevel("FATAL", 6000)
    public static const ERROR: LogLevel = LogLevel("ERROR", 5000)
    public static const WARN: LogLevel = LogLevel("WARN", 4000)
    public static const INFO: LogLevel = LogLevel("INFO", 3000)
    public static const DEBUG: LogLevel = LogLevel("DEBUG", 2000)
    public static const TRACE: LogLevel = LogLevel("TRACE", 1000)
    public static const ALL: LogLevel = LogLevel("ALL", -0x8000_0000)
    public let name: String
    public let value: Int32
    public const init(name: String, value: Int32)
}
```

功能：[LogLevel](log_package_structs.md#struct-loglevel) 为日志级别结构体。

定义了日志打印的七个级别，级别从高到低分别为 `OFF`、 `FATAL`、`ERROR`、`WARN`、`INFO`、`DEBUG`、`TRACE`、`ALL`。

我们期望只有级别大于等于指定打印级别的日志条目会被打印到输出流中。

父类型：

- ToString
- Comparable\<[LogLevel](#struct-loglevel)>

### static const ALL

```cangjie
public static const ALL: LogLevel = LogLevel("ALL", -0x8000_0000)
```

功能：获取一个日志打印级别的静态常量实例，等级为所有。

类型：[LogLevel](#struct-loglevel)

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 获取ALL日志级别常量
    let allLevel = LogLevel.ALL

    println("ALL日志级别名称: ${allLevel.name}")
    println("ALL日志级别值: ${allLevel.value}")

    return 0
}
```

运行结果：

```text
ALL日志级别名称: ALL
ALL日志级别值: -2147483648
```

### static const DEBUG

```cangjie
public static const DEBUG: LogLevel = LogLevel("DEBUG", 2000)
```

功能：获取一个日志打印级别的静态常量实例，等级为调试。

类型：[LogLevel](#struct-loglevel)

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 获取DEBUG日志级别常量
    let debugLevel = LogLevel.DEBUG

    println("DEBUG日志级别名称: ${debugLevel.name}")
    println("DEBUG日志级别值: ${debugLevel.value}")

    return 0
}
```

运行结果：

```text
DEBUG日志级别名称: DEBUG
DEBUG日志级别值: 2000
```

### static const ERROR

```cangjie
public static const ERROR: LogLevel = LogLevel("ERROR", 5000)
```

功能：获取一个日志打印级别的静态常量实例，等级为错误。

类型：[LogLevel](#struct-loglevel)

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 获取ERROR日志级别常量
    let errorLevel = LogLevel.ERROR

    println("ERROR日志级别名称: ${errorLevel.name}")
    println("ERROR日志级别值: ${errorLevel.value}")

    return 0
}
```

运行结果：

```text
ERROR日志级别名称: ERROR
ERROR日志级别值: 5000
```

### static const FATAL

```cangjie
public static const FATAL: LogLevel = LogLevel("FATAL", 6000)
```

功能：获取一个日志打印级别的静态常量实例，等级为严重错误。

类型：[LogLevel](#struct-loglevel)

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 获取FATAL日志级别常量
    let fatalLevel = LogLevel.FATAL

    println("FATAL日志级别名称: ${fatalLevel.name}")
    println("FATAL日志级别值: ${fatalLevel.value}")

    return 0
}
```

运行结果：

```text
FATAL日志级别名称: FATAL
FATAL日志级别值: 6000
```

### static const INFO

```cangjie
public static const INFO: LogLevel = LogLevel("INFO", 3000)
```

功能：获取一个日志打印级别的静态常量实例，等级为通知。

类型：[LogLevel](#struct-loglevel)

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 获取INFO日志级别常量
    let infoLevel = LogLevel.INFO

    println("INFO日志级别名称: ${infoLevel.name}")
    println("INFO日志级别值: ${infoLevel.value}")

    return 0
}
```

运行结果：

```text
INFO日志级别名称: INFO
INFO日志级别值: 3000
```

### static const OFF

```cangjie
public static const OFF: LogLevel = LogLevel("OFF", 0x7FFF_FFFF)
```

功能：获取一个日志打印级别的静态常量实例，等级为禁用。

类型：[LogLevel](#struct-loglevel)

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 获取OFF日志级别常量
    let offLevel = LogLevel.OFF

    println("OFF日志级别名称: ${offLevel.name}")
    println("OFF日志级别值: ${offLevel.value}")

    return 0
}
```

运行结果：

```text
OFF日志级别名称: OFF
OFF日志级别值: 2147483647
```

### static const TRACE

```cangjie
public static const TRACE: LogLevel = LogLevel("TRACE", 1000)
```

功能：获取一个日志打印级别的静态常量实例，等级为跟踪。

类型：[LogLevel](#struct-loglevel)

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 获取TRACE日志级别常量
    let traceLevel = LogLevel.TRACE

    println("TRACE日志级别名称: ${traceLevel.name}")
    println("TRACE日志级别值: ${traceLevel.value}")

    return 0
}
```

运行结果：

```text
TRACE日志级别名称: TRACE
TRACE日志级别值: 1000
```

### static const WARN

```cangjie
public static const WARN: LogLevel = LogLevel("WARN", 4000)
```

功能：获取一个日志打印级别的静态常量实例，等级为警告。

类型：[LogLevel](#struct-loglevel)

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 获取WARN日志级别常量
    let warnLevel = LogLevel.WARN

    println("WARN日志级别名称: ${warnLevel.name}")
    println("WARN日志级别值: ${warnLevel.value}")

    return 0
}
```

运行结果：

```text
WARN日志级别名称: WARN
WARN日志级别值: 4000
```

### let name

```cangjie
public let name: String
```

功能：日志级别名。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 获取一个日志级别常量
    let level = LogLevel.INFO

    // 访问name属性
    let name = level.name

    println("日志级别名称: ${name}")

    return 0
}
```

运行结果：

```text
日志级别名称: INFO
```

### let value

```cangjie
public let value: Int32
```

功能：日志级别值。

类型：Int32

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 获取一个日志级别常量
    let level = LogLevel.WARN

    // 访问value属性
    let value = level.value

    println("日志级别值: ${value}")

    return 0
}
```

运行结果：

```text
日志级别值: 4000
```

### const init(String, Int32)

```cangjie
public const init(name: String, value: Int32)
```

功能：常量构造函数，创建 LogLevel 对象。

参数：

- name: String - 日志级别名。
- value: Int32 - 日志级别值。

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 使用构造函数创建自定义LogLevel
    let customLevel = LogLevel("CUSTOM", 1500)

    println("自定义日志级别名称: ${customLevel.name}")
    println("自定义日志级别值: ${customLevel.value}")

    return 0
}
```

运行结果：

```text
自定义日志级别名称: CUSTOM
自定义日志级别值: 1500
```

### func compare(LogLevel)

```cangjie
public func compare(rhs: LogLevel): Ordering
```

功能：判断当前 [LogLevel](log_package_structs.md#struct-loglevel) 类型实例与参数指向的 [LogLevel](log_package_structs.md#struct-loglevel) 类型实例的大小关系。

参数：

- rhs: [LogLevel](log_package_structs.md#struct-loglevel) - 待与当前实例比较的另一个实例。

返回值：

- Ordering - 如果大于，返回 Ordering.GT，如果等于，返回 Ordering.EQ，如果小于，返回 Ordering.LT。

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 创建两个日志级别实例
    let level1 = LogLevel.INFO
    let level2 = LogLevel.WARN

    // 比较两个日志级别
    let comparison = level1.compare(level2)

    println("INFO与WARN的比较结果: ${comparison}")

    return 0
}
```

运行结果：

```text
INFO与WARN的比较结果: Ordering.LT
```

### func toString()

```cangjie
public func toString(): String
```

功能：获取日志级别对应的名称。

返回值：

- String - 当前的日志级别的名称。

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 获取一个日志级别常量
    let level = LogLevel.ERROR

    // 调用toString方法获取名称
    let name = level.toString()

    println("ERROR日志级别的字符串表示: ${name}")

    return 0
}
```

运行结果：

```text
ERROR日志级别的字符串表示: ERROR
```

### operator func !=(LogLevel)

```cangjie
public operator func !=(rhs: LogLevel): Bool
```

功能：比较日志级别高低。

参数：

- rhs: [LogLevel](log_package_structs.md#struct-loglevel) - 将当前日志级别和 `target` 进行比较。

返回值：

- Bool - 如果当前日志级别不等于 `target`，返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 创建两个不同的日志级别
    let level1 = LogLevel.INFO
    let level2 = LogLevel.WARN

    // 使用!=操作符比较
    let notEqual = level1 != level2

    println("INFO不等于WARN: ${notEqual}")

    // 创建两个相同的日志级别
    let level3 = LogLevel.INFO
    let level4 = LogLevel.INFO

    // 使用!=操作符比较
    let equalNot = level3 != level4

    println("INFO不等于INFO: ${equalNot}")

    return 0
}
```

运行结果：

```text
INFO不等于WARN: true
INFO不等于INFO: false
```

### operator func <(LogLevel)

```cangjie
public operator func <(rhs: LogLevel): Bool
```

功能：比较日志级别高低。

参数：

- rhs: [LogLevel](log_package_structs.md#struct-loglevel) - 将当前日志级别和 `target` 进行比较。

返回值：

- Bool - 如果当前日志级别小于 `target`，返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 创建两个日志级别
    let level1 = LogLevel.INFO
    let level2 = LogLevel.WARN

    // 使用<操作符比较
    let lessThan = level1 < level2

    println("INFO小于WARN: ${lessThan}")

    // 再次比较
    let greaterOrEqual = level2 < level1

    println("WARN小于INFO: ${greaterOrEqual}")

    return 0
}
```

运行结果：

```text
INFO小于WARN: true
WARN小于INFO: false
```

### operator func <=(LogLevel)

```cangjie
public operator func <=(rhs: LogLevel): Bool
```

功能：比较日志级别高低。

参数：

- rhs: [LogLevel](log_package_structs.md#struct-loglevel) - 将当前日志级别和 `target` 进行比较。

返回值：

- Bool - 如果当前日志级别小于等于 `target`，返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 创建两个日志级别
    let level1 = LogLevel.INFO
    let level2 = LogLevel.WARN

    // 使用<=操作符比较
    let lessThanOrEqual = level1 <= level2

    println("INFO小于等于WARN: ${lessThanOrEqual}")

    // 比较相同级别
    let level3 = LogLevel.INFO
    let level4 = LogLevel.INFO

    // 使用<=操作符比较相同级别
    let sameLevel = level3 <= level4

    println("INFO小于等于INFO: ${sameLevel}")

    return 0
}
```

运行结果：

```text
INFO小于等于WARN: true
INFO小于等于INFO: true
```

### operator func ==(LogLevel)

```cangjie
public operator func ==(rhs: LogLevel): Bool
```

功能：比较日志级别高低。

参数：

- rhs: [LogLevel](log_package_structs.md#struct-loglevel) - 将当前日志级别和 `target` 进行比较。

返回值：

- Bool - 如果当前日志级别等于 `target`，返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 创建两个相同的日志级别
    let level1 = LogLevel.INFO
    let level2 = LogLevel.INFO

    // 使用==操作符比较
    let isEqual = level1 == level2

    println("INFO等于INFO: ${isEqual}")

    // 创建两个不同的日志级别
    let level3 = LogLevel.INFO
    let level4 = LogLevel.WARN

    // 使用==操作符比较
    let notEqual = level3 == level4

    println("INFO等于WARN: ${notEqual}")

    return 0
}
```

运行结果：

```text
INFO等于INFO: true
INFO等于WARN: false
```

### operator func >(LogLevel)

```cangjie
public operator func >(rhs: LogLevel): Bool
```

功能：比较日志级别高低。

参数：

- rhs: [LogLevel](log_package_structs.md#struct-loglevel) - 将当前日志级别和 `target` 进行比较。

返回值：

- Bool - 如果当前日志级别大于 `target`，返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 创建两个日志级别
    let level1 = LogLevel.WARN
    let level2 = LogLevel.INFO

    // 使用>操作符比较
    let greaterThan = level1 > level2

    println("WARN大于INFO: ${greaterThan}")

    // 再次比较
    let lessOrEqual = level2 > level1

    println("INFO大于WARN: ${lessOrEqual}")

    return 0
}
```

运行结果：

```text
WARN大于INFO: true
INFO大于WARN: false
```

### operator func >=(LogLevel)

```cangjie
public operator func >=(rhs: LogLevel): Bool
```

功能：比较日志级别高低。

参数：

- rhs: [LogLevel](log_package_structs.md#struct-loglevel) - 将当前日志级别和 `target` 进行比较。

返回值：

- Bool - 如果当前日志级别大于等于 `target`，返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.log.*

main() {
    // 创建两个日志级别
    let level1 = LogLevel.WARN
    let level2 = LogLevel.INFO

    // 使用>=操作符比较
    let greaterThanOrEqual = level1 >= level2

    println("WARN大于等于INFO: ${greaterThanOrEqual}")

    // 比较相同级别
    let level3 = LogLevel.INFO
    let level4 = LogLevel.INFO

    // 使用>=操作符比较相同级别
    let sameLevel = level3 >= level4

    println("INFO大于等于INFO: ${sameLevel}")

    return 0
}
```

运行结果：

```text
WARN大于等于INFO: true
INFO大于等于INFO: true
```
