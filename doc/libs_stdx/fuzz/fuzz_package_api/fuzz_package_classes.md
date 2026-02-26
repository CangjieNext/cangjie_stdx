# 类

## class DebugDataProvider

```cangjie
public class DebugDataProvider <: FuzzDataProvider
```

功能：此类继承了 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 类型，额外增加了调试信息。

> **注意：**
>
> 不支持平台：Windows。

父类型：

- [FuzzDataProvider](#class-fuzzdataprovider)

### func consumeAll()

```cangjie
public override func consumeAll(): Array<UInt8>
```

功能：将所有数据转换成 UInt8 类型数组。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Array\<UInt8> - UInt8 类型数组。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将所有数据转换成 UInt8 类型数组
    let allData = ddp.consumeAll()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeAll return [65, 66, 67, 68]
```

### func consumeAllAsAscii()

```cangjie
public override func consumeAllAsAscii(): String
```

功能：将所有数据转换成 Ascii String 类型。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- String - Ascii String 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([72, 101, 108, 108, 111]) // "Hello" in ASCII
    let ddp = DebugDataProvider.wrap(fdp)
    // 将所有数据转换成 Ascii String 类型
    let asciiStr = ddp.consumeAllAsAscii()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeAllAsAscii return Hello
```

### func consumeAllAsString()

```cangjie
public override func consumeAllAsString(): String
```

功能：将所有数据转换成 utf8 String 类型。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- String - utf8 String 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([72, 101, 108, 108, 111]) // "Hello" in ASCII
    let ddp = DebugDataProvider.wrap(fdp)
    // 将所有数据转换成 utf8 String 类型
    let utf8Str = ddp.consumeAllAsString()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeAllAsString return Hello
```

### func consumeAsciiString(Int64)

```cangjie
public override func consumeAsciiString(maxLength: Int64): String
```

功能：将数据转换成 Ascii String 类型实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- maxLength: Int64 - String 类型的最大长度。

返回值：

- String - String 类型实例。

异常：

- IllegalArgumentException - 如果 maxLength 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([72, 101, 108, 108, 111]) // "Hello" in ASCII
    let ddp = DebugDataProvider.wrap(fdp)
    // 将数据转换成 Ascii String 类型实例，最大长度为3
    let asciiStr = ddp.consumeAsciiString(3)
    return 0
}
```

运行结果：

```text
[DEBUG] consumeAsciiString return Hel
```

### func consumeBool()

```cangjie
public override func consumeBool(): Bool
```

功能：将数据转换成 Bool 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Bool - Bool 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将数据转换成 Bool 类型实例
    let boolVal = ddp.consumeBool()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeBool return true
```

### func consumeBools(Int64)

```cangjie
public override func consumeBools(count: Int64): Array<Bool>
```

功能：将指定数量的数据转换成 Bool 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<Bool> - Bool 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将指定数量的数据转换成 Bool 类型数组
    let bools = ddp.consumeBools(3)
    return 0
}
```

运行结果：

```text
[DEBUG] consumeBools return [true, false, true]
```

### func consumeByte()

```cangjie
public override func consumeByte(): Byte
```

功能：将数据转换成 Byte 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Byte - Byte 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将数据转换成 Byte 类型实例
    let byteVal = ddp.consumeByte()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeByte return 65
```

### func consumeBytes(Int64)

```cangjie
public override func consumeBytes(count: Int64): Array<Byte>
```

功能：将指定数量的数据转换成 Byte 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<Byte> - Byte 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将指定数量的数据转换成 Byte 类型数组
    let bytes = ddp.consumeBytes(2)
    return 0
}
```

运行结果：

```text
[DEBUG] consumeBytes return [65, 66]
```

### func consumeFloat32()

```cangjie
public override func consumeFloat32(): Float32
```

功能：将数据转换成 Float32 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Float32 - Float32 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将数据转换成 Float32 类型实例
    let float32Val = ddp.consumeFloat32()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeFloat32 return 781.035217
```

### func consumeFloat64()

```cangjie
public override func consumeFloat64(): Float64
```

功能：将数据转换成 Float64 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Float64 - Float64 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 69, 70, 71, 72])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将数据转换成 Float64 类型实例
    let float64Val = ddp.consumeFloat64()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeFloat64 return 15839800103804824402926068484019465486336.000000
```

### func consumeInt16()

```cangjie
public override func consumeInt16(): Int16
```

功能：将数据转换成 Int16 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Int16 - Int16 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将数据转换成 Int16 类型实例
    let int16Val = ddp.consumeInt16()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeInt16 return 16961
```

### func consumeInt16s(Int64)

```cangjie
public override func consumeInt16s(count: Int64): Array<Int16>
```

功能：将指定数量的数据转换成 Int16 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<Int16> - Int16 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 69, 70])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将指定数量的数据转换成 Int16 类型数组
    let int16s = ddp.consumeInt16s(2)
    return 0
}
```

运行结果：

```text
[DEBUG] consumeInt16s return [16961, 17475]
```

### func consumeInt32()

```cangjie
public override func consumeInt32(): Int32
```

功能：将数据转换成 Int32 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Int32 - Int32 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将数据转换成 Int32 类型实例
    let int32Val = ddp.consumeInt32()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeInt32 return 1145258561
```

### func consumeInt32s(Int64)

```cangjie
public override func consumeInt32s(count: Int64): Array<Int32>
```

功能：将指定数量的数据转换成 Int32 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<Int32> - Int32 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 69, 70, 71, 72, 73, 74])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将指定数量的数据转换成 Int32 类型数组
    let int32s = ddp.consumeInt32s(2)
    return 0
}
```

运行结果：

```text
[DEBUG] consumeInt32s return [1145258561, 1212630597]
```

### func consumeInt64()

```cangjie
public override func consumeInt64(): Int64
```

功能：将数据转换成 Int64 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Int64 - Int64 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 65, 66, 67, 68])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将数据转换成 Int64 类型实例
    let int64Val = ddp.consumeInt64()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeInt64 return 4918848066104279617
```

### func consumeInt64s(Int64)

```cangjie
public override func consumeInt64s(count: Int64): Array<Int64>
```

功能：将指定数量的数据转换成 Int64 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<Int64> - Int64 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 65, 66, 67, 68, 65, 66, 67, 68, 65, 66, 67, 68])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将指定数量的数据转换成 Int64 类型数组
    let int64s = ddp.consumeInt64s(2)
    return 0
}
```

运行结果：

```text
[DEBUG] consumeInt64s return [4918848066104279617, 4918848066104279617]
```

### func consumeInt8()

```cangjie
public override func consumeInt8(): Int8
```

