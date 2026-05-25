# 枚举

## enum AssignOpKind

```cangjie
public enum AssignOpKind {
    | AddAssign
    | AndAssign
    | Assign
    | BitAndAssign
    | BitOrAssign
    | BitXorAssign
    | DivAssign
    | ExpAssign
    | LShiftAssign
    | ModAssign
    | MulAssign
    | OrAssign
    | RShiftAssign
    | SubAssign
    | ...
}
```

功能：表示赋值操作符的类型。

### AddAssign

```cangjie
AddAssign
```

功能：表示 `+=` 类型的赋值操作符。

### AndAssign

```cangjie
AndAssign
```

功能：表示 `&&=` 类型的赋值操作符。

### Assign

```cangjie
Assign
```

功能：表示 `=` 类型的赋值操作符。

### BitAndAssign

```cangjie
BitAndAssign
```

功能：表示 `&=` 类型的赋值操作符。

### BitOrAssign

```cangjie
BitOrAssign
```

功能：表示 `|=` 类型的赋值操作符。

### BitXorAssign

```cangjie
BitXorAssign
```

功能：表示 `^=` 类型的赋值操作符。

### DivAssign

```cangjie
DivAssign
```

功能：表示 `/=` 类型的赋值操作符。

### ExpAssign

```cangjie
ExpAssign
```

功能：表示 `**=` 类型的赋值操作符。

### LShiftAssign

```cangjie
LShiftAssign
```

功能：表示 `<<=` 类型的赋值操作符。

### ModAssign

```cangjie
ModAssign
```

功能：表示 `%=` 类型的赋值操作符。

### MulAssign

```cangjie
MulAssign
```

功能：表示 `*=` 类型的赋值操作符。

### OrAssign

```cangjie
OrAssign
```

功能：表示 `||=` 类型的赋值操作符。

### RShiftAssign

```cangjie
RShiftAssign
```

功能：表示 `>>=` 类型的赋值操作符。

### SubAssign

```cangjie
SubAssign
```

功能：表示 `-=` 类型的赋值操作符。

## enum AtomicCondition

```cangjie
public enum AtomicCondition {
    | LetPatternCondition(LetPattern)
    | Expression(Expr)
    | ParenConditionConstructor(ParenCondition)
    | ...
}
```

功能：表示原子类型的条件或 `let` 声明的解构匹配。

### Expression(Expr)

```cangjie
Expression(Expr)
```

功能：表示式类型的条件。

### LetPatternCondition(LetPattern)

```cangjie
LetPatternCondition(LetPattern)
```

功能：表示 `let` 声明。

### ParenConditionConstructor(ParenCondition)

```cangjie
ParenConditionConstructor(ParenCondition)
```

功能：表示有括号修饰的条件。

## enum AtomicTypeKind

```cangjie
public enum AtomicTypeKind {
    | BoolType
    | Float16Type
    | Float32Type
    | Float64Type
    | Int16Type
    | Int32Type
    | Int64Type
    | Int8Type
    | IntNativeType
    | NothingType
    | RuneType
    | ThisType
    | UInt16Type
    | UInt32Type
    | UInt64Type
    | UInt8Type
    | UIntNativeType
    | UnitType
    | ...
}
```

功能：表示原子类型的种类。

### BoolType

```cangjie
BoolType
```

功能：表示 `Bool` 基本类型。

### Float16Type

```cangjie
Float16Type
```

功能：表示 16 位浮点数基本类型。

### Float32Type

```cangjie
Float32Type
```

功能：表示 32 位浮点数基本类型。

### Float64Type

```cangjie
Float64Type
```

功能：表示 64 位浮点数基本类型。

### Int16Type

```cangjie
Int16Type
```

功能：表示 16 位有符号整数基本类型。

### Int32Type

```cangjie
Int32Type
```

功能：表示 32 位有符号整数基本类型。

### Int64Type

```cangjie
Int64Type
```

功能：表示 64 位有符号整数基本类型。

### Int8Type

```cangjie
Int8Type
```

功能：表示 8 位有符号整数基本类型。

### IntNativeType

```cangjie
IntNativeType
```

功能：表示平台原生大小的有符号整数基本类型。

### NothingType

```cangjie
NothingType
```

