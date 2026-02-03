# 函数

## func getGlobalLogger(Array\<Attr>)

```cangjie
public func getGlobalLogger(attrs: Array<Attr>): Logger
```

功能：获取 [Logger](log_package_classes.md#class-logger) 对象。

> **说明：**
>
> 如果未传入 attrs 参数，那么获取的是同一个 [Logger](log_package_classes.md#class-logger) 对象，传入了 attrs 参数，则创建一个包含指定的属性的  [Logger](log_package_classes.md#class-logger) 对象副本。

参数：

- attrs: Array\<[Attr](log_package_types.md#type-attr)> - 日志数据键值对属性，获取的 [Logger](log_package_classes.md#class-logger) 对象会包含这些属性。

返回值：

- [Logger](log_package_classes.md#class-logger) - [Logger](log_package_classes.md#class-logger) 类的对象实例。

示例：

<!-- run -->
```cangjie
import stdx.log.*
import stdx.logger.*
import std.env.*

main() {
    // 创建一个SimpleLogger（抽象类Logger的实现类）实例
    let logger = SimpleLogger(getStdOut())

    // 设置全局日志记录器
    println("提示：未设置全局日志记录器之前所有的日志事件都将被忽略")
    setGlobalLogger(logger)

    // 获取全局日志记录器（不带属性）
    let globalLogger = getGlobalLogger()
    globalLogger.warn("无属性日志打印")

    // 获取带属性的全局日志记录器
    let attrLogger = getGlobalLogger([("module", "main"), ("version", "1.0")])
    attrLogger.warn("带属性日志打印")

    return 0
}
```

可能的运行结果：

```text
提示：未设置全局日志记录器之前所有的日志事件都将被忽略
2026-01-14T10:16:02.144486114+08:00 WARN 无属性日志打印 
2026-01-14T10:16:02.144587908+08:00 WARN 带属性日志打印 module="main" version="1.0"
```

## func setGlobalLogger(Logger)

```cangjie
public func setGlobalLogger(logger: Logger): Unit
```

功能：设置全局 [Logger](log_package_classes.md#class-logger) 对象。

> **注意：**
>
> - 此函数在程序的生命周期中只应该被调用一次。对 setGlobalLogger 的调用完成之前发生的任何日志事件都将被忽略。
> - 此函数通常不需要手动调用。日志实现提供者应提供包含了调用本方法的的初始化方法。

参数：

- logger: [Logger](log_package_classes.md#class-logger) - 实现了 [Logger](log_package_classes.md#class-logger) 类的对象实例。

示例：

<!-- run -->
```cangjie
import stdx.log.*
import stdx.logger.*
import std.env.*

main() {
    // 获取全局日志记录器（未设置）
    let globalLogger = getGlobalLogger()
    globalLogger.warn("不会被打印！！")

    // 创建一个SimpleLogger（抽象类Logger的实现类）实例
    let logger = SimpleLogger(getStdOut())

    // 设置全局日志记录器
    println("提示：未设置全局日志记录器之前所有的日志事件都将被忽略")
    setGlobalLogger(logger)

    // 获取无属性的全局日志记录器
    let attrLogger = getGlobalLogger()
    attrLogger.warn("日志打印")

    return 0
}
```

可能的运行结果：

```text
提示：未设置全局日志记录器之前所有的日志事件都将被忽略
2026-01-14T10:18:57.993352204+08:00 WARN 日志打印
```
