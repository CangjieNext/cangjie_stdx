# 类

> **排序**：下列各类按**类型名字母序**（A–Z）排列。

## class AnnoInfo

```cangjie
public class AnnoInfo <: ToString
```

功能：CHIR 节点上挂载的**一组**注解（`Annotation` 列表）。

父类型：

- ToString

### prop annoClasses / func toString()

---

## class Annotation

```cangjie
public class Annotation <: ToString
```

功能：单个**注解类**实例的文本化信息（类源码名、字段键值）。

父类型：

- ToString

### prop classSrcCodeName / func getFieldValue(fieldName: String) / func toString()

---

## class BoolType

```cangjie
public class BoolType <: BuiltinType & Equatable<BoolType>
```

功能：表示类型系统中的布尔类型。这是一个单例类型，表示 Bool 类型。

父类型：

- BuiltinType
- Equatable\<BoolType>

### static func get()

```cangjie
public static func get(): BoolType
```

功能：获取 BoolType 的单例实例。

返回值：

- BoolType - BoolType 实例。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let boolType = BoolType.get()
    println("布尔类型: ${boolType.toString()}")
}
```

运行结果：

```text
布尔类型: Bool
```

### operator func==(BoolType)

```cangjie
public operator func==(_: BoolType): Bool
```

功能：检查该 BoolType 是否与另一个 BoolType 相等。

参数：

- _: BoolType - 要比较的另一个 BoolType（未使用，始终返回 true）。

返回值：

- Bool - 始终返回 true，因为所有 BoolType 实例都相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let boolType1 = BoolType.get()
    let boolType2 = BoolType.get()
    println("两个 BoolType 相等: ${boolType1 == boolType2}")
}
```

运行结果：

```text
两个 BoolType 相等: true
```

## class BoxType

```cangjie
public class BoxType <: Type & Equatable<BoxType>
```

功能：表示**装箱类型** `Box<T>`，对值进行装箱包装。通过缓存保证同一 `baseType` 对应唯一实例。

父类型：

- Type
- Equatable\<BoxType>

### static func get(baseType: Type)

```cangjie
public static func get(baseType: Type): BoxType
```

功能：获取或创建指定基类型的 `BoxType`。

### prop baseType

```cangjie
public prop baseType: Type
```

功能：被装箱的基类型。

### func toString()

```cangjie
public func toString(): String
```

功能：字符串形式，一般为 `Box<...>` 风格。

### operator func==(BoxType)

```cangjie
public operator func ==(other: BoxType): Bool
```

功能：比较两个 `BoxType` 是否相同。

---

## class BuiltinType

```cangjie
sealed abstract class BuiltinType <: Type & Equatable<BuiltinType>
```

功能：内置类型（数值、Bool、Unit、指针、数组等）的公共基类；可附加 `ExtendDef`（`addExtend`），并通过 `getSuperTypesRecusively` 收集由 extend 实现的接口父类型。

父类型：

- Type
- Equatable\<BuiltinType>

### public 成员概要

| 成员 | 说明 |
|------|------|
| `operator func ==(other: BuiltinType)` | 同种类且类型参数相同则相等。 |
| `getSuperTypesRecusively(visited!)` | 从 extend 块实现的接口递归收集 `ClassLikeType` 父类型。 |
| `addExtend(extendDef: ExtendDef)` | 为本内置类型注册 extend 定义。 |

---

## class CPointerType

```cangjie
public class CPointerType <: BuiltinType & Equatable<CPointerType>
```

功能：表示类型系统中的 C 指针类型。该类型表示指向 C 类型的指针，用于与 C 代码互操作。该类维护所有 C 指针类型的缓存以确保唯一性。

父类型：

- BuiltinType
- Equatable\<CPointerType>

### prop elementType

```cangjie
public prop elementType: Type
```

功能：获取该 C 指针类型所指向的元素类型。

返回值：

- Type - 元素类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let cPointerType = CPointerType.get(intType)
    let elementType = cPointerType.elementType
    println("C 指针类型: ${cPointerType.toString()}")
    println("元素类型: ${elementType.toString()}")
}
```

运行结果：

```text
C 指针类型: CPointer<Int32>
元素类型: Int32
```

### operator func==(CPointerType)

```cangjie
public operator func==(other: CPointerType): Bool
```

功能：检查该 CPointerType 是否与另一个 CPointerType 相等。

参数：

- other: CPointerType - 要比较的 CPointerType。

返回值：

- Bool - 如果类型相等则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let cPointerType1 = CPointerType.get(intType)
    let cPointerType2 = CPointerType.get(intType)
    println("两个 C 指针类型相等: ${cPointerType1 == cPointerType2}")
}
```

运行结果：

```text
两个 C 指针类型相等: true
```

### static func get(Type)

```cangjie
public static func get(elementType: Type): CPointerType
```

