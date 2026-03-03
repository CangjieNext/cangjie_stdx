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
- Equatable\<AccessLevel>

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
