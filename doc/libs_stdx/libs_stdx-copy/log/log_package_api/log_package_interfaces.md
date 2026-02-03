# 接口

## interface LogValue

```cangjie
public interface LogValue {
    func writeTo(w: LogWriter): Unit
}
```

功能：为类型提供序列化到日志输出目标的接口。

与 [LogWriter](log_package_classes.md#class-logwriter) 搭配使用， [LogWriter](log_package_classes.md#class-logwriter) 可以通过 writeValue 将实现了 [LogValue](log_package_interfaces.md#interface-logvalue) 接口的类型写入到日志输出目标中。

### func writeTo(LogWriter)

```cangjie
func writeTo(w: LogWriter): Unit
```

功能：将实现了 [LogValue](log_package_interfaces.md#interface-logvalue) 接口的类型写入参数 `w` 指定的 [LogWriter](log_package_classes.md#class-logwriter) 实例中。

参数：

- w:  [LogWriter](log_package_classes.md#class-logwriter) - 写入序列化结果的 [LogWriter](log_package_classes.md#class-logwriter) 实例。

### extend Bool <: LogValue

```cangjie
extend Bool <: LogValue
```

功能：为 Bool 类型实现 LogValue 接口。

父类型：

- [LogValue](#interface-logvalue)

#### func writeTo(LogWriter)

```cangjie
public func writeTo(w: LogWriter): Unit
```

功能：提供 Bool 类型序列化到流的功能。

参数：

- w:  [LogWriter](log_package_classes.md#class-logwriter) - 写入序列化结果的 [LogWriter](log_package_classes.md#class-logwriter) 实例。

示例：

<!-- verify -->
```cangjie
import stdx.log.*
import std.time.*

// 定义一个简单自定义的LogWriter实现用于演示，实际开发中请参考 samples 中示例
public class SimpleLogWriter <: LogWriter {
    var buffer = ""

    // 写入空值时，添加自定义内容
    public func writeNone(): Unit {
        buffer += " NONE "
    }
    // 写入整数时，添加自定义内容
    public func writeInt(v: Int64): Unit {
        buffer += "INT: ${v} "
    }
    // 写入布尔值时，添加自定义内容
    public func writeBool(v: Bool): Unit {
        buffer += "BOOL: ${v} "
    }
    // 写入浮点数时，添加自定义内容
    public func writeFloat(v: Float64): Unit {
        buffer += " FLOAT: ${v} "
    }
    // 写入字符串时，添加自定义内容
    public func writeString(v: String): Unit {
        buffer += " STRING: ${v} "
    }
    // 写入日期时间时，添加自定义内容
    public func writeDateTime(v: DateTime): Unit {
        buffer += " DATETIME: ${v} "
    }
    // 写入间隔时间时，添加自定义内容
    public func writeDuration(v: Duration): Unit {
        buffer += " DURATION: ${v} "
    }
    // 写入异常时，添加自定义内容
    public func writeException(v: Exception): Unit {
        buffer += " EXCEPTION: ${v.message} "
    }
    // 写入键时，添加自定义内容
    public func writeKey(v: String): Unit {
        buffer += " KEY: ${v} = "
    }
    // 写入值时，添加自定义内容
    public func writeValue(v: LogValue): Unit {
        v.writeTo(this)
    }
    // 写入数组时，添加自定义内容
    public func startArray(): Unit {
        buffer += "["
    }
    public func endArray(): Unit {
        buffer += "]"
    }
    // 写入对象时，添加自定义内容
    public func startObject(): Unit {
        buffer += "{"
    }
    public func endObject(): Unit {
        buffer += "}"
    }
}

main() {
    // 创建一个LogWriter实例
    let writer = SimpleLogWriter()

    Option<String>.Some("hello").writeTo(writer)
    123.writeTo(writer)
    true.writeTo(writer)
    3.14.writeTo(writer)
    "hello".writeTo(writer)
    DateTime.of(year: 2026, month: 1, dayOfMonth: 1, timeZone: TimeZone.UTC).writeTo(writer)
    Duration.second.writeTo(writer)
    Exception("异常信息").writeTo(writer)

    println("输出样式: ${writer.buffer}")

    return 0
}
```

运行结果：

```text
输出样式:  STRING: hello INT: 123 BOOL: true  FLOAT: 3.140000  STRING: hello  DATETIME: 2026-01-01T00:00:00Z  DURATION: 1s  EXCEPTION: 异常信息
```

### extend DateTime <: LogValue

```cangjie
extend DateTime <: LogValue
```

功能：为 DateTime 类型实现 LogValue 接口。

父类型：

- [LogValue](#interface-logvalue)

#### func writeTo(LogWriter)

```cangjie
public func writeTo(w: LogWriter): Unit
```

功能：提供 DateTime 类型序列化到流的功能。

参数：

- w:  [LogWriter](log_package_classes.md#class-logwriter) - 写入序列化结果的 [LogWriter](log_package_classes.md#class-logwriter) 实例。

示例：
<!-- associated_example -->
参见 [extend Bool](#extend-bool--logvalue) 示例。

### extend Duration <: LogValue

```cangjie
extend Duration <: LogValue
```

功能：为 Duration 类型实现 LogValue 接口。

父类型：

- [LogValue](#interface-logvalue)

#### func writeTo(LogWriter)

```cangjie
public func writeTo(w: LogWriter): Unit
```

功能：提供 Duration 类型序列化到流的功能。

参数：

- w:  [LogWriter](log_package_classes.md#class-logwriter) - 写入序列化结果的 [LogWriter](log_package_classes.md#class-logwriter) 实例。

示例：
<!-- associated_example -->
参见 [extend Bool](#extend-bool--logvalue) 示例。

### extend Exception <: LogValue

```cangjie
extend Exception <: LogValue
```

功能：为 Exception 类型实现 [LogValue](./log_package_interfaces.md#interface-logvalue) 接口。

父类型：

- [LogValue](#interface-logvalue)

#### func writeTo(LogWriter)

```cangjie
public func writeTo(w: LogWriter): Unit
```

功能：提供 Exception 类型序列化到流的功能。

参数：

- w:  [LogWriter](log_package_classes.md#class-logwriter) - 写入序列化结果的 [LogWriter](log_package_classes.md#class-logwriter) 实例。

示例：
<!-- associated_example -->
参见 [extend Bool](#extend-bool--logvalue) 示例。

### extend Float64 <: LogValue

```cangjie
extend Float64 <: LogValue
```

功能：为 Float64 类型实现 LogValue 接口。

父类型：

- [LogValue](#interface-logvalue)

#### func writeTo(LogWriter)

```cangjie
public func writeTo(w: LogWriter): Unit
```

功能：提供 Float64 类型序列化到流的功能。

参数：

- w:  [LogWriter](log_package_classes.md#class-logwriter) - 写入序列化结果的 [LogWriter](log_package_classes.md#class-logwriter) 实例。

示例：
<!-- associated_example -->
参见 [extend Bool](#extend-bool--logvalue) 示例。

### extend Int64 <: LogValue

```cangjie
extend Int64 <: LogValue
```

功能：为 Int64 类型实现 LogValue 接口。

父类型：

- [LogValue](#interface-logvalue)

#### func writeTo(LogWriter)

```cangjie
public func writeTo(w: LogWriter): Unit
```

功能：提供 Int64 类型序列化到流的功能。

参数：

- w:  [LogWriter](log_package_classes.md#class-logwriter) - 写入序列化结果的 [LogWriter](log_package_classes.md#class-logwriter) 实例。

示例：
<!-- associated_example -->
参见 [extend Bool](#extend-bool--logvalue) 示例。

### extend String <: LogValue

```cangjie
extend String <: LogValue
```

功能：为 String 类型实现 LogValue 接口。

父类型：

- [LogValue](#interface-logvalue)

#### func writeTo(LogWriter)

```cangjie
public func writeTo(w: LogWriter): Unit
```

功能：提供 String 类型序列化到流的功能。

参数：

- w:  [LogWriter](log_package_classes.md#class-logwriter) - 写入序列化结果的 [LogWriter](log_package_classes.md#class-logwriter) 实例。

示例：
<!-- associated_example -->
参见 [extend Bool](#extend-bool--logvalue) 示例。

### extend\<T> Array\<T> <: LogValue where T <: LogValue

```cangjie
extend<T> Array<T> <: LogValue where T <: LogValue
```

功能：为 Array\<T> 类型实现 LogValue 接口。

父类型：

- [LogValue](#interface-logvalue)

#### func writeTo(LogWriter)

```cangjie
public func writeTo(w: LogWriter): Unit
```

功能：提供 Array\<T> 类型序列化到流的功能。

参数：

- w:  [LogWriter](log_package_classes.md#class-logwriter) - 写入序列化结果的 [LogWriter](log_package_classes.md#class-logwriter) 实例。

示例：

<!-- verify -->
```cangjie
import stdx.log.*
import std.time.*

// 定义一个简单自定义的LogWriter实现用于演示，实际开发中请参考 samples 中示例
public class SimpleLogWriter <: LogWriter {
    var buffer = ""

    // 写入空值时，添加自定义内容
    public func writeNone(): Unit {
        buffer += " NONE "
    }
    // 写入整数时，添加自定义内容
    public func writeInt(v: Int64): Unit {
        buffer += "INT: ${v} "
    }
    // 写入布尔值时，添加自定义内容
    public func writeBool(v: Bool): Unit {
        buffer += "BOOL: ${v} "
    }
    // 写入浮点数时，添加自定义内容
    public func writeFloat(v: Float64): Unit {
        buffer += " FLOAT: ${v} "
    }
    // 写入字符串时，添加自定义内容
    public func writeString(v: String): Unit {
        buffer += " STRING: ${v} "
    }
    // 写入日期时间时，添加自定义内容
    public func writeDateTime(v: DateTime): Unit {
        buffer += " DATETIME: ${v} "
    }
    // 写入间隔时间时，添加自定义内容
    public func writeDuration(v: Duration): Unit {
        buffer += " DURATION: ${v} "
    }
    // 写入异常时，添加自定义内容
    public func writeException(v: Exception): Unit {
        buffer += " EXCEPTION: ${v.message} "
    }
    // 写入键时，添加自定义内容
    public func writeKey(v: String): Unit {
        buffer += " KEY: ${v} = "
    }
    // 写入值时，添加自定义内容
    public func writeValue(v: LogValue): Unit {
        v.writeTo(this)
    }
    // 写入数组时，添加自定义内容
    public func startArray(): Unit {
        buffer += "["
    }
    public func endArray(): Unit {
        buffer += "]"
    }
    // 写入对象时，添加自定义内容
    public func startObject(): Unit {
        buffer += "{"
    }
    public func endObject(): Unit {
        buffer += "}"
    }
}

main() {
    // 创建一个LogWriter实例
    let writer = SimpleLogWriter()

    // 创建一个Array实例
    let array: Array<LogValue> = [
        3.14,
        "hello",
        DateTime.of(year: 2026, month: 1, dayOfMonth: 1, timeZone: TimeZone.UTC),
        Duration.second,
        Exception("error"),
        Option<String>.None
    ]

    array.writeTo(writer)

    println("输出样式: ${writer.buffer}")

    return 0
}
```

运行结果：

```text
输出样式: [ FLOAT: 3.140000  STRING: hello  DATETIME: 2026-01-01T00:00:00Z  DURATION: 1s  EXCEPTION: error  NONE ]
```

### extend\<T> Option\<T> <: LogValue where T <: LogValue

```cangjie
extend<T> Option<T> <: LogValue where T <: LogValue
```

功能：为 Option\<T> 类型实现 LogValue 接口。

父类型：

- [LogValue](#interface-logvalue)

#### func writeTo(LogWriter)

```cangjie
public func writeTo(w: LogWriter): Unit
```

功能：提供 Option\<T> 类型序列化到流的功能。

参数：

- w:  [LogWriter](log_package_classes.md#class-logwriter) - 写入序列化结果的 [LogWriter](log_package_classes.md#class-logwriter) 实例。

示例：
<!-- associated_example -->
参见 [extend Bool](#extend-bool--logvalue) 示例。

### extend\<V> HashMap\<String, V> <: LogValue where V <: LogValue

```cangjie
extend<V> HashMap<String, V> <: LogValue where V <: LogValue
```

功能：为 HashMap\<K, V> 类型实现 LogValue 接口。

父类型：

- [LogValue](#interface-logvalue)

#### func writeTo(LogWriter)

```cangjie
public func writeTo(w: LogWriter): Unit
```

功能：提供 HashMap\<K, V> 类型序列化到流的功能。

参数：

- w:  [LogWriter](log_package_classes.md#class-logwriter) - 写入序列化结果的 [LogWriter](log_package_classes.md#class-logwriter) 实例。

示例：

<!-- verify -->
```cangjie
import stdx.log.*
import std.collection.*
import std.time.*

// 定义一个简单自定义的LogWriter实现用于演示，实际开发中请参考 samples 中示例
public class SimpleLogWriter <: LogWriter {
    var buffer = ""

    public func writeNone(): Unit {}

    // 写入整数时，添加自定义内容
    public func writeInt(v: Int64): Unit {
        buffer += "INT: ${v} "
    }
    public func writeBool(v: Bool): Unit {}
    public func writeFloat(v: Float64): Unit {}
    // 写入字符串时，添加自定义内容
    public func writeString(v: String): Unit {
        buffer += " STRING: ${v} "
    }
    public func writeDateTime(v: DateTime): Unit {}
    public func writeDuration(v: Duration): Unit {}
    public func writeException(v: Exception): Unit {}
    // 写入键时，添加自定义内容
    public func writeKey(v: String): Unit {
        buffer += " KEY: ${v} = "
    }
    // 写入值时，添加自定义内容
    public func writeValue(v: LogValue): Unit {
        v.writeTo(this)
    }
    public func startArray(): Unit {}
    public func endArray(): Unit {}
    // 写入对象时，添加自定义内容
    public func startObject(): Unit {
        buffer += "{"
    }
    public func endObject(): Unit {
        buffer += "}"
    }
}

main() {
    // 创建一个LogWriter实例
    let writer = SimpleLogWriter()

    // 创建一个HashMap实例
    let hashMap = HashMap<String, LogValue>([("HashMapKey", 123)])
    // 创建一个TreeMap实例
    let treeMap = TreeMap<String, LogValue>([("TreeMapKey", "TreeMapValue")])

    // 写入LogWriter
    hashMap.writeTo(writer)
    treeMap.writeTo(writer)

    println("输出样式: ${writer.buffer}")

    return 0
}
```

运行结果：

```text
输出样式: { KEY: HashMapKey = INT: 123 }{ KEY: TreeMapKey =  STRING: TreeMapValue }
```

### extend\<V> TreeMap\<String, V> <: LogValue where V <: LogValue

```cangjie
extend<V> TreeMap<String, V> <: LogValue where V <: LogValue
```

功能：为 TreeMap\<K, V> 类型实现 LogValue 接口。

父类型：

- [LogValue](#interface-logvalue)

#### func writeTo(LogWriter)

```cangjie
public func writeTo(w: LogWriter): Unit
```

功能：提供 TreeMap\<K, V> 类型序列化到流的功能。

参数：

- w:  [LogWriter](log_package_classes.md#class-logwriter) - 写入序列化结果的 [LogWriter](log_package_classes.md#class-logwriter) 实例。

示例：
<!-- associated_example -->
参见 [extend\<V> HashMap](#extendv-hashmapstring-v--logvalue-where-v--logvalue) 示例。