功能：获取或创建给定元素类型的 CPointerType。

此方法确保每个元素类型只存在一个 CPointerType 实例。

参数：

- elementType: Type - 指针所指向的类型。

返回值：

- CPointerType - 给定元素类型的 CPointerType 实例。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let cPointerType = CPointerType.get(intType)
    println("C 指针类型: ${cPointerType.toString()}")
}
```

运行结果：

```text
C 指针类型: CPointer<Int32>
```

### func toString()

```cangjie
public func toString(): String
```

功能：将该 CPointerType 转换为字符串表示。

返回值：

- String - C 指针类型的字符串表示（CPointer\<elementType>）。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let cPointerType = CPointerType.get(intType)
    println("C 指针类型字符串: ${cPointerType.toString()}")
}
```

运行结果：

```text
C 指针类型字符串: CPointer<Int32>
```

## class CStringType

```cangjie
public class CStringType <: BuiltinType & Equatable<CStringType>
```

功能：表示类型系统中的 C 字符串类型。该类型表示 C 风格的空终止字符串，用于与 C 代码互操作。这是一个单例类型，表示内置的 C 字符串类型。

父类型：

- BuiltinType
- Equatable\<CStringType>

### operator func==(CStringType)

```cangjie
public operator func==(_: CStringType): Bool
```

功能：检查该 CStringType 是否与另一个 CStringType 相等。

参数：

- _: CStringType - 要比较的另一个 CStringType（未使用，始终返回 true）。

返回值：

- Bool - 始终返回 true，因为所有 CStringType 实例都相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let cStringType1 = CStringType.get()
    let cStringType2 = CStringType.get()
    println("两个 CStringType 相等: ${cStringType1 == cStringType2}")
}
```

运行结果：

```text
两个 CStringType 相等: true
```

### static func get()

```cangjie
public static func get(): CStringType
```

功能：获取 CStringType 的单例实例。

返回值：

- CStringType - CStringType 实例。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let cStringType = CStringType.get()
    println("C 字符串类型: ${cStringType.toString()}")
}
```

运行结果：

```text
C 字符串类型: CString
```

```cangjie
public operator func==(_: CStringType): Bool
```

功能：检查该 CStringType 是否与另一个 CStringType 相等。

参数：

- _: CStringType - 要比较的另一个 CStringType（未使用，始终返回 true）。

返回值：

