# 枚举

## enum AccessLevel

```cangjie
public enum AccessLevel <: ToString & Equatable<AccessLevel> {
    Internal
    | Protected
    | Public
}
```

功能：表示**包的访问级别**，用于控制跨包边界的可见性。

父类型：

- ToString
- Equatable\<[AccessLevel](#enum-accesslevel)>

### Internal

```cangjie
Internal
```

功能：本包及子包可见。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Internal)
    println(pkg.accessLevel.toString())
}
```

运行结果：

```text
internal
```

### Protected

```cangjie
Protected
```

功能：同 Module 下的包可见。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Protected)
    println(pkg.accessLevel.toString())
}
```

运行结果：

```text
protected
```

### Public

```cangjie
Public
```

功能：所有包可见。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    println(pkg.accessLevel.toString())
}
```

运行结果：

```text
public
```

### func toString()

```cangjie
public func toString(): String
```

功能：将访问级别转为小写字符串：`"internal"`、`"protected"` 或 `"public"`。

返回值：

- String - 上述三种之一。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    println(AccessLevel.Public.toString())
}
```

运行结果：

```text
public
```

### operator func==(AccessLevel)

```cangjie
public operator func ==(other: AccessLevel): Bool
```

功能：比较两个访问级别是否为同一变体（`Internal`、`Protected`、`Public` 各自与自身相等，彼此不等）。

参数：

- other: AccessLevel - 另一访问级别。

返回值：

- Bool - 相等则为 `true`，否则为 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    println("op_eq_AccessLevel same: ${AccessLevel.Public == AccessLevel.Public}")
    println("op_eq_AccessLevel diff: ${AccessLevel.Public == AccessLevel.Internal}")
}
```

运行结果：

```text
op_eq_AccessLevel same: true
op_eq_AccessLevel diff: false
```

### operator func!=(AccessLevel)

```cangjie
public operator func !=(other: AccessLevel): Bool
```

功能：与上一节的 `==` 相反，两个访问级别不同时为 `true`，相同时为 `false`（等价于 `!(this == other)`）。

参数：

- other: AccessLevel - 另一访问级别。

返回值：

- Bool - 不相等则为 `true`，否则为 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    println("op_ne_AccessLevel diff: ${AccessLevel.Public != AccessLevel.Internal}")
    println("op_ne_AccessLevel same: ${AccessLevel.Public != AccessLevel.Public}")
}
```

运行结果：

```text
op_ne_AccessLevel diff: true
op_ne_AccessLevel same: false
```
