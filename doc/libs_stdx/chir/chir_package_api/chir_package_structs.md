# 结构体

## struct Position

```cangjie
public struct Position <: ToString {
    public prop line: Int64
    public prop column: Int64
    public func isValid(): Bool
    public func toString(): String
}
```

功能：表示源码中的**一个点**（行号与列号），在 [DebugLocation](chir_package_classes.md#class-debuglocation) 中作为区间端点使用。行、列一般为 **1 起计**；`isValid()` 要求二者均大于 0。

父类型：

- ToString

### func isValid()

```cangjie
public func isValid(): Bool
```

功能：当行、列均大于 0 时认为位置有效。

返回值：

- Bool - 是否有效。

### func toString()

```cangjie
public func toString(): String
```

功能：紧凑调试形式，如 `-行号-列号`。

返回值：

- String - 位置字符串。

### prop column

```cangjie
public prop column: Int64
```

功能：源码列号（1-based）。

### prop line

```cangjie
public prop line: Int64
```

功能：源码行号（1-based，与 `isValid` 语义一致）。