- Bool - 始终返回 true，因为所有 CStringType 实例都相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let cStringType1 = CStringType.get()
    let cStringType2 = CStringType.get()
    println("两个 CStringType 相等: ${cStringType1 == cStringType2}")
}
```

运行结果：

```text
两个 CStringType 相等: true
```

## class ClassLikeDef

```cangjie
public class ClassLikeDef <: CustomTypeDef & Equatable<ClassLikeDef>
```

功能：**类或接口**的定义。

父类型：

- CustomTypeDef
- Equatable\<ClassLikeDef>

### 主要 public 成员

- `classType`、`superClass`、`isAnnotation`
- `setAbstract`、`setOpen`、`setSealed`
- `==`

---

## class ClassLikeType

```cangjie
public class ClassLikeType <: CustomType & Equatable<ClassLikeType>
```

功能：类或接口的**实例化类型**。`get(def, genericTypeParams)` 缓存唯一实例。

父类型：

- CustomType
- Equatable\<ClassLikeType>

### static func get(def: ClassLikeDef, genericTypeParams: Array\<Type>)

功能：按定义与泛型实参获取唯一 `ClassLikeType`。

### prop classLikeDef

功能：对应的 `ClassLikeDef`。

### operator func==(ClassLikeType)

功能：相等比较。

---

## class CustomType

```cangjie
sealed abstract class CustomType <: Type & Equatable<CustomType>
```

功能：用户自定义类型（类/接口/结构体/枚举）实例化类型的公共基类，持有 `CustomTypeDef` 与泛型实参。

父类型：

- Type
- Equatable\<CustomType>

### public 成员概要

| 成员 | 说明 |
|------|------|
| `def` | 对应的 `CustomTypeDef`。 |
| `genericTypeArgs` | 泛型实参数组。 |
| `allMemberVarNames` | 线性化后的成员名列表。 |
| `getExtendImplementedInterfaceTypes(visited!)` | 由 extend 实现的接口（实例化后）。 |
| `getImplementedInterfaceTypes(visited!)` | 直接实现 + extend 实现的接口。 |
| `getInstantiatedMemberVarTypes()` | 成员类型（已代入泛型）。 |
| `getMemberVarInstantiatedType(name)` | 按名称查找成员实例化类型。 |
| `getSuperTypesRecusively(visited!)` | 递归父类与接口。 |
| `getExtendDefs(visited!)` | 适用于当前实例的 extend 定义。 |
| `toString()` / `==` | 字符串与相等。 |

---

## class CustomTypeDef

```cangjie
sealed abstract class CustomTypeDef <: Base & Equatable<CustomTypeDef> & Hashable
```

功能：类/接口/结构体/枚举/扩展的**定义**公共基类（与 `Base` 组合，含属性、CHIR 注解、调试位置等）。

父类型：

- Base
- Equatable\<CustomTypeDef>
- Hashable

### 主要 public 能力

- **标识**：`identifier`、`srcCodeName`、`packageName`、`ty`、`hashCode`、`==`
- **泛型**：`genericTypeParams`、`genericDecl`
- **成员与继承**：`instanceVars`、`extends`、`implementedInterfaceTypes`
- **可见性与标记**：`setPublic` 等、`isImported`、`isAbstract`、`isOpen`、`isSealed`、`isGeneric` 等
- **分类**：`isClassLike`、`isClass`、`isInterface`、`isStruct`、`isEnum`、`isExtend`
- **其它**：`toString()`、`dump()`、`getSuperTypesRecusively`

受保护的打印辅助（`printTitle` 等）供子类重写，一般使用者通过 `toString()` 查看。

---

## class DebugLocation

```cangjie
public class DebugLocation <: ToString
```

功能：源码中的**区间位置**（起止 `Position` 与文件路径），用于调试与打印。

父类型：

- ToString

### prop start / prop end / prop filePath

### func isValid() / func toString()

## class EnumCtorInfo

```cangjie
public class EnumCtorInfo <: ToString
```

功能：枚举的一个**构造器/变体**（名称、内部名、函数类型、注解）。

父类型：

- ToString

### prop srcCodeName / prop identifier / prop funcType / mut prop annotations

### func toString()

---

## class EnumDef

```cangjie
public class EnumDef <: CustomTypeDef & Equatable<EnumDef>
```

功能：**枚举**定义；含是否穷尽、构造器列表等。

父类型：

- CustomTypeDef
- Equatable\<EnumDef>

### prop isExhaustive / prop constructors / prop enumType

### func appendEnumCtorInfo(mangledName, name, argTypes!)

### operator func==(EnumDef)

---

## class EnumType

```cangjie
public class EnumType <: CustomType & Equatable<EnumType>
```

功能：枚举的实例化类型；`get(def, genericTypeParams)` 缓存。

父类型：

- CustomType
- Equatable\<EnumType>

### static func get(def: EnumDef, genericTypeParams: Array\<Type>)

### prop enumDef

### operator func==(EnumType)

---

## class ExtendDef

```cangjie
public class ExtendDef <: CustomTypeDef
```

功能：**扩展（extend）**定义：对某类型增加实现等，带 `extendedType` 与泛型参数。

父类型：

- CustomTypeDef

### prop extendedType

（其余行为继承 `CustomTypeDef`，`srcCodeName` 在 extend 上可为空语义，见源码。）

---

## class FloatType

```cangjie
public class FloatType <: NumericType & Equatable<FloatType>
```

功能：表示类型系统中的浮点类型。该类表示三种浮点类型：Float16、Float32 和 Float64。

父类型：

- [NumericType](#class-numerictype)
- Equatable\<FloatType>

### static func getFloat16()

```cangjie
public static func getFloat16(): FloatType
```

功能：获取 Float16 类型实例。

返回值：

- FloatType - Float16 类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let float16Type = FloatType.getFloat16()
    println("Float16 类型: ${float16Type.toString()}")
}
```

运行结果：

```text
Float16 类型: Float16
```

### static func getFloat32()

```cangjie
public static func getFloat32(): FloatType
```

功能：获取 Float32 类型实例。

返回值：

- FloatType - Float32 类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let float32Type = FloatType.getFloat32()
    println("Float32 类型: ${float32Type.toString()}")
}
```

运行结果：

```text
Float32 类型: Float32
```

### static func getFloat64()

```cangjie
public static func getFloat64(): FloatType
```

功能：获取 Float64 类型实例。

返回值：

- FloatType - Float64 类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let float64Type = FloatType.getFloat64()
    println("Float64 类型: ${float64Type.toString()}")
}
```

运行结果：

```text
Float64 类型: Float64
```

### operator func==(FloatType)

```cangjie
public operator func==(other: FloatType): Bool
```

功能：检查该 FloatType 是否与另一个 FloatType 相等。

参数：

- other: FloatType - 要比较的 FloatType。

返回值：