功能：表示空类型（无值类型）。

### RuneType

```cangjie
RuneType
```

功能：表示 `Unicode` 字符基本类型。

### ThisType

```cangjie
ThisType
```

功能：表示 `this` 类型。

### UInt16Type

```cangjie
UInt16Type
```

功能：表示 16 位无符号整数基本类型。

### UInt32Type

```cangjie
UInt32Type
```

功能：表示 32 位无符号整数基本类型。

### UInt64Type

```cangjie
UInt64Type
```

功能：表示 64 位无符号整数基本类型。

### UInt8Type

```cangjie
UInt8Type
```

功能：表示 8 位无符号整数基本类型。

### UIntNativeType

```cangjie
UIntNativeType
```

功能：表示平台原生大小的无符号整数基本类型。

### UnitType

```cangjie
UnitType
```

功能：表示 `Unit` 类型。

## enum AtOpKind

```cangjie
public enum AtOpKind {
    | At
    | AtExcl
    | ...
}
```

功能：表示注解的操作符类型。

### At

```cangjie
At
```

功能：表示 `@` 类型的注解操作符。

### AtExcl

```cangjie
AtExcl
```

功能：表示 `@!` 类型的注解操作符。

## enum BinaryOpKind

```cangjie
public enum BinaryOpKind {
    | Add
    | And
    | BitAnd
    | BitOr
    | BitXor
    | Coalescing
    | Composition
    | Div
    | Equal
    | Exp
    | Ge
    | Gt
    | Le
    | LShift
    | Lt
    | Mod
    | Mul
    | NotEq
    | Or
    | Pipeline
    | RShift
    | Sub
    | ...
}
```

功能：表示二元表达式的操作符类型。

### Add

```cangjie
Add
```

功能：表示 `+` 类型的二元操作符。

### And

```cangjie
And
```

功能：表示逻辑与 `&&` 类型的二元操作符。

### BitAnd

```cangjie
BitAnd
```

功能：表示按位与 `&` 类型的二元操作符。

### BitOr

```cangjie
BitOr
```

功能：表示按位或 `|` 类型的二元操作符。

### BitXor

```cangjie
BitXor
```

功能：表示按位异或 `^` 类型的二元操作符。

### Coalescing

```cangjie
Coalescing
```

功能：表示空值合并 `??` 类型的二元操作符。

### Composition

```cangjie
Composition
```

功能：表示函数组合 `~>` 类型的二元操作符。

### Div

```cangjie
Div
```

功能：表示除法 `/` 类型的二元操作符。

### Equal

```cangjie
Equal
```

功能：表示相等比较 `==` 类型的二元操作符。

### Exp

```cangjie
Exp
```

功能：表示指数运算 `**` 类型的二元操作符。

### Ge

```cangjie
Ge
```

功能：表示大于等于 `>=` 类型的二元操作符。

### Gt

```cangjie
Gt
```

功能：表示大于 `>` 类型的二元操作符。

### Le

```cangjie
Le
```

功能：表示小于等于 `<=` 类型的二元操作符。

### LShift

```cangjie
LShift
```

功能：表示左移位 `<<` 类型的二元操作符。

### Lt

```cangjie
Lt
```

功能：表示小于 `<` 类型的二元操作符。

### Mod

```cangjie
Mod
```

功能：表示取模 `%` 类型的二元操作符。

### Mul

```cangjie
Mul
```

功能：表示乘法 `*` 类型的二元操作符。

### NotEq

```cangjie
NotEq
```

功能：表示不等于 `!=` 类型的二元操作符。

### Or

```cangjie
Or
```

功能：表示逻辑或 `||` 类型的二元操作符。

### Pipeline

```cangjie
Pipeline
```

功能：表示管道操作 `|>` 类型的二元操作符。

### RShift

```cangjie
RShift
```

功能：表示右移位 `>>` 类型的二元操作符。

### Sub

```cangjie
Sub
```

功能：表示减法 `-` 类型的二元操作符。

## enum CommentKind

```cangjie
public enum CommentKind {
    | Block
    | Document
    | Line
    | ...
}
```

功能：表示语法树节点注释信息的类型。

### Block

```cangjie
Block
```

功能：表示注释信息 `/* */` 的块注释类型。

