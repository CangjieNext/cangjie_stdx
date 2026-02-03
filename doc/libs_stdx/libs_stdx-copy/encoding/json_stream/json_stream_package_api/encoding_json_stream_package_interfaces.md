# 接口

## interface JsonDeserializable\<T>

```cangjie
public interface JsonDeserializable<T> {
    static func fromJson(r: JsonReader): T
}
```

功能：此接口用于实现从 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个仓颉对象。

支持的对象类型包括：

- 基本数据类型：整数类型、浮点类型、布尔类型、字符串类型。

- Collection 类型：Array、ArrayList、HashMap、Option。

- BigInt、Decimal 类型。

- DateTime 类型。

### static func fromJson(JsonReader)

```cangjie
static func fromJson(r: JsonReader): T
```

功能：从参数 `r` 指定的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例中读取一个 `T` 类型对象。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- T - `T` 类型的实例。

异常：

- IllegalStateException - 如果输入流的 JSON 数据不符合格式，抛出异常。

### extend BigInt <: JsonDeserializable\<BigInt>

```cangjie
extend BigInt <: JsonDeserializable<BigInt>
```

功能：为 BigInt 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<BigInt>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): BigInt
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 BigInt。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- BigInt - BigInt 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.math.numeric.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个BigInt值作为示例数据 
    let originalBigInt: BigInt = BigInt(1234567890123456789)
    originalBigInt.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取BigInt对象 
    let bigIntValue: BigInt = BigInt.fromJson(reader)

    println("BigInt反序列化结果: ${bigIntValue}")
}
```

运行结果：

```text
BigInt反序列化结果: 1234567890123456789
```

### extend Bool <: JsonDeserializable\<Bool>

```cangjie
extend Bool <: JsonDeserializable<Bool>
```

功能：为 Bool 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<Bool>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): Bool
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 Bool。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- Bool - Bool 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个Bool值作为示例数据 
    let originalBool: Bool = true
    originalBool.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取Bool对象 
    let boolValue: Bool = Bool.fromJson(reader)

    println("Bool反序列化结果: ${boolValue}")
}
```

运行结果：

```text
Bool反序列化结果: true
```

### extend DateTime <: JsonDeserializable\<DateTime>

```cangjie
extend DateTime <: JsonDeserializable<DateTime>
```

功能：为 DateTime 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<DateTime>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): DateTime
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 DateTime 实例。

该函数将会把读取到的字符串按照 `RFC3339` 的规范解析，可包含小数秒格式，函数的行为参考 DateTime 的 func parse(String)。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- DateTime - DateTime 类型的实例。

异常：

- TimeParseException - 无法正常解析时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.io.*
import std.time.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个DateTime值作为示例数据 
    let originalDateTime: DateTime = DateTime.of(year: 2026, month: 1, dayOfMonth: 7)
    originalDateTime.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取DateTime对象 
    let dateTimeValue: DateTime = DateTime.fromJson(reader)

    println("DateTime反序列化结果: ${dateTimeValue}")
}
```

可能的运行结果：

```text
DateTime反序列化结果: 2026-01-07T00:00:00+08:00
```

### extend Decimal <: JsonDeserializable\<Decimal>

```cangjie
extend Decimal <: JsonDeserializable<Decimal>
```

功能：为 Decimal 类型实现 [JsonDeserializable](./encoding_json_stream_package_interfaces.md#interface-jsondeserializablet) 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<Decimal>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): Decimal
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 Decimal。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- Decimal - Decimal 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.math.numeric.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个Decimal值作为示例数据 
    let originalDecimal: Decimal = Decimal.parse("123.456")
    originalDecimal.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取Decimal对象 
    let decimalValue: Decimal = Decimal.fromJson(reader)

    println("Decimal反序列化结果: ${decimalValue}")
}
```

运行结果：

```text
Decimal反序列化结果: 123.456
```

### extend Float16 <: JsonDeserializable\<Float16>

```cangjie
extend Float16 <: JsonDeserializable<Float16>
```

功能：为 Float16 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<Float16>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): Float16
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 Float16。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- Float16 - Float16 类型的实例。

异常：

- OverflowException - 读取的数据超过范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个Float16值作为示例数据 
    let originalFloat16: Float16 = 123.45f16
    originalFloat16.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取Float16对象 
    let floatValue: Float16 = Float16.fromJson(reader)

    println("Float16反序列化结果: ${floatValue}")
}
```

运行结果：

```text
Float16反序列化结果: 123.437500
```

### extend Float32 <: JsonDeserializable\<Float32>

```cangjie
extend Float32 <: JsonDeserializable<Float32>
```

功能：为 Float32 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<Float32>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): Float32
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 Float32。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- Float32 - Float32 类型的实例。

异常：

- OverflowException - 读取的数据超过范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个Float32值作为示例数据 
    let originalFloat32: Float32 = 123.45f32
    originalFloat32.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取Float32对象 
    let floatValue: Float32 = Float32.fromJson(reader)

    println("Float32反序列化结果: ${floatValue}")
}
```

运行结果：

```text
Float32反序列化结果: 123.449997
```