- Bool - 如果类型相等则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let float32Type1 = FloatType.getFloat32()
    let float32Type2 = FloatType.getFloat32()
    let float64Type = FloatType.getFloat64()
    println("两个 Float32 相等: ${float32Type1 == float32Type2}")
    println("Float32 和 Float64 相等: ${float32Type1 == float64Type}")
}
```

运行结果：

```text
两个 Float32 相等: true
Float32 和 Float64 相等: false
```

## class FuncType

```cangjie
public class FuncType <: Type & Equatable<FuncType>
```

功能：函数类型（参数类型列表 + 返回类型），可选可变参数与 C 函数标记；按签名缓存。

父类型：

- Type
- Equatable\<FuncType>

### static func get(paramTypes: Array\<Type>, retType: Type, varArg!: Bool, cFunc!: Bool)

### prop hasVarArg / prop isCFunc / prop paramTypes / prop returnType

### func toString() / operator func==(FuncType)

---

## class GenericType

```cangjie
public class GenericType <: Type & Equatable<GenericType>
```

功能：泛型**形参**（如 `T`），可设置上界 `upperBounds`。按内部 `identifier` 缓存。

父类型：

- Type
- Equatable\<GenericType>

### static func get(identifier: String, srcCodeName: String)

### prop srcCodeName / mut prop upperBounds

### func toString() / operator func==(GenericType)

---

## class IntType

```cangjie
public class IntType <: NumericType & Equatable<IntType>
```

功能：表示类型系统中的整数类型。该类表示各种大小的有符号和无符号整数类型。

父类型：

- [NumericType](#class-numerictype)
- Equatable\<IntType>

### static func getInt16()

```cangjie
public static func getInt16(): IntType
```

功能：获取 Int16 类型实例。

返回值：

- IntType - Int16 类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let int16Type = IntType.getInt16()
    println("Int16 类型: ${int16Type.toString()}")
}
```

运行结果：

```text
Int16 类型: Int16
```

### static func getInt32()

```cangjie
public static func getInt32(): IntType
```

功能：获取 Int32 类型实例。

返回值：

- IntType - Int32 类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let int32Type = IntType.getInt32()
    println("Int32 类型: ${int32Type.toString()}")
}
```

运行结果：

```text
Int32 类型: Int32
```

### static func getInt64()

```cangjie
public static func getInt64(): IntType
```

功能：获取 Int64 类型实例。

返回值：

- IntType - Int64 类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let int64Type = IntType.getInt64()
    println("Int64 类型: ${int64Type.toString()}")
}
```

运行结果：

```text
Int64 类型: Int64
```

### static func getInt8()

```cangjie
public static func getInt8(): IntType
```

功能：获取 Int8 类型实例。

返回值：

- IntType - Int8 类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let int8Type = IntType.getInt8()
    println("Int8 类型: ${int8Type.toString()}")
}
```

运行结果：

```text
Int8 类型: Int8
```

### static func getIntNative()

```cangjie
public static func getIntNative(): IntType
```

功能：获取 IntNative 类型实例。

返回值：

- IntType - IntNative 类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intNativeType = IntType.getIntNative()
    println("IntNative 类型: ${intNativeType.toString()}")
}
```

运行结果：

```text
IntNative 类型: IntNative
```

### static func getUInt16()

```cangjie
public static func getUInt16(): IntType
```

功能：获取 UInt16 类型实例。

返回值：

- IntType - UInt16 类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let uint16Type = IntType.getUInt16()
    println("UInt16 类型: ${uint16Type.toString()}")
}
```

运行结果：

```text
UInt16 类型: UInt16
```

### static func getUInt32()

```cangjie
public static func getUInt32(): IntType
```

功能：获取 UInt32 类型实例。

返回值：

- IntType - UInt32 类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let uint32Type = IntType.getUInt32()
    println("UInt32 类型: ${uint32Type.toString()}")
}
```

运行结果：

```text
UInt32 类型: UInt32
```

### static func getUInt64()

```cangjie
public static func getUInt64(): IntType
```

功能：获取 UInt64 类型实例。

返回值：

- IntType - UInt64 类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let uint64Type = IntType.getUInt64()
    println("UInt64 类型: ${uint64Type.toString()}")
}
```

运行结果：

```text
UInt64 类型: UInt64
```

### static func getUInt8()

```cangjie
public static func getUInt8(): IntType
```

功能：获取 UInt8 类型实例。

返回值：

- IntType - UInt8 类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let uint8Type = IntType.getUInt8()
    println("UInt8 类型: ${uint8Type.toString()}")
}
```

运行结果：

```text
UInt8 类型: UInt8
```

### static func getUIntNative()

```cangjie
public static func getUIntNative(): IntType
```

功能：获取 UIntNative 类型实例。

返回值：

- IntType - UIntNative 类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let uintNativeType = IntType.getUIntNative()
    println("UIntNative 类型: ${uintNativeType.toString()}")
}
```

运行结果：

```text
UIntNative 类型: UIntNative
```

### operator func==(IntType)

```cangjie
public operator func==(other: IntType): Bool
```

功能：检查该 IntType 是否与另一个 IntType 相等。

参数：

- other: IntType - 要比较的 IntType。

返回值：

- Bool - 如果类型相等则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let int32Type1 = IntType.getInt32()
    let int32Type2 = IntType.getInt32()
    let int64Type = IntType.getInt64()
    println("两个 Int32 相等: ${int32Type1 == int32Type2}")
    println("Int32 和 Int64 相等: ${int32Type1 == int64Type}")
}
```

