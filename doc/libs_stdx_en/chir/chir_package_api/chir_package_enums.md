# Enums

## enum AccessLevel

```cangjie
public enum AccessLevel <: ToString & Equatable<AccessLevel> {
    Internal
    | Protected
    | Public
}
```

Function: Represents the **package access level** used to control visibility across package boundaries.

Parent Types:

- ToString
- Equatable\<[AccessLevel](#enum-accesslevel)>

### Internal

```cangjie
Internal
```

Function: Visible in this package and subpackages.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Internal)
    println(pkg.accessLevel.toString())
}
```

Output:

```text
internal
```

### Protected

```cangjie
Protected
```

Function: Visible to packages under the same module.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Protected)
    println(pkg.accessLevel.toString())
}
```

Output:

```text
protected
```

### Public

```cangjie
Public
```

Function: Visible to all packages.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    println(pkg.accessLevel.toString())
}
```

Output:

```text
public
```

### func toString()

```cangjie
public func toString(): String
```

Function: Converts the access level to a lowercase string: `"internal"`, `"protected"`, or `"public"`.

Return Value:

- String - One of the three values above.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    println(AccessLevel.Public.toString())
}
```

Output:

```text
public
```

### operator func==(AccessLevel)

```cangjie
public operator func ==(other: AccessLevel): Bool
```

Function: Compares whether two access levels are the same variant (`Internal`, `Protected`, and `Public` are each equal to themselves and unequal to each other).

Parameters:

- other: AccessLevel - The other access level.

Return Value:

- Bool - `true` if equal, otherwise `false`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    println("op_eq_AccessLevel same: ${AccessLevel.Public == AccessLevel.Public}")
    println("op_eq_AccessLevel diff: ${AccessLevel.Public == AccessLevel.Internal}")
}
```

Output:

```text
op_eq_AccessLevel same: true
op_eq_AccessLevel diff: false
```

### operator func!=(AccessLevel)

```cangjie
public operator func !=(other: AccessLevel): Bool
```

Function: Opposite of `==` in the previous section: `true` when the two access levels differ, `false` when they are equal (equivalent to `!(this == other)`).

Parameters:

- other: AccessLevel - The other access level.

Return Value:

- Bool - `true` if not equal, otherwise `false`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    println("op_ne_AccessLevel diff: ${AccessLevel.Public != AccessLevel.Internal}")
    println("op_ne_AccessLevel same: ${AccessLevel.Public != AccessLevel.Public}")
}
```

Output:

```text
op_ne_AccessLevel diff: true
op_ne_AccessLevel same: false
```
