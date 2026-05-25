# 类

## class Annotation

```cangjie
public class Annotation <: ToString
```

功能：表示 CHIR 中**一处**注解实例，对应源码形态 `@ClassName[k1=v1, k2=v2]`：保存注解类名及参数字段名到字符串值的映射。

父类型：

- ToString

### prop classSrcCodeName

```cangjie
public prop classSrcCodeName: String
```

功能：注解类在源码中的名称。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let a = Annotation("MyAnno")
    println(a.classSrcCodeName)
}
```

运行结果：

```text
MyAnno
```

### init(String)

```cangjie
public init(classSrcCodeName: String)
```

功能：构造一个 `Annotation` 对象，指定注解类名且**参数表初始为空**；可通过 [`setFieldValue`](#func-setfieldvaluestring-string) 写入键值。

参数：

- classSrcCodeName: String - 源码中的注解类名（如 `MyAnno`）。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let a = Annotation("Fresh")
    println(a.toString())
}
```

运行结果：

```text
@Fresh[]
```

### func getFieldValue(String)

```cangjie
public func getFieldValue(fieldName: String): ?String
```

功能：按键名查找注解参数；若不存在则返回 `None`。

参数：

- fieldName: String - 参数字段名（与 `toString()` 中 `key=value` 的键一致）。

返回值：

- ?String - 有则 `Some(字符串值)`，否则 `None`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let a = Annotation("A")
    if (let None <- a.getFieldValue("noSuchKey")) {
        println("missing")
    }
}
```

运行结果：

```text
missing
```

### func setFieldValue(String, String)

```cangjie
public func setFieldValue(fieldName: String, value: String): Unit
```

功能：设置或覆盖某一参数字段的字符串值（构建或测试 CHIR 时使用）。

参数：

- fieldName: String - 参数名。
- value: String - 参数值（字符串形式）。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let a = Annotation("S")
    a.setFieldValue("path", "/tmp")
    println(a.toString())
}
```

运行结果：

```text
@S[path=/tmp]
```

### func toString()

```cangjie
public func toString(): String
```

功能：格式化为 `@ClassName[k1=v1, k2=v2]`，便于日志与调试。

返回值：

- String - 注解的文本形式。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let a = Annotation("T")
    println(a.toString())
}
```

运行结果：

```text
@T[]
```

---

## class BoolType

```cangjie
public class BoolType <: BuiltinType & Equatable<BoolType>
```

功能：表示类型系统中的布尔类型。这是一个单例类型，表示 Bool 类型。

父类型：

- [BuiltinType](#class-builtintype)
- Equatable\<[BoolType](#class-booltype)>

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

- [Type](#class-type)
- Equatable\<[BoxType](#class-boxtype)>

### prop baseType

```cangjie
public prop baseType: Type
```

功能：被装箱的基类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let b = BoxType.get(IntType.getInt32())
    println(b.baseType.toString())
}
```

运行结果：

```text
Int32
```

### static func get(Type)

```cangjie
public static func get(baseType: Type): BoxType
```

功能：获取或创建指定基类型的 `BoxType`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let b = BoxType.get(IntType.getInt32())
    println(b.toString())
}
```

运行结果：

```text
Box<Int32>
```

### func toString()

```cangjie
public func toString(): String
```

功能：字符串形式，一般为 `Box<...>` 风格。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let b = BoxType.get(IntType.getUInt32())
    println(b.toString())
}
```

运行结果：

```text
Box<UInt32>
```

### operator func==(BoxType)

```cangjie
public operator func ==(other: BoxType): Bool
```

功能：比较两个 `BoxType` 是否相同。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let base = IntType.getInt32()
    let b1 = BoxType.get(base)
    let b2 = BoxType.get(base)
    println("op_eq_BoxType: ${b1 == b2}")
}
```

运行结果：

```text
op_eq_BoxType: true
```

---

## class BuiltinType

```cangjie
sealed abstract class BuiltinType <: Type & Equatable<BuiltinType>
```

功能：内置类型（数值、Bool、Unit、指针、数组等）的公共基类；可附加 `ExtendDef`（`addExtend`），并通过 `getSuperTypesRecusively` 收集由 extend 实现的接口父类型。

父类型：

- [Type](#class-type)
- Equatable\<[BuiltinType](#class-builtintype)>

### func addExtend(ExtendDef)

```cangjie
public func addExtend(extendDef: ExtendDef): Unit
```

功能：为当前内置类型登记一条 [ExtendDef](#class-extenddef)（与源码中对该内置类型的 `extend` 块对应）。

参数：

- extendDef: ExtendDef - 扩展定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let ext = pkg.addExtend("ext_mangled", IntType.getInt32())
    IntType.getInt32().addExtend(ext)
    println("extend id: ${ext.identifier}")
}
```

运行结果：

```text
extend id: @ext_mangled
```

（具体 `identifier` 前缀与 mangling 规则以源码为准。）

### func getSuperTypesRecusively(ArrayList\<(Type, Type)>)

```cangjie
public func getSuperTypesRecusively(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType>
```

功能：从本类型上通过 `extend` 所实现的接口出发，递归收集父接口/父类侧的 [ClassLikeType](#class-classliketype)（用于语义与继承分析）。

参数：

- visited! - 环检测用访问表；一般可传默认空表。

返回值：

- Array\<ClassLikeType> - 收集到的类型序列。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = IntType.getInt32()
    println("${t.getSuperTypesRecusively().size}")
}
```

运行结果：

```text
0
```

### operator func==(BuiltinType)

```cangjie
public operator func==(other: BuiltinType): Bool
```

功能：比较两个内置类型是否表示同一类及相同类型实参。

参数：

- other: BuiltinType - 另一内置类型。

返回值：

- Bool - 相等则为 `true`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let a = IntType.getInt32()
    let b = IntType.getInt32()
    let c = IntType.getInt64()
    println("op_eq_BuiltinType sameInt32: ${a == b}")
    println("op_eq_BuiltinType int32vsInt64: ${a == c}")
}
```

运行结果：

```text
op_eq_BuiltinType sameInt32: true
op_eq_BuiltinType int32vsInt64: false
```

## class CPointerType

```cangjie
public class CPointerType <: BuiltinType & Equatable<CPointerType>
```

功能：表示类型系统中的 C 指针类型。该类型表示指向 C 类型的指针，用于与 C 代码互操作。该类维护所有 C 指针类型的缓存以确保唯一性。

父类型：

- [BuiltinType](#class-builtintype)
- Equatable\<[CPointerType](#class-cpointertype)>

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
    let cp = CPointerType.get(intType)
    println(cp.elementType.toString())
}
```

运行结果：

```text
Int32
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
    println(cPointerType.toString())
}
```

运行结果：

```text
CPointer<Int32>
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
    let cPointerType = CPointerType.get(IntType.getUInt32())
    println(cPointerType.toString())
}
```

运行结果：

```text
CPointer<UInt32>
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
    println("op_eq_CPointerType: ${cPointerType1 == cPointerType2}")
}
```

运行结果：

```text
op_eq_CPointerType: true
```

## class CStringType

```cangjie
public class CStringType <: BuiltinType & Equatable<CStringType>
```

功能：表示类型系统中的 C 字符串类型。该类型表示 C 风格的空终止字符串，用于与 C 代码互操作。这是一个单例类型，表示内置的 C 字符串类型。

父类型：

- [BuiltinType](#class-builtintype)
- Equatable\<[CStringType](#class-cstringtype)>

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
    println(cStringType.toString())
}
```

运行结果：

```text
CString
```

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
    println("op_eq_CStringType: ${cStringType1 == cStringType2}")
}
```

运行结果：

```text
op_eq_CStringType: true
```

## class ClassLikeDef

```cangjie
public class ClassLikeDef <: CustomTypeDef & Equatable<ClassLikeDef>
```

功能：**类或接口**的定义。

父类型：

- [CustomTypeDef](#class-customtypedef)
- Equatable\<[ClassLikeDef](#class-classlikedef)>

### prop classType

```cangjie
public prop classType: ClassLikeType
```

功能：与此定义对应的 [ClassLikeType](#class-classliketype)。

类型：[ClassLikeType](#class-classliketype)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    println("prop_classType: ${def.classType.classLikeDef == def}")
}
```