### extend Float64 <: JsonDeserializable\<Float64>

```cangjie
extend Float64 <: JsonDeserializable<Float64>
```

功能：为 Float64 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<Float64>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): Float64
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 Float64。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- Float64 - Float64 类型的实例。

异常：

- OverflowException - 读取的数据超过范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个Float64值作为示例数据 
    let originalFloat64: Float64 = 123.45f64
    originalFloat64.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取Float64对象 
    let floatValue: Float64 = Float64.fromJson(reader)

    println("Float64反序列化结果: ${floatValue}")
}
```

运行结果：

```text
Float64反序列化结果: 123.450000
```

### extend Int16 <: JsonDeserializable\<Int16>

```cangjie
extend Int16 <: JsonDeserializable<Int16>
```

功能：为 Int16 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<Int16>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): Int16
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 Int16。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- Int16 - Int16 类型的实例。

异常：

- OverflowException - 读取的数据超过范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个Int16值作为示例数据 
    let originalInt16: Int16 = 12345
    originalInt16.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取Int16对象 
    let intValue: Int16 = Int16.fromJson(reader)

    println("Int16反序列化结果: ${intValue}")
}
```

运行结果：

```text
Int16反序列化结果: 12345
```

### extend Int32 <: JsonDeserializable\<Int32>

```cangjie
extend Int32 <: JsonDeserializable<Int32>
```

功能：为 Int32 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<Int32>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): Int32
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 Int32。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- Int32 - Int32 类型的实例。

异常：

- OverflowException - 读取的数据超过范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个Int32值作为示例数据 
    let originalInt32: Int32 = 1234567890
    originalInt32.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取Int32对象 
    let intValue: Int32 = Int32.fromJson(reader)

    println("Int32反序列化结果: ${intValue}")
}
```

运行结果：

```text
Int32反序列化结果: 1234567890
```

### extend Int64 <: JsonDeserializable\<Int64>

```cangjie
extend Int64 <: JsonDeserializable<Int64>
```

功能：为 Int64 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<Int64>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): Int64
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 Int64。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- Int64 - Int64 类型的实例。

异常：

- OverflowException - 读取的数据超过范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个Int64值作为示例数据 
    let originalInt64: Int64 = 1234567890123456789
    originalInt64.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取Int64对象 
    let intValue: Int64 = Int64.fromJson(reader)

    println("Int64反序列化结果: ${intValue}")
}
```

运行结果：

```text
Int64反序列化结果: 1234567890123456789
```

### extend Int8 <: JsonDeserializable\<Int8>

```cangjie
extend Int8 <: JsonDeserializable<Int8>
```

功能：为 Int8 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<Int8>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): Int8
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 Int8。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- Int8 - Int8 类型的实例。

异常：

- OverflowException - 读取的数据超过范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个Int8值作为示例数据 
    let originalInt8: Int8 = 123
    originalInt8.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取Int8对象 
    let intValue: Int8 = Int8.fromJson(reader)

    println("Int8反序列化结果: ${intValue}")
}
```

运行结果：

```text
Int8反序列化结果: 123
```

### extend IntNative <: JsonDeserializable\<IntNative>

```cangjie
extend IntNative <: JsonDeserializable<IntNative>
```

功能：为 IntNative 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<IntNative>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): IntNative
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 IntNative。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- IntNative - IntNative 类型的实例。

异常：

- OverflowException - 读取的数据超过范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个IntNative值作为示例数据 
    let originalIntNative: IntNative = 123456789
    originalIntNative.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取IntNative对象 
    let intValue: IntNative = IntNative.fromJson(reader)

    println("IntNative反序列化结果: ${intValue}")
}
```

运行结果：

```text
IntNative反序列化结果: 123456789
```

### extend String <: JsonDeserializable\<String>

```cangjie
extend String <: JsonDeserializable<String>
```

功能：为 String 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<String>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): String
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 String。

根据下一个 `JsonToken` 的不同，`String` 的反序列化结果将会不同：

- 当下一个 `JsonToken` 是 `JsonString` 时， 反序列化过程会按照标准[ECMA-404 The JSON Data Interchange Standard](https://www.ecma-international.org/publications-and-standards/standards/ecma-404/)对读到的 `String` 进行转义。
- 当下一个 `JsonToken` 是 `JsonNumber` `JsonBool` `JsonNull` 其中一个时，将会读取下一个 `value` 字段的原始字符串并返回。
- 当下一个 `JsonToken` 是其它类型时，调用此接口会抛异常。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- String - String 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个String值作为示例数据 
    let originalString: String = "Hello, World!"
    originalString.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取String对象 
    let stringValue: String = String.fromJson(reader)

    println("String反序列化结果: ${stringValue}")
}
```

运行结果：

```text
String反序列化结果: Hello, World!
```

### extend UInt16 <: JsonDeserializable\<UInt16>

```cangjie
extend UInt16 <: JsonDeserializable<UInt16>
```

功能：为 UInt16 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<UInt16>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): UInt16
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 UInt16。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- UInt16 - UInt16 类型的实例。

异常：

- OverflowException - 读取的数据超过范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个UInt16值作为示例数据 
    let originalUInt16: UInt16 = 65432
    originalUInt16.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取UInt16对象 
    let uintValue: UInt16 = UInt16.fromJson(reader)

    println("UInt16反序列化结果: ${uintValue}")
}
```