运行结果：

```text
两个 Int32 相等: true
Int32 和 Int64 相等: false
```

### func isSigned()

```cangjie
public func isSigned(): Bool
```

功能：检查该整数类型是否为有符号类型。

返回值：

- Bool - 如果类型是有符号的则返回 true，如果是无符号的则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let int32Type = IntType.getInt32()
    let uint32Type = IntType.getUInt32()
    println("Int32 是有符号的: ${int32Type.isSigned()}")
    println("UInt32 是有符号的: ${uint32Type.isSigned()}")
}
```

运行结果：

```text
Int32 是有符号的: true
UInt32 是有符号的: false
```

## class MemberVar

```cangjie
public class MemberVar <: ToString
```

功能：描述自定义类型上的**成员变量**（名称、类型、位置、注解、访问修饰等）。

父类型：

- ToString

### 主要 public 成员

| 类别 | 成员 |
|------|------|
| 属性 | `name`、`ty`、`location`、`annoInfo`、`outerDef` |
| 修饰 | `setReadOnly`、`setPublic`、`setPrivate`、`setProtected`、`setInternal` |
| 查询 | `isReadOnly`、`isPublic`、`isPrivate`、`isProtected`、`isInternal` |
| 其它 | `toString()`、`dump()` |

---

## class NothingType

```cangjie
public class NothingType <: BuiltinType & Equatable<NothingType>
```

功能：表示类型系统中的 Nothing 类型（底部类型）。该类型用于表示永远不会返回的表达式。

父类型：

- BuiltinType
- Equatable\<NothingType>

### static func get()

```cangjie
public static func get(): NothingType
```

功能：获取 NothingType 的单例实例。

返回值：

- NothingType - NothingType 实例。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let nothingType = NothingType.get()
    println("Nothing 类型: ${nothingType.toString()}")
}
```

运行结果：

```text
Nothing 类型: Nothing
```

### operator func==(NothingType)

```cangjie
public operator func==(_: NothingType): Bool
```

功能：检查该 NothingType 是否与另一个 NothingType 相等。

参数：

- _: NothingType - 要比较的另一个 NothingType（未使用，始终返回 true）。

返回值：

- Bool - 始终返回 true，因为所有 NothingType 实例都相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let nothingType1 = NothingType.get()
    let nothingType2 = NothingType.get()
    println("两个 NothingType 相等: ${nothingType1 == nothingType2}")
}
```

运行结果：

```text
两个 NothingType 相等: true
```

## class NumericType

```cangjie
sealed abstract class NumericType <: BuiltinType & Equatable<NumericType>
```

功能：数值类型的抽象基类。该类表示数值类型，包括整数类型和浮点类型。

父类型：

- BuiltinType
- Equatable\<NumericType>

### operator func==(NumericType)

```cangjie
public operator func==(other: NumericType): Bool
```

功能：检查该数值类型是否与另一个数值类型相等。

参数：

- other: NumericType - 要比较的数值类型。

返回值：

- Bool - 如果类型相等则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType1 = IntType.getInt32()
    let intType2 = IntType.getInt32()
    let floatType = FloatType.getFloat32()
    println("两个 Int32 相等: ${intType1 == intType2}")
    println("Int32 和 Float32 相等: ${intType1 == floatType}")
}
```

运行结果：

```text
两个 Int32 相等: true
Int32 和 Float32 相等: false
```

## class Package

```cangjie
public class Package <: ToString
```

功能：表示一个 **CHIR 包**：名称、访问级别、导入与本包内的类型定义集合。

父类型：

- ToString

### init(name: String, accessLevel: AccessLevel)

### prop name / prop accessLevel

### prop importedClassDefs / importedEnumDefs / importedStructDefs / importedExtendDefs

### prop classDefs / enumDefs / structDefs / extendDefs

### func addClass / addImportedClass / addStruct / addImportedStruct / addEnum / addImportedEnum / addExtend / addImportedExtend

### func getSpecifiedClassDef / getSpecifiedStructDef / getSpecifiedEnumDef

### func toString() / dump()

---

## class RawArrayType

```cangjie
public class RawArrayType <: BuiltinType & Equatable<RawArrayType>
```

功能：**原始数组**类型，带元素类型与维度数 `dims`。使用缓存按 `(elementType, dims)` 唯一化。

父类型：

- BuiltinType
- Equatable\<RawArrayType>

### static func get(elementType: Type, dims: UInt32)

```cangjie
public static func get(elementType: Type, dims: UInt32): RawArrayType
```

功能：获取或创建原始数组类型。

