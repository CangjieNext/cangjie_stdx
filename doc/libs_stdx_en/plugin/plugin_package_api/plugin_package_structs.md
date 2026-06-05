# Structs

## struct PluginResult

```cangjie
@C public struct PluginResult
```

Description: CHIR plugin execution result, containing processed data pointer, data length, and execution success status.

### init(CPointer\<UInt8>, Int64, Bool)

```cangjie
public init(data: CPointer<UInt8>, length: Int64, success: Bool)
```

Description: Constructs a plugin execution result instance.

Parameters:

- data: CPointer\<UInt8> - Pointer to the processed data.
- length: Int64 - Data length.
- success: Bool - Whether the execution succeeded.

Example:

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

Output:

```text
length: 0
success: false
```

### prop data

```cangjie
public let data: CPointer<UInt8>
```

Description: Gets the pointer to the processed data.

### prop length

```cangjie
public let length: Int64
```

Description: Gets the length of the processed data.

Example:

<!-- verify -->
```cangjie
import stdx.plugin.*

main() {
    let ptr = CPointer<UInt8>().null()
    let result = PluginResult(ptr, 128, true)
    println("length: ${result.length}")
}
```

Output:

```text
length: 128
```

### prop success

```cangjie
public let success: Bool
```

Description: Gets whether the plugin execution succeeded.

Example:

<!-- verify -->
```cangjie
import stdx.plugin.*

main() {
    let ptr = CPointer<UInt8>().null()
    let result = PluginResult(ptr, 0, true)
    println("success: ${result.success}")
}
```

Output:

```text
success: true
```