运行结果：

```text
UInt16反序列化结果: 65432
```

### extend UInt32 <: JsonDeserializable\<UInt32>

```cangjie
extend UInt32 <: JsonDeserializable<UInt32>
```

功能：为 UInt32 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<UInt32>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): UInt32
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 UInt32。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- UInt32 - UInt32 类型的实例。

异常：

- OverflowException - 读取的数据超过范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个UInt32值作为示例数据 
    let originalUInt32: UInt32 = 3214567890
    originalUInt32.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取UInt32对象 
    let uintValue: UInt32 = UInt32.fromJson(reader)

    println("UInt32反序列化结果: ${uintValue}")
}
```

运行结果：

```text
UInt32反序列化结果: 3214567890
```

### extend UInt64 <: JsonDeserializable\<UInt64 >

```cangjie
extend UInt64 <: JsonDeserializable<UInt64>
```

功能：为 UInt64 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<UInt64>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): UInt64
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 UInt64。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- UInt64 - UInt64 类型的实例。

异常：

- OverflowException - 读取的数据超过范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个UInt64值作为示例数据 
    let originalUInt64: UInt64 = 1234567890123456789
    originalUInt64.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取UInt64对象 
    let uintValue: UInt64 = UInt64.fromJson(reader)

    println("UInt64反序列化结果: ${uintValue}")
}
```

运行结果：

```text
UInt64反序列化结果: 1234567890123456789
```

### extend UInt8 <: JsonDeserializable\<UInt8>

```cangjie
extend UInt8 <: JsonDeserializable<UInt8>
```

功能：为 UInt8 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<UInt8>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): UInt8
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 UInt8。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- UInt8 - UInt8 类型的实例。

异常：

- OverflowException - 读取的数据超过范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个UInt8值作为示例数据 
    let originalUInt8: UInt8 = 255
    originalUInt8.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取UInt8对象 
    let uintValue: UInt8 = UInt8.fromJson(reader)

    println("UInt8反序列化结果: ${uintValue}")
}
```

运行结果：

```text
UInt8反序列化结果: 255
```

### extend UIntNative <: JsonDeserializable\<UIntNative>

```cangjie
extend UIntNative <: JsonDeserializable<UIntNative>
```

功能：为 UIntNative 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<UIntNative>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): UIntNative
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 UIntNative。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- UIntNative - UIntNative 类型的实例。

异常：

- OverflowException - 读取的数据超过范围时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个UIntNative值作为示例数据 
    let originalUIntNative: UIntNative = 987654321
    originalUIntNative.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取UIntNative对象 
    let uintValue: UIntNative = UIntNative.fromJson(reader)

    println("UIntNative反序列化结果: ${uintValue}")
}
```

运行结果：

```text
UIntNative反序列化结果: 987654321
```

### extend\<T> Array\<T> <: JsonDeserializable\<Array\<T>> where T <: JsonDeserializable\<T>

```cangjie
extend<T> Array<T> <: JsonDeserializable<Array<T>> where T <: JsonDeserializable<T>
```

功能：为 Array\<T> 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<Array\<T>>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): Array<T>
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 Array。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- Array\<T> - Array 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonReader 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个Array值作为示例数据 
    let originalArray: Array<Int64> = [1, 2, 3, 4, 5]
    originalArray.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取Array对象 
    let arrayValue: Array<Int64> = Array.fromJson(reader)

    println("Array反序列化结果: ${arrayValue}")
}
```

运行结果：

```text
Array反序列化结果: [1, 2, 3, 4, 5]
```

### extend\<T> ArrayDeque\<T> <: JsonDeserializable\<ArrayDeque\<T>> where T <: JsonDeserializable\<T>

```cangjie
extend<T> ArrayDeque<T> <: JsonDeserializable<ArrayDeque<T>> where T <: JsonDeserializable<T>
```

功能：为 ArrayDeque 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<ArrayDeque\<T>>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): ArrayDeque<T>
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 ArrayDeque。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- ArrayDeque\<T> - ArrayDeque 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonReader 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个ArrayDeque值作为示例数据 
    let originalArrayDeque: ArrayDeque<Int64> = ArrayDeque<Int64>()
    originalArrayDeque.addFirst(1)
    originalArrayDeque.addFirst(2)
    originalArrayDeque.addFirst(3)
    originalArrayDeque.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取ArrayDeque对象 
    let arrayDequeValue: ArrayDeque<Int64> = ArrayDeque.fromJson(reader)

    println("ArrayDeque反序列化结果: ${arrayDequeValue}")
}
```

运行结果：

```text
ArrayDeque反序列化结果: [3, 2, 1]
```

### extend\<T> ArrayList\<T> <: JsonDeserializable\<ArrayList\<T>> where T <: JsonDeserializable\<T>