### prop elementType / prop dims

```cangjie
public prop elementType: Type
public prop dims: UInt32
```

功能：元素类型与维数。

### func toString() / operator func==(RawArrayType)

功能：字符串化与相等比较。

---

## class RefType

```cangjie
public class RefType <: Type & Equatable<RefType>
```

功能：表示类型系统中的引用类型。该类型包装另一个类型以表示对该类型的引用。该类维护所有引用类型的缓存以确保唯一性。

父类型：

- [Type](#class-type)
- Equatable\<RefType>

### prop baseType

```cangjie
public prop baseType: Type
```

功能：获取该引用类型所引用的基类型。

返回值：

- Type - 基类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let refType = RefType.get(intType)
    let baseType = refType.baseType
    println("引用类型: ${refType.toString()}")
    println("基类型: ${baseType.toString()}")
}
```

运行结果：

```text
引用类型: Int32&
基类型: Int32
```

### operator func==(RefType)

```cangjie
public operator func==(other: RefType): Bool
```

功能：检查该 RefType 是否与另一个 RefType 相等。

参数：

- other: RefType - 要比较的 RefType。

返回值：

- Bool - 如果类型相等则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let refType1 = RefType.get(intType)
    let refType2 = RefType.get(intType)
    println("两个引用类型相等: ${refType1 == refType2}")
}
```

运行结果：

```text
两个引用类型相等: true
```

### static func get(Type)

```cangjie
public static func get(baseType: Type): RefType
```

功能：获取或创建给定基类型的 RefType。

此方法确保每个基类型只存在一个 RefType 实例。

参数：

- baseType: Type - 要创建引用的基类型。

返回值：

- RefType - 给定基类型的 RefType 实例。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let refType = RefType.get(intType)
    println("引用类型: ${refType.toString()}")
}
```

运行结果：

```text
引用类型: Int32&
```

### func toString()

```cangjie
public func toString(): String
```

功能：将该 RefType 转换为字符串表示。

返回值：

- String - 引用类型的字符串表示（基类型后跟 '&'）。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let refType = RefType.get(intType)
    println("引用类型字符串: ${refType.toString()}")
}
```

运行结果：

```text
引用类型字符串: Int32&
```

## class RuneType

```cangjie
public class RuneType <: BuiltinType & Equatable<RuneType>
```

功能：表示类型系统中的 Rune 类型。该类型表示字符类型。

父类型：

- BuiltinType
- Equatable\<RuneType>

### static func get()

```cangjie
public static func get(): RuneType
```

功能：获取 RuneType 的单例实例。

返回值：

- RuneType - RuneType 实例。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let runeType = RuneType.get()
    println("Rune 类型: ${runeType.toString()}")
}
```

运行结果：

```text
Rune 类型: Rune
```

### operator func==(RuneType)

```cangjie
public operator func==(_: RuneType): Bool
```

功能：检查该 RuneType 是否与另一个 RuneType 相等。

参数：

- _: RuneType - 要比较的另一个 RuneType（未使用，始终返回 true）。

返回值：

- Bool - 始终返回 true，因为所有 RuneType 实例都相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let runeType1 = RuneType.get()
    let runeType2 = RuneType.get()
    println("两个 RuneType 相等: ${runeType1 == runeType2}")
}
```

运行结果：

```text
两个 RuneType 相等: true
```

## class StructDef

```cangjie
public class StructDef <: CustomTypeDef & Equatable<StructDef>
```

功能：**结构体**定义；`isCStruct` 表示 C 互操作结构体。

父类型：

- CustomTypeDef
- Equatable\<StructDef>

### prop structType / mut prop isCStruct / operator func==(StructDef)

---

## class StructType

```cangjie
public class StructType <: CustomType & Equatable<StructType>
```

功能：结构体的实例化类型；`get(def, genericTypeParams)` 缓存。

父类型：

- CustomType
- Equatable\<StructType>

### static func get(def: StructDef, genericTypeParams: Array\<Type>)

### prop structDef

### operator func==(StructType)

---

## class ThisType

```cangjie
public class ThisType <: Type & Equatable<ThisType>
```

功能：类/结构体体内的 **`This`** 类型，单例。

父类型：

- Type
- Equatable\<ThisType>

### static func get()

### operator func==(_: ThisType)

---

## class TupleType

```cangjie
public class TupleType <: Type & Equatable<TupleType>
```

功能：元组类型；按元素类型序列签名缓存。

父类型：

- Type
- Equatable\<TupleType>

### static func get(elementTypes: Array\<Type>)

### prop elementTypes

### func toString() / operator func==(TupleType)

---

## class Type

```cangjie
sealed abstract class Type <: ToString & Hashable & Equatable<Type>
```

功能：类型系统中所有类型的抽象基类。该类提供了类型的基础功能，包括相等性比较、哈希计算和字符串转换。