运行结果：

```text
prop_classType: true
```

### prop isAnnotation

```cangjie
public mut prop isAnnotation: Bool
```

功能：是否为注解类。

类型：Bool

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    println(def.isAnnotation)
}
```

运行结果：

```text
false
```

### prop superClass

```cangjie
public mut prop superClass: ?ClassLikeType
```

功能：父类；无父类时为 `None`。

类型：?[ClassLikeType](#class-classliketype)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    println("mut_prop_superClass: ${def.superClass.isNone()}")
}
```

运行结果：

```text
mut_prop_superClass: true
```

### func setAbstract(Bool)

```cangjie
public func setAbstract(enable: Bool): Unit
```

功能：设置或清除 `abstract` 标记。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    def.setAbstract(true)
    println("fn_setAbstract: ${def.isAbstract()}")
}
```

运行结果：

```text
fn_setAbstract: true
```

### func setOpen(Bool)

```cangjie
public func setOpen(enable: Bool): Unit
```

功能：设置或清除 `open`（可继承/虚）相关标记。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    def.setOpen(true)
    println("fn_setOpen: ${def.isOpen()}")
}
```

运行结果：

```text
fn_setOpen: true
```

### func setSealed(Bool)

```cangjie
public func setSealed(enable: Bool): Unit
```

功能：设置或清除 `sealed` 标记。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    def.setSealed(true)
    println("fn_setSealed: ${def.isSealed()}")
}
```

运行结果：

```text
fn_setSealed: true
```

### operator func==(ClassLikeDef)

```cangjie
public operator func==(other: ClassLikeDef): Bool
```

功能：比较是否同一类/接口定义。

参数：

- other: ClassLikeDef - 另一定义。

返回值：

- Bool - 是否相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    println("op_eq_ClassLikeDef: ${def == def}")
}
```

运行结果：

```text
op_eq_ClassLikeDef: true
```

---

## class ClassLikeType

```cangjie
public class ClassLikeType <: CustomType & Equatable<ClassLikeType>
```

功能：类或接口的**实例化类型**。`get(def, genericTypeParams)` 缓存唯一实例。

父类型：

- [CustomType](#class-customtype)
- Equatable\<[ClassLikeType](#class-classliketype)>

### prop classLikeDef

```cangjie
public prop classLikeDef: ClassLikeDef
```

功能：对应的 [ClassLikeDef](#class-classlikedef)。

类型：[ClassLikeDef](#class-classlikedef)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("C_m", "C", true)
    let ty = ClassLikeType.get(d, [])
    println(ty.classLikeDef.srcCodeName)
}
```

运行结果：

```text
C
```

### static func get(ClassLikeDef, Array\<Type>)

```cangjie
public static func get(def: ClassLikeDef, genericTypeParams: Array<Type>): ClassLikeType
```

功能：按定义与泛型实参取得或创建缓存中的唯一实例。

参数：

- def: ClassLikeDef - 类/接口定义。
- genericTypeParams: Array\<Type> - 泛型实参（非泛型时为空数组）。

返回值：

- ClassLikeType - 实例化类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("C_m", "C", true)
    let ty = ClassLikeType.get(d, [])
    println("static_get: ${ty.classLikeDef.identifier.size > 0}")
}
```

运行结果：

```text
static_get: true
```

### operator func==(ClassLikeType)

```cangjie
public operator func==(other: ClassLikeType): Bool
```

功能：比较是否为同一实例化类/接口类型。

参数：

- other: ClassLikeType - 另一类型。

返回值：

- Bool - 是否相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("C_m", "C", true)
    let ty1 = ClassLikeType.get(d, [])
    let ty2 = ClassLikeType.get(d, [])
    println("op_eq_ClassLikeType: ${ty1 == ty2}")
}
```

运行结果：

```text
op_eq_ClassLikeType: true
```

---

## class CustomType

```cangjie
sealed abstract class CustomType <: Type & Equatable<CustomType>
```

功能：用户自定义类型（类/接口/结构体/枚举）实例化类型的公共基类，持有 `CustomTypeDef` 与泛型实参。

父类型：

- [Type](#class-type)
- Equatable\<[CustomType](#class-customtype)>

子类包括 [ClassLikeType](#class-classliketype)、[StructType](#class-structtype)、[EnumType](#class-enumtype) 等。

### prop allMemberVarNames

```cangjie
public prop allMemberVarNames: Array<String>
```

功能：自超类链线性化后直至本类型声明的全部实例成员名。

类型：Array\<String>

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    d.appendInstanceMemberVar("x", IntType.getInt32())
    let st = StructType.get(d, [])
    println("${st.allMemberVarNames.size}")
}
```

运行结果：

```text
1
```

### prop def

```cangjie
public prop def: CustomTypeDef
```

功能：对应的类型定义节点。

类型：[CustomTypeDef](#class-customtypedef)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println(st.def.srcCodeName)
}
```

运行结果：

```text
S
```

### prop genericTypeArgs

```cangjie
public prop genericTypeArgs: Array<Type>
```

功能：泛型实参列表（非泛型时为空）。

类型：Array\<Type>

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println("${st.genericTypeArgs.size}")
}
```

运行结果：

```text
0
```

### func getExtendDefs(ArrayList\<(Type, Type)>)

```cangjie
public func getExtendDefs(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ExtendDef>
```

功能：返回 `def.extends` 中 `extendedType` 与当前类型可匹配的 extend 定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println("${st.getExtendDefs().size}")
}
```

运行结果：

```text
0
```

### func getExtendImplementedInterfaceTypes(ArrayList\<(Type, Type)>)

```cangjie
public func getExtendImplementedInterfaceTypes(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType>
```

功能：收集适用于当前实例的 `extend` 块所实现的接口（已代入泛型）。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println("${st.getExtendImplementedInterfaceTypes().size}")
}
```

运行结果：

```text
0
```

### func getImplementedInterfaceTypes(ArrayList\<(Type, Type)>)

```cangjie
public func getImplementedInterfaceTypes(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType>
```

功能：`extend` 实现的接口与定义上 `implementedInterfaceTypes` 的并集（已实例化）。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println("${st.getImplementedInterfaceTypes().size}")
}
```

运行结果：

```text
0
```

### func getInstantiatedMemberVarTypes()

```cangjie
public func getInstantiatedMemberVarTypes(): Array<Type>
```

功能：与 `allMemberVarNames` 对齐的成员类型，已按当前泛型实参替换。

返回值：

- Array\<Type> - 成员实例化类型序列。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    d.appendInstanceMemberVar("x", IntType.getInt32())
    let st = StructType.get(d, [])
    println("${st.getInstantiatedMemberVarTypes().size}")
}
```

运行结果：

```text
1
```

### func getMemberVarInstantiatedType(String)

```cangjie
public func getMemberVarInstantiatedType(name: String): Type
```

功能：按成员名查找实例化后的成员类型（自内向外遮蔽）。

参数：

- name: String - 成员源码名。

返回值：

- Type - 成员类型。

异常：

- Exception - 未找到该成员名时抛出。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    d.appendInstanceMemberVar("x", IntType.getInt32())
    let st = StructType.get(d, [])
    println(st.getMemberVarInstantiatedType("x").toString())
}
```

运行结果：

```text
Int32
```

### func getSuperTypesRecusively(ArrayList\<(Type, Type)>)

```cangjie
public func getSuperTypesRecusively(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType>
```

功能：递归收集父类与接口父类型（已实例化）。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println("${st.getSuperTypesRecusively().size}")
}
```

运行结果：

```text
0
```

### func toString()

```cangjie
public func toString(): String
```

功能：内部 kind、标识与泛型实参的紧凑字符串。

返回值：

- String - 文本形式。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println("fn_toString: ${st.toString().size > 0}")
}
```

运行结果：

```text
fn_toString: true
```

### operator func==(CustomType)

```cangjie
public operator func==(other: CustomType): Bool
```

功能：比较种类、定义与泛型实参是否一致。

参数：

- other: CustomType - 另一自定义实例化类型。

返回值：

- Bool - 是否相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println("op_eq_CustomType: ${st == StructType.get(d, [])}")
}
```