功能：将数据转换成 Int8 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Int8 - Int8 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将数据转换成 Int8 类型实例
    let int8Val = ddp.consumeInt8()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeInt8 return 65
```

### func consumeInt8s(Int64)

```cangjie
public override func consumeInt8s(count: Int64): Array<Int8>
```

功能：将指定数量的数据转换成 Int8 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<Int8> - Int8 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将指定数量的数据转换成 Int8 类型数组
    let int8s = ddp.consumeInt8s(2)
    return 0
}
```

运行结果：

```text
[DEBUG] consumeInt8s return [65, 66]
```

### func consumeRune()

```cangjie
public override func consumeRune(): Rune
```

功能：将数据转换成 Rune 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Rune - Rune 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([72, 101, 108, 108, 111]) // "Hello" string
    let ddp = DebugDataProvider.wrap(fdp)
    // 将数据转换成 Rune 类型实例
    let runeVal = ddp.consumeRune()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeRune return 󆕈
```

### func consumeString(Int64)

```cangjie
public override func consumeString(maxLength: Int64): String
```

功能：将数据转换成 utf8 String 类型实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- maxLength: Int64 - String 类型的最大长度。

返回值：

- String - String 类型实例。

异常：

- IllegalArgumentException - 如果 maxLength 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([228, 189, 160, 229, 165, 189]) // "你好" string
    let ddp = DebugDataProvider.wrap(fdp)
    // 将指定长度的数据转换成 String 类型实例
    let str = ddp.consumeString(1)
    return 0
}
```

运行结果：

```text
[DEBUG] consumeString return 你
```

### func consumeUInt16()

```cangjie
public override func consumeUInt16(): UInt16
```

功能：将数据转换成 UInt16 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- UInt16 - UInt16 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将数据转换成 UInt16 类型实例
    let uint16Val = ddp.consumeUInt16()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeUInt16 return 16961
```

### func consumeUInt16s(Int64)

```cangjie
public override func consumeUInt16s(count: Int64): Array<UInt16>
```

功能：将指定数量的数据转换成 UInt16 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<UInt16> - UInt16 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将指定数量的数据转换成 UInt16 类型数组
    let uint16s = ddp.consumeUInt16s(2)
    return 0
}
```

运行结果：

```text
[DEBUG] consumeUInt16s return [16961, 17475]
```

### func consumeUInt32()

```cangjie
public override func consumeUInt32(): UInt32
```

功能：将数据转换成 UInt32 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- UInt32 - UInt32 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将数据转换成 UInt32 类型实例
    let uint32Val = ddp.consumeUInt32()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeUInt32 return 1145258561
```

### func consumeUInt32s(Int64)

```cangjie
public override func consumeUInt32s(count: Int64): Array<UInt32>
```

功能：将指定数量的数据转换成 UInt32 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<UInt32> - UInt32 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 69, 70, 71, 72])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将指定数量的数据转换成 UInt32 类型数组
    let uint32s = ddp.consumeUInt32s(2)
    return 0
}
```

运行结果：

```text
[DEBUG] consumeUInt32s return [1145258561, 1212630597]
```

### func consumeUInt64()

```cangjie
public override func consumeUInt64(): UInt64
```

功能：将数据转换成 UInt64 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- UInt64 - UInt64 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 69, 70, 71, 72])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将数据转换成 UInt64 类型实例
    let uint64Val = ddp.consumeUInt64()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeUInt64 return 5208208757389214273
```

### func consumeUInt64s(Int64)

```cangjie
public override func consumeUInt64s(count: Int64): Array<UInt64>
```

功能：将指定数量的数据转换成 UInt64 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<UInt64> - UInt64 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将指定数量的数据转换成 UInt64 类型数组
    let uint64s = ddp.consumeUInt64s(2)
    return 0
}
```

运行结果：

```text
[DEBUG] consumeUInt64s return [5208208757389214273, 5786930140093827657]
```

### func consumeUInt8()

```cangjie
public override func consumeUInt8(): UInt8
```

功能：将数据转换成 UInt8 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- UInt8 - UInt8 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将数据转换成 UInt8 类型实例
    let uint8Val = ddp.consumeUInt8()
    return 0
}
```

运行结果：

```text
[DEBUG] consumeUInt8 return 65
```

### func consumeUInt8s(Int64)

```cangjie
public override func consumeUInt8s(count: Int64): Array<UInt8>
```

功能：将指定数量的数据转换成 UInt8 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<UInt8> - UInt8 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67])
    let ddp = DebugDataProvider.wrap(fdp)
    // 将指定数量的数据转换成 UInt8 类型数组
    let uint8s = ddp.consumeUInt8s(2)
    return 0
}
```

运行结果：

```text
[DEBUG] consumeUInt8s return [65, 66]
```

### func wrap(FuzzDataProvider)

```cangjie
public static func wrap(dp: FuzzDataProvider): DebugDataProvider
```

