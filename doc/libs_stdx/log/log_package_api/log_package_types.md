# 类型别名

## type Attr

```cangjie
public type Attr = (String, LogValue)
```

功能：日志消息的键值对类型，是 (String, [LogValue](./log_package_interfaces.md#interface-logvalue)) 的类型别名。

示例：

<!-- verify -->
```cangjie
import stdx.log.*
import std.time.*

main() {
    // 创建一个LogRecord实例
    let logRecord = LogRecord(DateTime.now(), LogLevel.INFO, "测试消息")

    // 获取当前的attrs属性
    println("原始attrs长度: ${logRecord.attrs.size}")

    // 指定attrs属性
    let attr: Attr = ("key", "value")
    let attr1: Attr = ("key1", 123)
    let attr2: (String, LogValue) = ("key2", true)

    // 检查attr2的类型
    println("attr2类型是 Attr: ${attr2 is Attr}")

    logRecord.attrs = [attr, attr1, attr2]
    println("修改后attrs长度: ${logRecord.attrs.size}")

    return 0
}
```

运行结果：

```text
原始attrs长度: 0
attr2类型是 Attr: true
修改后attrs长度: 3
```