运行结果：

```text
op_eq_CustomType: true
```

---

## class CustomTypeDef

```cangjie
sealed abstract class CustomTypeDef <: Base & Equatable<CustomTypeDef> & Hashable
```

功能：类/接口/结构体/枚举/扩展的**定义**公共基类（与 `Base` 组合，含属性、CHIR 注解、调试位置等）。

父类型：

- Equatable\<[CustomTypeDef](#class-customtypedef)>
- Hashable

### prop identifier

```cangjie
public prop identifier: String
```

功能：内部标识，全局唯一标识符。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("prop_identifier: ${d.identifier.size > 0}")
}
```

运行结果：

```text
prop_identifier: true
```

### prop srcCodeName

```cangjie
public prop srcCodeName: String
```

功能：源码中的类型名（extend 等场景可能为空串，见源码注释）。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.srcCodeName)
}
```

运行结果：

```text
X
```

### prop packageName

```cangjie
public prop packageName: String
```

功能：所属包名。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.packageName)
}
```

运行结果：

```text
p
```

### prop ty

```cangjie
public prop ty: Type
```

功能：对普通定义为实例化类型；对 [ExtendDef](#class-extenddef) 为 `extendedType`。

类型：[Type](#class-type)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("prop_ty: ${d.ty.toString().size > 0}")
}
```

运行结果：

```text
prop_ty: true
```

### prop genericTypeParams

```cangjie
public prop genericTypeParams: Array<GenericType>
```

功能：泛型形参列表；非泛型或无法从类型实参反推时为空数组。

类型：Array\<[GenericType](#class-generictype)>

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("${d.genericTypeParams.size}")
}
```

运行结果：

```text
0
```

### prop genericDecl

```cangjie
public mut prop genericDecl: ?CustomTypeDef
```

功能：与当前**单态**定义配对的泛型模板定义；`set` 时校验种类、`srcCodeName` 及泛型约束（见源码断言）。

类型：?CustomTypeDef

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("mut_prop_genericDecl: ${d.genericDecl.isNone()}")
}
```

运行结果：

```text
mut_prop_genericDecl: true
```

### prop instanceVars

```cangjie
public prop instanceVars: Array<MemberVar>
```

功能：实例成员变量列表（声明顺序）。

类型：Array\<[MemberVar](#class-membervar)>

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("${d.instanceVars.size}")
}
```

运行结果：

```text
0
```

### prop extends

```cangjie
public mut prop extends: Array<ExtendDef>
```

功能：嵌套于该类型下的 `extend` 定义集合。

类型：Array\<[ExtendDef](#class-extenddef)>

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("${d.extends.size}")
}
```

运行结果：

```text
0
```

### prop implementedInterfaceTypes

```cangjie
public mut prop implementedInterfaceTypes: Array<ClassLikeType>
```

功能：直接实现的接口类型列表。

类型：Array\<[ClassLikeType](#class-classliketype)>

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("${d.implementedInterfaceTypes.size}")
}
```

运行结果：

```text
0
```

### func setPublic()

```cangjie
public func setPublic(): Unit
```

功能：标记为 `public` 可见性。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    d.setPublic()
    println("fn_setPublic: ${d.isPublic()}")
}
```

运行结果：

```text
fn_setPublic: true
```

### func setPrivate()

```cangjie
public func setPrivate(): Unit
```

功能：标记为 `private`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    d.setPrivate()
    println("fn_setPrivate: ${d.isPrivate()}")
}
```

运行结果：

```text
fn_setPrivate: true
```

### func setProtected()

```cangjie
public func setProtected(): Unit
```

功能：标记为 `protected`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    d.setProtected()
    println("fn_setProtected: ${d.isProtected()}")
}
```

运行结果：

```text
fn_setProtected: true
```

### func setInternal()

```cangjie
public func setInternal(): Unit
```

功能：标记为 `internal`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    d.setInternal()
    println("fn_setInternal: ${d.isInternal()}")
}
```

运行结果：

```text
fn_setInternal: true
```

### func isImported()

```cangjie
public func isImported(): Bool
```

功能：是否为从其它包导入的定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isImported())
}
```

运行结果：

```text
false
```

### func isPublic()

```cangjie
public func isPublic(): Bool
```

功能：是否带 `public` 属性。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isPublic())
}
```

运行结果：

```text
false
```

### func isPrivate()

```cangjie
public func isPrivate(): Bool
```

功能：是否带 `private` 属性。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isPrivate())
}
```

运行结果：

```text
false
```

### func isInternal()

```cangjie
public func isInternal(): Bool
```

功能：是否带 `internal` 属性。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isInternal())
}
```

运行结果：

```text
false
```

### func isProtected()

```cangjie
public func isProtected(): Bool
```

功能：是否带 `protected` 属性。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isProtected())
}
```

运行结果：

```text
false
```

### func isAbstract()

```cangjie
public func isAbstract(): Bool
```

功能：是否为 `abstract`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isAbstract())
}
```

运行结果：

```text
false
```

### func isOpen()

```cangjie
public func isOpen(): Bool
```

功能：是否可继承/实现（`virtual` 或 `abstract`）。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isOpen())
}
```

运行结果：

```text
false
```

### func isSealed()

```cangjie
public func isSealed(): Bool
```

功能：是否为 `sealed`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isSealed())
}
```

运行结果：

```text
false
```

### func isGeneric()

```cangjie
public func isGeneric(): Bool
```

功能：是否为泛型定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isGeneric())
}
```

运行结果：

```text
false
```

### func isClassLike()

```cangjie
public func isClassLike(): Bool
```

功能：种类是否为类/接口。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("fn_isClassLike: ${d.isClassLike()}")
}
```

运行结果：

```text
fn_isClassLike: true
```

### func isClass()

```cangjie
public func isClass(): Bool
```

功能：是否为类（非接口）。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("fn_isClass: ${d.isClass()}")
}
```

运行结果：

```text
fn_isClass: true
```

### func isInterface()

```cangjie
public func isInterface(): Bool
```

功能：是否为接口。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isInterface())
}
```

运行结果：

```text
false
```

### func isEnum()

```cangjie
public func isEnum(): Bool
```

功能：是否为枚举定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isEnum())
}
```

运行结果：

```text
false
```

### func isExtend()

```cangjie
public func isExtend(): Bool
```

功能：是否为 extend 定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isExtend())
}
```

运行结果：

```text
false
```

### func isStruct()

```cangjie
public func isStruct(): Bool
```

功能：是否为结构体定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isStruct())
}
```

运行结果：

```text
false
```

### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：定义的哈希码。

返回值：

- Int64 - 哈希值。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("fn_hashCode: ${d.hashCode() != 0}")
}
```

运行结果：

```text
fn_hashCode: true
```

### operator func==(CustomTypeDef)

```cangjie
public operator func==(other: CustomTypeDef): Bool
```

功能：按种类、标识、源码名与包名比较。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("op_eq_CustomTypeDef: ${d == d}")
}
```

运行结果：

```text
op_eq_CustomTypeDef: true
```

### func toString()

```cangjie
public open func toString(): String
```

功能：多行类/接口/枚举等形状文本（含属性、成员、`extend` 列表）。

返回值：

- String - 定义的可读转储。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("fn_toString: ${d.toString().size > 0}")
}
```

运行结果：

```text
fn_toString: true
```

### func dump()

```cangjie
public func dump(): Unit
```

功能：将 `toString()` 输出到标准输出。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    d.dump()
}
```

运行结果：

