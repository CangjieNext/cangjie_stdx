# 枚举

## enum AccessLevel

```cangjie
@Derive[Equatable]
public enum AccessLevel <: ToString {
    Internal
    | Protected
    | Public

    public func toString(): String
}
```

功能：表示**包的访问级别**，用于控制跨包边界的可见性。

父类型：

- ToString

### Internal

功能：本包及子包可见。

### Protected

功能：同Module下的包可见。

### Public

功能：所有包可见。

### func toString()

```cangjie
public func toString(): String
```

功能：将访问级别转为小写字符串：`"internal"`、`"protected"` 或 `"public"`。

返回值：

- String - 上述三种之一。

### 完整用例

（覆盖三变体、`toString()` 与 `Equatable` 相等比较。）

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    println(AccessLevel.Internal.toString())
    println(AccessLevel.Protected.toString())
    println(AccessLevel.Public.toString())
    let a = AccessLevel.Internal
    let b = AccessLevel.Public
    println(a == a)
    println(a == b)
}
```

运行结果：

```text
internal
protected
public
true
false
```