功能：根据 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 实例创建 [DebugDataProvider](fuzz_package_classes.md#class-debugdataprovider) 实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- dp: [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) - [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 类型实例。

返回值：

- [DebugDataProvider](fuzz_package_classes.md#class-debugdataprovider) - 类型实例。


示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67])

    // 通过FuzzDataProvider创建DebugDataProvider
    let ddp = DebugDataProvider.wrap(fdp)
    // 将指定数量的数据转换成 UInt8 类型数组
    let uint8s = ddp.consumeUInt8s(2)
    return 0
}
```

运行结果：

```text
[DEBUG] consumeUInt8s return [65, 66]
```

## class FuzzDataProvider

```cangjie
public open class FuzzDataProvider {
    public let data: Array<UInt8>
    public var remainingBytes: Int64
    public var offset: Int64
}
```

功能：[FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 是一个工具类，目的是将变异数据的字节流转化为标准的仓颉基本数据。

> **注意：**
>
> 不支持平台：Windows。

当前支持的数据结构如下：

| 目标类型          | API                                  | 说明                                               |
|---------------|--------------------------------------|--------------------------------------------------|
| Bool          | consumeBool()                        | 获取 1 个 Bool，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。         |
| Array\<Bool>   | consumeBools(count: Int64)           | 获取 N 个 Bool，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。         |
| Byte          | consumeByte()                        | 获取 1 个 Byte，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。         |
| Array\<Byte>   | consumeBytes(count: Int64)           | 获取 N 个 Byte，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。         |
| UInt8         | consumeUInt8()                       | 获取 1 个 UInt8，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。        |
| UInt16        | consumeUInt16()                      | 获取 1 个 UInt16，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。       |
| UInt32        | consumeUInt32()                      | 获取 1 个 UInt32，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。       |
| UInt64        | consumeUInt64()                      | 获取 1 个 UInt64，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。       |
| Int8          | consumeInt8()                        | 获取 1 个 Int8，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。         |
| Int16         | consumeInt16()                       | 获取 1 个 Int16，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。        |
| Int32         | consumeInt32()                       | 获取 1 个 Int32，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。        |
| Int64         | consumeInt64()                       | 获取 1 个 Int64，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。        |
| Float32         | consumeFloat32()                       | 获取 1 个 Float32，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。        |
| Float64         | consumeFloat64()                       | 获取 1 个 Float64，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。        |
| Array\<UInt8>  | consumeUInt8s(count: Int64)          | 获取 N 个 UInt8，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。        |
| Array\<UInt16> | consumeUInt16s(count: Int64)         | 获取 N 个 UInt16，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。       |
| Array\<UInt32> | consumeUInt32s(count: Int64)         | 获取 N 个 UInt32，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。       |
| Array\<UInt64> | consumeUInt64s(count: Int64)         | 获取 N 个 UInt64，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。       |
| Array\<Int8>   | consumeInt8s(count: Int64)           | 获取 N 个 Int8，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。         |
| Array\<Int16>  | consumeInt16s(count: Int64)          | 获取 N 个 Int16，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。        |
| Array\<Int32>  | consumeInt32s(count: Int64)          | 获取 N 个 Int32，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。        |
| Array\<Int64>  | consumeInt64s(count: Int64)          | 获取 N 个 Int64，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。        |
| Rune          | consumeRune()                        | 获取 1 个 Rune，变异数据长度不足时，抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)。         |
| String        | consumeAsciiString(maxLength: Int64) | 获取 1 个纯 ASCII 的 String，长度为 0 到 maxLength，可以为 0。           |
| String        | consumeString(maxLength: Int64)      | 获取 1 个 UTF8 String，长度为 0 到 maxLength，可以为 0。             |
| Array\<UInt8>  | consumeAll()                         | 将 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 中的剩余内容全部转化为字节数组。                    |
| String        | consumeAllAsAscii()                  | 将 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 中的剩余内容全部转化为纯 ASCII 的 String。           |
| String        | consumeAllAsString()                 | 将 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 中的剩余内容全部转化为 UTF8 String，末尾多余的字符不会被消耗。 |

在数据长度不足时，调用上述大部分虽然会抛出 [ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception)，但编写 fuzz 函数时通常并不需要对它进行处理，[ExhaustedException](fuzz_package_exceptions.md#class-exhaustedexception) 默认会被 fuzz 框架捕获，告诉 libfuzzer 该次运行无效，请继续下一轮变异。随着执行时间的变长，变异数据也会逐渐变长，直到满足 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 的需求。

如果达到了 `max_len` 仍无法满足 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 的需求，则进程退出，请修改 fuzz 测试用例（推荐） 或 增大 `max_len`（不推荐）。

### let data

```cangjie
public let data: Array<UInt8>
```

功能：变异数据。

> **注意：**
>
> 不支持平台：Windows。

类型：Array\<UInt8>

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let inputData: Array<UInt8> = [65, 66, 67]
    // 使用withCangjieData创建FuzzDataProvider实例
    let fdp = FuzzDataProvider.withCangjieData(inputData)
    println("数据: ${fdp.data}")
    return 0
}
```

运行结果：

```text
数据: [65, 66, 67]
```

### var offset

```cangjie
public var offset: Int64
```

功能：已转化的字节数。

> **注意：**
>
> 不支持平台：Windows。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 69, 70, 71, 72])
    // 访问offset属性
    println("当前消耗量: ${fdp.offset}")
    // 消费一些数据后再次查看offset
    let _ = fdp.consumeByte()
    let _ = fdp.consumeByte()
    let _ = fdp.consumeByte()
    println("消费数据后: ${fdp.offset}")
    return 0
}
```

运行结果：

```text
当前消耗量: 0
消费数据后: 3
```

### var remainingBytes

```cangjie
public var remainingBytes: Int64
```

功能：剩余字节数。

> **注意：**
>
> 不支持平台：Windows。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 69, 70, 71, 72])
    // 访问remainingBytes属性
    println("当前剩余量: ${fdp.remainingBytes}")
    // 消费一些数据后再次查看remainingBytes
    let _ = fdp.consumeByte()
    let _ = fdp.consumeByte()
    let _ = fdp.consumeByte()
    println("消费数据后: ${fdp.remainingBytes}")
    return 0
}
```

运行结果：

```text
当前剩余量: 8
消费数据后: 5
```

### static func withCangjieData(Array\<UInt8>)

```cangjie
public static func withCangjieData(data: Array<UInt8>): FuzzDataProvider
```

功能：使用 Array\<UInt8> 类型的数据生成 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 类型实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- data: Array\<UInt8> - 输入的外部数据。

返回值：

- [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) - 构造的 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let inputData: Array<UInt8> = [65, 66, 67, 68, 69, 70]
    // 使用withCangjieData创建FuzzDataProvider实例
    let fdp = FuzzDataProvider.withCangjieData(inputData)
    println("FuzzDataProvider创建成功，数据长度: ${fdp.data.size}")
    return 0
}
```

运行结果：

```text
FuzzDataProvider创建成功，数据长度: 6
```

### static func withNativeData(CPointer\<UInt8>, Int64)

```cangjie
public static unsafe func withNativeData(data: CPointer<UInt8>, length: Int64): FuzzDataProvider
```

功能：使用 C 指针数据生成 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 类型实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- data: CPointer\<UInt8> - 输入的外部数据。
- length: Int64 - 数据长度。

返回值：

- [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) - 构造的 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let arr: Array<UInt8> = [65, 66, 67, 68]
    // 获取CPointerHandle
    let cptrHandle: CPointerHandle<UInt8> = unsafe { acquireArrayRawData(arr) }
    // 获取pointer
    let cptr: CPointer<UInt8> = cptrHandle.pointer

    // 模拟外部数据指针创建FuzzDataProvider实例
    let fdp = unsafe { FuzzDataProvider.withNativeData(cptr, arr.size) }
    println("数据: ${fdp.data}")

    // 释放CPointerHandle
    unsafe { releaseArrayRawData<UInt8>(cptrHandle) }
    return 0
}
```

运行结果：

```text
数据: [65, 66, 67, 68]
```

### func consumeAll()

```cangjie
public open func consumeAll(): Array<UInt8>
```

