# 函数

## func fromBase64String(String)

```cangjie
public func fromBase64String(data: String): Option<Array<Byte>>
```

功能：此函数用于 Base64 编码的字符串的解码。

参数：

- data: String - 要解码的 Base64 编码的字符串。

返回值：

- Option\<Array\<Byte>> - 输入空字符串会返回 Option\<Array\<Byte>>.Some(Array\<Byte>())，解码失败会返回 Option\<Array\<Byte>>.None。

示例：

<!-- verify -->
```cangjie
import stdx.encoding.base64.*

main() {
    // 对Base64编码的字符串进行解码
    let base64Str = "SGVsbG8gV29ybGQh" // "Hello World!"的Base64编码
    let result = fromBase64String(base64Str)

    if (let Some(str) <- result) {
        println("解码成功: ${str}")
        println("转成字符串: ${String.fromUtf8(str)}")
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

## func toBase64String(Array\<Byte>)

```cangjie
public func toBase64String(data: Array<Byte>): String
```

功能：此函数用于将 Byte 数组转换成 Base64 编码的字符串。

参数：

- data: Array\<Byte> - 要编码的 Byte 数组。

返回值：

- String - 返回编码后的字符串。

示例：

<!-- verify -->
```cangjie
import stdx.encoding.base64.*

main() {
    // 将字符串转换成Byte数组
    let str = "Hello World!"
    let bytes = str.toArray()
    println("字节数组: ${bytes}")

    // 将Byte数组转换成Base64编码的字符串
    let result = toBase64String(bytes)
    println("编码结果: ${result}")
}
```

运行结果：

```text
字节数组: [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33]
编码结果: SGVsbG8gV29ybGQh
```