### Document

```cangjie
Document
```

功能：表示注释信息 `/** */` 的文档注释类型。

### Line

```cangjie
Line
```

功能：表示注释信息 `//` 的行注释类型。

## enum DiagnosticInfo

```cangjie
public enum DiagnosticInfo {
    | Error(String, String)
    | Warning(String, String)
    | ...
}
```

功能：表示语法树诊断信息的类型。

### Error(String, String)

```cangjie
Error(String, String)
```

功能：构造一个 `(String, String)` 类型的 [DiagnosticInfo](#enum-diagnosticinfo) 实例，表示语法分析发现的错误。

### Warning(String, String)

```cangjie
Warning(String, String)
```

功能：构造一个 `(String, String)` 类型的 [DiagnosticInfo](#enum-diagnosticinfo) 实例，表示语法分析发现的告警。

## enum FuncKind

```cangjie
public enum FuncKind {
    | Constructor
    | Finalizer
    | Foreign
    | Normal
    | Operator
    | PrimaryConstructor
    | ...
}
```

功能：表示声明函数的类型。

### Constructor

```cangjie
Constructor
```

功能：表示一个构造函数，通常用于初始化对象。如 `init(srcVal: Expr, targetTypeAnnotation: TypeAnnotation)`。

### Finalizer

```cangjie
Finalizer
```

功能：表示一个终结器函数，负责在对象被垃圾回收之前执行清理操作。如 `~init()`。

### Foreign

```cangjie
Foreign
```

功能：表示一个外部函数，通常用于调用外部库中的函数。如 `foreign func CjStdSyncStateInit(capacity: Int64): CPointer<UInt8>`。

### Normal

```cangjie
Normal
```

功能：表示一个普通函数，通常用于执行一系列语句。如 `public func hasInterpolation(): Bool`。

### Operator

```cangjie
Operator
```

功能：表示一个操作符函数，通常用于重载操作符。如 `public operator func !=(right: TokenKind): Bool`。

### PrimaryConstructor

```cangjie
PrimaryConstructor
```

功能：表示一个主构造函数，通常用于初始化对象。如 `User(val name: String, var age: Int)`。

## enum ImportKind

```cangjie
public enum ImportKind {
    | Alias 
    | All 
    | Multi 
    | Single 
    | ...
}
```

功能：表示导入语句的类型。

### Alias

```cangjie
Alias
```

功能：表示别名导入，如 `import a.b as c`。

### All

```cangjie
All
```

功能：表示全导入，如 `import a.b.*`。

### Multi

```cangjie
Multi
```

功能：表示多导入，如 `import a.{b, c, d}`。

### Single

```cangjie
Single
```

功能：表示单导入，如 `import a.b`。

## enum IncOrDecOpKind

```cangjie
public enum IncOrDecOpKind {
    | Decr
    | Incr
    | ...
}
```

功能：表示自增自减表达式的操作符类型。

### Decr

```cangjie
Decr
```

功能：表示 `--` 类型的操作符。

### Incr

```cangjie
Incr
```

功能：表示 `++` 类型的操作符。

## enum LitConstKind

```cangjie
public enum LitConstKind {
    | BoolLiteral
    | FloatLiteral
    | IntergerLiteral
    | RuneLiteral
    | StringLiteral
    | UnitLiteral
    | ...
}
```

功能：表示字面量表达式的类型。

### BoolLiteral

```cangjie
BoolLiteral
```

功能：表示布尔类型字面量，如 `true`。

### FloatLiteral

```cangjie
FloatLiteral
```

功能：表示浮点数类型字面量，如 `1.0`。

### IntergerLiteral

```cangjie
IntergerLiteral
```

功能：表示整形字面量，如 `1`。

### RuneLiteral

```cangjie
RuneLiteral
```

功能：表示字符字面量，如 `r'a'`。

### StringLiteral

```cangjie
StringLiteral
```

功能：表示字符串字面量，如 `"hello"`。

### UnitLiteral

```cangjie
UnitLiteral
```

功能：表示 `Unit` 类型的字面量，如 `()`。

## enum LitConstStrKind

```cangjie
public enum LitConstStrKind {
    | JStringLiteral
    | MultiLineString
    | MultiLineRawString
    | StringLiteral
    | ...
}
```

功能：表示字符串字面量表达式的类型。

### JStringLiteral

```cangjie
JStringLiteral
```

功能：表示 `JavaString` 类型的字符串字面量，如 `J"xx"`。

### MultiLineRawString

```cangjie
MultiLineRawString
```

功能：表示多行原始字符串字面量，如 `#"aaa"#`。

### MultiLineString

```cangjie
MultiLineString
```

功能：表示多行字符串字面量，如 `"""aaa"""`。

### StringLiteral

```cangjie
StringLiteral
```

功能：表示单行字符串字面量，如 `'xx'`。

## enum MacroExpandInput

```cangjie
public enum MacroExpandInput {
    | WithoutParens(Decl)
    | WithParens(Tokens)
    | ...
}
```

功能：表示宏展开的输入形式，区分不同的宏调用语法形式。

### WithoutParens(Decl)

```cangjie
WithoutParens(Decl)
```

功能：表示无括号形式的宏输入，直接以声明作为宏参数。

### WithParens(Tokens)

```cangjie
WithParens(Tokens)
```

功能：表示带括号形式的宏输入，括号内包含标记序列作为宏参数。

## enum ModifierKind

```cangjie
public enum ModifierKind {
    | Abstract
    | Internal
    | Mut
    | Open
    | Operator
    | Override
    | Private
    | Protected
    | Public
    | Redef
    | Sealed
    | Static
    | Unsafe
    | Const
    | ...
}
```

功能：表示修饰符的类型。

### Abstract

```cangjie
Abstract
```

功能：表示 `abstract` 类型的修饰符。

### Const

```cangjie
Const
```

功能：表示 `const` 类型的修饰符。

### Internal

```cangjie
Internal
```

功能：表示 `internal` 类型的修饰符。

### Mut

```cangjie
Mut
```

功能：表示 `mut` 类型的修饰符。

### Open

```cangjie
Open
```

功能：表示 `open` 类型的修饰符。

### Operator

```cangjie
Operator
```

功能：表示 `operator` 类型的修饰符。

### Override

```cangjie
Override
```

功能：表示 `override` 类型的修饰符。

### Private

```cangjie
Private
```

功能：表示 `private` 类型的修饰符。

### Protected

```cangjie
Protected
```

功能：表示 `protected` 类型的修饰符。

### Public

```cangjie
Public
```

功能：表示 `public` 类型的修饰符。

### Redef

```cangjie
Redef
```

功能：表示 `redef` 类型的修饰符。

### Sealed

```cangjie
Sealed
```

功能：表示 `sealed` 类型的修饰符。

### Static

```cangjie
Static
```

功能：表示 `static` 类型的修饰符。

### Unsafe

```cangjie
Unsafe
```

功能：表示 `unsafe` 类型的修饰符。

### operator func !=(ModifierKind)

```cangjie
public operator func !=(rhs: ModifierKind): Bool
```

功能：判断当前修饰符类型是否与传入的修饰符类型不相等。

参数：

- rhs: [ModifierKind](#enum-modifierkind) - 要比较的修饰符类型。

返回值：

- Bool - 如果两个修饰符类型不相等，则返回 `true`；否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 ModifierKind
    let publicKind = ModifierKind.Public
    let internalKind = ModifierKind.Internal

    println("publicKind == publicKind: ${publicKind == publicKind}")
    println("publicKind == internalKind: ${publicKind == internalKind}")
}
```

运行结果：

```text
publicKind == publicKind: true
publicKind == internalKind: false
```

### operator func ==(ModifierKind)

```cangjie
public operator func ==(rhs: ModifierKind): Bool
```

功能：判断当前修饰符类型是否与传入的修饰符类型相等。

参数：

- rhs: [ModifierKind](#enum-modifierkind) - 要比较的修饰符类型。

返回值：

- Bool - 如果两个修饰符类型相等，则返回 `true`；否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 创建 ModifierKind
    let publicKind = ModifierKind.Public
    let internalKind = ModifierKind.Internal

    println("publicKind != publicKind: ${publicKind != publicKind}")
    println("publicKind != internalKind: ${publicKind != internalKind}")
}
```

运行结果：

```text
publicKind != publicKind: false
publicKind != internalKind: true
```

## enum PostActionMode

```cangjie
public enum PostActionMode {
    | Continue
    | Stop
    | ...
}
```

功能：控制 ASTVisitor 在访问节点完成后的行为策略。

### Continue

```cangjie
Continue
```

功能：`func postAction` 的默认策略，继续遍历。

### Stop

```cangjie
Stop
```

功能：立即停止整个遍历过程。

## enum PreActionMode

```cangjie
public enum PreActionMode {
    | Continue
    | Skip
    | Stop
    | ...
}
```

功能：控制 ASTVisitor 在访问节点前的行为策略。

### Continue

```cangjie
Continue
```

功能：`func preAction` 的默认策略，继续访问当前节点及其所有子节点。

### Skip

```cangjie
Skip
```

功能：跳过当前节点的子节点。

### Stop

```cangjie
Stop
```

功能：立即停止整个遍历过程。

## enum PrefixTypeOpKind

```cangjie
public enum PrefixTypeOpKind {
    | Quest
    | ...
}
```

功能：表示前缀类型中的前缀操作符类型。

### Quest

```cangjie
Quest
```

功能：表示 `?` 类型的前缀操作符。

## enum QuoteExprContent

```cangjie
public enum QuoteExprContent{
    | TokenPart(QuoteToken)
    | QuoteInterpolation(QuoteInterpolationExpr)
    | ...
}
```

功能：表示 `quote` 表达式中由 `()` 括起的内容类型。

### QuoteInterpolation(QuoteInterpolationExpr)

```cangjie
QuoteInterpolation(QuoteInterpolationExpr)
```

功能：表示 [QuoteInterpolationExpr](syntax_package_classes.md#class-quoteinterpolationexpr) 类型的 `quote` 表达式部分。

### TokenPart(QuoteToken)

```cangjie
TokenPart(QuoteToken)
```

功能：表示 [QuoteToken](syntax_package_classes.md#class-quotetoken) 类型的 `quote` 表达式部分。

## enum RangeKind

```cangjie
public enum RangeKind {
    | ClosedRangeOp
    | RangeOp
    | ...
}
```

功能：表示区间表达式的操作符类型。

### ClosedRangeOp

```cangjie
ClosedRangeOp
```

功能：表示 `:=` 类型的区间操作符。

### RangeOp

```cangjie
RangeOp
```

功能：表示 `:` 类型的区间操作符。

## enum StrLiteralPart

```cangjie
public enum StrLiteralPart {
    | LitConstPart(LitConstExpr)
    | StrInterpolation(StrInterpolationContent)
    | ...
}
```

功能：表示字符串常量的不同部分，分为字面量常量部分和字符串插值部分。

### LitConstPart(LitConstExpr)

```cangjie
LitConstPart(LitConstExpr)
```

功能：构造一个 [LitConstExpr](syntax_package_classes.md#class-litconstexpr) 类型的 [StrLiteralPart](#enum-strliteralpart) 实例，表示字面量常量部分。

### StrInterpolation(StrInterpolationContent)

```cangjie
StrInterpolation(StrInterpolationContent)
```

功能：构造一个 [StrInterpolationContent](syntax_package_classes.md#class-strinterpolationcontent) 类型的 [StrLiteralPart](#enum-strliteralpart) 实例，表示字符串插值部分。

## enum UnaryOpKind

```cangjie
public enum UnaryOpKind {
    | Not
    | Sub
    | ...
}
```

功能：表示一元表达式的操作符类型。

### Not

```cangjie
Not
```

功能：表示 `!` 类型的一元操作符。

### Sub

```cangjie
Sub
```

功能：表示 `-` 类型的一元操作符。

## enum VarKind

```cangjie
public enum VarKind {
    | Const
    | Let
    | Var
    | ...
}
```

功能：表示变量声明表达式的类型。

### Const

```cangjie
Const
```

功能：表示声明一个字面量，如 `const PI = 3.14159`。

### Let

```cangjie
Let
```

功能：表示声明一个不可变变量，如 `let a = 1`，`a` 的值为 1 且不可变。

### Var

```cangjie
Var
```

功能：表示声明一个不可变变量，如 `var a = 1`，`a` 的值为 1，可被重新赋值。