父类型：

- ToString
- Hashable
- Equatable\<Type>

### prop typeArgs

```cangjie
public prop typeArgs: Array<Type>
```

功能：获取该类型的类型参数。

返回值：

- Array\<Type> - 类型参数数组。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    println("类型参数数量: ${intType.typeArgs.size}")
}
```

运行结果：

```text
类型参数数量: 0
```

### func dump()

```cangjie
public func dump(): Unit
```

功能：将类型的字符串表示打印到标准输出。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    intType.dump()
}
```

运行结果：

```text
Int32
```

### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取该类型的哈希码。

返回值：

- Int64 - 类型的哈希码。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    println("哈希码: ${intType.hashCode()}")
}
```

运行结果：

```text
哈希码: -7959616418923165251
```

### func isBoolType()

```cangjie
public func isBoolType(): Bool
```

功能：检查该类型是否为布尔类型。

返回值：

- Bool - 如果类型是 Bool 则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let boolType = BoolType.get()
    let intType = IntType.getInt32()
    println("BoolType 是布尔类型: ${boolType.isBoolType()}")
    println("Int32 是布尔类型: ${intType.isBoolType()}")
}
```

运行结果：

```text
BoolType 是布尔类型: true
Int32 是布尔类型: false
```

### func isFloatType()

```cangjie
public func isFloatType(): Bool
```

功能：检查该类型是否为浮点类型。

返回值：

- Bool - 如果类型是 Float16、Float32 或 Float64 则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let floatType = FloatType.getFloat32()
    let intType = IntType.getInt32()
    println("Float32 是浮点类型: ${floatType.isFloatType()}")
    println("Int32 是浮点类型: ${intType.isFloatType()}")
}
```

运行结果：

```text
Float32 是浮点类型: true
Int32 是浮点类型: false
```

### func isIntType()

```cangjie
public func isIntType(): Bool
```

功能：检查该类型是否为整数类型（有符号或无符号）。

返回值：

- Bool - 如果类型是任何整数类型则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let floatType = FloatType.getFloat32()
    println("Int32 是整数类型: ${intType.isIntType()}")
    println("Float32 是整数类型: ${floatType.isIntType()}")
}
```

运行结果：

```text
Int32 是整数类型: true
Float32 是整数类型: false
```

### func isNothingType()

```cangjie
public func isNothingType(): Bool
```

功能：检查该类型是否为 Nothing 类型。

返回值：

- Bool - 如果类型是 Nothing 则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let nothingType = NothingType.get()
    let intType = IntType.getInt32()
    println("NothingType 是 Nothing 类型: ${nothingType.isNothingType()}")
    println("Int32 是 Nothing 类型: ${intType.isNothingType()}")
}
```

运行结果：

```text
NothingType 是 Nothing 类型: true
Int32 是 Nothing 类型: false
```

### func isNumericType()

```cangjie
public func isNumericType(): Bool
```

功能：检查该类型是否为数值类型（整数或浮点数）。

返回值：

- Bool - 如果类型是数值类型则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let floatType = FloatType.getFloat32()
    let boolType = BoolType.get()
    println("Int32 是数值类型: ${intType.isNumericType()}")
    println("Float32 是数值类型: ${floatType.isNumericType()}")
    println("Bool 是数值类型: ${boolType.isNumericType()}")
}
```

运行结果：

```text
Int32 是数值类型: true
Float32 是数值类型: true
Bool 是数值类型: false
```

### func isPrimitiveType()

```cangjie
public func isPrimitiveType(): Bool
```

功能：检查该类型是否为原始类型。

返回值：

- Bool - 如果类型是原始类型（int、float、bool、rune、unit 或 nothing）则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let boolType = BoolType.get()
    println("Int32 是原始类型: ${intType.isPrimitiveType()}")
    println("Bool 是原始类型: ${boolType.isPrimitiveType()}")
}
```

运行结果：

```text
Int32 是原始类型: true
Bool 是原始类型: true
```

### func isRefType()

```cangjie
public func isRefType(): Bool
```

功能：检查该类型是否为引用类型。

返回值：

- Bool - 如果类型是引用类型则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let refType = RefType.get(intType)
    println("Int32 是引用类型: ${intType.isRefType()}")
    println("Int32& 是引用类型: ${refType.isRefType()}")
}
```

运行结果：

```text
Int32 是引用类型: false
Int32& 是引用类型: true
```

### func isRuneType()

```cangjie
public func isRuneType(): Bool
```

功能：检查该类型是否为 Rune 类型。

返回值：