```text
[pluginAdded]class @X_m { // srcCodeName: X, packageName: p
}
```

### func appendInstanceMemberVar(String, Type)

```cangjie
public func appendInstanceMemberVar(name: String, ty: Type): MemberVar
```

功能：向当前类型定义**追加**一个实例成员变量（名称与类型），并返回对应的 [MemberVar](#class-membervar)。成员在 `instanceVars` 中的顺序与调用顺序一致；适用于插件或测试在 `Package.addClass` / `addStruct` 等创建定义之后挂载 CHIR 成员。

返回值：

- [MemberVar](#class-membervar) - 新创建的成员变量节点。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    let mv = d.appendInstanceMemberVar("f", IntType.getInt32())
    println(mv.name)
}
```

运行结果：

```text
f
```

### func getSuperTypesRecusively()

```cangjie
public func getSuperTypesRecusively(): Array<ClassLikeType>
```

功能：递归收集这个定义的所有父类，包括父类通过扩展实现的接口，但不包括本定义通过扩展实现的接口。

返回值：

- Array\<ClassLikeType> - 收集到的父类型；**不保证顺序**。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("${d.getSuperTypesRecusively().size}")
}
```

运行结果：

```text
0
```

---

## class DebugLocation

```cangjie
public class DebugLocation <: ToString
```

功能：源码中的**区间位置**（起止 `Position` 与文件路径），用于调试与打印。

父类型：

- ToString

### prop start

```cangjie
public prop start: Position
```

功能：区间起点（含），与 [struct Position](chir_package_structs.md#struct-position) 成对使用。

类型：[Position](chir_package_structs.md#struct-position)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.location.start.line)
}
```

运行结果：

```text
0
```

### prop end

```cangjie
public prop end: Position
```

功能：区间终点。

类型：[Position](chir_package_structs.md#struct-position)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.location.end.column)
}
```

运行结果：

```text
0
```

### prop filePath

```cangjie
public prop filePath: Path
```

功能：源文件路径（绝对或工程内路径，见 `std.fs.Path`）。

类型：Path

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println("prop_filePath: ${mv.location.filePath.isEmpty()}")
}
```

运行结果：

```text
prop_filePath: true
```

### func isValid()

```cangjie
public func isValid(): Bool
```

功能：当 `start`、`end` 均有效且 `filePath` 非空时返回 `true`。

返回值：

- Bool - 是否为可用调试区间。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.location.isValid())
}
```

运行结果：

```text
false
```

### func toString()

```cangjie
public func toString(): String
```

功能：无效时返回空串；否则输出文件名、`start`/`end` 的紧凑形式及可选 scope 链（见源码）。

返回值：

- String - 人类可读位置描述。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.location.toString().size)
}
```

运行结果：

```text
0
```

## class EnumCtorInfo

```cangjie
public class EnumCtorInfo <: ToString
```

功能：枚举的一个**构造器/变体**（名称、内部标识、函数类型、注解）。

父类型：

- ToString

### prop identifier

```cangjie
public prop identifier: String
```

功能：内部标识，全局唯一标识符。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    let ctor = e.appendEnumCtorInfo("A_m", "A")
    println("prop_identifier: ${ctor.identifier.size > 0}")
}
```

运行结果：

```text
prop_identifier: true
```

### prop funcType

```cangjie
public prop funcType: FuncType
```

功能：该变元的参数类型与返回类型（返回为所属枚举类型）的 [FuncType](#class-functype)。

类型：[FuncType](#class-functype)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    let ctor = e.appendEnumCtorInfo("A_m", "A")
    println("${ctor.funcType.paramTypes.size}")
}
```

运行结果：

```text
0
```

### prop srcCodeName

```cangjie
public prop srcCodeName: String
```

功能：源码中的构造器/变体名。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    let ctor = e.appendEnumCtorInfo("A_m", "A")
    println(ctor.srcCodeName)
}
```

运行结果：

```text
A
```

### prop annotations

```cangjie
public mut prop annotations: Array<Annotation>
```

功能：挂在此枚举构造器上的注解实例列表（内部由 `AnnoInfo` 存储，对外为 `Array<Annotation>`）；`set` 时整体替换。

类型：Array\<[Annotation](#class-annotation)>

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    let ctor = e.appendEnumCtorInfo("A_m", "A")
    let ann = Annotation("Marker")
    ann.setFieldValue("x", "1")
    ctor.annotations = [ann]
    println("${ctor.annotations.size}")
}
```

运行结果：

```text
1
```

### func toString()

```cangjie
public func toString(): String
```

功能：形如 `VariantName(paramTypes...)` 的简短描述（见源码）。

返回值：

- String - 构造器文本形式。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    let ctor = e.appendEnumCtorInfo("A_m", "A")
    println(ctor.toString())
}
```

运行结果：

```text
A
```

---

## class EnumDef

```cangjie
public class EnumDef <: CustomTypeDef & Equatable<EnumDef>
```

功能：**枚举**定义；含是否穷尽、构造器列表等。

父类型：

- [CustomTypeDef](#class-customtypedef)
- Equatable\<[EnumDef](#class-enumdef)>

### prop isExhaustive

```cangjie
public prop isExhaustive: Bool
```

功能：是否为**穷尽**枚举（与内部 `nonExhaustive` 标志相反）。

类型：Bool

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    println("prop_isExhaustive: ${e.isExhaustive}")
}
```

运行结果：

```text
prop_isExhaustive: true
```

### prop constructors

```cangjie
public prop constructors: Array<EnumCtorInfo>
```

功能：全部枚举构造器/变体，按声明顺序。

类型：Array\<[EnumCtorInfo](#class-enumctorinfo)>

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    e.appendEnumCtorInfo("A_m", "A")
    println("${e.constructors.size}")
}
```

运行结果：

```text
1
```

### prop enumType

```cangjie
public prop enumType: EnumType
```

功能：与此定义对应的实例化 [EnumType](#class-enumtype)。

类型：[EnumType](#class-enumtype)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    println("prop_enumType: ${e.enumType.enumDef == e}")
}
```

运行结果：

```text
prop_enumType: true
```

### func appendEnumCtorInfo(String, String, Array\<Type>)

```cangjie
public func appendEnumCtorInfo(identifier: String, name: String, argTypes!: Array<Type> = Array<Type>()): EnumCtorInfo
```

功能：追加一个枚举变元；无参变元可省略 `argTypes` 或传空数组。

参数：

- identifier: String - 全局唯一标识符。
- name: String - 源码变体名。
- argTypes!: Array\<Type> - 参数类型列表。

返回值：

- [EnumCtorInfo](#class-enumctorinfo) - 新创建的构造器信息。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_mangled", "E", true)
    let c = e.appendEnumCtorInfo("A_mangled", "A")
    println(c.srcCodeName)
}
```

运行结果：

```text
A
```

### operator func==(EnumDef)

```cangjie
public operator func==(other: EnumDef): Bool
```

功能：按定义标识比较是否同一枚举定义。

参数：

- other: EnumDef - 另一枚举定义。

返回值：

- Bool - 是否相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    println("op_eq_EnumDef: ${e == e}")
}
```

运行结果：

```text
op_eq_EnumDef: true
```

---

## class EnumType

```cangjie
public class EnumType <: CustomType & Equatable<EnumType>
```

功能：枚举的实例化类型；`get(def, genericTypeParams)` 缓存。

父类型：

- [CustomType](#class-customtype)
- Equatable\<[EnumType](#class-enumtype)>

### prop enumDef

```cangjie
public prop enumDef: EnumDef
```

功能：对应的 [EnumDef](#class-enumdef)。

类型：[EnumDef](#class-enumdef)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addEnum("E_m", "E", true)
    let t = EnumType.get(d, [])
    println(t.enumDef.srcCodeName)
}
```

运行结果：

```text
E
```

### static func get(EnumDef, Array\<Type>)

```cangjie
public static func get(def: EnumDef, genericTypeParams: Array<Type>): EnumType
```

功能：按枚举定义与泛型实参取得或创建缓存实例。

参数：

- def: EnumDef - 枚举定义。
- genericTypeParams: Array\<Type> - 泛型实参。

返回值：

- EnumType - 实例化枚举类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addEnum("E_m", "E", true)
    let t = EnumType.get(d, [])
    println(t.enumDef.srcCodeName)
}
```

运行结果：

```text
E
```

### operator func==(EnumType)

```cangjie
public operator func==(other: EnumType): Bool
```

功能：比较是否为同一实例化枚举类型。

参数：

- other: EnumType - 另一枚举类型。

返回值：

- Bool - 是否相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addEnum("E_m", "E", true)
    let t1 = EnumType.get(d, [])
    let t2 = EnumType.get(d, [])
    println("op_eq_EnumType: ${t1 == t2}")
}
```

运行结果：

```text
op_eq_EnumType: true
```

---

## class ExtendDef

```cangjie
public class ExtendDef <: CustomTypeDef
```

功能：**扩展（extend）**定义：对某类型增加实现等，带 `extendedType` 与泛型参数。

父类型：

- [CustomTypeDef](#class-customtypedef)

### prop extendedType

```cangjie
public prop extendedType: Type
```

功能：被扩展的目标类型（`extend T { ... }` 中的 `T`）。

类型：[Type](#class-type)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let ext = pkg.addExtend("ext_m", IntType.getInt32())
    println(ext.extendedType.toString())
}
```

运行结果：

```text
Int32
```

---

## class FloatType

```cangjie
public class FloatType <: NumericType & Equatable<FloatType>
```

功能：表示类型系统中的浮点类型。该类表示三种浮点类型：Float16、Float32 和 Float64。

父类型：

- [NumericType](#class-numerictype)
- Equatable\<[FloatType](#class-floattype)>

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

- [Type](#class-type)
- Equatable\<[FuncType](#class-functype)>

### prop hasVarArg

```cangjie
public prop hasVarArg: Bool
```

功能：是否为可变参数函数类型。

类型：Bool

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let i32 = IntType.getInt32()
    let f = FuncType.get([i32], i32)
    println(f.hasVarArg)
}
```

运行结果：

```text
false
```

### prop isCFunc

```cangjie
public prop isCFunc: Bool
```

功能：是否表示 C 函数类型（影响 `toString()` 前缀 `CFunc<...>`）。

类型：Bool

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let i32 = IntType.getInt32()
    let f = FuncType.get([i32], i32)
    println(f.isCFunc)
}
```

运行结果：

```text
false
```

### prop paramTypes

```cangjie
public prop paramTypes: Array<Type>
```

功能：形参类型数组。

类型：Array\<Type>

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let i32 = IntType.getInt32()
    let f = FuncType.get([i32], i32)
    println("${f.paramTypes.size}")
}
```

运行结果：

```text
1
```

### prop returnType

```cangjie
public prop returnType: Type
```

功能：返回类型。

类型：Type

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let i32 = IntType.getInt32()
    let f = FuncType.get([i32], i32)
    println(f.returnType.toString())
}
```

运行结果：

```text
Int32
```

### static func get(Array\<Type>, Type, Bool, Bool)

```cangjie
public static func get(paramTypes: Array<Type>, retType: Type, varArg!: Bool = false, cFunc!: Bool = false): FuncType
```

功能：按形参列表、返回类型及可变参/C 函数标记取得或创建唯一缓存实例。

参数：

- paramTypes: Array\<Type> - 形参类型序列。
- retType: Type - 返回类型。
- varArg! - 是否为可变参数函数类型，默认 `false`。
- cFunc! - 是否为 `CFunc<...>` 形式，默认 `false`。

返回值：

- FuncType - 函数类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let i32 = IntType.getInt32()
    let f = FuncType.get([i32], i32)
    println(f.toString())
}
```