```cangjie
extend<T> ArrayList<T> <: JsonDeserializable<ArrayList<T>> where T <: JsonDeserializable<T>
```

功能：为 ArrayList 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<ArrayList\<T>>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): ArrayList<T>
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 ArrayList。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- ArrayList \<T> - ArrayList 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonReader 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个ArrayList值作为示例数据 
    let originalArrayList: ArrayList<Int64> = ArrayList<Int64>([10, 20, 30])
    originalArrayList.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取ArrayList对象 
    let arrayListValue: ArrayList<Int64> = ArrayList.fromJson(reader)

    println("ArrayList反序列化结果: ${arrayListValue}")
}
```

运行结果：

```text
ArrayList反序列化结果: [10, 20, 30]
```

### extend\<T> ArrayQueue\<T> <: JsonDeserializable\<ArrayQueue\<T>> where T <: JsonDeserializable\<T>

```cangjie
extend<T> ArrayQueue<T> <: JsonDeserializable<ArrayQueue<T>> where T <: JsonDeserializable<T>
```

功能：为 ArrayQueue 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<ArrayQueue\<T>>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): ArrayQueue<T>
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 ArrayQueue。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- ArrayQueue\<T> - ArrayQueue 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonReader 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个ArrayQueue值作为示例数据 
    let originalArrayQueue: ArrayQueue<Int64> = ArrayQueue<Int64>()
    originalArrayQueue.add(10)
    originalArrayQueue.add(20)
    originalArrayQueue.add(30)
    originalArrayQueue.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取ArrayQueue对象 
    let arrayQueueValue: ArrayQueue<Int64> = ArrayQueue.fromJson(reader)

    println("ArrayQueue反序列化结果: ${arrayQueueValue}")
}
```

运行结果：

```text
ArrayQueue反序列化结果: [10, 20, 30]
```

### extend\<T> ArrayStack\<T> <: JsonDeserializable\<ArrayStack\<T>> where T <: JsonDeserializable\<T>

```cangjie
extend<T> ArrayStack<T> <: JsonDeserializable<ArrayStack<T>> where T <: JsonDeserializable<T>
```

功能：为 ArrayStack 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<ArrayStack\<T>>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): ArrayStack<T>
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 ArrayStack。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- ArrayStack\<T> - ArrayStack 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonReader 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个ArrayStack值作为示例数据 
    let originalArrayStack: ArrayStack<Int64> = ArrayStack<Int64>()
    originalArrayStack.add(10)
    originalArrayStack.add(20)
    originalArrayStack.add(30)
    originalArrayStack.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取ArrayStack对象 
    let arrayStackValue: ArrayStack<Int64> = ArrayStack.fromJson(reader)

    println("ArrayStack反序列化结果: ${arrayStackValue}")
}
```

运行结果：

```text
ArrayStack反序列化结果: [30, 20, 10]
```

### extend\<T> ConcurrentHashMap\<String, T> <: JsonDeserializable\<ConcurrentHashMap\<String, T>> where T <: JsonDeserializable\<T>

```cangjie
extend<T> ConcurrentHashMap<String, T> <: JsonDeserializable<ConcurrentHashMap<String, T>> where T <: JsonDeserializable<T>
```

功能：为 ConcurrentHashMap 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<ConcurrentHashMap\<String, T>>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): ConcurrentHashMap<String, T>
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 ConcurrentHashMap。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- ConcurrentHashMap\<String, T> - ConcurrentHashMap\<String, T> 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.concurrent.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonReader 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个ConcurrentHashMap值作为示例数据 
    let originalConcurrentHashMap: ConcurrentHashMap<String, Int64> = ConcurrentHashMap<String, Int64>()
    originalConcurrentHashMap.add("key1", 10)
    originalConcurrentHashMap.add("key2", 20)
    originalConcurrentHashMap.add("key3", 30)
    originalConcurrentHashMap.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取ConcurrentHashMap对象 
    let concurrentHashMapValue: ConcurrentHashMap<String, Int64> = ConcurrentHashMap.fromJson(reader)

    println("ConcurrentHashMap反序列化结果的大小: ${concurrentHashMapValue.size}")
}
```

运行结果：

```text
ConcurrentHashMap反序列化结果的大小: 3
```

### extend\<T> HashMap\<String, T> <: JsonDeserializable\<HashMap\<String, T>> where T <: JsonDeserializable\<T>

```cangjie
extend<T> HashMap<String, T> <: JsonDeserializable<HashMap<String, T>> where T <: JsonDeserializable<T>
```

