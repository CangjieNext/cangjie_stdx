# 类

## class Annotation

```cangjie
public class Annotation <: SyntaxTreeNode {
    public init(arguments: Array<Argument>, identifier: String, opKind: AtOpKind, comments!: Array<Comment> = [])
}
```

功能：表示编译器内置的注解节点。

一个 [Annotation](#class-annotation) 节点：`@CallingConv[xxx]`, `@Attribute[xxx]`, `@When[condition]`等。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop arguments

```cangjie
public prop arguments: Array<Argument>
```

功能：获取 [Annotation](#class-annotation) 中的参数序列，如 `@CallingConv[xxx]` 中的 `xxx`。

类型：Array\<[Argument](#class-argument)>

### prop identifier

```cangjie
public prop identifier: String
```

功能：获取 [Annotation](#class-annotation) 节点的标识符，如 `@CallingConv[xxx]` 中的 `CallingConv`。

类型：String

### prop opKind

```cangjie
public prop opKind: AtOpKind
```

功能：获取 [Annotation](#class-annotation) 节点的操作符，如 `@CallingConv[xxx]` 中的 `@`。

类型：[AtOpKind](syntax_package_enums.md#enum-atopkind)

### init(Array\<Argument>, String, AtOpKind, Array\<Comment>)

```cangjie
public init(arguments: Array<Argument>, identifier: String, opKind: AtOpKind, comments!: Array<Comment> = [])
```

功能：构造一个 [Annotation](#class-annotation) 对象，表示语法树中的注解节点。

参数：

- arguments: Array\<[Argument](#class-argument)> - 注解的参数列表。
- identifier: String - 注解的标识符名称，例如 `MyAnnotation`。
- opKind: [AtOpKind](syntax_package_enums.md#enum-atopkind) - 注解操作符类型，如 `@` 或 `@!`。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `identifier` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 arguments
    let arguments = [Argument(
        "a1", 
        false, 
        LitConstExpr(LitConstKind.IntergerLiteral, "123")
    )]

    // 创建 identifier
    let identifier = "MyAnnotation"

    // 创建 opKind
    let opKind = AtOpKind.At

    // 创建 Annotation 实例
    let annotation = Annotation(
        arguments, 
        identifier, 
        opKind
    )

    println("annotation: ${annotation}")
}
```

运行结果：

```text
annotation: @MyAnnotation[a1: 123]
```

### func getAtOpPos()

```cangjie
public func getAtOpPos(): CodePositionRange
```

功能：获取 [Annotation](#class-annotation) 节点中操作符 `@` 或 `@!` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回操作符 `@` 或 `@!` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 arguments
    let arguments = [Argument(
        "a1", 
        false, 
        LitConstExpr(LitConstKind.IntergerLiteral, "123")
    )]

    // 创建 identifier
    let identifier = "MyAnnotation"

    // 创建 opKind
    let opKind = AtOpKind.At

    // 创建 Annotation 实例
    let annotation = Annotation(
        arguments, 
        identifier, 
        opKind
    )
    let pos = annotation.getAtOpPos()

    // 输出 @ 或 @! 操作符位置
    println("annotation.getAtOpPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
annotation.getAtOpPos(): 1:1-1:2
```

### func getCommasPos()

```cangjie
public func getCommasPos(): Array<CodePositionRange>
```

功能：获取 [Annotation](#class-annotation) 节点中 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 arguments
    let arguments = [
        Argument("a1", false, LitConstExpr(LitConstKind.IntergerLiteral, "1")),
        Argument("a2", false, LitConstExpr(LitConstKind.IntergerLiteral, "2")),
        Argument("a3", false, LitConstExpr(LitConstKind.IntergerLiteral, "3"))
    ]

    // 创建 identifier
    let identifier = "MyAnnotation"

    // 创建 opKind
    let opKind = AtOpKind.At

    // 创建 Annotation 实例
    let annotation = Annotation(
        arguments, 
        identifier, 
        opKind
    )
    let posArr = annotation.getCommasPos()

    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("annotation.getCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
annotation.getCommasPos()[0]: 1:20-1:21
annotation.getCommasPos()[1]: 1:27-1:28
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取 [Annotation](#class-annotation) 节点中标识符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回标识符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 arguments
    let arguments = [Argument(
        "a1", 
        false, 
        LitConstExpr(LitConstKind.IntergerLiteral, "123")
    )]

    // 创建 identifier
    let identifier = "MyAnnotation"

    // 创建 opKind
    let opKind = AtOpKind.At

    // 创建 Annotation 实例
    let annotation = Annotation(
        arguments, 
        identifier, 
        opKind
    )
    let pos = annotation.getIdentifierPos()

    // 输出注解名位置
    println("annotation.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
annotation.getIdentifierPos(): 1:2-1:14
```

### func getLSquarePos()

```cangjie
public func getLSquarePos(): Option<CodePositionRange>
```

功能：获取 [Annotation](#class-annotation) 节点中 `[` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `[` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 arguments
    let arguments = [Argument(
        "a1", 
        false, 
        LitConstExpr(LitConstKind.IntergerLiteral, "123")
    )]

    // 创建 identifier
    let identifier = "MyAnnotation"

    // 创建 opKind
    let opKind = AtOpKind.At

    // 创建 Annotation 实例
    let annotation = Annotation(
        arguments, 
        identifier, 
        opKind
    )

    if (let Some(pos) <- annotation.getLSquarePos()) {
        // 输出 [ 位置
        println("annotation.getLSquarePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
annotation.getLSquarePos(): 1:14-1:15
```

### func getRSquarePos()

```cangjie
public func getRSquarePos(): Option<CodePositionRange>
```

功能：获取 [Annotation](#class-annotation) 节点中 `]` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `]` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 arguments
    let arguments = [Argument(
        "a1", 
        false, 
        LitConstExpr(LitConstKind.IntergerLiteral, "123")
    )]

    // 创建 identifier
    let identifier = "MyAnnotation"

    // 创建 opKind
    let opKind = AtOpKind.At

    // 创建 Annotation 实例
    let annotation = Annotation(
        arguments, 
        identifier, 
        opKind
    )

    if (let Some(pos) <- annotation.getRSquarePos()) {
        // 输出 ] 位置
        println("annotation.getRSquarePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
annotation.getRSquarePos(): 1:22-1:23
```

## class Argument

```cangjie
public class Argument <: SyntaxTreeNode {
    public init(identifier: Option<String>, isInOut: Bool, value: Expr, comments!: Array<Comment> = [])
}
```

功能：表示函数调用的实参节点。

例如 `foo(arg:value)` 中的 `arg:value`。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop identifier

```cangjie
public prop identifier: Option<String>
```

功能：获取 [Argument](#class-argument) 节点中的标识符，如 `arg:value` 中的 `arg`（若不存在返回 `None`）。

类型：Option\<String>

### prop isInOut

```cangjie
public prop isInOut: Bool
```

功能：获取 [Argument](#class-argument) 节点是否有关键字 `inout`。

类型：Bool

### prop isNamed

```cangjie
public prop isNamed: Bool
```

功能：获取 [Argument](#class-argument) 节点是否为命名参数。

类型：Bool

### prop value

```cangjie
public prop value: Expr
```

功能：获取 [Argument](#class-argument) 节点中的表达式，如 `arg:value` 中的 `value`。

类型：[Expr](#class-expr)

### init(Option\<String>, Bool, Expr, Array\<Comment>)

```cangjie
public init(identifier: Option<String>, isInOut: Bool, value: Expr, comments!: Array<Comment> = [])
```

功能：构造一个 [Argument](#class-argument) 对象，表示语法树中的参数节点。

参数：

- identifier: Option\<String> - 参数的可选标识符名称。
- isInOut: Bool - 是否为 `inout` 参数。
- value: [Expr](#class-expr) - 参数的值表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `identifier` 不为 `None` 且不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建参数标识符（可选）
    let identifier = "paramName"

    // 设置是否为 inout 参数
    let isInOut = false

    // 创建参数值
    let value = LitConstExpr(LitConstKind.IntergerLiteral, "123")

    // 创建 Argument 实例
    let argument = Argument(
        identifier, 
        isInOut, 
        value
    )

    println("argument: ${argument}")
}
```

运行结果：

```text
argument: paramName: 123
```

### func getColonPos()

```cangjie
public func getColonPos(): Option<CodePositionRange>
```

功能：获取当前 [Argument](#class-argument) 中 `:` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `:` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建参数标识符
    let identifier = "paramName"

    // 设置是否为 inout 参数
    let isInOut = false

    // 创建参数值
    let value = LitConstExpr(LitConstKind.IntergerLiteral, "123")

    // 创建 Argument 实例
    let argument = Argument(
        identifier, 
        isInOut, 
        value
    )

    if (let Some(pos) <- argument.getColonPos()) {
        // 输出冒号位置
        println("argument.getColonPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
argument.getColonPos(): 1:10-1:11
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): Option<CodePositionRange>
```

功能：获取当前 [Argument](#class-argument) 中标识符的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回标识符的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建参数标识符
    let identifier = "paramName"

    // 设置是否为 inout 参数
    let isInOut = false

    // 创建参数值
    let value = LitConstExpr(LitConstKind.IntergerLiteral, "123")

    // 创建 Argument 实例
    let argument = Argument(
        identifier, 
        isInOut, 
        value
    )

    if (let Some(pos) <- argument.getIdentifierPos()) {
        // 输出标识符位置
        println("argument.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
argument.getIdentifierPos(): 1:1-1:10
```

### func getInoutKeyWordPos()

```cangjie
public func getInoutKeyWordPos(): Option<CodePositionRange>
```

功能：获取当前 [Argument](#class-argument) 中 `inout` 关键字的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `inout` 关键字的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建参数标识符
    let identifier = "paramName"

    // 设置为 inout 参数
    let isInOut = true

    // 创建参数值
    let value = LitConstExpr(LitConstKind.IntergerLiteral, "123")

    // 创建 Argument 实例
    let argument = Argument(
        identifier, 
        isInOut, 
        value
    )

    if (let Some(pos) <- argument.getInoutKeyWordPos()) {
        // 输出 inout 关键字位置
        println("argument.getInoutKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
argument.getInoutKeyWordPos(): 1:12-1:17
```

## class ArrayLiteral

```cangjie
public class ArrayLiteral <: Expr {
    public init(elements: Array<Expr>, comments!: Array<Comment> = [])
}
```

功能：表示 Array 字面量节点。

[ArrayLiteral](#class-arrayliteral) 节点：使用格式 `[element1, element2, ... , elementN]` 表示， 每个 `element` 是一个表达式。

父类型：

- [Expr](#class-expr)

### prop elements

```cangjie
public prop elements: Array<Expr>
```

功能：获取 [ArrayLiteral](#class-arrayliteral) 中的表达式列表。

类型：Array\<[Expr](#class-expr)>

### init(Array\<Expr>, Array\<Comment>)

```cangjie
public init(elements: Array<Expr>, comments!: Array<Comment> = [])
```

功能：构造一个 [ArrayLiteral](#class-arrayliteral) 对象，表示数组字面量表达式，如 `[1, 2, 3]`。

参数：

- elements: Array\<[Expr](#class-expr)> - 数组元素表达式列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 elements
    let elements: Array<Expr> = [
        LitConstExpr(LitConstKind.IntergerLiteral, "123"),
        LitConstExpr(LitConstKind.BoolLiteral, "true")
    ]

    // 创建 ArrayLiteral 实例
    let arrayLiteral = ArrayLiteral(
        elements
    )

    println("arrayLiteral: ${arrayLiteral}")
}
```

运行结果：

```text
arrayLiteral: [123, true]
```

### func getCommasPos()

```cangjie
public func getCommasPos(): Array<CodePositionRange>
```

功能：获取当前 [ArrayLiteral](#class-arrayliteral) 中所有 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回所有 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 elements
    let elements: Array<Expr> = [
        LitConstExpr(LitConstKind.IntergerLiteral, "1"),
        LitConstExpr(LitConstKind.IntergerLiteral, "2"),
        LitConstExpr(LitConstKind.IntergerLiteral, "3")
    ]

    // 创建 ArrayLiteral 实例
    let arrayLiteral = ArrayLiteral(elements)
    let posArr = arrayLiteral.getCommasPos()

    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("arrayLiteral.getCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
arrayLiteral.getCommasPos()[0]: 1:3-1:4
arrayLiteral.getCommasPos()[1]: 1:6-1:7
```

### func getLSquarePos()

```cangjie
public func getLSquarePos(): CodePositionRange
```

功能：获取当前 [ArrayLiteral](#class-arrayliteral) 中 `[` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `[` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 elements
    let elements: Array<Expr> = [
        LitConstExpr(LitConstKind.IntergerLiteral, "1"),
        LitConstExpr(LitConstKind.IntergerLiteral, "2")
    ]

    // 创建 ArrayLiteral 实例
    let arrayLiteral = ArrayLiteral(elements)
    let pos = arrayLiteral.getLSquarePos()

    // 输出左方括号位置
    println("arrayLiteral.getLSquarePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
arrayLiteral.getLSquarePos(): 1:1-1:2
```

### func getRSquarePos()

```cangjie
public func getRSquarePos(): CodePositionRange
```

功能：获取当前 [ArrayLiteral](#class-arrayliteral) 中 `]` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `]` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 elements
    let elements: Array<Expr> = [
        LitConstExpr(LitConstKind.IntergerLiteral, "1"),
        LitConstExpr(LitConstKind.IntergerLiteral, "2")
    ]

    // 创建 ArrayLiteral 实例
    let arrayLiteral = ArrayLiteral(elements)
    let pos = arrayLiteral.getRSquarePos()

    // 输出右方括号位置
    println("arrayLiteral.getRSquarePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
arrayLiteral.getRSquarePos(): 1:6-1:7
```

## class AsExpr

```cangjie
public class AsExpr <: Expr {
    public init(srcVal: Expr, targetTypeAnnotation: TypeAnnotation, comments!: Array<Comment> = [])
}
```

功能：表示一个类型转换表达式。

一个 [AsExpr](#class-asexpr) 表达式：`e as T`，类型为 `Option<T>`。其中 `e` 可以是任何类型的表达式，`T` 可以是任何类型。

父类型：

- [Expr](#class-expr)

### prop srcVal

```cangjie
public prop srcVal: Expr
```

功能：获取 [AsExpr](#class-asexpr) 节点中的源表达式节点。

类型：[Expr](#class-expr)

### prop targetTypeAnnotation

```cangjie
public prop targetTypeAnnotation: TypeAnnotation
```

功能：获取 [AsExpr](#class-asexpr) 节点中的目标类型。

类型：[TypeAnnotation](#class-typeannotation)

### init(Expr, TypeAnnotation, Array\<Comment>)

```cangjie
public init(srcVal: Expr, targetTypeAnnotation: TypeAnnotation, comments!: Array<Comment> = [])
```

功能：构造一个 [AsExpr](#class-asexpr) 对象，表示类型转换表达式，如 `x as Int32`。

参数：

- srcVal: [Expr](#class-expr) - 被转换的源表达式。
- targetTypeAnnotation: [TypeAnnotation](#class-typeannotation) - 目标类型。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 srcVal
    let srcVal = SymbolRef("x", [])

    // 创建 targetTypeAnnotation
    let targetTypeAnnotation = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 AsExpr 实例
    let asExpr = AsExpr(
        srcVal, 
        targetTypeAnnotation
    )

    println("asExpr: ${asExpr}")
}
```

运行结果：

```text
asExpr: x as Int64
```

### func getAsKeyWordPos()

```cangjie
public func getAsKeyWordPos(): CodePositionRange
```

功能：获取 `as` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `as` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 srcVal
    let srcVal = SymbolRef("x", [])

    // 创建 targetTypeAnnotation
    let targetTypeAnnotation = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 AsExpr 实例
    let asExpr = AsExpr(srcVal, targetTypeAnnotation)
    let pos = asExpr.getAsKeyWordPos()

    // 输出 as 关键字位置
    println("asExpr.getAsKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
asExpr.getAsKeyWordPos(): 1:3-1:5
```

## class AssignExpr

```cangjie
public class AssignExpr <: Expr {
    public init(assignOpKind: AssignOpKind, lhs: SyntaxTreeNode, rhs: Expr, comments!: Array<Comment> = [])
}
```

功能：表示赋值表达式节点。

用于将左操作数的值修改为右操作数的值。一个 [AssignExpr](#class-assignexpr) 节点：`a = b`。

父类型：

- [Expr](#class-expr)

### prop assignOpKind

```cangjie
public prop assignOpKind: AssignOpKind
```

功能：获取 [AssignExpr](#class-assignexpr) 节点中的赋值操作符类型（如 `=` 等）。

类型：[AssignOpKind](syntax_package_enums.md#enum-assignopkind)

### prop lhs

```cangjie
public prop lhs: SyntaxTreeNode
```

功能：获取 [AssignExpr](#class-assignexpr) 节点中的左操作数。

类型：[SyntaxTreeNode](#class-syntaxtreenode)

### prop rhs

```cangjie
public prop rhs: Expr
```

功能：获取 [AssignExpr](#class-assignexpr) 节点中的右操作数。

类型：[Expr](#class-expr)

### init(AssignOpKind, SyntaxTreeNode, Expr, Array\<Comment>)

```cangjie
public init(assignOpKind: AssignOpKind, lhs: SyntaxTreeNode, rhs: Expr, comments!: Array<Comment> = [])
```

功能：构造一个 [AssignExpr](#class-assignexpr) 对象，表示赋值表达式。

参数：

- assignOpKind: [AssignOpKind](syntax_package_enums.md#enum-assignopkind) - 赋值操作符类型。
- lhs: [SyntaxTreeNode](#class-syntaxtreenode) - 左操作数节点。
- rhs: [Expr](#class-expr) - 右操作数表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 assignOpKind
    let assignOpKind = AssignOpKind.Assign

    // 创建 lhs
    let lhs = SymbolRef("a", [])

    // 创建 rhs
    let rhs = LitConstExpr(LitConstKind.IntergerLiteral, "3")

    // 创建 AssignExpr 实例
    let assignExpr = AssignExpr(
        assignOpKind, 
        lhs, 
        rhs
    )

    println("assignExpr: ${assignExpr}")
}
```

运行结果：

```text
assignExpr: a = 3
```

### func getAssignOpPos()

```cangjie
public func getAssignOpPos(): CodePositionRange
```

功能：获取赋值操作符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回赋值操作符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 assignOpKind
    let assignOpKind = AssignOpKind.Assign

    // 创建 lhs
    let lhs = SymbolRef("a", [])

    // 创建 rhs
    let rhs = LitConstExpr(LitConstKind.IntergerLiteral, "3")

    // 创建 AssignExpr 实例
    let assignExpr = AssignExpr(assignOpKind, lhs, rhs)
    let pos = assignExpr.getAssignOpPos()

    // 输出赋值操作符位置
    println("assignExpr.getAssignOpPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
assignExpr.getAssignOpPos(): 1:3-1:4
```

## class ASTRewriter

```cangjie
public open class ASTRewriter {}
```

功能：语法树的重写器基类，提供对语法树节点的遍历时重写节点内容的能力。

> **说明：**
>
> - 通过 `walk` 方法自顶向下遍历语法树，并在遍历过程中调用 `rewrite` 方法对节点进行重写；
> - 支持对任意语法树节点进行遍历及重写；
> - 重写过程中会保持节点类型一致性，若重写后节点类型发生变化将抛出异常。

### func rewrite(SyntaxTreeNode)

```cangjie
public open func rewrite(node: SyntaxTreeNode): SyntaxTreeNode
```

功能：重写单个语法树节点，默认实现为直接返回原节点，子类可重写此方法以实现自定义的节点替换逻辑。

参数：

- node: [SyntaxTreeNode](#class-syntaxtreenode) - 待重写的语法树节点。

返回值：

- [SyntaxTreeNode](#class-syntaxtreenode) - 重写后的语法树节点。

示例：

<!-- compile -->
```cangjie
import stdx.syntax.*
import std.collection.ArrayList

// 继承 ASTRewriter
class DocStubGenerator <: ASTRewriter {
    public override func rewrite(node: SyntaxTreeNode): SyntaxTreeNode {
        match (node) {
            case fn: FuncDecl =>
                let comment = Comment(
                    "// @brief describe ${fn.name}"
                )
                let newComments = ArrayList<Comment>(fn.comments)
                newComments.add(comment)
                // 2. 修改 FuncDecl 中的 comments 属性
                let f = FuncDecl(
                    fn.body,
                    fn.genericConstraints,
                    fn.genericParams,
                    fn.kind,
                    fn.name,
                    fn.params,
                    fn.retTyAnnotation,
                    annotations: fn.annotations,
                    modifiers: fn.modifiers,
                    comments: newComments.toArray()
                )
                return f
            case _ => return node
        }
    }
}

main() {
    let root = parseFile("path/to/source/main.cj")

    // 利用实现的 DocStubGenerator 重写节点
    let generator = DocStubGenerator()
    let newNode = generator.walk(root.node.getOrThrow(), detach: true)

    println(newNode)
}
```

### func walk(SyntaxTreeNode, Bool)

```cangjie
public func walk(startPoint: SyntaxTreeNode, detach!: Bool = false): SyntaxTreeNode
```

功能：对指定的语法树节点进行遍历与重写。

> **说明：**
>
> - 若 `detach` 为 `true`，遍历后产生一颗独立的新树，新树的父节点为空；若 `detach` 为 `false`，会向上刷新父节点中的内容。

参数：

- startPoint: [SyntaxTreeNode](#class-syntaxtreenode) - 起始节点，可以是任意语法树节点或整包节点。
- detach!: Bool - 是否断开与父节点的关联，默认为 `false`。

返回值：

- [SyntaxTreeNode](#class-syntaxtreenode) - 重写后的新语法树节点。

异常：

- Exception - 当重写后的节点类型与原始节点类型不一致时，抛出异常。

示例：

<!-- compile -->
```cangjie
import stdx.syntax.*
import std.collection.ArrayList

// 继承 ASTRewriter
class DocStubGenerator <: ASTRewriter {
    public override func rewrite(node: SyntaxTreeNode): SyntaxTreeNode {
        match (node) {
            case fn: FuncDecl =>
                let comment = Comment(
                    "// @brief describe ${fn.name}"
                )
                let newComments = ArrayList<Comment>(fn.comments)
                newComments.add(comment)
                // 2. 修改 FuncDecl 中的 comments 属性
                let f = FuncDecl(
                    fn.body,
                    fn.genericConstraints,
                    fn.genericParams,
                    fn.kind,
                    fn.name,
                    fn.params,
                    fn.retTyAnnotation,
                    annotations: fn.annotations,
                    modifiers: fn.modifiers,
                    comments: newComments.toArray()
                )
                return f
            case _ => return node
        }
    }
}

main() {
    let root = parseFile("path/to/source/main.cj")

    // 利用实现的 DocStubGenerator 重写节点
    let generator = DocStubGenerator()
    let newNode = generator.walk(root.node.getOrThrow(), detach: true)

    println(newNode)
}
```

## class ASTVisitor

```cangjie
public open class ASTVisitor {}
```

功能：语法树的通用访问器基类。开发者可以通过遍历 [SyntaxTreeNode](#class-syntaxtreenode) 及其子类，实现对 `Cangjie` 源代码结构的统一访问与处理。

### func postAction(SyntaxTreeNode)

```cangjie
public open func postAction(node: SyntaxTreeNode): PostActionMode
```

功能：在离开节点后执行的钩子函数，用于决定是否继续或停止遍历，当 `preAction` 停止时， `postAction` 也会立即停止。

参数：

- node: [SyntaxTreeNode](#class-syntaxtreenode) - 当前已访问完成的节点。

返回值：

- [PostActionMode](syntax_package_enums.md#enum-postactionmode) - 访问节点完成后的行为策略。

示例：

<!-- compile -->
```cangjie
import stdx.syntax.*

// 继承 ASTVisitor
public class BinaryCounter <: ASTVisitor {
    public var count = 0

    // 重写 postAction，在进入节点后做判断
    public override func postAction(node: SyntaxTreeNode): PostActionMode {
        match (node) {
            // 遇到 BinaryExpr 时计数 +1 并继续
            case _: BinaryExpr =>
                count += 1
                return PostActionMode.Continue

            // 遇到 CallExpr 停止整个遍历
            case _: CallExpr =>
                println("Found CallExpr, stop traversal")
                return PostActionMode.Stop

            // 其它节点保持默认行为
            case _ => PostActionMode.Continue
        }
    }
}

main() {
    let root = parseFile("path/to/source/main.cj")

    let counter = BinaryCounter()
    if (let Some(node) <- root.node) {
        // 进行遍历
        counter.walk(node)
    }

    println("Total BinaryExpr count: ${counter.count}")
}
```

### func preAction(SyntaxTreeNode)

```cangjie
public open func preAction(node: SyntaxTreeNode): PreActionMode
```

功能：在进入节点前执行的钩子函数，用于决定是否继续、跳过或停止遍历。

参数：

- node: [SyntaxTreeNode](#class-syntaxtreenode) - 当前即将访问的节点。

返回值：

- [PreActionMode](syntax_package_enums.md#enum-preactionmode) - 访问节点前的行为策略。

示例：

<!-- compile -->
```cangjie
import stdx.syntax.*

//继承 ASTVisitor
public class BinaryCounter <: ASTVisitor {
    public var count = 0

    // 重写 preAction，只在进入节点前做判断
    public override func preAction(node: SyntaxTreeNode): PreActionMode {
        match (node) {
            // 遇到 BinaryExpr 时计数 +1 并继续
            case _: BinaryExpr =>
                count += 1
                return PreActionMode.Continue

            // 遇到 CallExpr 立即停止整个遍历
            case _: CallExpr =>
                println("Found CallExpr, stop traversal")
                return PreActionMode.Stop

            // 其它节点保持默认行为
            case _ => PreActionMode.Continue
        }
    }
}

main() {
    let root = parseFile("path/to/source/main.cj")

    let counter = BinaryCounter()
    if (let Some(node) <- root.node) {
        // 进行遍历
        counter.walk(node)
    }

    println("Total BinaryExpr count: ${counter.count}")
}
```

### func walk(SyntaxTreeNode)

```cangjie
public func walk(root: SyntaxTreeNode): Unit
```

功能：从指定节点开始深度优先遍历 `AST`。

参数：

- root: [SyntaxTreeNode](#class-syntaxtreenode) - 遍历的起始节点。

示例：

<!-- compile -->
```cangjie
import stdx.syntax.*

//继承 ASTVisitor
public class BinaryCounter <: ASTVisitor {
    public var count = 0

    // 重写 preAction，只在进入节点前做判断
    public override func preAction(node: SyntaxTreeNode): PreActionMode {
        match (node) {
            // 遇到 BinaryExpr 时计数 +1 并继续
            case _: BinaryExpr =>
                count += 1
                return PreActionMode.Continue

            // 遇到 CallExpr 立即停止整个遍历
            case _: CallExpr =>
                println("Found CallExpr, stop traversal")
                return PreActionMode.Stop

            // 其它节点保持默认行为
            case _ => PreActionMode.Continue
        }
    }
}

main() {
    let root = parseFile("path/to/source/main.cj")

    let counter = BinaryCounter()
    if (let Some(node) <- root.node) {
        // 进行遍历
        counter.walk(node)
    }

    println("Total BinaryExpr count: ${counter.count}")
}
```

## class AtomicType

```cangjie
public class AtomicType <: TypeAnnotation {
    public init(kind: AtomicTypeKind, comments!: Array<Comment> = [])
}
```

功能：表示一个基本类型节点。

例如数值类型，字符类型，布尔类型等。

父类型：

- [TypeAnnotation](#class-typeannotation)

### prop kind

```cangjie
public prop kind: AtomicTypeKind
```

功能：获取 [AtomicType](#class-atomictype) 的具体类型。

类型：[AtomicTypeKind](syntax_package_enums.md#enum-atomictypekind)

### init(AtomicTypeKind, Array\<Comment>)

```cangjie
public init(kind: AtomicTypeKind, comments!: Array<Comment> = [])
```

功能：构造一个 [AtomicType](#class-atomictype) 对象，表示原子类型，如 `Int64`、`Bool` 等。

参数：

- kind: [AtomicTypeKind](syntax_package_enums.md#enum-atomictypekind) - 原子类型种类。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 kind
    let kind = AtomicTypeKind.UInt32Type

    // 创建 AtomicType 实例
    let atomicType = AtomicType(
        kind
    )

    println("atomicType: ${atomicType}")
}
```

运行结果：

```text
atomicType: UInt32
```

## class BinaryExpr

```cangjie
public class BinaryExpr <: Expr {
    public init(lhs: Expr, opKind: BinaryOpKind, rhs: Expr, comments!: Array<Comment> = [])
}
```

功能：表示一个二元操作表达式节点。

一个 [BinaryExpr](#class-binaryexpr) 节点：`1 + 2`

父类型：

- [Expr](#class-expr)

### prop lhs

```cangjie
public prop lhs: Expr
```

功能：获取 [BinaryExpr](#class-binaryexpr) 节点中操作符左侧的表达式节点。

类型：[Expr](#class-expr)

### prop opKind

```cangjie
public prop opKind: BinaryOpKind
```

功能：获取 [BinaryExpr](#class-binaryexpr) 节点中的二元操作符类型。

类型：[BinaryOpKind](syntax_package_enums.md#enum-binaryopkind)

### prop rhs

```cangjie
public prop rhs: Expr
```

功能：获取 [BinaryExpr](#class-binaryexpr) 节点中操作符右侧的表达式节点。

类型：[Expr](#class-expr)

### init(Expr, BinaryOpKind, Expr, Array\<Comment>)

```cangjie
public init(lhs: Expr, opKind: BinaryOpKind, rhs: Expr, comments!: Array<Comment> = [])
```

功能：构造一个 [BinaryExpr](#class-binaryexpr) 对象，表示二元运算表达式，如 `x + y`。

参数：

- lhs: [Expr](#class-expr) - 左操作数表达式。
- opKind: [BinaryOpKind](syntax_package_enums.md#enum-binaryopkind) - 二元操作符类型。
- rhs: [Expr](#class-expr) - 右操作数表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 lhs
    let lhs = SymbolRef("x", [])

    // 创建 opKind
    let opKind = BinaryOpKind.Add

    // 创建 rhs
    let rhs = SymbolRef("y", [])

    // 创建 BinaryExpr 实例
    let binaryExpr = BinaryExpr(
        lhs, 
        opKind, 
        rhs
    )

    println("binaryExpr: ${binaryExpr}")
}
```

运行结果：

```text
binaryExpr: x + y
```

### func getOperatorPos()

```cangjie
public func getOperatorPos(): CodePositionRange
```

功能：获取二元操作符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回二元操作符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 lhs
    let lhs = SymbolRef("x", [])

    // 创建 opKind
    let opKind = BinaryOpKind.Add

    // 创建 rhs
    let rhs = SymbolRef("y", [])

    // 创建 BinaryExpr 实例
    let binaryExpr = BinaryExpr(lhs, opKind, rhs)
    let pos = binaryExpr.getOperatorPos()

    // 输出操作符位置
    println("binaryExpr.getOperatorPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
binaryExpr.getOperatorPos(): 1:3-1:4
```

## class Block

```cangjie
public class Block <: SyntaxTreeNode {
    public init(nodes: Array<SyntaxTreeNode>, comments!: Array<Comment> = [])
}
```

功能：表示一个块节点。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop nodes

```cangjie
public prop nodes: Array<SyntaxTreeNode>
```

功能：获取 [Block](#class-block) 中的表达式或声明序列。

类型：Array\<[SyntaxTreeNode](#class-syntaxtreenode)>

### init(Array\<SyntaxTreeNode>, Array\<Comment>)

```cangjie
public init(nodes: Array<SyntaxTreeNode>, comments!: Array<Comment> = [])
```

功能：构造一个 [Block](#class-block) 对象，表示语法树中的代码块节点。

参数：

- nodes: Array\<[SyntaxTreeNode](#class-syntaxtreenode)> - 块内的子节点列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `nodes` 中的节点不是表达式类型、函数声明或变量声明时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 nodes
    let nodes: Array<SyntaxTreeNode> = [
        LitConstExpr(LitConstKind.IntergerLiteral, "123")
    ]

    // 创建 Block 实例
    let block = Block(
        nodes
    )

    println("block: ${block}")
}
```

运行结果：

```text
block: {
    123
}
```

### func getLCurlPos()

```cangjie
public func getLCurlPos(): CodePositionRange
```

功能：获取 [Block](#class-block) 节点中 `{` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `{` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 nodes
    let nodes: Array<SyntaxTreeNode> = [
        LitConstExpr(LitConstKind.IntergerLiteral, "123")
    ]

    // 创建 Block 实例
    let block = Block(nodes)
    let pos = block.getLCurlPos()

    // 输出左花括号位置
    println("block.getLCurlPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
block.getLCurlPos(): 1:1-1:2
```

### func getRCurlPos()

```cangjie
public func getRCurlPos(): CodePositionRange
```

功能：获取 [Block](#class-block) 节点中 `}` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `}` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 nodes
    let nodes: Array<SyntaxTreeNode> = [
        LitConstExpr(LitConstKind.IntergerLiteral, "123")
    ]

    // 创建 Block 实例
    let block = Block(nodes)
    let pos = block.getRCurlPos()

    // 输出右花括号位置
    println("block.getRCurlPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
block.getRCurlPos(): 3:1-3:2
```

## class Body

```cangjie
public class Body <: SyntaxTreeNode {
    public init(memberDecls: Array<Decl>, comments!: Array<Comment> = [])
}
```

功能：表示 `Class` 类型、 `Struct` 类型、 `Interface` 类型以及扩展中由 `{}` 和内部的一组声明节点组成的结构。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop memberDecls

```cangjie
public prop memberDecls: Array<Decl>
```

功能：获取 [Body](#class-body) 内的声明节点集合。

类型：Array\<[Decl](#class-decl)>

### init(Array\<Decl>, Array\<Comment>)

```cangjie
public init(memberDecls: Array<Decl>, comments!: Array<Comment> = [])
```

功能：构造一个 [Body](#class-body) 对象，表示语法树中的声明体节点。

参数：

- memberDecls: Array\<[Decl](#class-decl)> - 成员声明列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建一个变量声明
    let initializer = LitConstExpr(LitConstKind.IntergerLiteral, "1")
    let varDecl = VarDecl(initializer, VarKind.Let, "x", VarPattern("x"), AtomicType(AtomicTypeKind.Int64Type))
    
    // 创建成员声明列表
    let memberDecls: Array<Decl> = [varDecl]
    
    // 创建 Body 实例
    let body = Body(memberDecls)
    
    println("body: ${body}")
}
```

运行结果：

```text
body: {
    let x: Int64 = 1
}
```

### func getLCurlPos()

```cangjie
public func getLCurlPos(): CodePositionRange
```

功能：获取 [Body](#class-body) 节点中 `{` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `{` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建一个变量声明
    let initializer = LitConstExpr(LitConstKind.IntergerLiteral, "1")
    let varDecl = VarDecl(initializer, VarKind.Let, "x", VarPattern("x"), AtomicType(AtomicTypeKind.Int64Type))
    
    // 创建成员声明列表
    let memberDecls: Array<Decl> = [varDecl]
    
    // 创建 Body 实例
    let body = Body(memberDecls)
    
    // 获取左花括号位置
    let pos = body.getLCurlPos()
    
    // 输出左花括号位置
    println("body.getLCurlPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
body.getLCurlPos(): 1:1-1:2
```

### func getRCurlPos()

```cangjie
 public func getRCurlPos(): CodePositionRange
```

功能：获取 [Body](#class-body) 节点中 `}` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `}` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建一个变量声明
    let initializer = LitConstExpr(LitConstKind.IntergerLiteral, "1")
    let varDecl = VarDecl(initializer, VarKind.Let, "x", VarPattern("x"), AtomicType(AtomicTypeKind.Int64Type))
    
    // 创建成员声明列表
    let memberDecls: Array<Decl> = [varDecl]
    
    // 创建 Body 实例
    let body = Body(memberDecls)
    
    // 获取右花括号位置
    let pos = body.getRCurlPos()
    
    // 输出右花括号位置
    println("body.getRCurlPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
body.getRCurlPos(): 3:1-3:2
```

## class BreakExpr

```cangjie
public class BreakExpr <: Expr {
    public init(comments!: Array<Comment> = [])
}
```

功能：表示中断表达式。

用于终止当前循环语句，并将控制权转移到外层代码。[BreakExpr](#class-breakexpr) 节点以 `break` 关键字表示，通常用于循环体内部，以提前退出循环。

父类型：

- [Expr](#class-expr)

### init(Array\<Comment>)

```cangjie
public init(comments!: Array<Comment> = [])
```

功能：构造一个 [BreakExpr](#class-breakexpr) 对象，表示 `break` 表达式。

参数：

- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 BreakExpr 实例
    let breakexpr = BreakExpr()

    println("breakexpr: ${breakexpr}")
}
```

运行结果：

```text
breakexpr: break
```

## class CallExpr

```cangjie
public class CallExpr <: Expr {
    public init(callee: Expr, arguments: Array<Argument>, comments!: Array<Comment> = [])
}
```

功能：表示函数调用节点。

一个 [CallExpr](#class-callexpr) 节点包括一个表达式，后面紧跟参数列表，例如 `foo(100)`。

父类型：

- [Expr](#class-expr)

### prop arguments

```cangjie
public prop arguments: Array<Argument>
```

功能：获取 [CallExpr](#class-callexpr) 节点中的函数参数。

类型：Array\<[Argument](#class-argument)>

### prop callee

```cangjie
public prop callee: Expr
```

功能：获取 [CallExpr](#class-callexpr) 节点中的函数调用节点。

类型：[Expr](#class-expr)

### init(Expr, Array\<Argument>, Array\<Comment>)

```cangjie
public init(callee: Expr, arguments: Array<Argument>, comments!: Array<Comment> = [])
```

功能：构造一个 [CallExpr](#class-callexpr) 对象，表示函数调用表达式，如 `f(x, y)`。

参数：

- callee: [Expr](#class-expr) - 被调用的函数表达式。
- arguments: Array\<[Argument](#class-argument)> - 实参列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当调用表达式不是成员访问或引用表达式时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 callee
    let callee = SymbolRef("foo", [])

    // 创建 arguments
    let arguments = [Argument(
        "a1", 
        false, 
        LitConstExpr(LitConstKind.IntergerLiteral, "123")
    )]

    // 创建 CallExpr 实例
    let callExpr = CallExpr(
        callee, 
        arguments
    )

    println("callExpr: ${callExpr}")
}
```

运行结果：

```text
callExpr: foo(a1: 123)
```

### func getCommasPos()

```cangjie
public func getCommasPos(): Array<CodePositionRange>
```

功能：获取 [CallExpr](#class-callexpr) 节点中 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 callee
    let callee = SymbolRef("foo", [])

    // 创建 arguments
    let arguments = [
        Argument("a1", false, LitConstExpr(LitConstKind.IntergerLiteral, "1")),
        Argument("a2", false, LitConstExpr(LitConstKind.IntergerLiteral, "2")),
        Argument("a3", false, LitConstExpr(LitConstKind.IntergerLiteral, "3"))
    ]

    // 创建 CallExpr 实例
    let callExpr = CallExpr(callee, arguments)
    let posArr = callExpr.getCommasPos()

    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("callExpr.getCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
callExpr.getCommasPos()[0]: 1:10-1:11
callExpr.getCommasPos()[1]: 1:17-1:18
```

### func getLParenPos()

```cangjie
public func getLParenPos(): CodePositionRange
```

功能：获取当前 [CallExpr](#class-callexpr) 中 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 callee
    let callee = SymbolRef("foo", [])

    // 创建 arguments
    let arguments = [Argument("a1", false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))]

    // 创建 CallExpr 实例
    let callExpr = CallExpr(callee, arguments)
    let pos = callExpr.getLParenPos()

    // 输出左括号位置
    println("callExpr.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
callExpr.getLParenPos(): 1:4-1:5
```

### func getRParenPos()

```cangjie
public func getRParenPos(): CodePositionRange
```

功能：获取当前 [CallExpr](#class-callexpr) 中 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 callee
    let callee = SymbolRef("foo", [])

    // 创建 arguments
    let arguments = [Argument("a1", false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))]

    // 创建 CallExpr 实例
    let callExpr = CallExpr(callee, arguments)
    let pos = callExpr.getRParenPos()

    // 输出右括号位置
    println("callExpr.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
callExpr.getRParenPos(): 1:12-1:13
```

## class CatchPattern

```cangjie
public class CatchPattern <: SyntaxTreeNode {
    public init(pattern: Pattern, exceptionType: Array<TypeAnnotation>, comments!: Array<Comment> = [])
}
```

功能：表示一个捕获模式。

用于获取 [TryCatch](#class-trycatch) 中通过模式匹配的方式匹配待捕获的异常序列。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop exceptionType

```cangjie
public prop exceptionType: Array<TypeAnnotation>
```

功能：获取当前捕获模式的异常类型列表。

类型：Array\<[TypeAnnotation](#class-typeannotation)>

### prop pattern

```cangjie
public prop pattern: Pattern
```

功能：获取当前捕获模式的模式。

类型：[Pattern](#class-pattern)

### init(Pattern, Array\<TypeAnnotation>, Array\<Comment>)

```cangjie
public init(pattern: Pattern, exceptionType: Array<TypeAnnotation>, comments!: Array<Comment> = [])
```

功能：构造一个 [CatchPattern](#class-catchpattern) 对象，表示 `catch` 子句中的异常捕获模式。

参数：

- pattern: [Pattern](#class-pattern) - 用于绑定异常的模式。
- exceptionType: Array\<[TypeAnnotation](#class-typeannotation)> - 可捕获的异常类型列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `pattern` 不为 [WildcardPattern](#class-wildcardpattern) 或 [VarPattern](#class-varpattern)，或当 `pattern` 为 [VarPattern](#class-varpattern) 但 `exceptionType` 为空时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 pattern
    let pattern = VarPattern("x")

    // 创建 exceptionType
    let exceptionType: Array<TypeAnnotation> = [CompositeType("I1", [], []), CompositeType("I2", [], [])]

    // 创建 CatchPattern 实例
    let catchPattern = CatchPattern(
        pattern, 
        exceptionType
    )

    println("catchPattern: ${catchPattern}")
}
```

运行结果：

```text
catchPattern: x: I1 | I2
```

### func getBitOrsPos()

```cangjie
public func getBitOrsPos(): Array<CodePositionRange>
```

功能：获取 [CatchPattern](#class-catchpattern) 节点中 `|` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `|` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 pattern
    let pattern = VarPattern("x")

    // 创建 exceptionType
    let exceptionType: Array<TypeAnnotation> = [
        CompositeType("I1", [], []),
        CompositeType("I2", [], []),
        CompositeType("I3", [], [])
    ]

    // 创建 CatchPattern 实例
    let catchPattern = CatchPattern(pattern, exceptionType)
    let posArr = catchPattern.getBitOrsPos()

    // 遍历输出竖线位置
    for (i in 0..posArr.size) {
        println("catchPattern.getBitOrsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
catchPattern.getBitOrsPos()[0]: 1:7-1:8
catchPattern.getBitOrsPos()[1]: 1:12-1:13
```

### func getColonPos()

```cangjie
public func getColonPos(): Option<CodePositionRange>
```

功能：获取 [CatchPattern](#class-catchpattern) 节点中 `:` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `:` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 pattern
    let pattern = VarPattern("x")

    // 创建 exceptionType
    let exceptionType: Array<TypeAnnotation> = [CompositeType("I1", [], []), CompositeType("I2", [], [])]

    // 创建 CatchPattern 实例
    let catchPattern = CatchPattern(pattern, exceptionType)

    if (let Some(pos) <- catchPattern.getColonPos()) {
        // 输出冒号位置
        println("catchPattern.getColonPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
catchPattern.getColonPos(): 1:2-1:3
```

## class ClassDecl

```cangjie
public class ClassDecl <: Decl {
    public init(body: Body, genericConstraints: Option<GenericConstraints>, genericParams: Array<GenericParam>,
        name: String, superTyAnnotations: Array<TypeAnnotation>, annotations!: Array<Annotation> = [],
        modifiers!: Array<Modifier> = [], comments!: Array<Comment> = [])
}
```

功能：表示一个类声明节点。

类的声明使用 `class` 关键字，声明依次为：可缺省的修饰符、`class` 关键字、`class` 名、可选的类型参数、是否指定父类或父接口、可选的泛型约束、类体的声明。

父类型：

- [Decl](#class-decl)

### prop body

```cangjie
public prop body: Body
```

功能：获取当前类声明的主体部分。

类型：[Body](#class-body)

### prop genericConstraints

```cangjie
public prop genericConstraints: Option<GenericConstraints>
```

功能：获取当前类声明的泛型约束（若不存在返回 `None`）。

类型：Option\<[GenericConstraints](#class-genericconstraints)>

### prop genericParams

```cangjie
public prop genericParams: Array<GenericParam>
```

功能：获取当前类声明的泛型参数列表。

类型：Array\<[GenericParam](#class-genericparam)>

### prop name

```cangjie
public prop name: String
```

功能：获取当前类声明的名称。

类型：String

### prop superTyAnnotations

```cangjie
public prop superTyAnnotations: Array<TypeAnnotation>
```

功能：获取当前类声明的父类类型标注列表。

类型：Array\<[TypeAnnotation](#class-typeannotation)>

### init(Body, Option\<GenericConstraints>, Array\<GenericParam>, String, Array\<TypeAnnotation>, Array\<Annotation>, Array\<Modifier>, Array\<Comment>)

```cangjie
public init(body: Body, genericConstraints: Option<GenericConstraints>, genericParams: Array<GenericParam>,
    name: String, superTyAnnotations: Array<TypeAnnotation>, annotations!: Array<Annotation> = [],
    modifiers!: Array<Modifier> = [], comments!: Array<Comment> = [])
```

功能：构造一个 [ClassDecl](#class-classdecl) 对象，表示类声明节点。

参数：

- body: [Body](#class-body) - 类体，包含成员声明。
- genericConstraints: Option\<[GenericConstraints](#class-genericconstraints)> - 可选的泛型约束。
- genericParams: Array\<[GenericParam](#class-genericparam)> - 泛型参数列表。
- name: String - 类名。
- superTyAnnotations: Array\<[TypeAnnotation](#class-typeannotation)> - 父类类型标注列表。
- annotations!: Array\<[Annotation](#class-annotation)> - 附加的注解列表，默认为空数组。
- modifiers!: Array\<[Modifier](#class-modifier)> - 修饰符列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `body` 中有除静态初始化器、函数声明、变量声明、宏展开声明和属性声明外的声明或当泛型约束与泛型参数不对应，或输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 annotations
    let annotations = [Annotation([Argument(None, false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))], "MyAnno", AtOpKind.At)]
    
    // 创建 modifiers
    let modifiers = [Modifier(ModifierKind.Public)]
    
    // 创建 ClassDecl 实例
    let classDecl = ClassDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations, 
        annotations: annotations, 
        modifiers: modifiers
    )
    
    println("classDecl: ${classDecl}")
}
```

运行结果：

```text
classDecl: @MyAnno[123]
public class A<T> <: I1 where T<:I1 {
}
```

### func getClassKeyWordPos()

```cangjie
public func getClassKeyWordPos(): CodePositionRange
```

功能：获取 [ClassDecl](#class-classdecl) 节点中 `class` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `class` 关键字 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 ClassDecl 实例
    let classDecl = ClassDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations
    )
    
    // 获取 class 关键字位置
    let pos = classDecl.getClassKeyWordPos()
    
    // 输出 class 关键字位置
    println("classDecl.getClassKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
classDecl.getClassKeyWordPos(): 1:1-1:6
```

### func getGenericParamsCommasPos()

```cangjie
public func getGenericParamsCommasPos(): Array<CodePositionRange>
```

功能：获取 [ClassDecl](#class-classdecl) 节点中泛型参数中 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数中 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T"), GenericParam("U"), GenericParam("V")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 ClassDecl 实例
    let classDecl = ClassDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations
    )
    
    // 获取泛型参数中逗号的位置
    let posArr = classDecl.getGenericParamsCommasPos()
    
    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("classDecl.getGenericParamsCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
classDecl.getGenericParamsCommasPos()[0]: 1:10-1:11
classDecl.getGenericParamsCommasPos()[1]: 1:13-1:14
```

### func getGenericParamsLAnglePos()

```cangjie
public func getGenericParamsLAnglePos(): Option<CodePositionRange>
```

功能：获取 [ClassDecl](#class-classdecl) 节点中泛型参数的 `<` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数的 `<` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 ClassDecl 实例
    let classDecl = ClassDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations
    )
    
    // 获取泛型参数左尖括号的位置
    if (let Some(pos) <- classDecl.getGenericParamsLAnglePos()) {
        // 输出左尖括号位置
        println("classDecl.getGenericParamsLAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    } else {
        println("No left angle bracket found")
    }
}
```

运行结果：

```text
classDecl.getGenericParamsLAnglePos(): 1:8-1:9
```

### func getGenericParamsRAnglePos()

```cangjie
public func getGenericParamsRAnglePos(): Option<CodePositionRange>
```

功能：获取 [ClassDecl](#class-classdecl) 节点中泛型参数的 `>` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数的 `>` 的位置（若不存在返回 `None`）

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 ClassDecl 实例
    let classDecl = ClassDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations
    )
    
    // 获取泛型参数右尖括号的位置
    if (let Some(pos) <- classDecl.getGenericParamsRAnglePos()) {
        // 输出右尖括号位置
        println("classDecl.getGenericParamsRAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    } else {
        println("No right angle bracket found")
    }
}
```

运行结果：

```text
classDecl.getGenericParamsRAnglePos(): 1:10-1:11
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取 [ClassDecl](#class-classdecl) 节点中标识符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回标识符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 ClassDecl 实例
    let classDecl = ClassDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations
    )
    
    // 获取标识符的位置
    let pos = classDecl.getIdentifierPos()
    
    // 输出标识符位置
    println("classDecl.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
classDecl.getIdentifierPos(): 1:7-1:8
```

### func getSuperTyAnnotationsBitAndsPos()

```cangjie
public func getSuperTyAnnotationsBitAndsPos(): Array<CodePositionRange>
```

功能：获取 [ClassDecl](#class-classdecl) 节点中父类型中 `&` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回父类型中 `&` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T")]
    
    // 创建 name
    let name = "A"
    
    // 创建多个父类型（使用 & 连接）
    let superTyAnnotations: Array<TypeAnnotation> = [
        CompositeType("I1", [], []),
        CompositeType("I2", [], []),
        CompositeType("I3", [], [])
    ]
    
    // 创建 ClassDecl 实例
    let classDecl = ClassDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations
    )
    
    // 获取父类型中 & 的位置
    let posArr = classDecl.getSuperTyAnnotationsBitAndsPos()
    
    // 遍历输出 & 位置
    for (i in 0..posArr.size) {
        println("classDecl.getSuperTyAnnotationsBitAndsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
classDecl.getSuperTyAnnotationsBitAndsPos()[0]: 1:18-1:19
classDecl.getSuperTyAnnotationsBitAndsPos()[1]: 1:23-1:24
```

### func getUpperBoundPos()

```cangjie
public func getUpperBoundPos(): Option<CodePositionRange>
```

功能：获取 [ClassDecl](#class-classdecl) 节点中 `<:` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `<:` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 ClassDecl 实例
    let classDecl = ClassDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations
    )
    
    // 获取 <: 位置
    if (let Some(pos) <- classDecl.getUpperBoundPos()) {
        // 输出 <: 位置
        println("classDecl.getUpperBoundPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    } else {
        println("No upper bound found")
    }
}
```

运行结果：

```text
classDecl.getUpperBoundPos(): 1:12-1:14
```

## class Comment

```cangjie
public class Comment <: SyntaxTreeNode {
    public init(content: String)
}
```

功能：表示一个注释信息节点。例如 `// comment`。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop content

```cangjie
public prop content: String
```

功能：表示注释信息的内容。

类型：String

### prop kind

```cangjie
public prop kind: CommentKind
```

功能：表示注释的类型。

类型：[CommentKind](syntax_package_enums.md#enum-commentkind)

### init(String)

```cangjie
public init(content: String)
```

功能：构造一个 [Comment](#class-comment) 对象，表示语法树中的注释节点。

参数：

- content: String - 注释内容。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建注释内容
    let content = "// This is a comment"

    // 创建 Comment 实例
    let comment = Comment(
        content
    )

    println("comment: ${comment}")
}
```

运行结果：

```text
comment: // This is a comment
```

## class CompositeType

```cangjie
public class CompositeType <: TypeAnnotation {
    public init(name: String, prefixes: Array<String>, typeArguments: Array<TypeAnnotation>, comments!: Array<Comment> = [])
}
```

功能：表示一个复合类型节点。例如 `p1.p0.A<Int64>`。

父类型：

- [TypeAnnotation](#class-typeannotation)

### prop name

```cangjie
public prop name: String
```

功能：表示复合类型的名称。

类型：String

### prop prefixes

```cangjie
public prop prefixes: Array<String>
```

功能：表示复合类型的所有前缀类型。

类型：Array\<String>

### prop typeArguments

```cangjie
public prop typeArguments: Array<TypeAnnotation>
```

功能：表示复合类型的所有类型参数。

类型：Array\<[TypeAnnotation](#class-typeannotation)>

### init(String, Array\<String>, Array\<TypeAnnotation>, Array\<Comment>)

```cangjie
public init(name: String, prefixes: Array<String>, typeArguments: Array<TypeAnnotation>, comments!: Array<Comment> = [])
```

功能：构造一个 [CompositeType](#class-compositetype) 对象，表示如 `p1.p0.A<Int64>` 这样的复合类型。

参数：

- name: String - 复合类型的主名称，例如 `A`。
- prefixes: Array\<String> - 复合类型的前缀路径，例如 `["p1", "p0"]`。
- typeArguments: Array\<[TypeAnnotation](#class-typeannotation)> - 类型参数列表，例如 `[Int64]`。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 name
    let name = "A"

    // 创建 prefixes
    let prefixes = ["p0"]

    // 创建 typeArguments
    let typeArguments : Array<TypeAnnotation> = [CompositeType("I1", [], [])]

    // 创建 CompositeType 实例
    let compositeType = CompositeType(
        name, 
        prefixes, 
        typeArguments
    )

    println("compositeType: ${compositeType}")
}
```

运行结果：

```text
compositeType: p0.A<I1>
```

### func getCommasPos()

```cangjie
public func getCommasPos(): Array<CodePositionRange>
```

功能：获取 `,` 的位置序列。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `,` 的位置序列。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 CompositeType 实例
    let typeArguments: Array<TypeAnnotation> = [CompositeType("I1", [], []), CompositeType("I2", [], [])]
    let compositeType = CompositeType("A", ["p0"], typeArguments)
    let posArr = compositeType.getCommasPos()

    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("compositeType.getCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
compositeType.getCommasPos()[0]: 1:8-1:9
```

### func getDotsPos()

```cangjie
public func getDotsPos(): Array<CodePositionRange>
```

功能：获取 `.` 的位置序列。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `.` 的位置序列。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 CompositeType 实例
    let compositeType = CompositeType("A", ["p0", "p1"], [])
    let posArr = compositeType.getDotsPos()

    // 遍历输出点位置
    for (i in 0..posArr.size) {
        println("compositeType.getDotsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
compositeType.getDotsPos()[0]: 1:3-1:4
compositeType.getDotsPos()[1]: 1:6-1:7
```

### func getLAnglePos()

```cangjie
public func getLAnglePos(): Option<CodePositionRange>
```

功能：获取 `<` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `<` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 CompositeType 实例
    let typeArguments: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    let compositeType = CompositeType("A", [], typeArguments)

    if (let Some(pos) <- compositeType.getLAnglePos()) {
        // 输出左尖括号位置
        println("compositeType.getLAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
compositeType.getLAnglePos(): 1:2-1:3
```

### func getRAnglePos()

```cangjie
public func getRAnglePos(): Option<CodePositionRange>
```

功能：获取 `>` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `>` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 CompositeType 实例
    let typeArguments: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    let compositeType = CompositeType("A", [], typeArguments)

    if (let Some(pos) <- compositeType.getRAnglePos()) {
        // 输出右尖括号位置
        println("compositeType.getRAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
compositeType.getRAnglePos(): 1:5-1:6
```

## class ConjunctionCondition

```cangjie
public class ConjunctionCondition <: SyntaxTreeNode {
    public init(cond: Array<AtomicCondition>, comments!: Array<Comment> = [])
}
```

功能：表示原子条件的逻辑合取。

该节点聚合了多个原子条件，只有当所有原子条件的求值结果都为 `true` 时，该合取条件才会被满足。它对其包含的原子条件之间的关系建模为逻辑 AND 运算。

父类型：

-[SyntaxTreeNode](#class-syntaxtreenode)

### prop cond

```cangjie
public prop cond: Array<AtomicCondition>
```

功能：表示该模式节点中的原子条件列表。

类型：Array\<[AtomicCondition](syntax_package_enums.md#enum-atomiccondition)>

### init(Array\<AtomicCondition>, Array\<Comment>)

```cangjie
public init(cond: Array<AtomicCondition>, comments!: Array<Comment> = [])
```

功能：构造一个 [ConjunctionCondition](#class-conjunctioncondition) 对象，表示原子条件的逻辑合取。

参数：

- cond: Array\<[AtomicCondition](syntax_package_enums.md#enum-atomiccondition)> - 原子条件列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `cond` 为空时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 cond
    let cond = [
            AtomicCondition.Expression(BinaryExpr(SymbolRef("x", []),BinaryOpKind.Equal, SymbolRef("y", []))), 
            AtomicCondition.Expression(BinaryExpr(SymbolRef("a", []),BinaryOpKind.Gt, SymbolRef("b", [])))
        ]

    // 创建 ConjunctionCondition 实例
    let conjunctionCondition = ConjunctionCondition(
        cond
    )

    println("conjunctionCondition: ${conjunctionCondition}")
}
```

运行结果：

```text
conjunctionCondition: x == y && a > b
```

### func getAndsPos()

```cangjie
public func getAndsPos(): Array<CodePositionRange>
```

功能：获取 [ConjunctionCondition](#class-conjunctioncondition) 节点中 `&&` 的位置序列。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `&&` 的位置序列。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 cond
    let cond = [
        AtomicCondition.Expression(BinaryExpr(SymbolRef("x", []), BinaryOpKind.Equal, SymbolRef("y", []))),
        AtomicCondition.Expression(BinaryExpr(SymbolRef("a", []), BinaryOpKind.Gt, SymbolRef("b", []))),
        AtomicCondition.Expression(BinaryExpr(SymbolRef("m", []), BinaryOpKind.Lt, SymbolRef("n", [])))
    ]

    // 创建 ConjunctionCondition 实例
    let conjunctionCondition = ConjunctionCondition(cond)
    let posArr = conjunctionCondition.getAndsPos()

    // 遍历输出 && 位置
    for (i in 0..posArr.size) {
        println("conjunctionCondition.getAndsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
conjunctionCondition.getAndsPos()[0]: 1:8-1:10
conjunctionCondition.getAndsPos()[1]: 1:17-1:19
```

## class ConstPattern

```cangjie
public class ConstPattern <: Pattern {
    public init(litConstExpr: LitConstExpr, comments!: Array<Comment> = [])
}
```

功能：表示常量模式节点。

常量模式可以是整数字面量、浮点数字面量、字符字面量、布尔字面量、字符串字面量等字面量，如 `case 1 => 0` 中的 `1`。

父类型：

- [Pattern](#class-pattern)

### prop litConstExpr

```cangjie
public prop litConstExpr: LitConstExpr
```

功能：表示该模式节点中的常量表达式节点。

类型：[LitConstExpr](#class-litconstexpr)

### init(LitConstExpr, Array\<Comment>)

```cangjie
public init(litConstExpr: LitConstExpr, comments!: Array<Comment> = [])
```

功能：构造一个 [ConstPattern](#class-constpattern) 对象，表示常量模式，如 `42`、`"hello"`。

参数：

- litConstExpr: [LitConstExpr](#class-litconstexpr) - 字面量常量表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 litConstExpr
    let litConstExpr = LitConstExpr(LitConstKind.BoolLiteral, "true")

    // 创建 ConstPattern 实例
    let constPattern = ConstPattern(
        litConstExpr
    )

    println("constPattern: ${constPattern}")
}
```

运行结果：

```text
constPattern: true
```

## class ContinueExpr

```cangjie
public class ContinueExpr <: Expr {
    public init(comments!: Array<Comment> = [])
}
```

功能：表示继续表达式。

用于跳过当前循环迭代，直接进入下一次循环迭代。[ContinueExpr](#class-continueexpr) 节点以 `continue` 关键字表示，通常用于循环体内部，以跳过当前迭代的剩余部分。

父类型：

- [Expr](#class-expr)

### init(Array\<Comment>)

```cangjie
public init(comments!: Array<Comment> = [])
```

功能：构造一个 [ContinueExpr](#class-continueexpr) 对象，表示 `continue` 表达式。

参数：

- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 ContinueExpr 实例
    let continueexpr = ContinueExpr()

    println("continueexpr: ${continueexpr}")
}
```

运行结果：

```text
continueexpr: continue
```

## class Decl

```cangjie
sealed abstract class Decl <: SyntaxTreeNode {}
```

功能：所有声明节点的父类，继承自 [SyntaxTreeNode](#class-syntaxtreenode) 节点，提供了所有声明节点的通用接口。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop annotations

```cangjie
public prop annotations: Array<Annotation>
```

功能：获取当前声明的注解列表。

类型：Array\<[Annotation](#class-annotation)>

### prop modifiers

```cangjie
public prop modifiers: Array<Modifier>
```

功能：获取当前声明的修饰符列表。

类型：Array\<[Modifier](#class-modifier)>

## class Diagnostic

```cangjie
public class Diagnostic {
    public let codePos: CodePositionRange
    public let diagInfo: DiagnosticInfo
}
```

功能：表示仓颉语法树的一个诊断信息。

### let codePos

```cangjie
public let codePos: CodePositionRange
```

功能：获取当前代码诊断信息的位置信息。

类型：[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)

### let diagInfo

```cangjie
public let diagInfo: DiagnosticInfo
```

功能：获取当前代码诊断信息的具体诊断信息，包括 `Warning`, `Error` 类型等。

类型：[DiagnosticInfo](syntax_package_enums.md#enum-diagnosticinfo)

## class DisjunctionCondition

```cangjie
public class DisjunctionCondition <: SyntaxTreeNode {
    public init(cond: Array<ConjunctionCondition>, comments!: Array<Comment> = [])
}
```

功能：表示合取条件的逻辑析取。

该节点聚合了多个合取条件，只要其中至少一个合取条件的求值结果为 `true`，该析取条件就会被满足。它对其包含的合取条件之间的关系建模为逻辑 OR 运算，形成一个析取范式的逻辑表达式。

父类型：

-[SyntaxTreeNode](#class-syntaxtreenode)

### prop cond

```cangjie
public prop cond: Array<ConjunctionCondition>
```

功能：表示该模式节点中的合取条件列表。

类型：Array\<[ConjunctionCondition](#class-conjunctioncondition)>

### init(Array\<ConjunctionCondition>, Array\<Comment>)

```cangjie
public init(cond: Array<ConjunctionCondition>, comments!: Array<Comment> = [])
```

功能：构造一个 [DisjunctionCondition](#class-disjunctioncondition) 对象，表示逻辑析取条件。

参数：

- cond: Array\<[ConjunctionCondition](#class-conjunctioncondition)> - 合取条件列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `cond` 为空时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 cond
    let cond = [
            ConjunctionCondition(AtomicCondition.Expression(BinaryExpr(SymbolRef("x", []),BinaryOpKind.Equal, SymbolRef("y", [])))), 
            ConjunctionCondition(AtomicCondition.Expression(BinaryExpr(SymbolRef("a", []),BinaryOpKind.Equal, SymbolRef("b", []))))
        ]

    // 创建 DisjunctionCondition 实例
    let disjunctionCondition = DisjunctionCondition(
        cond
    )

    println("disjunctionCondition: ${disjunctionCondition}")
}
```

运行结果：

```text
disjunctionCondition: x == y || a == b
```

### func getOrsPos()

```cangjie
public func getOrsPos(): Array<CodePositionRange>
```

功能：获取 [DisjunctionCondition](#class-disjunctioncondition) 节点中 `||` 的位置序列。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `||` 的位置序列。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 cond
    let cond = [
        ConjunctionCondition(AtomicCondition.Expression(BinaryExpr(SymbolRef("x", []), BinaryOpKind.Equal, SymbolRef("y", [])))),
        ConjunctionCondition(AtomicCondition.Expression(BinaryExpr(SymbolRef("a", []), BinaryOpKind.Equal, SymbolRef("b", [])))),
        ConjunctionCondition(AtomicCondition.Expression(BinaryExpr(SymbolRef("m", []), BinaryOpKind.Equal, SymbolRef("n", []))))
    ]

    // 创建 DisjunctionCondition 实例
    let disjunctionCondition = DisjunctionCondition(cond)
    let posArr = disjunctionCondition.getOrsPos()

    // 遍历输出 || 位置
    for (i in 0..posArr.size) {
        println("disjunctionCondition.getOrsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
disjunctionCondition.getOrsPos()[0]: 1:8-1:10
disjunctionCondition.getOrsPos()[1]: 1:18-1:20
```

## class DoWhileExpr

```cangjie
public class DoWhileExpr <: Expr {
    public init(body: Block, condition: Expr, comments!: Array<Comment> = [])
}
```

功能：表示 `do-while` 表达式。

父类型：

- [Expr](#class-expr)

### prop body

```cangjie
public prop body: Block
```

功能：获取当前 `do-while` 语句的循环体代码块。

类型：[Block](#class-block)

### prop condition

```cangjie
public prop condition: Expr
```

功能：获取当前 `do-while` 语句的继续条件表达式。

类型：[Expr](#class-expr)

### init(Block, Expr, Array\<Comment>)

```cangjie
public init(body: Block, condition: Expr, comments!: Array<Comment> = [])
```

功能：构造一个 [DoWhileExpr](#class-dowhileexpr) 对象，表示 `do-while` 循环表达式。

参数：

- body: [Block](#class-block) - 循环体代码块。
- condition: [Expr](#class-expr) - 循环继续条件表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建循环体
    let body = Block([])

    // 创建循环条件
    let condition = BinaryExpr(SymbolRef("x", []),BinaryOpKind.Gt, SymbolRef("y", []))

    // 创建 DoWhileExpr 实例
    let doWhileExpr = DoWhileExpr(
        body, 
        condition
    )

    println("doWhileExpr: ${doWhileExpr}")
}
```

运行结果：

```text
doWhileExpr: do {
} while (x > y)
```

### func getCondLParenPos()

```cangjie
public func getCondLParenPos(): CodePositionRange
```

功能：获取 [DoWhileExpr](#class-dowhileexpr) 节点中条件的 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回条件的 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建循环体
    let body = Block([])

    // 创建循环条件
    let condition = BinaryExpr(SymbolRef("x", []), BinaryOpKind.Gt, SymbolRef("y", []))

    // 创建 DoWhileExpr 实例
    let doWhileExpr = DoWhileExpr(body, condition)
    let pos = doWhileExpr.getCondLParenPos()

    // 输出条件左括号位置
    println("doWhileExpr.getCondLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
doWhileExpr.getCondLParenPos(): 2:9-2:10
```

### func getCondRParenPos()

```cangjie
public func getCondRParenPos(): CodePositionRange
```

功能：获取 [DoWhileExpr](#class-dowhileexpr) 节点中条件的 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回条件的 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建循环体
    let body = Block([])

    // 创建循环条件
    let condition = BinaryExpr(SymbolRef("x", []), BinaryOpKind.Gt, SymbolRef("y", []))

    // 创建 DoWhileExpr 实例
    let doWhileExpr = DoWhileExpr(body, condition)
    let pos = doWhileExpr.getCondRParenPos()

    // 输出条件右括号位置
    println("doWhileExpr.getCondRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
doWhileExpr.getCondRParenPos(): 2:15-2:16
```

### func getDoKeyWordPos()

```cangjie
public func getDoKeyWordPos(): CodePositionRange
```

功能：获取 [DoWhileExpr](#class-dowhileexpr) 节点中 `do` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `do` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建循环体
    let body = Block([])

    // 创建循环条件
    let condition = BinaryExpr(SymbolRef("x", []), BinaryOpKind.Gt, SymbolRef("y", []))

    // 创建 DoWhileExpr 实例
    let doWhileExpr = DoWhileExpr(body, condition)
    let pos = doWhileExpr.getDoKeyWordPos()

    // 输出 do 关键字位置
    println("doWhileExpr.getDoKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
doWhileExpr.getDoKeyWordPos(): 1:1-1:3
```

### func getWhileKeyWordPos()

```cangjie
public func getWhileKeyWordPos(): CodePositionRange
```

功能：获取 [DoWhileExpr](#class-dowhileexpr) 节点中 `while` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `while` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建循环体
    let body = Block([])

    // 创建循环条件
    let condition = BinaryExpr(SymbolRef("x", []), BinaryOpKind.Gt, SymbolRef("y", []))

    // 创建 DoWhileExpr 实例
    let doWhileExpr = DoWhileExpr(body, condition)
    let pos = doWhileExpr.getWhileKeyWordPos()

    // 输出 while 关键字位置
    println("doWhileExpr.getWhileKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
doWhileExpr.getWhileKeyWordPos(): 2:3-2:8
```

## class EnumConstructor

```cangjie
public class EnumConstructor <: Decl {
    public init(name: String, paramTyAnnotations: Array<TypeAnnotation>, annotations!: Array<Annotation> = [],
        comments!: Array<Comment> = [])
}
```

功能：表示一个枚举构造器。

[EnumConstructor](#class-enumconstructor) 类用于在枚举类型中声明一个构造器，`name` 表示构造器的名称，`paramTyAnnotations` 表示构造器参数的类型标注列表。

父类型：

- [Decl](#class-decl)

### prop name

```cangjie
public prop name: String
```

功能：获取当前枚举构造器的名称。

类型：String

### prop paramTyAnnotations

```cangjie
public prop paramTyAnnotations: Array<TypeAnnotation>
```

功能：获取当前枚举构造器参数的类型标注列表。

类型：Array\<[TypeAnnotation](#class-typeannotation)>

### init(String, Array\<TypeAnnotation>, Array\<Annotation>, Array\<Comment>)

```cangjie
public init(name: String, paramTyAnnotations: Array<TypeAnnotation>, annotations!: Array<Annotation> = [],
    comments!: Array<Comment> = [])
```

功能：构造一个 [EnumConstructor](#class-enumconstructor) 对象，表示枚举构造器节点。

参数：

- name: String - 构造器名称。
- paramTyAnnotations: Array\<[TypeAnnotation](#class-typeannotation)> - 参数类型注解列表。
- annotations!: Array\<[Annotation](#class-annotation)> - 附加的注解列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 name
    let name = "EnumA"

    // 创建 paramTyAnnotations
    let paramTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]

    // 创建 annotations
    let annotations = [Annotation([Argument(None, false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))], "MyAnno", AtOpKind.At)]

    // 创建 EnumConstructor 实例
    let enumConstructor = EnumConstructor(
        name, 
        paramTyAnnotations, 
        annotations: annotations
    )

    println("enumConstructor: ${enumConstructor}")
}
```

运行结果：

```text
enumConstructor: @MyAnno[123]
EnumA(I1)
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取 [EnumConstructor](#class-enumconstructor) 节点中标识符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回标识符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumConstructor 实例
    let enumConstructor = EnumConstructor("EnumA", [])
    let pos = enumConstructor.getIdentifierPos()

    // 输出标识符位置
    println("enumConstructor.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
enumConstructor.getIdentifierPos(): 1:1-1:6
```

### func getParamsCommasPos()

```cangjie
public func getParamsCommasPos(): Array<CodePositionRange>
```

功能：获取 [EnumConstructor](#class-enumconstructor) 节点中参数间的 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回参数间的 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumConstructor 实例
    let paramTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], []), CompositeType("I2", [], [])]
    let enumConstructor = EnumConstructor("EnumA", paramTyAnnotations)
    let posArr = enumConstructor.getParamsCommasPos()

    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("enumConstructor.getParamsCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
enumConstructor.getParamsCommasPos()[0]: 1:9-1:10
```

### func getParamsLParenPos()

```cangjie
public func getParamsLParenPos(): Option<CodePositionRange>
```

功能：获取 [EnumConstructor](#class-enumconstructor) 节点中参数的 `(` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回参数的 `(` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumConstructor 实例
    let paramTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    let enumConstructor = EnumConstructor("EnumA", paramTyAnnotations)

    if (let Some(pos) <- enumConstructor.getParamsLParenPos()) {
        // 输出参数左括号位置
        println("enumConstructor.getParamsLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
enumConstructor.getParamsLParenPos(): 1:6-1:7
```

### func getParamsRParenPos()

```cangjie
public func getParamsRParenPos(): Option<CodePositionRange>
```

功能：获取 [EnumConstructor](#class-enumconstructor) 节点中参数的 `)` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回参数的 `)` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumConstructor 实例
    let paramTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    let enumConstructor = EnumConstructor("EnumA", paramTyAnnotations)

    if (let Some(pos) <- enumConstructor.getParamsRParenPos()) {
        // 输出参数右括号位置
        println("enumConstructor.getParamsRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
enumConstructor.getParamsRParenPos(): 1:9-1:10
```

## class EnumDecl

```cangjie
public class EnumDecl <: Decl {
    public init(body: Body, constructors: Array<EnumConstructor>, genericConstraints: Option<GenericConstraints>, genericParams: Array<GenericParam>,
        isNonExhaustive: Bool, name: String, superTyAnnotations: Array<TypeAnnotation>,
        annotations!: Array<Annotation> = [], modifiers!: Array<Modifier> = [], comments!: Array<Comment> = [])
}
```

功能：表示一个 `Enum` 声明节点。

Enum 的声明使用 `enum` 关键字，声明依次为：可缺省的修饰符、`enum` 关键字、`enum` 名、可选的类型参数、是否指定父接口、可选的泛型约束、`enum` 体的声明。

父类型：

- [Decl](#class-decl)

### prop body

```cangjie
public prop body: Body
```

功能：获取当前枚举声明的主体部分。

类型：[Body](#class-body)

### prop genericConstraints

```cangjie
public prop genericConstraints: Option<GenericConstraints>
```

功能：获取当前枚举声明的泛型约束（若不存在返回 `None`）。

类型：Option\<[GenericConstraints](#class-genericconstraints)>

### prop genericParams

```cangjie
public prop genericParams: Array<GenericParam>
```

功能：获取当前枚举声明的泛型参数列表。

类型：Array\<[GenericParam](#class-genericparam)>

### prop isNonExhaustive

```cangjie
public prop isNonExhaustive: Bool
```

功能：判断当前枚举声明是否为 `non-exhaustive enum`。

类型：Bool

### prop name

```cangjie
public prop name: String
```

功能：获取当前枚举声明的名称。

类型：String

### prop superTyAnnotations

```cangjie
public prop superTyAnnotations: Array<TypeAnnotation>
```

功能：获取当前枚举声明的父类类型标注列表。

类型：Array\<[TypeAnnotation](#class-typeannotation)>

### init(Body, Array\<EnumConstructor>, Option\<GenericConstraints>, Array\<GenericParam>, Bool, String, Array\<TypeAnnotation>, Array\<Annotation>, Array\<Modifier>, Array\<Comment>)

```cangjie
public init(body: Body, constructors: Array<EnumConstructor>, genericConstraints: Option<GenericConstraints>,
    genericParams: Array<GenericParam>, isNonExhaustive: Bool, name: String, superTyAnnotations: Array<TypeAnnotation>,
    annotations!: Array<Annotation> = [], modifiers!: Array<Modifier> = [], comments!: Array<Comment> = [])
```

功能：构造一个 [EnumDecl](#class-enumdecl) 对象，表示枚举声明节点。

参数：

- body: [Body](#class-body) - 枚举体，包含除枚举构造器外其他成员声明。
- constructors: Array\<[EnumConstructor](#class-enumconstructor)> - 枚举构造器列表。
- genericConstraints: Option\<[GenericConstraints](#class-genericconstraints)> - 可选的泛型约束。
- genericParams: Array\<[GenericParam](#class-genericparam)> - 泛型参数列表。
- isNonExhaustive: Bool - 是否为非穷举枚举。
- name: String - 枚举名。
- superTyAnnotations: Array\<[TypeAnnotation](#class-typeannotation)> - 父类类型标注列表。
- annotations!: Array\<[Annotation](#class-annotation)> - 附加的注解列表，默认为空数组。
- modifiers!: Array\<[Modifier](#class-modifier)> - 修饰符列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `constructors` 为空，或输入的 `body` 中的节点不是函数声明、属性声明及宏展开声明，或当泛型约束与泛型参数不对应，或输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Body([])

    // 创建 constructor
    let constructor = [EnumConstructor("EnumA", [])]

    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])

    // 创建 genericParams
    let genericParams = [GenericParam("T")]

    // 创建 isNonExhaustive
    let isNonExhaustive = true

    // 创建 name
    let name = "A"

    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]

    // 创建 EnumDecl 实例
    let enumDecl = EnumDecl(
        body, 
        constructor, 
        genericConstraints, 
        genericParams, 
        isNonExhaustive, 
        name, 
        superTyAnnotations
    )

    println("enumDecl: ${enumDecl}")
}
```

运行结果：

```text
enumDecl: enum A<T> <: I1 where T<:I1 {
    | EnumA
    | ...
}
```

### func getCaseSeparatorsPos()

```cangjie
public func getCaseSeparatorsPos(): Array<CodePositionRange>
```

功能：获取 [EnumDecl](#class-enumdecl) 节点中 `|` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `|` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumDecl 实例
    let constructors = [EnumConstructor("A", []), EnumConstructor("B", [])]
    let enumDecl = EnumDecl(Body([]), constructors, None, [], false, "MyEnum", [])
    let posArr = enumDecl.getCaseSeparatorsPos()

    // 遍历输出竖线位置
    for (i in 0..posArr.size) {
        println("enumDecl.getCaseSeparatorsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
enumDecl.getCaseSeparatorsPos()[0]: 2:5-2:6
enumDecl.getCaseSeparatorsPos()[1]: 3:5-3:6
```

### func getEnumKeyWordPos()

```cangjie
public func getEnumKeyWordPos(): CodePositionRange
```

功能：获取 [EnumDecl](#class-enumdecl) 节点中 `enum` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `enum` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumDecl 实例
    let constructors = [EnumConstructor("A", [])]
    let enumDecl = EnumDecl(Body([]), constructors, None, [], false, "MyEnum", [])
    let pos = enumDecl.getEnumKeyWordPos()

    // 输出 enum 关键字位置
    println("enumDecl.getEnumKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
enumDecl.getEnumKeyWordPos(): 1:1-1:5
```

### func getGenericParamsCommasPos()

```cangjie
public func getGenericParamsCommasPos(): Array<CodePositionRange>
```

功能：获取 [EnumDecl](#class-enumdecl) 节点中泛型参数中 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数中 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumDecl 实例
    let genericParams = [GenericParam("T"), GenericParam("U")]
    let constructors = [EnumConstructor("A", [])]
    let enumDecl = EnumDecl(Body([]), constructors, None, genericParams, false, "MyEnum", [])
    let posArr = enumDecl.getGenericParamsCommasPos()

    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("enumDecl.getGenericParamsCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
enumDecl.getGenericParamsCommasPos()[0]: 1:14-1:15
```

### func getGenericParamsLAnglePos()

```cangjie
public func getGenericParamsLAnglePos(): Option<CodePositionRange>
```

功能：获取 [EnumDecl](#class-enumdecl) 节点中泛型参数的 `<` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数的 `<` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumDecl 实例
    let genericParams = [GenericParam("T")]
    let constructors = [EnumConstructor("A", [])]
    let enumDecl = EnumDecl(Body([]), constructors, None, genericParams, false, "MyEnum", [])

    if (let Some(pos) <- enumDecl.getGenericParamsLAnglePos()) {
        // 输出泛型参数左尖括号位置
        println("enumDecl.getGenericParamsLAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
enumDecl.getGenericParamsLAnglePos(): 1:12-1:13
```

### func getGenericParamsRAnglePos()

```cangjie
public func getGenericParamsRAnglePos(): Option<CodePositionRange>
```

功能：获取 [EnumDecl](#class-enumdecl) 节点中泛型参数的 `>` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数的 `>` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumDecl 实例
    let genericParams = [GenericParam("T")]
    let constructors = [EnumConstructor("A", [])]
    let enumDecl = EnumDecl(Body([]), constructors, None, genericParams, false, "MyEnum", [])

    if (let Some(pos) <- enumDecl.getGenericParamsRAnglePos()) {
        // 输出泛型参数右尖括号位置
        println("enumDecl.getGenericParamsRAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
enumDecl.getGenericParamsRAnglePos(): 1:14-1:15
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取 [EnumDecl](#class-enumdecl) 节点中标识符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回标识符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumDecl 实例
    let constructors = [EnumConstructor("A", [])]
    let enumDecl = EnumDecl(Body([]), constructors, None, [], false, "MyEnum", [])
    let pos = enumDecl.getIdentifierPos()

    // 输出标识符位置
    println("enumDecl.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
enumDecl.getIdentifierPos(): 1:6-1:12
```

### func getNonExhaustiveTripleDotPos()

```cangjie
public func getNonExhaustiveTripleDotPos(): Option<CodePositionRange>
```

功能：获取 [EnumDecl](#class-enumdecl) 节点中 `...` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `...` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumDecl 实例
    let constructors = [EnumConstructor("A", [])]
    let enumDecl = EnumDecl(Body([]), constructors, None, [], true, "MyEnum", [])

    if (let Some(pos) <- enumDecl.getNonExhaustiveTripleDotPos()) {
        // 输出三点位置
        println("enumDecl.getNonExhaustiveTripleDotPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
enumDecl.getNonExhaustiveTripleDotPos(): 3:7-3:10
```

### func getSuperTyAnnotationsBitAndsPos()

```cangjie
public func getSuperTyAnnotationsBitAndsPos(): Array<CodePositionRange>
```

功能：获取 [EnumDecl](#class-enumdecl) 节点的父类型中 `&` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回父类型中 `&` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumDecl 实例
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], []), CompositeType("I2", [], [])]
    let constructors = [EnumConstructor("A", [])]
    let enumDecl = EnumDecl(Body([]), constructors, None, [], false, "MyEnum", superTyAnnotations)
    let posArr = enumDecl.getSuperTyAnnotationsBitAndsPos()

    // 遍历输出&位置
    for (i in 0..posArr.size) {
        println("enumDecl.getSuperTyAnnotationsBitAndsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
enumDecl.getSuperTyAnnotationsBitAndsPos()[0]: 1:19-1:20
```

### func getUpperBoundPos()

```cangjie
public func getUpperBoundPos(): Option<CodePositionRange>
```

功能：获取 [EnumDecl](#class-enumdecl) 节点中 `<:` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回父类型中 `&` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumDecl 实例
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    let constructors = [EnumConstructor("A", [])]
    let enumDecl = EnumDecl(Body([]), constructors, None, [], false, "MyEnum", superTyAnnotations)

    if (let Some(pos) <- enumDecl.getUpperBoundPos()) {
        // 输出 <: 位置
        println("enumDecl.getUpperBoundPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
enumDecl.getUpperBoundPos(): 1:13-1:15
```

## class EnumPattern

```cangjie
public class EnumPattern <: Pattern {
    public init(enumConstructor: SymbolRef, enumType: Option<CompositeType>, subPatterns: Array<Pattern>, 
        comments!: Array<Comment> = [])
}
```

功能：表示 `enum` 模式节点。

用于匹配 `enum` 的 `constructor`， 如 `case Year(n) => 1` 中的 `Year(n)`。

父类型：

- [Pattern](#class-pattern)

### prop enumConstructor

```cangjie
public prop enumConstructor: SymbolRef
```

功能：表示 `enum` 构造器。

类型：[SymbolRef](#class-symbolref)

### prop enumType

```cangjie
public prop enumType: Option<CompositeType>
```

功能：表示该 `enum` 模式节点中的前缀类型，例如，`p1.p0.E<Int64>` 是模式 `p1.p0.E<Int64>.C0(x)` 的 `enumType`。

类型：Option\<[CompositeType](#class-compositetype)>

### prop subPatterns

```cangjie
public prop subPatterns: Array<Pattern>
```

功能：表示该模式节点中有参构造器内的模式节点列表。

类型：Array\<[Pattern](#class-pattern)>

### init(SymbolRef, Option\<CompositeType>, Array\<Pattern>, Array\<Comment>)

```cangjie
public init(enumConstructor: SymbolRef, enumType: Option<CompositeType>, subPatterns: Array<Pattern>, comments!: Array<Comment> = [])
```

功能：构造一个 [EnumPattern](#class-enumpattern) 对象，表示枚举模式。

参数：

- enumConstructor: [SymbolRef](#class-symbolref) - 枚举构造器引用。
- enumType: Option\<[CompositeType](#class-compositetype)> - 可选的枚举类型前缀，如 `Result`。
- subPatterns: Array\<[Pattern](#class-pattern)> - 子模式列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 enumConstructor
    let enumConstructor = SymbolRef("A", [])

    // 创建 enumType
    let enumType = CompositeType("C1", [], [])

    // 创建 subPatterns
    let subPatterns: Array<Pattern> = [VarPattern("x")]

    // 创建 EnumPattern 实例
    let enumPattern = EnumPattern(
        enumConstructor, 
        enumType, 
        subPatterns
    )

    println("enumPattern: ${enumPattern}")
}
```

运行结果：

```text
enumPattern: C1.A(x)
```

### func getCommasPos()

```cangjie
public func getCommasPos(): Array<CodePositionRange>
```

功能：获取 [EnumPattern](#class-enumpattern) 节点中 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumPattern 实例
    let enumConstructor = SymbolRef("A", [])
    let subPatterns: Array<Pattern> = [VarPattern("x"), VarPattern("y")]
    let enumPattern = EnumPattern(enumConstructor, None, subPatterns)
    let posArr = enumPattern.getCommasPos()

    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("enumPattern.getCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
enumPattern.getCommasPos()[0]: 1:4-1:5
```

### func getDotPos()

```cangjie
public func getDotPos(): Option<CodePositionRange>
```

功能：获取 [EnumPattern](#class-enumpattern) 节点中 `.` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `.` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumPattern 实例
    let enumConstructor = SymbolRef("A", [])
    let enumType = CompositeType("C1", [], [])
    let subPatterns: Array<Pattern> = [VarPattern("x")]
    let enumPattern = EnumPattern(enumConstructor, enumType, subPatterns)

    if (let Some(pos) <- enumPattern.getDotPos()) {
        // 输出点位置
        println("enumPattern.getDotPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
enumPattern.getDotPos(): 1:3-1:4
```

### func getLParenPos()

```cangjie
public func getLParenPos(): Option<CodePositionRange>
```

功能：获取 [EnumPattern](#class-enumpattern) 节点中 `(` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumPattern 实例
    let enumConstructor = SymbolRef("A", [])
    let subPatterns: Array<Pattern> = [VarPattern("x")]
    let enumPattern = EnumPattern(enumConstructor, None, subPatterns)

    if (let Some(pos) <- enumPattern.getLParenPos()) {
        // 输出左括号位置
        println("enumPattern.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
enumPattern.getLParenPos(): 1:2-1:3
```

### func getRParenPos()

```cangjie
public func getRParenPos(): Option<CodePositionRange>
```

功能：获取 [EnumPattern](#class-enumpattern) 节点中 `)` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 EnumPattern 实例
    let enumConstructor = SymbolRef("A", [])
    let subPatterns: Array<Pattern> = [VarPattern("x")]
    let enumPattern = EnumPattern(enumConstructor, None, subPatterns)

    if (let Some(pos) <- enumPattern.getRParenPos()) {
        // 输出右括号位置
        println("enumPattern.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
enumPattern.getRParenPos(): 1:4-1:5
```

## class Expr

```cangjie
sealed abstract class Expr <: SyntaxTreeNode {}
```

功能：表示一个表达式节点。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

## class ExtendDecl

```cangjie
public class ExtendDecl <: Decl {
    public init(body: Body, extendedTyAnnotation: TypeAnnotation, genericConstraints: Option<GenericConstraints>,
        genericParams: Array<GenericParam>, superTyAnnotations: Array<TypeAnnotation>,
        annotations!: Array<Annotation> = [], comments!: Array<Comment> = [])
}
```

功能：表示一个扩展声明节点。

扩展的声明使用 `extend` 关键字，扩展声明依次为：`extend` 关键字、扩展类型、是否指定父接口、可选的泛型约束、扩展体的声明。

父类型：

- [Decl](#class-decl)

### prop body

```cangjie
public prop body: Body
```

功能：获取当前扩展声明的主体部分。

类型：[Body](#class-body)

### prop extendedTyAnnotation

```cangjie
public prop extendedTyAnnotation: TypeAnnotation
```

功能：获取当前扩展声明的被扩展类型标注。

类型：[TypeAnnotation](#class-typeannotation)

### prop genericConstraints

```cangjie
public prop genericConstraints: Option<GenericConstraints>
```

功能：获取当前扩展声明的泛型约束（若不存在返回 `None`）。

类型：Option\<[GenericConstraints](#class-genericconstraints)>

### prop genericParams

```cangjie
public prop genericParams: Array<GenericParam>
```

功能：获取当前扩展声明的泛型参数列表。

类型：Array\<[GenericParam](#class-genericparam)>

### prop superTyAnnotations

```cangjie
public prop superTyAnnotations: Array<TypeAnnotation>
```

功能：获取当前扩展声明的父类类型标注列表。

类型：Array\<[TypeAnnotation](#class-typeannotation)>

### init(Body, TypeAnnotation, Option\<GenericConstraints>, Array\<GenericParam>, Array\<TypeAnnotation>, Array\<Annotation>, Array\<Comment>)

```cangjie
public init(body: Body, extendedTyAnnotation: TypeAnnotation, genericConstraints: Option<GenericConstraints>,
    genericParams: Array<GenericParam>, superTyAnnotations: Array<TypeAnnotation>,
    annotations!: Array<Annotation> = [], comments!: Array<Comment> = [])
```

功能：构造一个 [ExtendDecl](#class-extenddecl) 对象，表示扩展声明节点。

参数：

- body: [Body](#class-body) - 扩展体，包含成员声明。
- extendedTyAnnotation: [TypeAnnotation](#class-typeannotation) - 被扩展的类型注解。
- genericConstraints: Option\<[GenericConstraints](#class-genericconstraints)> - 可选的泛型约束。
- genericParams: Array\<[GenericParam](#class-genericparam)> - 泛型参数列表。
- superTyAnnotations: Array\<[TypeAnnotation](#class-typeannotation)> - 父类类型标注列表。
- annotations!: Array\<[Annotation](#class-annotation)> - 附加的注解列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `body` 中有除函数声明、宏展开声明和属性声明外的声明或当泛型约束与泛型参数不对应时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建扩展体，包含一些成员声明
    let body = Body([])

    // 设置被扩展的类型注解
    let extendedTyAnnotation = CompositeType("C1", [], [])

    // 创建泛型约束（无）
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])

    // 创建泛型参数
    let genericParams = [GenericParam("T")]

    // 设置父类型注解
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]

    // 创建注解
    let annotations = [Annotation([Argument(None, false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))], "MyAnno", AtOpKind.At)]

    // 创建 ExtendDecl 实例
    let extendDecl = ExtendDecl(
        body, 
        extendedTyAnnotation, 
        genericConstraints, 
        genericParams, 
        superTyAnnotations, 
        annotations: annotations
    )

    println("extendDecl: ${extendDecl}")
}
```

运行结果：

```text
extendDecl: @MyAnno[123]
extend<T> C1 <: I1 where T<:I1 {
}

```

### func getExtendKeyWordPos()

```cangjie
public func getExtendKeyWordPos(): CodePositionRange
```

功能：获取 [ExtendDecl](#class-extenddecl) 节点中 `extend` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `extend` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建扩展体
    let body = Body([])

    // 设置被扩展的类型注解
    let extendedTyAnnotation = CompositeType("C1", [], [])

    // 创建泛型约束（无）
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])

    // 创建泛型参数
    let genericParams = [GenericParam("T")]

    // 设置父类型注解
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 ExtendDecl 实例
    let extendDecl = ExtendDecl(
        body, 
        extendedTyAnnotation, 
        genericConstraints, 
        genericParams, 
        superTyAnnotations
    )
    
    // 获取 extend 关键字位置
    let pos = extendDecl.getExtendKeyWordPos()
    
    // 输出 extend 关键字位置
    println("extendDecl.getExtendKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
extendDecl.getExtendKeyWordPos(): 1:1-1:7
```

### func getGenericParamsCommasPos()

```cangjie
public func getGenericParamsCommasPos(): Array<CodePositionRange>
```

功能：获取 [ExtendDecl](#class-extenddecl) 节点中泛型参数中 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数中 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建扩展体
    let body = Body([])

    // 设置被扩展的类型注解
    let extendedTyAnnotation = CompositeType("C1", [], [])

    // 创建泛型约束（无）
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])

    // 创建泛型参数
    let genericParams = [GenericParam("T"), GenericParam("U"), GenericParam("V")]

    // 设置父类型注解
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 ExtendDecl 实例
    let extendDecl = ExtendDecl(
        body, 
        extendedTyAnnotation, 
        genericConstraints, 
        genericParams, 
        superTyAnnotations
    )
    
    // 获取泛型参数中逗号的位置
    let posArr = extendDecl.getGenericParamsCommasPos()
    
    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("extendDecl.getGenericParamsCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
extendDecl.getGenericParamsCommasPos()[0]: 1:9-1:10
extendDecl.getGenericParamsCommasPos()[1]: 1:12-1:13
```

### func getGenericParamsLAnglePos()

```cangjie
public func getGenericParamsLAnglePos(): Option<CodePositionRange>
```

功能：获取 [ExtendDecl](#class-extenddecl) 节点中泛型参数的 `<` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数中 `<` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建扩展体
    let body = Body([])

    // 设置被扩展的类型注解
    let extendedTyAnnotation = CompositeType("C1", [], [])

    // 创建泛型约束（无）
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])

    // 创建泛型参数
    let genericParams = [GenericParam("T")]

    // 设置父类型注解
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 ExtendDecl 实例
    let extendDecl = ExtendDecl(
        body, 
        extendedTyAnnotation, 
        genericConstraints, 
        genericParams, 
        superTyAnnotations
    )
    
    // 获取泛型参数左尖括号的位置
    if (let Some(pos) <- extendDecl.getGenericParamsLAnglePos()) {
        // 输出左尖括号位置
        println("extendDecl.getGenericParamsLAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    } else {
        println("No left angle bracket found")
    }
}
```

运行结果：

```text
extendDecl.getGenericParamsLAnglePos(): 1:7-1:8
```

### func getGenericParamsRAnglePos()

```cangjie
public func getGenericParamsRAnglePos(): Option<CodePositionRange>
```

功能：获取 [ExtendDecl](#class-extenddecl) 节点中泛型参数的 `>` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数中 `>` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建扩展体
    let body = Body([])

    // 设置被扩展的类型注解
    let extendedTyAnnotation = CompositeType("C1", [], [])

    // 创建泛型约束（无）
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])

    // 创建泛型参数
    let genericParams = [GenericParam("T")]

    // 设置父类型注解
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 ExtendDecl 实例
    let extendDecl = ExtendDecl(
        body, 
        extendedTyAnnotation, 
        genericConstraints, 
        genericParams, 
        superTyAnnotations
    )
    
    // 获取泛型参数右尖括号的位置
    if (let Some(pos) <- extendDecl.getGenericParamsRAnglePos()) {
        // 输出右尖括号位置
        println("extendDecl.getGenericParamsRAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    } else {
        println("No right angle bracket found")
    }
}
```

运行结果：

```text
extendDecl.getGenericParamsRAnglePos(): 1:9-1:10
```

### func getSuperTyAnnotationsBitAndsPos()

```cangjie
public func getSuperTyAnnotationsBitAndsPos(): Array<CodePositionRange>
```

功能：获取 [ExtendDecl](#class-extenddecl) 节点中父类型中 `&` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回父类型中 `&` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建扩展体
    let body = Body([])

    // 设置被扩展的类型注解
    let extendedTyAnnotation = CompositeType("C1", [], [])

    // 创建泛型约束（无）
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])

    // 创建泛型参数
    let genericParams = [GenericParam("T")]
    
    // 创建多个父类型（使用 & 连接）
    let superTyAnnotations: Array<TypeAnnotation> = [
        CompositeType("I1", [], []),
        CompositeType("I2", [], []),
        CompositeType("I3", [], [])
    ]
    
    // 创建 ExtendDecl 实例
    let extendDecl = ExtendDecl(
        body, 
        extendedTyAnnotation, 
        genericConstraints, 
        genericParams, 
        superTyAnnotations
    )
    
    // 获取父类型中 & 的位置
    let posArr = extendDecl.getSuperTyAnnotationsBitAndsPos()
    
    // 遍历输出 & 位置
    for (i in 0..posArr.size) {
        println("extendDecl.getSuperTyAnnotationsBitAndsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
extendDecl.getSuperTyAnnotationsBitAndsPos()[0]: 1:20-1:21
extendDecl.getSuperTyAnnotationsBitAndsPos()[1]: 1:25-1:26
```

### func getUpperBoundPos()

```cangjie
public func getUpperBoundPos(): Option<CodePositionRange>
```

功能：获取 [ExtendDecl](#class-extenddecl) 节点中 `<:` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `<:` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建扩展体
    let body = Body([])

    // 设置被扩展的类型注解
    let extendedTyAnnotation = CompositeType("C1", [], [])

    // 创建泛型约束（无）
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])

    // 创建泛型参数
    let genericParams = [GenericParam("T")]

    // 设置父类型注解
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 ExtendDecl 实例
    let extendDecl = ExtendDecl(
        body, 
        extendedTyAnnotation, 
        genericConstraints, 
        genericParams, 
        superTyAnnotations
    )
    
    // 获取 <: 位置
    if (let Some(pos) <- extendDecl.getUpperBoundPos()) {
        // 输出 <: 位置
        println("extendDecl.getUpperBoundPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    } else {
        println("No upper bound found")
    }
}
```

运行结果：

```text
extendDecl.getUpperBoundPos(): 1:14-1:16
```

## class FeatureId

```cangjie
public class FeatureId <: SyntaxTreeNode {
    public init(identifiers: Array<String>, comments!: Array<Comment> = [])
}
```

功能：一个 feature 标识节点。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop featureNameIdentifiers

```cangjie
public prop featureNameIdentifiers: Array<String> 
```

功能：获取 feature 名称中的标识符。

类型：Array\<String>

### init(Array\<String>, Array\<Comment>)

```cangjie
public init(identifiers: Array<String>, comments!: Array<Comment> = [])
```

功能：构造一个对象。

参数：

- features: Array\<String> - feature 名称数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当数组为空或包含空字符串时抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 identifiers
    let identifiers = ["std", "core", "feature"]

    // 创建 FeatureId 实例
    let featureId = FeatureId(
        identifiers
    )

    println("featureId: ${featureId}")
}
```

运行结果：

```text
featureId: std.core.feature
```

### func getDotPoses()

```cangjie
public func getDotPoses(): Array<CodePositionRange>
```

功能：获取 feature 名称中的 `.` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)>

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 identifiers
    let identifiers = ["std", "core", "feature"]

    // 创建 FeatureId 实例
    let featureId = FeatureId(identifiers)
    
    // 获取点的位置
    let posArr = featureId.getDotPoses()
    
    // 遍历输出点的位置
    for (i in 0..posArr.size) {
        println("featureId.getDotPoses()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
featureId.getDotPoses()[0]: 1:4-1:5
featureId.getDotPoses()[1]: 1:9-1:10
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): Array<CodePositionRange> 
```

功能：获取 feature 名称中的标识符位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)>

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 identifiers
    let identifiers = ["std", "core", "feature"]

    // 创建 FeatureId 实例
    let featureId = FeatureId(identifiers)
    
    // 获取标识符的位置
    let posArr = featureId.getIdentifierPos()
    
    // 遍历输出标识符位置
    for (i in 0..posArr.size) {
        println("featureId.getIdentifierPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
featureId.getIdentifierPos()[0]: 1:1-1:4
featureId.getIdentifierPos()[1]: 1:5-1:9
featureId.getIdentifierPos()[2]: 1:10-1:17
```

## class FeaturesDirective

```cangjie
public class FeaturesDirective <: SyntaxTreeNode {
    public init(annotations: Array<Annotation>, set: FeaturesSet, comments!: Array<Comment> = [])
}
```

功能：一个 features 声明节点。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop annotations

```cangjie
public prop annotations: Array<Annotation>
```

功能：获取当前声明的注解列表。

类型：Array\<[Annotation](#class-annotation)>

### prop featuresSet

```cangjie
public prop featuresSet: FeaturesSet
```

功能：获取当前声明的 features set。

类型：[FeaturesSet](#class-featuresset)

### init(Array\<Annotation>, FeaturesSet, Array\<Comment>)

```cangjie
public init(annotations: Array<Annotation>, set: FeaturesSet, comments!: Array<Comment> = [])
```

功能：构造一个 FeatureId 对象。

参数：

- annotations: Array\<[Annotation](#class-annotation)> - 一组在 feature directive 声明节点上的注解。
- set: [FeaturesSet](#class-featuresset) - 一组 features 名称。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 featureId 无法构造时抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建注解
    let annotations: Array<Annotation> = []

    // 创建 FeatureId
    let featureId1 = FeatureId(["std", "core", "feature1"])
    let featureId2 = FeatureId(["std", "core", "feature2"])

    // 创建 FeaturesSet
    let featuresSet = FeaturesSet([featureId1, featureId2])

    // 创建 FeaturesDirective 实例
    let featuresDirective = FeaturesDirective(
        annotations, 
        featuresSet
    )

    println("featuresDirective: ${featuresDirective}")
}
```

运行结果：

```text
featuresDirective: features {std.core.feature1, std.core.feature2}
```

### func getFeaturesKeywordPos()

```cangjie
public func getFeaturesKeywordPos(): CodePositionRange    
```

功能：获取声明中的关键字 `features` 的位置信息。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange)

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建注解
    let annotations: Array<Annotation> = []

    // 创建 FeatureId
    let featureId = FeatureId(["std", "core", "feature"])

    // 创建 FeaturesSet
    let featuresSet = FeaturesSet([featureId])

    // 创建 FeaturesDirective 实例
    let featuresDirective = FeaturesDirective(
        annotations, 
        featuresSet
    )

    // 获取 features 关键字的位置
    let pos = featuresDirective.getFeaturesKeywordPos()

    // 输出关键字位置
    println("featuresDirective.getFeaturesKeywordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
featuresDirective.getFeaturesKeywordPos(): 1:1-1:9
```

## class FeaturesSet

```cangjie
public class FeaturesSet <: SyntaxTreeNode {
    public init(features: Array<FeatureId>, comments!: Array<Comment> = [])
}
```

功能：一个 feature set 节点。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop content

```cangjie
public prop content: Array<FeatureId>
```

功能：获取 features set 内包含的一组 featureId。

类型：Array\<[FeatureId](#class-featureid)>

### init(Array\<FeatureId>, Array\<Comment>)

```cangjie
public init(features: Array<FeatureId>, comments!: Array<Comment> = [])
```

功能：创建一个 FeaturesSet 对象。

参数：

- features: Array\<[FeatureId](#class-featureid)> - 一组定义在 features set 中的 feature id。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 FeatureId
    let featureId1 = FeatureId(["std", "core", "feature1"])
    let featureId2 = FeatureId(["std", "core", "feature2"])

    // 创建 FeaturesSet 实例
    let featuresSet = FeaturesSet([featureId1, featureId2])

    println("featuresSet: ${featuresSet}")
}
```

运行结果：

```text
featuresSet: {std.core.feature1, std.core.feature2}
```

### func getLCurlPos()

```cangjie
public func getLCurlPos(): CodePositionRange 
```

功能：获取 '{' 的位置信息。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange)

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FeatureId
    let featureId = FeatureId(["std", "core", "feature"])

    // 创建 FeaturesSet 实例
    let featuresSet = FeaturesSet([featureId])

    // 获取左花括号的位置
    let pos = featuresSet.getLCurlPos()

    // 输出左花括号位置
    println("featuresSet.getLCurlPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
featuresSet.getLCurlPos(): 1:1-1:2
```

### func getRCurlPos()

```cangjie
public func getRCurlPos(): CodePositionRange
```

功能：获取 '}' 的位置信息。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange)

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FeatureId
    let featureId = FeatureId(["std", "core", "feature"])

    // 创建 FeaturesSet 实例
    let featuresSet = FeaturesSet([featureId])

    // 获取右花括号的位置
    let pos = featuresSet.getRCurlPos()

    // 输出右花括号位置
    println("featuresSet.getRCurlPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
featuresSet.getRCurlPos(): 1:18-1:19
```

### func getCommaPoses()

```cangjie
public func getCommaPoses(): Array<CodePositionRange>
```

功能：获取 ',' 的位置信息。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)>

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建多个 FeatureId
    let featureId1 = FeatureId(["std", "core", "feature1"])
    let featureId2 = FeatureId(["std", "core", "feature2"])
    let featureId3 = FeatureId(["std", "core", "feature3"])

    // 创建 FeaturesSet 实例
    let featuresSet = FeaturesSet([featureId1, featureId2, featureId3])

    // 获取逗号的位置
    let posArr = featuresSet.getCommaPoses()

    // 输出逗号位置
    for (i in 0..posArr.size) {
        println("featuresSet.getCommaPoses()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
featuresSet.getCommaPoses()[0]: 1:19-1:20
featuresSet.getCommaPoses()[1]: 1:38-1:39
```

## class ForInExpr

```cangjie
public class ForInExpr <: Expr {
    public init(body: Block, expr: Expr, pattern: Pattern, patternGuard: Option<Expr>, comments!: Array<Comment> = [])
}
```

功能：表示 `for-in` 表达式。

[ForInExpr](#class-forinexpr) 类型中，关键字 `for` 之后是 [Pattern](#class-pattern), 此后是一个 `in` 关键字和表达式节点，最后是一个执行循环体 [Block](#class-block)。

父类型：

- [Expr](#class-expr)

### prop body

```cangjie
public prop body: Block
```

功能：获取当前 `for-in` 语句的循环体代码块。

类型：[Block](#class-block)

### prop expr

```cangjie
public prop expr: Expr
```

功能：获取当前 `for-in` 语句的集合表达式，即要遍历的对象。

类型：[Expr](#class-expr)

### prop pattern

```cangjie
public prop pattern: Pattern
```

功能：获取当前 `for-in` 语句的迭代变量模式。

类型：[Pattern](#class-pattern)

### prop patternGuard

```cangjie
public prop patternGuard: Option<Expr>
```

功能：获取当前 `for-in` 语句中用于迭代的条件表达式（若不存在返回 `None`）。

类型：Option\<[Expr](#class-expr)>

### init(Block, Expr, Pattern, Option\<Expr>, Array\<Comment>)

```cangjie
public init(body: Block, expr: Expr, pattern: Pattern, patternGuard: Option<Expr>, comments!: Array<Comment> = [])
```

功能：构造一个 [ForInExpr](#class-forinexpr) 对象，表示 `for-in` 循环表达式。

参数：

- body: [Block](#class-block) - 循环体代码块。
- expr: [Expr](#class-expr) - 被迭代的集合表达式。
- pattern: [Pattern](#class-pattern) - 用于解构每次迭代值的绑定模式。
- patternGuard: Option\<[Expr](#class-expr)> - 可选的模式守卫表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `pattern` 不是通配符模式、变量绑定模式、元组模式或枚举模式时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Block([])

    // 创建 expr
    let expr = LitConstExpr(LitConstKind.IntergerLiteral, "10")

    // 创建 pattern
    let pattern = VarPattern("x")

    // 创建 patternGuard
    let patternGuard = BinaryExpr(SymbolRef("x", []),BinaryOpKind.NotEq, LitConstExpr(LitConstKind.IntergerLiteral, "5"))

    // 创建 ForInExpr 实例
    let forInExpr = ForInExpr(
        body, 
        expr, 
        pattern, 
        patternGuard
    )

    println("forInExpr: ${forInExpr}")
}
```

运行结果：

```text
forInExpr: for (x in 10 where x != 5) {
}
```

### func getForKeyWordPos()

```cangjie
public func getForKeyWordPos(): CodePositionRange
```

功能：获取 [ForInExpr](#class-forinexpr) 节点中 `for` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `for` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 ForInExpr 实例
    let forInExpr = ForInExpr(Block([]), LitConstExpr(LitConstKind.IntergerLiteral, "10"), VarPattern("x"), None)
    let pos = forInExpr.getForKeyWordPos()

    // 输出 for 关键字位置
    println("forInExpr.getForKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
forInExpr.getForKeyWordPos(): 1:1-1:4
```

### func getInKeyWordPos()

```cangjie
public func getInKeyWordPos(): CodePositionRange
```

功能：获取 [ForInExpr](#class-forinexpr) 节点中 `in` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `in` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 ForInExpr 实例
    let forInExpr = ForInExpr(Block([]), LitConstExpr(LitConstKind.IntergerLiteral, "10"), VarPattern("x"), None)
    let pos = forInExpr.getInKeyWordPos()

    // 输出 in 关键字位置
    println("forInExpr.getInKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
forInExpr.getInKeyWordPos(): 1:8-1:10
```

### func getLParenPos()

```cangjie
public func getLParenPos(): CodePositionRange
```

功能：获取 [ForInExpr](#class-forinexpr) 节点中的 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 ForInExpr 实例
    let forInExpr = ForInExpr(Block([]), LitConstExpr(LitConstKind.IntergerLiteral, "10"), VarPattern("x"), None)
    let pos = forInExpr.getLParenPos()

    // 输出左括号位置
    println("forInExpr.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
forInExpr.getLParenPos(): 1:5-1:6
```

### func getRParenPos()

```cangjie
public func getRParenPos(): CodePositionRange
```

功能：获取 [ForInExpr](#class-forinexpr) 节点中的 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 ForInExpr 实例
    let forInExpr = ForInExpr(Block([]), LitConstExpr(LitConstKind.IntergerLiteral, "10"), VarPattern("x"), None)
    let pos = forInExpr.getRParenPos()

    // 输出右括号位置
    println("forInExpr.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
forInExpr.getRParenPos(): 1:13-1:14
```

### func getWhereKeyWordPos()

```cangjie
public func getWhereKeyWordPos(): Option<CodePositionRange>
```

功能：获取 [ForInExpr](#class-forinexpr) 节点中 `where` 关键字的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `where` 关键字的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 patternGuard
    let patternGuard = BinaryExpr(SymbolRef("x", []), BinaryOpKind.NotEq, LitConstExpr(LitConstKind.IntergerLiteral, "5"))

    // 创建 ForInExpr 实例
    let forInExpr = ForInExpr(Block([]), LitConstExpr(LitConstKind.IntergerLiteral, "10"), VarPattern("x"), patternGuard)

    if (let Some(pos) <- forInExpr.getWhereKeyWordPos()) {
        // 输出 where 关键字位置
        println("forInExpr.getWhereKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
forInExpr.getWhereKeyWordPos(): 1:14-1:19
```

## class FuncDecl

```cangjie
public class FuncDecl <: Decl {
    public init(body: Option<Block>, genericConstraints: Option<GenericConstraints>, genericParams: Array<GenericParam>,
        kind: FuncKind, name: String, params: ParameterList, retTyAnnotation: Option<TypeAnnotation>,
        annotations!: Array<Annotation> = [], modifiers!: Array<Modifier> = [], comments!: Array<Comment> = [])
}
```

功能：表示一个函数声明节点。

由可选的函数修饰符，关键字 `func`，函数名，可选的泛型约束列表，可选的类型形参列表，函数参数，可选的函数体，可缺省的函数返回类型来声明一个函数。

父类型：

- [Decl](#class-decl)

### prop body

```cangjie
public prop body: Option<Block>
```

功能：获取当前函数声明的主体部分（若不存在返回 `None`）。

类型：Option\<[Block](#class-block)>

### prop genericConstraints

```cangjie
public prop genericConstraints: Option<GenericConstraints>
```

功能：获取当前函数声明的泛型约束（若不存在返回 `None`）。

类型：Option\<[GenericConstraints](#class-genericconstraints)>

### prop genericParams

```cangjie
public prop genericParams: Array<GenericParam>
```

功能：获取当前函数声明的泛型参数列表。

类型：Array\<[GenericParam](#class-genericparam)>

### prop kind

```cangjie
public prop kind: FuncKind
```

功能：获取当前函数声明的种类。

类型：[FuncKind](syntax_package_enums.md#enum-funckind)

### prop name

```cangjie
public prop name: String
```

功能：获取当前函数声明的名称。

类型：String

### prop params

```cangjie
public prop params: ParameterList
```

功能：获取当前函数声明的参数列表。

类型：[ParameterList](#class-parameterlist)

### prop retTyAnnotation

```cangjie
public prop retTyAnnotation: Option<TypeAnnotation>
```

功能：获取当前函数声明的返回类型标注（若不存在返回 `None`）。

类型：Option\<[TypeAnnotation](#class-typeannotation)>

### init(Option\<Block>, Option\<GenericConstraints>, Array\<GenericParam>, FuncKind, String, ParameterList, Option\<TypeAnnotation>, Array\<Annotation>, Array\<Modifier>, Array\<Comment>)

```cangjie
public init(body: Option<Block>, genericConstraints: Option<GenericConstraints>, genericParams: Array<GenericParam>,
    kind: FuncKind, name: String, params: ParameterList, retTyAnnotation: Option<TypeAnnotation>,
    annotations!: Array<Annotation> = [], modifiers!: Array<Modifier> = [], comments!: Array<Comment> = [])
```

功能：构造一个 [FuncDecl](#class-funcdecl) 对象，表示函数声明节点。

参数：

- body: Option\<[Block](#class-block)> - 可选的函数体。
- genericConstraints: Option\<[GenericConstraints](#class-genericconstraints)> - 可选的泛型约束。
- genericParams: Array\<[GenericParam](#class-genericparam)> - 泛型参数列表。
- kind: [FuncKind](syntax_package_enums.md#enum-funckind) - 函数种类。
- name: String - 函数名。
- params: [ParameterList](#class-parameterlist) - 参数列表。
- retTyAnnotation: Option\<[TypeAnnotation](#class-typeannotation)> - 可选的返回类型注解。
- annotations!: Array\<[Annotation](#class-annotation)> - 附加的注解列表，默认为空数组。
- modifiers!: Array\<[Modifier](#class-modifier)> - 修饰符列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当函数种类和修饰符不对应，或输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Block([ReturnExpr(None)])

    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])

    // 创建 genericParams
    let genericParams = [GenericParam("T")]

    // 创建 kind
    let kind = FuncKind.Normal

    // 创建 name
    let name = "foo"

    // 创建 params
    let params = ParameterList([])

    // 创建 retTyAnnotation
    let retTyAnnotation = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 FuncDecl 实例
    let funcDecl = FuncDecl(
        body, 
        genericConstraints, 
        genericParams, 
        kind, 
        name, 
        params, 
        retTyAnnotation
    )

    println("funcDecl: ${funcDecl}")
}
```

运行结果：

```text
funcDecl: func foo<T>(): Int64 where T<:I1 {
    return
}
```

### func getFuncKeyWordPos()

```cangjie
public func getFuncKeyWordPos(): Option<CodePositionRange>
```

功能：获取 [FuncDecl](#class-funcdecl) 节点中 `func` 关键字的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `func` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FuncDecl 实例
    let funcDecl = FuncDecl(
        Block([ReturnExpr(None)]),
        None,
        [],
        FuncKind.Normal,
        "foo",
        ParameterList([]),
        AtomicType(AtomicTypeKind.Int64Type)
    )

    if (let Some(pos) <- funcDecl.getFuncKeyWordPos()) {
        // 输出 func 关键字位置
        println("funcDecl.getFuncKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
funcDecl.getFuncKeyWordPos(): 1:1-1:5
```

### func getFuncKindKeyWordPos()

```cangjie
public func getFuncKindKeyWordPos(): Option<CodePositionRange>
```

功能：获取 [FuncDecl](#class-funcdecl) 节点中 FuncKind 关键字的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 FuncKind 关键字的位置。

> **注意：**
>
> `kind` 为 `Finalizer` 时，返回 `~` 的位置，`kind` 为 `Operator` 时，返回 `operator` 的位置，`kind` 为 `Foreign` 时，返回 `foriegn` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 Operator 类型的 FuncDecl 实例
    let operatorFuncDecl = FuncDecl(
        Block([ReturnExpr(None)]),
        None,
        [],
        FuncKind.Operator,
        "+",
        ParameterList([]),
        AtomicType(AtomicTypeKind.Int64Type),
        modifiers: [Modifier(ModifierKind.Operator)]
    )

    if (let Some(pos) <- operatorFuncDecl.getFuncKindKeyWordPos()) {
        // 输出 operator 关键字位置
        println("operatorFuncDecl.getFuncKindKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
operatorFuncDecl.getFuncKindKeyWordPos(): 1:1-1:9
```

### func getGenericParamsCommasPos()

```cangjie
public func getGenericParamsCommasPos(): Array<CodePositionRange>
```

功能：获取 [FuncDecl](#class-funcdecl) 节点中泛型参数间 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数间 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建带有多个泛型参数的 FuncDecl 实例
    let funcDecl = FuncDecl(
        Block([ReturnExpr(None)]),
        None,
        [GenericParam("T"), GenericParam("U"), GenericParam("V")],
        FuncKind.Normal,
        "foo",
        ParameterList([]),
        AtomicType(AtomicTypeKind.Int64Type)
    )

    // 获取泛型参数间逗号的位置
    let posArr = funcDecl.getGenericParamsCommasPos()

    // 输出逗号位置
    for (i in 0..posArr.size) {
        println("funcDecl.getGenericParamsCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
funcDecl.getGenericParamsCommasPos()[0]: 1:11-1:12
funcDecl.getGenericParamsCommasPos()[1]: 1:14-1:15
```

### func getGenericParamsLAnglePos()

```cangjie
public func getGenericParamsLAnglePos(): Option<CodePositionRange>
```

功能：获取 [FuncDecl](#class-funcdecl) 节点中泛型参数 `<` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数 `<` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建带有泛型参数的 FuncDecl 实例
    let funcDecl = FuncDecl(
        Block([ReturnExpr(None)]),
        None,
        [GenericParam("T")],
        FuncKind.Normal,
        "foo",
        ParameterList([]),
        AtomicType(AtomicTypeKind.Int64Type)
    )

    if (let Some(pos) <- funcDecl.getGenericParamsLAnglePos()) {
        // 输出左尖括号位置
        println("funcDecl.getGenericParamsLAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
funcDecl.getGenericParamsLAnglePos(): 1:9-1:10
```

### func getGenericParamsRAnglePos()

```cangjie
public func getGenericParamsRAnglePos(): Option<CodePositionRange>
```

功能：获取 [FuncDecl](#class-funcdecl) 节点中泛型参数 `>` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数 `>` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建带有泛型参数的 FuncDecl 实例
    let funcDecl = FuncDecl(
        Block([ReturnExpr(None)]),
        None,
        [GenericParam("T")],
        FuncKind.Normal,
        "foo",
        ParameterList([]),
        AtomicType(AtomicTypeKind.Int64Type)
    )

    if (let Some(pos) <- funcDecl.getGenericParamsRAnglePos()) {
        // 输出右尖括号位置
        println("funcDecl.getGenericParamsRAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
funcDecl.getGenericParamsRAnglePos(): 1:11-1:12
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取 [FuncDecl](#class-funcdecl) 节点中标识符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回标识符的位置。

> **注意：**
>
> `kind` 为 `Finalizer` 时，返回 `init` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FuncDecl 实例
    let funcDecl = FuncDecl(
        Block([ReturnExpr(None)]),
        None,
        [],
        FuncKind.Normal,
        "foo",
        ParameterList([]),
        AtomicType(AtomicTypeKind.Int64Type)
    )

    // 获取标识符位置
    let pos = funcDecl.getIdentifierPos()

    // 输出标识符位置
    println("funcDecl.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
funcDecl.getIdentifierPos(): 1:6-1:9
```

### func getRetTyAnnotationColonPos()

```cangjie
public func getRetTyAnnotationColonPos(): Option<CodePositionRange>
```

功能：获取 [FuncDecl](#class-funcdecl) 节点中类型前 `:` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回类型前 `:` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建带有返回类型注解的 FuncDecl 实例
    let funcDecl = FuncDecl(
        Block([ReturnExpr(None)]),
        None,
        [],
        FuncKind.Normal,
        "foo",
        ParameterList([]),
        AtomicType(AtomicTypeKind.Int64Type)
    )

    if (let Some(pos) <- funcDecl.getRetTyAnnotationColonPos()) {
        // 输出冒号位置
        println("funcDecl.getRetTyAnnotationColonPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
funcDecl.getRetTyAnnotationColonPos(): 1:11-1:12
```

## class FuncParam

```cangjie
public open class FuncParam <: Parameter {
    public init(defaultValue: Option<Expr>, kind: Option<VarKind>, name: String, typeAnnotation: TypeAnnotation,
        isNamed!: Bool = false, annotations!: Array<Annotation> = [], modifiers!: Array<Modifier> = [],
        comments!: Array<Comment> = [])
}
```

功能：表示一个函数参数。

[FuncParam](#class-funcparam) 类用于在程序中声明一个新的函数参数，`defaultValue` 表示参数的默认值，`name` 表示参数的名称，`typeAnnotation` 表示参数的类型标注。

父类型：

- [Parameter](#class-parameter)

### prop defaultValue

```cangjie
public prop defaultValue: Option<Expr>
```

功能：获取当前函数参数的默认值（若不存在返回 `None`）。

类型：Option\<[Expr](#class-expr)>

### prop kind

```cangjie
public prop kind: Option<VarKind>
```

功能：获取当前函数参数的种类（若不存在返回 `None`）。

类型：Option\<[VarKind](syntax_package_enums.md#enum-varkind)>

### prop name

```cangjie
public prop name: String
```

功能：获取当前函数参数的名称。

类型：String

### prop typeAnnotation

```cangjie
public prop typeAnnotation: TypeAnnotation
```

功能：获取当前函数参数的类型标注。

类型：[TypeAnnotation](#class-typeannotation)

### init(Option\<Expr>, Option\<VarKind>, String, TypeAnnotation, Bool, Array\<Annotation>, Array\<Modifier>, Array\<Comment>)

```cangjie
public init(defaultValue: Option<Expr>, kind: Option<VarKind>, name: String, typeAnnotation: TypeAnnotation,
    isNamed!: Bool = false, annotations!: Array<Annotation> = [], modifiers!: Array<Modifier> = [],
    comments!: Array<Comment> = [])
```

功能：构造一个 [FuncParam](#class-funcparam) 对象，表示函数参数节点。

参数：

- defaultValue: Option\<[Expr](#class-expr)> - 可选的默认值表达式。
- kind: Option\<[VarKind](syntax_package_enums.md#enum-varkind)> - 可选的变量种类。
- name: String - 参数名。
- typeAnnotation: [TypeAnnotation](#class-typeannotation) - 类型注解。
- isNamed!: Bool - 是否为命名参数，默认为 `false`。
- annotations!: Array\<[Annotation](#class-annotation)> - 附加的注解列表，默认为空数组。
- modifiers!: Array\<[Modifier](#class-modifier)> - 修饰符列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `kind` 不代表 `var` 或 `let`，或 `kind` 为空但 `modifiers` 不为空，或没有传入参数名却为命名参数，或输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 defaultValue
    let defaultValue = LitConstExpr(LitConstKind.IntergerLiteral, "1")

    // 创建 kind
    let kind = VarKind.Let

    // 创建 name
    let name = "x"

    // 创建 typeAnnotation
    let typeAnnotation = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 isNamed
    let isNamed = true

    // 创建 FuncParam 实例
    let funcParam = FuncParam(
        defaultValue, 
        kind, 
        name, 
        typeAnnotation, 
        isNamed: isNamed
    )

    println("funcParam: ${funcParam}")
}
```

运行结果：

```text
funcParam: let x!: Int64 = 1
```

### func getAssignPos()

```cangjie
public func getAssignPos(): Option<CodePositionRange>
```

功能：获取 [FuncParam](#class-funcparam) 节点中 `=` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `=` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FuncParam 实例
    let defaultValue = LitConstExpr(LitConstKind.IntergerLiteral, "1")
    let funcParam = FuncParam(defaultValue, VarKind.Let, "x", AtomicType(AtomicTypeKind.Int64Type), isNamed: true)

    if (let Some(pos) <- funcParam.getAssignPos()) {
        // 输出等号位置
        println("funcParam.getAssignPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
funcParam.getAssignPos(): 1:15-1:16
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取 [FuncParam](#class-funcparam) 节点中标识符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回标识符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FuncParam 实例
    let funcParam = FuncParam(None, VarKind.Let, "x", AtomicType(AtomicTypeKind.Int64Type))
    let pos = funcParam.getIdentifierPos()

    // 输出标识符位置
    println("funcParam.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
funcParam.getIdentifierPos(): 1:5-1:6
```

### func getNotPos()

```cangjie
public func getNotPos(): Option<CodePositionRange>
```

功能：获取 [FuncParam](#class-funcparam) 节点中 `!` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `!` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FuncParam 实例
    let funcParam = FuncParam(None, VarKind.Let, "x", AtomicType(AtomicTypeKind.Int64Type), isNamed: true)

    if (let Some(pos) <- funcParam.getNotPos()) {
        // 输出感叹号位置
        println("funcParam.getNotPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
funcParam.getNotPos(): 1:6-1:7
```

### func getTypeAnnotationColonPos()

```cangjie
public func getTypeAnnotationColonPos(): CodePositionRange
```

功能：获取 [FuncParam](#class-funcparam) 节点中 `:` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `:` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FuncParam 实例
    let funcParam = FuncParam(None, VarKind.Let, "x", AtomicType(AtomicTypeKind.Int64Type))
    let pos = funcParam.getTypeAnnotationColonPos()

    // 输出冒号位置
    println("funcParam.getTypeAnnotationColonPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
funcParam.getTypeAnnotationColonPos(): 1:6-1:7
```

### func getVarKindKeyWordPos()

```cangjie
public func getVarKindKeyWordPos(): Option<CodePositionRange>
```

功能：获取 [FuncParam](#class-funcparam) 节点中关键字 `let` 或 `var` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回关键字 `let` 或 `var` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FuncParam 实例
    let funcParam = FuncParam(None, VarKind.Let, "x", AtomicType(AtomicTypeKind.Int64Type))

    if (let Some(pos) <- funcParam.getVarKindKeyWordPos()) {
        // 输出 let/var 关键字位置
        println("funcParam.getVarKindKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
funcParam.getVarKindKeyWordPos(): 1:1-1:4
```

## class FuncType

```cangjie
public class FuncType <: TypeAnnotation {
    public init(paramTypes: Array<TypeAnnotation>, labels: Array<String>, retType: TypeAnnotation, comments!: Array<Comment> = [])
}
```

功能：表示函数类型节点。

由函数的参数类型和返回类型组成，参数类型与返回类型之间用 `->` 分隔，如：`(Int32) -> Unit`。

父类型：

- [TypeAnnotation](#class-typeannotation)

### prop labels

```cangjie
public prop labels: Array<String>
```

功能：获取 [FuncType](#class-functype) 节点中的类型参数名，例如 `(name: String, age: Int64) -> Unit` 中的 `name` 和 `age`。

类型：Array\<String>

### prop paramTypes

```cangjie
public prop paramTypes: Array<TypeAnnotation>
```

功能：获取 [FuncType](#class-functype) 节点中函数的参数类型列表。

类型：Array\<[TypeAnnotation](#class-typeannotation)>

### prop retType

```cangjie
public prop retType: TypeAnnotation
```

功能：获取 [FuncType](#class-functype) 的返回类型节点。

类型：[TypeAnnotation](#class-typeannotation)

### init(Array\<TypeAnnotation>, Array\<String>, TypeAnnotation, Array\<Comment>)

```cangjie
public init(paramTypes: Array<TypeAnnotation>, labels: Array<String>, retType: TypeAnnotation, comments!: Array<Comment> = [])
```

功能：构造一个 [FuncType](#class-functype) 对象，表示函数类型，如 `(a: Int64, b: String) -> Bool`。

参数：

- paramTypes: Array\<[TypeAnnotation](#class-typeannotation)> - 参数类型列表。
- labels: Array\<String> - 参数标签列表。
- retType: [TypeAnnotation](#class-typeannotation) - 返回类型。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当参数类型列表和参数名列表长度不一样时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 paramTypes
    let paramTypes: Array<TypeAnnotation> = [CompositeType("I1", [], [])]

    // 创建 labels
    let labels = ["x"]

    // 创建 retType
    let retType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 FuncType 实例
    let funcType = FuncType(
        paramTypes, 
        labels, 
        retType
    )

    println("funcType: ${funcType}")
}
```

运行结果：

```text
funcType: (x: I1) -> Int64
```

### func getArrowPos()

```cangjie
public func getArrowPos(): CodePositionRange
```

功能：获取 `->` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `->` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FuncType 实例
    let funcType = FuncType(
        [AtomicType(AtomicTypeKind.Int64Type), AtomicType(Int32Type)],
        ["a", "b"],
        AtomicType(BoolType)
    )

    // 获取箭头位置
    let pos = funcType.getArrowPos()

    // 输出箭头位置
    println("funcType.getArrowPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
funcType.getArrowPos(): 1:22-1:24
```

### func getColonsPos()

```cangjie
public func getColonsPos(): Array<CodePositionRange>
```

功能：获取 `:` 的位置序列。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `:` 的位置序列。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FuncType 实例
    let funcType = FuncType(
        [AtomicType(AtomicTypeKind.Int64Type), AtomicType(Int32Type)],
        ["a", "b"],
        AtomicType(BoolType)
    )

    // 获取冒号位置
    let posArr = funcType.getColonsPos()

    // 输出冒号位置
    for (i in 0..posArr.size) {
        println("funcType.getColonsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
funcType.getColonsPos()[0]: 1:3-1:4
funcType.getColonsPos()[1]: 1:13-1:14
```

### func getCommasPos()

```cangjie
public func getCommasPos(): Array<CodePositionRange>
```

功能：获取 `,` 的位置序列。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `,` 的位置序列。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FuncType 实例
    let funcType = FuncType(
        [AtomicType(AtomicTypeKind.Int64Type), AtomicType(Int32Type), AtomicType(BoolType)],
        ["a", "b", "c"],
        AtomicType(UnitType)
    )

    // 获取逗号位置
    let posArr = funcType.getCommasPos()

    // 输出逗号位置
    for (i in 0..posArr.size) {
        println("funcType.getCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
funcType.getCommasPos()[0]: 1:10-1:11
funcType.getCommasPos()[1]: 1:20-1:21
```

### func getLabelsPos()

```cangjie
public func getLabelsPos(): Array<CodePositionRange>
```

功能：获取标签的位置序列。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回标签的位置序列。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FuncType 实例
    let funcType = FuncType(
        [AtomicType(AtomicTypeKind.Int64Type), AtomicType(Int32Type)],
        ["a", "b"],
        AtomicType(BoolType)
    )

    // 获取标签位置
    let posArr = funcType.getLabelsPos()

    // 输出标签位置
    for (i in 0..posArr.size) {
        println("funcType.getLabelsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
funcType.getLabelsPos()[0]: 1:2-1:3
funcType.getLabelsPos()[1]: 1:12-1:13
```

### func getLParenPos()

```cangjie
public func getLParenPos(): CodePositionRange
```

功能：获取 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FuncType 实例
    let funcType = FuncType(
        [AtomicType(AtomicTypeKind.Int64Type)],
        ["a"],
        AtomicType(BoolType)
    )

    // 获取左括号位置
    let pos = funcType.getLParenPos()

    // 输出左括号位置
    println("funcType.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
funcType.getLParenPos(): 1:1-1:2
```

### func getRParenPos()

```cangjie
public func getRParenPos(): CodePositionRange
```

功能：获取 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 FuncType 实例
    let funcType = FuncType(
        [AtomicType(AtomicTypeKind.Int64Type)],
        ["a"],
        AtomicType(BoolType)
    )

    // 获取右括号位置
    let pos = funcType.getRParenPos()

    // 输出右括号位置
    println("funcType.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
funcType.getRParenPos(): 1:10-1:11
```

## class GenericConstraint

```cangjie
public class GenericConstraint <: SyntaxTreeNode {
    public init(typeArgument: TypeAnnotation, upperBounds: Array<TypeAnnotation>, comments!: Array<Comment> = [])
}
```

功能：表示一个泛型约束节点。

一个 [GenericConstraint](#class-genericconstraint) 节点：`interface Enumerable<T> where T <: Interface & Class {}` 中的 `where T <: Interface & Class`。

> **说明：**
>
> 通过 `where` 之后的 `<:` 符号来声明，其中 `<:` 左边称为类型变元，`<:` 右边称为约束上界，约束上界可以为类型或接口。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop typeArgument

```cangjie
public prop typeArgument: TypeAnnotation
```

功能：获取 [GenericConstraint](#class-genericconstraint) 节点中的类型变元。

类型：[TypeAnnotation](#class-typeannotation)

### prop upperBounds

```cangjie
public prop upperBounds: Array<TypeAnnotation>
```

功能：获取 [GenericConstraint](#class-genericconstraint) 节点约束上界的 [TypeAnnotation](#class-typeannotation) 类型节点的集合。

类型：Array\<[TypeAnnotation](#class-typeannotation)>

### init(TypeAnnotation, Array\<TypeAnnotation>, Array\<Comment>)

```cangjie
public init(typeArgument: TypeAnnotation, upperBounds: Array<TypeAnnotation>, comments!: Array<Comment> = [])
```

功能：构造一个 [GenericConstraint](#class-genericconstraint) 对象，表示泛型约束。

参数：

- typeArgument: [TypeAnnotation](#class-typeannotation) - 被约束的类型参数。
- upperBounds: Array\<[TypeAnnotation](#class-typeannotation)> - 上界类型列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `upperBounds` 为空时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 typeArgument
    let typeArgument = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 upperBounds
    let upperBounds: Array<TypeAnnotation> = [CompositeType("I1", [], [])]

    // 创建 GenericConstraint 实例
    let genericConstraint = GenericConstraint(
        typeArgument, 
        upperBounds
    )

    println("genericConstraint: ${genericConstraint}")
}
```

运行结果：

```text
genericConstraint: Int64<:I1
```

### func getBitAndsPos()

```cangjie
public func getBitAndsPos(): Array<CodePositionRange>
```

功能：获取 [GenericConstraint](#class-genericconstraint) 节点中 `&` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `&` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 GenericConstraint 实例
    let typeArgument = AtomicType(AtomicTypeKind.Int64Type)
    let upperBounds: Array<TypeAnnotation> = [CompositeType("I1", [], []), CompositeType("I2", [], [])]
    let genericConstraint = GenericConstraint(typeArgument, upperBounds)
    let posArr = genericConstraint.getBitAndsPos()

    // 遍历输出&位置
    for (i in 0..posArr.size) {
        println("genericConstraint.getBitAndsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
genericConstraint.getBitAndsPos()[0]: 1:11-1:12
```

### func getUpperBoundPos()

```cangjie
public func getUpperBoundPos(): CodePositionRange
```

功能：获取 [GenericConstraint](#class-genericconstraint) 节点中 `<:` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `<:` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 GenericConstraint 实例
    let typeArgument = AtomicType(AtomicTypeKind.Int64Type)
    let upperBounds: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    let genericConstraint = GenericConstraint(typeArgument, upperBounds)
    let pos = genericConstraint.getUpperBoundPos()

    // 输出 <: 位置
    println("genericConstraint.getUpperBoundPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
genericConstraint.getUpperBoundPos(): 1:6-1:8
```

## class GenericConstraints

```cangjie
public class GenericConstraints <: SyntaxTreeNode {
    public init(constraints: Array<GenericConstraint>, comments!: Array<Comment> = [])
}
```

功能：表示一组泛型约束。

一个 [GenericConstraints](#class-genericconstraints) 节点：`interface Enumerable<T1, T2> where T1 <: I1 & I2, T2 <: I3 & I4` 中的 `where T1 <: I1 & I2, T2 <: I3 & I4`。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop constraints

```cangjie
public prop constraints: Array<GenericConstraint>
```

功能：获取 [GenericConstraints](#class-genericconstraints) 节点中的所有约束。

类型：Array\<[GenericConstraint](#class-genericconstraint)>

### init(Array\<GenericConstraint>, Array\<Comment>)

```cangjie
public init(constraints: Array<GenericConstraint>, comments!: Array<Comment> = [])
```

功能：构造一个 [GenericConstraints](#class-genericconstraints) 对象，表示一组泛型约束。

参数：

- constraints: Array\<[GenericConstraint](#class-genericconstraint)> - 泛型约束列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `constraints` 为空时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 constraints
    let constraints = [
        GenericConstraint(CompositeType("I1", [], []), [CompositeType("T", [], [])]), 
        GenericConstraint(CompositeType("I2", [], []), [CompositeType("T", [], []), CompositeType("U", [], [])])
    ]

    // 创建 GenericConstraints 实例
    let genericConstraints = GenericConstraints(
        constraints
    )

    println("genericConstraints: ${genericConstraints}")
}
```

运行结果：

```text
genericConstraints: where I1<:T, I2<:T & U
```

### func getCommasPos()

```cangjie
public func getCommasPos(): Array<CodePositionRange>
```

功能：获取 [GenericConstraints](#class-genericconstraints) 节点中 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 GenericConstraints 实例
    let constraints = [
        GenericConstraint(CompositeType("I1", [], []), [CompositeType("T", [], [])]),
        GenericConstraint(CompositeType("I2", [], []), [CompositeType("T", [], []), CompositeType("U", [], [])])
    ]
    let genericConstraints = GenericConstraints(constraints)
    let posArr = genericConstraints.getCommasPos()

    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("genericConstraints.getCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
genericConstraints.getCommasPos()[0]: 1:12-1:13
```

### func getWhereKeyWordPos()

```cangjie
public func getWhereKeyWordPos(): CodePositionRange
```

功能：获取 [GenericConstraints](#class-genericconstraints) 节点中 `where` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `where` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 GenericConstraints 实例
    let constraints = [
        GenericConstraint(CompositeType("I1", [], []), [CompositeType("T", [], [])])
    ]
    let genericConstraints = GenericConstraints(constraints)
    let pos = genericConstraints.getWhereKeyWordPos()

    // 输出 where 关键字位置
    println("genericConstraints.getWhereKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
genericConstraints.getWhereKeyWordPos(): 1:1-1:6
```

## class GenericParam

```cangjie
public class GenericParam <: Decl {
    public init(name: String, comments!: Array<Comment> = [])
}
```

功能：表示一个泛型参数节点。

一个 [GenericParam](#class-genericparam) 节点：`<T1, T2, T3>` 中的 `T1`。

父类型：

- [Decl](#class-decl)

### prop name

```cangjie
public prop name: String
```

功能：获取当前型参的名称。

类型：String

### init(String, Array\<Comment>)

```cangjie
public init(name: String, comments!: Array<Comment> = [])
```

功能：构造一个 [GenericParam](#class-genericparam) 对象，表示泛型参数节点。

参数：

- name: String - 泛型参数名。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 name
    let name = "T"

    // 创建 GenericParam 实例
    let genericParam = GenericParam(
        name
    )

    println("genericParam: ${genericParam}")
}
```

运行结果：

```text
genericParam: T
```

## class IfExpr

```cangjie
public class IfExpr <: Expr {
    public init(condition: DisjunctionCondition, elseBlock: Option<Block>, elseIf: Option<IfExpr>, ifBlock: Block, comments!: Array<Comment> = [])
}
```

功能：表示条件表达式。

可以根据判定条件是否成立来决定执行哪条代码分支。一个 [IfExpr](#class-ifexpr) 节点中 `if` 是关键字，`if` 之后是一个小括号，小括号内可以是一个表达式或者一个 `let` 声明的解构匹配，接着是一个 [Block](#class-block)，[Block](#class-block) 之后是可选的 `else` 分支。 `else` 分支以 `else` 关键字开始，后接新的 `if` 表达式或一个 [Block](#class-block)。

父类型：

- [Expr](#class-expr)

### prop condition

```cangjie
public prop condition: DisjunctionCondition
```

功能：获取当前 `if` 语句的条件表达式。

类型：[DisjunctionCondition](#class-disjunctioncondition)

### prop elseBlock

```cangjie
public prop elseBlock: Option<Block>
```

功能：获取当前 `if` 语句的 `else` 分支代码块（若不存在返回 `None`）。

类型：Option\<[Block](#class-block)>

### prop elseIf

```cangjie
public prop elseIf: Option<IfExpr>
```

功能：获取当前 `if` 语句的 `else if` 分支（若不存在返回 `None`）。

类型：Option\<[IfExpr](#class-ifexpr)>

### prop ifBlock

```cangjie
public prop ifBlock: Block
```

功能：获取当前 `if` 语句的 `if` 分支代码块。

类型：[Block](#class-block)

### init(DisjunctionCondition, Option\<Block>, Option\<IfExpr>, Block, Array\<Comment>)

```cangjie
public init(condition: DisjunctionCondition, elseBlock: Option<Block>, elseIf: Option<IfExpr>, ifBlock: Block, comments!: Array<Comment> = [])
```

功能：构造一个 [IfExpr](#class-ifexpr) 对象，表示 `if` 条件表达式。

参数：

- condition: [DisjunctionCondition](#class-disjunctioncondition) - 条件表达式。
- elseBlock: Option\<[Block](#class-block)> - 可选的 `else` 分支代码块。
- elseIf: Option\<[IfExpr](#class-ifexpr)> - 可选的 `else if` 分支。
- ifBlock: [Block](#class-block) - `if` 分支代码块。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入中存在多个 `elseBlock` 时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 condition
    let cond = [
        ConjunctionCondition(AtomicCondition.Expression(SymbolRef("x", [])))
    ]

    // 创建 DisjunctionCondition 实例
    let condition = DisjunctionCondition(cond)

    // 创建 elseBlock
    let elseBlock = Block([ReturnExpr(LitConstExpr(LitConstKind.IntergerLiteral, "100"))])

    // 创建 ifBlock
    let ifBlock = Block([ReturnExpr(LitConstExpr(LitConstKind.IntergerLiteral, "10"))])

    // 创建 IfExpr 实例
    let ifExpr = IfExpr(
        condition, 
        elseBlock, 
        None, 
        ifBlock
    )

    println("ifExpr: ${ifExpr}")
}
```

运行结果：

```text
ifExpr: if (x) {
    return 10
} else {
    return 100
}
```

### func getCondLParenPos()

```cangjie
public func getCondLParenPos(): CodePositionRange
```

功能：获取 [IfExpr](#class-ifexpr) 节点中条件的 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回条件的 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 condition
    let condition = DisjunctionCondition([ConjunctionCondition(AtomicCondition.Expression(SymbolRef("x", [])))])

    // 创建 ifBlock
    let ifBlock = Block([ReturnExpr(LitConstExpr(LitConstKind.IntergerLiteral, "10"))])

    // 创建 IfExpr 实例
    let ifExpr = IfExpr(condition, None, None, ifBlock)
    let pos = ifExpr.getCondLParenPos()

    // 输出条件左括号位置
    println("ifExpr.getCondLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
ifExpr.getCondLParenPos(): 1:4-1:5
```

### func getCondRParenPos()

```cangjie
public func getCondRParenPos(): CodePositionRange
```

功能：获取 [IfExpr](#class-ifexpr) 节点中条件的 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回条件的 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 condition
    let condition = DisjunctionCondition([ConjunctionCondition(AtomicCondition.Expression(SymbolRef("x", [])))])

    // 创建 ifBlock
    let ifBlock = Block([ReturnExpr(LitConstExpr(LitConstKind.IntergerLiteral, "10"))])

    // 创建 IfExpr 实例
    let ifExpr = IfExpr(condition, None, None, ifBlock)
    let pos = ifExpr.getCondRParenPos()

    // 输出条件右括号位置
    println("ifExpr.getCondRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
ifExpr.getCondRParenPos(): 1:6-1:7
```

### func getElseKeyWordPos()

```cangjie
public func getElseKeyWordPos(): Option<CodePositionRange>
```

功能：获取 [IfExpr](#class-ifexpr) 节点中 `else` 关键字的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `else` 关键字的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 condition
    let condition = DisjunctionCondition([ConjunctionCondition(AtomicCondition.Expression(SymbolRef("x", [])))])

    // 创建 elseBlock
    let elseBlock = Block([ReturnExpr(LitConstExpr(LitConstKind.IntergerLiteral, "100"))])

    // 创建 ifBlock
    let ifBlock = Block([ReturnExpr(LitConstExpr(LitConstKind.IntergerLiteral, "10"))])

    // 创建 IfExpr 实例
    let ifExpr = IfExpr(condition, elseBlock, None, ifBlock)

    if (let Some(pos) <- ifExpr.getElseKeyWordPos()) {
        // 输出 else 关键字位置
        println("ifExpr.getElseKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
ifExpr.getElseKeyWordPos(): 3:3-3:7
```

### func getIfKeyWordPos()

```cangjie
public func getIfKeyWordPos(): CodePositionRange
```

功能：获取 [IfExpr](#class-ifexpr) 节点中 `if` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `if` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 condition
    let condition = DisjunctionCondition([ConjunctionCondition(AtomicCondition.Expression(SymbolRef("x", [])))])

    // 创建 ifBlock
    let ifBlock = Block([ReturnExpr(LitConstExpr(LitConstKind.IntergerLiteral, "10"))])

    // 创建 IfExpr 实例
    let ifExpr = IfExpr(condition, None, None, ifBlock)
    let pos = ifExpr.getIfKeyWordPos()

    // 输出 if 关键字位置
    println("ifExpr.getIfKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
ifExpr.getIfKeyWordPos(): 1:1-1:3
```

## class ImportAlias

```cangjie
public class ImportAlias <: ImportContent {
    public init(prefixes: Array<String>, identifier: String, alias: String, comments!: Array<Comment> = [])
}
```

功能：表示一个别名导入的包导入声明节点的具体项目，如 `import pkg.a.b as p` 中的 `pkg.a.b as p`。

父类型：

- [ImportContent](#class-importcontent)

### prop aliasName

```cangjie
public prop aliasName: String
```

功能：表示该包导入节点中的别名，如 `pkg.a.b as p` 中的 `p`。

类型：String

### prop identifier

```cangjie
public prop identifier: String
```

功能：表示该包导入节点中的被导入的项，它可能是包中的顶层声明或声明，也可能是子包的名字，如 `pkg.a.b as a` 中的 `b`。

类型：String

### init(Array\<String>, String, String, Array\<Comment>)

```cangjie
public init(prefixes: Array<String>, identifier: String, alias: String, comments!: Array<Comment> = [])
```

功能：构造一个 [ImportAlias](#class-importalias) 对象，表示带别名的导入项。

参数：

- prefixes: Array\<String> - 导入路径的前缀列表，如 `["pkg"]`。
- identifier: String - 被导入的标识符名称，如 `A`。
- alias: String - 别名名称，如 `B`。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `identifier` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 prefixes
    let prefixes = ["pkg"]

    // 创建 identifier
    let identifier = "a"

    // 创建 alias
    let alias = "p"

    // 创建 ImportAlias 实例
    let importAlias = ImportAlias(
        prefixes, 
        identifier, 
        alias
    )

    println("importAlias: ${importAlias}")
}
```

运行结果：

```text
importAlias: pkg.a as p
```

### func getAliasNamePos()

```cangjie
public func getAliasNamePos(): CodePositionRange
```

功能：获取当前 [ImportAlias](#class-importalias) 中包的别名的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回包别名的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 ImportAlias 实例
    let importAlias = ImportAlias(["pkg"], "a", "p")
    let pos = importAlias.getAliasNamePos()

    // 输出别名位置
    println("importAlias.getAliasNamePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
importAlias.getAliasNamePos(): 1:10-1:11
```

### func getAsPos()

```cangjie
public func getAsPos(): CodePositionRange
```

功能：获取当前 [ImportAlias](#class-importalias) 中 `as` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `as` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 ImportAlias 实例
    let importAlias = ImportAlias(["pkg"], "a", "p")
    let pos = importAlias.getAsPos()

    // 输出 as 关键字位置
    println("importAlias.getAsPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
importAlias.getAsPos(): 1:7-1:9
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取当前 [ImportAlias](#class-importalias) 中原始包名的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回原始包名的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 ImportAlias 实例
    let importAlias = ImportAlias(["pkg"], "a", "p")
    let pos = importAlias.getIdentifierPos()

    // 输出原始包名位置
    println("importAlias.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
importAlias.getIdentifierPos(): 1:5-1:6
```

## class ImportAll

```cangjie
public class ImportAll <: ImportContent {
    public init(prefixes: Array<String>, comments!: Array<Comment> = [])
}
```

功能：表示一个全导入的包导入声明节点的具体项目，如 `import pkg.*` 中的 `pkg.*`。

父类型：

- [ImportContent](#class-importcontent)

### init(Array\<String>, Array\<Comment>)

```cangjie
public init(prefixes: Array<String>, comments!: Array<Comment> = [])
```

功能：构造一个 [ImportAll](#class-importall) 对象，表示通配符导入。

参数：

- prefixes: Array\<String> - 导入路径的前缀列表，如 `["pkg"]`。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 prefixes
    let prefixes = ["pkg"]

    // 创建 ImportAll 实例
    let importAll = ImportAll(
        prefixes
    )

    println("importAll: ${importAll}")
}
```

运行结果：

```text
importAll: pkg.*
```

### func getMulPos()

```cangjie
public func getMulPos(): CodePositionRange
```

功能：获取当前 [ImportAll](#class-importall) 中 `*` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `*` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 ImportAll 实例
    let importAll = ImportAll(["pkg"])
    let pos = importAll.getMulPos()

    // 输出星号位置
    println("importAll.getMulPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
importAll.getMulPos(): 1:5-1:6
```

## class ImportContent

```cangjie
public open class ImportContent <: SyntaxTreeNode {}
```

功能：表示一个包导入声明节点的具体声明内容，如 `import pkg.a.b` 中的 `pkg.a.b`。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop prefixes

```cangjie
public prop prefixes: Array<String>
```

功能：表示该包导入节点中完整包名的前缀列表，如 `pkg.a.b` 中的 `[pkg, a]`。

类型：Array\<String>

### func getDotsPos()

```cangjie
public func getDotsPos(): Array<CodePositionRange>
```

功能：获取当前 [ImportContent](#class-importcontent) 中所有 `.` 分隔符的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回所有 `.` 分隔符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 使用 ImportSingle 子类来演示
    let importSingle = ImportSingle(["pkg", "a"], "b")
    let posArr = importSingle.getDotsPos()

    // 输出点号位置
    for (i in 0..posArr.size) {
        println("importSingle.getDotsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
importSingle.getDotsPos()[0]: 1:4-1:5
importSingle.getDotsPos()[1]: 1:6-1:7
```

### func getPrefixesPos()

```cangjie
public func getPrefixesPos(): Array<CodePositionRange>
```

功能：获取当前 [ImportMulti](#class-importmulti) 中所有前缀包名的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回所有前缀包名的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 使用 ImportSingle 子类来演示
    let importSingle = ImportSingle(["pkg", "a"], "b")
    let posArr = importSingle.getPrefixesPos()

    // 输出前缀包名位置
    for (i in 0..posArr.size) {
        println("importSingle.getPrefixesPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
importSingle.getPrefixesPos()[0]: 1:1-1:4
importSingle.getPrefixesPos()[1]: 1:5-1:6
```

## class ImportList

```cangjie
public class ImportList <: SyntaxTreeNode {
    public init(contents: ImportContent, modifier: Option<Modifier>, comments!: Array<Comment> = [])
}
```

功能：表示包导入节点。

一个 [ImportList](#class-importlist) 节点：`import pkg.a.b`，`import pkg.a.b as p` 等。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop contents

```cangjie
public prop contents: ImportContent
```

功能：表示该包导入节点中的导入内容。

类型：[ImportContent](#class-importcontent)

### prop kind

```cangjie
public prop kind: ImportKind
```

功能：表示该包导入节点的类型。

类型：[ImportKind](syntax_package_enums.md#enum-importkind)

### prop modifier

```cangjie
public prop modifier: Option<Modifier>
```

功能：表示该包导入节点中的修饰符。

类型：Option\<[Modifier](#class-modifier)>

### init(ImportContent, Option\<Modifier>, Array\<Comment>)

```cangjie
public init(contents: ImportContent, modifier: Option<Modifier>, comments!: Array<Comment> = [])
```

功能：构造一个 [ImportList](#class-importlist) 对象，表示一条导入语句，如 `import pkg.A`。

参数：

- contents: [ImportContent](#class-importcontent) - 导入内容。
- modifier: Option\<[Modifier](#class-modifier)> - 修饰符，可选。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `modifier` 不为 [Public](syntax_package_enums.md#public)、[Protected](syntax_package_enums.md#protected)、[Private](syntax_package_enums.md#private) 或 [Internal](syntax_package_enums.md#internal) 时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 contents
    let contents = ImportSingle(["pkg"], "a")

    // 创建 modifier
    let modifier = Modifier(ModifierKind.Public)

    // 创建 ImportList 实例
    let importList = ImportList(
        contents, 
        modifier
    )

    println("importList: ${importList}")
}
```

运行结果：

```text
importList: public import pkg.a
```

### func getImportKeyWordPos()

```cangjie
public func getImportKeyWordPos(): CodePositionRange
```

功能：获取当前 [ImportList](#class-importlist) 中 `import` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `import` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 ImportList 实例
    let contents = ImportSingle(["pkg"], "a")
    let importList = ImportList(contents, None)
    let pos = importList.getImportKeyWordPos()

    // 输出 import 关键字位置
    println("importList.getImportKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
importList.getImportKeyWordPos(): 1:1-1:7
```

## class ImportMulti

```cangjie
public class ImportMulti <: ImportContent {
    public init(prefixes: Array<String>, contents: Array<ImportContent>, comments!: Array<Comment> = [])
}
```

功能：表示一个多导入的包导入声明节点的具体项目，如 `import pkg.{a.*, b.c, d as p}` 中的 `pkg.{a.*, b.c, d as p}`。

父类型：

- [ImportContent](#class-importcontent)

### prop contents

```cangjie
public prop contents: Array<ImportContent>
```

功能：表示该包导入节点中的多个导入项的列表，如 `pkg.{a.*, b.c, d as p}` 中的 `[a.*, b.c, d as p]`。

类型：Array\<[ImportContent](#class-importcontent)>

### init(Array\<String>, Array\<ImportContent>, Array\<Comment>)

```cangjie
public init(prefixes: Array<String>, contents: Array<ImportContent>, comments!: Array<Comment> = [])
```

功能：构造一个 [ImportMulti](#class-importmulti) 对象，表示多导入项。

参数：

- prefixes: Array\<String> - 导入路径的前缀列表，如 `["pkg"]`。
- contents: Array\<ImportContent> - 导入内容列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `contents` 为空时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 prefixes
    let prefixes = ["pkg"]

    // 创建 contents
    let contents: Array<ImportContent> = [ImportSingle([], "a"), ImportSingle([], "b")]

    // 创建 ImportMulti 实例
    let importMulti = ImportMulti(
        prefixes, 
        contents
    )

    println("importMulti: ${importMulti}")
}
```

运行结果：

```text
importMulti: pkg.{a, b}
```

### func getCommasPos()

```cangjie
public func getCommasPos(): Array<CodePositionRange>
```

功能：获取当前 [ImportMulti](#class-importmulti) 中所有 `,` 分隔符的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回所有 `,` 分隔符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 ImportMulti 实例
    let contents: Array<ImportContent> = [ImportSingle([], "a"), ImportSingle([], "b")]
    let importMulti = ImportMulti(["pkg"], contents)
    let posArr = importMulti.getCommasPos()

    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("importMulti.getCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
importMulti.getCommasPos()[0]: 1:7-1:8
```

### func getLCurlPos()

```cangjie
public func getLCurlPos(): CodePositionRange
```

功能：获取当前 [ImportMulti](#class-importmulti) 中 `{` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `{` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 ImportMulti 实例
    let contents: Array<ImportContent> = [ImportSingle([], "a")]
    let importMulti = ImportMulti(["pkg"], contents)
    let pos = importMulti.getLCurlPos()

    // 输出左花括号位置
    println("importMulti.getLCurlPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
importMulti.getLCurlPos(): 1:5-1:6
```

### func getRCurlPos()

```cangjie
public func getRCurlPos(): CodePositionRange
```

功能：获取当前 [ImportMulti](#class-importmulti) 中 `}` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `}` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 ImportMulti 实例
    let contents: Array<ImportContent> = [ImportSingle([], "a")]
    let importMulti = ImportMulti(["pkg"], contents)
    let pos = importMulti.getRCurlPos()

    // 输出右花括号位置
    println("importMulti.getRCurlPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
importMulti.getRCurlPos(): 1:7-1:8
```

## class ImportSingle

```cangjie
public class ImportSingle <: ImportContent {
    public init(prefixes: Array<String>, identifier: String, comments!: Array<Comment> = [])
}
```

功能：表示一个单导入的包导入声明节点的具体项目，如 `import pkg.a` 中的 `pkg.a`。

父类型：

- [ImportContent](#class-importcontent)

### prop identifier

```cangjie
public prop identifier: String
```

功能：表示该包导入节点中的被导入的项，它可能是包中的顶层声明或声明，也可能是子包的名字，如 `pkg.a` 中的 `a`。

类型：String

### init(Array\<String>, String, Array\<Comment>)

```cangjie
public init(prefixes: Array<String>, identifier: String, comments!: Array<Comment> = [])
```

功能：构造一个 [ImportSingle](#class-importsingle) 对象，表示单导入项。

参数：

- prefixes: Array\<String> - 导入路径的前缀列表，如 `["pkg"]`。
- identifier: String - 被导入的标识符名称，如 `A`。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `identifier` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 prefixes
    let prefixes = ["pkg"]

    // 创建 identifier
    let identifier = "a"

    // 创建 ImportSingle 实例
    let importSingle = ImportSingle(
        prefixes, 
        identifier
    )

    println("importSingle: ${importSingle}")
}
```

运行结果：

```text
importSingle: pkg.a
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取当前 [ImportSingle](#class-importsingle) 中具体包名的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回具体包名的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 ImportSingle 实例
    let importSingle = ImportSingle(["pkg"], "a")
    let pos = importSingle.getIdentifierPos()

    // 输出标识符位置
    println("importSingle.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
importSingle.getIdentifierPos(): 1:5-1:6
```

## class IncOrDecExpr

```cangjie
public class IncOrDecExpr <: Expr {
    public init(kind: IncOrDecOpKind, operand: Expr, comments!: Array<Comment> = [])
}
```

功能：表示包含自增操作符（`++`）或自减操作符（`--`）的表达式。

父类型：

- [Expr](#class-expr)

### prop kind

```cangjie
public prop kind: IncOrDecOpKind
```

功能：获取当前自增自减表达式的操作符类型。

类型：[IncOrDecOpKind](syntax_package_enums.md#enum-incordecopkind)

### prop operand

```cangjie
public prop operand: Expr
```

功能：获取 [IncOrDecExpr](#class-incordecexpr) 中的表达式。

类型：[Expr](#class-expr)

### init(IncOrDecOpKind, Expr, Array\<Comment>)

```cangjie
public init(kind: IncOrDecOpKind, operand: Expr, comments!: Array<Comment> = [])
```

功能：构造一个 [IncOrDecExpr](#class-incordecexpr) 对象，表示自增或自减表达式。

参数：

- kind: [IncOrDecOpKind](syntax_package_enums.md#enum-incordecopkind) - 自增或自减操作类型。
- operand: [Expr](#class-expr) - 被操作的表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 kind
    let kind = IncOrDecOpKind.Incr

    // 创建 operand
    let operand = SymbolRef("x", [])

    // 创建 IncOrDecExpr 实例
    let incOrDecExpr = IncOrDecExpr(
        kind, 
        operand
    )

    println("incOrDecExpr: ${incOrDecExpr}")
}
```

运行结果：

```text
incOrDecExpr: x++
```

### func getOperatorPos()

```cangjie
public func getOperatorPos(): CodePositionRange
```

功能：获取操作符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回操作符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 kind
    let kind = IncOrDecOpKind.Incr

    // 创建 operand
    let operand = SymbolRef("x", [])

    // 创建 IncOrDecExpr 实例
    let incOrDecExpr = IncOrDecExpr(kind, operand)
    let pos = incOrDecExpr.getOperatorPos()

    // 输出操作符位置
    println("incOrDecExpr.getOperatorPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
incOrDecExpr.getOperatorPos(): 1:2-1:4
```

## class InterfaceDecl

```cangjie
public class InterfaceDecl <: Decl {
    public init(body: Body, genericConstraints: Option<GenericConstraints>, genericParams: Array<GenericParam>,
        name: String, superTyAnnotations: Array<TypeAnnotation>, annotations!: Array<Annotation> = [],
        modifiers!: Array<Modifier> = [], comments!: Array<Comment> = [])
}
```

功能：表示接口声明节点。

接口的声明使用 `interface` 关键字，接口声明依次为：可缺省的修饰符、`interface` 关键字、接口名、可选的类型参数、是否指定父接口、可选的泛型约束、接口体的声明。

父类型：

- [Decl](#class-decl)

### prop body

```cangjie
public prop body: Body
```

功能：获取当前接口声明的主体部分。

类型：[Body](#class-body)

### prop genericConstraints

```cangjie
public prop genericConstraints: Option<GenericConstraints>
```

功能：获取当前接口声明的泛型约束（若不存在返回 `None`）。

类型：Option\<[GenericConstraints](#class-genericconstraints)>

### prop genericParams

```cangjie
public prop genericParams: Array<GenericParam>
```

功能：获取当前接口声明的泛型参数列表。

类型：Array\<[GenericParam](#class-genericparam)>

### prop name

```cangjie
public prop name: String
```

功能：获取当前接口声明的名称。

类型：String

### prop superTyAnnotations

```cangjie
public prop superTyAnnotations: Array<TypeAnnotation>
```

功能：获取当前接口声明的父类类型标注列表。

类型：Array\<[TypeAnnotation](#class-typeannotation)>

### init(Body, Option\<GenericConstraints>, Array\<GenericParam>, String, Array\<TypeAnnotation>, Array\<Annotation>, Array\<Modifier>, Array\<Comment>)

```cangjie
public init(body: Body, genericConstraints: Option<GenericConstraints>, genericParams: Array<GenericParam>,
    name: String, superTyAnnotations: Array<TypeAnnotation>, annotations!: Array<Annotation> = [],
    modifiers!: Array<Modifier> = [], comments!: Array<Comment> = [])
```

功能：构造一个 [InterfaceDecl](#class-interfacedecl) 对象，表示接口声明节点。

参数：

- body: [Body](#class-body) - 接口体，包含成员声明。
- genericConstraints: Option\<[GenericConstraints](#class-genericconstraints)> - 可选的泛型约束。
- genericParams: Array\<[GenericParam](#class-genericparam)> - 泛型参数列表。
- name: String - 接口名。
- superTyAnnotations: Array\<[TypeAnnotation](#class-typeannotation)> - 父类类型标注列表。
- annotations!: Array\<[Annotation](#class-annotation)> - 附加的注解列表，默认为空数组。
- modifiers!: Array\<[Modifier](#class-modifier)> - 修饰符列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `body` 中有除函数声明和宏展开声明外的声明，或泛型约束与泛型参数不对应，或输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Body([])

    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])

    // 创建 genericParams
    let genericParams = [GenericParam("T")]

    // 创建 name
    let name = "foo"

    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]

    // 创建 InterfaceDecl 实例
    let interfaceDecl = InterfaceDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations
    )

    println("interfaceDecl: ${interfaceDecl}")
}
```

运行结果：

```text
interfaceDecl: interface foo<T> <: I1 where T<:I1 {
}
```

### func getGenericParamsCommasPos()

```cangjie
public func getGenericParamsCommasPos(): Array<CodePositionRange>
```

功能：获取 [InterfaceDecl](#class-interfacedecl) 节点中泛型参数中 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数中 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 InterfaceDecl 实例
    let body = Body([])
    let genericParams = [GenericParam("T"), GenericParam("U"), GenericParam("V")]
    let interfaceDecl = InterfaceDecl(body, None, genericParams, "MyInterface", [])

    // 获取泛型参数中逗号的位置
    let commaPoses = interfaceDecl.getGenericParamsCommasPos()

    // 输出逗号位置
    for (i in 0..commaPoses.size) {
        println("interfaceDecl.getGenericParamsCommasPos()[${i}]: ${commaPoses[i].beginLine}:${commaPoses[i].beginColumn}-${commaPoses[i].endLine}:${commaPoses[i].endColumn}")
    }
}
```

运行结果：

```text
interfaceDecl.getGenericParamsCommasPos()[0]: 1:24-1:25
interfaceDecl.getGenericParamsCommasPos()[1]: 1:27-1:28
```

### func getGenericParamsLAnglePos()

```cangjie
public func getGenericParamsLAnglePos(): Option<CodePositionRange>
```

功能：获取 [InterfaceDecl](#class-interfacedecl) 节点中泛型参数的 `<` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数的 `<` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 InterfaceDecl 实例
    let body = Body([])
    let genericParams = [GenericParam("T")]
    let interfaceDecl = InterfaceDecl(body, None, genericParams, "MyInterface", [])

    if (let Some(pos) <- interfaceDecl.getGenericParamsLAnglePos()) {
        // 输出左尖括号位置
        println("interfaceDecl.getGenericParamsLAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
interfaceDecl.getGenericParamsLAnglePos(): 1:22-1:23
```

### func getGenericParamsRAnglePos()

```cangjie
public func getGenericParamsRAnglePos(): Option<CodePositionRange>
```

功能：获取 [InterfaceDecl](#class-interfacedecl) 节点中泛型参数的 `>` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数的 `>` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 InterfaceDecl 实例
    let body = Body([])
    let genericParams = [GenericParam("T")]
    let interfaceDecl = InterfaceDecl(body, None, genericParams, "MyInterface", [])

    if (let Some(pos) <- interfaceDecl.getGenericParamsRAnglePos()) {
        // 输出右尖括号位置
        println("interfaceDecl.getGenericParamsRAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
interfaceDecl.getGenericParamsRAnglePos(): 1:24-1:25
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取 [InterfaceDecl](#class-interfacedecl) 节点中标识符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回标识符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 InterfaceDecl 实例
    let body = Body([])
    let interfaceDecl = InterfaceDecl(body, None, [], "MyInterface", [])

    // 获取标识符位置
    let pos = interfaceDecl.getIdentifierPos()

    // 输出标识符位置
    println("interfaceDecl.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
interfaceDecl.getIdentifierPos(): 1:11-1:22
```

### func getInterfaceKeyWordPos()

```cangjie
public func getInterfaceKeyWordPos(): CodePositionRange
```

功能：获取 [InterfaceDecl](#class-interfacedecl) 节点中 `interface` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `interface` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 InterfaceDecl 实例
    let body = Body([])
    let interfaceDecl = InterfaceDecl(body, None, [], "MyInterface", [])

    // 获取 interface 关键字位置
    let pos = interfaceDecl.getInterfaceKeyWordPos()

    // 输出 interface 关键字位置
    println("interfaceDecl.getInterfaceKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
interfaceDecl.getInterfaceKeyWordPos(): 1:1-1:10
```

### func getSuperTyAnnotationsBitAndsPos()

```cangjie
public func getSuperTyAnnotationsBitAndsPos(): Array<CodePositionRange>
```

功能：获取 [InterfaceDecl](#class-interfacedecl) 节点中父类型中 `&` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回父类型中 `&` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 InterfaceDecl 实例
    let body = Body([])
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], []), CompositeType("I2", [], [])]
    let interfaceDecl = InterfaceDecl(body, None, [], "MyInterface", superTyAnnotations)

    // 获取父类型中 & 的位置
    let bitAndsPoses = interfaceDecl.getSuperTyAnnotationsBitAndsPos()

    // 输出 & 位置
    for (i in 0..bitAndsPoses.size) {
        println("interfaceDecl.getSuperTyAnnotationsBitAndsPos()[${i}]: ${bitAndsPoses[i].beginLine}:${bitAndsPoses[i].beginColumn}-${bitAndsPoses[i].endLine}:${bitAndsPoses[i].endColumn}")
    }
}
```

运行结果：

```text
interfaceDecl.getSuperTyAnnotationsBitAndsPos()[0]: 1:29-1:30
```

### func getUpperBoundPos()

```cangjie
public func getUpperBoundPos(): Option<CodePositionRange>
```

功能：获取 [InterfaceDecl](#class-interfacedecl) 节点中 `<:` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `<:` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 InterfaceDecl 实例
    let body = Body([])
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    let interfaceDecl = InterfaceDecl(body, None, [], "MyInterface", superTyAnnotations)

    if (let Some(pos) <- interfaceDecl.getUpperBoundPos()) {
        // 输出 <: 位置
        println("interfaceDecl.getUpperBoundPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
interfaceDecl.getUpperBoundPos(): 1:23-1:25
```

## class IsExpr

```cangjie
public class IsExpr <: Expr {
    public init(srcVal: Expr, targetTypeAnnotation: TypeAnnotation, comments!: Array<Comment> = [])
}
```

功能：表示一个类型检查表达式。

一个 [IsExpr](#class-isexpr) 表达式：`e is T`，类型为 `Bool` 。其中 `e` 可以是任何类型的表达式，`T` 可以是任何类型。

父类型：

- [Expr](#class-expr)

### prop srcVal

```cangjie
public prop srcVal: Expr
```

功能：获取 [IsExpr](#class-isexpr) 节点中的源表达式节点。

类型：[Expr](#class-expr)

### prop targetTypeAnnotation

```cangjie
public prop targetTypeAnnotation: TypeAnnotation
```

功能：获取 [IsExpr](#class-isexpr) 节点中的目标类型。

类型：[TypeAnnotation](#class-typeannotation)

### init(Expr, TypeAnnotation, Array\<Comment>)

```cangjie
public init(srcVal: Expr, targetTypeAnnotation: TypeAnnotation, comments!: Array<Comment> = [])
```

功能：构造一个 [IsExpr](#class-isexpr) 对象，表示类型判断表达式，如 `x is Int64`。

参数：

- srcVal: [Expr](#class-expr) - 被判断的源表达式。
- targetTypeAnnotation: [TypeAnnotation](#class-typeannotation) - 目标类型。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 srcVal
    let srcVal = SymbolRef("x", [])

    // 创建 targetTypeAnnotation
    let targetTypeAnnotation = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 IsExpr 实例
    let isExpr = IsExpr(
        srcVal, 
        targetTypeAnnotation
    )

    println("isExpr: ${isExpr}")
}
```

运行结果：

```text
isExpr: x is Int64
```

### func getIsKeyWordPos()

```cangjie
public func getIsKeyWordPos(): CodePositionRange
```

功能：获取 `is` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `is` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 srcVal
    let srcVal = SymbolRef("x", [])

    // 创建 targetTypeAnnotation
    let targetTypeAnnotation = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 IsExpr 实例
    let isExpr = IsExpr(srcVal, targetTypeAnnotation)
    let pos = isExpr.getIsKeyWordPos()

    // 输出 is 关键字位置
    println("isExpr.getIsKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
isExpr.getIsKeyWordPos(): 1:3-1:5
```

## class Lambda

```cangjie
public class Lambda <: Expr {
    public init(body: Array<SyntaxTreeNode>, params: ParameterList, comments!: Array<Comment> = [])
}
```

功能：表示 `Lambda` 表达式，是一个匿名的函数。

一个 [Lambda](#class-lambda) 节点有两种形式，一种是有形参的，例如 `{a: Int64 => e1; e2 }`，另一种是无形参的，例如 `{ => e1; e2 }`。

父类型：

- [Expr](#class-expr)

### prop body

```cangjie
public prop body: Array<SyntaxTreeNode>
```

功能：获取当前 `Lambda` 表达式的主体代码块。

类型：Array\<[SyntaxTreeNode](#class-syntaxtreenode)>

### prop params

```cangjie
public prop params: ParameterList
```

功能：获取当前 `Lambda` 表达式的参数列表。

类型：[ParameterList](#class-parameterlist)

### init(Array\<SyntaxTreeNode>, ParameterList, Array\<Comment>)

```cangjie
public init(body: Array<SyntaxTreeNode>, params: ParameterList, comments!: Array<Comment> = [])
```

功能：构造一个 [Lambda](#class-lambda) 对象，表示匿名函数（lambda）表达式，如 `{ x => x + 1 }`。

参数：

- body: Array\<[SyntaxTreeNode](#class-syntaxtreenode)> - lambda 体中的语法节点列表。
- params: [ParameterList](#class-parameterlist) - 参数列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body: Array<SyntaxTreeNode> = [BinaryExpr(SymbolRef("x", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))]

    // 创建 params
    let params = ParameterList(LambdaParam("x", None), hasParen:false)

    // 创建 Lambda 实例
    let lambda = Lambda(
        body, 
        params
    )

    println("lambda: ${lambda}")
}
```

运行结果：

```text
lambda: { x => x + 1 }
```

### func getDoubleArrowPos()

```cangjie
public func getDoubleArrowPos(): Option<CodePositionRange>
```

功能：获取当前 [Lambda](#class-lambda) 中 `=>` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `=>` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 Lambda 实例
    let body: Array<SyntaxTreeNode> = [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))]
    let params = ParameterList(LambdaParam("x", None), hasParen: false)
    let lambda = Lambda(body, params)

    if (let Some(pos) <- lambda.getDoubleArrowPos()) {
        // 输出双箭头位置
        println("lambda.getDoubleArrowPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
lambda.getDoubleArrowPos(): 1:5-1:7
```

### func getLCurlPos()

```cangjie
public func getLCurlPos(): CodePositionRange
```

功能：获取当前 [Lambda](#class-lambda) 中 `{` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `{` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 Lambda 实例
    let body: Array<SyntaxTreeNode> = [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))]
    let params = ParameterList(LambdaParam("x", None), hasParen: false)
    let lambda = Lambda(body, params)
    let pos = lambda.getLCurlPos()

    // 输出左花括号位置
    println("lambda.getLCurlPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
lambda.getLCurlPos(): 1:1-1:2
```

### func getRCurlPos()

```cangjie
public func getRCurlPos(): CodePositionRange
```

功能：获取当前 [Lambda](#class-lambda) 中 `}` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `}` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 Lambda 实例
    let body: Array<SyntaxTreeNode> = [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))]
    let params = ParameterList(LambdaParam("x", None), hasParen: false)
    let lambda = Lambda(body, params)
    let pos = lambda.getRCurlPos()

    // 输出右花括号位置
    println("lambda.getRCurlPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
lambda.getRCurlPos(): 1:14-1:15
```

## class LambdaParam

```cangjie
public open class LambdaParam <: Parameter {
    public init(name: String, typeAnnotation: Option<TypeAnnotation>, comments!: Array<Comment> = [])
}
```

功能：表示一个 `lambda` 参数。

[LambdaParam](#class-lambdaparam) 类用于在程序中声明一个新的 `lambda` 参数，`name` 表示参数的名称，`typeAnnotation` 表示参数的类型标注。

父类型：

- [Parameter](#class-parameter)

### prop name

```cangjie
public prop name: String
```

功能：获取当前 `lambda` 参数的名称。

类型：String

### prop typeAnnotation

```cangjie
public prop typeAnnotation: Option<TypeAnnotation>
```

功能：获取 [LambdaParam](#class-lambdaparam) 节点中的类型标注（若不存在返回 `None`）。

类型：Option\<[TypeAnnotation](#class-typeannotation)>

### init(String, Option\<TypeAnnotation>, Array\<Comment>)

```cangjie
public init(name: String, typeAnnotation: Option<TypeAnnotation>, comments!: Array<Comment> = [])
```

功能：构造一个 [LambdaParam](#class-lambdaparam) 对象，表示 lambda 参数节点。

参数：

- name: String - 参数名。
- typeAnnotation: Option\<[TypeAnnotation](#class-typeannotation)> - 可选的类型注解。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 name
    let name = "x"

    // 创建 typeAnnotation
    let typeAnnotation = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 LambdaParam 实例
    let lambdaParam = LambdaParam(
        name, 
        typeAnnotation
    )

    println("lambdaParam: ${lambdaParam}")
}
```

运行结果：

```text
lambdaParam: x: Int64
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取 [LambdaParam](#class-lambdaparam) 节点中标识符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回标识符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 LambdaParam 实例
    let lambdaParam = LambdaParam("x", AtomicType(AtomicTypeKind.Int64Type))
    let pos = lambdaParam.getIdentifierPos()

    // 输出标识符位置
    println("lambdaParam.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
lambdaParam.getIdentifierPos(): 1:1-1:2
```

### func getTypeAnnotationColonPos()

```cangjie
public func getTypeAnnotationColonPos(): Option<CodePositionRange>
```

功能：获取 [LambdaParam](#class-lambdaparam) 节点中 `:` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `:` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 LambdaParam 实例
    let lambdaParam = LambdaParam("x", AtomicType(AtomicTypeKind.Int64Type))

    if (let Some(pos) <- lambdaParam.getTypeAnnotationColonPos()) {
        // 输出冒号位置
        println("lambdaParam.getTypeAnnotationColonPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
lambdaParam.getTypeAnnotationColonPos(): 1:2-1:3
```

## class LetPattern

```cangjie
public class LetPattern <: SyntaxTreeNode {
    public init(expr: Expr, patterns: Array<Pattern>, comments!: Array<Comment> = [])
}
```

功能：表示一个 `let` 模式绑定表达式。

它将一个表达式绑定到一个或多个模式以进行解构。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop expr

```cangjie
public prop expr: Expr
```

功能：需要解构的表达式。

类型：[Expr](#class-expr)

### prop patterns

```cangjie
public prop patterns: Array<Pattern>
```

功能：绑定表达式的模式列表。

类型：Array\<[Pattern](#class-pattern)>

### init(Expr, Array\<Pattern>, Array\<Comment>)

```cangjie
public init(expr: Expr, patterns: Array<Pattern>, comments!: Array<Comment> = [])
```

功能：构造一个 [LetPattern](#class-letpattern) 对象，表示 `let` 模式绑定表达式。

参数：

- expr: [Expr](#class-expr) - 被绑定的表达式。
- patterns: Array\<[Pattern](#class-pattern)> - 用于解构的模式列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `patterns` 为空时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 expr
    let expr = SymbolRef("y", [])

    // 创建 patterns
    let patterns: Array<Pattern> = [VarPattern("x")]

    // 创建 LetPattern 实例
    let letPattern = LetPattern(
        expr, 
        patterns
    )

    println("letPattern: ${letPattern}")
}
```

运行结果：

```text
letPattern: let x <- y
```

### func getBackArrowPos()

```cangjie
public func getBackArrowPos(): CodePositionRange
```

功能：获取 [LetPattern](#class-letpattern) 节点中 `<-` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `<-` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 expr
    let expr = SymbolRef("y", [])

    // 创建 patterns
    let patterns: Array<Pattern> = [VarPattern("x")]

    // 创建 LetPattern 实例
    let letPattern = LetPattern(expr, patterns)
    let pos = letPattern.getBackArrowPos()

    // 输出后箭头位置
    println("letPattern.getBackArrowPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
letPattern.getBackArrowPos(): 1:7-1:9
```

### func getBitOrsPos()

```cangjie
public func getBitOrsPos(): Array<CodePositionRange>
```

功能：获取 [LetPattern](#class-letpattern) 节点中 `|` 的位置序列。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `|` 的位置序列。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 expr
    let expr = SymbolRef("y", [])

    // 创建 patterns
    let patterns: Array<Pattern> = [
        VarPattern("x1"),
        VarPattern("x2"),
        VarPattern("x3")
    ]

    // 创建 LetPattern 实例
    let letPattern = LetPattern(expr, patterns)
    let posArr = letPattern.getBitOrsPos()

    // 遍历输出竖线位置
    for (i in 0..posArr.size) {
        println("letPattern.getBitOrsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
letPattern.getBitOrsPos()[0]: 1:8-1:9
letPattern.getBitOrsPos()[1]: 1:13-1:14
```

### func getLetKeyWordPos()

```cangjie
public func getLetKeyWordPos(): CodePositionRange
```

功能：获取 [LetPattern](#class-letpattern) 节点中 `let` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `let` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 expr
    let expr = SymbolRef("y", [])

    // 创建 patterns
    let patterns: Array<Pattern> = [VarPattern("x")]

    // 创建 LetPattern 实例
    let letPattern = LetPattern(expr, patterns)
    let pos = letPattern.getLetKeyWordPos()

    // 输出 let 关键字位置
    println("letPattern.getLetKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
letPattern.getLetKeyWordPos(): 1:1-1:4
```

## class LitConstExpr

```cangjie
public open class LitConstExpr <: Expr {
    public init(kind: LitConstKind, rawValue: String, comments!: Array<Comment> = [])
}
```

功能：表示一个字面量表达式节点。

一个 [LitConstExpr](#class-litconstexpr) 表达式：`1.0`，`123` 等。

父类型：

- [Expr](#class-expr)

### prop kind

```cangjie
public prop kind: LitConstKind
```

功能：获取当前字面量表达式的类型。

类型：[LitConstKind](syntax_package_enums.md#enum-litconstkind)

### prop rawValue

```cangjie
public prop rawValue: String
```

功能：获取当前字面量表达式的原始值。

类型：String

### init(LitConstKind, String, Array\<Comment>)

```cangjie
public init(kind: LitConstKind, rawValue: String, comments!: Array<Comment> = [])
```

功能：构造一个 [LitConstExpr](#class-litconstexpr) 对象，表示字面量常量表达式。

参数：

- kind: [LitConstKind](syntax_package_enums.md#enum-litconstkind) - 字面量类型。
- rawValue: String - 字面量的原始字符串值。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `kind` 为 [RuneLiteral](syntax_package_enums.md#runeliteral) 或 [StringLiteral](syntax_package_enums.md#stringliteral) 时，或 `rawValue` 无法用于构建对应类型字面量时，抛出异常，异常中包含报错提示信息。

> **注意：**
>
> 不支持构造字符类型和字符串类型的字面量表达式节点，字符类型的字面量表达式节点通过 [LitConstRuneExpr](#class-litconstruneexpr) 构造，字符串类型的字面量表达式节点通过 [LitConstStrExpr](#class-litconststrexpr) 构造。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 设置字面量类型
    let kind = LitConstKind.BoolLiteral

    // 设置原始值
    let rawValue = "true"

    // 创建 LitConstExpr 实例
    let litConstExpr = LitConstExpr(
        kind, 
        rawValue
    )

    println("litConstExpr: ${litConstExpr}")
}
```

运行结果：

```text
litConstExpr: true
```

## class LitConstRuneExpr

```cangjie
public class LitConstRuneExpr <: LitConstExpr {
    public init(kind: LitConstKind, rawValue: String, isSingleQuote: Bool, comments!: Array<Comment> = [])
}
```

功能：表示一个字符类型的字面量表达式节点。

一个 [LitConstRuneExpr](#class-litconstruneexpr) 表达式：`r'a'`。

父类型：

- [LitConstExpr](#class-litconstexpr)

> **注意：**
>
> `syntax` 库不支持字符字节字面量，即形如 `b'x'` 的字面量。

### prop isSingleQuote

```cangjie
public prop isSingleQuote: Bool
```

功能：表示当前字符字面量表达式是否为单引号引用。

类型：Bool

### init(LitConstKind, String, Bool, Array\<Comment>)

```cangjie
public init(kind: LitConstKind, rawValue: String, isSingleQuote: Bool, comments!: Array<Comment> = [])
```

功能：构造一个 [LitConstRuneExpr](#class-litconstruneexpr) 对象，表示字符字面量表达式。

参数：

- kind: [LitConstKind](syntax_package_enums.md#enum-litconstkind) - 字面量类型，固定为 `RuneLiteral`。
- rawValue: String - 字面量的原始字符串值。
- isSingleQuote: Bool - 是否使用单引号包裹。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `kind` 不是字符字面量类型时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 设置字面量类型
    let kind = LitConstKind.RuneLiteral

    // 设置原始值
    let rawValue = "a"

    // 设置是否为单引号
    let isSingleQuote = true

    // 创建 LitConstRuneExpr 实例
    let litConstRuneExpr = LitConstRuneExpr(
        kind, 
        rawValue, 
        isSingleQuote
    )

    println("litConstRuneExpr: ${litConstRuneExpr}")
}
```

运行结果：

```text
litConstRuneExpr: r'a'
```

## class LitConstStrExpr

```cangjie
public class LitConstStrExpr <: LitConstExpr {
    public init(kind: LitConstKind, rawValue: String, delimiterNum: Int64, isSingleQuote: Bool, strKind: LitConstStrKind, strPartExprs: Array<StrLiteralPart>,
        comments!: Array<Comment> = [])
}
```

功能：表示一个字符串类型的字面量表达式节点。

一个 [LitConstStrExpr](#class-litconststrexpr) 表达式：`"me"`，`#"hi"#` 等。

父类型：

- [LitConstExpr](#class-litconstexpr)

### prop delimiterNum

```cangjie
public prop delimiterNum: Int64
```

功能：表示当前 [LitConstStrExpr](#class-litconststrexpr) 前后成对出现的 `#` 分隔符数。例如 `##'\n'##` 中 `delimiterNum = 2` 。

类型：Int64

### prop isSingleQuote

```cangjie
public prop isSingleQuote: Bool
```

功能：表示当前 [LitConstStrExpr](#class-litconststrexpr) 是否为单引号引用。

类型：Bool

### prop strKind

```cangjie
public prop strKind: LitConstStrKind
```

功能：获取当前 [LitConstStrExpr](#class-litconststrexpr) 的类型

类型：[LitConstStrKind](syntax_package_enums.md#enum-litconststrkind)

### prop strPartExprs

```cangjie
public prop strPartExprs: Array<StrLiteralPart>
```

功能：获取当前 [LitConstStrExpr](#class-litconststrexpr) 中的各个字符串部分，分为字面量表达式和插值字符串表达式两种。

类型：Array\<[StrLiteralPart](syntax_package_enums.md#enum-strliteralpart)>

### init(LitConstKind, String, Int64, Bool, LitConstStrKind, Array\<StrLiteralPart>, Array\<Comment>)

```cangjie
public init(kind: LitConstKind, rawValue: String, delimiterNum: Int64, isSingleQuote: Bool, strKind: LitConstStrKind, strPartExprs: Array<StrLiteralPart>, comments!: Array<Comment> = [])
```

功能：构造一个 [LitConstStrExpr](#class-litconststrexpr) 对象，表示字符串字面量表达式，支持插值。

参数：

- kind: [LitConstKind](syntax_package_enums.md#enum-litconstkind) - 字面量类型。
- rawValue: String - 字面量的原始字符串值。
- delimiterNum: Int64 - 分隔符数量。
- isSingleQuote: Bool - 是否使用单引号包裹。
- strKind: [LitConstStrKind](syntax_package_enums.md#enum-litconststrkind) - 字符串字面量种类。
- strPartExprs: Array\<[StrLiteralPart](syntax_package_enums.md#enum-strliteralpart)> - 字符串片段列表，可包含插值。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `strKind` 为 [MultiLineRawString](syntax_package_enums.md#multilinerawstring) 且 `delimiterNum` 为 `0` 时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 kind
    let kind = LitConstKind.StringLiteral

    // 创建 rawValue
    let rawValue = "abc"

    // 创建 delimiterNum
    let delimiterNum = 0

    // 创建 isSingleQuote
    let isSingleQuote = true

    // 创建 strKind
    let strKind = LitConstStrKind.StringLiteral

    // 创建 strPartExprs
    let strPartExprs: Array<StrLiteralPart> = []

    // 创建 LitConstStrExpr 实例
    let litConstStrExpr = LitConstStrExpr(
        kind, 
        rawValue, 
        delimiterNum, 
        isSingleQuote, 
        strKind, 
        strPartExprs
    )

    println("litConstStrExpr: ${litConstStrExpr}")
}
```

运行结果：

```text
litConstStrExpr: 'abc'
```

### func hasInterpolation()

```cangjie
public func hasInterpolation(): Bool
```

功能：表示当前 [LitConstStrExpr](#class-litconststrexpr) 是否存在插值。

返回值：

- Bool - 返回是否存在插值。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 LitConstStrExpr 实例
    let litConstStrExpr = LitConstStrExpr(LitConstKind.StringLiteral, "abc", 0, true, LitConstStrKind.StringLiteral, [])
    let hasInterp = litConstStrExpr.hasInterpolation()

    // 输出是否存在插值
    println("litConstStrExpr.hasInterpolation(): ${hasInterp}")
}
```

运行结果：

```text
litConstStrExpr.hasInterpolation(): false
```

## class MacroDecl

```cangjie
public class MacroDecl <: Decl {
    public init(body: Block, name: String, params: ParameterList, retTyAnnotation: Option<TypeAnnotation>,
        annotations!: Array<Annotation> = [], modifiers!: Array<Modifier> = [], comments!: Array<Comment> = [])
}
```

功能：表示一个宏定义节点。

一个 [MacroDecl](#class-macrodecl) 节点：`public macro M(input: Tokens): Tokens {...}`。

父类型：

- [Decl](#class-decl)

### prop body

```cangjie
public prop body: Block
```

功能：获取 [MacroDecl](#class-macrodecl) 节点的函数体。

类型：[Block](#class-block)

### prop name

```cangjie
public prop name: String
```

功能：获取 [MacroDecl](#class-macrodecl) 节点的名称。

类型：String

### prop params

```cangjie
public prop params: ParameterList
```

功能：获取 [MacroDecl](#class-macrodecl) 节点的的参数列表。

类型：[ParameterList](#class-parameterlist)

### prop retTyAnnotation

```cangjie
public prop retTyAnnotation: Option<TypeAnnotation>
```

功能：获取 [MacroDecl](#class-macrodecl) 节点的函数返回类型。

类型：Option\<[TypeAnnotation](#class-typeannotation)>

### init(Block, String, ParameterList, Option\<TypeAnnotation>, Array\<Annotation>, Array\<Modifier>, Array\<Comment>)

```cangjie
public init(body: Block, name: String, params: ParameterList, retTyAnnotation: Option<TypeAnnotation>,
    annotations!: Array<Annotation> = [], modifiers!: Array<Modifier> = [], comments!: Array<Comment> = [])
```

功能：构造一个 [MacroDecl](#class-macrodecl) 对象，表示宏声明节点，如 `macro myMacro(input: Tokens): Tokens {...}`。

参数：

- body: [Block](#class-block) - 宏体。
- name: String - 宏名。
- params: [ParameterList](#class-parameterlist) - 参数列表。
- retTyAnnotation: Option\<[TypeAnnotation](#class-typeannotation)> - 可选的返回类型注解。
- annotations!: Array\<[Annotation](#class-annotation)> - 附加的注解列表，默认为空数组。
- modifiers!: Array\<[Modifier](#class-modifier)> - 修饰符列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Block([])

    // 创建 name
    let name = "foo"

    // 创建 params
    let params = ParameterList([])

    // 创建 retTyAnnotation
    let retTyAnnotation = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 MacroDecl 实例
    let macroDecl = MacroDecl(
        body, 
        name, 
        params, 
        retTyAnnotation
    )

    println("macroDecl: ${macroDecl}")
}
```

运行结果：

```text
macroDecl: macro foo(): Int64 {
}
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取 [MacroDecl](#class-macrodecl) 节点中标识符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回标识符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 MacroDecl 实例
    let body = Block([])
    let params = ParameterList([])
    let macroDecl = MacroDecl(body, "foo", params, None)
    let pos = macroDecl.getIdentifierPos()

    // 输出标识符位置
    println("macroDecl.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
macroDecl.getIdentifierPos(): 1:7-1:10
```

### func getMacroKeyWordPos()

```cangjie
public func getMacroKeyWordPos(): CodePositionRange
```

功能：获取 [MacroDecl](#class-macrodecl) 节点中 `macro` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `macro` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 MacroDecl 实例
    let body = Block([])
    let params = ParameterList([])
    let macroDecl = MacroDecl(body, "foo", params, None)
    let pos = macroDecl.getMacroKeyWordPos()

    // 输出 macro 关键字位置
    println("macroDecl.getMacroKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
macroDecl.getMacroKeyWordPos(): 1:1-1:6
```

### func getRetTyAnnotationColonPos()

```cangjie
public func getRetTyAnnotationColonPos(): Option<CodePositionRange>
```

功能：获取 [MacroDecl](#class-macrodecl) 节点中返回类型的冒号的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回返回类型的冒号的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 MacroDecl 实例
    let body = Block([])
    let params = ParameterList([])
    let retTyAnnotation = AtomicType(AtomicTypeKind.Int64Type)
    let macroDecl = MacroDecl(body, "foo", params, retTyAnnotation)

    if (let Some(pos) <- macroDecl.getRetTyAnnotationColonPos()) {
        // 输出冒号位置
        println("macroDecl.getRetTyAnnotationColonPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
macroDecl.getRetTyAnnotationColonPos(): 1:12-1:13
```

## class MacroExpandDecl

```cangjie
public class MacroExpandDecl <: Decl {
    public init(calleeMacro: Expr, macroAttrs: Tokens, macroInputs: MacroExpandInput,
        annotations!: Array<Annotation> = [], comments!: Array<Comment> = [])
}
```

功能：表示宏展开声明。

用于在编译时执行宏并将其展开为具体代码，实现元编程能力。

父类型：

- [Decl](#class-decl)

### prop calleeMacro

```cangjie
public prop calleeMacro: Expr
```

功能：获取被调用的宏表达式。

类型：[Expr](#class-expr)

### prop macroAttrs

```cangjie
public prop macroAttrs: Tokens
```

功能：获取宏的属性标记集合，用于传递编译时元数据。

类型：Tokens

### prop macroInputs

```cangjie
public prop macroInputs: MacroExpandInput
```

功能：获取宏展开的输入声明，定义宏执行所需的上下文。

类型：[MacroExpandInput](syntax_package_enums.md#enum-macroexpandinput)

### init(Expr, Tokens, MacroExpandInput, Array\<Annotation>, Array\<Comment>)

```cangjie
public init(calleeMacro: Expr, macroAttrs: Tokens, macroInputs: MacroExpandInput,
    annotations!: Array<Annotation> = [], comments!: Array<Comment> = [])
```

功能：构造一个 [MacroExpandDecl](#class-macroexpanddecl) 对象，表示宏展开声明节点。

参数：

- calleeMacro: [Expr](#class-expr) - 被调用的宏表达式。
- macroAttrs: Tokens - 宏的属性标记序列，会被格式化。
- macroInputs: [MacroExpandInput](syntax_package_enums.md#enum-macroexpandinput) - 宏输入，会被格式化。
- annotations!: Array\<[Annotation](#class-annotation)> - 附加的注解列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当宏调用表达式不是成员访问或引用表达式时，格式化过程中内存分配失败，或 `macroInputs` 不在 [MacroExpandInput](syntax_package_enums.md#enum-macroexpandinput) 中时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 EnumConstructor 实例
    let enumConstructor = EnumConstructor(
        "EnumA",
        [AtomicType(AtomicTypeKind.Int64Type)]
    )

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithoutParens(enumConstructor)

    // 创建 MacroExpandDecl 实例
    let macroExpandDecl = MacroExpandDecl(
        calleeMacro,
        macroAttrs,
        macroInputs
    )

    println("macroExpandDecl: ${macroExpandDecl}")
}
```

运行结果：

```text
macroExpandDecl: @testMacro[123]
EnumA(Int64)
```

### func getAtPos()

```cangjie
public func getAtPos(): CodePositionRange
```

功能：获取 [MacroExpandDecl](#class-macroexpanddecl) 节点中 `@` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `@` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 EnumConstructor 实例
    let enumConstructor = EnumConstructor(
        "EnumA",
        [AtomicType(AtomicTypeKind.Int64Type)]
    )

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithoutParens(enumConstructor)

    // 创建 MacroExpandDecl 实例
    let macroExpandDecl = MacroExpandDecl(
        calleeMacro,
        macroAttrs,
        macroInputs
    )

    let pos = macroExpandDecl.getAtPos()
    // 输出 @ 位置
    println("macroExpandDecl.getAtPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
macroExpandDecl.getAtPos(): 1:1-1:2
```

### func getLParenPos()

```cangjie
public func getLParenPos(): Option<CodePositionRange>
```

功能：获取 [MacroExpandDecl](#class-macroexpanddecl) 节点中 `(` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 EnumConstructor 实例
    let enumConstructor = EnumConstructor(
        "EnumA",
        [AtomicType(AtomicTypeKind.Int64Type)]
    )

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithoutParens(enumConstructor)

    // 创建 MacroExpandDecl 实例
    let macroExpandDecl = MacroExpandDecl(
        calleeMacro,
        macroAttrs,
        macroInputs
    )

    // 实际上所创建的 MacroExpandDecl 节点中不存在 ( 子节点，因此 getLParenPos() 会返回 None
    if (let Some(pos) <- macroExpandDecl.getLParenPos()) {
        // 输出 ( 位置
        println("macroExpandDecl.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    } else {
        println("macroExpandDecl.getLParenPos(): None")
    }
}
```

运行结果：

```text
macroExpandDecl.getLParenPos(): None
```

### func getLSquarePos()

```cangjie
public func getLSquarePos(): Option<CodePositionRange>
```

功能：获取 [MacroExpandDecl](#class-macroexpanddecl) 节点中 `[` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `[` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 EnumConstructor 实例
    let enumConstructor = EnumConstructor(
        "EnumA",
        [AtomicType(AtomicTypeKind.Int64Type)]
    )

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithoutParens(enumConstructor)

    // 创建 MacroExpandDecl 实例
    let macroExpandDecl = MacroExpandDecl(
        calleeMacro,
        macroAttrs,
        macroInputs
    )

    if (let Some(pos) <- macroExpandDecl.getLSquarePos()) {
        // 输出 [ 位置
        println("macroExpandDecl.getLSquarePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
macroExpandDecl.getLSquarePos(): 1:11-1:12
```

### func getRParenPos()

```cangjie
public func getRParenPos(): Option<CodePositionRange>
```

功能：获取 [MacroExpandDecl](#class-macroexpanddecl) 节点中 `)` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 EnumConstructor 实例
    let enumConstructor = EnumConstructor(
        "EnumA",
        [AtomicType(AtomicTypeKind.Int64Type)]
    )

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithoutParens(enumConstructor)

    // 创建 MacroExpandDecl 实例
    let macroExpandDecl = MacroExpandDecl(
        calleeMacro,
        macroAttrs,
        macroInputs
    )

    // 实际上所创建的 MacroExpandDecl 节点中不存在 ( 子节点，因此 getLParenPos() 会返回 None
    if (let Some(pos) <- macroExpandDecl.getRParenPos()) {
        // 输出 ) 位置
        println("macroExpandDecl.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    } else {
        println("macroExpandDecl.getRParenPos(): None")
    }
}
```

运行结果：

```text
macroExpandDecl.getRParenPos(): None
```

### func getRSquarePos()

```cangjie
public func getRSquarePos(): Option<CodePositionRange>
```

功能：获取 [MacroExpandDecl](#class-macroexpanddecl) 节点中 `]` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `]` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 EnumConstructor 实例
    let enumConstructor = EnumConstructor(
        "EnumA",
        [AtomicType(AtomicTypeKind.Int64Type)]
    )

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithoutParens(enumConstructor)

    // 创建 MacroExpandDecl 实例
    let macroExpandDecl = MacroExpandDecl(
        calleeMacro,
        macroAttrs,
        macroInputs
    )

    if (let Some(pos) <- macroExpandDecl.getRSquarePos()) {
        // 输出 ] 位置
        println("macroExpandDecl.getRSquarePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
macroExpandDecl.getRSquarePos(): 1:15-1:16
```

## class MacroExpandExpr

```cangjie
public class MacroExpandExpr <: Expr {
    public init(calleeMacro: Expr, macroAttrs: Tokens, macroInputs: MacroExpandInput, comments!: Array<Comment> = [])
}
```

功能：表示宏展开表达式。

用于在表达式上下文中执行编译时宏，将宏调用展开为具体的表达式代码。

父类型：

- [Expr](#class-expr)

### prop calleeMacro

```cangjie
public prop calleeMacro: Expr
```

功能：获取被调用的宏表达式。

类型：[Expr](#class-expr)

### prop macroAttrs

```cangjie
public prop macroAttrs: Tokens
```

功能：获取宏的属性标记集合，用于传递编译时元数据。

类型：Tokens

### prop macroInputs

```cangjie
public prop macroInputs: MacroExpandInput
```

功能：获取宏展开的输入声明，定义宏执行所需的上下文。

类型：[MacroExpandInput](syntax_package_enums.md#enum-macroexpandinput)

### init(Expr, Tokens, MacroExpandInput, Array\<Comment>)

```cangjie
public init(calleeMacro: Expr, macroAttrs: Tokens, macroInputs: MacroExpandInput, comments!: Array<Comment> = [])
```

功能：构造一个 [MacroExpandExpr](#class-macroexpandexpr) 对象，表示宏展开表达式节点。

参数：

- calleeMacro: [Expr](#class-expr) - 被调用的宏表达式。
- macroAttrs: Tokens - 宏的属性标记序列。
- macroInputs: [MacroExpandInput](syntax_package_enums.md#enum-macroexpandinput) - 宏输入，可以是带括号的 Tokens 或不带括号的 Decl。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当宏调用表达式不是成员访问或引用表达式时，格式化过程中内存分配失败，或 `macroInputs` 不在 [MacroExpandInput](syntax_package_enums.md#enum-macroexpandinput) 中时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 EnumConstructor 实例
    let enumConstructor = EnumConstructor(
        "EnumA",
        [AtomicType(AtomicTypeKind.Int64Type)]
    )

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithParens(quote(1 + 1))

    // 创建 MacroExpandExpr 实例
    let macroExpandExpr = MacroExpandExpr(
        calleeMacro,
        macroAttrs,
        macroInputs
    )

    println("macroExpandExpr: ${macroExpandExpr}")
}
```

运行结果：

```text
macroExpandExpr: @testMacro[123](1 + 1)
```

### func getAtPos()

```cangjie
public func getAtPos(): CodePositionRange
```

功能：获取 [MacroExpandExpr](#class-macroexpandexpr) 节点中 `@` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `@` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithParens(quote(1 + 1))

    // 创建 MacroExpandExpr 实例
    let macroExpandExpr = MacroExpandExpr(
        calleeMacro,
        macroAttrs,
        macroInputs
    )

    let pos = macroExpandExpr.getAtPos()
    // 输出 @ 位置
    println("macroExpandExpr.getAtPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
macroExpandExpr.getAtPos(): 1:1-1:2
```

### func getLParenPos()

```cangjie
public func getLParenPos(): Option<CodePositionRange>
```

功能：获取 [MacroExpandExpr](#class-macroexpandexpr) 节点中 `(` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `(` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithParens(quote(1 + 1))

    // 创建 MacroExpandExpr 实例
    let macroExpandExpr = MacroExpandExpr(
        calleeMacro,
        macroAttrs,
        macroInputs
    )

    if (let Some(pos) <- macroExpandExpr.getLParenPos()) {
        // 输出 ( 位置
        println("macroExpandExpr.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
macroExpandExpr.getLParenPos(): 1:16-1:17
```

### func getLSquarePos()

```cangjie
public func getLSquarePos(): Option<CodePositionRange>
```

功能：获取 [MacroExpandExpr](#class-macroexpandexpr) 节点中 `[` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `[` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithParens(quote(1 + 1))

    // 创建 MacroExpandExpr 实例
    let macroExpandExpr = MacroExpandExpr(
        calleeMacro,
        macroAttrs,
        macroInputs
    )

    if (let Some(pos) <- macroExpandExpr.getLSquarePos()) {
        // 输出 [ 位置
        println("macroExpandExpr.getLSquarePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
macroExpandExpr.getLSquarePos(): 1:11-1:12
```

### func getRParenPos()

```cangjie
public func getRParenPos(): Option<CodePositionRange>
```

功能：获取 [MacroExpandExpr](#class-macroexpandexpr) 节点中 `)` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `)` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithParens(quote(1 + 1))

    // 创建 MacroExpandExpr 实例
    let macroExpandExpr = MacroExpandExpr(
        calleeMacro,
        macroAttrs,
        macroInputs
    )

    if (let Some(pos) <- macroExpandExpr.getRParenPos()) {
        // 输出 ) 位置
        println("macroExpandExpr.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
macroExpandExpr.getRParenPos(): 1:22-1:23
```

### func getRSquarePos()

```cangjie
public func getRSquarePos(): Option<CodePositionRange>
```

功能：获取 [MacroExpandExpr](#class-macroexpandexpr) 节点中 `]` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `]` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithParens(quote(1 + 1))

    // 创建 MacroExpandExpr 实例
    let macroExpandExpr = MacroExpandExpr(
        calleeMacro,
        macroAttrs,
        macroInputs
    )

    if (let Some(pos) <- macroExpandExpr.getRSquarePos()) {
        // 输出 ] 位置
        println("macroExpandExpr.getRSquarePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
macroExpandExpr.getRSquarePos(): 1:15-1:16
```

## class MacroExpandParam

```cangjie
public class MacroExpandParam <: Parameter {
    public init(calleeMacro: Expr, macroAttrs: Tokens, macroInputs: MacroExpandInput,
        annotations!: Array<Annotation> = [], comments!: Array<Comment> = [])
}
```

功能：表示宏展开参数。

用于在函数参数定义中应用编译时宏，将宏逻辑应用于参数处理。

父类型：

- [Parameter](#class-parameter)

### prop calleeMacro

```cangjie
public prop calleeMacro: Expr
```

功能：获取被调用的宏表达式。

类型：[Expr](#class-expr)

### prop macroAttrs

```cangjie
public prop macroAttrs: Tokens
```

功能：获取宏的属性标记集合，用于传递编译时元数据。

类型：Tokens

### prop macroInputs

```cangjie
public prop macroInputs: MacroExpandInput
```

功能：获取宏展开的输入声明，定义宏执行所需的上下文。

类型：[MacroExpandInput](syntax_package_enums.md#enum-macroexpandinput)

### init(Expr, Tokens, MacroExpandInput, Array\<Annotation>, Array\<Comment>)

```cangjie
public init(calleeMacro: Expr, macroAttrs: Tokens, macroInputs: MacroExpandInput,
    annotations!: Array<Annotation> = [], comments!: Array<Comment> = [])
```

功能：构造一个 [MacroExpandParam](#class-macroexpandparam) 对象，表示宏展开参数节点，用于函数参数中嵌入宏调用。

参数：

- calleeMacro: [Expr](#class-expr) - 被调用的宏表达式。
- macroAttrs: Tokens - 宏的属性标记序列。
- macroInputs: [MacroExpandInput](syntax_package_enums.md#enum-macroexpandinput) - 宏输入，可以是带括号的 Tokens 或不带括号的 Decl。
- annotations!: Array\<[Annotation](#class-annotation)> - 附加的注解列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当宏调用表达式不是成员访问或引用表达式时，格式化过程中内存分配失败，或 `macroInputs` 不在 [MacroExpandInput](syntax_package_enums.md#enum-macroexpandinput) 中时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 EnumConstructor 实例
    let enumConstructor = EnumConstructor(
        "EnumA",
        [AtomicType(AtomicTypeKind.Int64Type)]
    )

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithParens(quote(a: Int64))

    // 创建 MacroExpandParam 实例
    let macroExpandParam = MacroExpandParam(
        calleeMacro,
        macroAttrs,
        macroInputs
    )

    println("macroExpandParam: ${macroExpandParam}")
}
```

运行结果：

```text
macroExpandParam: @testMacro[123](a: Int64)
```

### func getAtPos()

```cangjie
public func getAtPos(): CodePositionRange
```

功能：获取 [MacroExpandParam](#class-macroexpandparam) 节点中 `@` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `@` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithParens(quote(a: Int64))

    // 创建 MacroExpandParam 实例
    let macroExpandParam = MacroExpandParam(
        calleeMacro,
        macroAttrs,
        macroInputs
    )
    let pos = macroExpandParam.getAtPos()

    // 输出 @ 位置
    println("macroExpandParam.getAtPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
macroExpandParam.getAtPos(): 1:1-1:2
```

### func getLParenPos()

```cangjie
public func getLParenPos(): Option<CodePositionRange>
```

功能：获取 [MacroExpandParam](#class-macroexpandparam) 节点中 `(` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `(` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithParens(quote(a: Int64))

    // 创建 MacroExpandParam 实例
    let macroExpandParam = MacroExpandParam(
        calleeMacro,
        macroAttrs,
        macroInputs
    )
    if (let Some(pos) <- macroExpandParam.getLParenPos()) {
        // 输出 ( 位置
        println("macroExpandParam.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
macroExpandParam.getLParenPos(): 1:16-1:17
```

### func getLSquarePos()

```cangjie
public func getLSquarePos(): Option<CodePositionRange>
```

功能：获取 [MacroExpandParam](#class-macroexpandparam) 节点中 `[` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `[` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->

```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithParens(quote(a: Int64))

    // 创建 MacroExpandParam 实例
    let macroExpandParam = MacroExpandParam(
        calleeMacro,
        macroAttrs,
        macroInputs
    )
    if (let Some(pos) <- macroExpandParam.getLSquarePos()) {
        // 输出 [ 位置
        println("macroExpandParam.getLSquarePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
macroExpandParam.getLSquarePos(): 1:11-1:12
```

### func getRParenPos()

```cangjie
public func getRParenPos(): Option<CodePositionRange>
```

功能：获取 [MacroExpandParam](#class-macroexpandparam) 节点中 `)` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `)` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithParens(quote(a: Int64))

    // 创建 MacroExpandParam 实例
    let macroExpandParam = MacroExpandParam(
        calleeMacro,
        macroAttrs,
        macroInputs
    )
    if (let Some(pos) <- macroExpandParam.getRParenPos()) {
        // 输出 ) 位置
        println("macroExpandParam.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
macroExpandParam.getRParenPos(): 1:25-1:26
```

### func getRSquarePos()

```cangjie
public func getRSquarePos(): Option<CodePositionRange>
```

功能：获取 [MacroExpandParam](#class-macroexpandparam) 节点中 `]` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `]` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 calleeMacro
    let calleeMacro = SymbolRef(
        "testMacro",
        []
    )

    // 创建 macroAttrs
    let macroAttrs = quote(123)

    // 创建 macroInputs
    let macroInputs = MacroExpandInput.WithParens(quote(a: Int64))

    // 创建 MacroExpandParam 实例
    let macroExpandParam = MacroExpandParam(
        calleeMacro,
        macroAttrs,
        macroInputs
    )
    if (let Some(pos) <- macroExpandParam.getRSquarePos()) {
        // 输出 ] 位置
        println("macroExpandParam.getRSquarePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
macroExpandParam.getRSquarePos(): 1:15-1:16
```

## class MainDecl

```cangjie
public class MainDecl <: Decl {
    public init(body: Block, params: ParameterList, retTyAnnotation: Option<TypeAnnotation>, comments!: Array<Comment> = [])
}
```

功能：表示一个 `main` 函数声明节点。

一个 [MainDecl](#class-maindecl) 节点：`main() {}`。

父类型：

- [Decl](#class-decl)

### prop body

```cangjie
public prop body: Block
```

功能：获取当前主函数声明的主体部分。

类型：[Block](#class-block)

### prop params

```cangjie
public prop params: ParameterList
```

功能：获取当前主函数声明的参数列表。

类型：[ParameterList](#class-parameterlist)

### prop retTyAnnotation

```cangjie
public prop retTyAnnotation: Option<TypeAnnotation>
```

功能：获取当前主函数声明的返回类型标注（若不存在返回 `None`）。

类型：Option\<[TypeAnnotation](#class-typeannotation)>

### init(Block, ParameterList, Option\<TypeAnnotation>, Array\<Comment>)

```cangjie
public init(body: Block, params: ParameterList, retTyAnnotation: Option<TypeAnnotation>, comments!: Array<Comment> = [])
```

功能：构造一个 [MainDecl](#class-maindecl) 对象，表示主函数声明节点。

参数：

- body: [Block](#class-block) - 主函数体。
- params: [ParameterList](#class-parameterlist) - 参数列表。
- retTyAnnotation: Option\<[TypeAnnotation](#class-typeannotation)> - 可选的返回类型注解。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Block([ReturnExpr(None)])

    // 创建 params
    let params = ParameterList([])

    // 创建 retTyAnnotation
    let retTyAnnotation = AtomicType(UnitType)

    // 创建 MainDecl 实例
    let mainDecl = MainDecl(
        body, 
        params, 
        retTyAnnotation
    )

    println("mainDecl: ${mainDecl}")
}
```

运行结果：

```text
mainDecl: main(): Unit {
    return
}
```

### func getMainKeyWordPos()

```cangjie
public func getMainKeyWordPos(): CodePositionRange
```

功能：获取 [MainDecl](#class-maindecl) 节点中 `main` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `main` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 MainDecl 实例
    let body = Block([ReturnExpr(None)])
    let params = ParameterList([])
    let mainDecl = MainDecl(body, params, None)
    let pos = mainDecl.getMainKeyWordPos()

    // 输出 main 关键字位置
    println("mainDecl.getMainKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
mainDecl.getMainKeyWordPos(): 1:1-1:5
```

### func getRetTyAnnotationColonPos()

```cangjie
public func getRetTyAnnotationColonPos(): Option<CodePositionRange>
```

功能：获取 [MainDecl](#class-maindecl) 节点中类型前 `:` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回类型前 `:` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 MainDecl 实例
    let body = Block([ReturnExpr(None)])
    let params = ParameterList([])
    let retTyAnnotation = AtomicType(UnitType)
    let mainDecl = MainDecl(body, params, retTyAnnotation)

    if (let Some(pos) <- mainDecl.getRetTyAnnotationColonPos()) {
        // 输出冒号位置
        println("mainDecl.getRetTyAnnotationColonPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
mainDecl.getRetTyAnnotationColonPos(): 1:7-1:8
```

## class MatchCase

```cangjie
public class MatchCase <: SyntaxTreeNode {
    public init(patterns: Array<Pattern>, patternGuardCond: Option<Expr>, caseCond: Option<Expr>, body: Array<SyntaxTreeNode>, comments!: Array<Comment> = [])
}
```

功能：表示 `match` 表达式中的一个 `case` 节点。

一个 [MatchCase](#class-matchcase) 节点：`case failScore where score > 0 => 0`。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop body

```cangjie
public prop body: Array<SyntaxTreeNode>
```

功能：获取当前匹配条件满足时执行的代码块。

类型：Array\<[SyntaxTreeNode](#class-syntaxtreenode)>

### prop caseCond

```cangjie
public prop caseCond: Option<Expr>
```

功能：获取当前匹配条件的表达式（若不存在返回 `None`）。

类型：Option\<[Expr](#class-expr)>

### prop patternGuardCond

```cangjie
public prop patternGuardCond: Option<Expr>
```

功能：获取当前匹配条件的模式守卫表达式（若不存在返回 `None`）。

类型：Option\<[Expr](#class-expr)>

### prop patterns

```cangjie
public prop patterns: Array<Pattern>
```

功能：获取当前匹配条件的模式列表。

类型：Array\<[Pattern](#class-pattern)>

### init(Array\<Pattern>, Option\<Expr>, Option\<Expr>, Array\<SyntaxTreeNode>, Array\<Comment>)

```cangjie
public init(patterns: Array<Pattern>, patternGuardCond: Option<Expr>, caseCond: Option<Expr>, body: Array<SyntaxTreeNode>, comments!: Array<Comment> = [])
```

功能：构造一个 [MatchCase](#class-matchcase) 对象，表示 `match` 表达式中的分支 case。

参数：

- patterns: Array\<[Pattern](#class-pattern)> - 匹配模式列表。
- patternGuardCond: Option\<[Expr](#class-expr)> - 可选的模式守卫条件。
- caseCond: Option\<[Expr](#class-expr)> - 可选的 case 条件表达式。
- body: Array\<[SyntaxTreeNode](#class-syntaxtreenode)> - case 体中的语法节点列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `body` 中的节点不是表达式类型、函数声明或变量声明时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 patterns
    let patterns: Array<Pattern> = [VarPattern("x"), VarPattern("y")]

    // 创建 patternGuardCond
    let patternGuardCond = BinaryExpr(SymbolRef("x", []),BinaryOpKind.Lt, LitConstExpr(LitConstKind.IntergerLiteral, "5"))

    // 创建 body
    let body: Array<SyntaxTreeNode> = [BinaryExpr(SymbolRef("x", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))]

    // 创建 MatchCase 实例
    let matchCase = MatchCase(
        patterns, 
        patternGuardCond, 
        None, 
        body
    )

    println("matchCase: ${matchCase}")
}
```

运行结果：

```text
matchCase: case x | y where x < 5 => x + 1
```

### func getBitOrsPos()

```cangjie
public func getBitOrsPos(): Array<CodePositionRange>
```

功能：获取当前 [MatchCase](#class-matchcase) 中所有 `|` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回所有 `|` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 patterns
    let patterns: Array<Pattern> = [VarPattern("x"), VarPattern("y"), VarPattern("z")]

    // 创建 body
    let body: Array<SyntaxTreeNode> = [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))]

    // 创建 MatchCase 实例
    let matchCase = MatchCase(patterns, None, None, body)
    let posArr = matchCase.getBitOrsPos()

    // 遍历输出竖线位置
    for (i in 0..posArr.size) {
        println("matchCase.getBitOrsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
matchCase.getBitOrsPos()[0]: 1:8-1:9
matchCase.getBitOrsPos()[1]: 1:12-1:13
```

### func getCasePos()

```cangjie
public func getCasePos(): CodePositionRange
```

功能：获取当前 [MatchCase](#class-matchcase) 中 `case` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `case` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 patterns
    let patterns: Array<Pattern> = [VarPattern("x")]

    // 创建 body
    let body: Array<SyntaxTreeNode> = [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))]

    // 创建 MatchCase 实例
    let matchCase = MatchCase(patterns, None, None, body)
    let pos = matchCase.getCasePos()

    // 输出 case 关键字位置
    println("matchCase.getCasePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
matchCase.getCasePos(): 1:1-1:5
```

### func getDoubleArrowPos()

```cangjie
public func getDoubleArrowPos(): CodePositionRange
```

功能：获取当前 [MatchCase](#class-matchcase) 中 `=>` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `=>` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 patterns
    let patterns: Array<Pattern> = [VarPattern("x")]

    // 创建 body
    let body: Array<SyntaxTreeNode> = [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))]

    // 创建 MatchCase 实例
    let matchCase = MatchCase(patterns, None, None, body)
    let pos = matchCase.getDoubleArrowPos()

    // 输出双箭头位置
    println("matchCase.getDoubleArrowPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
matchCase.getDoubleArrowPos(): 1:8-1:10
```

### func getWherePos()

```cangjie
public func getWherePos(): Option<CodePositionRange>
```

功能：获取当前 [MatchCase](#class-matchcase) 中 `where` 关键字的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `where` 关键字的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 patterns
    let patterns: Array<Pattern> = [VarPattern("x")]

    // 创建 patternGuardCond
    let patternGuardCond = BinaryExpr(SymbolRef("x", []), BinaryOpKind.Lt, LitConstExpr(LitConstKind.IntergerLiteral, "5"))

    // 创建 body
    let body: Array<SyntaxTreeNode> = [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))]

    // 创建 MatchCase 实例
    let matchCase = MatchCase(patterns, patternGuardCond, None, body)

    if (let Some(pos) <- matchCase.getWherePos()) {
        // 输出 where 关键字位置
        println("matchCase.getWherePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
matchCase.getWherePos(): 1:8-1:13
```

## class MatchExpr

```cangjie
public class MatchExpr <: Expr {
    public init(matchCases: Array<MatchCase>, selector: Option<Expr>, comments!: Array<Comment> = [])
}
```

功能：表示模式匹配表达式，用于实现模式匹配。

模式匹配表达式分为带 `selector` 的 `match` 表达式和不带 `selector` 的 `match` 表达式。

父类型：

- [Expr](#class-expr)

### prop matchCases

```cangjie
public prop matchCases: Array<MatchCase>
```

功能：获取当前 `match` 语句的所有匹配条件和对应的代码块。

类型：Array\<[MatchCase](#class-matchcase)>

### prop selector

```cangjie
public prop selector: Option<Expr>
```

功能：获取当前 `match` 语句的要匹配的表达式。

类型：Option\<[Expr](#class-expr)>

### init(Array\<MatchCase>, Option\<Expr>, Array\<Comment>)

```cangjie
public init(matchCases: Array<MatchCase>, selector: Option<Expr>, comments!: Array<Comment> = [])
```

功能：构造一个 [MatchExpr](#class-matchexpr) 对象，表示 `match` 表达式。

参数：

- matchCases: Array\<[MatchCase](#class-matchcase)> - 分支 case 列表。
- selector: Option\<[Expr](#class-expr)> - 可选的被匹配表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 matchCases
    let matchCases = [MatchCase([VarPattern("x"), VarPattern("y")], None, None, [BinaryExpr(SymbolRef("x", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])]

    // 创建 selector
    let selector = SymbolRef("x", [])

    // 创建 MatchExpr 实例
    let matchExpr = MatchExpr(
        matchCases, 
        selector
    )

    println("matchExpr: ${matchExpr}")
}
```

运行结果：

```text
matchExpr: match (x) {
    case x | y => x + 1
}
```

### func getMatchCasesLCurlPos()

```cangjie
public func getMatchCasesLCurlPos(): CodePositionRange
```

功能：获取当前 [MatchExpr](#class-matchexpr) 中 `{` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `{` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 matchCases
    let matchCases = [MatchCase([VarPattern("x")], None, None, [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])]

    // 创建 MatchExpr 实例
    let matchExpr = MatchExpr(matchCases, SymbolRef("x", []))
    let pos = matchExpr.getMatchCasesLCurlPos()

    // 输出左花括号位置
    println("matchExpr.getMatchCasesLCurlPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
matchExpr.getMatchCasesLCurlPos(): 1:11-1:12
```

### func getMatchCasesRCurlPos()

```cangjie
public func getMatchCasesRCurlPos(): CodePositionRange
```

功能：获取当前 [MatchExpr](#class-matchexpr) 中 `}` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `}` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 matchCases
    let matchCases = [MatchCase([VarPattern("x")], None, None, [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])]

    // 创建 MatchExpr 实例
    let matchExpr = MatchExpr(matchCases, SymbolRef("x", []))
    let pos = matchExpr.getMatchCasesRCurlPos()

    // 输出右花括号位置
    println("matchExpr.getMatchCasesRCurlPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
matchExpr.getMatchCasesRCurlPos(): 3:1-3:2
```

### func getMatchKeyWordPos()

```cangjie
public func getMatchKeyWordPos(): CodePositionRange
```

功能：获取当前 [MatchExpr](#class-matchexpr) 中 `match` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `match` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 matchCases
    let matchCases = [MatchCase([VarPattern("x")], None, None, [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])]

    // 创建 MatchExpr 实例
    let matchExpr = MatchExpr(matchCases, SymbolRef("x", []))
    let pos = matchExpr.getMatchKeyWordPos()

    // 输出 match 关键字位置
    println("matchExpr.getMatchKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
matchExpr.getMatchKeyWordPos(): 1:1-1:6
```

### func getSelectorLParenPos()

```cangjie
public func getSelectorLParenPos(): Option<CodePositionRange>
```

功能：获取当前 [MatchExpr](#class-matchexpr) 的选择器中的 `(` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回选择器中的 `(` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 matchCases
    let matchCases = [MatchCase([VarPattern("x")], None, None, [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])]

    // 创建 MatchExpr 实例
    let matchExpr = MatchExpr(matchCases, SymbolRef("x", []))

    if (let Some(pos) <- matchExpr.getSelectorLParenPos()) {
        // 输出选择器左括号位置
        println("matchExpr.getSelectorLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
matchExpr.getSelectorLParenPos(): 1:7-1:8
```

### func getSelectorRParenPos()

```cangjie
public func getSelectorRParenPos(): Option<CodePositionRange>
```

功能：获取当前 [MatchExpr](#class-matchexpr) 的选择器中的 `)` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回选择器中的 `)` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 matchCases
    let matchCases = [MatchCase([VarPattern("x")], None, None, [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])]

    // 创建 MatchExpr 实例
    let matchExpr = MatchExpr(matchCases, SymbolRef("x", []))

    if (let Some(pos) <- matchExpr.getSelectorRParenPos()) {
        // 输出选择器右括号位置
        println("matchExpr.getSelectorRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
matchExpr.getSelectorRParenPos(): 1:9-1:10
```

## class MemberAccess

```cangjie
public class MemberAccess <: Expr {
    public init(base: SyntaxTreeNode, field: SymbolRef, comments!: Array<Comment> = [])
}
```

功能：表示成员访问表达式。

可以用于访问 `class`、`interface`、`struct` 等类型的成员。一个 [MemberAccess](#class-memberaccess) 节点的形式为 `p.a`，`p` 为成员访问表达式的主体，`a` 表示成员的名字。

父类型：

- [Expr](#class-expr)

### prop base

```cangjie
public prop base: SyntaxTreeNode
```

功能：获取当前成员访问表达式的基节点，即被访问的对象或结构体。

类型：[SyntaxTreeNode](#class-syntaxtreenode)

### prop field

```cangjie
public prop field: SymbolRef
```

功能：获取当前成员访问表达式中要访问的成员字段。

类型：[SymbolRef](#class-symbolref)

### init(SyntaxTreeNode, SymbolRef, Array\<Comment>)

```cangjie
public init(base: SyntaxTreeNode, field: SymbolRef, comments!: Array<Comment> = [])
```

功能：构造一个 [MemberAccess](#class-memberaccess) 对象，表示成员访问表达式。

参数：

- base: [SyntaxTreeNode](#class-syntaxtreenode) - 被访问的对象表达式或类型标注。
- field: [SymbolRef](#class-symbolref) - 成员字段引用。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `base` 节点不是表达式或类型标注时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 base
    let base = SymbolRef("p", [])

    // 创建 field
    let field = SymbolRef("A", [])

    // 创建 MemberAccess 实例
    let memberAccess = MemberAccess(
        base, 
        field
    )

    println("memberAccess: ${memberAccess}")
}
```

运行结果：

```text
memberAccess: p.A
```

### func getDotPos()

```cangjie
public func getDotPos(): CodePositionRange
```

功能：获取当前 [MemberAccess](#class-memberaccess) 中 `.` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `.` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 base
    let base = SymbolRef("p", [])

    // 创建 field
    let field = SymbolRef("A", [])

    // 创建 MemberAccess 实例
    let memberAccess = MemberAccess(base, field)
    let pos = memberAccess.getDotPos()

    // 输出点号位置
    println("memberAccess.getDotPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
memberAccess.getDotPos(): 1:2-1:3
```

## class Modifier

```cangjie
public class Modifier <: SyntaxTreeNode {
    public init(kind: ModifierKind, comments!: Array<Comment> = [])
}
```

功能：表示某个声明的修饰符，通常放在声明处的最前端。

一个 [Modifier](#class-modifier) 节点：`public func foo()` 中的 `public`。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop kind

```cangjie
public prop kind: ModifierKind
```

功能：获取 [Modifier](#class-modifier) 节点的修饰符种类。

类型：[ModifierKind](syntax_package_enums.md#enum-modifierkind)

### init(ModifierKind, Array\<Comment>)

```cangjie
public init(kind: ModifierKind, comments!: Array<Comment> = [])
```

功能：构造一个 [Modifier](#class-modifier) 对象，表示语法树中的修饰符节点，如 `public`、`static` 等。

参数：

- kind: [ModifierKind](syntax_package_enums.md#enum-modifierkind) - 修饰符类型。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 ModifierKind
    let kind = ModifierKind.Public

    // 创建 Modifier 实例
    let modifier = Modifier(
        kind
    )

    println("modifier: ${modifier}")
}
```

运行结果：

```text
modifier: public
```

## class OptionalExpr

```cangjie
public class OptionalExpr <: Expr {
    public init(base: Expr, comments!: Array<Comment> = [])
}
```

功能：表示一个带有问号操作符的表达式节点。

一个 [OptionalExpr](#class-optionalexpr) 节点：`a?.b, a?(b), a?[b]` 中的 `a?`。

父类型：

- [Expr](#class-expr)

### prop base

```cangjie
public prop base: Expr
```

功能：获取 [OptionalExpr](#class-optionalexpr) 的表达式节点。

类型：[Expr](#class-expr)

### init(Expr, Array\<Comment>)

```cangjie
public init(base: Expr, comments!: Array<Comment> = [])
```

功能：构造一个 [OptionalExpr](#class-optionalexpr) 对象，表示带问号操作符的表达式节点。

参数：

- base: [Expr](#class-expr) - 基础表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 SymbolRef 实例
    let symbolRef = SymbolRef("a", [])

    // 创建 OptionalExpr 实例
    let optionalExpr = OptionalExpr(symbolRef)

    println("optionalExpr: ${optionalExpr}")
}
```

运行结果：

```text
optionalExpr: a?
```

### func getQuestionPos()

```cangjie
public func getQuestionPos(): CodePositionRange
```

功能：获取 `?` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `?` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 SymbolRef 实例
    let symbolRef = SymbolRef("a", [])

    // 创建 OptionalExpr 实例
    let optionalExpr = OptionalExpr(symbolRef)
    
    let pos = optionalExpr.getQuestionPos()
    
    // 输出 ? 位置
    println("optionalExpr.getQuestionPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
optionalExpr.getQuestionPos(): 1:2-1:3
```

## class Package

```cangjie
public class Package <: SyntaxTreeNode {
    public init(isMacroPkg: Bool, name: String, srcFile: Array<SourceFile>)
}
```

功能：表示包节点。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop isMacroPkg

```cangjie
public prop isMacroPkg: Bool
```

功能：表示当前包是否为宏包。

类型：Bool

### prop name

```cangjie
public prop name: String
```

功能：表示当前包的包名。

类型：String

### prop srcFile

```cangjie
public prop srcFile: Array<SourceFile>
```

功能：表示当前包的源码文件列表。

类型：Array\<[SourceFile](#class-sourcefile)>

### init(Bool, String, Array\<SourceFile>)

```cangjie
public init(isMacroPkg: Bool, name: String, srcFile: Array<SourceFile>)
```

功能：构造一个 [Package](#class-package) 对象，表示整个包节点，包含多个源文件。

参数：

- isMacroPkg: Bool - 是否为宏包。
- name: String - 包名。
- srcFile: Array\<[SourceFile](#class-sourcefile)> - 源文件列表。

异常：

- Exception - 当输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let contents = ImportSingle(["pkg"], "a")

    // 创建 ImportList 实例
    let importList = ImportList(
        contents, 
        None
    )

    let body = Block([ReturnExpr(None)])
    let params = ParameterList([])
    let retTyAnnotation = AtomicType(UnitType)

    // 创建 MainDecl 实例
    let mainDecl = MainDecl(
        body, 
        params, 
        retTyAnnotation
    )

    let name = "sourceFile.cj"
    let path = "/path/to/sourceFile.cj"

    // 创建 SourceFile 实例
    let sourceFile = SourceFile(
        [importList],
        name,
        path,
        None,
        [mainDecl]
    )

    let isMacroPkg = false
    let pkgName = "default"

    // 创建 Package 实例
    let pkg = Package(
        isMacroPkg,
        pkgName,
        [sourceFile]
    )

    println("pkg: ${pkg}")
}
```

运行结果：

```text
pkg: // sourceFile.cj
import pkg.a
main(): Unit {
    return
}
```

### func toString()

```cangjie
public func toString(): String
```

功能：将包节点作为字符串打印出来，包内的文件按文件名字母序排序，对每个文件依次打印文件名和文件内容。

返回值：

- String - 返回包节点作为字符串打印的结果。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let contents = ImportSingle(["pkg"], "a")

    // 创建 ImportList 实例
    let importList = ImportList(
        contents, 
        None
    )

    let body = Block([ReturnExpr(None)])
    let params = ParameterList([])
    let retTyAnnotation = AtomicType(UnitType)

    // 创建 MainDecl 实例
    let mainDecl = MainDecl(
        body, 
        params, 
        retTyAnnotation
    )

    let name = "sourceFile.cj"
    let path = "/path/to/sourceFile.cj"

    // 创建 SourceFile 实例
    let sourceFile = SourceFile(
        [importList],
        name,
        path,
        None,
        [mainDecl]
    )

    let isMacroPkg = false
    let pkgName = "default"

    // 创建 Package 实例
    let pkg = Package(
        isMacroPkg,
        pkgName,
        [sourceFile]
    )

    println("pkg.toString(): ${pkg.toString()}")
}
```

运行结果：

```text
pkg.toString(): // sourceFile.cj
import pkg.a
main(): Unit {
    return
}
```

### func toTokens()

```cangjie
public func toTokens(): Tokens
```

功能：将包节点转换为一组词法单元，包内的文件按文件名字典序排序，在每个文件对应的词法单元之前加上一个注释类型的 `Token`, 内容为该文件的文件名。

返回值：

- Tokens - 返回包节点转换为一组词法单元的结果。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let contents = ImportSingle(["pkg"], "a")

    // 创建 ImportList 实例
    let importList = ImportList(
        contents, 
        None
    )

    let body = Block([ReturnExpr(None)])
    let params = ParameterList([])
    let retTyAnnotation = AtomicType(UnitType)

    // 创建 MainDecl 实例
    let mainDecl = MainDecl(
        body, 
        params, 
        retTyAnnotation
    )

    let name = "sourceFile.cj"
    let path = "/path/to/sourceFile.cj"

    // 创建 SourceFile 实例
    let sourceFile = SourceFile(
        [importList],
        name,
        path,
        None,
        [mainDecl]
    )

    let isMacroPkg = false
    let pkgName = "default"

    // 创建 Package 实例
    let pkg = Package(
        isMacroPkg,
        pkgName,
        [sourceFile]
    )

    println("pkg.toTokens(): ${pkg.toTokens()}")
}
```

运行结果：

```text
pkg.toTokens(): 
// sourceFile.cj
 import pkg.a
main(): Unit {
    return
}
```

## class PackageHeader

```cangjie
public class PackageHeader <: SyntaxTreeNode {
    public init(accessModifier: Option<Modifier>, isMacroPkg: Bool, packageNameIdentifiers: Array<String>, comments!: Array<Comment> = [])
}
```

功能：表示包声明节点。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop accessModifier

```cangjie
public prop accessModifier: Option<Modifier>
```

功能：表示当前包声明的可见性修饰符。

类型：Option\<[Modifier](#class-modifier)>

### prop isMacroPkg

```cangjie
public prop isMacroPkg: Bool
```

功能：表示当前包是否为宏包。

类型：Bool

### prop packageNameIdentifiers

```cangjie
public prop packageNameIdentifiers: Array<String>
```

功能：获取 [PackageHeader](#class-packageheader) 节点中当前包的包名列表，包含 root 包到当前子包的各级包名。

类型：Array\<String>

### init(Option\<Modifier>, Bool, Array\<String>, Array\<Comment>)

```cangjie
public init(accessModifier: Option<Modifier>, isMacroPkg: Bool, packageNameIdentifiers: Array<String>, comments!: Array<Comment> = [])
```

功能：构造一个 [PackageHeader](#class-packageheader) 对象，表示包声明头。

参数：

- accessModifier: Option\<[Modifier](#class-modifier)> - 访问修饰符，可选。
- isMacroPkg: Bool - 是否为宏包。
- packageNameIdentifiers: Array\<String> - 包名标识符列表，如 `["stdx", "syntax"]`。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当修饰符不是 `public`、`internal` 或 `protected`，或 `packageNameIdentifiers` 为空时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 accessModifier
    let accessModifier = Modifier(ModifierKind.Public)

    // 创建 isMacroPkg
    let isMacroPkg = true

    // 创建 packageNameIdentifiers
    let packageNameIdentifiers = ["A"]

    // 创建 PackageHeader 实例
    let packageHeader = PackageHeader(
        accessModifier, 
        isMacroPkg, 
        packageNameIdentifiers
    )

    println("packageHeader: ${packageHeader}")
}
```

运行结果：

```text
packageHeader: public macro package A
```

### func getDotsPos()

```cangjie
public func getDotsPos(): Array<CodePositionRange>
```

功能：获取 [PackageHeader](#class-packageheader) 节点中 `.` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `.` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 PackageHeader 实例
    let packageNameIdentifiers = ["syntax"]
    let packageHeader = PackageHeader(None, false, packageNameIdentifiers)
    let posArr = packageHeader.getDotsPos()

    // 遍历输出点位置
    for (i in 0..posArr.size) {
        println("packageHeader.getDotsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
```

### func getMacroKeyWordPos()

```cangjie
public func getMacroKeyWordPos(): Option<CodePositionRange>
```

功能：获取 [PackageHeader](#class-packageheader) 节点中 `macro` 关键字的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `macro` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 PackageHeader 实例
    let packageHeader = PackageHeader(None, true, ["A"])

    if (let Some(pos) <- packageHeader.getMacroKeyWordPos()) {
        // 输出 macro 关键字位置
        println("packageHeader.getMacroKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
packageHeader.getMacroKeyWordPos(): 1:1-1:6
```

### func getPackageIdentifiersPos()

```cangjie
public func getPackageIdentifiersPos(): Array<CodePositionRange>
```

功能：获取 [PackageHeader](#class-packageheader) 节点中包标识符的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回包标识符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 PackageHeader 实例
    let packageNameIdentifiers = ["std"]
    let packageHeader = PackageHeader(None, false, packageNameIdentifiers)
    let posArr = packageHeader.getPackageIdentifiersPos()

    // 遍历输出包标识符位置
    for (i in 0..posArr.size) {
        println("packageHeader.getPackageIdentifiersPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
packageHeader.getPackageIdentifiersPos()[0]: 1:9-1:12
```

### func getPackageKeyWordPos()

```cangjie
public func getPackageKeyWordPos(): CodePositionRange
```

功能：获取 [PackageHeader](#class-packageheader) 节点中 `package` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `package` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 PackageHeader 实例
    let packageHeader = PackageHeader(None, false, ["A"])
    let pos = packageHeader.getPackageKeyWordPos()

    // 输出 package 关键字位置
    println("packageHeader.getPackageKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
packageHeader.getPackageKeyWordPos(): 1:1-1:8
```

### func getPackageName()

```cangjie
public func getPackageName(): String
```

功能：获取 [PackageHeader](#class-packageheader) 节点中的包名。

返回值：

- String - 返回包名。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 PackageHeader 实例
    let packageNameIdentifiers = ["syntax"]
    let packageHeader = PackageHeader(None, false, packageNameIdentifiers)
    let name = packageHeader.getPackageName()

    // 输出包名
    println("packageHeader.getPackageName(): ${name}")
}
```

运行结果：

```text
packageHeader.getPackageName(): syntax
```

### func getParentPackageName()

```cangjie
public func getParentPackageName(): String
```

功能：获取 [PackageHeader](#class-packageheader) 节点中所有父包的包名。

返回值：

- String - 返回所有父包的包名。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 PackageHeader 实例
    let packageNameIdentifiers = ["std", "syntax"]
    let packageHeader = PackageHeader(None, false, packageNameIdentifiers)
    let parentName = packageHeader.getParentPackageName()

    // 输出父包名
    println("packageHeader.getParentPackageName(): ${parentName}")
}
```

运行结果：

```text
packageHeader.getParentPackageName(): std
```

## class Parameter

```cangjie
sealed abstract class Parameter <: Decl {}
```

功能：参数节点的父类，继承自 [Decl](#class-decl) 节点。

父类型：

- [Decl](#class-decl)

## class ParameterList

```cangjie
public class ParameterList <: SyntaxTreeNode {
    public init(parameters: Array<Parameter>, hasParen!: Bool = true, comments!: Array<Comment> = [])
}
```

功能：参数列表节点。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop params

```cangjie
public prop params: Array<Parameter>
```

功能：获取全部参数。

类型：Array\<[Parameter](#class-parameter)>

### init(Array\<Parameter>, Bool, Array\<Comment>)

```cangjie
public init(parameters: Array<Parameter>, hasParen!: Bool = true, comments!: Array<Comment> = [])
```

功能：构造一个 [ParameterList](#class-parameterlist) 对象，表示参数列表。

参数：

- parameters: Array\<[Parameter](#class-parameter)> - 参数列表。
- hasParen!: Bool - 是否带有括号，默认为 `true`。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let name0 = "x"
    let typeAnnotation0 = AtomicType(Int64Type)
    let name1 = "y"
    let typeAnnotation1 = AtomicType(Int64Type)

    // 创建 LambdaParam 实例
    let lambdaParam0 = LambdaParam(
        name0, 
        typeAnnotation0
    )
    let lambdaParam1 = LambdaParam(
        name1, 
        typeAnnotation1
    )

    // 创建 ParameterList 实例
    let parameterList = ParameterList(
        [lambdaParam0, lambdaParam1],
        hasParen: false
    )

    println("parameterList: ${parameterList}")
}
```

运行结果：

```text
parameterList: x: Int64, y: Int64
```

### func getParamsCommasPos()

```cangjie
public func getParamsCommasPos(): Array<CodePositionRange>
```

功能：获取参数间 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回参数间 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let name0 = "x"
    let typeAnnotation0 = AtomicType(Int64Type)
    let name1 = "y"
    let typeAnnotation1 = AtomicType(Int64Type)

    // 创建 LambdaParam 实例
    let lambdaParam0 = LambdaParam(
        name0, 
        typeAnnotation0
    )
    let lambdaParam1 = LambdaParam(
        name1, 
        typeAnnotation1
    )

    // 创建 ParameterList 实例
    let parameterList = ParameterList(
        [lambdaParam0, lambdaParam1],
        hasParen: false
    )

    let commasPos = parameterList.getParamsCommasPos()
    
    // 输出参数间逗号位置
    for (i in 0..commasPos.size) {
        println("parameterList.getParamsCommasPos()[${i}]: ${commasPos[i].beginLine}:${commasPos[i].beginColumn}-${commasPos[i].endLine}:${commasPos[i].endColumn}")
    }
}
```

运行结果：

```text
parameterList.getParamsCommasPos()[0]: 1:9-1:10
```

### func getParamsLParenPos()

```cangjie
public func getParamsLParenPos(): Option<CodePositionRange>
```

功能：获取参数前 `(` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回参数前 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let name0 = "x"
    let typeAnnotation0 = AtomicType(Int64Type)
    let name1 = "y"
    let typeAnnotation1 = AtomicType(Int64Type)

    // 创建 LambdaParam 实例
    let lambdaParam0 = LambdaParam(
        name0, 
        typeAnnotation0
    )
    let lambdaParam1 = LambdaParam(
        name1, 
        typeAnnotation1
    )

    // 创建 ParameterList 实例
    let parameterList = ParameterList(
        [lambdaParam0, lambdaParam1],
        hasParen: true
    )

    if (let Some(pos) <- parameterList.getParamsLParenPos()) {
        // 输出 ( 位置
        println("parameterList.getParamsLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
parameterList.getParamsLParenPos(): 1:1-1:2
```

### func getParamsRParenPos()

```cangjie
public func getParamsRParenPos(): Option<CodePositionRange>
```

功能：获取参数后 `)` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回参数后 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let name0 = "x"
    let typeAnnotation0 = AtomicType(Int64Type)
    let name1 = "y"
    let typeAnnotation1 = AtomicType(Int64Type)

    // 创建 LambdaParam 实例
    let lambdaParam0 = LambdaParam(
        name0, 
        typeAnnotation0
    )
    let lambdaParam1 = LambdaParam(
        name1, 
        typeAnnotation1
    )

    // 创建 ParameterList 实例
    let parameterList = ParameterList(
        [lambdaParam0, lambdaParam1],
        hasParen: true
    )

    if (let Some(pos) <- parameterList.getParamsRParenPos()) {
        // 输出 ) 位置
        println("parameterList.getParamsRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
parameterList.getParamsRParenPos(): 1:20-1:21
```

## class ParenCondition

```cangjie
public class ParenCondition <: SyntaxTreeNode {
    public init(cond: DisjunctionCondition, comments!: Array<Comment> = [])
}
```

功能：表示一个括号条件节点，是指使用圆括号括起来的条件。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop cond

```cangjie
public prop cond: DisjunctionCondition
```

功能：获取 [ParenCondition](#class-parencondition) 节点中由圆括号括起来的条件。

类型：[DisjunctionCondition](#class-disjunctioncondition)

### init(DisjunctionCondition, Array\<Comment>)

```cangjie
public init(cond: DisjunctionCondition, comments!: Array<Comment> = [])
```

功能：构造一个 [ParenCondition](#class-parencondition) 对象，表示括号包裹的逻辑条件。

参数：

- cond: [DisjunctionCondition](#class-disjunctioncondition) - 被括号包裹的析取条件。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let symbolRef0 = SymbolRef("x", [])
    let symbolRef1 = SymbolRef("y", [])
    let symbolRef2 = SymbolRef("a", [])
    let symbolRef3 = SymbolRef("b", [])

    let binaryExpr0 = BinaryExpr(symbolRef0, BinaryOpKind.Equal, symbolRef1)
    let binaryExpr1 = BinaryExpr(symbolRef2, BinaryOpKind.Equal, symbolRef3)

    // 创建 ConjunctionCondition 实例
    let cond0 = ConjunctionCondition(AtomicCondition.Expression(binaryExpr0))
    let cond1 = ConjunctionCondition(AtomicCondition.Expression(binaryExpr1))

    // 创建 DisjunctionCondition 实例
    let disjunctionCondition = DisjunctionCondition(
        [cond0, cond1]
    )

    // 创建 ParenCondition 实例
    let parenCondition = ParenCondition(disjunctionCondition)

    println("parenCondition: ${parenCondition}")
}
```

运行结果：

```text
parenCondition: (x == y || a == b)
```

### func getLParenPos()

```cangjie
public func getLParenPos(): CodePositionRange
```

功能：获取 [ParenCondition](#class-parencondition) 节点中的 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let symbolRef0 = SymbolRef("x", [])
    let symbolRef1 = SymbolRef("y", [])
    let symbolRef2 = SymbolRef("a", [])
    let symbolRef3 = SymbolRef("b", [])

    let binaryExpr0 = BinaryExpr(symbolRef0, BinaryOpKind.Equal, symbolRef1)
    let binaryExpr1 = BinaryExpr(symbolRef2, BinaryOpKind.Equal, symbolRef3)

    // 创建 ConjunctionCondition 实例
    let cond0 = ConjunctionCondition(AtomicCondition.Expression(binaryExpr0))
    let cond1 = ConjunctionCondition(AtomicCondition.Expression(binaryExpr1))

    // 创建 DisjunctionCondition 实例
    let disjunctionCondition = DisjunctionCondition(
        [cond0, cond1]
    )

    // 创建 ParenCondition 实例
    let parenCondition = ParenCondition(disjunctionCondition)
    
    let pos = parenCondition.getLParenPos()
    // 输出 ( 位置
    println("parenCondition.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
parenCondition.getLParenPos(): 1:1-1:2
```

### func getRParenPos()

```cangjie
public func getRParenPos(): CodePositionRange
```

功能：获取 [ParenCondition](#class-parencondition) 节点中的 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let symbolRef0 = SymbolRef("x", [])
    let symbolRef1 = SymbolRef("y", [])
    let symbolRef2 = SymbolRef("a", [])
    let symbolRef3 = SymbolRef("b", [])

    let binaryExpr0 = BinaryExpr(symbolRef0, BinaryOpKind.Equal, symbolRef1)
    let binaryExpr1 = BinaryExpr(symbolRef2, BinaryOpKind.Equal, symbolRef3)

    // 创建 ConjunctionCondition 实例
    let cond0 = ConjunctionCondition(AtomicCondition.Expression(binaryExpr0))
    let cond1 = ConjunctionCondition(AtomicCondition.Expression(binaryExpr1))

    // 创建 DisjunctionCondition 实例
    let disjunctionCondition = DisjunctionCondition(
        [cond0, cond1]
    )

    // 创建 ParenCondition 实例
    let parenCondition = ParenCondition(disjunctionCondition)
    
    let pos = parenCondition.getRParenPos()
    // 输出 ) 位置
    println("parenCondition.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
parenCondition.getRParenPos(): 1:18-1:19
```

## class ParenExpr

```cangjie
public class ParenExpr <: Expr {
    public init(subExpr: Expr, comments!: Array<Comment> = [])
}
```

功能：表示一个括号表达式节点，是指使用圆括号括起来的表达式。

父类型：

- [Expr](#class-expr)

### prop subExpr

```cangjie
public prop subExpr: Expr
```

功能：获取 [ParenExpr](#class-parenexpr) 节点中由圆括号括起来的子表达式。

类型：[Expr](#class-expr)

### init(Expr, Array\<Comment>)

```cangjie
public init(subExpr: Expr, comments!: Array<Comment> = [])
```

功能：构造一个 [ParenExpr](#class-parenexpr) 对象，表示括号表达式，如 `(x + 1)`。

参数：

- subExpr: [Expr](#class-expr) - 被括号包裹的子表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let srcVal = SymbolRef("a", [])
    let targetTypeAnnotation = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 AsExpr 实例
    let asExpr = AsExpr(
        srcVal, 
        targetTypeAnnotation
    )

    // 创建 ParenExpr 实例
    let parenExpr = ParenExpr(asExpr)

    println("parenExpr: ${parenExpr}")
}
```

运行结果：

```text
parenExpr: (a as Int64)
```

### func getLParenPos()

```cangjie
public func getLParenPos(): CodePositionRange
```

功能：获取 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let srcVal = SymbolRef("a", [])
    let targetTypeAnnotation = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 AsExpr 实例
    let asExpr = AsExpr(
        srcVal, 
        targetTypeAnnotation
    )

    // 创建 ParenExpr 实例
    let parenExpr = ParenExpr(asExpr)
    
    let pos = parenExpr.getLParenPos()
    // 输出 ( 位置
    println("parenExpr.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
parenExpr.getLParenPos(): 1:1-1:2
```

### func getRParenPos()

```cangjie
public func getRParenPos(): CodePositionRange
```

功能：获取 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let srcVal = SymbolRef("a", [])
    let targetTypeAnnotation = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 AsExpr 实例
    let asExpr = AsExpr(
        srcVal, 
        targetTypeAnnotation
    )

    // 创建 ParenExpr 实例
    let parenExpr = ParenExpr(asExpr)
    
    let pos = parenExpr.getRParenPos()
    // 输出 ) 位置
    println("parenExpr.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
parenExpr.getRParenPos(): 1:12-1:13
```

## class ParenType

```cangjie
public class ParenType <: TypeAnnotation {
    public init(subType: TypeAnnotation, comments!: Array<Comment> = [])
}
```

功能：表示括号类型节点。

例如 `var a: (Int64)` 中的 `(Int64)`。

父类型：

- [TypeAnnotation](#class-typeannotation)

### prop subType

```cangjie
public prop subType: TypeAnnotation
```

功能：获取 [ParenType](#class-parentype) 节点中括起来的类型，如 `(Int64)` 中的 `Int64`。

类型：[TypeAnnotation](#class-typeannotation)

### init(TypeAnnotation, Array\<Comment>)

```cangjie
public init(subType: TypeAnnotation, comments!: Array<Comment> = [])
```

功能：构造一个 [ParenType](#class-parentype) 对象，表示括号包裹的类型，如 `(T)`。

参数：

- subType: [TypeAnnotation](#class-typeannotation) - 被括号包裹的子类型。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    
    let subType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 ParenType 实例
    let parenType = ParenType(subType)

    println("parenType: ${parenType}")
}
```

运行结果：

```text
parenType: (Int64)
```

### func getLParenPos()

```cangjie
public func getLParenPos(): CodePositionRange
```

功能：获取 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let subType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 ParenType 实例
    let parenType = ParenType(subType)
    
    let pos = parenType.getLParenPos()
    // 输出 ( 位置
    println("parenType.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
parenType.getLParenPos(): 1:1-1:2
```

### func getRParenPos()

```cangjie
public func getRParenPos(): CodePositionRange
```

功能：获取 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let subType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 ParenType 实例
    let parenType = ParenType(subType)
    
    let pos = parenType.getRParenPos()
    // 输出 ) 位置
    println("parenType.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
parenType.getRParenPos(): 1:7-1:8
```

## class ParsingResult\<T> where T <: SyntaxTreeNode

```cangjie
public class ParsingResult<T> where T <: SyntaxTreeNode {
    public let diags: Array<Diagnostic>
    public let node: Option<T>
}
```

功能：表示一个符合仓颉语法的抽象语法树。

### let diags

```cangjie
public let diags: Array<Diagnostic>
```

功能：获取当前抽象语法树的全部诊断信息。

类型：Array\<[Diagnostic](#class-diagnostic)>

### let node

```cangjie
public let node: Option<T>
```

功能：获取当前抽象语法树的节点（若不存在返回 `None`）。

类型：Option\<T>，其中 `T` 为 [SyntaxTreeNode](#class-syntaxtreenode) 的子类型 `T`。

## class Pattern

```cangjie
sealed abstract class Pattern <: SyntaxTreeNode {}
```

功能：表示一个模式匹配节点。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

## class PrefixType

```cangjie
public class PrefixType <: TypeAnnotation {
    public init(base: TypeAnnotation, prefixOp: PrefixTypeOpKind, comments!: Array<Comment> = [])
}
```

功能：表示带前缀操作符的前缀类型节点。

例如 `var a : ?A` 中的 `?A`。

父类型：

- [TypeAnnotation](#class-typeannotation)

### prop base

```cangjie
public prop base: TypeAnnotation
```

功能：获取 [PrefixType](#class-prefixtype) 节点中的类型节点，如 `var a: ?A` 中的 `A`。

类型：[TypeAnnotation](#class-typeannotation)

### prop prefixTypeOpKind

```cangjie
public prop prefixTypeOpKind: PrefixTypeOpKind
```

功能：获取 [PrefixType](#class-prefixtype) 节点中的前缀操作符类型。

类型：[PrefixTypeOpKind](syntax_package_enums.md#enum-prefixtypeopkind)

### init(TypeAnnotation, PrefixTypeOpKind, Array\<Comment>)

```cangjie
public init(base: TypeAnnotation, prefixOp: PrefixTypeOpKind, comments!: Array<Comment> = [])
```

功能：构造一个 [PrefixType](#class-prefixtype) 对象，表示带前缀的类型，如 `?T`。

参数：

- base: [TypeAnnotation](#class-typeannotation) - 基础类型。
- prefixOp: [PrefixTypeOpKind](syntax_package_enums.md#enum-prefixtypeopkind) - 前缀操作符类型。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let base = AtomicType(AtomicTypeKind.Int64Type)
    let prefixOp = PrefixTypeOpKind.Quest

    // 创建 PrefixType 实例
    let prefixType = PrefixType(
        base,
        prefixOp
    )

    println("prefixType: ${prefixType}")
}
```

运行结果：

```text
prefixType: ?Int64
```

### func getOperatorPos()

```cangjie
public func getOperatorPos(): CodePositionRange
```

功能：获取前缀操作符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回前缀操作符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let base = AtomicType(AtomicTypeKind.Int64Type)
    let prefixOp = PrefixTypeOpKind.Quest

    // 创建 PrefixType 实例
    let prefixType = PrefixType(
        base,
        prefixOp
    )
    
    let pos = prefixType.getOperatorPos()
    // 输出前缀操作符位置
    println("prefixType.getOperatorPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
prefixType.getOperatorPos(): 1:1-1:2
```

## class PropDecl

```cangjie
public class PropDecl <: Decl {
    public init(getter: Option<PropGetterOrSetter>, name: String, setter: Option<PropGetterOrSetter>,
        tyAnnotation: TypeAnnotation, annotations!: Array<Annotation> = [], modifiers!: Array<Modifier> = [],
        comments!: Array<Comment> = [])
}
```

功能：表示一个属性声明节点。

一个 [PropDecl](#class-propdecl) 节点：`prop X: Int64 { get() { 0 } }`。

父类型：

- [Decl](#class-decl)

### prop getter

```cangjie
public prop getter: Option<PropGetterOrSetter>
```

功能：获取当前属性声明的 `getter` 方法（若不存在返回 `None`）。

类型：Option\<[PropGetterOrSetter](#class-propgetterorsetter)>

### prop isMut

```cangjie
public prop isMut: Bool
```

功能：判断当前属性声明是否可变。

类型：Bool

### prop name

```cangjie
public prop name: String
```

功能：获取当前属性声明的名称。

类型：String

### prop setter

```cangjie
public prop setter: Option<PropGetterOrSetter>
```

功能：获取当前属性声明的 `setter` 方法（若不存在返回 `None`）。

类型：Option\<[PropGetterOrSetter](#class-propgetterorsetter)>

### prop tyAnnotation

```cangjie
public prop tyAnnotation: TypeAnnotation
```

功能：获取当前属性声明的类型标注。

类型：[TypeAnnotation](#class-typeannotation)

### init(Option\<PropGetterOrSetter>, String, Option\<PropGetterOrSetter>, TypeAnnotation, Array\<Annotation>, Array\<Modifier>, Array\<Comment>)

```cangjie
public init(getter: Option<PropGetterOrSetter>, name: String, setter: Option<PropGetterOrSetter>,
    tyAnnotation: TypeAnnotation, annotations!: Array<Annotation> = [], modifiers!: Array<Modifier> = [],
    comments!: Array<Comment> = [])
```

功能：构造一个 [PropDecl](#class-propdecl) 对象，表示属性声明节点。

参数：

- getter: Option\<[PropGetterOrSetter](#class-propgetterorsetter)> - 可选的 getter。
- name: String - 属性名。
- setter: Option\<[PropGetterOrSetter](#class-propgetterorsetter)> - 可选的 setter。
- tyAnnotation: [TypeAnnotation](#class-typeannotation) - 类型注解。
- annotations!: Array\<[Annotation](#class-annotation)> - 附加的注解列表，默认为空数组。
- modifiers!: Array\<[Modifier](#class-modifier)> - 修饰符列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `setter` 存在但 `getter` 不存在，或输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 getter
    let getter = PropGetterOrSetter(Block([]), None, true)

    // 创建 name
    let name = "x"

    // 创建 setter
    let setter = PropGetterOrSetter(Block([]), "v", false)

    // 创建 tyAnnotation
    let tyAnnotation = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 PropDecl 实例
    let propDecl = PropDecl(
        getter, 
        name, 
        setter, 
        tyAnnotation
    )

    println("propDecl: ${propDecl}")
}
```

运行结果：

```text
propDecl: prop x: Int64 {
    get() {
}
    set(v) {
}
}
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取 [PropDecl](#class-propdecl) 节点中标识符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回标识符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 PropDecl 实例
    let getter = PropGetterOrSetter(Block([]), None, true)
    let propDecl = PropDecl(getter, "x", None, AtomicType(AtomicTypeKind.Int64Type))
    let pos = propDecl.getIdentifierPos()

    // 输出标识符位置
    println("propDecl.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
propDecl.getIdentifierPos(): 1:6-1:7
```

### func getLCurlPos()

```cangjie
public func getLCurlPos(): Option<CodePositionRange>
```

功能：获取 [PropDecl](#class-propdecl) 节点中 `{` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `{` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 PropDecl 实例
    let getter = PropGetterOrSetter(Block([]), None, true)
    let propDecl = PropDecl(getter, "x", None, AtomicType(AtomicTypeKind.Int64Type))

    if (let Some(pos) <- propDecl.getLCurlPos()) {
        // 输出左花括号位置
        println("propDecl.getLCurlPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
propDecl.getLCurlPos(): 1:15-1:16
```

### func getPropKeyWordPos()

```cangjie
public func getPropKeyWordPos(): CodePositionRange
```

功能：获取 [PropDecl](#class-propdecl) 节点中 `prop` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `prop` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 PropDecl 实例
    let getter = PropGetterOrSetter(Block([]), None, true)
    let propDecl = PropDecl(getter, "x", None, AtomicType(AtomicTypeKind.Int64Type))
    let pos = propDecl.getPropKeyWordPos()

    // 输出 prop 关键字位置
    println("propDecl.getPropKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
propDecl.getPropKeyWordPos(): 1:1-1:5
```

### func getRCurlPos()

```cangjie
public func getRCurlPos(): Option<CodePositionRange>
```

功能：获取 [PropDecl](#class-propdecl) 节点中 `}` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `}` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 PropDecl 实例
    let getter = PropGetterOrSetter(Block([]), None, true)
    let propDecl = PropDecl(getter, "x", None, AtomicType(AtomicTypeKind.Int64Type))

    if (let Some(pos) <- propDecl.getRCurlPos()) {
        // 输出右花括号位置
        println("propDecl.getRCurlPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
propDecl.getRCurlPos(): 5:1-5:2
```

### func getTyAnnotationColonPos()

```cangjie
public func getTyAnnotationColonPos(): CodePositionRange
```

功能：获取 [PropDecl](#class-propdecl) 节点中返回类型前的 `:` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回返回类型前的 `:` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 PropDecl 实例
    let getter = PropGetterOrSetter(Block([]), None, true)
    let propDecl = PropDecl(getter, "x", None, AtomicType(AtomicTypeKind.Int64Type))
    let pos = propDecl.getTyAnnotationColonPos()

    // 输出冒号位置
    println("propDecl.getTyAnnotationColonPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
propDecl.getTyAnnotationColonPos(): 1:7-1:8
```

## class PropGetterOrSetter

```cangjie
public class PropGetterOrSetter <: Decl {
    public init(block: Block, identifier: Option<String>, isGetter: Bool, annotations!: Array<Annotation> = [],
        comments!: Array<Comment> = [])
}
```

功能：表示一个属性的 `getter` 或 `setter` 声明。

父类型：

- [Decl](#class-decl)

### prop block

```cangjie
public prop block: Block
```

功能：获取当前属性 `getter` 或 `setter` 方法的主体部分。

类型：[Block](#class-block)

### prop identifier

```cangjie
public prop identifier: Option<String>
```

功能：若为 `setter` 方法，则获取当前方法的输入参数，否则返回 None。

类型：Option\<String>

### prop isGetter

```cangjie
public prop isGetter: Bool
```

功能：判断当前属性方法是否为 `getter` 方法。

类型：Bool

### init(Block, Option\<String>, Bool, Array\<Annotation>, Array\<Comment>)

```cangjie
public init(block: Block, identifier: Option<String>, isGetter: Bool, annotations!: Array<Annotation> = [],
    comments!: Array<Comment> = [])
```

功能：构造一个 [PropGetterOrSetter](#class-propgetterorsetter) 对象，表示属性 getter 或 setter 节点。

参数：

- block: [Block](#class-block) - 代码块。
- identifier: Option\<String> - 可选的标识符。
- isGetter: Bool - 是否为 getter。
- annotations!: Array\<[Annotation](#class-annotation)> - 附加的注解列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `isGetter` 为 `true` 但 `annotations` 不为空或 `identifier` 不为空，或 `isGetter` 为 `false` 但 `identifier` 为空或不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let assignOpKind = AssignOpKind.Assign
    let lhs = SymbolRef("variable_", [])
    let rhs = SymbolRef("v", [])

    // 创建 AssignExpr 实例
    let assignExpr = AssignExpr(
        assignOpKind, 
        lhs, 
        rhs
    )

    let nodes: Array<SyntaxTreeNode> = [assignExpr]

    // 创建 Block 实例
    let block = Block(
        nodes
    )

    // 创建 PropGetterOrSetter 实例
    let propSetter = PropGetterOrSetter(
        block,
        Some("v"),
        false
    )

    println("propSetter: ${propSetter}")
}
```

运行结果：

```text
propSetter: set(v) {
    variable_ = v
}
```

### func getGetKeyWordPos()

```cangjie
public func getGetKeyWordPos(): Option<CodePositionRange>
```

功能：获取 [PropGetterOrSetter](#class-propgetterorsetter) 节点中 `get` 关键字的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `get` 关键字的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let assignOpKind = AssignOpKind.Assign
    let lhs = SymbolRef("variable_", [])
    let rhs = SymbolRef("v", [])

    // 创建 AssignExpr 实例
    let assignExpr = AssignExpr(
        assignOpKind, 
        lhs, 
        rhs
    )

    let nodes: Array<SyntaxTreeNode> = [assignExpr]

    // 创建 Block 实例
    let block = Block(
        nodes
    )

    // 创建 PropGetterOrSetter 实例
    let propGetter = PropGetterOrSetter(
        block,
        None, 
        true
    )

    if (let Some(pos) <- propGetter.getGetKeyWordPos()) {
        // 输出 get 关键字位置
        println("propGetter.getGetKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
propGetter.getGetKeyWordPos(): 1:1-1:4
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): Option<CodePositionRange>
```

功能：获取 [PropGetterOrSetter](#class-propgetterorsetter) 节点中标识符的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回标识符的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let assignOpKind = AssignOpKind.Assign
    let lhs = SymbolRef("variable_", [])
    let rhs = SymbolRef("v", [])

    // 创建 AssignExpr 实例
    let assignExpr = AssignExpr(
        assignOpKind, 
        lhs, 
        rhs
    )

    let nodes: Array<SyntaxTreeNode> = [assignExpr]

    // 创建 Block 实例
    let block = Block(
        nodes
    )

    // 创建 PropGetterOrSetter 实例
    let propSetter = PropGetterOrSetter(
        block,
        Some("v"),
        false
    )

    if (let Some(pos) <- propSetter.getIdentifierPos()) {
        // 输出 setter 中标识符位置
        println("propSetter.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
propSetter.getIdentifierPos(): 1:5-1:6
```

### func getLParenPos()

```cangjie
public func getLParenPos(): CodePositionRange
```

功能：获取 [PropGetterOrSetter](#class-propgetterorsetter) 节点中 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let assignOpKind = AssignOpKind.Assign
    let lhs = SymbolRef("variable_", [])
    let rhs = SymbolRef("v", [])

    // 创建 AssignExpr 实例
    let assignExpr = AssignExpr(
        assignOpKind, 
        lhs, 
        rhs
    )

    let nodes: Array<SyntaxTreeNode> = [assignExpr]

    // 创建 Block 实例
    let block = Block(
        nodes
    )

    // 创建 PropGetterOrSetter 实例
    let propSetter = PropGetterOrSetter(
        block,
        Some("v"),
        false
    )

    let pos = propSetter.getLParenPos()
    // 输出 ( 位置
    println("propSetter.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
propSetter.getLParenPos(): 1:4-1:5
```

### func getRParenPos()

```cangjie
public func getRParenPos(): CodePositionRange
```

功能：获取 [PropGetterOrSetter](#class-propgetterorsetter) 节点中 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let assignOpKind = AssignOpKind.Assign
    let lhs = SymbolRef("variable_", [])
    let rhs = SymbolRef("v", [])

    // 创建 AssignExpr 实例
    let assignExpr = AssignExpr(
        assignOpKind, 
        lhs, 
        rhs
    )

    let nodes: Array<SyntaxTreeNode> = [assignExpr]

    // 创建 Block 实例
    let block = Block(
        nodes
    )

    // 创建 PropGetterOrSetter 实例
    let propSetter = PropGetterOrSetter(
        block,
        Some("v"),
        false
    )

    let pos = propSetter.getRParenPos()
    // 输出 ) 位置
    println("propSetter.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
propSetter.getRParenPos(): 1:6-1:7
```

### func getSetKeyWordPos()

```cangjie
public func getSetKeyWordPos(): Option<CodePositionRange>
```

功能：获取 [PropGetterOrSetter](#class-propgetterorsetter) 节点中 `set` 关键字的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `set` 关键字的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let assignOpKind = AssignOpKind.Assign
    let lhs = SymbolRef("variable_", [])
    let rhs = SymbolRef("v", [])

    // 创建 AssignExpr 实例
    let assignExpr = AssignExpr(
        assignOpKind, 
        lhs, 
        rhs
    )

    let nodes: Array<SyntaxTreeNode> = [assignExpr]

    // 创建 Block 实例
    let block = Block(
        nodes
    )

    // 创建 PropGetterOrSetter 实例
    let propSetter = PropGetterOrSetter(
        block,
        Some("v"),
        false
    )

    if (let Some(pos) <- propSetter.getSetKeyWordPos()) {
        // 输出 set 关键字位置
        println("propSetter.getSetKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
propSetter.getSetKeyWordPos(): 1:1-1:4
```

## class QuoteExpr

```cangjie
public class QuoteExpr <: Expr {
    public init(tokensOrRefExpr: Array<QuoteExprContent>, comments!: Array<Comment> = [])
}
```

功能：表示 `quote` 表达式节点。

一个 [QuoteExpr](#class-quoteexpr) 节点： `quote(var ident = 0)`。

父类型：

- [Expr](#class-expr)

### prop tokensOrRefExpr

```cangjie
public prop tokensOrRefExpr: Array<QuoteExprContent>
```

功能：获取 [QuoteExpr](#class-quoteexpr) 中由 `()` 括起的内部引用表达式或 [QuoteToken](#class-quotetoken) 节点。

类型：Array\<[QuoteExprContent](syntax_package_enums.md#enum-quoteexprcontent)>

### init(Array\<QuoteExprContent>, Array\<Comment>)

```cangjie
public init(tokensOrRefExpr: Array<QuoteExprContent>, comments!: Array<Comment> = [])
```

功能：构造一个 [QuoteExpr](#class-quoteexpr) 对象，表示引用表达式，如 `quote( ... )`，内部可混合 Tokens 和插值表达式。

参数：

- tokensOrRefExpr: Array\<[QuoteExprContent](syntax_package_enums.md#enum-quoteexprcontent)> - 引用内容列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 QuoteToken 实例
    let quoteToken = QuoteToken(quote(hello world))

    // 创建 QuoteExpr 实例
    let quoteExpr = QuoteExpr(
        QuoteExprContent.TokenPart(quoteToken)
    )

    println("quoteExpr: ${quoteExpr}")
}
```

运行结果：

```text
quoteExpr: quote(hello world)
```

### func getLParenPos()

```cangjie
public func getLParenPos(): CodePositionRange
```

功能：获取当前 [QuoteExpr](#class-quoteexpr) 中 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 QuoteToken 实例
    let quoteToken = QuoteToken(quote(hello world))

    // 创建 QuoteExpr 实例
    let quoteExpr = QuoteExpr(
        QuoteExprContent.TokenPart(quoteToken)
    )
    
    let pos = quoteExpr.getLParenPos()
    // 输出 ( 位置
    println("quoteExpr.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
quoteExpr.getLParenPos(): 1:6-1:7
```

### func getQuoteKeyWordPos()

```cangjie
public func getQuoteKeyWordPos(): CodePositionRange
```

功能：获取当前 [QuoteExpr](#class-quoteexpr) 中 `quote` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `quote` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 QuoteToken 实例
    let quoteToken = QuoteToken(quote(hello world))

    // 创建 QuoteExpr 实例
    let quoteExpr = QuoteExpr(
        QuoteExprContent.TokenPart(quoteToken)
    )
    
    let pos = quoteExpr.getQuoteKeyWordPos()
    // 输出 quote 关键字位置
    println("quoteExpr.getQuoteKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
quoteExpr.getQuoteKeyWordPos(): 1:1-1:6
```

### func getRParenPos()

```cangjie
public func getRParenPos(): CodePositionRange
```

功能：获取当前 [QuoteExpr](#class-quoteexpr) 中 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 QuoteToken 实例
    let quoteToken = QuoteToken(quote(hello world))

    // 创建 QuoteExpr 实例
    let quoteExpr = QuoteExpr(
        QuoteExprContent.TokenPart(quoteToken)
    )
    
    let pos = quoteExpr.getRParenPos()
    // 输出 ) 位置
    println("quoteExpr.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
quoteExpr.getRParenPos(): 1:18-1:19
```

## class QuoteInterpolationExpr

```cangjie
public class QuoteInterpolationExpr <: Expr {
    public init(expr: Expr, hasParen!: Bool = false, comments!: Array<Comment> = [])
}
```

功能：表示 [QuoteExpr](#class-quoteexpr) 中由 `()` 括起的内部引用表达式， 例如 `$(A.a)` 或 `$a`。

父类型：

- [Expr](#class-expr)

### prop expr

```cangjie
public prop expr: Expr
```

功能：获取 [QuoteInterpolationExpr](#class-quoteinterpolationexpr) 中被引用的表达式。

类型：[Expr](#class-expr)

### init(Expr, Bool, Array\<Comment>)

```cangjie
public init(expr: Expr, hasParen!: Bool = false, comments!: Array<Comment> = [])
```

功能：构造一个 [QuoteInterpolationExpr](#class-quoteinterpolationexpr) 对象，表示 `quote` 中的插值表达式。

参数：

- expr: [Expr](#class-expr) - 被插值的表达式。
- hasParen!: Bool - 是否带有括号，默认为 `false`。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let symbolRef = SymbolRef("a", [])

    // 创建 QuoteInterpolationExpr 实例
    let quoteInterpolationExpr = QuoteInterpolationExpr(
        symbolRef,
        hasParen: false
    )

    println("quoteInterpolationExpr: ${quoteInterpolationExpr}")
}
```

运行结果：

```text
quoteInterpolationExpr: $a
```

### func getDollarPos()

```cangjie
public func getDollarPos(): CodePositionRange
```

功能：获取当前 [QuoteInterpolationExpr](#class-quoteinterpolationexpr) 中 `$` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `$` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let symbolRef = SymbolRef("a", [])

    // 创建 QuoteInterpolationExpr 实例
    let quoteInterpolationExpr = QuoteInterpolationExpr(
        symbolRef,
        hasParen: false
    )
    
    let pos = quoteInterpolationExpr.getDollarPos()
    // 输出 $ 位置
    println("quoteInterpolationExpr.getDollarPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
quoteInterpolationExpr.getDollarPos(): 1:1-1:2
```

### func getLParenPos()

```cangjie
public func getLParenPos(): Option<CodePositionRange>
```

功能：获取当前 [QuoteInterpolationExpr](#class-quoteinterpolationexpr) 中 `(` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `(` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let symbolRef = SymbolRef("a", [])

    // 创建 QuoteInterpolationExpr 实例
    let quoteInterpolationExpr = QuoteInterpolationExpr(
        symbolRef,
        hasParen: true
    )
    
    if (let Some(pos) <- quoteInterpolationExpr.getLParenPos()) {
        // 输出 ( 位置
        println("quoteInterpolationExpr.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
quoteInterpolationExpr.getLParenPos(): 1:2-1:3
```

### func getRParenPos()

```cangjie
public func getRParenPos(): Option<CodePositionRange>
```

功能：获取当前 [QuoteInterpolationExpr](#class-quoteinterpolationexpr) 中 `)` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `)` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let symbolRef = SymbolRef("a", [])

    // 创建 QuoteInterpolationExpr 实例
    let quoteInterpolationExpr = QuoteInterpolationExpr(
        symbolRef,
        hasParen: true
    )
    
    if (let Some(pos) <- quoteInterpolationExpr.getRParenPos()) {
        // 输出 ) 位置
        println("quoteInterpolationExpr.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
quoteInterpolationExpr.getRParenPos(): 1:4-1:5
```

## class QuoteToken

```cangjie
public class QuoteToken <: SyntaxTreeNode {
    public init(content: Tokens, comments!: Array<Comment> = [])
}
```

功能：表示 `quote` 表达式节点内任意合法的 `token`。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop content

```cangjie
public prop content: Tokens
```

功能：获取 [QuoteToken](#class-quotetoken) 内的 Tokens。

类型：Tokens

### init(Tokens, Array\<Comment>)

```cangjie
public init(content: Tokens, comments!: Array<Comment> = [])
```

功能：构造一个 [QuoteToken](#class-quotetoken) 对象，表示 `quote` 表达式节点内任意合法的 `token`。

参数：

- content: Tokens - 被引用的标记序列，会被格式化。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当格式化过程中内存分配失败时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let tokens = quote(hello world)
    
    // 创建 QuoteToken 实例
    let quoteToken = QuoteToken(tokens)

    println("quoteToken: ${quoteToken}")
}
```

运行结果：

```text
quoteToken: hello world
```

## class RangeExpr

```cangjie
public class RangeExpr <: Expr {
    public init(start: Option<Expr>, kind: RangeKind, end: Option<Expr>, step: Option<Expr>, comments!: Array<Comment> = [])
}
```

功能：表示包含区间操作符的表达式。

[RangeExpr](#class-rangeexpr) 节点：存在两种 `Range` 操作符：`..` 和 `..=`，分别用于创建左闭右开和左闭右闭的 `Range` 实例。它们的使用方式分别为 `start..end:step` 和 `start..=end:step`。

父类型：

- [Expr](#class-expr)

### prop end

```cangjie
public prop end: Option<Expr>
```

功能：获取 [RangeExpr](#class-rangeexpr) 中的终止值。

类型：Option\<[Expr](#class-expr)>

### prop kind

```cangjie
public prop kind: RangeKind
```

功能：获取 [RangeExpr](#class-rangeexpr) 的类型。

类型：[RangeKind](syntax_package_enums.md#enum-rangekind)

### prop start

```cangjie
public prop start: Option<Expr>
```

功能：获取 [RangeExpr](#class-rangeexpr) 中的起始值。

类型：Option\<[Expr](#class-expr)>

### prop step

```cangjie
public prop step: Option<Expr>
```

功能：获取 [RangeExpr](#class-rangeexpr) 中的步长表达式。

类型：Option\<[Expr](#class-expr)>

### init(Option\<Expr>, RangeKind, Option\<Expr>, Option\<Expr>, Array\<Comment>)

```cangjie
public init(start: Option<Expr>, kind: RangeKind, end: Option<Expr>, step: Option<Expr>, comments!: Array<Comment> = [])
```

功能：构造一个 [RangeExpr](#class-rangeexpr) 对象，表示区间表达式，如 `1..10` 或 `1..=10`。

参数：

- start: Option\<[Expr](#class-expr)> - 区间起始表达式。
- kind: [RangeKind](syntax_package_enums.md#enum-rangekind) - 区间类型（开区间或闭区间）。
- end: Option\<[Expr](#class-expr)> - 区间结束表达式。
- step: Option\<[Expr](#class-expr)> - 可选的步长表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let kind = LitConstKind.IntergerLiteral
    let rawValue0 = "1"
    let rawValue1 = "100"
    let rawValue2 = "2"

    // 创建 LitConstExpr 实例
    let litConstExpr0 = LitConstExpr(
        kind, 
        rawValue0
    )
    let litConstExpr1 = LitConstExpr(
        kind, 
        rawValue1
    )
    let litConstExpr2 = LitConstExpr(
        kind, 
        rawValue2
    )

    let rangeKind = RangeKind.ClosedRangeOp

    // 创建 RangeExpr 实例
    let rangeExpr = RangeExpr(
        litConstExpr0,
        rangeKind,
        litConstExpr1,
        litConstExpr2
    )

    println("rangeExpr: ${rangeExpr}")
}
```

运行结果：

```text
rangeExpr: 1..=100 : 2
```

### func getColonPos()

```cangjie
public func getColonPos(): Option<CodePositionRange>
```

功能：获取 `:` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `:` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let kind = LitConstKind.IntergerLiteral
    let rawValue0 = "1"
    let rawValue1 = "100"
    let rawValue2 = "2"

    // 创建 LitConstExpr 实例
    let litConstExpr0 = LitConstExpr(
        kind, 
        rawValue0
    )
    let litConstExpr1 = LitConstExpr(
        kind, 
        rawValue1
    )
    let litConstExpr2 = LitConstExpr(
        kind, 
        rawValue2
    )

    let rangeKind = RangeKind.ClosedRangeOp

    // 创建 RangeExpr 实例
    let rangeExpr = RangeExpr(
        litConstExpr0,
        rangeKind,
        litConstExpr1,
        litConstExpr2
    )

    if (let Some(pos) <- rangeExpr.getColonPos()) {
        // 输出 : 位置
        println("rangeExpr.getColonPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
rangeExpr.getColonPos(): 1:9-1:10
```

### func getRangeOpPos()

```cangjie
public func getRangeOpPos(): CodePositionRange
```

功能：获取 `..` 或 `..=` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `..` 或 `..=` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let kind = LitConstKind.IntergerLiteral
    let rawValue0 = "1"
    let rawValue1 = "100"
    let rawValue2 = "2"

    // 创建 LitConstExpr 实例
    let litConstExpr0 = LitConstExpr(
        kind, 
        rawValue0
    )
    let litConstExpr1 = LitConstExpr(
        kind, 
        rawValue1
    )
    let litConstExpr2 = LitConstExpr(
        kind, 
        rawValue2
    )

    let rangeKind = RangeKind.ClosedRangeOp

    // 创建 RangeExpr 实例
    let rangeExpr = RangeExpr(
        litConstExpr0,
        rangeKind,
        litConstExpr1,
        litConstExpr2
    )

    let pos = rangeExpr.getRangeOpPos()
    // 输出 .. 位置
    println("rangeExpr.getRangeOpPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
rangeExpr.getRangeOpPos(): 1:2-1:5
```

## class ReturnExpr

```cangjie
public class ReturnExpr <: Expr {
    public init(retVal: Option<Expr>, comments!: Array<Comment> = [])
}
```

功能：表示 `return` 表达式节点。

一个 [ReturnExpr](#class-returnexpr) 节点：`return 1`。

父类型：

- [Expr](#class-expr)

### prop retVal

```cangjie
public prop retVal: Option<Expr>
```

功能：获取当前 `return` 语句的返回值表达式（若不存在返回 `None`）。

类型：Option\<[Expr](#class-expr)>

### init(Option\<Expr>, Array\<Comment>)

```cangjie
public init(retVal: Option<Expr>, comments!: Array<Comment> = [])
```

功能：构造一个 [ReturnExpr](#class-returnexpr) 对象，表示 `return` 表达式，可带返回值。

参数：

- retVal: Option\<[Expr](#class-expr)> - 可选的返回值表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let kind = LitConstKind.FloatLiteral
    let rawValue = "3.14"

    // 创建 LitConstExpr 实例
    let litConstExpr = LitConstExpr(
        kind, 
        rawValue
    )

    // 创建 ReturnExpr 实例
    let returnExpr = ReturnExpr(
        Some(litConstExpr)
    )

    println("returnExpr: ${returnExpr}")
}
```

运行结果：

```text
returnExpr: return 3.14
```

### func getReturnKeyWordPos()

```cangjie
public func getReturnKeyWordPos(): CodePositionRange
```

功能：获取 `return` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `return` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let kind = LitConstKind.FloatLiteral
    let rawValue = "3.14"

    // 创建 LitConstExpr 实例
    let litConstExpr = LitConstExpr(
        kind, 
        rawValue
    )

    // 创建 ReturnExpr 实例
    let returnExpr = ReturnExpr(
        Some(litConstExpr)
    )
    
    let pos = returnExpr.getReturnKeyWordPos()
    // 输出 return 关键字位置
    println("returnExpr.getReturnKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
returnExpr.getReturnKeyWordPos(): 1:1-1:7
```

## class SourceFile

```cangjie
public class SourceFile <: SyntaxTreeNode {
    public init(importLists: Array<ImportList>, name: String, path: String, pkgHeader: Option<PackageHeader>, topLevelDecls: Array<Decl>,
        ftrDirective!: Option<FeaturesDirective> = None, comments!: Array<Comment> = [])
}
```

功能：表示单个仓颉源码文件的语法树节点。

一个仓颉源码文件节点主要包括包声明节点，包导入节点和 TopLevel 作用域内的所有声明节点。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop ftrDirective

```cangjie
public prop ftrDirective: Option<FeaturesDirective> 
```

功能：在源码文件节点中找到 [FeaturesDirective](#class-featuresdirective) 节点。

类型： Option\<[FeaturesDirective](#class-featuresdirective)>

### prop importLists

```cangjie
public prop importLists: Array<ImportList>
```

功能：获取仓颉源码文件中包导入节点 [ImportList](#class-importlist) 的列表。

类型：Array\<[ImportList](#class-importlist)>

### prop name

```cangjie
public prop name: String
```

功能：获取仓颉源码文件的名称。

类型：String

### prop path

```cangjie
public prop path: String
```

功能：获取仓颉源码文件的绝对路径。

类型：String

### prop pkgHeader

```cangjie
public prop pkgHeader: Option<PackageHeader>
```

功能：获取仓颉源码文件中包的声明节点 [PackageHeader](#class-packageheader)。

类型：Option\<[PackageHeader](#class-packageheader)>

### prop topLevelDecls

```cangjie
public prop topLevelDecls: Array<Decl>
```

功能：获取仓颉源码文件中 `TopLevel` 作用域内声明的声明节点列表。

类型：Array\<[Decl](#class-decl)>

### init(Array\<ImportList>, String, String, Option\<PackageHeader>, Array\<Decl>, Option\<FeaturesDirective>, Array\<Comment>)

```cangjie
public init(importLists: Array<ImportList>, name: String, path: String, pkgHeader: Option<PackageHeader>, topLevelDecls: Array<Decl>,
    ftrDirective!: Option<FeaturesDirective> = None, comments!: Array<Comment> = [])
```

功能：构造一个 [SourceFile](#class-sourcefile) 对象，表示语法树中的源文件节点。

参数：

- importLists: Array\<[ImportList](#class-importlist)> - 导入列表。
- name: String - 源文件名。
- path: String - 源文件路径。
- pkgHeader: Option\<[PackageHeader](#class-packageheader)> - 包声明头，可选。
- topLevelDecls: Array\<[Decl](#class-decl)> - 顶层声明列表。
- ftrDirective!: Option\<FeaturesDirective> - 特性指令，默认为 `None`。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let contents = ImportSingle(["pkg"], "a")

    // 创建 ImportList 实例
    let importList = ImportList(
        contents, 
        None
    )

    let isMacroPkg = false
    let packageNameIdentifiers = ["A"]

    // 创建 PackageHeader 实例
    let packageHeader = PackageHeader(
        None, 
        isMacroPkg,
        packageNameIdentifiers
    )

    let body = Block([ReturnExpr(None)])
    let params = ParameterList([])
    let retTyAnnotation = AtomicType(UnitType)

    // 创建 MainDecl 实例
    let mainDecl = MainDecl(
        body, 
        params, 
        retTyAnnotation
    )

    let name = "sourceFile.cj"
    let path = "/path/to/sourceFile.cj"

    // 创建 SourceFile 实例
    let sourceFile = SourceFile(
        [importList],
        name,
        path,
        Some(packageHeader),
        [mainDecl]
    )

    println("sourceFile: ${sourceFile}")
}
```

运行结果：

```text
sourceFile: package A
import pkg.a
main(): Unit {
    return
}

```

## class SpawnExpr

```cangjie
public class SpawnExpr <: Expr {
    public init(threadContext: Option<Expr>, trailingLambdaExpr: Lambda, comments!: Array<Comment> = [])
}
```

功能：表示 `Spawn` 表达式。

一个 [SpawnExpr](#class-spawnexpr) 节点由 `spawn` 关键字和一个不包含形参的闭包组成，例如：`spawn { add(1, 2) }`。

父类型：

- [Expr](#class-expr)

### prop threadContext

```cangjie
public prop threadContext: Option<Expr>
```

功能：获取当前 `Spawn` 语句的线程执行上下文（若不存在返回 `None`）。

类型：Option\<[Expr](#class-expr)>

### prop trailingLambdaExpr

```cangjie
public prop trailingLambdaExpr: Lambda
```

功能：获取当前 `Spawn` 语句的线程执行代码块。

类型：[Lambda](#class-lambda)

### init(Option\<Expr>, Lambda, Array\<Comment>)

```cangjie
public init(threadContext: Option<Expr>, trailingLambdaExpr: Lambda, comments!: Array<Comment> = [])
```

功能：构造一个 [SpawnExpr](#class-spawnexpr) 对象，表示 `spawn` 表达式，用于创建线程。

参数：

- threadContext: Option\<[Expr](#class-expr)> - 可选的线程上下文表达式。
- trailingLambdaExpr: [Lambda](#class-lambda) - 线程体 lambda 表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 LitConstExpr 实例
    let litConstExpr = LitConstExpr(
        LitConstKind.FloatLiteral, 
        "3.14"
    )

    // 创建 Lambda 实例
    let lambda = Lambda(
        [litConstExpr],
        ParameterList([], hasParen: false)
    )

    let symbolRef = SymbolRef("context", [])

    // 创建 SpawnExpr 实例
    let spawnExpr = SpawnExpr(
        Some(symbolRef),
        lambda
    )

    println("spawnExpr: ${spawnExpr}")
}
```

运行结果：

```text
spawnExpr: spawn (context) {  => 3.14 }
```

### func getSpawnKeyWordPos()

```cangjie
public func getSpawnKeyWordPos(): CodePositionRange
```

功能：获取 [SpawnExpr](#class-spawnexpr) 节点中 `spawn` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `spawn` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 LitConstExpr 实例
    let litConstExpr = LitConstExpr(
        LitConstKind.FloatLiteral, 
        "3.14"
    )

    // 创建 Lambda 实例
    let lambda = Lambda(
        [litConstExpr],
        ParameterList([], hasParen: false)
    )

    let symbolRef = SymbolRef("context", [])

    // 创建 SpawnExpr 实例
    let spawnExpr = SpawnExpr(
        Some(symbolRef),
        lambda
    )
    
    let pos = spawnExpr.getSpawnKeyWordPos()
    // 输出 spawn 关键字位置
    println("spawnExpr.getSpawnKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
spawnExpr.getSpawnKeyWordPos(): 1:1-1:6
```

### func getThreadContextLParenPos()

```cangjie
public func getThreadContextLParenPos(): Option<CodePositionRange>
```

功能：获取 [SpawnExpr](#class-spawnexpr) 节点中线程上下文的 `(` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `return` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 LitConstExpr 实例
    let litConstExpr = LitConstExpr(
        LitConstKind.FloatLiteral, 
        "3.14"
    )

    // 创建 Lambda 实例
    let lambda = Lambda(
        [litConstExpr],
        ParameterList([], hasParen: false)
    )

    let symbolRef = SymbolRef("context", [])

    // 创建 SpawnExpr 实例
    let spawnExpr = SpawnExpr(
        Some(symbolRef),
        lambda
    )
    
    if (let Some(pos) <- spawnExpr.getThreadContextLParenPos()) {
        // 输出线程上下文参数 ( 位置
        println("spawnExpr.getThreadContextLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
spawnExpr.getThreadContextLParenPos(): 1:7-1:8
```

### func getThreadContextRParenPos()

```cangjie
public func getThreadContextRParenPos(): Option<CodePositionRange>
```

功能：获取 [SpawnExpr](#class-spawnexpr) 节点中线程上下文的 `)` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回线程上下文的 `)` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 LitConstExpr 实例
    let litConstExpr = LitConstExpr(
        LitConstKind.FloatLiteral, 
        "3.14"
    )

    // 创建 Lambda 实例
    let lambda = Lambda(
        [litConstExpr],
        ParameterList([], hasParen: false)
    )

    let symbolRef = SymbolRef("context", [])

    // 创建 SpawnExpr 实例
    let spawnExpr = SpawnExpr(
        Some(symbolRef),
        lambda
    )
    
    if (let Some(pos) <- spawnExpr.getThreadContextRParenPos()) {
        // 输出线程上下文参数 ) 位置
        println("spawnExpr.getThreadContextRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
spawnExpr.getThreadContextRParenPos(): 1:15-1:16
```

## class StaticInit

```cangjie
public class StaticInit <: Decl {
    public init(body: Block, comments!: Array<Comment> = [])
}
```

功能：表示一个静态初始化器。

父类型：

- [Decl](#class-decl)

### prop body

```cangjie
public prop body: Block
```

功能：获取当前静态初始化器的主体部分。

类型：[Block](#class-block)

### init(Block, Array\<Comment>)

```cangjie
public init(body: Block, comments!: Array<Comment> = [])
```

功能：构造一个 [StaticInit](#class-staticinit) 对象，表示静态初始化器节点。

参数：

- body: [Block](#class-block) - 静态初始化代码块。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let assignOpKind = AssignOpKind.Assign
    let lhs = SymbolRef("variable_", [])
    let rhs = LitConstExpr(LitConstKind.FloatLiteral, "3.14")

    // 创建 AssignExpr 实例
    let assignExpr = AssignExpr(
        assignOpKind, 
        lhs, 
        rhs
    )

    // 创建 Block 实例
    let block = Block([assignExpr])

    // 创建 StaticInit 实例
    let staticInit = StaticInit(block)

    println("staticInit: ${staticInit}")
}
```

运行结果：

```text
staticInit: static init() {
    variable_ = 3.14
}
```

### func getInitKeyWordPos()

```cangjie
public func getInitKeyWordPos(): CodePositionRange
```

功能：获取 [StaticInit](#class-staticinit) 节点中 `init` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `init` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let assignOpKind = AssignOpKind.Assign
    let lhs = SymbolRef("variable_", [])
    let rhs = LitConstExpr(LitConstKind.FloatLiteral, "3.14")

    // 创建 AssignExpr 实例
    let assignExpr = AssignExpr(
        assignOpKind, 
        lhs, 
        rhs
    )

    // 创建 Block 实例
    let block = Block([assignExpr])

    // 创建 StaticInit 实例
    let staticInit = StaticInit(block)
    
    let pos = staticInit.getInitKeyWordPos()
    // 输出 init 关键字位置
    println("staticInit.getInitKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
staticInit.getInitKeyWordPos(): 1:8-1:12
```

### func getParamsLParenPos()

```cangjie
public func getParamsLParenPos(): CodePositionRange
```

功能：获取 [StaticInit](#class-staticinit) 节点中参数左括号的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回参数左括号的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let assignOpKind = AssignOpKind.Assign
    let lhs = SymbolRef("variable_", [])
    let rhs = LitConstExpr(LitConstKind.FloatLiteral, "3.14")

    // 创建 AssignExpr 实例
    let assignExpr = AssignExpr(
        assignOpKind, 
        lhs, 
        rhs
    )

    // 创建 Block 实例
    let block = Block([assignExpr])

    // 创建 StaticInit 实例
    let staticInit = StaticInit(block)
    
    let pos = staticInit.getParamsLParenPos()
    // 输出 ( 位置
    println("staticInit.getParamsLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
staticInit.getParamsLParenPos(): 1:12-1:13
```

### func getParamsRParenPos()

```cangjie
public func getParamsRParenPos(): CodePositionRange
```

功能：获取 [StaticInit](#class-staticinit) 节点中参数右括号的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回参数右括号的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let assignOpKind = AssignOpKind.Assign
    let lhs = SymbolRef("variable_", [])
    let rhs = LitConstExpr(LitConstKind.FloatLiteral, "3.14")

    // 创建 AssignExpr 实例
    let assignExpr = AssignExpr(
        assignOpKind, 
        lhs, 
        rhs
    )

    // 创建 Block 实例
    let block = Block([assignExpr])

    // 创建 StaticInit 实例
    let staticInit = StaticInit(block)
    
    let pos = staticInit.getParamsRParenPos()
    // 输出 ) 位置
    println("staticInit.getParamsRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
staticInit.getParamsRParenPos(): 1:13-1:14
```

### func getStaticKeyWordPos()

```cangjie
public func getStaticKeyWordPos(): CodePositionRange
```

功能：获取 [StaticInit](#class-staticinit) 节点中 `static` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `static` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let assignOpKind = AssignOpKind.Assign
    let lhs = SymbolRef("variable_", [])
    let rhs = LitConstExpr(LitConstKind.FloatLiteral, "3.14")

    // 创建 AssignExpr 实例
    let assignExpr = AssignExpr(
        assignOpKind, 
        lhs, 
        rhs
    )

    // 创建 Block 实例
    let block = Block([assignExpr])

    // 创建 StaticInit 实例
    let staticInit = StaticInit(block)
    
    let pos = staticInit.getStaticKeyWordPos()
    // 输出 static 关键字位置
    println("staticInit.getStaticKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
staticInit.getStaticKeyWordPos(): 1:1-1:7
```

## class StrInterpolationContent

```cangjie
public class StrInterpolationContent <: SyntaxTreeNode {
    public init(interpolationBlock: Block, comments!: Array<Comment> = [])
}
```

功能：表示字符串插值内容的节点。

一个 [StrInterpolationContent](#class-strinterpolationcontent) 节点：`prop str = "hello ${str}"` 中的 `${str}`。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

### prop interpolationBlock

```cangjie
public prop interpolationBlock: Block
```

功能：获取当前字符串插值内容的插值块。

类型：[Block](#class-block)

### init(Block, Array\<Comment>)

```cangjie
public init(interpolationBlock: Block, comments!: Array<Comment> = [])
```

功能：构造一个 [StrInterpolationContent](#class-strinterpolationcontent) 对象，表示字符串插值内容。

参数：

- interpolationBlock: [Block](#class-block) - 插值代码块。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 interpolationBlock
    let interpolationBlock = Block(SymbolRef("str", []))

    // 创建 StrInterpolationContent 实例
    let strInterpolationContent = StrInterpolationContent(interpolationBlock)

    println("strInterpolationContent: ${strInterpolationContent}")
}
```

运行结果：

```text
strInterpolationContent: ${str}
```

### func getDollarPos()

```cangjie
public func getDollarPos(): CodePositionRange
```

功能：获取 [StrInterpolationContent](#class-strinterpolationcontent) 节点中 `$` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `$` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 interpolationBlock
    let interpolationBlock = Block(SymbolRef("str", []))

    // 创建 StrInterpolationContent 实例
    let strInterpolationContent = StrInterpolationContent(interpolationBlock)
    let pos = strInterpolationContent.getDollarPos()

    // 输出 $ 关键字位置
    println("strInterpolationContent.getDollarPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
strInterpolationContent.getDollarPos(): 1:1-1:2
```

## class StructDecl

```cangjie
public class StructDecl <: Decl {
    public init(body: Body, genericConstraints: Option<GenericConstraints>, genericParams: Array<GenericParam>,
        name: String, superTyAnnotations: Array<TypeAnnotation>, annotations!: Array<Annotation> = [],
        modifiers!: Array<Modifier> = [], comments!: Array<Comment> = [])
}
```

功能：表示一个 `Struct` 声明节点。

Struct 的声明使用 `struct` 关键字，声明依次为：可缺省的修饰符、`struct` 关键字、`struct` 名、可选的类型参数、是否指定父接口、可选的泛型约束、`struct` 体的声明。

父类型：

- [Decl](#class-decl)

### prop body

```cangjie
public prop body: Body
```

功能：获取当前结构体声明的主体部分。

类型：[Body](#class-body)

### prop genericConstraints

```cangjie
public prop genericConstraints: Option<GenericConstraints>
```

功能：获取当前结构体声明的泛型约束（若不存在返回 `None`）。

类型：Option\<[GenericConstraints](#class-genericconstraints)>

### prop genericParams

```cangjie
public prop genericParams: Array<GenericParam>
```

功能：获取当前结构体声明的泛型参数列表。

类型：Array\<[GenericParam](#class-genericparam)>

### prop name

```cangjie
public prop name: String
```

功能：获取当前结构体声明的名称。

类型：String

### prop superTyAnnotations

```cangjie
public prop superTyAnnotations: Array<TypeAnnotation>
```

功能：获取当前结构体声明的父类类型标注列表。

类型：Array\<[TypeAnnotation](#class-typeannotation)>

### init(Body, Option\<GenericConstraints>, Array\<GenericParam>, String, Array\<TypeAnnotation>, Array\<Annotation>, Array\<Modifier>, Array\<Comment>)

```cangjie
public init(body: Body, genericConstraints: Option<GenericConstraints>, genericParams: Array<GenericParam>,
    name: String, superTyAnnotations: Array<TypeAnnotation>, annotations!: Array<Annotation> = [],
    modifiers!: Array<Modifier> = [], comments!: Array<Comment> = [])
```

功能：构造一个 [StructDecl](#class-structdecl) 对象，表示结构体声明节点。

参数：

- body: [Body](#class-body) - 结构体，包含各类声明。
- genericConstraints: Option\<[GenericConstraints](#class-genericconstraints)> - 可选的泛型约束。
- genericParams: Array\<[GenericParam](#class-genericparam)> - 泛型参数列表。
- name: String - 结构体名。
- superTyAnnotations: Array\<[TypeAnnotation](#class-typeannotation)> - 父类类型标注列表。
- annotations!: Array\<[Annotation](#class-annotation)> - 附加的注解列表，默认为空数组。
- modifiers!: Array\<[Modifier](#class-modifier)> - 修饰符列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `body` 中有除静态初始化器、函数声明、变量声明、宏展开声明和属性声明外的声明，或泛型约束与泛型参数不对应，或输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 annotations
    let annotations = [Annotation([Argument(None, false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))], "MyAnno", AtOpKind.At)]
    
    // 创建 modifiers
    let modifiers = [Modifier(ModifierKind.Public)]
    
    // 创建 StructDecl 实例
    let structDecl = StructDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations, 
        annotations: annotations, 
        modifiers: modifiers
    )

    println("structDecl: ${structDecl}")
}
```

运行结果：

```text
structDecl: @MyAnno[123]
public struct A<T> <: I1 where T<:I1 {
}
```

### func getGenericParamsCommasPos()

```cangjie
public func getGenericParamsCommasPos(): Array<CodePositionRange>
```

功能：获取 [StructDecl](#class-structdecl) 节点中泛型参数中 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数中 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T"), GenericParam("U")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 annotations
    let annotations = [Annotation([Argument(None, false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))], "MyAnno", AtOpKind.At)]
    
    // 创建 modifiers
    let modifiers = [Modifier(ModifierKind.Public)]
    
    // 创建 StructDecl 实例
    let structDecl = StructDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations, 
        annotations: annotations, 
        modifiers: modifiers
    )

    let pos = structDecl.getGenericParamsCommasPos()
    // 遍历输出泛型参数中逗号位置
    for (i in 0..pos.size) {
        println("structDecl.getGenericParamsCommasPos()[${i}]: ${pos[i].beginLine}:${pos[i].beginColumn}-${pos[i].endLine}:${pos[i].endColumn}")
    }
}
```

运行结果：

```text
structDecl.getGenericParamsCommasPos()[0]: 2:18-2:19
```

### func getGenericParamsLAnglePos()

```cangjie
public func getGenericParamsLAnglePos(): Option<CodePositionRange>
```

功能：获取 [StructDecl](#class-structdecl) 节点中泛型参数的 `<` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数的 `<` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 annotations
    let annotations = [Annotation([Argument(None, false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))], "MyAnno", AtOpKind.At)]
    
    // 创建 modifiers
    let modifiers = [Modifier(ModifierKind.Public)]
    
    // 创建 StructDecl 实例
    let structDecl = StructDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations, 
        annotations: annotations, 
        modifiers: modifiers
    )

    if (let Some(pos) <- structDecl.getGenericParamsLAnglePos()) {
        // 输出泛型参数 < 位置
        println("structDecl.getGenericParamsLAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
structDecl.getGenericParamsLAnglePos(): 2:16-2:17
```

### func getGenericParamsRAnglePos()

```cangjie
public func getGenericParamsRAnglePos(): Option<CodePositionRange>
```

功能：获取 [StructDecl](#class-structdecl) 节点中泛型参数的 `>` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回泛型参数的 `>` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 annotations
    let annotations = [Annotation([Argument(None, false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))], "MyAnno", AtOpKind.At)]
    
    // 创建 modifiers
    let modifiers = [Modifier(ModifierKind.Public)]
    
    // 创建 StructDecl 实例
    let structDecl = StructDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations, 
        annotations: annotations, 
        modifiers: modifiers
    )

    if (let Some(pos) <- structDecl.getGenericParamsRAnglePos()) {
        // 输出泛型参数 > 位置
        println("structDecl.getGenericParamsRAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
structDecl.getGenericParamsRAnglePos(): 2:18-2:19
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取 [StructDecl](#class-structdecl) 节点中标识符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回泛型参数的 `<` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 annotations
    let annotations = [Annotation([Argument(None, false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))], "MyAnno", AtOpKind.At)]
    
    // 创建 modifiers
    let modifiers = [Modifier(ModifierKind.Public)]
    
    // 创建 StructDecl 实例
    let structDecl = StructDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations, 
        annotations: annotations, 
        modifiers: modifiers
    )

    let pos = structDecl.getIdentifierPos()
    // 获取标识符位置
    println("structDecl.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
structDecl.getIdentifierPos(): 2:15-2:16
```

### func getStructKeyWordPos()

```cangjie
public func getStructKeyWordPos(): CodePositionRange
```

功能：获取 [StructDecl](#class-structdecl) 节点中 `struct` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `struct` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 annotations
    let annotations = [Annotation([Argument(None, false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))], "MyAnno", AtOpKind.At)]
    
    // 创建 modifiers
    let modifiers = [Modifier(ModifierKind.Public)]
    
    // 创建 StructDecl 实例
    let structDecl = StructDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations, 
        annotations: annotations, 
        modifiers: modifiers
    )

    let pos = structDecl.getStructKeyWordPos()
    // 获取 struct 关键字位置
    println("structDecl.getStructKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
structDecl.getStructKeyWordPos(): 2:8-2:14
```

### func getSuperTyAnnotationsBitAndsPos()

```cangjie
public func getSuperTyAnnotationsBitAndsPos(): Array<CodePositionRange>
```

功能：获取 [StructDecl](#class-structdecl) 节点中父类型中 `&` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回父类型中 `&` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], []), CompositeType("I2", [], [])]
    
    // 创建 annotations
    let annotations = [Annotation([Argument(None, false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))], "MyAnno", AtOpKind.At)]
    
    // 创建 modifiers
    let modifiers = [Modifier(ModifierKind.Public)]
    
    // 创建 StructDecl 实例
    let structDecl = StructDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations, 
        annotations: annotations, 
        modifiers: modifiers
    )

    let bitAndsPos = structDecl.getSuperTyAnnotationsBitAndsPos()
    // 遍历输出父类型 & 位置
    for (i in 0..bitAndsPos.size) {
        println("structDecl.getSuperTyAnnotationsBitAndsPos()[${i}]: ${bitAndsPos[i].beginLine}:${bitAndsPos[i].beginColumn}-${bitAndsPos[i].endLine}:${bitAndsPos[i].endColumn}")
    }
}
```

运行结果：

```text
structDecl.getSuperTyAnnotationsBitAndsPos()[0]: 2:26-2:27
```

### func getUpperBoundPos()

```cangjie
public func getUpperBoundPos(): Option<CodePositionRange>
```

功能：获取 [StructDecl](#class-structdecl) 节点中 `<:` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `<:` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 body
    let body = Body([])
    
    // 创建 genericConstraints
    let genericConstraints = GenericConstraints([GenericConstraint(CompositeType("T", [], []), [CompositeType("I1", [], [])])])
    
    // 创建 genericParams
    let genericParams = [GenericParam("T")]
    
    // 创建 name
    let name = "A"
    
    // 创建 superTyAnnotations
    let superTyAnnotations: Array<TypeAnnotation> = [CompositeType("I1", [], [])]
    
    // 创建 annotations
    let annotations = [Annotation([Argument(None, false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))], "MyAnno", AtOpKind.At)]
    
    // 创建 modifiers
    let modifiers = [Modifier(ModifierKind.Public)]
    
    // 创建 StructDecl 实例
    let structDecl = StructDecl(
        body, 
        genericConstraints, 
        genericParams, 
        name, 
        superTyAnnotations, 
        annotations: annotations, 
        modifiers: modifiers
    )

    if (let Some(pos) <- structDecl.getUpperBoundPos()) {
        // 输出 <: 位置
        println("structDecl.getUpperBoundPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
structDecl.getUpperBoundPos(): 2:20-2:22
```

## class SubscriptExpr

```cangjie
public class SubscriptExpr <: Expr {
    public init(base: Expr, indexs: Array<Expr>, comments!: Array<Comment> = [])
}
```

功能：表示索引访问表达式。

[SubscriptExpr](#class-subscriptexpr) 节点：用于那些支持索引访问的类型（包括 `Array` 类型和 `Tuple` 类型）通过下标来访问其具体位置的元素，如 `arr[0]`。

父类型：

- [Expr](#class-expr)

### prop base

```cangjie
public prop base: Expr
```

功能：获取当前下标表达式的基表达式，即被访问的数据结构。

类型：[Expr](#class-expr)

### prop indexs

```cangjie
public prop indexs: Array<Expr>
```

功能：获取当前下标表达式的索引表达式数组。

类型：Array\<[Expr](#class-expr)>

### init(Expr, Array\<Expr>, Array\<Comment>)

```cangjie
public init(base: Expr, indexs: Array<Expr>, comments!: Array<Comment> = [])
```

功能：构造一个 [SubscriptExpr](#class-subscriptexpr) 对象，表示下标访问表达式，如 `arr[i]`。

参数：

- base: [Expr](#class-expr) - 被索引的基础表达式。
- indexs: Array\<[Expr](#class-expr)> - 索引表达式列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `indexs` 为空时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 base
    let base = SymbolRef("arr", [])

    // 创建 indexs
    let indexs: Array<Expr> = [
        LitConstExpr(LitConstKind.IntergerLiteral, "1"),
        LitConstExpr(LitConstKind.IntergerLiteral, "2")
    ]

    // 创建 SubscriptExpr 实例
    let subscriptExpr = SubscriptExpr(
        base, 
        indexs
    )

    println("subscriptExpr: ${subscriptExpr}")
}
```

运行结果：

```text
subscriptExpr: arr[1, 2]
```

### func getCommasPos()

```cangjie
public func getCommasPos(): Array<CodePositionRange>
```

功能：获取当前 [SubscriptExpr](#class-subscriptexpr) 的下标中所有 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回下标中所有 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 base
    let base = SymbolRef("arr", [])

    // 创建 indexs
    let indexs: Array<Expr> = [
        LitConstExpr(LitConstKind.IntergerLiteral, "1"),
        LitConstExpr(LitConstKind.IntergerLiteral, "2"),
        LitConstExpr(LitConstKind.IntergerLiteral, "3")
    ]

    // 创建 SubscriptExpr 实例
    let subscriptExpr = SubscriptExpr(base, indexs)
    let posArr = subscriptExpr.getCommasPos()

    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("subscriptExpr.getCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
subscriptExpr.getCommasPos()[0]: 1:6-1:7
subscriptExpr.getCommasPos()[1]: 1:9-1:10
```

### func getLSquarePos()

```cangjie
public func getLSquarePos(): CodePositionRange
```

功能：获取当前 [SubscriptExpr](#class-subscriptexpr) 中 `[` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `[` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 base
    let base = SymbolRef("arr", [])

    // 创建 indexs
    let indexs: Array<Expr> = [LitConstExpr(LitConstKind.IntergerLiteral, "1")]

    // 创建 SubscriptExpr 实例
    let subscriptExpr = SubscriptExpr(base, indexs)
    let pos = subscriptExpr.getLSquarePos()

    // 输出左方括号位置
    println("subscriptExpr.getLSquarePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
subscriptExpr.getLSquarePos(): 1:4-1:5
```

### func getRSquarePos()

```cangjie
public func getRSquarePos(): CodePositionRange
```

功能：获取当前 [ArrayLiteral](#class-arrayliteral) 中 `]` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `]` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 base
    let base = SymbolRef("arr", [])

    // 创建 indexs
    let indexs: Array<Expr> = [LitConstExpr(LitConstKind.IntergerLiteral, "1")]

    // 创建 SubscriptExpr 实例
    let subscriptExpr = SubscriptExpr(base, indexs)
    let pos = subscriptExpr.getRSquarePos()

    // 输出右方括号位置
    println("subscriptExpr.getRSquarePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
subscriptExpr.getRSquarePos(): 1:6-1:7
```

## class SymbolRef

```cangjie
public class SymbolRef <: Expr {
    public init(name: String, typeArguments: Array<TypeAnnotation>, comments!: Array<Comment> = [])
}
```

功能：表示代码中通过标识符对某个声明、包的引用的表达式节点。

父类型：

- [Expr](#class-expr)

### prop name

```cangjie
public prop name: String
```

功能：获取 [SymbolRef](#class-symbolref) 节点的标识符。

类型：String

### prop typeArguments

```cangjie
public prop typeArguments: Array<TypeAnnotation>
```

功能：获取 [SymbolRef](#class-symbolref) 节点中的实例化类型。

类型：Array\<[TypeAnnotation](#class-typeannotation)>

### init(String, Array\<TypeAnnotation>, Array\<Comment>)

```cangjie
public init(name: String, typeArguments: Array<TypeAnnotation>, comments!: Array<Comment> = [])
```

功能：构造一个 [SymbolRef](#class-symbolref) 对象，表示符号引用表达式。

参数：

- name: String - 符号名称。
- typeArguments: Array\<[TypeAnnotation](#class-typeannotation)> - 实例化类型。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 name
    let name = "x"

    // 创建 typeArguments
    let typeArguments : Array<TypeAnnotation> = [CompositeType("I1", [], [])]

    // 创建 SymbolRef 实例
    let symbolRef = SymbolRef(
        name, 
        typeArguments
    )

    println("symbolRef: ${symbolRef}")
}
```

运行结果：

```text
symbolRef: x<I1>
```

### func getCommasPos()

```cangjie
public func getCommasPos(): Array<CodePositionRange>
```

功能：获取当前 [SymbolRef](#class-symbolref) 的类型参数中所有 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回类型参数中所有 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 typeArguments
    let typeArguments: Array<TypeAnnotation> = [
        CompositeType("I1", [], []),
        CompositeType("I2", [], []),
        CompositeType("I3", [], [])
    ]

    // 创建 SymbolRef 实例
    let symbolRef = SymbolRef("x", typeArguments)
    let posArr = symbolRef.getCommasPos()

    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("symbolRef.getCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
symbolRef.getCommasPos()[0]: 1:5-1:6
symbolRef.getCommasPos()[1]: 1:9-1:10
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取当前 [SymbolRef](#class-symbolref) 中变量名的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回变量名的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 SymbolRef 实例
    let symbolRef = SymbolRef("x", [CompositeType("I1", [], [])])
    let pos = symbolRef.getIdentifierPos()

    // 输出标识符位置
    println("symbolRef.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
symbolRef.getIdentifierPos(): 1:1-1:2
```

### func getLAnglePos()

```cangjie
public func getLAnglePos(): Option<CodePositionRange>
```

功能：获取当前 [SymbolRef](#class-symbolref) 的类型参数中 `<` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回类型参数中 `<` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 SymbolRef 实例
    let symbolRef = SymbolRef("x", [CompositeType("I1", [], [])])

    if (let Some(pos) <- symbolRef.getLAnglePos()) {
        // 输出小于号位置
        println("symbolRef.getLAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
symbolRef.getLAnglePos(): 1:2-1:3
```

### func getRAnglePos()

```cangjie
public func getRAnglePos(): Option<CodePositionRange>
```

功能：获取当前 [SymbolRef](#class-symbolref) 的类型参数中 `>` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回类型参数中 `>` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 SymbolRef 实例
    let symbolRef = SymbolRef("x", [CompositeType("I1", [], [])])

    if (let Some(pos) <- symbolRef.getRAnglePos()) {
        // 输出大于号位置
        println("symbolRef.getRAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
symbolRef.getRAnglePos(): 1:5-1:6
```

## class SynchronizedExpr

```cangjie
public class SynchronizedExpr <: Expr {
    public init(block: Block, structuredMutex: Expr, comments!: Array<Comment> = [])
}

```

功能：表示 `synchronized` 表达式。

一个 [SynchronizedExpr](#class-synchronizedexpr) 节点由 `synchronized` 关键字和 `StructuredMutex` 对以及后面的代码块组成，例如 `synchronized(m) { foo() }`。

### prop block

```cangjie
public prop block: Block
```

功能：获取当前 `synchronized` 语句的代码块，即需要同步执行的代码。

类型：[Block](#class-block)

### prop structuredMutex

```cangjie
public prop structuredMutex: Expr
```

功能：获取当前 `synchronized` 语句的锁对象表达式。

类型：[Expr](#class-expr)

### init(Block, Expr, Array\<Comment>)

```cangjie
public init(block: Block, structuredMutex: Expr, comments!: Array<Comment> = [])
```

功能：构造一个 [SynchronizedExpr](#class-synchronizedexpr) 对象，表示符号引用表达式。

参数：

- block: [Block](#class-block) - 需要同步执行的代码块。
- structuredMutex: [Expr](#class-expr) - 锁对象表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let callee = SymbolRef("foo", [])

    // 创建 CallExpr 实例
    let callExpr = CallExpr(
        callee,
        []
    )

    // 创建 Block 实例
    let block = Block(
        [callExpr]
    )

    let mutex = SymbolRef("mtx", [])

    // 创建 SynchronizedExpr 实例
    let synchronizedExpr = SynchronizedExpr(
        block,
        mutex
    )
    
    println("synchronizedExpr: ${synchronizedExpr}")
}
```

运行结果：

```text
synchronizedExpr: synchronized (mtx) {
    foo()
}
```

### func getLParenPos()

```cangjie
public func getLParenPos(): CodePositionRange
```

功能：获取 [SynchronizedExpr](#class-synchronizedexpr) 节点中 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let callee = SymbolRef("foo", [])

    // 创建 CallExpr 实例
    let callExpr = CallExpr(
        callee,
        []
    )

    // 创建 Block 实例
    let block = Block(
        [callExpr]
    )

    let mutex = SymbolRef("mtx", [])

    // 创建 SynchronizedExpr 实例
    let synchronizedExpr = SynchronizedExpr(
        block,
        mutex
    )
    
    let pos = synchronizedExpr.getLParenPos()
    // 输出 ( 位置
    println("synchronizedExpr.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
synchronizedExpr.getLParenPos(): 1:14-1:15
```

### func getRParenPos()

```cangjie
public func getRParenPos(): CodePositionRange
```

功能：获取 [SynchronizedExpr](#class-synchronizedexpr) 节点中 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let callee = SymbolRef("foo", [])

    // 创建 CallExpr 实例
    let callExpr = CallExpr(
        callee,
        []
    )

    // 创建 Block 实例
    let block = Block(
        [callExpr]
    )

    let mutex = SymbolRef("mtx", [])

    // 创建 SynchronizedExpr 实例
    let synchronizedExpr = SynchronizedExpr(
        block,
        mutex
    )
    
    let pos = synchronizedExpr.getRParenPos()
    // 输出 ) 位置
    println("synchronizedExpr.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
synchronizedExpr.getRParenPos(): 1:18-1:19
```

### func getSynchronizedKeyWordPos()

```cangjie
public func getSynchronizedKeyWordPos(): CodePositionRange
```

功能：获取 [SynchronizedExpr](#class-synchronizedexpr) 节点中 `synchronized` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `synchronized` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let callee = SymbolRef("foo", [])

    // 创建 CallExpr 实例
    let callExpr = CallExpr(
        callee,
        []
    )

    // 创建 Block 实例
    let block = Block(
        [callExpr]
    )

    let mutex = SymbolRef("mtx", [])

    // 创建 SynchronizedExpr 实例
    let synchronizedExpr = SynchronizedExpr(
        block,
        mutex
    )
    
    let pos = synchronizedExpr.getSynchronizedKeyWordPos()
    // 输出 synchronized 关键字位置
    println("synchronizedExpr.getSynchronizedKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
synchronizedExpr.getSynchronizedKeyWordPos(): 1:1-1:13
```

## class SyntaxTreeNode

```cangjie
sealed abstract class SyntaxTreeNode <: ToString & ToTokens & Hashable & Equatable<SyntaxTreeNode> {
    public let nodePos: CodePositionRange
    public let parentNode: Option<SyntaxTreeNode>
}
```

功能：所有仓颉语法树节点的父类。

该类提供了所有数据类型通用的操作接口。

父类型：

- ToString
- ToTokens
- Hashable
- Equatable\<[SyntaxTreeNode](#class-syntaxtreenode)>

### let nodePos

```cangjie
public let nodePos: CodePositionRange
```

功能：获取当前语法树节点的位置信息，包含起点和终点位置。

> **注意：**
>
> [Package](#class-package) 节点的起始和结束行列号均为 0，文件信息为空。

类型：[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)

### let parentNode

```cangjie
public let parentNode: Option<SyntaxTreeNode>
```

功能：获取当前语法树节点的父节点信息（若不存在返回 `None`）。

类型：Option\<[SyntaxTreeNode](#class-syntaxtreenode)>

### prop comments

```cangjie
public prop comments: Array<Comment>
```

功能：获取当前语法树节点的注释节点信息。

类型：Array\<[Comment](#class-comment)>

### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取 [SyntaxTreeNode](#class-syntaxtreenode) 对象的哈希值。

返回值：

- Int64 - 当前 [SyntaxTreeNode](#class-syntaxtreenode) 对象的哈希值。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let quoteToken = QuoteToken(quote(hello world))

    // 创建 SyntaxTreeNode 子类实例
    let node = QuoteExpr(
        QuoteExprContent.TokenPart(quoteToken)
    )
    // 输出哈希值
    println("node.hashCode(): ${node.hashCode()}")
}
```

运行结果：

```text
node.hashCode(): -4469856843433877754
```

### func toString()

```cangjie
public open func toString(): String
```

功能：将语法树节点作为字符串打印出来，保留原本的相对位置信息。

> **注意：**
>
> 当前语法树节点的打印不支持行尾空格、分号以及各类注释的打印。

返回值：

- String - 返回语法树节点打印为字符串的结果。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let quoteToken = QuoteToken(quote(hello world))

    // 创建 SyntaxTreeNode 子类实例
    let node = QuoteExpr(
        QuoteExprContent.TokenPart(quoteToken)
    )

    println("node.toString(): ${node.toString()}")
}
```

运行结果：

```text
node.toString(): quote(hello world)
```

### func toTokens()

```cangjie
public open func toTokens(): Tokens
```

功能：将语法树节点转换为一组词法单元，保留原本的相对位置信息。

> **注意：**
>
> 空格，分号等无法转换为 `Token` 的内容将被忽略。

返回值：

- Tokens - 返回语法树节点转换为一组词法单元的结果。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let quoteToken = QuoteToken(quote(hello world))

    // 创建 SyntaxTreeNode 子类实例
    let node = QuoteExpr(
        QuoteExprContent.TokenPart(quoteToken)
    )

    // 转化为 Tokens 并输出
    println("node.toTokens(): ${node.toTokens()}")
}
```

运行结果：

```text
node.toTokens(): quote(hello world)
```

### operator func ==(SyntaxTreeNode)

```cangjie
public operator func ==(that: SyntaxTreeNode): Bool
```

功能：判断当前 [SyntaxTreeNode](#class-syntaxtreenode) 与传入的 [SyntaxTreeNode](#class-syntaxtreenode) 是否相等。

参数：

- that: [SyntaxTreeNode](#class-syntaxtreenode) - 被比较的另一个 [SyntaxTreeNode](#class-syntaxtreenode) 对象。

返回值：

- Bool - 两个 [SyntaxTreeNode](#class-syntaxtreenode) 相等则为 `true` ，不等则为 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let quoteToken = QuoteToken(quote(hello world))

    // 创建 SyntaxTreeNode 子类实例
    let node0 = QuoteExpr(
        QuoteExprContent.TokenPart(quoteToken)
    )
    let node1 = QuoteExpr(
        QuoteExprContent.TokenPart(quoteToken)
    )

    // 输出判等结果
    println("node0 == node0: ${node0 == node0}")
    println("node0 == node1: ${node0 == node1}")
}
```

运行结果：

```text
node0 == node0: true
node0 == node1: false
```

## class ThrowExpr

```cangjie
public class ThrowExpr <: Expr {
    public init(throwVal: Expr, comments!: Array<Comment> = [])
}

```

功能：表示一个 `throw` 表达式。

[ThrowExpr](#class-throwexpr) 类用于在程序中抛出异常，`throwVal` 表示被抛出的异常对象。

父类型：

- [Expr](#class-expr)

### prop throwVal

```cangjie
public prop throwVal: Expr
```

功能：获取当前 `throw` 语句的异常值表达式。

类型：[Expr](#class-expr)

### init(Expr, Array\<Comment>)

```cangjie
public init(throwVal: Expr, comments!: Array<Comment> = [])
```

功能：构造一个 [ThrowExpr](#class-throwexpr) 对象，表示 `throw` 异常抛出表达式。

参数：

- throwVal: [Expr](#class-expr) - 被抛出的异常表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let callee = SymbolRef("Exception", [])

    // 创建 CallExpr 实例
    let callExpr = CallExpr(
        callee,
        []
    )

    // 创建 ThrowExpr 实例
    let throwExpr = ThrowExpr(
        callExpr
    )
    
    println("throwExpr: ${throwExpr}")
}
```

运行结果：

```text
throwExpr: throw Exception()
```

### func getThrowKeyWordPos()

```cangjie
public func getThrowKeyWordPos(): CodePositionRange
```

功能：获取当前 [ThrowExpr](#class-throwexpr) 中 `throw` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `throw` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let callee = SymbolRef("Exception", [])

    // 创建 CallExpr 实例
    let callExpr = CallExpr(
        callee,
        []
    )

    // 创建 ThrowExpr 实例
    let throwExpr = ThrowExpr(
        callExpr
    )
    
    let pos = throwExpr.getThrowKeyWordPos()
    // 输出 throw 关键字位置
    println("throwExpr.getThrowKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
throwExpr.getThrowKeyWordPos(): 1:1-1:6
```

## class TrailingClosureExpr

```cangjie
public class TrailingClosureExpr <: Expr {
    public init(callee: Expr, arguments: Array<Argument>, trailingLambdaExpr: Lambda, comments!: Array<Comment> = [])
}
```

功能：表示尾随闭包表达式。尾随闭包是一种语法糖，允许将闭包作为函数的最后一个参数时，可以放在函数调用括号之后。

父类型：

- [Expr](#class-expr)

### prop arguments

```cangjie
public prop arguments: Array<Argument>
```

功能：获取 [TrailingClosureExpr](#class-trailingclosureexpr) 节点中的函数参数。

类型：Array\<[Argument](#class-argument)>

### prop callee

```cangjie
public prop callee: Expr
```

功能：获取调用表达式，即包含尾随闭包的函数调用。

类型：[Expr](#class-expr)

### prop trailingLambdaExpr

```cangjie
public prop trailingLambdaExpr: Lambda
```

功能：获取尾随闭包对应的 `Lambda` 表达式。

类型：[Lambda](#class-lambda)

### init(Expr, Array\<Argument>, Lambda, Array\<Comment>)

```cangjie
public init(callee: Expr, arguments: Array<Argument>, trailingLambdaExpr: Lambda, comments!: Array<Comment> = [])
```

功能：构造一个 [TrailingClosureExpr](#class-trailingclosureexpr) 对象，表示尾随闭包调用表达式，如 `f(x) { y => y + 1 }`。

参数：

- callee: [Expr](#class-expr) - 被调用的函数表达式。
- arguments: Array\<[Argument](#class-argument)> - 普通实参列表。
- trailingLambdaExpr: [Lambda](#class-lambda) - 尾随 lambda 表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `callee` 不是成员访问或引用表达式时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 callee
    let callee = SymbolRef("foo", [])

    // 创建 arguments
    let arguments = [Argument(
        "a1", 
        false, 
        LitConstExpr(LitConstKind.IntergerLiteral, "123")
    )]

    // 创建 trailingLambdaExpr
    let trailingLambdaExpr = Lambda(
        [BinaryExpr(SymbolRef("x", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))], 
        ParameterList(LambdaParam("x", None), hasParen:false)
    )

    // 创建 TrailingClosureExpr 实例
    let trailingClosureExpr = TrailingClosureExpr(
        callee, 
        arguments, 
        trailingLambdaExpr
    )

    println("trailingClosureExpr: ${trailingClosureExpr}")
}
```

运行结果：

```text
trailingClosureExpr: foo(a1: 123) { x => x + 1 }
```

### func getCommasPos()

```cangjie
public func getCommasPos(): Array<CodePositionRange>
```

功能：获取当前 [TrailingClosureExpr](#class-trailingclosureexpr) 节点中所有 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回所有 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 callee
    let callee = SymbolRef("foo", [])

    // 创建 arguments
    let arguments = [
        Argument("a1", false, LitConstExpr(LitConstKind.IntergerLiteral, "1")),
        Argument("a2", false, LitConstExpr(LitConstKind.IntergerLiteral, "2")),
        Argument("a3", false, LitConstExpr(LitConstKind.IntergerLiteral, "3"))
    ]

    // 创建 trailingLambdaExpr
    let trailingLambdaExpr = Lambda(
        [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))],
        ParameterList(LambdaParam("x", None), hasParen:false)
    )

    // 创建 TrailingClosureExpr 实例
    let trailingClosureExpr = TrailingClosureExpr(callee, arguments, trailingLambdaExpr)
    let posArr = trailingClosureExpr.getCommasPos()

    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("trailingClosureExpr.getCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
trailingClosureExpr.getCommasPos()[0]: 1:10-1:11
trailingClosureExpr.getCommasPos()[1]: 1:17-1:18
```

### func getLParenPos()

```cangjie
public func getLParenPos(): Option<CodePositionRange>
```

功能：获取 [TrailingClosureExpr](#class-trailingclosureexpr) 节点中 `(` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 callee
    let callee = SymbolRef("foo", [])

    // 创建 arguments
    let arguments = [Argument("a1", false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))]

    // 创建 trailingLambdaExpr
    let trailingLambdaExpr = Lambda(
        [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))],
        ParameterList(LambdaParam("x", None), hasParen:false)
    )

    // 创建 TrailingClosureExpr 实例
    let trailingClosureExpr = TrailingClosureExpr(callee, arguments, trailingLambdaExpr)

    if (let Some(pos) <- trailingClosureExpr.getLParenPos()) {
        // 输出左括号位置
        println("trailingClosureExpr.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
trailingClosureExpr.getLParenPos(): 1:4-1:5
```

### func getRParenPos()

```cangjie
public func getRParenPos(): Option<CodePositionRange>
```

功能：获取 [TrailingClosureExpr](#class-trailingclosureexpr) 节点中 `)` 的位置。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 callee
    let callee = SymbolRef("foo", [])

    // 创建 arguments
    let arguments = [Argument("a1", false, LitConstExpr(LitConstKind.IntergerLiteral, "123"))]

    // 创建 trailingLambdaExpr
    let trailingLambdaExpr = Lambda(
        [BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))],
        ParameterList(LambdaParam("x", None), hasParen:false)
    )

    // 创建 TrailingClosureExpr 实例
    let trailingClosureExpr = TrailingClosureExpr(callee, arguments, trailingLambdaExpr)

    if (let Some(pos) <- trailingClosureExpr.getRParenPos()) {
        // 输出右括号位置
        println("trailingClosureExpr.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
trailingClosureExpr.getRParenPos(): 1:12-1:13
```

## class TryCatch

```cangjie
public class TryCatch <: Expr {
    public init(catchBlocks: Array<Block>, catchPatterns: Array<CatchPattern>, finallyBlock: Option<Block>, resourceSpec: Array<VarDecl>, 
        tryBlock: Block, comments!: Array<Comment> = [])
}
```

功能：表示 `try-catch` 表达式节点。

`try-catch` 表达式包括三个部分：`try` 块，`catch` 块和 `finally` 块。

父类型：

- [Expr](#class-expr)

### prop catchBlocks

```cangjie
public prop catchBlocks: Array<Block>
```

功能：获取异常处理代码块的数组，每个代码块对应一种异常处理方式。

类型：Array\<[Block](#class-block)>

### prop catchPatterns

```cangjie
public prop catchPatterns: Array<CatchPattern>
```

功能：获取异常匹配模式的数组，每个模式对应一个异常类型。

类型：Array\<[CatchPattern](#class-catchpattern)>

### prop finallyBlock

```cangjie
public prop finallyBlock: Option<Block>
```

功能：获取最终执行的代码块，无论异常是否被捕获和处理，该代码块总是会被执行（若不存在返回 `None`）。

类型：Option\<[Block](#class-block)>

### prop resourceSpec

```cangjie
public prop resourceSpec: Array<VarDecl>
```

功能：获取需要在完成后释放的资源声明。

类型：Array\<[VarDecl](#class-vardecl)>

### prop tryBlock

```cangjie
public prop tryBlock: Block
```

功能：获取需要监控的异常的代码块。

类型：[Block](#class-block)

### init(Array\<Block>, Array\<CatchPattern>, Option\<Block>, Array\<VarDecl>, Block, Array\<Comment>)

```cangjie
public init(catchBlocks: Array<Block>, catchPatterns: Array<CatchPattern>, finallyBlock: Option<Block>, resourceSpec: Array<VarDecl>, tryBlock: Block, comments!: Array<Comment> = [])
```

功能：构造一个 [TryCatch](#class-trycatch) 对象，表示 `try-catch-finally` 异常处理表达式。

参数：

- catchBlocks: Array\<[Block](#class-block)> - `catch` 代码块列表。
- catchPatterns: Array\<[CatchPattern](#class-catchpattern)> - 对应的异常捕获模式列表。
- finallyBlock: Option\<[Block](#class-block)> - 可选的 `finally` 代码块。
- resourceSpec: Array\<[VarDecl](#class-vardecl)> - 资源声明列表（try-with-resources）。
- tryBlock: [Block](#class-block) - `try` 代码块。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `catchPatterns`、`resourceSpec` 和 `finallyBlock` 同时为空时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 catchBlocks
    let catchBlocks = [Block(BinaryExpr(SymbolRef("y", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))]

    // 创建 catchPatterns
    let catchPatterns = [CatchPattern(VarPattern("e1"), [CompositeType("AException", [], []), CompositeType("BException", [], [])])]

    // 创建 finallyBlock
    let finallyBlock = Block(BinaryExpr(SymbolRef("z", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))

    // 创建 resourceSpec
    let resourceSpec: Array<VarDecl> = []

    // 创建 tryBlock
    let tryBlock = Block([BinaryExpr(SymbolRef("x", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])

    // 创建 TryCatch 实例
    let tryCatch = TryCatch(
        catchBlocks, 
        catchPatterns, 
        finallyBlock, 
        resourceSpec, 
        tryBlock
    )

    println("tryCatch: ${tryCatch}")
}
```

运行结果：

```text
tryCatch: try {
    x + 1
} catch (e1: AException | BException) {
    y + 1
} finally {
    z + 1
}
```

### func getCatchKeyWordsPos()

```cangjie
public func getCatchKeyWordsPos(): Array<CodePositionRange>
```

功能：获取当前 [TryCatch](#class-trycatch) 中所有 `catch` 关键字的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回所有 `catch` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 catchBlocks
    let catchBlocks = [Block(BinaryExpr(SymbolRef("y", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))]

    // 创建 catchPatterns
    let catchPatterns = [CatchPattern(VarPattern("e1"), [CompositeType("AException", [], []), CompositeType("BException", [], [])])]

    // 创建 finallyBlock
    let finallyBlock = Block(BinaryExpr(SymbolRef("z", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))

    // 创建 resourceSpec
    let resourceSpec: Array<VarDecl> = []

    // 创建 tryBlock
    let tryBlock = Block([BinaryExpr(SymbolRef("x", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])

    // 创建 TryCatch 实例
    let tryCatch = TryCatch(
        catchBlocks, 
        catchPatterns, 
        finallyBlock, 
        resourceSpec, 
        tryBlock
    )

    // 获取 catch 关键字位置
    let posArr = tryCatch.getCatchKeyWordsPos()
    for (i in 0..posArr.size) {
        println("tryCatch.getCatchKeyWordsPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
tryCatch.getCatchKeyWordsPos()[0]: 3:3-3:8
```

### func getCatchLParensPos()

```cangjie
public func getCatchLParensPos(): Array<CodePositionRange>
```

功能：获取当前 [TryCatch](#class-trycatch) 的所有 `catch` 语句中 `(` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回所有 `catch` 语句中 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 catchBlocks
    let catchBlocks = [Block(BinaryExpr(SymbolRef("y", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))]

    // 创建 catchPatterns
    let catchPatterns = [CatchPattern(VarPattern("e1"), [CompositeType("AException", [], []), CompositeType("BException", [], [])])]

    // 创建 finallyBlock
    let finallyBlock = Block(BinaryExpr(SymbolRef("z", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))

    // 创建 resourceSpec
    let resourceSpec: Array<VarDecl> = []

    // 创建 tryBlock
    let tryBlock = Block([BinaryExpr(SymbolRef("x", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])

    // 创建 TryCatch 实例
    let tryCatch = TryCatch(
        catchBlocks, 
        catchPatterns, 
        finallyBlock, 
        resourceSpec, 
        tryBlock
    )

    // 获取 catch 语句中 ( 的位置
    let catchLParensPos = tryCatch.getCatchLParensPos()
    for (i in 0..catchLParensPos.size) {
        println("tryCatch.getCatchLParensPos()[${i}]: ${catchLParensPos[i].beginLine}:${catchLParensPos[i].beginColumn}-${catchLParensPos[i].endLine}:${catchLParensPos[i].endColumn}")
    }
}
```

运行结果：

```text
tryCatch.getCatchLParensPos()[0]: 3:9-3:10
```

### func getCatchRParensPos()

```cangjie
public func getCatchRParensPos(): Array<CodePositionRange>
```

功能：获取当前 [TryCatch](#class-trycatch) 的所有 `catch` 语句中 `)` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回所有 `catch` 语句中 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 catchBlocks
    let catchBlocks = [Block(BinaryExpr(SymbolRef("y", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))]

    // 创建 catchPatterns
    let catchPatterns = [CatchPattern(VarPattern("e1"), [CompositeType("AException", [], []), CompositeType("BException", [], [])])]

    // 创建 finallyBlock
    let finallyBlock = Block(BinaryExpr(SymbolRef("z", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))

    // 创建 resourceSpec
    let resourceSpec: Array<VarDecl> = []

    // 创建 tryBlock
    let tryBlock = Block([BinaryExpr(SymbolRef("x", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])

    // 创建 TryCatch 实例
    let tryCatch = TryCatch(
        catchBlocks, 
        catchPatterns, 
        finallyBlock, 
        resourceSpec, 
        tryBlock
    )

    // 获取 catch 语句中 ) 的位置
    let catchRParensPos = tryCatch.getCatchRParensPos()
    for (i in 0..catchRParensPos.size) {
        println("tryCatch.getCatchRParensPos()[${i}]: ${catchRParensPos[i].beginLine}:${catchRParensPos[i].beginColumn}-${catchRParensPos[i].endLine}:${catchRParensPos[i].endColumn}")
    }
}
```

运行结果：

```text
tryCatch.getCatchRParensPos()[0]: 3:37-3:38
```

### func getFinallyKeyWordPos()

```cangjie
public func getFinallyKeyWordPos(): Option<CodePositionRange>
```

功能：获取当前 [TryCatch](#class-trycatch) 中 `finally` 关键字的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `finally` 关键字的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 catchBlocks
    let catchBlocks = [Block(BinaryExpr(SymbolRef("y", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))]

    // 创建 catchPatterns
    let catchPatterns = [CatchPattern(VarPattern("e1"), [CompositeType("AException", [], []), CompositeType("BException", [], [])])]

    // 创建 finallyBlock
    let finallyBlock = Block(BinaryExpr(SymbolRef("z", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))

    // 创建 resourceSpec
    let resourceSpec: Array<VarDecl> = []

    // 创建 tryBlock
    let tryBlock = Block([BinaryExpr(SymbolRef("x", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])

    // 创建 TryCatch 实例
    let tryCatch = TryCatch(
        catchBlocks, 
        catchPatterns, 
        finallyBlock, 
        resourceSpec, 
        tryBlock
    )

    // 获取 finally 关键字位置
    let finallyKeyWordPos = tryCatch.getFinallyKeyWordPos()
    match (finallyKeyWordPos) {
        case Some(pos) => println("tryCatch.getFinallyKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
        case None => println("tryCatch.getFinallyKeyWordPos(): None")
    }
}
```

运行结果：

```text
tryCatch.getFinallyKeyWordPos(): 5:3-5:10
```

### func getResourceSpecCommasPos()

```cangjie
public func getResourceSpecCommasPos(): Array<CodePositionRange>
```

功能：获取当前 [TryCatch](#class-trycatch) 的 `resource` 语句中所有 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `resource` 语句中所有 `,`的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 catchBlocks
    let catchBlocks = [Block(BinaryExpr(SymbolRef("y", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))]

    // 创建 catchPatterns
    let catchPatterns = [CatchPattern(VarPattern("e1"), [CompositeType("AException", [], []), CompositeType("BException", [], [])])]

    // 创建 finallyBlock
    let finallyBlock = Block(BinaryExpr(SymbolRef("z", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))

    // 创建 resourceSpec (包含多个资源，用于测试逗号位置)
    let resourceSpec = [
        VarDecl(LitConstExpr(LitConstKind.IntergerLiteral, "1"), VarKind.Var, "x", VarPattern("x"), AtomicType(AtomicTypeKind.Int64Type)),
        VarDecl(LitConstExpr(LitConstKind.IntergerLiteral, "2"), VarKind.Var, "y", VarPattern("y"), AtomicType(AtomicTypeKind.Int64Type))
    ]

    // 创建 tryBlock
    let tryBlock = Block([BinaryExpr(SymbolRef("x", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])

    // 创建 TryCatch 实例
    let tryCatch = TryCatch(
        catchBlocks, 
        catchPatterns, 
        finallyBlock, 
        resourceSpec, 
        tryBlock
    )

    // 获取 resource 语句中逗号的位置
    let resourceSpecCommasPos = tryCatch.getResourceSpecCommasPos()
    for (i in 0..resourceSpecCommasPos.size) {
        println("tryCatch.getResourceSpecCommasPos()[${i}]: ${resourceSpecCommasPos[i].beginLine}:${resourceSpecCommasPos[i].beginColumn}-${resourceSpecCommasPos[i].endLine}:${resourceSpecCommasPos[i].endColumn}")
    }
}
```

运行结果：

```text
tryCatch.getResourceSpecCommasPos()[0]: 1:22-1:23
```

### func getResourceSpecLParenPos()

```cangjie
public func getResourceSpecLParenPos(): Option<CodePositionRange>
```

功能：获取当前 [TryCatch](#class-trycatch) 的 `resource` 语句中 `(` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `resource` 语句中 `(` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 catchBlocks
    let catchBlocks = [Block(BinaryExpr(SymbolRef("y", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))]

    // 创建 catchPatterns
    let catchPatterns = [CatchPattern(VarPattern("e1"), [CompositeType("AException", [], []), CompositeType("BException", [], [])])]

    // 创建 finallyBlock
    let finallyBlock = Block(BinaryExpr(SymbolRef("z", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))

    // 创建 resourceSpec
    let resourceSpec = [VarDecl(LitConstExpr(LitConstKind.IntergerLiteral, "1"), VarKind.Var, "x", VarPattern("x"), AtomicType(AtomicTypeKind.Int64Type))]

    // 创建 tryBlock
    let tryBlock = Block([BinaryExpr(SymbolRef("x", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])

    // 创建 TryCatch 实例
    let tryCatch = TryCatch(
        catchBlocks, 
        catchPatterns, 
        finallyBlock, 
        resourceSpec, 
        tryBlock
    )

    // 获取 resource 语句中 ( 的位置
    let resourceSpecLParenPos = tryCatch.getResourceSpecLParenPos()
    match (resourceSpecLParenPos) {
        case Some(pos) => println("tryCatch.getResourceSpecLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
        case None => println("tryCatch.getResourceSpecLParenPos(): None")
    }
}
```

运行结果：

```text
tryCatch.getResourceSpecLParenPos(): 1:5-1:6
```

### func getResourceSpecRParenPos()

```cangjie
public func getResourceSpecRParenPos(): Option<CodePositionRange>
```

功能：获取当前 [TryCatch](#class-trycatch) 的 `resource` 语句中 `)` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `resource` 语句中 `)` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 catchBlocks
    let catchBlocks = [Block(BinaryExpr(SymbolRef("y", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))]

    // 创建 catchPatterns
    let catchPatterns = [CatchPattern(VarPattern("e1"), [CompositeType("AException", [], []), CompositeType("BException", [], [])])]

    // 创建 finallyBlock
    let finallyBlock = Block(BinaryExpr(SymbolRef("z", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))

    // 创建 resourceSpec
    let resourceSpec = [VarDecl(LitConstExpr(LitConstKind.IntergerLiteral, "1"), VarKind.Var, "x", VarPattern("x"), AtomicType(AtomicTypeKind.Int64Type))]

    // 创建 tryBlock
    let tryBlock = Block([BinaryExpr(SymbolRef("x", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])

    // 创建 TryCatch 实例
    let tryCatch = TryCatch(
        catchBlocks, 
        catchPatterns, 
        finallyBlock, 
        resourceSpec, 
        tryBlock
    )

    // 获取 resource 语句中 ) 的位置
    let resourceSpecRParenPos = tryCatch.getResourceSpecRParenPos()
    match (resourceSpecRParenPos) {
        case Some(pos) => println("tryCatch.getResourceSpecRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
        case None => println("tryCatch.getResourceSpecRParenPos(): None")
    }
}
```

运行结果：

```text
tryCatch.getResourceSpecRParenPos(): 1:22-1:23
```

### func getTryKeyWordPos()

```cangjie
public func getTryKeyWordPos(): CodePositionRange
```

功能：获取当前 [TryCatch](#class-trycatch) 中 `try` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `try` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 catchBlocks
    let catchBlocks = [Block(BinaryExpr(SymbolRef("y", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))]

    // 创建 catchPatterns
    let catchPatterns = [CatchPattern(VarPattern("e1"), [CompositeType("AException", [], []), CompositeType("BException", [], [])])]

    // 创建 finallyBlock
    let finallyBlock = Block(BinaryExpr(SymbolRef("z", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1")))

    // 创建 resourceSpec
    let resourceSpec: Array<VarDecl> = []

    // 创建 tryBlock
    let tryBlock = Block([BinaryExpr(SymbolRef("x", []),BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])

    // 创建 TryCatch 实例
    let tryCatch = TryCatch(
        catchBlocks, 
        catchPatterns, 
        finallyBlock, 
        resourceSpec, 
        tryBlock
    )

    // 获取 try 关键字位置
    let tryKeyWordPos = tryCatch.getTryKeyWordPos()
    println("tryCatch.getTryKeyWordPos(): ${tryKeyWordPos.beginLine}:${tryKeyWordPos.beginColumn}-${tryKeyWordPos.endLine}:${tryKeyWordPos.endColumn}")
}
```

运行结果：

```text
tryCatch.getTryKeyWordPos(): 1:1-1:4
```

## class TupleLiteral

```cangjie
public class TupleLiteral <: Expr {
    public init(elements: Array<SyntaxTreeNode>, comments!: Array<Comment> = [])
}
```

功能：表示 `Tuple` 字面量节点。

[TupleLiteral](#class-tupleliteral) 节点：使用格式 `(element1, element2, ... , elementN)` 表示， 每个 `element` 是一个语法树节点。

父类型：

- [Expr](#class-expr)

### prop elements

```cangjie
public prop elements: Array<SyntaxTreeNode>
```

功能：获取 [TupleLiteral](#class-tupleliteral) 中的节点列表。

类型：Array\<[SyntaxTreeNode](#class-syntaxtreenode)>

### init(Array\<SyntaxTreeNode>, Array\<Comment>)

```cangjie
public init(elements: Array<SyntaxTreeNode>, comments!: Array<Comment> = [])
```

功能：构造一个 [TupleLiteral](#class-tupleliteral) 对象，表示元组字面量表达式，如 `(1, "hello")`。

参数：

- elements: Array\<[SyntaxTreeNode](#class-syntaxtreenode)> - 元组元素节点列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 LitConstExpr 实例
    let litConstExpr0 = LitConstExpr(
        LitConstKind.FloatLiteral,
        "3.14"
    )
    let litConstExpr1 = LitConstExpr(
        LitConstKind.BoolLiteral,
        "false"
    )
    let litConstExpr2 = LitConstExpr(
        LitConstKind.FloatLiteral,
        "1.1"
    )

    // 创建 TupleLiteral 实例
    let tupleLiteral = TupleLiteral(
        [litConstExpr0, litConstExpr1, litConstExpr2]
    )
    
    println("tupleLiteral: ${tupleLiteral}")
}
```

运行结果：

```text
tupleLiteral: (3.14, false, 1.1)
```

### func getCommasPos()

```cangjie
public func getCommasPos(): Array<CodePositionRange>
```

功能：获取当前 [TupleLiteral](#class-tupleliteral) 中所有 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回所有 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 LitConstExpr 实例
    let litConstExpr0 = LitConstExpr(
        LitConstKind.FloatLiteral,
        "3.14"
    )
    let litConstExpr1 = LitConstExpr(
        LitConstKind.BoolLiteral,
        "false"
    )
    let litConstExpr2 = LitConstExpr(
        LitConstKind.FloatLiteral,
        "1.1"
    )

    // 创建 TupleLiteral 实例
    let tupleLiteral = TupleLiteral(
        [litConstExpr0, litConstExpr1, litConstExpr2]
    )
    
    let commasPos = tupleLiteral.getCommasPos()
    // 遍历输出逗号位置
    for (i in 0..commasPos.size) {
        println("tupleLiteral.getCommasPos()[${i}]: ${commasPos[i].beginLine}:${commasPos[i].beginColumn}-${commasPos[i].endLine}:${commasPos[i].endColumn}")
    }
}
```

运行结果：

```text
tupleLiteral.getCommasPos()[0]: 1:6-1:7
tupleLiteral.getCommasPos()[1]: 1:13-1:14
```

### func getLParenPos()

```cangjie
public func getLParenPos(): CodePositionRange
```

功能：获取当前 [TupleLiteral](#class-tupleliteral) 中 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 LitConstExpr 实例
    let litConstExpr0 = LitConstExpr(
        LitConstKind.FloatLiteral,
        "3.14"
    )
    let litConstExpr1 = LitConstExpr(
        LitConstKind.BoolLiteral,
        "false"
    )
    let litConstExpr2 = LitConstExpr(
        LitConstKind.FloatLiteral,
        "1.1"
    )

    // 创建 TupleLiteral 实例
    let tupleLiteral = TupleLiteral(
        [litConstExpr0, litConstExpr1, litConstExpr2]
    )
    
    let pos = tupleLiteral.getLParenPos()
    // 输出 ( 位置
    println("tupleLiteral.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
tupleLiteral.getLParenPos(): 1:1-1:2
```

### func getRParenPos()

```cangjie
public func getRParenPos(): CodePositionRange
```

功能：获取当前 [TupleLiteral](#class-tupleliteral) 中 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 LitConstExpr 实例
    let litConstExpr0 = LitConstExpr(
        LitConstKind.FloatLiteral,
        "3.14"
    )
    let litConstExpr1 = LitConstExpr(
        LitConstKind.BoolLiteral,
        "false"
    )
    let litConstExpr2 = LitConstExpr(
        LitConstKind.FloatLiteral,
        "1.1"
    )

    // 创建 TupleLiteral 实例
    let tupleLiteral = TupleLiteral(
        [litConstExpr0, litConstExpr1, litConstExpr2]
    )
    
    let pos = tupleLiteral.getRParenPos()
    // 输出 ) 位置
    println("tupleLiteral.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
tupleLiteral.getRParenPos(): 1:18-1:19
```

## class TuplePattern

```cangjie
public class TuplePattern <: Pattern {
    public init(subPatterns: Array<Pattern>, comments!: Array<Comment> = [])
}
```

功能：表示 `Tuple` 模式节点。

用于 `tuple` 值的匹配，如 `case ("Bob", age) => 1` 中的 `("Bob", age)`。

父类型：

- [Pattern](#class-pattern)

### prop subPatterns

```cangjie
public prop subPatterns: Array<Pattern>
```

功能：表示该模式节点中元组内的一组模式节点。

类型：Array\<[Pattern](#class-pattern)>

### init(Array\<Pattern>, Array\<Comment>)

```cangjie
public init(subPatterns: Array<Pattern>, comments!: Array<Comment> = [])
```

功能：构造一个 [TuplePattern](#class-tuplepattern) 对象，表示元组模式。

参数：

- subPatterns: Array\<[Pattern](#class-pattern)> - 子模式列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `subPatterns` 包含的元素个数少于 `2` 时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 subPatterns
    let subPatterns: Array<Pattern> = [VarPattern("x"), VarPattern("y")]

    // 创建 TuplePattern 实例
    let tuplePattern = TuplePattern(
        subPatterns
    )

    println("tuplePattern: ${tuplePattern}")
}
```

运行结果：

```text
tuplePattern: (x, y)
```

### func getCommasPos()

```cangjie
public func getCommasPos(): Array<CodePositionRange>
```

功能：获取 [TuplePattern](#class-tuplepattern) 节点中 `,` 的位置。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 subPatterns
    let subPatterns: Array<Pattern> = [
        VarPattern("x"),
        VarPattern("y"),
        VarPattern("z")
    ]

    // 创建 TuplePattern 实例
    let tuplePattern = TuplePattern(subPatterns)
    let posArr = tuplePattern.getCommasPos()

    // 遍历输出逗号位置
    for (i in 0..posArr.size) {
        println("tuplePattern.getCommasPos()[${i}]: ${posArr[i].beginLine}:${posArr[i].beginColumn}-${posArr[i].endLine}:${posArr[i].endColumn}")
    }
}
```

运行结果：

```text
tuplePattern.getCommasPos()[0]: 1:3-1:4
tuplePattern.getCommasPos()[1]: 1:6-1:7
```

### func getLParenPos()

```cangjie
public func getLParenPos(): CodePositionRange
```

功能：获取 [TuplePattern](#class-tuplepattern) 节点中 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 subPatterns
    let subPatterns: Array<Pattern> = [VarPattern("x"), VarPattern("y")]

    // 创建 TuplePattern 实例
    let tuplePattern = TuplePattern(subPatterns)
    let pos = tuplePattern.getLParenPos()

    // 输出左括号位置
    println("tuplePattern.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
tuplePattern.getLParenPos(): 1:1-1:2
```

### func getRParenPos()

```cangjie
public func getRParenPos(): CodePositionRange
```

功能：获取 [TuplePattern](#class-tuplepattern) 节点中 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 subPatterns
    let subPatterns: Array<Pattern> = [VarPattern("x"), VarPattern("y")]

    // 创建 TuplePattern 实例
    let tuplePattern = TuplePattern(subPatterns)
    let pos = tuplePattern.getRParenPos()

    // 输出右括号位置
    println("tuplePattern.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
tuplePattern.getRParenPos(): 1:6-1:7
```

## class TupleType

```cangjie
public class TupleType <: TypeAnnotation {
    public init(labels: Array<String>, elements: Array<TypeAnnotation>, comments!: Array<Comment> = [])
}
```

功能：表示元组类型节点。

例如 `var a : (Int64, Int32)` 中的 `(Int64, Int32)`。

父类型：

- [TypeAnnotation](#class-typeannotation)

### prop elements

```cangjie
public prop elements: Array<TypeAnnotation>
```

功能：获取 [TupleType](#class-tupletype) 节点中的类型节点列表。

类型：Array\<[TypeAnnotation](#class-typeannotation)>

### prop labels

```cangjie
public prop labels: Array<String>
```

功能：获取 [TupleType](#class-tupletype) 节点中的类型参数名，例如 `(name: String, age: Int64)` 中的 `name` 和 `age`。

类型：Array\<String>

### init(Array\<String>, Array\<TypeAnnotation>, Array\<Comment>)

```cangjie
public init(labels: Array<String>, elements: Array<TypeAnnotation>, comments!: Array<Comment> = [])
```

功能：构造一个 [TupleType](#class-tupletype) 对象，表示元组类型，如 `(Int64, String)`。

参数：

- labels: Array\<String> - 元素标签列表。
- elements: Array\<[TypeAnnotation](#class-typeannotation)> - 元素类型列表。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当元素类型列表和元素名列表长度不一样时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 AtomicType 实例
    let atomicType0 = AtomicType(AtomicTypeKind.UInt32Type)
    let atomicType1 = AtomicType(AtomicTypeKind.BoolType)
    let atomicType2 = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 TupleType 实例
    let tupleType = TupleType(
        ["a", "b", "c"],
        [atomicType0, atomicType1, atomicType2]
    )
    
    println("tupleType: ${tupleType}")
}
```

运行结果：

```text
tupleType: (a: UInt32, b: Bool, c: Int64)
```

### func getColonsPos()

```cangjie
public func getColonsPos(): Array<CodePositionRange>
```

功能：获取 `:` 的位置序列。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `:` 的位置序列。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 AtomicType 实例
    let atomicType0 = AtomicType(AtomicTypeKind.UInt32Type)
    let atomicType1 = AtomicType(AtomicTypeKind.BoolType)
    let atomicType2 = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 TupleType 实例
    let tupleType = TupleType(
        ["a", "b", "c"],
        [atomicType0, atomicType1, atomicType2]
    )
    
    let colonsPos = tupleType.getColonsPos()
    // 遍历输出冒号位置
    for (i in 0..colonsPos.size) {
        println("tupleType.getColonsPos()[${i}]: ${colonsPos[i].beginLine}:${colonsPos[i].beginColumn}-${colonsPos[i].endLine}:${colonsPos[i].endColumn}")
    }
}
```

运行结果：

```text
tupleType.getColonsPos()[0]: 1:3-1:4
tupleType.getColonsPos()[1]: 1:14-1:15
tupleType.getColonsPos()[2]: 1:23-1:24
```

### func getCommasPos()

```cangjie
public func getCommasPos(): Array<CodePositionRange>
```

功能：获取 `,` 的位置序列。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `,` 的位置序列。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 AtomicType 实例
    let atomicType0 = AtomicType(AtomicTypeKind.UInt32Type)
    let atomicType1 = AtomicType(AtomicTypeKind.BoolType)
    let atomicType2 = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 TupleType 实例
    let tupleType = TupleType(
        ["a", "b", "c"],
        [atomicType0, atomicType1, atomicType2]
    )
    
    let commasPos = tupleType.getCommasPos()
    // 遍历输出逗号位置
    for (i in 0..commasPos.size) {
        println("tupleType.getCommasPos()[${i}]: ${commasPos[i].beginLine}:${commasPos[i].beginColumn}-${commasPos[i].endLine}:${commasPos[i].endColumn}")
    }
}
```

运行结果：

```text
tupleType.getCommasPos()[0]: 1:11-1:12
tupleType.getCommasPos()[1]: 1:20-1:21
```

### func getLabelsPos()

```cangjie
public func getLabelsPos(): Array<CodePositionRange>
```

功能：获取标签的位置序列。

返回值：

- Array\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回标签的位置序列。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 AtomicType 实例
    let atomicType0 = AtomicType(AtomicTypeKind.UInt32Type)
    let atomicType1 = AtomicType(AtomicTypeKind.BoolType)
    let atomicType2 = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 TupleType 实例
    let tupleType = TupleType(
        ["a", "b", "c"],
        [atomicType0, atomicType1, atomicType2]
    )
    
    let labelsPos = tupleType.getLabelsPos()
    // 遍历输出标签位置
    for (i in 0..labelsPos.size) {
        println("tupleType.getLabelsPos()[${i}]: ${labelsPos[i].beginLine}:${labelsPos[i].beginColumn}-${labelsPos[i].endLine}:${labelsPos[i].endColumn}")
    }
}
```

运行结果：

```text
tupleType.getLabelsPos()[0]: 1:2-1:3
tupleType.getLabelsPos()[1]: 1:13-1:14
tupleType.getLabelsPos()[2]: 1:22-1:23
```

### func getLParenPos()

```cangjie
public func getLParenPos(): CodePositionRange
```

功能：获取 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 AtomicType 实例
    let atomicType0 = AtomicType(AtomicTypeKind.UInt32Type)
    let atomicType1 = AtomicType(AtomicTypeKind.BoolType)
    let atomicType2 = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 TupleType 实例
    let tupleType = TupleType(
        ["a", "b", "c"],
        [atomicType0, atomicType1, atomicType2]
    )
    
    let pos = tupleType.getLParenPos()
    // 输出 ( 位置
    println("tupleType.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
tupleType.getLParenPos(): 1:1-1:2
```

### func getRParenPos()

```cangjie
public func getRParenPos(): CodePositionRange
```

功能：获取 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 AtomicType 实例
    let atomicType0 = AtomicType(AtomicTypeKind.UInt32Type)
    let atomicType1 = AtomicType(AtomicTypeKind.BoolType)
    let atomicType2 = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 TupleType 实例
    let tupleType = TupleType(
        ["a", "b", "c"],
        [atomicType0, atomicType1, atomicType2]
    )
    
    let pos = tupleType.getRParenPos()
    // 输出 ) 位置
    println("tupleType.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
tupleType.getRParenPos(): 1:30-1:31
```

## class TypeAlias

```cangjie
public class TypeAlias <: Decl {
    public init(aliasName: String, originalTyAnnotation: TypeAnnotation, typeParameters: Array<GenericParam>,
        modifiers!: Array<Modifier> = [], comments!: Array<Comment> = [])
}
```

功能：表示类型别名节点。

一个 [TypeAlias](#class-typealias) 节点： `type Point2D = Float64`。

父类型：

- [Decl](#class-decl)

### prop aliasName

```cangjie
public prop aliasName: String
```

功能：获取当前类型别名的名称。

类型：String

### prop originalTyAnnotation

```cangjie
public prop originalTyAnnotation: TypeAnnotation
```

功能：获取当前类型别名的原始类型的注解。

类型：Option\<[TypeAnnotation](#class-typeannotation)>

### prop typeParameters

```cangjie
public prop typeParameters: Array<GenericParam>
```

功能：获取当前类型别名的类型参数。

类型：Array\<[GenericParam](#class-genericparam)>

### init(String, TypeAnnotation, Array\<GenericParam>, Array\<Modifier>, Array\<Comment>)

```cangjie
public init(aliasName: String, originalTyAnnotation: TypeAnnotation, typeParameters: Array<GenericParam>,
    modifiers!: Array<Modifier> = [], comments!: Array<Comment> = [])
```

功能：构造一个 [TypeAlias](#class-typealias) 对象，表示类型别名声明节点。

参数：

- aliasName: String - 别名名称。
- originalTyAnnotation: [TypeAnnotation](#class-typeannotation) - 原始类型注解。
- typeParameters: Array\<[GenericParam](#class-genericparam)> - 类型参数列表。
- modifiers!: Array\<[Modifier](#class-modifier)> - 修饰符列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `aliasName` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 CompositeType 实例
    let compositeType = CompositeType(
        "A", 
        ["p0"], 
        [CompositeType("T", [], [])]
    )
    
    // 创建 TypeAlias 实例
    let typeAlias = TypeAlias(
        "MyType",
        compositeType,
        GenericParam("T")
    )

    println("typeAlias: ${typeAlias}")
}
```

运行结果：

```text
typeAlias: type MyType<T> = p0.A<T>
```

### func getAssignPos()

```cangjie
public func getAssignPos(): CodePositionRange
```

功能：获取当前 [TypeAlias](#class-typealias) 中 `=` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `=` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 CompositeType 实例
    let compositeType = CompositeType(
        "A", 
        ["p0"], 
        [CompositeType("T", [], [])]
    )
    
    // 创建 TypeAlias 实例
    let typeAlias = TypeAlias(
        "MyType",
        compositeType,
        [GenericParam("T")]
    )
    
    let pos = typeAlias.getAssignPos()
    // 输出 = 位置
    println("typeAlias.getAssignPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
typeAlias.getAssignPos(): 1:16-1:17
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): CodePositionRange
```

功能：获取当前 [TypeAlias](#class-typealias) 中类型别名的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回类型别名的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 CompositeType 实例
    let compositeType = CompositeType(
        "A", 
        ["p0"], 
        [CompositeType("T", [], [])]
    )
    
    // 创建 TypeAlias 实例
    let typeAlias = TypeAlias(
        "MyType",
        compositeType,
        [GenericParam("T")]
    )
    
    let pos = typeAlias.getIdentifierPos()
    // 输出标识符位置
    println("typeAlias.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
typeAlias.getIdentifierPos(): 1:6-1:12
```

### func getTypeAliasKeyWordPos()

```cangjie
public func getTypeAliasKeyWordPos(): CodePositionRange
```

功能：获取当前 [TypeAlias](#class-typealias) 中 `type` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `type` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 CompositeType 实例
    let compositeType = CompositeType(
        "A", 
        ["p0"], 
        [CompositeType("T", [], [])]
    )
    
    // 创建 TypeAlias 实例
    let typeAlias = TypeAlias(
        "MyType",
        compositeType,
        [GenericParam("T")]
    )
    
    let pos = typeAlias.getTypeAliasKeyWordPos()
    // 输出 type 关键字位置
    println("typeAlias.getTypeAliasKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
typeAlias.getTypeAliasKeyWordPos(): 1:1-1:5
```

## class TypeAnnotation

```cangjie
sealed abstract class TypeAnnotation <: SyntaxTreeNode {}
```

功能：表示一个类型标注节点。

父类型：

- [SyntaxTreeNode](#class-syntaxtreenode)

## class TypeConvExpr

```cangjie
public class TypeConvExpr <: Expr {
    public init(srcVal: Expr, targetTypeAnnotation: AtomicType, comments!: Array<Comment> = [])
}
```

功能：表示一个类型转换表达式。

用于实现若干数值类型间的转换。一个 [TypeConvExpr](#class-typeconvexpr) 节点：`Int8(32)`。

父类型：

- [Expr](#class-expr)

### prop srcVal

```cangjie
public prop srcVal: Expr
```

功能：获取 [TypeConvExpr](#class-typeconvexpr) 中的源表达式节点。

类型：[Expr](#class-expr)

### prop targetTypeAnnotation

```cangjie
public prop targetTypeAnnotation: AtomicType
```

功能：获取 [TypeConvExpr](#class-typeconvexpr) 中将要转换到的目标类型。

类型：[AtomicType](#class-atomictype)

### init(Expr, AtomicType, Array\<Comment>)

```cangjie
public init(srcVal: Expr, targetTypeAnnotation: AtomicType, comments!: Array<Comment> = [])
```

功能：构造一个 [TypeConvExpr](#class-typeconvexpr) 对象，表示显式类型转换表达式，如 `Int64(x)`。

参数：

- srcVal: [Expr](#class-expr) - 被转换的源表达式。
- targetTypeAnnotation: [AtomicType](#class-atomictype) - 目标原子类型。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 LitConstExpr 实例
    let srcVal = LitConstExpr(
        LitConstKind.FloatLiteral,
        "3.14"
    )

    // 创建 AtomicType 实例
    let targetType = AtomicType(AtomicTypeKind.Float64Type)

    // 创建 TypeConvExpr 实例
    let typeConvExpr = TypeConvExpr(
        srcVal,
        targetType
    )

    println("typeConvExpr: ${typeConvExpr}")
}
```

运行结果：

```text
typeConvExpr: Float64(3.14)
```

### func getLParenPos()

```cangjie
public func getLParenPos(): CodePositionRange
```

功能：获取 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 LitConstExpr 实例
    let srcVal = LitConstExpr(
        LitConstKind.FloatLiteral,
        "3.14"
    )

    // 创建 AtomicType 实例
    let targetType = AtomicType(AtomicTypeKind.Float64Type)

    // 创建 TypeConvExpr 实例
    let typeConvExpr = TypeConvExpr(
        srcVal,
        targetType
    )
    
    let pos = typeConvExpr.getLParenPos()
    // 输出 ( 位置
    println("typeConvExpr.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
typeConvExpr.getLParenPos(): 1:8-1:9
```

### func getRParenPos()

```cangjie
public func getRParenPos(): CodePositionRange
```

功能：获取 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 LitConstExpr 实例
    let srcVal = LitConstExpr(
        LitConstKind.FloatLiteral,
        "3.14"
    )

    // 创建 AtomicType 实例
    let targetType = AtomicType(AtomicTypeKind.Float64Type)

    // 创建 TypeConvExpr 实例
    let typeConvExpr = TypeConvExpr(
        srcVal,
        targetType
    )
    
    let pos = typeConvExpr.getRParenPos()
    // 输出 ) 位置
    println("typeConvExpr.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
typeConvExpr.getRParenPos(): 1:13-1:14
```

## class TypePattern

```cangjie
public class TypePattern <: Pattern {
    public init(subPattern: Pattern, patternType: TypeAnnotation, comments!: Array<Comment> = [])
}
```

功能：表示类型模式节点。

用于判断一个值的运行时类型是否是某个类型的子类型，如 `case b: Base => 0` 中的 `b: Base`。

父类型：

- [Pattern](#class-pattern)

### prop patternType

```cangjie
public prop patternType: TypeAnnotation
```

功能：表示该模式节点中的待匹配的类型节点。

类型：[TypeAnnotation](#class-typeannotation)

### prop subPattern

```cangjie
public prop subPattern: Pattern
```

功能：表示该模式节点中的被判断值的模式节点。

类型：[Pattern](#class-pattern)

### init(Pattern, TypeAnnotation, Array\<Comment>)

```cangjie
public init(subPattern: Pattern, patternType: TypeAnnotation, comments!: Array<Comment> = [])
```

功能：构造一个 [TypePattern](#class-typepattern) 对象，表示带类型的模式，如 `x: Int64`。

参数：

- subPattern: [Pattern](#class-pattern) - 被判断值的模式节点。
- patternType: [TypeAnnotation](#class-typeannotation) - 类型。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `subPattern` 不为 [WildcardPattern](#class-wildcardpattern) 或 [VarPattern](#class-varpattern) 时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 subPattern
    let subPattern = VarPattern("x")

    // 创建 patternType
    let patternType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 TypePattern 实例
    let typePattern = TypePattern(
        subPattern, 
        patternType
    )

    println("typePattern: ${typePattern}")
}
```

运行结果：

```text
typePattern: x: Int64
```

### func getColonPos()

```cangjie
public func getColonPos(): CodePositionRange
```

功能：获取 [TypePattern](#class-typepattern) 节点中 `:` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `:` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 subPattern
    let subPattern = VarPattern("x")

    // 创建 patternType
    let patternType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 TypePattern 实例
    let typePattern = TypePattern(subPattern, patternType)
    let pos = typePattern.getColonPos()

    // 输出冒号位置
    println("typePattern.getColonPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
typePattern.getColonPos(): 1:2-1:3
```

## class UnaryExpr

```cangjie
public class UnaryExpr <: Expr {
    public init(opKind: UnaryOpKind, operand: Expr, comments!: Array<Comment> = [])
}
```

功能：表示一个一元操作表达式节点。

一个 [UnaryExpr](#class-unaryexpr) 节点：`-1`

父类型：

- [Expr](#class-expr)

### prop operand

```cangjie
public prop operand: Expr
```

功能：获取 [UnaryExpr](#class-unaryexpr) 节点中的操作数。

类型：[Expr](#class-expr)

### prop opKind

```cangjie
public prop opKind: UnaryOpKind
```

功能：获取 [UnaryExpr](#class-unaryexpr) 节点中的一元操作符。

类型：[UnaryOpKind](syntax_package_enums.md#enum-unaryopkind)

### init(UnaryOpKind, Expr, Array\<Comment>)

```cangjie
public init(opKind: UnaryOpKind, operand: Expr, comments!: Array<Comment> = [])
```

功能：构造一个 [UnaryExpr](#class-unaryexpr) 对象，表示一元运算表达式，如 `!flag` 或 `-x`。

参数：

- opKind: [UnaryOpKind](syntax_package_enums.md#enum-unaryopkind) - 一元操作符类型。
- operand: [Expr](#class-expr) - 被操作的表达式。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建操作数（使用一个字面量表达式作为操作数）
    let operand = LitConstExpr(LitConstKind.IntergerLiteral, "123")
    
    // 创建操作符类型（使用负号操作符）
    let opKind = UnaryOpKind.Sub
    
    // 创建 UnaryExpr 实例
    let unaryExpr = UnaryExpr(
        opKind,
        operand
    )
    
    println("unaryExpr: ${unaryExpr}")
}
```

运行结果：

```text
unaryExpr: -123
```

### func getOperatorPos()

```cangjie
public func getOperatorPos(): CodePositionRange
```

功能：获取一元操作符的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回一元操作符的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建操作数（使用一个字面量表达式作为操作数）
    let operand = LitConstExpr(LitConstKind.IntergerLiteral, "123")
    
    // 创建操作符类型（使用负号操作符）
    let opKind = UnaryOpKind.Sub
    
    // 创建 UnaryExpr 实例
    let unaryExpr = UnaryExpr(
        opKind,
        operand
    )
    
    // 获取操作符位置
    let pos = unaryExpr.getOperatorPos()
    
    // 输出操作符位置
    println("unaryExpr.getOperatorPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
unaryExpr.getOperatorPos(): 1:1-1:2
```

## class UnsafeExpr

```cangjie
public class UnsafeExpr <: Expr {
    public init(block: Block, comments!: Array<Comment> = [])
}
```

功能：表示一个不安全代码块。

用于标记包含不安全操作（如指针操作、内存管理等）的代码区域，编译器会对该区域放松安全检查。

父类型：

- [Expr](#class-expr)

### prop block

```cangjie
public prop block: Block
```

功能：获取不安全代码块的内容。

类型：[Block](#class-block)

### init(Block, Array\<Comment>)

```cangjie
public init(block: Block, comments!: Array<Comment> = [])
```

功能：构造一个 [UnsafeExpr](#class-unsafeexpr) 对象，表示 `unsafe` 块表达式，用于执行不安全代码。

参数：

- block: [Block](#class-block) - 不安全代码块。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let callee = SymbolRef("foo", [])

    // 创建 CallExpr 实例
    let callExpr = CallExpr(
        callee,
        []
    )

    let block = Block([callExpr])

    // 创建 UnsafeExpr 实例
    let unsafeExpr = UnsafeExpr(block)

    println("unsafeExpr: ${unsafeExpr}")
}
```

运行结果：

```text
unsafeExpr: unsafe {
    foo()
}
```

### func getUnsafePos()

```cangjie
public func getUnsafePos(): CodePositionRange
```

功能：获取当前 [UnsafeExpr](#class-unsafeexpr) 中 `unsafe` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `unsafe` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let callee = SymbolRef("foo", [])

    // 创建 CallExpr 实例
    let callExpr = CallExpr(
        callee,
        []
    )

    let block = Block([callExpr])

    // 创建 UnsafeExpr 实例
    let unsafeExpr = UnsafeExpr(block)
    
    let pos = unsafeExpr.getUnsafePos()
    // 输出 unsafe 关键字位置
    println("unsafeExpr.getUnsafePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
unsafeExpr.getUnsafePos(): 1:1-1:7
```

## class VarDecl

```cangjie
public class VarDecl <: Decl {
    public init(initializer: Option<Expr>, kind: VarKind, name: String, pattern: Pattern,
        tyAnnotation: Option<TypeAnnotation>, annotations!: Array<Annotation> = [], modifiers!: Array<Modifier> = [],
        comments!: Array<Comment> = [])
}
```

功能：表示变量声明节点。

一个 [VarDecl](#class-vardecl) 节点：`var a: String`，`var b: Int64 = 1` 等。

父类型：

- [Decl](#class-decl)

### prop initializer

```cangjie
public prop initializer: Option<Expr>
```

功能：获取当前变量声明的初始化表达式（若不存在返回 `None`）。

类型：Option\<[Expr](#class-expr)>

### prop kind

```cangjie
public prop kind: VarKind
```

功能：获取当前变量声明的种类。

类型：[VarKind](syntax_package_enums.md#enum-varkind)

### prop name

```cangjie
public prop name: String
```

功能：当前变量声明的模式为 `VarPattern` 时，获取其名称，其他模式返回空字符串。

类型：String

### prop pattern

```cangjie
public prop pattern: Pattern
```

功能：获取当前变量声明的模式。

类型：[Pattern](#class-pattern)

### prop tyAnnotation

```cangjie
public prop tyAnnotation: Option<TypeAnnotation>
```

功能：获取当前变量声明的类型标注（若不存在返回 `None`）。

类型：Option\<[TypeAnnotation](#class-typeannotation)>

### init(Option\<Expr>, VarKind, String, Pattern, Option\<TypeAnnotation>, Array\<Annotation>, Array\<Modifier>, Array\<Comment>)

```cangjie
public init(initializer: Option<Expr>, kind: VarKind, name: String, pattern: Pattern,
    tyAnnotation: Option<TypeAnnotation>, annotations!: Array<Annotation> = [], modifiers!: Array<Modifier> = [],
    comments!: Array<Comment> = [])
```

功能：构造一个 [VarDecl](#class-vardecl) 对象，表示变量声明节点。

参数：

- initializer: Option\<[Expr](#class-expr)> - 可选的初始化表达式。
- kind: [VarKind](syntax_package_enums.md#enum-varkind) - 变量种类。
- name: String - 变量名（仅当模式为 VarPattern 时有效）。
- pattern: [Pattern](#class-pattern) - 变量绑定模式。
- tyAnnotation: Option\<[TypeAnnotation](#class-typeannotation)> - 可选的类型注解。
- annotations!: Array\<[Annotation](#class-annotation)> - 附加的注解列表，默认为空数组。
- modifiers!: Array\<[Modifier](#class-modifier)> - 修饰符列表，默认为空数组。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `pattern` 不是通配符模式、变量绑定模式、元组模式或枚举模式，或 `modifiers` 包含 `const`，或 `kind` 不代表 `var`、`let` 或 `const`，或输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 initializer
    let initializer = LitConstExpr(LitConstKind.IntergerLiteral, "1")

    // 创建 kind
    let kind = VarKind.Let

    // 创建 name
    let name = "x"

    // 创建 pattern
    let pattern = VarPattern("x")

    // 创建 tyAnnotation
    let tyAnnotation = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 VarDecl 实例
    let varDecl = VarDecl(
        initializer, 
        kind, 
        name, 
        pattern, 
        tyAnnotation
    )

    println("varDecl: ${varDecl}")
}
```

运行结果：

```text
varDecl: let x: Int64 = 1
```

### func getAssignPos()

```cangjie
public func getAssignPos(): Option<CodePositionRange>
```

功能：获取当前 [VarDecl](#class-vardecl) 中 `=` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回 `=` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 initializer
    let initializer = LitConstExpr(LitConstKind.IntergerLiteral, "1")

    // 创建 VarDecl 实例
    let varDecl = VarDecl(initializer, VarKind.Let, "x", VarPattern("x"), AtomicType(AtomicTypeKind.Int64Type))

    if (let Some(pos) <- varDecl.getAssignPos()) {
        // 输出赋值符位置
        println("varDecl.getAssignPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
varDecl.getAssignPos(): 1:14-1:15
```

### func getIdentifierPos()

```cangjie
public func getIdentifierPos(): Option<CodePositionRange>
```

功能：获取当前 [VarDecl](#class-vardecl) 中变量标识符的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回变量标识符的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 initializer
    let initializer = LitConstExpr(LitConstKind.IntergerLiteral, "1")

    // 创建 VarDecl 实例
    let varDecl = VarDecl(initializer, VarKind.Let, "x", VarPattern("x"), AtomicType(AtomicTypeKind.Int64Type))

    if (let Some(pos) <- varDecl.getIdentifierPos()) {
        // 输出变量标识符位置
        println("varDecl.getIdentifierPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
varDecl.getIdentifierPos(): 1:5-1:6
```

### func getTyAnnotationColonPos()

```cangjie
public func getTyAnnotationColonPos(): Option<CodePositionRange>
```

功能：获取当前 [VarDecl](#class-vardecl) 中类型名之前的 `:` 的位置（若不存在返回 `None`）。

返回值：

- Option\<[CodePositionRange](syntax_package_structs.md#struct-codepositionrange)> - 返回类型名之前的 `:` 的位置（若不存在返回 `None`）。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 initializer
    let initializer = LitConstExpr(LitConstKind.IntergerLiteral, "1")

    // 创建 VarDecl 实例
    let varDecl = VarDecl(initializer, VarKind.Let, "x", VarPattern("x"), AtomicType(AtomicTypeKind.Int64Type))

    if (let Some(pos) <- varDecl.getTyAnnotationColonPos()) {
        // 输出类型注解冒号位置
        println("varDecl.getTyAnnotationColonPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
    }
}
```

运行结果：

```text
varDecl.getTyAnnotationColonPos(): 1:6-1:7
```

### func getVarKindKeyWordPos()

```cangjie
public func getVarKindKeyWordPos(): CodePositionRange
```

功能：获取当前 [VarDecl](#class-vardecl) 中变量声明类型关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回变量声明类型关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 initializer
    let initializer = LitConstExpr(LitConstKind.IntergerLiteral, "1")

    // 创建 VarDecl 实例
    let varDecl = VarDecl(initializer, VarKind.Let, "x", VarPattern("x"), AtomicType(AtomicTypeKind.Int64Type))
    let pos = varDecl.getVarKindKeyWordPos()

    // 输出关键字位置
    println("varDecl.getVarKindKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
varDecl.getVarKindKeyWordPos(): 1:1-1:4
```

## class VarOrEnumPattern

```cangjie
public class VarOrEnumPattern <: Pattern {
    public init(identifier: String, comments!: Array<Comment> = [])
}
```

功能：表示当模式的标识符为 `Enum` 构造器时的节点。

例如 `case RED` 中的 `RED` 为 `Enum` 构造器。

父类型：

- [Pattern](#class-pattern)

### prop identifier

```cangjie
public prop identifier: String
```

功能：表示该模式节点中的标识符。

类型：String

### init(String, Array\<Comment>)

```cangjie
public init(identifier: String, comments!: Array<Comment> = [])
```

功能：构造一个 [VarOrEnumPattern](#class-varorenumpattern) 对象，表示变量或枚举模式。

参数：

- identifier: String - 标识符名称。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `identifier` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 identifier
    let identifier = "A"

    // 创建 VarOrEnumPattern 实例
    let varOrEnumPattern = VarOrEnumPattern(
        identifier
    )

    println("varOrEnumPattern: ${varOrEnumPattern}")
}
```

运行结果：

```text
varOrEnumPattern: A
```

## class VarPattern

```cangjie
public class VarPattern <: Pattern {
    public init(name: String, comments!: Array<Comment> = [])
}
```

功能：表示绑定模式节点。

使用一个合法的标识符表示，如 `for (i in 1..10)` 中的 `i`。

父类型：

- [Pattern](#class-pattern)

### prop name

```cangjie
public prop name: String
```

功能：表示该模式节点中的标识符。

类型：String

### init(String, Array\<Comment>)

```cangjie
public init(name: String, comments!: Array<Comment> = [])
```

功能：构造一个 [VarPattern](#class-varpattern) 对象，表示变量模式，如。

参数：

- name: String - 变量名。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当输入的 `name` 不符合仓颉标识符规范时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 VarPattern 实例
    let varPattern = VarPattern("i")

    println("varPattern: ${varPattern}")
}
```

运行结果：

```text
varPattern: i
```

## class VArrayExpr

```cangjie
public class VArrayExpr <: Expr {
    public init(argument: Argument, vArrayType: VArrayType, comments!: Array<Comment> = [])
}
```

功能：表示 `VArray` 表达式的实例节点。

一个 [VArrayExpr](#class-varrayexpr) 节点：`prop arr: VArray<Int64, $5> = VArray<Int64, $5>({ i => i })` 中的 `VArray<Int64, $5>({ i => i })`。

父类型：

- [Expr](#class-expr)

### prop argument

```cangjie
public prop argument: Argument
```

功能：获取 [VArrayExpr](#class-varrayexpr) 中的初始化参数。

类型：[Argument](#class-argument)

### prop vArrayType

```cangjie
public prop vArrayType: VArrayType
```

功能：获取 [VArrayExpr](#class-varrayexpr) 中的 `VArray` 类型节点。

类型：[VArrayType](#class-varraytype)

### init(Argument, VArrayType, Array\<Comment>)

```cangjie
public init(argument: Argument, vArrayType: VArrayType, comments!: Array<Comment> = [])
```

功能：构造一个 [VArrayExpr](#class-varrayexpr) 对象，表示 `VArray` 表达式。

参数：

- argument: [Argument](#class-argument) - 构造参数。
- vArrayType: [VArrayType](#class-varraytype) - 定长数组类型。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `size` 小于 `0` 时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let symbolRef = SymbolRef("i", [])
    let params = ParameterList(LambdaParam("i", None), hasParen:false)

    // 创建 Lambda 实例
    let lambda = Lambda(
        [symbolRef], 
        params
    )

    // 创建 Argument 实例
    let argument = Argument(
        None, 
        false, 
        lambda
    )

    let elementType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 VArrayType 实例
    let vArrayType = VArrayType(elementType, 10)

    let vArrayExpr = VArrayExpr(
        argument,
        vArrayType
    )

    println("vArrayExpr: ${vArrayExpr}")
}
```

运行结果：

```text
vArrayExpr: VArray<Int64, $10>({ i => i })
```

### func getLParenPos()

```cangjie
public func getLParenPos(): CodePositionRange
```

功能：获取当前 [VArrayExpr](#class-varrayexpr) 中 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let symbolRef = SymbolRef("i", [])
    let params = ParameterList([LambdaParam("i", None)], hasParen:false)

    // 创建 Lambda 实例
    let lambda = Lambda(
        [symbolRef], 
        params
    )

    // 创建 Argument 实例
    let argument = Argument(
        None, 
        false, 
        lambda
    )

    let elementType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 VArrayType 实例
    let vArrayType = VArrayType(elementType, 10)

    let vArrayExpr = VArrayExpr(
        argument,
        vArrayType
    )
    
    let pos = vArrayExpr.getLParenPos()
    // 输出 ( 位置
    println("vArrayExpr.getLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
vArrayExpr.getLParenPos(): 1:19-1:20
```

### func getRParenPos()

```cangjie
public func getRParenPos(): CodePositionRange
```

功能：获取当前 [VArrayExpr](#class-varrayexpr) 中 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let symbolRef = SymbolRef("i", [])
    let params = ParameterList([LambdaParam("i", None)], hasParen:false)

    // 创建 Lambda 实例
    let lambda = Lambda(
        [symbolRef], 
        params
    )

    // 创建 Argument 实例
    let argument = Argument(
        None, 
        false, 
        lambda
    )

    let elementType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 VArrayType 实例
    let vArrayType = VArrayType(elementType, 10)

    let vArrayExpr = VArrayExpr(
        argument,
        vArrayType
    )
    
    let pos = vArrayExpr.getRParenPos()
    // 输出 ) 位置
    println("vArrayExpr.getRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
vArrayExpr.getRParenPos(): 1:30-1:31
```

## class VArrayType

```cangjie
public class VArrayType <: TypeAnnotation {
    public init(elementType: TypeAnnotation, size: Int64, comments!: Array<Comment> = [])
}
```

功能：表示 `VArray` 类型节点。

使用泛型 `VArray<T, $N>` 表示 `VArray` 类型，其中 `T` 表示该值类型数组的元素类型，`$N` 是一个固定的语法，通过 `$` 加上一个 `Int64` 类型的数值字面量表示这个值类型数组的长度。

父类型：

- [TypeAnnotation](#class-typeannotation)

### prop elementType

```cangjie
public prop elementType: TypeAnnotation
```

功能：获取 [VArrayType](#class-varraytype) 节点中的类型变元节点，如 `VArray<Int16, $0>` 中的 `Int16`。

类型：[TypeAnnotation](#class-typeannotation)

### prop size

```cangjie
public prop size: Int64
```

功能：获取 [VArrayType](#class-varraytype) 节点的大小。

类型：Int64

### init(TypeAnnotation, Int64, Array\<Comment>)

```cangjie
public init(elementType: TypeAnnotation, size: Int64, comments!: Array<Comment> = [])
```

功能：构造一个 [VArrayType](#class-varraytype) 对象，表示定长数组类型，如 `VArray<Int64, $5>`。

参数：

- elementType: [TypeAnnotation](#class-typeannotation) - 元素类型。
- size: Int64 - 数组长度。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

异常：

- Exception - 当 `size` 小于等于 `0` 时，抛出异常，异常中包含报错提示信息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let elementType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 VArrayType 实例
    let vArrayType = VArrayType(elementType, 10)

    println("vArrayType: ${vArrayType}")
}
```

运行结果：

```text
vArrayType: VArray<Int64, $10>
```

### func getCommaPos()

```cangjie
public func getCommaPos(): CodePositionRange
```

功能：获取 `,` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `,` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let elementType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 VArrayType 实例
    let vArrayType = VArrayType(elementType, 10)
    
    let pos = vArrayType.getCommaPos()
    // 输出逗号位置
    println("vArrayType.getCommaPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
vArrayType.getCommaPos(): 1:13-1:14
```

### func getDollarPos()

```cangjie
public func getDollarPos(): CodePositionRange
```

功能：获取 `$` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `$` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let elementType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 VArrayType 实例
    let vArrayType = VArrayType(elementType, 10)
    
    let pos = vArrayType.getDollarPos()
    // 输出 $ 位置
    println("vArrayType.getDollarPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
vArrayType.getDollarPos(): 1:15-1:16
```

### func getLAnglePos()

```cangjie
public func getLAnglePos(): CodePositionRange
```

功能：获取 `<` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `<` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let elementType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 VArrayType 实例
    let vArrayType = VArrayType(elementType, 10)
    
    let pos = vArrayType.getLAnglePos()
    // 输出 < 位置
    println("vArrayType.getLAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
vArrayType.getLAnglePos(): 1:7-1:8
```

### func getRAnglePos()

```cangjie
public func getRAnglePos(): CodePositionRange
```

功能：获取 `>` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `>` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let elementType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 VArrayType 实例
    let vArrayType = VArrayType(elementType, 10)
    
    let pos = vArrayType.getRAnglePos()
    // 输出 > 位置
    println("vArrayType.getRAnglePos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
vArrayType.getRAnglePos(): 1:18-1:19
```

### func getVArrayPos()

```cangjie
public func getVArrayPos(): CodePositionRange
```

功能：获取 `VArray` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `VArray` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let elementType = AtomicType(AtomicTypeKind.Int64Type)

    // 创建 VArrayType 实例
    let vArrayType = VArrayType(elementType, 10)
    
    let pos = vArrayType.getVArrayPos()
    // 输出 VArray 关键字位置
    println("vArrayType.getVArrayPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
vArrayType.getVArrayPos(): 1:1-1:7
```

## class WhileExpr

```cangjie
public class WhileExpr <: Expr {
    public init(body: Block, condition: DisjunctionCondition, comments!: Array<Comment> = [])
}
```

功能：表示 `while` 表达式。

`while` 是关键字，`while` 之后是一个小括号，小括号内可以是一个表达式或者一个 `let` 声明的解构匹配，接着是一个 [Block](#class-block) 节点。

父类型：

- [Expr](#class-expr)

### prop body

```cangjie
public prop body: Block
```

功能：表示 `while` 循环的循环体。

类型：[Block](#class-block)

### prop condition

```cangjie
public prop condition: DisjunctionCondition
```

功能：表示 `while` 循环的条件。

类型：[DisjunctionCondition](#class-disjunctioncondition)

### init(Block, DisjunctionCondition, Array\<Comment>)

```cangjie
public init(body: Block, condition: DisjunctionCondition, comments!: Array<Comment> = [])
```

功能：构造一个 [WhileExpr](#class-whileexpr) 对象，表示 `while` 循环表达式。

参数：

- body: [Block](#class-block) - 循环体代码块。
- condition: [DisjunctionCondition](#class-disjunctioncondition) - 循环继续条件。
- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 body
    let body = Block([BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])

    // 创建 condition
    let condition = DisjunctionCondition([ConjunctionCondition(AtomicCondition.Expression(SymbolRef("x", [])))])

    // 创建 WhileExpr 实例
    let whileExpr = WhileExpr(body, condition)

    println("whileExpr: ${whileExpr}")
}
```

运行结果：

```text
whileExpr: while (x) {
    x + 1
}
```

### func getCondLParenPos()

```cangjie
public func getCondLParenPos(): CodePositionRange
```

功能：获取 [WhileExpr](#class-whileexpr) 节点中条件的 `(` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回条件的 `(` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 WhileExpr 实例
    let body = Block([BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])
    let condition = DisjunctionCondition([ConjunctionCondition(AtomicCondition.Expression(SymbolRef("x", [])))])
    let whileExpr = WhileExpr(body, condition)
    let pos = whileExpr.getCondLParenPos()

    // 输出条件左括号位置
    println("whileExpr.getCondLParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
whileExpr.getCondLParenPos(): 1:7-1:8
```

### func getCondRParenPos()

```cangjie
public func getCondRParenPos(): CodePositionRange
```

功能：获取 [WhileExpr](#class-whileexpr) 节点中条件的 `)` 的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回条件的 `)` 的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 WhileExpr 实例
    let body = Block([BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])
    let condition = DisjunctionCondition([ConjunctionCondition(AtomicCondition.Expression(SymbolRef("x", [])))])
    let whileExpr = WhileExpr(body, condition)
    let pos = whileExpr.getCondRParenPos()

    // 输出条件右括号位置
    println("whileExpr.getCondRParenPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
whileExpr.getCondRParenPos(): 1:9-1:10
```

### func getWhileKeyWordPos()

```cangjie
public func getWhileKeyWordPos(): CodePositionRange
```

功能：获取 [WhileExpr](#class-whileexpr) 节点中 `while` 关键字的位置。

返回值：

- [CodePositionRange](syntax_package_structs.md#struct-codepositionrange) - 返回 `while` 关键字的位置。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main(): Unit {
    // 创建 WhileExpr 实例
    let body = Block([BinaryExpr(SymbolRef("x", []), BinaryOpKind.Add, LitConstExpr(LitConstKind.IntergerLiteral, "1"))])
    let condition = DisjunctionCondition([ConjunctionCondition(AtomicCondition.Expression(SymbolRef("x", [])))])
    let whileExpr = WhileExpr(body, condition)
    let pos = whileExpr.getWhileKeyWordPos()

    // 输出 while 关键字位置
    println("whileExpr.getWhileKeyWordPos(): ${pos.beginLine}:${pos.beginColumn}-${pos.endLine}:${pos.endColumn}")
}
```

运行结果：

```text
whileExpr.getWhileKeyWordPos(): 1:1-1:6
```

## class WildcardPattern

```cangjie
public class WildcardPattern <: Pattern {
    public init(comments!: Array<Comment> = [])
}
```

功能：表示通配符模式节点。

父类型：

- [Pattern](#class-pattern)

### init(Array\<Comment>)

```cangjie
public init(comments!: Array<Comment> = [])
```

功能：构造一个 [WildcardPattern](#class-wildcardpattern) 对象，表示通配符模式 `_`。

参数：

- comments!: Array\<[Comment](#class-comment)> - 附加的注释列表，默认为空数组。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 WildcardPattern 实例
    let wildcardPattern = WildcardPattern()

    println("wildcardPattern: ${wildcardPattern}")
}
```

运行结果：

```text
wildcardPattern: _
```