功能：将所有数据转换成 UInt8 类型数组。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Array\<UInt8> - UInt8 类型数组。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68])
    // 将所有数据转换成 UInt8 类型数组
    let allData = fdp.consumeAll()
    println("转换后的UInt8数组: ${allData}")
    return 0
}
```

运行结果：

```text
转换后的UInt8数组: [65, 66, 67, 68]
```

### func consumeAllAsAscii()

```cangjie
public open func consumeAllAsAscii(): String
```

功能：将所有数据转换成 Ascii String 类型。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- String - Ascii String 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([72, 101, 108, 108, 111]) // "Hello" in ASCII

    // 将所有数据转换成 Ascii String 类型
    let asciiStr = fdp.consumeAllAsAscii()
    println("转换后的Ascii字符串: ${asciiStr}")
    return 0
}
```

运行结果：

```text
转换后的Ascii字符串: Hello
```

### func consumeAllAsString()

```cangjie
public open func consumeAllAsString(): String
```

功能：将所有数据转换成 utf8 String 类型。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- String - utf8 String 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([72, 101, 108, 108, 111]) // "Hello" in ASCII

    // 将所有数据转换成 utf8 String 类型
    let utf8Str = fdp.consumeAllAsString()
    println("转换后的utf8字符串: ${utf8Str}")
    return 0
}
```

运行结果：

```text
转换后的utf8字符串: Hello
```

### func consumeAsciiString(Int64)

```cangjie
public open func consumeAsciiString(maxLength: Int64): String
```

功能：将数据转换成 Ascii String 类型实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- maxLength: Int64 - String 类型的最大长度。

返回值：

- String - String 类型实例。

异常：

- IllegalArgumentException - 如果 maxLength 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([72, 101, 108, 108, 111]) // "Hello" in ASCII

    // 将数据转换成 Ascii String 类型实例，最大长度为3
    let asciiStr = fdp.consumeAsciiString(3)
    println("转换后的Ascii字符串: ${asciiStr}")
    return 0
}
```

运行结果：

```text
转换后的Ascii字符串: Hel
```

### func consumeBool()

```cangjie
public open func consumeBool(): Bool
```

功能：将数据转换成 Bool 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Bool - Bool 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65])
    // 将数据转换成 Bool 类型实例
    let boolVal = fdp.consumeBool()
    println("转换后的Bool值: ${boolVal}")
    return 0
}
```

运行结果：

```text
转换后的Bool值: true
```

### func consumeBools(Int64)

```cangjie
public open func consumeBools(count: Int64): Array<Bool>
```

功能：将指定数量的数据转换成 Bool 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<Bool> - Bool 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67])
    // 将指定数量的数据转换成 Bool 类型数组
    let bools = fdp.consumeBools(3)
    println("转换后的Bool数组: ${bools}")
    return 0
}
```

运行结果：

```text
转换后的Bool数组: [true, false, true]
```

### func consumeByte()

```cangjie
public open func consumeByte(): Byte
```

功能：将数据转换成 Byte 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Byte - Byte 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66])
    // 将数据转换成 Byte 类型实例
    let byteVal = fdp.consumeByte()
    println("转换后的Byte值: ${byteVal}")
    return 0
}
```

运行结果：

```text
转换后的Byte值: 65
```

### func consumeBytes(Int64)

```cangjie
public open func consumeBytes(count: Int64): Array<Byte>
```

功能：将指定数量的数据转换成 Byte 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<Byte> - Byte 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67])
    // 将指定数量的数据转换成 Byte 类型数组
    let bytes = fdp.consumeBytes(2)
    println("转换后的Byte数组: ${bytes}")
    return 0
}
```

运行结果：

```text
转换后的Byte数组: [65, 66]
```

### func consumeFloat32()

```cangjie
public open func consumeFloat32(): Float32
```

功能：将数据转换成 Float32 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Float32 - Float32 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68])
    // 将数据转换成 Float32 类型实例
    let float32Val = fdp.consumeFloat32()
    println("转换后的Float32值: ${float32Val}")
    return 0
}
```

运行结果：

```text
转换后的Float32值: 781.035217
```

### func consumeFloat64()

```cangjie
public open func consumeFloat64(): Float64
```

功能：将数据转换成 Float64 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Float64 - Float64 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 69, 70, 71, 72])
    // 将数据转换成 Float64 类型实例
    let float64Val = fdp.consumeFloat64()
    println("转换后的Float64值: ${float64Val}")
    return 0
}
```

运行结果：

```text
转换后的Float64值: 15839800103804824402926068484019465486336.000000
```

### func consumeInt16()

```cangjie
public open func consumeInt16(): Int16
```

功能：将数据转换成 Int16 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Int16 - Int16 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66])
    // 将数据转换成 Int16 类型实例
    let int16Val = fdp.consumeInt16()
    println("转换后的Int16值: ${int16Val}")
    return 0
}
```

运行结果：

```text
转换后的Int16值: 16961
```

### func consumeInt16s(Int64)

```cangjie
public open func consumeInt16s(count: Int64): Array<Int16>
```

功能：将指定数量的数据转换成 Int16 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<Int16> - Int16 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 69, 70])
    // 将指定数量的数据转换成 Int16 类型数组
    let int16s = fdp.consumeInt16s(2)
    println("Int16数组: ${int16s}")
    return 0
}
```

运行结果：

```text
Int16数组: [16961, 17475]
```

### func consumeInt32()

```cangjie
public open func consumeInt32(): Int32
```

功能：将数据转换成 Int32 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Int32 - Int32 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68])
    // 将数据转换成 Int32 类型实例
    let int32Val = fdp.consumeInt32()
    println("转换后的Int32值: ${int32Val}")
    return 0
}
```

运行结果：

```text
转换后的Int32值: 1145258561
```

### func consumeInt32s(Int64)

```cangjie
public open func consumeInt32s(count: Int64): Array<Int32>
```

功能：将指定数量的数据转换成 Int32 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<Int32> - Int32 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 69, 70, 71, 72, 73, 74])
    // 将指定数量的数据转换成 Int32 类型数组
    let int32s = fdp.consumeInt32s(2)
    println("转换后的Int32数组: ${int32s}")
    return 0
}
```

运行结果：

```text
转换后的Int32数组: [1145258561, 1212630597]
```

### func consumeInt64()

```cangjie
public open func consumeInt64(): Int64
```

功能：将数据转换成 Int64 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Int64 - Int64 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 65, 66, 67, 68])
    // 将数据转换成 Int64 类型实例
    let int64Val = fdp.consumeInt64()
    println("转换后的Int64值: ${int64Val}")
    return 0
}
```

运行结果：

```text
转换后的Int64值: 4918848066104279617
```

### func consumeInt64s(Int64)

```cangjie
public open func consumeInt64s(count: Int64): Array<Int64>
```

功能：将指定数量的数据转换成 Int64 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<Int64> - Int64 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 65, 66, 67, 68, 65, 66, 67, 68, 65, 66, 67, 68])
    // 将指定数量的数据转换成 Int64 类型数组
    let int64s = fdp.consumeInt64s(2)
    println("转换后的Int64数组: ${int64s}")
    return 0
}
```