功能：为 HashMap 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<HashMap\<String, T>>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): HashMap<String, T>
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 HashMap。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- HashMap\<String, T> - HashMap\<String, T> 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonReader 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个HashMap值作为示例数据 
    let originalHashMap: HashMap<String, Int64> = HashMap<String, Int64>()
    originalHashMap.add("first", 10)
    originalHashMap.add("second", 20)
    originalHashMap.add("third", 30)
    originalHashMap.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取HashMap对象 
    let hashMapValue: HashMap<String, Int64> = HashMap.fromJson(reader)

    println("HashMap反序列化结果: ${hashMapValue}")
}
```

运行结果：

```text
HashMap反序列化结果: [(first, 10), (second, 20), (third, 30)]
```

### extend\<T> HashSet\<T> <: JsonDeserializable\<HashSet\<T>> where T <: JsonDeserializable\<T>

```cangjie
extend<T> HashSet<T> <: JsonDeserializable<HashSet<T>> where T <: JsonDeserializable<T>
```

功能：为 HashSet 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<HashSet\<T>>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): HashSet<T>
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 HashSet。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- HashSet\<T> - HashSet 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonReader 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个HashSet值作为示例数据 
    let originalHashSet: HashSet<Int64> = HashSet<Int64>([10, 20, 30])
    originalHashSet.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取HashSet对象 
    let hashSetValue: HashSet<Int64> = HashSet.fromJson(reader)

    println("HashSet反序列化结果: ${hashSetValue}")
}
```

运行结果：

```text
HashSet反序列化结果: [10, 20, 30]
```

### extend\<T> LinkedList\<T> <: JsonDeserializable\<LinkedList\<T>> where T <: JsonDeserializable\<T>

```cangjie
extend<T> LinkedList<T> <: JsonDeserializable<LinkedList<T>> where T <: JsonDeserializable<T>
```

功能：为 LinkedList 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<LinkedList\<T>>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): LinkedList<T>
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 LinkedList。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- LinkedList\<T> - LinkedList 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonReader 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个LinkedList值作为示例数据 
    let originalLinkedList: LinkedList<Int64> = LinkedList<Int64>([50, 60, 70])
    originalLinkedList.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取LinkedList对象 
    let linkedListValue: LinkedList<Int64> = LinkedList.fromJson(reader)

    println("LinkedList反序列化结果: ${linkedListValue}")
}
```

运行结果：

```text
LinkedList反序列化结果: [50, 60, 70]
```

### extend\<T> Option \<T> <: JsonDeserializable\<Option\<T>> where T <: JsonDeserializable\<T>

```cangjie
extend<T> Option<T> <: JsonDeserializable<Option<T>> where T <: JsonDeserializable<T>
```

功能：为 Option 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<Option\<T>>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): Option<T>
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 Option。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- Option\<T> - Option 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonReader 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个Option值作为示例数据 
    let originalOption: Option<Int32> = Some(99)
    originalOption.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取Option对象 
    let optionValue: Option<Int32> = Option.fromJson(reader)

    println("Option反序列化结果: ${optionValue}")
}
```

运行结果：

```text
Option反序列化结果: Some(99)
```

### extend\<T> TreeMap\<String, T> <: JsonDeserializable\<TreeMap\<String, T>> where T <: JsonDeserializable\<T>

```cangjie
extend<T> TreeMap<String, T> <: JsonDeserializable<TreeMap<String, T>> where T <: JsonDeserializable<T>
```

功能：为 TreeMap 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<TreeMap\<String, T>>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): TreeMap<String, T>
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 TreeMap。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- TreeMap\<String, T> - TreeMap\<String, T> 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonReader 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个TreeMap值作为示例数据 
    let originalTreeMap: TreeMap<String, Int64> = TreeMap<String, Int64>()
    originalTreeMap.add("first", 10)
    originalTreeMap.add("second", 20)
    originalTreeMap.add("third", 30)
    originalTreeMap.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取TreeMap对象 
    let treeMapValue: TreeMap<String, Int64> = TreeMap.fromJson(reader)

    println("TreeMap反序列化结果: ${treeMapValue}")
}
```

运行结果：

```text
TreeMap反序列化结果: [(first, 10), (second, 20), (third, 30)]
```

### extend\<T> TreeSet\<T> <: JsonDeserializable\<TreeSet\<T>> where T <: JsonDeserializable\<T>

```cangjie
extend<T> TreeSet<T> <: JsonDeserializable<TreeSet<T>> where T <: JsonDeserializable<T>
```

功能：为 TreeSet 类型实现 JsonDeserializable 接口。

父类型：

- [JsonDeserializable](#interface-jsondeserializablet)\<TreeSet\<T>>

#### static func fromJson(JsonReader)

```cangjie
public static func fromJson(r: JsonReader): TreeSet<T>
```

功能：从 [JsonReader](../json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) 中读取一个 TreeSet。

参数：

- r: [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) - 读取反序列化结果的 [JsonReader](encoding_json_stream_package_classes.md#class-jsonreader) 实例。

返回值：

- TreeSet\<T> - TreeSet 类型的实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonReader 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 先写入一个TreeSet值作为示例数据 
    let originalTreeSet: TreeSet<Int64> = TreeSet<Int64>([10, 20, 30])
    originalTreeSet.toJson(writer)
    writer.flush()

    // 从ByteBuffer创建JsonReader 
    let reader = JsonReader(buffer)

    // 从JsonReader读取TreeSet对象 
    let treeSetValue: TreeSet<Int64> = TreeSet.fromJson(reader)

    println("TreeSet反序列化结果: ${treeSetValue}")
}
```

运行结果：