运行结果：

```text
(Int32) -> Int32
```

### func toString()

```cangjie
public func toString(): String
```

功能：形如 `(T1, T2) -> R` 或 `CFunc<(T1)-> R>` 的字符串（见源码）。

返回值：

- String - 函数类型文本。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let u = IntType.getUInt32()
    let f = FuncType.get([u], UnitType.get())
    println(f.toString())
}
```

运行结果：

```text
(UInt32) -> Unit
```

### operator func==(FuncType)

```cangjie
public operator func==(other: FuncType): Bool
```

功能：比较签名、`varArg`、`cFunc` 是否一致。

参数：

- other: FuncType - 另一函数类型。

返回值：

- Bool - 是否相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let i32 = IntType.getInt32()
    let f1 = FuncType.get([i32], i32)
    let f2 = FuncType.get([i32], i32)
    println("op_eq_FuncType: ${f1 == f2}")
}
```

运行结果：

```text
op_eq_FuncType: true
```

---

## class GenericType

```cangjie
public class GenericType <: Type & Equatable<GenericType>
```

功能：泛型**形参**（如 `T`），可设置上界 `upperBounds`。按内部 `identifier` 缓存。

父类型：

- [Type](#class-type)
- Equatable\<[GenericType](#class-generictype)>

### prop srcCodeName

```cangjie
public prop srcCodeName: String
```

功能：源码中的泛型参数名（如 `T`）。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = GenericType.get("g:T", "T")
    println(t.srcCodeName)
}
```

运行结果：

```text
T
```

### prop upperBounds

```cangjie
public mut prop upperBounds: Array<Type>
```

功能：上界类型列表；赋值时会拒绝**值类型**上界（见源码校验）。

类型：Array\<Type>

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = GenericType.get("g:T", "T")
    println("${t.upperBounds.size}")
}
```

运行结果：

```text
0
```

### static func get(String, String)

```cangjie
public static func get(identifier: String, srcCodeName: String): GenericType
```

功能：按内部 `identifier` 缓存取得或创建泛型形参类型（如 `T`）。

参数：

- identifier: String - 内部唯一键（mangling 用）。
- srcCodeName: String - 源码中的形参名。

返回值：

- GenericType - 泛型形参类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = GenericType.get("g:T", "T")
    println("static_get: ${t.toString().size > 0}")
}
```

运行结果：

```text
static_get: true
```

### func toString()

```cangjie
public func toString(): String
```

功能：内部调试用字符串（含 kind 与 identifier）。

返回值：

- String - 文本形式。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = GenericType.get("g:U", "U")
    println("fn_toString: ${t.toString().size > 0}")
}
```

运行结果：

```text
fn_toString: true
```

### operator func==(GenericType)

```cangjie
public operator func==(other: GenericType): Bool
```

功能：比较是否为同一泛型形参节点。

参数：

- other: GenericType - 另一泛型形参。

返回值：

- Bool - 是否相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t1 = GenericType.get("g:T", "T")
    let t2 = GenericType.get("g:T", "T")
    println("op_eq_GenericType: ${t1 == t2}")
}
```

运行结果：

```text
op_eq_GenericType: true
```

---

## class IntType

```cangjie
public class IntType <: NumericType & Equatable<IntType>
```

功能：表示类型系统中的整数类型。该类表示各种大小的有符号和无符号整数类型。

父类型：

- [NumericType](#class-numerictype)
- Equatable\<[IntType](#class-inttype)>

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

功能：描述自定义类型上的**实例成员变量**（名称、类型、调试位置、注解与访问修饰等）。

父类型：

- ToString

### prop name

```cangjie
public prop name: String
```

功能：成员源码名。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.name)
}
```

运行结果：

```text
x
```

### prop ty

```cangjie
public prop ty: Type
```

功能：成员类型。

类型：[Type](#class-type)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.ty.toString())
}
```

运行结果：

```text
Int32
```

### prop location

```cangjie
public prop location: DebugLocation
```

功能：源码位置；未设置时可能为无效区间（见 [DebugLocation](#class-debuglocation)）。

类型：[DebugLocation](#class-debuglocation)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.location.isValid())
}
```

运行结果：

```text
false
```