运行结果：

```text
转换后的Int64数组: [4918848066104279617, 4918848066104279617]
```

### func consumeInt8()

```cangjie
public open func consumeInt8(): Int8
```

功能：将数据转换成 Int8 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Int8 - Int8 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65])
    // 将数据转换成 Int8 类型实例
    let int8Val = fdp.consumeInt8()
    println("转换后的Int8值: ${int8Val}")
    return 0
}
```

运行结果：

```text
转换后的Int8值: 65
```

### func consumeInt8s(Int64)

```cangjie
public open func consumeInt8s(count: Int64): Array<Int8>
```

功能：将指定数量的数据转换成 Int8 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<Int8> - Int8 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67])
    // 将指定数量的数据转换成 Int8 类型数组
    let int8s = fdp.consumeInt8s(2)
    println("转换后的Int8数组: ${int8s}")
    return 0
}
```

运行结果：

```text
转换后的Int8数组: [65, 66]
```

### func consumeRune()

```cangjie
public open func consumeRune(): Rune
```

功能：将数据转换成 Rune 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Rune - Rune 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([72, 101, 108, 108, 111]) // "Hello" string

    // 将数据转换成 Rune 类型实例
    let runeVal = fdp.consumeRune()
    println("转换后的Rune值: ${runeVal}")
    return 0
}
```

运行结果：

```text
转换后的Rune值: 󆕈
```

### func consumeString(Int64)

```cangjie
public open func consumeString(maxLength: Int64): String
```

功能：将数据转换成 utf8 String 类型实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- maxLength: Int64 - String 类型的最大长度。

返回值：

- String - String 类型实例。

异常：

- IllegalArgumentException - 如果 maxLength 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([228, 189, 160, 229, 165, 189]) // "你好" string

    // 将指定长度的数据转换成 String 类型实例
    let str = fdp.consumeString(1)
    println("转换后的String值: ${str}")
    return 0
}
```

运行结果：

```text
转换后的String值: 你
```

### func consumeUInt16()

```cangjie
public open func consumeUInt16(): UInt16
```

功能：将数据转换成 UInt16 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- UInt16 - UInt16 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66])
    // 将数据转换成 UInt16 类型实例
    let uint16Val = fdp.consumeUInt16()
    println("转换后的UInt16值: ${uint16Val}")
    return 0
}
```

运行结果：

```text
转换后的UInt16值: 16961
```

### func consumeUInt16s(Int64)

```cangjie
public open func consumeUInt16s(count: Int64): Array<UInt16>
```

功能：将指定数量的数据转换成 UInt16 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<UInt16> - UInt16 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68])
    // 将指定数量的数据转换成 UInt16 类型数组
    let uint16s = fdp.consumeUInt16s(2)
    println("转换后的UInt16数组: ${uint16s}")
    return 0
}
```

运行结果：

```text
转换后的UInt16数组: [16961, 17475]
```

### func consumeUInt32()

```cangjie
public open func consumeUInt32(): UInt32
```

功能：将数据转换成 UInt32 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- UInt32 - UInt32 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68])
    // 将数据转换成 UInt32 类型实例
    let uint32Val = fdp.consumeUInt32()
    println("转换后的UInt32值: ${uint32Val}")
    return 0
}
```

运行结果：

```text
转换后的UInt32值: 1145258561
```

### func consumeUInt32s(Int64)

```cangjie
public open func consumeUInt32s(count: Int64): Array<UInt32>
```

功能：将指定数量的数据转换成 UInt32 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<UInt32> - UInt32 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 69, 70, 71, 72])
    // 将指定数量的数据转换成 UInt32 类型数组
    let uint32s = fdp.consumeUInt32s(2)
    println("转换后的UInt32数组: ${uint32s}")
    return 0
}
```

运行结果：

```text
转换后的UInt32数组: [1145258561, 1212630597]
```

### func consumeUInt64()

```cangjie
public open func consumeUInt64(): UInt64
```

功能：将数据转换成 UInt64 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- UInt64 - UInt64 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 69, 70, 71, 72])
    // 将数据转换成 UInt64 类型实例
    let uint64Val = fdp.consumeUInt64()
    println("转换后的UInt64值: ${uint64Val}")
    return 0
}
```

运行结果：

```text
转换后的UInt64值: 5208208757389214273
```

### func consumeUInt64s(Int64)

```cangjie
public open func consumeUInt64s(count: Int64): Array<UInt64>
```

功能：将指定数量的数据转换成 UInt64 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<UInt64> - UInt64 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80])
    // 将指定数量的数据转换成 UInt64 类型数组
    let uint64s = fdp.consumeUInt64s(2)
    println("转换后的UInt64数组: ${uint64s}")
    return 0
}
```

运行结果：

```text
转换后的UInt64数组: [5208208757389214273, 5786930140093827657]
```

### func consumeUInt8()

```cangjie
public open func consumeUInt8(): UInt8
```

功能：将数据转换成 UInt8 类型实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- UInt8 - UInt8 类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65])
    // 将数据转换成 UInt8 类型实例
    let uint8Val = fdp.consumeUInt8()
    println("转换后的UInt8值: ${uint8Val}")
    return 0
}
```

运行结果：

```text
转换后的UInt8值: 65
```

### func consumeUInt8s(Int64)

```cangjie
public open func consumeUInt8s(count: Int64): Array<UInt8>
```

功能：将指定数量的数据转换成 UInt8 类型数组。

> **注意：**
>
> 不支持平台：Windows。

参数：

- count: Int64 - 指定转换的数据量。

返回值：

- Array\<UInt8> - UInt8 类型数组。

异常：

- IllegalArgumentException - 如果 count 为负数，则抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 通过手动传入数据创建FuzzDataProvider（真实模糊测试自动、持续生成海量随机初始数据）
    let fdp = FuzzDataProvider.withCangjieData([65, 66, 67])
    // 将指定数量的数据转换成 UInt8 类型数组
    let uint8s = fdp.consumeUInt8s(2)
    println("转换后的UInt8数组: ${uint8s}")
    return 0
}
```

运行结果：

```text
转换后的UInt8数组: [65, 66]
```

## class Fuzzer