- Bool - 如果类型是 Rune 则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let runeType = RuneType.get()
    let intType = IntType.getInt32()
    println("RuneType 是 Rune 类型: ${runeType.isRuneType()}")
    println("Int32 是 Rune 类型: ${intType.isRuneType()}")
}
```

运行结果：

```text
RuneType 是 Rune 类型: true
Int32 是 Rune 类型: false
```

### func isSignedIntType()

```cangjie
public func isSignedIntType(): Bool
```

功能：检查该类型是否为有符号整数类型。

返回值：

- Bool - 如果类型是有符号整数类型则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let uintType = IntType.getUInt32()
    println("Int32 是有符号整数: ${intType.isSignedIntType()}")
    println("UInt32 是有符号整数: ${uintType.isSignedIntType()}")
}
```

运行结果：

```text
Int32 是有符号整数: true
UInt32 是有符号整数: false
```

### func isUnitType()

```cangjie
public func isUnitType(): Bool
```

功能：检查该类型是否为 Unit 类型。

返回值：

- Bool - 如果类型是 Unit 则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let unitType = UnitType.get()
    let intType = IntType.getInt32()
    println("UnitType 是 Unit 类型: ${unitType.isUnitType()}")
    println("Int32 是 Unit 类型: ${intType.isUnitType()}")
}
```

运行结果：

```text
UnitType 是 Unit 类型: true
Int32 是 Unit 类型: false
```

### func isUnsignedIntType()

```cangjie
public func isUnsignedIntType(): Bool
```

功能：检查该类型是否为无符号整数类型。

返回值：

- Bool - 如果类型是无符号整数类型则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let uintType = IntType.getUInt32()
    println("Int32 是无符号整数: ${intType.isUnsignedIntType()}")
    println("UInt32 是无符号整数: ${uintType.isUnsignedIntType()}")
}
```

运行结果：

```text
Int32 是无符号整数: false
UInt32 是无符号整数: true
```

### operator func==(Type)

```cangjie
public open operator func==(other: Type): Bool
```

功能：检查该类型是否与另一个类型相等。

参数：

- other: Type - 要比较的类型。

返回值：

- Bool - 如果类型具有相同的种类和类型参数则返回 true，否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let type1 = IntType.getInt32()
    let type2 = IntType.getInt32()
    let type3 = IntType.getInt64()
    println("type1 == type2: ${type1 == type2}")
    println("type1 == type3: ${type1 == type3}")
}
```

运行结果：

```text
type1 == type2: true
type1 == type3: false
```

### func stripAllRefs()

```cangjie
public func stripAllRefs(): Type
```

功能：去除该类型的所有引用包装。

递归地移除所有 Ref 类型包装，直到到达非引用类型。

返回值：

- Type - 去除所有引用包装后的基类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let refType = RefType.get(intType)
    let baseType = refType.stripAllRefs()
    println("引用类型: ${refType.toString()}")
    println("去除引用后: ${baseType.toString()}")
}
```

运行结果：

```text
引用类型: Int32&
去除引用后: Int32
```

### func toString()

```cangjie
public open func toString(): String
```

功能：将类型转换为字符串表示。

返回值：

- String - 类型的字符串表示。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    println("类型: ${intType.toString()}")
}
```

运行结果：

```text
类型: Int32
```

## class UnitType

```cangjie
public class UnitType <: BuiltinType & Equatable<UnitType>
```

功能：表示类型系统中的 Unit 类型。该类型表示没有有意义的值，类似于 C 语言中的 void。

父类型：

- BuiltinType
- Equatable\<UnitType>

### static func get()

```cangjie
public static func get(): UnitType
```

功能：获取 UnitType 的单例实例。

返回值：

- UnitType - UnitType 实例。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let unitType = UnitType.get()
    println("Unit 类型: ${unitType.toString()}")
}
```

运行结果：

```text
Unit 类型: Unit
```

### operator func==(UnitType)

```cangjie
public operator func==(_: UnitType): Bool
```

功能：检查该 UnitType 是否与另一个 UnitType 相等。

参数：

- _: UnitType - 要比较的另一个 UnitType（未使用，始终返回 true）。

返回值：

- Bool - 始终返回 true，因为所有 UnitType 实例都相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let unitType1 = UnitType.get()
    let unitType2 = UnitType.get()
    println("两个 UnitType 相等: ${unitType1 == unitType2}")
}
```

运行结果：

```text
两个 UnitType 相等: true
```

## class VArrayType

```cangjie
public class VArrayType <: BuiltinType & Equatable<VArrayType>
```

功能：**定长 VArray** 类型 `VArray<T, $n>`，编译期固定长度。按 `(elementType, size)` 缓存唯一实例。

父类型：

- BuiltinType
- Equatable\<VArrayType>

### static func get(elementType: Type, size: Int64)

```cangjie
public static func get(elementType: Type, size: Int64): VArrayType
```

功能：获取或创建 VArray 类型。

### prop elementType / prop size

```cangjie
public prop elementType: Type
public prop size: Int64
```

功能：元素类型与长度。

### func toString() / operator func==(VArrayType)

功能：字符串化与相等比较。

---