### prop annotations

```cangjie
public mut prop annotations: Array<Annotation>
```

功能：成员上的注解实例列表（内部由 `AnnoInfo` 存储，对外为 `Array<Annotation>`）；`set` 时整体替换。

类型：Array\<[Annotation](#class-annotation)>

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println("${mv.annotations.size}")
}
```

运行结果：

```text
0
```

### prop outerDef

```cangjie
public prop outerDef: CustomTypeDef
```

功能：包含该成员的外层类型定义。

类型：[CustomTypeDef](#class-customtypedef)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.outerDef.srcCodeName)
}
```

运行结果：

```text
S
```

### func setReadOnly(Bool)

```cangjie
public func setReadOnly(enable: Bool): Unit
```

功能：设置或清除只读（`let` 语义）标记。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    mv.setReadOnly(true)
    println("fn_setReadOnly: ${mv.isReadOnly()}")
}
```

运行结果：

```text
fn_setReadOnly: true
```

### func setInternal()

```cangjie
public func setInternal(): Unit
```

功能：将成员标为 `internal`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    mv.setInternal()
    println("fn_setInternal: ${mv.isInternal()}")
}
```

运行结果：

```text
fn_setInternal: true
```

### func setPublic()

```cangjie
public func setPublic(): Unit
```

功能：将成员标为 `public`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    mv.setPublic()
    println("fn_setPublic: ${mv.isPublic()}")
}
```

运行结果：

```text
fn_setPublic: true
```

### func setPrivate()

```cangjie
public func setPrivate(): Unit
```

功能：将成员标为 `private`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    mv.setPrivate()
    println("fn_setPrivate: ${mv.isPrivate()}")
}
```

运行结果：

```text
fn_setPrivate: true
```

### func setProtected()

```cangjie
public func setProtected(): Unit
```

功能：将成员标为 `protected`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    mv.setProtected()
    println("fn_setProtected: ${mv.isProtected()}")
}
```

运行结果：

```text
fn_setProtected: true
```

### func isReadOnly()

```cangjie
public func isReadOnly(): Bool
```

功能：是否为只读成员。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.isReadOnly())
}
```

运行结果：

```text
false
```

### func isInternal()

```cangjie
public func isInternal(): Bool
```

功能：是否为 `internal`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.isInternal())
}
```

运行结果：

```text
false
```

### func isPublic()

```cangjie
public func isPublic(): Bool
```

功能：是否为 `public`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.isPublic())
}
```

运行结果：

```text
false
```

### func isPrivate()

```cangjie
public func isPrivate(): Bool
```

功能：是否为 `private`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.isPrivate())
}
```

运行结果：

```text
false
```

### func isProtected()

```cangjie
public func isProtected(): Bool
```

功能：是否为 `protected`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.isProtected())
}
```

运行结果：

```text
false
```

### func toString()

```cangjie
public func toString(): String
```

功能：属性前缀 + `let`/`var`、名称、类型及位置注释。

返回值：

- String - 单行成员描述。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println("fn_toString: ${mv.toString().size > 0}")
}
```

运行结果：

```text
fn_toString: true
```

### func dump()

```cangjie
public func dump(): Unit
```

功能：打印 `toString()`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    mv.dump()
}
```

运行结果：

```text
var x: Int32
```

## class NothingType

```cangjie
public class NothingType <: BuiltinType & Equatable<NothingType>
```

功能：表示类型系统中的 Nothing 类型（底部类型）。该类型用于表示永远不会返回的表达式。

父类型：