```cangjie
public class Fuzzer {
    public init(targetFunction: (Array<UInt8>) -> Int32)
    public init(targetFunction: (Array<UInt8>) -> Int32, args: Array<String>)
    public init(targetFunction: (FuzzDataProvider) -> Int32)
    public init(targetFunction: (FuzzDataProvider) -> Int32, args: Array<String>)
}
```

功能：[Fuzzer](fuzz_package_classes.md#class-fuzzer) 类提供了 fuzz 工具的创建。用户提供需要进行 fuzz 测试的函数 `targetFunction`，以及设置特定的 fuzz 运行参数 `args` 比如 fuzz 执行次数、初始种子、生成数据最大长度等，可创建相应类型的 [Fuzzer](fuzz_package_classes.md#class-fuzzer)。

> **注意：**
>
> 不支持平台：Windows。

### init((Array\<UInt8>) -> Int32)

```cangjie
public init(targetFunction: (Array<UInt8>) -> Int32)
```

功能：根据以 UInt8 数组为参数，以 Int32 为返回值的目标函数，创建 [Fuzzer](fuzz_package_classes.md#class-fuzzer) 实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- targetFunction: (Array\<UInt8>) ->Int32 - 以 UInt8 数组为参数，以 Int32 为返回值的目标函数。

示例：

<!-- run -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 创建Fuzzer
    let fuzzer = Fuzzer(testApi)

    // 启动Fuzz，解除注释有临时文件和输出
    // fuzzer.startFuzz()
    return 0
}

// 被测函数，在满足特定条件会抛出异常，该异常会被 Fuzzer 捕获
public func testApi(data: Array<UInt8>): Int32 {
    if (data.size == 8 && data[0] == b'C' && data[1] == b'a' && data[2] == b'n' && data[3] == b'g' && data[4] == b'j' &&
        data[5] == b'i' && data[6] == b'e' && data[7] == b'!') {
        throw Exception("TRAP")
    }
    return 0
}
```

### init((Array\<UInt8>) -> Int32, Array\<String>)

```cangjie
public init(targetFunction: (Array<UInt8>) -> Int32, args: Array<String>)
```

功能：根据以 UInt8 数组为参数，以 Int32 为返回值的目标函数，以及 Fuzz 运行参数，创建 [Fuzzer](fuzz_package_classes.md#class-fuzzer) 实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- targetFunction: (Array\<UInt8>) ->Int32 - 以 UInt8 数组为参数，以 Int32 为返回值的目标函数。
- args: Array\<String> - Fuzz 运行参数。

示例：

<!-- run -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 此示例因为有运行参数的原因而输出帮助信息
    let fuzzer = Fuzzer(testApi, ["-help=1"])
    fuzzer.startFuzz()
    return 0
}

public func testApi(data: Array<UInt8>): Int32 {
    throw Exception("TRAP")
    return 0
}
```

### init((FuzzDataProvider) -> Int32)

```cangjie
public init(targetFunction: (FuzzDataProvider) -> Int32)
```

功能：根据以 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 为参数，以 Int32 为返回值的目标函数，创建 [Fuzzer](fuzz_package_classes.md#class-fuzzer) 实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- targetFunction: ([FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider)) ->Int32 - 以 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 为参数，以 Int32 为返回值的目标函数。

示例：

<!-- run -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 创建Fuzzer
    let fuzzer = Fuzzer(testApi)

    // 启动Fuzz，解除注释有临时文件和输出
    // fuzzer.startFuzz()
    return 0
}

public func testApi(dp: FuzzDataProvider): Int32 {
    if (dp.consumeBool() && dp.consumeByte() == b'A' && dp.consumeUInt32() == 0xdeadbeef) {
        throw Exception("TRAP")
    }
    return 0
}
```

### init((FuzzDataProvider) -> Int32, Array\<String>)

```cangjie
public init(targetFunction: (FuzzDataProvider) -> Int32, args: Array<String>)
```

功能：根据以 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 为参数，以 Int32 为返回值的目标函数，以及 Fuzz 运行参数，创建 [Fuzzer](fuzz_package_classes.md#class-fuzzer) 实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- targetFunction: ([FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider)) ->Int32 - 以 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 为参数，以 Int32 为返回值的目标函数。
- args: Array\<String> - Fuzz 运行参数。

示例：

<!-- run -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 此示例因为有运行参数的原因而输出帮助信息
    let fuzzer = Fuzzer(testApi, ["-help=1"])
    fuzzer.startFuzz()
    return 0
}

public func testApi(dp: FuzzDataProvider): Int32 {
    throw Exception("TRAP")
    return 0
}
```

### func disableDebugDataProvider()

```cangjie
public func disableDebugDataProvider(): Unit
```

功能：关闭调试信息打印功能，当 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider).consumeXXX 被调用时，返回值将不被打印到 `stdout`。

> **注意：**
>
> 不支持平台：Windows。

示例：

<!-- run -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 创建Fuzzer
    let fuzzer = Fuzzer(testApi)

    // 关闭调试信息打印功能
    fuzzer.disableDebugDataProvider()

    // 启动Fuzz，解除注释有临时文件和输出
    // fuzzer.startFuzz()
    return 0
}

public func testApi(dp: FuzzDataProvider): Int32 {
    if (dp.consumeBool() && dp.consumeByte() == b'A' && dp.consumeUInt32() == 0xdeadbeef) {
        throw Exception("TRAP")
    }
    return 0
}
```

### func disableFakeCoverage()

```cangjie
public func disableFakeCoverage(): Unit
```

功能：关闭调用 `enableFakeCoverage` 对 Fuzz 的影响。

> **注意：**
>
> 不支持平台：Windows。

示例：

<!-- run -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 创建Fuzzer
    let fuzzer = Fuzzer(testApi)

    // 关闭调用 `enableFakeCoverage` 对 Fuzz 的影响
    fuzzer.disableFakeCoverage()

    // 启动Fuzz，解除注释有临时文件和输出
    // fuzzer.startFuzz()
    return 0
}

public func testApi(dp: FuzzDataProvider): Int32 {
    if (dp.consumeBool() && dp.consumeByte() == b'A' && dp.consumeUInt32() == 0xdeadbeef) {
        throw Exception("TRAP")
    }
    return 0
}
```

### func enableDebugDataProvider()

```cangjie
public func enableDebugDataProvider(): Unit
```

功能：启用调试信息打印功能，当 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider).consumeXXX 被调用时，返回值将被打印到 `stdout`。该功能默认为关闭。

> **注意：**
>
> 不支持平台：Windows。

示例：

<!-- run -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 创建Fuzzer
    let fuzzer = Fuzzer(testApi)

    // 启用调试信息打印功能
    fuzzer.enableDebugDataProvider()

    // 启动Fuzz，解除注释有临时文件和输出
    // fuzzer.startFuzz()
    return 0
}

