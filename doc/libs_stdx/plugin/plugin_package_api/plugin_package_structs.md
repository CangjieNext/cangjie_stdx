# 结构体

## struct PluginResult

```cangjie
@C public struct PluginResult
```

功能：CHIR 插件执行结果，包含处理后数据指针、数据长度及执行是否成功。

### init(CPointer\<UInt8>, Int64, Bool)

```cangjie
public init(data: CPointer<UInt8>, length: Int64, success: Bool)
```

功能：构造一个插件执行结果实例。

参数：

- data: CPointer\<UInt8> - 处理后的数据指针。
- length: Int64 - 数据长度。
- success: Bool - 执行是否成功。

示例：

<!-- verify -->
```cangjie
import stdx.plugin.*

main() {
    let ptr = CPointer<UInt8>().null()
    let result = PluginResult(ptr, 0, false)
    println("length: ${result.length}")
    println("success: ${result.success}")
}
```

运行结果：

```text
length: 0
success: false
```

### prop data

```cangjie
public let data: CPointer<UInt8>
```

功能：获取处理后数据的指针。

### prop length

```cangjie
public let length: Int64
```

功能：获取处理后数据的长度。

示例：

<!-- verify -->
```cangjie
import stdx.plugin.*

main() {
    let ptr = CPointer<UInt8>().null()
    let result = PluginResult(ptr, 128, true)
    println("length: ${result.length}")
}
```

运行结果：

```text
length: 128
```

### prop success

```cangjie
public let success: Bool
```

功能：获取插件执行是否成功的状态。

示例：

<!-- verify -->
```cangjie
import stdx.plugin.*

main() {
    let ptr = CPointer<UInt8>().null()
    let result = PluginResult(ptr, 0, true)
    println("success: ${result.success}")
}
```

运行结果：

```text
success: true
```