```text
TreeSet反序列化结果: [10, 20, 30]
```

## interface JsonSerializable

```cangjie
public interface JsonSerializable {
    func toJson(w: JsonWriter): Unit
}
```

功能：为类型提供序列化到 JSON 数据流的接口。

与 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 搭配使用，[JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 可以将实现了 [JsonSerializable](encoding_json_stream_package_interfaces.md#interface-jsonserializable) 接口的类型写入到 Stream 中。

### func toJson(JsonWriter)

```cangjie
func toJson(w: JsonWriter): Unit
```

功能：将实现了 [JsonSerializable](encoding_json_stream_package_interfaces.md#interface-jsonserializable) 接口的类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

### extend BigInt <: JsonSerializable

```cangjie
extend BigInt <: JsonSerializable
```

功能：为 BigInt 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 BigInt 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.math.numeric.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入BigInt对象 
    let bigIntValue: BigInt = BigInt(1234567890123456789)
    bigIntValue.toJson(writer)
    writer.flush()

    println("BigInt序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
BigInt序列化结果: 1234567890123456789
```

### extend Bool <: JsonSerializable

```cangjie
extend Bool <: JsonSerializable
```

功能：为 Bool 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 Bool 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入Bool对象 
    let boolValue: Bool = true
    boolValue.toJson(writer)
    writer.flush()

    println("Bool序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
Bool序列化结果: true
```

### extend DateTime <: JsonSerializable

```cangjie
extend DateTime <: JsonSerializable
```

功能：为 DateTime 类型实现 JsonSerializable 接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：提供 DateTime 类型序列化到流的功能。

该接口的功能与 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 的 [writeConfig](./encoding_json_stream_package_classes.md#var-writeconfig)中的属性 [dateTimeFormat](./encoding_json_stream_package_structs.md#prop-datetimeformat)有关联，将会把 DateTime 按照[dateTimeFormat](./encoding_json_stream_package_structs.md#prop-datetimeformat)中的格式输出到目标流中，可以通过修改[dateTimeFormat](./encoding_json_stream_package_structs.md#prop-datetimeformat)实现不同的格式控制。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- run -->
```cangjie
import std.io.*
import std.time.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入DateTime对象 
    let dateTimeValue = DateTime.of(year: 2026, month: 1, dayOfMonth: 7)
    dateTimeValue.toJson(writer)
    writer.flush()

    println("DateTime序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

可能的运行结果：

```text
DateTime序列化结果: "2026-01-07T00:00:00+08:00"
```

### extend Decimal <: JsonSerializable

```cangjie
extend Decimal <: JsonSerializable
```

功能：为 Decimal 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 Decimal 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.math.numeric.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入Decimal对象 
    let decimalValue: Decimal = Decimal(123.456)
    decimalValue.toJson(writer)
    writer.flush()

    println("Decimal序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
Decimal序列化结果: 123.4560000000000030695446184836328029632568359375
```

### extend Float16 <: JsonSerializable

```cangjie
extend Float16 <: JsonSerializable
```

功能：为 Float16 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 Float16 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入Float16对象 
    let floatValue: Float16 = 123.45f16
    floatValue.toJson(writer)
    writer.flush()

    println("Float16序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
Float16序列化结果: 123.4375
```

### extend Float32 <: JsonSerializable

```cangjie
extend Float32 <: JsonSerializable
```

功能：为 Float32 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 Float32 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入Float32对象 
    let floatValue: Float32 = 123.45f32
    floatValue.toJson(writer)
    writer.flush()

    println("Float32序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
Float32序列化结果: 123.449997
```

### extend Float64 <: JsonSerializable

```cangjie
extend Float64 <: JsonSerializable
```

功能：为 Float64 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 Float64 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入Float64对象 
    let floatValue: Float64 = 123.456
    floatValue.toJson(writer)
    writer.flush()

    println("Float64序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
Float64序列化结果: 123.456
```

### extend Int16 <: JsonSerializable

```cangjie
extend Int16 <: JsonSerializable
```

功能：为 Int16 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 Int16 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入Int16对象 
    let intValue: Int16 = 12345
    intValue.toJson(writer)
    writer.flush()

    println("Int16序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
Int16序列化结果: 12345
```

### extend Int32 <: JsonSerializable

```cangjie
extend Int32 <: JsonSerializable
```

功能：为 Int32 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 Int32 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入Int32对象 
    let intValue: Int32 = 1234567
    intValue.toJson(writer)
    writer.flush()

    println("Int32序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
Int32序列化结果: 1234567
```

### extend Int64 <: JsonSerializable

```cangjie
extend Int64 <: JsonSerializable
```

功能：为 Int64 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 Int64 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入Int64对象 
    let intValue: Int64 = 1234567890123
    intValue.toJson(writer)
    writer.flush()

    println("Int64序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
Int64序列化结果: 1234567890123
```

### extend Int8 <: JsonSerializable

```cangjie
extend Int8 <: JsonSerializable
```

功能：为 Int8 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 Int8 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入Int8对象 
    let intValue: Int8 = 123
    intValue.toJson(writer)
    writer.flush()

    println("Int8序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
Int8序列化结果: 123
```

### extend IntNative <: JsonSerializable

```cangjie
extend IntNative <: JsonSerializable
```

功能：为 IntNative 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 IntNative 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入IntNative对象 
    let intValue: IntNative = 987654
    intValue.toJson(writer)
    writer.flush()

    println("IntNative序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
IntNative序列化结果: 987654
```

### extend String <: JsonSerializable

```cangjie
extend String <: JsonSerializable
```

功能：为 String 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 String 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入String对象 
    let strValue: String = "Hello, World!"
    strValue.toJson(writer)
    writer.flush()

    println("String序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
String序列化结果: "Hello, World!"
```

### extend UInt16 <: JsonSerializable

```cangjie
extend UInt16 <: JsonSerializable
```

功能：为 UInt16 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 UInt16 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入UInt16对象 
    let uintValue: UInt16 = 45678
    uintValue.toJson(writer)
    writer.flush()

    println("UInt16序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
UInt16序列化结果: 45678
```

### extend UInt32 <: JsonSerializable

```cangjie
extend UInt32 <: JsonSerializable
```

功能：为 UInt32 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 UInt32 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入UInt32对象 
    let uintValue: UInt32 = 3245678901
    uintValue.toJson(writer)
    writer.flush()

    println("UInt32序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
UInt32序列化结果: 3245678901
```

### extend UInt64 <: JsonSerializable

```cangjie
extend UInt64 <: JsonSerializable
```

功能：为 UInt64 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 UInt64 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入UInt64对象 
    let uintValue: UInt64 = 12345678901234567890
    uintValue.toJson(writer)
    writer.flush()

    println("UInt64序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
UInt64序列化结果: 12345678901234567890
```

### extend UInt8 <: JsonSerializable

```cangjie
extend UInt8 <: JsonSerializable
```

功能：为 UInt8 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 UInt8 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入UInt8对象 
    let uintValue: UInt8 = 200
    uintValue.toJson(writer)
    writer.flush()

    println("UInt8序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
UInt8序列化结果: 200
```

### extend UIntNative <: JsonSerializable

```cangjie
extend UIntNative <: JsonSerializable
```

功能：为 UIntNative 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 UIntNative 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入UIntNative对象 
    let uintValue: UIntNative = 2147483648
    uintValue.toJson(writer)
    writer.flush()

    println("UIntNative序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
UIntNative序列化结果: 2147483648
```

### extend\<T> Array\<T> <: JsonSerializable where T <: JsonSerializable

```cangjie
extend<T> Array<T> <: JsonSerializable where T <: JsonSerializable
```

功能：为 Array\<T> 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 Array\<T> 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入Array对象 
    let arrayValue: Array<Int32> = [1, 2, 3, 4, 5]
    arrayValue.toJson(writer)
    writer.flush()

    println("Array序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
Array序列化结果: [1,2,3,4,5]
```

### extend\<T> ArrayDeque\<T> <: JsonSerializable where T <: JsonSerializable

```cangjie
extend<T> ArrayDeque<T> <: JsonSerializable where T <: JsonSerializable
```

功能：为 ArrayDeque\<T> 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 ArrayDeque\<T> 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入ArrayDeque对象 
    let arrayDequeValue: ArrayDeque<Int64> = ArrayDeque<Int64>()
    arrayDequeValue.addFirst(10)
    arrayDequeValue.addFirst(20)
    arrayDequeValue.addFirst(30)
    arrayDequeValue.toJson(writer)
    writer.flush()

    println("ArrayDeque序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
ArrayDeque序列化结果: [30,20,10]
```

### extend\<T> ArrayList\<T> <: JsonSerializable where T <: JsonSerializable

```cangjie
extend<T> ArrayList<T> <: JsonSerializable where T <: JsonSerializable
```

功能：为 ArrayList\<T> 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 ArrayList\<T> 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入ArrayList对象 
    let arrayListValue: ArrayList<Int64> = ArrayList<Int64>([100, 200, 300])
    arrayListValue.toJson(writer)
    writer.flush()

    println("ArrayList序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
ArrayList序列化结果: [100,200,300]
```

### extend\<T> ArrayQueue\<T> <: JsonSerializable where T <: JsonSerializable

```cangjie
extend<T> ArrayQueue<T> <: JsonSerializable where T <: JsonSerializable
```

功能：为 ArrayQueue\<T> 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 ArrayQueue\<T> 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入ArrayQueue对象 
    let arrayQueueValue: ArrayQueue<Int64> = ArrayQueue<Int64>()
    arrayQueueValue.add(100)
    arrayQueueValue.add(200)
    arrayQueueValue.add(300)
    arrayQueueValue.toJson(writer)
    writer.flush()

    println("ArrayQueue序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
ArrayQueue序列化结果: [100,200,300]
```

### extend\<T> ArrayStack\<T> <: JsonSerializable where T <: JsonSerializable

```cangjie
extend<T> ArrayStack<T> <: JsonSerializable where T <: JsonSerializable
```

功能：为 ArrayStack\<T> 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 ArrayStack\<T> 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入ArrayStack对象 
    let arrayStackValue: ArrayStack<Int64> = ArrayStack<Int64>()
    arrayStackValue.add(111)
    arrayStackValue.add(222)
    arrayStackValue.add(333)
    arrayStackValue.toJson(writer)
    writer.flush()

    println("ArrayStack序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
ArrayStack序列化结果: [111,222,333]
```

### extend\<T> HashSet\<T> <: JsonSerializable where T <: JsonSerializable

```cangjie
extend<T> HashSet<T> <: JsonSerializable where T <: JsonSerializable
```

功能：为 HashSet\<T> 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 HashSet\<T> 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入HashSet对象 
    let hashSetValue: HashSet<Int64> = HashSet<Int64>([100, 200, 300])
    hashSetValue.toJson(writer)
    writer.flush()

    println("HashSet序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
HashSet序列化结果: [100,200,300]
```

### extend\<T> LinkedList\<T> <: JsonSerializable where T <: JsonSerializable

```cangjie
extend<T> LinkedList<T> <: JsonSerializable where T <: JsonSerializable
```

功能：为 LinkedList\<T> 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 LinkedList\<T> 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入LinkedList对象 
    let linkedListValue: LinkedList<Int64> = LinkedList<Int64>()
    linkedListValue.addFirst(111)
    linkedListValue.addFirst(222)
    linkedListValue.addFirst(333)
    linkedListValue.toJson(writer)
    writer.flush()

    println("LinkedList序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
LinkedList序列化结果: [333,222,111]
```

### extend\<T> Option\<T> <: JsonSerializable where T <: JsonSerializable

```cangjie
extend<T> Option<T> <: JsonSerializable where T <: JsonSerializable
```

功能：为 Option\<T> 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 Option\<T> 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入Option对象 
    let optionValue: Option<Int64> = Some(999)
    optionValue.toJson(writer)
    writer.flush()

    println("Option序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
Option序列化结果: 999
```

### extend\<T> TreeSet\<T> <: JsonSerializable where T <: JsonSerializable

```cangjie
extend<T> TreeSet<T> <: JsonSerializable where T <: JsonSerializable
```

功能：为 TreeSet\<T> 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 TreeSet\<T> 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入TreeSet对象 
    let treeSetValue: TreeSet<Int64> = TreeSet<Int64>([333, 111, 222])
    treeSetValue.toJson(writer)
    writer.flush()

    println("TreeSet序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
TreeSet序列化结果: [111,222,333]
```

### extend\<V> ConcurrentHashMap\<String, V> <: JsonSerializable where V <: JsonSerializable

```cangjie
extend<V> ConcurrentHashMap<String, V> <: JsonSerializable where V <: JsonSerializable
```

功能：为 ConcurrentHashMap\<String, T> 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 ConcurrentHashMap\<String, T> 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入ConcurrentHashMap对象 
    let concurrentHashMapValue = HashMap<String, Int64>([("key1", 100), ("key2", 200), ("key3", 300)])
    concurrentHashMapValue.toJson(writer)
    writer.flush()

    println("ConcurrentHashMap序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
ConcurrentHashMap序列化结果: {"key1":100,"key2":200,"key3":300}
```

### extend\<V> HashMap\<String, V> <: JsonSerializable where V <: JsonSerializable

```cangjie
extend<V> HashMap<String, V> <: JsonSerializable where V <: JsonSerializable
```

功能：为 HashMap\<String, T> 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 HashMap\<String, T> 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入HashMap对象 
    let hashMapValue = HashMap<String, Int64>([("first", 100), ("second", 200), ("third", 300)])
    hashMapValue.toJson(writer)
    writer.flush()

    println("HashMap序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
HashMap序列化结果: {"first":100,"second":200,"third":300}
```

### extend\<V> TreeMap\<String, V> <: JsonSerializable where V <: JsonSerializable

```cangjie
extend<V> TreeMap<String, V> <: JsonSerializable where V <: JsonSerializable
```

功能：为 TreeMap\<String, T> 类型提供序列化到 JSON 数据流的接口。

父类型：

- [JsonSerializable](#interface-jsonserializable)

#### func toJson(JsonWriter)

```cangjie
public func toJson(w: JsonWriter): Unit
```

功能：将 TreeMap\<String, T> 类型写入参数 `w` 指定的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例中。

参数：

- w: [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) - 写入序列化结果的 [JsonWriter](encoding_json_stream_package_classes.md#class-jsonwriter) 实例。

示例：

<!-- verify -->
```cangjie
import std.io.*
import std.collection.*
import stdx.encoding.json.stream.*

main() {
    // 创建JsonWriter 
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    // 写入TreeMap对象 
    let treeMapValue = TreeMap<String, Int64>([("apple", 100), ("banana", 200), ("cherry", 300)])
    treeMapValue.toJson(writer)
    writer.flush()

    println("TreeMap序列化结果: ${String.fromUtf8(buffer.bytes())}")
}
```

运行结果：

```text
TreeMap序列化结果: {"apple":100,"banana":200,"cherry":300}
```