public func testApi(dp: FuzzDataProvider): Int32 {
    if (dp.consumeBool() && dp.consumeByte() == b'A' && dp.consumeUInt32() == 0xdeadbeef) {
        throw Exception("TRAP")
    }
    return 0
}
```

### func enableFakeCoverage()

```cangjie
public func enableFakeCoverage(): Unit
```

功能：创建一块虚假的覆盖率反馈区域，保持 Fuzz 持续进行。在 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 模式下，前几轮运行时可能由于数据不足而导致没有覆盖率，libfuzzer 会退出。该功能默认为关闭。

> **注意：**
>
> 不支持平台：Windows。

示例：

<!-- run -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 创建Fuzzer
    let fuzzer = Fuzzer(testApi)

    fuzzer.enableFakeCoverage()

    // 启动Fuzz，解除注释有临时文件和输出
    // fuzzer.startFuzz()
    return 0
}

public func testApi(dp: FuzzDataProvider): Int32 {
    if (dp.consumeBool() && dp.consumeByte() == b'A' && dp.consumeUInt32() == 0xdeadbeef) {
        throw Exception("TRAP")
    }
    return 0
}
```

### func getArgs()

```cangjie
public func getArgs(): Array<String>
```

功能：获取 Fuzz 运行参数。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- Array\<String> - 当前 Fuzz 运行参数。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 创建有运行参数的Fuzzer
    let fuzzer = Fuzzer(testApi, ["-help=1"])

    // 获取运行参数
    let args = fuzzer.getArgs()

    println("运行参数: ${args}")
    return 0
}

public func testApi(data: Array<UInt8>): Int32 {
    throw Exception("TRAP")
    return 0
}
```

运行结果：

```text
运行参数: [-help=1]
```

### func setArgs(Array\<String>)

```cangjie
public func setArgs(args: Array<String>): Unit
```

功能：设置 Fuzz 运行参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- args: Array\<String> - Fuzz 运行参数。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 创建Fuzzer
    let fuzzer = Fuzzer(testApi)

    // 设置运行参数
    fuzzer.setArgs(["-help=1"])

    // 获取运行参数
    let args = fuzzer.getArgs()

    println("运行参数: ${args}")
    return 0
}

public func testApi(data: Array<UInt8>): Int32 {
    throw Exception("TRAP")
    return 0
}
```

运行结果：

```text
运行参数: [-help=1]
```

### func setTargetFunction((Array\<UInt8>) -> Int32)

```cangjie
public func setTargetFunction(targetFunction: (Array<UInt8>) -> Int32): Unit
```

功能：设置 Fuzz 目标函数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- targetFunction: (Array\<UInt8>) ->Int32 - 以 UInt8 数组为参数，以 Int32 为返回值的目标函数。

示例：

<!-- run -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 创建Fuzzer
    let fuzzer = Fuzzer(testApi)

    // 设置被测函数，原本的 testApi 函数将被 testApi1 替代
    fuzzer.setTargetFunction(testApi1)

    // 启动Fuzz，解除注释有临时文件和输出
    // fuzzer.startFuzz()
    return 0
}

// 被测函数，在满足特定条件会抛出异常，该异常会被 Fuzzer 捕获
public func testApi(dp: FuzzDataProvider): Int32 {
    if (dp.consumeBool() && dp.consumeByte() == b'A' && dp.consumeUInt32() == 0xdeadbeef) {
        throw Exception("TRAP")
    }
    return 0
}

// 被测函数，在满足特定条件会抛出异常，该异常会被 Fuzzer 捕获
public func testApi1(data: Array<UInt8>): Int32 {
    if (data.size == 8 && data[0] == b'C' && data[1] == b'a' && data[2] == b'n' && data[3] == b'g' && data[4] == b'j' &&
        data[5] == b'i' && data[6] == b'e' && data[7] == b'!') {
        throw Exception("TRAP")
    }
    return 0
}
```

### func setTargetFunction((FuzzDataProvider) -> Int32)

```cangjie
public func setTargetFunction(targetFunction: (FuzzDataProvider) -> Int32): Unit
```

功能：设置 Fuzz 目标函数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- targetFunction: ([FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider)) ->Int32 - 以 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 为参数，以 Int32 为返回值的目标函数。

示例：

<!-- run -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 创建Fuzzer
    let fuzzer = Fuzzer(testApi)

    // 设置被测函数，原本的 testApi 函数将被 testApi1 替代
    fuzzer.setTargetFunction(testApi1)

    // 启动Fuzz，解除注释有临时文件和输出
    // fuzzer.startFuzz()
    return 0
}

// 被测函数，在满足特定条件会抛出异常，该异常会被 Fuzzer 捕获
public func testApi(data: Array<UInt8>): Int32 {
    if (data.size == 8 && data[0] == b'C' && data[1] == b'a' && data[2] == b'n' && data[3] == b'g' && data[4] == b'j' &&
        data[5] == b'i' && data[6] == b'e' && data[7] == b'!') {
        throw Exception("TRAP")
    }
    return 0
}

// 被测函数，在满足特定条件会抛出异常，该异常会被 Fuzzer 捕获
public func testApi1(dp: FuzzDataProvider): Int32 {
    if (dp.consumeBool() && dp.consumeByte() == b'A' && dp.consumeUInt32() == 0xdeadbeef) {
        throw Exception("TRAP")
    }
    return 0
}
```

### func startFuzz()

```cangjie
public func startFuzz(): Unit
```

功能：执行 Fuzz。

> **注意：**
>
> 不支持平台：Windows。

示例：

<!-- run -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    // 创建Fuzzer
    let fuzzer = Fuzzer(testApi)

    // 启动Fuzz，解除注释有临时文件和输出
    // fuzzer.startFuzz()
    return 0
}