- [BuiltinType](#class-builtintype)
- Equatable\<[NothingType](#class-nothingtype)>

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

- [BuiltinType](#class-builtintype)
- Equatable\<[NumericType](#class-numerictype)>

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

### prop name

```cangjie
public prop name: String
```

功能：包逻辑名。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    println(pkg.name)
}
```

运行结果：

```text
demo
```

### prop accessLevel

```cangjie
public prop accessLevel: AccessLevel
```

功能：包访问级别。

类型：[AccessLevel](chir_package_enums.md#enum-accesslevel)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    println("prop_accessLevel: ${pkg.accessLevel == AccessLevel.Public}")
}
```

运行结果：

```text
prop_accessLevel: true
```

### prop importedClassDefs

```cangjie
public prop importedClassDefs: Array<ClassLikeDef>
```

功能：从其它包导入的类/接口定义快照。

类型：Array\<[ClassLikeDef](#class-classlikedef)>

### prop importedEnumDefs

```cangjie
public prop importedEnumDefs: Array<EnumDef>
```

功能：导入的枚举定义。

类型：Array\<[EnumDef](#class-enumdef)>

### prop importedStructDefs

```cangjie
public prop importedStructDefs: Array<StructDef>
```

功能：导入的结构体定义。

类型：Array\<[StructDef](#class-structdef)>

### prop importedExtendDefs

```cangjie
public prop importedExtendDefs: Array<ExtendDef>
```

功能：导入的 extend 定义。

类型：Array\<[ExtendDef](#class-extenddef)>

### prop classDefs

```cangjie
public prop classDefs: Array<ClassLikeDef>
```

功能：本包内定义的类/接口。

类型：Array\<[ClassLikeDef](#class-classlikedef)>

### prop enumDefs

```cangjie
public prop enumDefs: Array<EnumDef>
```

功能：本包内定义的枚举。

类型：Array\<[EnumDef](#class-enumdef)>

### prop structDefs

```cangjie
public prop structDefs: Array<StructDef>
```

功能：本包内定义的结构体。

类型：Array\<[StructDef](#class-structdef)>

### prop extendDefs

```cangjie
public prop extendDefs: Array<ExtendDef>
```

功能：本包内定义的 extend。

类型：Array\<[ExtendDef](#class-extenddef)>

### init(String, AccessLevel)

```cangjie
public init(name: String, accessLevel: AccessLevel)
```

功能：创建空包，指定逻辑包名与 [AccessLevel](chir_package_enums.md#enum-accesslevel)。

参数：

- name: String - 包名。
- accessLevel: AccessLevel - 包访问级别。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    println(pkg.name)
}
```

运行结果：

```text
demo
```

### func addClass(String, String, Bool, Array\<GenericType>)

```cangjie
public func addClass(identifier: String, srcCodeName: String, isClass: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ClassLikeDef
```

功能：在本包中新建类或接口定义并加入 `classDefs`。

返回值：

- [ClassLikeDef](#class-classlikedef) - 新定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addClass("C_m", "C", true)
    println("${pkg.classDefs.size}")
    println(d.srcCodeName)
}
```

运行结果：

```text
1
C
```

### func addImportedClass(String, String, String, Bool, Array\<GenericType>)

```cangjie
public func addImportedClass(identifier: String, srcCodeName: String, packageName: String, isClass: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ClassLikeDef
```

功能：登记导入的类/接口定义（带 `Imported` 标记）。

返回值：

- [ClassLikeDef](#class-classlikedef) - 新定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addImportedClass("I_m", "I", "other", true)
    println("fn_addImportedClass importedCount: ${pkg.importedClassDefs.size}")
    println("fn_addImportedClass isImported: ${d.isImported()}")
}
```

运行结果：

```text
fn_addImportedClass importedCount: 1
fn_addImportedClass isImported: true
```

### func addStruct(String, String, Array\<GenericType>)

```cangjie
public func addStruct(identifier: String, srcCodeName: String, genericTypeParams!: Array<GenericType> = Array<GenericType>()): StructDef
```

功能：在本包中新建结构体定义。

返回值：

- [StructDef](#class-structdef) - 新定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    println("${pkg.structDefs.size}")
    println(d.srcCodeName)
}
```

运行结果：

```text
1
S
```

### func addImportedStruct(String, String, String, Array\<GenericType>)

```cangjie
public func addImportedStruct(identifier: String, srcCodeName: String, packageName: String, genericTypeParams!: Array<GenericType> = Array<GenericType>()): StructDef
```

功能：登记导入的结构体定义。

返回值：

- [StructDef](#class-structdef) - 新定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addImportedStruct("IS_m", "IS", "other")
    println("${pkg.importedStructDefs.size}")
    println(d.srcCodeName)
}
```

运行结果：

```text
1
IS
```

### func addEnum(String, String, Bool, Array\<GenericType>)

```cangjie
public func addEnum(identifier: String, srcCodeName: String, isExhaustive: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): EnumDef
```

功能：在本包中新建枚举定义。

返回值：

- [EnumDef](#class-enumdef) - 新定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addEnum("E_m", "E", true)
    println("${pkg.enumDefs.size}")
    println(d.srcCodeName)
}
```

运行结果：

```text
1
E
```

### func addImportedEnum(String, String, String, Bool, Array\<GenericType>)

```cangjie
public func addImportedEnum(identifier: String, srcCodeName: String, packageName: String, isExhaustive: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): EnumDef
```

功能：登记导入的枚举定义。

返回值：

- [EnumDef](#class-enumdef) - 新定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addImportedEnum("IE_m", "IE", "other", true)
    println("${pkg.importedEnumDefs.size}")
    println(d.srcCodeName)
}
```

运行结果：

```text
1
IE
```

### func addExtend(String, Type, Array\<GenericType>)

```cangjie
public func addExtend(identifier: String, extendedType: Type, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ExtendDef
```

功能：在本包中新建 extend 定义。

返回值：

- [ExtendDef](#class-extenddef) - 新定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addExtend("ext_m", IntType.getInt32())
    println("${pkg.extendDefs.size}")
    println(d.extendedType.toString())
}
```

运行结果：

```text
1
Int32
```

### func addImportedExtend(String, String, Type, Array\<GenericType>)

```cangjie
public func addImportedExtend(identifier: String, packageName: String, extendedType: Type, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ExtendDef
```

功能：登记导入的 extend 定义。

返回值：

- [ExtendDef](#class-extenddef) - 新定义。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addImportedExtend("iext_m", "other", IntType.getInt32())
    println("${pkg.importedExtendDefs.size}")
    println(d.extendedType.toString())
}
```

运行结果：

```text
1
Int32
```

### func getSpecifiedClassDef(String, String)

```cangjie
public func getSpecifiedClassDef(packageName: String, srcCodeName: String): ?ClassLikeDef
```

功能：在导入与本包 `classDefs` 中按「声明包名 + 源码类型名」查找类/接口定义。

返回值：

- ?ClassLikeDef - 命中则 `Some`，否则 `None`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let _ = pkg.addImportedClass("I_m", "I", "other", true)
    let r = pkg.getSpecifiedClassDef("other", "I")
    println("fn_getSpecifiedClassDef: ${r.isSome()}")
}
```

运行结果：

```text
fn_getSpecifiedClassDef: true
```

### func getSpecifiedStructDef(String, String)

```cangjie
public func getSpecifiedStructDef(packageName: String, srcCodeName: String): ?StructDef
```

功能：同上，查找结构体定义。

返回值：

- ?StructDef - 可选结果。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let _ = pkg.addImportedStruct("IS_m", "IS", "other")
    let r = pkg.getSpecifiedStructDef("other", "IS")
    println("fn_getSpecifiedStructDef: ${r.isSome()}")
}
```

运行结果：

```text
fn_getSpecifiedStructDef: true
```

### func getSpecifiedEnumDef(String, String)

```cangjie
public func getSpecifiedEnumDef(packageName: String, srcCodeName: String): ?EnumDef
```

功能：同上，查找枚举定义。

返回值：

- ?EnumDef - 可选结果。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let _ = pkg.addImportedEnum("IE_m", "IE", "other", true)
    let r = pkg.getSpecifiedEnumDef("other", "IE")
    println("fn_getSpecifiedEnumDef: ${r.isSome()}")
}
```

运行结果：

```text
fn_getSpecifiedEnumDef: true
```

### func toString()

```cangjie
public func toString(): String
```

功能：输出包名、访问级别、导入区与本地类型区的拼接文本（调试用）。

返回值：

- String - 完整包描述。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("my.pkg", AccessLevel.Public)
    let _ = pkg.addClass("C1", "C", true)
    println("fn_toString: ${pkg.toString().size > 0}")
}
```

运行结果：

```text
fn_toString: true
```

### func dump()

```cangjie
public func dump(): Unit
```

功能：将 `toString()` 打印到标准输出。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("my.pkg", AccessLevel.Public)
    let _ = pkg.addClass("C1", "C", true)
    pkg.dump()
}
```

运行结果：

```text
package: my.pkg
packageAccessLevel: public

==========================imports===============================


==========================types=================================

[pluginAdded]class @C1 { // srcCodeName: C, packageName: my.pkg
}
```

---

## class RawArrayType

```cangjie
public class RawArrayType <: BuiltinType & Equatable<RawArrayType>
```

功能：**原始数组**类型，带元素类型与维度数 `dims`。使用缓存按 `(elementType, dims)` 唯一化。

父类型：

- [BuiltinType](#class-builtintype)
- Equatable\<[RawArrayType](#class-rawarraytype)>

### prop elementType

```cangjie
public prop elementType: Type
```

功能：数组元素类型。

类型：Type

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = RawArrayType.get(IntType.getUInt32(), 1)
    println(t.elementType.toString())
}
```

运行结果：

```text
UInt32
```

### prop dims

```cangjie
public prop dims: UInt32
```

功能：原始数组维数。

类型：UInt32

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = RawArrayType.get(IntType.getInt32(), 3)
    println("${t.dims}")
}
```

运行结果：

```text
3
```

### static func get(Type, UInt32)

```cangjie
public static func get(elementType: Type, dims: UInt32): RawArrayType
```

功能：获取或创建原始数组类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = RawArrayType.get(IntType.getInt32(), 2)
    println("static_get: ${t.toString().size > 0}")
}
```

运行结果：

```text
static_get: true
```

### func toString()

```cangjie
public func toString(): String
```

功能：类型的字符串形式（如多维 `[[[T]]]` 风格，见源码）。

返回值：

- String - 文本表示。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = RawArrayType.get(IntType.getInt32(), 2)
    println(t.toString())
}
```

运行结果：

```text
RawArray<RawArray<Int32>>
```

### operator func==(RawArrayType)

```cangjie
public operator func==(other: RawArrayType): Bool
```

功能：比较元素类型与维数是否相同。

参数：

- other: RawArrayType - 另一原始数组类型。

返回值：

- Bool - 是否相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t1 = RawArrayType.get(IntType.getInt32(), 2)
    let t2 = RawArrayType.get(IntType.getInt32(), 2)
    println("op_eq_RawArrayType: ${t1 == t2}")
}
```

运行结果：

```text
op_eq_RawArrayType: true
```

---

## class RefType

```cangjie
public class RefType <: Type & Equatable<RefType>
```

功能：表示类型系统中的引用类型。该类型包装另一个类型以表示对该类型的引用。该类维护所有引用类型的缓存以确保唯一性。

父类型：

- [Type](#class-type)
- Equatable\<[RefType](#class-reftype)>

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
    println(refType.baseType.toString())
}
```

运行结果：

```text
Int32
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
    println(refType.toString())
}
```

运行结果：

```text
Int32&
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
    let refType = RefType.get(IntType.getUInt32())
    println(refType.toString())
}
```

运行结果：

```text
UInt32&
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
    println("op_eq_RefType: ${refType1 == refType2}")
}
```

运行结果：

```text
op_eq_RefType: true
```

## class RuneType

```cangjie
public class RuneType <: BuiltinType & Equatable<RuneType>
```

功能：表示类型系统中的 Rune 类型。该类型表示字符类型。

父类型：

- [BuiltinType](#class-builtintype)
- Equatable\<[RuneType](#class-runetype)>

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

- [CustomTypeDef](#class-customtypedef)
- Equatable\<[StructDef](#class-structdef)>

### prop structType

```cangjie
public prop structType: StructType
```

功能：与此定义对应的实例化 [StructType](#class-structtype)。

类型：[StructType](#class-structtype)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let s = pkg.addStruct("S_m", "S")
    println("prop_structType: ${s.structType.structDef == s}")
}
```

运行结果：

```text
prop_structType: true
```

### prop isCStruct

```cangjie
public mut prop isCStruct: Bool
```

功能：是否标记为与 C 互操作的结构体。

类型：Bool

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let s = pkg.addStruct("S_m", "S")
    s.isCStruct = true
    println("mut_prop_isCStruct: ${s.isCStruct}")
}
```

运行结果：

```text
mut_prop_isCStruct: true
```

### operator func==(StructDef)

```cangjie
public operator func==(other: StructDef): Bool
```

功能：比较是否同一结构体定义。

参数：

- other: StructDef - 另一结构体定义。

返回值：

- Bool - 是否相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let s = pkg.addStruct("S_m", "S")
    println("op_eq_StructDef: ${s == s}")
}
```

运行结果：

```text
op_eq_StructDef: true
```

---

## class StructType

```cangjie
public class StructType <: CustomType & Equatable<StructType>
```

功能：结构体的实例化类型；`get(def, genericTypeParams)` 缓存。

父类型：

- [CustomType](#class-customtype)
- Equatable\<[StructType](#class-structtype)>

### prop structDef

```cangjie
public prop structDef: StructDef
```

功能：对应的 [StructDef](#class-structdef)。

类型：[StructDef](#class-structdef)

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addStruct("S_m", "S")
    let st = StructType.get(def, [])
    println(st.structDef.srcCodeName)
}
```

运行结果：

```text
S
```

### static func get(StructDef, Array\<Type>)

```cangjie
public static func get(def: StructDef, genericTypeParams: Array<Type>): StructType
```

功能：按结构体定义与泛型实参取得或创建缓存实例。

参数：

- def: StructDef - 结构体定义。
- genericTypeParams: Array\<Type> - 泛型实参。

返回值：

- StructType - 实例化结构体类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addStruct("S_m", "S")
    let st = StructType.get(def, [])
    println(st.structDef.srcCodeName)
}
```

运行结果：

```text
S
```

### operator func==(StructType)

```cangjie
public operator func==(other: StructType): Bool
```

功能：比较是否为同一实例化结构体类型。

参数：

- other: StructType - 另一结构体类型。

返回值：

- Bool - 是否相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addStruct("S_m", "S")
    let st1 = StructType.get(def, [])
    let st2 = StructType.get(def, [])
    println("op_eq_StructType: ${st1 == st2}")
}
```

运行结果：

```text
op_eq_StructType: true
```

---

## class ThisType

```cangjie
public class ThisType <: Type & Equatable<ThisType>
```

功能：类/结构体体内的 **`This`** 类型，单例。

父类型：

- [Type](#class-type)
- Equatable\<[ThisType](#class-thistype)>

### static func get()

```cangjie
public static func get(): ThisType
```

功能：返回 `This` 类型的唯一单例。

返回值：

- ThisType - 单例。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    println("static_get: ${ThisType.get().toString().size > 0}")
}
```

运行结果：

```text
static_get: true
```

### operator func==(ThisType)

```cangjie
public operator func==(_: ThisType): Bool
```

功能：与另一 `ThisType` 比较（单例恒等）。

参数：

- _: ThisType - 另一实例。

返回值：

- Bool - 恒为 `true`。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t1 = ThisType.get()
    let t2 = ThisType.get()
    println("op_eq_ThisType: ${t1 == t2}")
}
```

运行结果：

```text
op_eq_ThisType: true
```

---

## class TupleType

```cangjie
public class TupleType <: Type & Equatable<TupleType>
```

功能：元组类型；按元素类型序列签名缓存。

父类型：

- [Type](#class-type)
- Equatable\<[TupleType](#class-tupletype)>

### prop elementTypes

```cangjie
public prop elementTypes: Array<Type>
```

功能：元组各位置上的类型。

类型：Array\<Type>

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let u = UnitType.get()
    let tup = TupleType.get([IntType.getInt32(), u])
    println("${tup.elementTypes.size}")
}
```

运行结果：

```text
2
```

### static func get(Array\<Type>)

```cangjie
public static func get(elementTypes: Array<Type>): TupleType
```

功能：按元素类型序列取得或创建唯一元组类型。

参数：

- elementTypes: Array\<Type> - 从左到右的元素类型。

返回值：

- TupleType - 元组类型实例。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let tup = TupleType.get([IntType.getInt32()])
    println("${tup.elementTypes.size}")
}
```

运行结果：

```text
1
```

### func toString()

```cangjie
public func toString(): String
```

功能：元组类型的字符串表示。

返回值：

- String - 文本形式。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let tup = TupleType.get([IntType.getUInt32()])
    println(tup.toString())
}
```

运行结果：

```text
Tuple(UInt32)
```

### operator func==(TupleType)

```cangjie
public operator func==(other: TupleType): Bool
```

功能：按元素类型序列比较是否相同。

参数：

- other: TupleType - 另一元组类型。

返回值：

- Bool - 是否相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let u = UnitType.get()
    let t1 = TupleType.get([IntType.getInt32(), u])
    let t2 = TupleType.get([IntType.getInt32(), u])
    println("op_eq_TupleType: ${t1 == t2}")
}
```

运行结果：

```text
op_eq_TupleType: true
```

---

## class Type

```cangjie
sealed abstract class Type <: ToString & Hashable & Equatable<Type>
```

功能：类型系统中所有类型的抽象基类。该类提供了类型的基础功能，包括相等性比较、哈希计算和字符串转换。

父类型：

- ToString
- Hashable
- Equatable\<[Type](#class-type)>

### prop qualifiedName

```cangjie
public prop qualifiedName: String
```

功能：类型的限定名（用于调试与展示，具体规则见源码中 `qualifiedName` 的 `match` 分支）。

类型：String

### prop typeArgs

```cangjie
public prop typeArgs: Array<Type>
```

功能：该类型的类型参数/子类型实参列表（依具体 `TypeKind` 而定）。

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

- [BuiltinType](#class-builtintype)
- Equatable\<[UnitType](#class-unittype)>

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

- [BuiltinType](#class-builtintype)
- Equatable\<[VArrayType](#class-varraytype)>

### prop elementType

```cangjie
public prop elementType: Type
```

功能：元素类型。

类型：Type

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let v = VArrayType.get(IntType.getUInt32(), 4)
    println(v.elementType.toString())
}
```

运行结果：

```text
UInt32
```

### prop size

```cangjie
public prop size: Int64
```

功能：编译期固定长度。

类型：Int64

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let v = VArrayType.get(IntType.getInt32(), 8)
    println("${v.size}")
}
```

运行结果：

```text
8
```

### static func get(Type, Int64)

```cangjie
public static func get(elementType: Type, size: Int64): VArrayType
```

功能：获取或创建 VArray 类型。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let v = VArrayType.get(IntType.getInt32(), 8)
    println("static_get: ${v.toString().size > 0}")
}
```

运行结果：

```text
static_get: true
```

### func toString()

```cangjie
public func toString(): String
```

功能：定长 VArray 的字符串表示。

返回值：

- String - 文本形式。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let v = VArrayType.get(IntType.getInt32(), 2)
    println(v.toString())
}
```

运行结果：

```text
VArray<Int32, $2>
```

### operator func==(VArrayType)

```cangjie
public operator func==(other: VArrayType): Bool
```

功能：比较元素类型与长度是否一致。

参数：

- other: VArrayType - 另一 VArray 类型。

返回值：

- Bool - 是否相等。

示例：

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let v1 = VArrayType.get(IntType.getInt32(), 8)
    let v2 = VArrayType.get(IntType.getInt32(), 8)
    println("op_eq_VArrayType: ${v1 == v2}")
}
```

运行结果：

```text
op_eq_VArrayType: true
```

---
