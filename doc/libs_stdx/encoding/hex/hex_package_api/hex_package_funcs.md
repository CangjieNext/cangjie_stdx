# 函数

## func fromHexString(String)

```cangjie
public func fromHexString(data: String): Option<Array<Byte>>
```

功能：此函数用于 Hex 编码的字符串的解码。

参数：

- data: String - 要解码的 Hex 编码的字符串。

返回值：

- Option\<Array\<Byte>> - 输入空字符串会返回 Option\<Array\<Byte>>.Some(Array\<Byte>())，解码失败会返回 Option\<Array\<Byte>>.None。

示例：

<!-- verify -->
```cangjie
import stdx.encoding.hex.*

main() {
    // 将Hex编码的字符串解码为字节数组
    let hexStr = "48656c6c6f20576f726c6421" // "Hello World!"的Hex编码
    let result = fromHexString(hexStr)

    if (let Some(bytes) <- result) {
        println("解码成功: ${bytes}")
        println("转成字符串: ${String.fromUtf8(bytes)}")
    } else {
        println("解码失败")
    }
}
```

运行结果：

```text
解码成功: [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33]
转成字符串: Hello World!
```

## func toHexString(Array\<Byte>)

```cangjie
public func toHexString(data: Array<Byte>): String
```

功能：此函数用于将 Byte 数组转换成 Hex 编码的字符串。

参数：

- data: Array\<Byte> - 要编码的 Byte 数组。

返回值：

- String - 返回编码后的字符串。

示例：

<!-- verify -->
```cangjie
import stdx.encoding.hex.*

main() {
    // 将字符串转换成Byte数组
    let str = "Hello World!"
    let bytes = str.toArray()
    println("字节数组: ${bytes}")

    // 将Byte数组转换成Hex编码的字符串
    let result = toHexString(bytes)
    println("编码结果: ${result}")
}
```

运行结果：

```text
字节数组: [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33]
编码结果: 48656c6c6f20576f726c6421
```