// 被测函数，在满足特定条件会抛出异常，该异常会被 Fuzzer 捕获
public func testApi(data: Array<UInt8>): Int32 {
    if (data.size == 8 && data[0] == b'C' && data[1] == b'a' && data[2] == b'n' && data[3] == b'g' && data[4] == b'j' &&
        data[5] == b'i' && data[6] == b'e' && data[7] == b'!') {
        throw Exception("TRAP")
    }
    return 0
}
```

## class FuzzerBuilder

```cangjie
public class FuzzerBuilder {
    public init(targetFunction: (Array<UInt8>) -> Int32)
    public init(targetFunction: (FuzzDataProvider) -> Int32)
}
```

功能：此类用于 [Fuzzer](fuzz_package_classes.md#class-fuzzer) 类的构建。

> **注意：**
>
> 不支持平台：Windows。

### init((Array\<UInt8>) -> Int32)

```cangjie
public init(targetFunction: (Array<UInt8>) -> Int32)
```

功能：根据以 UInt8 数组为参数，以 Int32 为返回值的目标函数，创建 [FuzzerBuilder](fuzz_package_classes.md#class-fuzzerbuilder) 实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- targetFunction: (Array\<UInt8>) ->Int32 - 以 UInt8 数组为参数，以 Int32 为返回值的目标函数。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

func myFuzzFunction(data: Array<UInt8>): Int32 {
    // 简单的模糊测试函数，检查数据长度
    if (data.size > 3) {
        println("数据长度大于3")
        return 0
    }
    return -1
}

main() {
    // 使用以UInt8数组为目标函数的FuzzerBuilder
    let builder = FuzzerBuilder(myFuzzFunction)
    println("FuzzerBuilder创建成功")
    return 0
}
```

运行结果：

```text
FuzzerBuilder创建成功
```

### init((FuzzDataProvider) -> Int32)

```cangjie
public init(targetFunction: (FuzzDataProvider) -> Int32)
```

功能：根据以 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 为参数，以 Int32 为返回值的目标函数，创建 [FuzzerBuilder](fuzz_package_classes.md#class-fuzzerbuilder) 实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- targetFunction: ([FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider)) ->Int32 - 以 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 为参数，以 Int32 为返回值的目标函数。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

func myFuzzFunctionWithProvider(fdp: FuzzDataProvider): Int32 {
    // 使用FuzzDataProvider的简单模糊测试函数
    try {
        let byte = fdp.consumeByte()
        println("消耗了一个字节: ${byte}")
        return 0
    } catch (ex: ExhaustedException) {
        println("数据耗尽")
        return -1
    }
}

main() {
    // 使用以FuzzDataProvider为目标函数的FuzzerBuilder
    let builder = FuzzerBuilder(myFuzzFunctionWithProvider)
    println("FuzzerBuilder创建成功")
    return 0
}
```

运行结果：

```text
FuzzerBuilder创建成功
```

### func build()

```cangjie
public func build(): Fuzzer
```

功能：生成一个 [Fuzzer](fuzz_package_classes.md#class-fuzzer) 实例。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- [Fuzzer](fuzz_package_classes.md#class-fuzzer) - [Fuzzer](fuzz_package_classes.md#class-fuzzer) 实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

func myFuzzFunction(data: Array<UInt8>): Int32 {
    // 简单的模糊测试函数
    if (data.size >= 1) {
        let value = data[0]
        println("第一个字节值: ${value}")
        return 0
    }
    return -1
}

main() {
    // 创建FuzzerBuilder并构建Fuzzer实例
    let builder = FuzzerBuilder(myFuzzFunction)
    let fuzzer = builder.build()
    println("Fuzzer构建成功")
    return 0
}
```

运行结果：

```text
Fuzzer构建成功
```

### func setArgs(Array\<String>)

```cangjie
public func setArgs(args: Array<String>): FuzzerBuilder
```

功能：设置 Fuzz 运行参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- args: Array\<String> - Fuzz 运行参数。

返回值：

- [FuzzerBuilder](fuzz_package_classes.md#class-fuzzerbuilder) - 当前 [FuzzerBuilder](fuzz_package_classes.md#class-fuzzerbuilder) 实例。

示例：

<!-- run -->
```cangjie
import stdx.fuzz.fuzz.*

func myFuzzFunction(data: Array<UInt8>): Int32 {
    // 简单的模糊测试函数
    return 0
}

main() {
    // 创建FuzzerBuilder并设置参数
    let builder = FuzzerBuilder(myFuzzFunction)
    let args = ["-max_len=1024", "-timeout=10"]
    builder.setArgs(args)
    return 0
}
```

### func setTargetFunction((Array\<UInt8>) -> Int32)

```cangjie
public func setTargetFunction(targetFunction: (Array<UInt8>) -> Int32): FuzzerBuilder
```

功能：设置 Fuzz 目标函数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- targetFunction: (Array\<UInt8>) ->Int32 - 以 UInt8 数组为参数，以 Int32 为返回值的目标函数。

返回值：

- [FuzzerBuilder](fuzz_package_classes.md#class-fuzzerbuilder) - 当前 [FuzzerBuilder](fuzz_package_classes.md#class-fuzzerbuilder) 实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

func myFirstFuzzFunction(data: Array<UInt8>): Int32 {
    // 第一个模糊测试函数
    return 0
}

func mySecondFuzzFunction(data: Array<UInt8>): Int32 {
    // 第二个模糊测试函数
    if (data.size > 5) {
        return 1
    }
    return 0
}

main() {
    // 创建FuzzerBuilder并设置目标函数
    let builder = FuzzerBuilder(myFirstFuzzFunction)
    let updatedBuilder = builder.setTargetFunction(mySecondFuzzFunction)
    println("目标函数更新成功")
    return 0
}
```

运行结果：

```text
目标函数更新成功
```

### func setTargetFunction((FuzzDataProvider) -> Int32)

```cangjie
public func setTargetFunction(targetFunction: (FuzzDataProvider) -> Int32): FuzzerBuilder
```

功能：设置 Fuzz 目标函数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- targetFunction: ([FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider)) ->Int32 - 以 [FuzzDataProvider](fuzz_package_classes.md#class-fuzzdataprovider) 为参数，以 Int32 为返回值的目标函数。

返回值：

- [FuzzerBuilder](fuzz_package_classes.md#class-fuzzerbuilder) - 当前 [FuzzerBuilder](fuzz_package_classes.md#class-fuzzerbuilder) 实例。

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

func myFirstFuzzFunctionWithProvider(fdp: FuzzDataProvider): Int32 {
    // 第一个使用FuzzDataProvider的模糊测试函数
    return 0
}

func mySecondFuzzFunctionWithProvider(fdp: FuzzDataProvider): Int32 {
    // 第二个使用FuzzDataProvider的模糊测试函数
    try {
        let intVal = fdp.consumeInt32()
        println("消耗了一个Int32值: ${intVal}")
        return 0
    } catch (ex: ExhaustedException) {
        println("数据耗尽")
        return -1
    }
}

main() {
    // 创建FuzzerBuilder并设置FuzzDataProvider目标函数
    let builder = FuzzerBuilder(myFirstFuzzFunctionWithProvider)
    let updatedBuilder = builder.setTargetFunction(mySecondFuzzFunctionWithProvider)
    println("FuzzDataProvider目标函数更新成功")
    return 0
}
```

运行结果：

```text
FuzzDataProvider目标函数更新成功
```
