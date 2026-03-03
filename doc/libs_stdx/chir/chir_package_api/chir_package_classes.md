# 类

## class Annotation

```cangjie
public class Annotation <: ToString
```

功能：表示 CHIR 中**一处**注解实例，对应源码形态 `@ClassName[k1=v1, k2=v2]`：保存注解类名及参数字段名到字符串值的映射。

父类型：

- ToString

**说明**：包内另有 `internal class AnnoInfo` 用于在节点上聚合多条 `Annotation`，对外 API 统一通过 `Array<Annotation>`（如 [MemberVar](#class-membervar)、[EnumCtorInfo](#class-enumctorinfo) 的 `annotations`），不再直接暴露 `AnnoInfo`。

### init(classSrcCodeName: String)

```cangjie
public init(classSrcCodeName: String)
```

功能：构造指定注解类名的实例，**参数表初始为空**；可通过 `setFieldValue` 写入键值。

参数：

- classSrcCodeName: String - 源码中的注解类名（如 `MyAnno`）。

### prop classSrcCodeName

```cangjie
public prop classSrcCodeName: String
```

功能：注解类在源码中的名称。

类型：String

### func getFieldValue(fieldName: String)

```cangjie
public func getFieldValue(fieldName: String): ?String
```

功能：按键名查找注解参数；若不存在则返回 `None`。

参数：

- fieldName: String - 参数字段名（与 `toString()` 中 `key=value` 的键一致）。

返回值：

- ?String - 有则 `Some(字符串值)`，否则 `None`。

### func setFieldValue(fieldName: String, value: String)

```cangjie
public func setFieldValue(fieldName: String, value: String): Unit
```

功能：设置或覆盖某一参数字段的字符串值（构建或测试 CHIR 时使用）。

参数：

- fieldName: String - 参数名。
- value: String - 参数值（字符串形式）。

### func toString()

```cangjie
public func toString(): String
```

功能：格式化为 `@ClassName[k1=v1, k2=v2]`，便于日志与调试。

返回值：

- String - 注解的文本形式。

### 完整用例

（演示 `init`、`classSrcCodeName`、`setFieldValue`、`getFieldValue`、`toString`。）

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let a = Annotation("MyAnno")
    a.setFieldValue("path", "/foo")
    println(a.toString())
    if (let Some(p) <- a.getFieldValue("path")) {
        println(p)
    }
}
```

运行结果：

```text
@MyAnno[path=/foo]
/foo
```

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

### 完整用例

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let base = IntType.getInt32()
    let b1 = BoxType.get(base)
    let b2 = BoxType.get(base)
    println(b1.baseType.toString())
    println("${b1 == b2}")
    println(b1.toString())
}
```

运行结果：

```text
Int32
true
Box<Int32>
```

---

## class BuiltinType

```cangjie
sealed abstract class BuiltinType <: Type & Equatable<BuiltinType>
```

功能：内置类型（数值、Bool、Unit、指针、数组等）的公共基类；可附加 `ExtendDef`（`addExtend`），并通过 `getSuperTypesRecusively` 收集由 extend 实现的接口父类型。

父类型：

- Type
- Equatable\<BuiltinType>

### operator func==(BuiltinType)

```cangjie
public operator func==(other: BuiltinType): Bool
```

功能：比较两个内置类型是否表示同一类及相同类型实参。

参数：

- other: BuiltinType - 另一内置类型。

返回值：

- Bool - 相等则为 `true`。

### func getSuperTypesRecusively(visited!)

```cangjie
public func getSuperTypesRecusively(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType>
```

功能：从本类型上通过 `extend` 所实现的接口出发，递归收集父接口/父类侧的 [ClassLikeType](#class-classliketype)（用于语义与继承分析）。

参数：

- visited! - 环检测用访问表；一般可传默认空表。

返回值：

- Array\<ClassLikeType> - 收集到的类型序列。

### func addExtend(extendDef: ExtendDef)

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
extend id: ...
```

（具体 `identifier` 前缀与 mangling 规则以源码为准。）

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

## class ClassLikeDef

```cangjie
public class ClassLikeDef <: CustomTypeDef & Equatable<ClassLikeDef>
```

功能：**类或接口**的定义。

父类型：

- CustomTypeDef
- Equatable\<ClassLikeDef>

**说明**：通常通过 [Package](#class-package) 的 `addClass` / `addImportedClass` 等创建；以下为类/接口定义专有成员（其余见 [CustomTypeDef](#class-customtypedef)）。

### mut prop isAnnotation

```cangjie
public mut prop isAnnotation: Bool
```

功能：是否为注解类。

类型：Bool

### prop classType

```cangjie
public prop classType: ClassLikeType
```

功能：与此定义对应的 [ClassLikeType](#class-classliketype)。

类型：[ClassLikeType](#class-classliketype)

### mut prop superClass

```cangjie
public mut prop superClass: ?ClassLikeType
```

功能：父类；无父类时为 `None`。

类型：?[ClassLikeType](#class-classliketype)

### func setAbstract(enable: Bool)

```cangjie
public func setAbstract(enable: Bool): Unit
```

功能：设置或清除 `abstract` 标记。

### func setOpen(enable: Bool)

```cangjie
public func setOpen(enable: Bool): Unit
```

功能：设置或清除 `open`（可继承/虚）相关标记。

### func setSealed(enable: Bool)

```cangjie
public func setSealed(enable: Bool): Unit
```

功能：设置或清除 `sealed` 标记。

### operator func==(ClassLikeDef)

```cangjie
public operator func==(other: ClassLikeDef): Bool
```

功能：比较是否同一类/接口定义。

参数：

- other: ClassLikeDef - 另一定义。

返回值：

- Bool - 是否相等。

### 完整用例

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    def.setAbstract(true)
    def.setOpen(true)
    println(def.isAnnotation)
    println(def.classType.classLikeDef == def)
}
```

运行结果：

```text
false
true
```

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

```cangjie
public static func get(def: ClassLikeDef, genericTypeParams: Array<Type>): ClassLikeType
```

功能：按定义与泛型实参取得或创建缓存中的唯一实例。

参数：

- def: ClassLikeDef - 类/接口定义。
- genericTypeParams: Array\<Type> - 泛型实参（非泛型时为空数组）。

返回值：

- ClassLikeType - 实例化类型。

### prop classLikeDef

```cangjie
public prop classLikeDef: ClassLikeDef
```

功能：对应的 [ClassLikeDef](#class-classlikedef)。

类型：[ClassLikeDef](#class-classlikedef)

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
    let ty = ClassLikeType.get(d, [])
    println(ty.classLikeDef.srcCodeName)
}
```

运行结果：

```text
C
```

---

## class CustomType

```cangjie
sealed abstract class CustomType <: Type & Equatable<CustomType>
```

功能：用户自定义类型（类/接口/结构体/枚举）实例化类型的公共基类，持有 `CustomTypeDef` 与泛型实参。

父类型：

- Type
- Equatable\<CustomType>

子类包括 [ClassLikeType](#class-classliketype)、[StructType](#class-structtype)、[EnumType](#class-enumtype) 等。

### operator func==(CustomType)

```cangjie
public operator func==(other: CustomType): Bool
```

功能：比较种类、定义与泛型实参是否一致。

参数：

- other: CustomType - 另一自定义实例化类型。

返回值：

- Bool - 是否相等。

### prop def

```cangjie
public prop def: CustomTypeDef
```

功能：对应的类型定义节点。

类型：[CustomTypeDef](#class-customtypedef)

### prop genericTypeArgs

```cangjie
public prop genericTypeArgs: Array<Type>
```

功能：泛型实参列表（非泛型时为空）。

类型：Array\<Type>

### prop allMemberVarNames

```cangjie
public prop allMemberVarNames: Array<String>
```

功能：自超类链线性化后直至本类型声明的全部实例成员名。

类型：Array\<String>

### func getExtendImplementedInterfaceTypes(visited!)

```cangjie
public func getExtendImplementedInterfaceTypes(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType>
```

功能：收集适用于当前实例的 `extend` 块所实现的接口（已代入泛型）。

### func getImplementedInterfaceTypes(visited!)

```cangjie
public func getImplementedInterfaceTypes(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType>
```

功能：`extend` 实现的接口与定义上 `implementedInterfaceTypes` 的并集（已实例化）。

### func getInstantiatedMemberVarTypes()

```cangjie
public func getInstantiatedMemberVarTypes(): Array<Type>
```

功能：与 `allMemberVarNames` 对齐的成员类型，已按当前泛型实参替换。

返回值：

- Array\<Type> - 成员实例化类型序列。

### func getMemberVarInstantiatedType(name: String)

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

### func getSuperTypesRecusively(visited!)

```cangjie
public func getSuperTypesRecusively(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType>
```

功能：递归收集父类与接口父类型（已实例化）。

### func getExtendDefs(visited!)

```cangjie
public func getExtendDefs(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ExtendDef>
```

功能：返回 `def.extends` 中 `extendedType` 与当前类型可匹配的 extend 定义。

### func toString()

```cangjie
public func toString(): String
```

功能：内部 kind、标识与泛型实参的紧凑字符串。

返回值：

- String - 文本形式。

### 完整用例

（演示 `def`、`genericTypeArgs`、`allMemberVarNames`、`toString` 等。）

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println(st.def.srcCodeName)
    println("${st.allMemberVarNames.size}")
}
```

运行结果：

```text
S
0
```

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

**说明**：子类含 [ClassLikeDef](#class-classlikedef)、[StructDef](#class-structdef)、[EnumDef](#class-enumdef)、[ExtendDef](#class-extenddef) 等。下列列出密封基类上的公开 **prop** / **func**（与 `Base` 组合的 CHIR 注解等见源码）。

### prop identifier

```cangjie
public prop identifier: String
```

功能：内部标识（通常含全局前缀与 mangled 名）。

类型：String

### prop srcCodeName

```cangjie
public prop srcCodeName: String
```

功能：源码中的类型名（extend 等场景可能为空串，见源码注释）。

类型：String

### prop packageName

```cangjie
public prop packageName: String
```

功能：所属包名。

类型：String

### prop ty

```cangjie
public prop ty: Type
```

功能：对普通定义为实例化类型；对 [ExtendDef](#class-extenddef) 为 `extendedType`。

类型：[Type](#class-type)

### prop genericTypeParams

```cangjie
public prop genericTypeParams: Array<GenericType>
```

功能：泛型形参列表；非泛型或无法从类型实参反推时为空数组。

类型：Array\<[GenericType](#class-generictype)>

### mut prop genericDecl

```cangjie
public mut prop genericDecl: ?CustomTypeDef
```

功能：与当前**单态**定义配对的泛型模板定义；`set` 时校验种类、`srcCodeName` 及泛型约束（见源码断言）。

类型：?CustomTypeDef

### prop instanceVars

```cangjie
public prop instanceVars: Array<MemberVar>
```

功能：实例成员变量列表（声明顺序）。

类型：Array\<[MemberVar](#class-membervar)>

### mut prop extends

```cangjie
public mut prop extends: Array<ExtendDef>
```

功能：嵌套于该类型下的 `extend` 定义集合。

类型：Array\<[ExtendDef](#class-extenddef)>

### mut prop implementedInterfaceTypes

```cangjie
public mut prop implementedInterfaceTypes: Array<ClassLikeType>
```

功能：直接实现的接口类型列表。

类型：Array\<[ClassLikeType](#class-classliketype)>

### func setPublic()

```cangjie
public func setPublic(): Unit
```

功能：标记为 `public` 可见性。

### func setPrivate()

```cangjie
public func setPrivate(): Unit
```

功能：标记为 `private`。

### func setProtected()

```cangjie
public func setProtected(): Unit
```

功能：标记为 `protected`。

### func setInternal()

```cangjie
public func setInternal(): Unit
```

功能：标记为 `internal`。

### func isImported()

```cangjie
public func isImported(): Bool
```

功能：是否为从其它包导入的定义。

### func isPublic()

```cangjie
public func isPublic(): Bool
```

功能：是否带 `public` 属性。

### func isPrivate()

```cangjie
public func isPrivate(): Bool
```

功能：是否带 `private` 属性。

### func isInternal()

```cangjie
public func isInternal(): Bool
```

功能：是否带 `internal` 属性。

### func isProtected()

```cangjie
public func isProtected(): Bool
```

功能：是否带 `protected` 属性。

### func isAbstract()

```cangjie
public func isAbstract(): Bool
```

功能：是否为 `abstract`。

### func isOpen()

```cangjie
public func isOpen(): Bool
```

功能：是否可继承/实现（`virtual` 或 `abstract`）。

### func isSealed()

```cangjie
public func isSealed(): Bool
```

功能：是否为 `sealed`。

### func isGeneric()

```cangjie
public func isGeneric(): Bool
```

功能：是否为泛型定义。

### func isClassLike()

```cangjie
public func isClassLike(): Bool
```

功能：种类是否为类/接口。

### func isClass()

```cangjie
public func isClass(): Bool
```

功能：是否为类（非接口）。

### func isInterface()

```cangjie
public func isInterface(): Bool
```

功能：是否为接口。

### func isEnum()

```cangjie
public func isEnum(): Bool
```

功能：是否为枚举定义。

### func isExtend()

```cangjie
public func isExtend(): Bool
```

功能：是否为 extend 定义。

### func isStruct()

```cangjie
public func isStruct(): Bool
```

功能：是否为结构体定义。

### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：定义的哈希码。

返回值：

- Int64 - 哈希值。

### operator func==(CustomTypeDef)

```cangjie
public operator func==(other: CustomTypeDef): Bool
```

功能：按种类、标识、源码名与包名比较。

### func toString()

```cangjie
public open func toString(): String
```

功能：多行类/接口/枚举等形状文本（含属性、成员、`extend` 列表）。

返回值：

- String - 定义的可读转储。

### func dump()

```cangjie
public func dump(): Unit
```

功能：将 `toString()` 输出到标准输出。

### func appendInstanceMemberVar()

```cangjie
public func appendInstanceMemberVar(name: String, ty: Type): MemberVar
```

功能：向当前类型定义**追加**一个实例成员变量（名称与类型），并返回对应的 [MemberVar](#class-membervar)。成员在 `instanceVars` 中的顺序与调用顺序一致；适用于插件或测试在 `Package.addClass` / `addStruct` 等创建定义之后挂载 CHIR 成员。

返回值：

- [MemberVar](#class-membervar) - 新创建的成员变量节点。

### func getSuperTypesRecusively()

```cangjie
public func getSuperTypesRecusively(): Array<ClassLikeType>
```

功能：若 `ty` 为 [CustomType](#class-customtype) 或 [BuiltinType](#class-builtintype)，委托其递归父类型收集；否则抛异常。

返回值：

- Array\<ClassLikeType> - 父类型集合。

### 完整用例

（演示 `identifier`、`srcCodeName`、`isClass`、`hashCode`、`appendInstanceMemberVar`、`instanceVars`、`toString` 等常用 API。）

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.identifier.size > 0)
    println(d.isClass())
    println(d.hashCode() != 0)
    let mv = d.appendInstanceMemberVar("f", IntType.getInt32())
    println(mv.name)
    println(d.instanceVars.size)
}
```

运行结果：

```text
true
true
true
f
1
```

---

## class DebugLocation

```cangjie
public class DebugLocation <: ToString
```

功能：源码中的**区间位置**（起止 `Position` 与文件路径），用于调试与打印。

父类型：

- ToString

**说明**：无公开构造器。通常从 [CustomTypeDef](#class-customtypedef) / [MemberVar](#class-membervar) 等节点上的 **`location`** 取得；包内另有带起止位置与路径的 `internal` 构造及 `internal` 空占位（无效区间）。

### prop start

```cangjie
public prop start: Position
```

功能：区间起点（含），与 [struct Position](chir_package_structs.md#struct-position) 成对使用。

类型：[Position](chir_package_structs.md#struct-position)

### prop end

```cangjie
public prop end: Position
```

功能：区间终点。

类型：[Position](chir_package_structs.md#struct-position)

### prop filePath

```cangjie
public prop filePath: Path
```

功能：源文件路径（绝对或工程内路径，见 `std.fs.Path`）。

类型：Path

### func isValid()

```cangjie
public func isValid(): Bool
```

功能：当 `start`、`end` 均有效且 `filePath` 非空时返回 `true`。

返回值：

- Bool - 是否为可用调试区间。

### func toString()

```cangjie
public func toString(): String
```

功能：无效时返回空串；否则输出文件名、`start`/`end` 的紧凑形式及可选 scope 链（见源码）。

返回值：

- String - 人类可读位置描述。

### 完整用例

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    let loc = mv.location
    println(loc.isValid())
    println(loc.start.line)
    println(loc.toString())
}
```

运行结果：

```text
false
0

```

## class EnumCtorInfo

```cangjie
public class EnumCtorInfo <: ToString
```

功能：枚举的一个**构造器/变体**（名称、内部名、函数类型、注解）。

父类型：

- ToString

**说明**：由 [EnumDef](#class-enumdef) 的 `appendEnumCtorInfo` 等在构建 CHIR 时创建。

### prop srcCodeName

```cangjie
public prop srcCodeName: String
```

功能：源码中的构造器/变体名。

类型：String

### prop identifier

```cangjie
public prop identifier: String
```

功能：内部 mangled 标识。

类型：String

### prop funcType

```cangjie
public prop funcType: FuncType
```

功能：该变元的参数类型与返回类型（返回为所属枚举类型）的 [FuncType](#class-functype)。

类型：[FuncType](#class-functype)

### mut prop annotations

```cangjie
public mut prop annotations: Array<Annotation>
```

功能：挂在此枚举构造器上的注解实例列表（内部由 `AnnoInfo` 存储，对外为 `Array<Annotation>`）；`set` 时整体替换。

类型：Array\<[Annotation](#class-annotation)>

### func toString()

```cangjie
public func toString(): String
```

功能：形如 `VariantName(paramTypes...)` 的简短描述（见源码）。

返回值：

- String - 构造器文本形式。

### 完整用例

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
    println(ctor.srcCodeName)
    println(ctor.annotations.size)
    println(ctor.toString())
}
```

运行结果：

```text
A
1
A
```

（第三行为 `EnumCtorInfo.toString()`，无参变元形如 `A()`。）

---

## class EnumDef

```cangjie
public class EnumDef <: CustomTypeDef & Equatable<EnumDef>
```

功能：**枚举**定义；含是否穷尽、构造器列表等。

父类型：

- CustomTypeDef
- Equatable\<EnumDef>

### prop isExhaustive

```cangjie
public prop isExhaustive: Bool
```

功能：是否为**穷尽**枚举（与内部 `nonExhaustive` 标志相反）。

类型：Bool

### prop constructors

```cangjie
public prop constructors: Array<EnumCtorInfo>
```

功能：全部枚举构造器/变体，按声明顺序。

类型：Array\<[EnumCtorInfo](#class-enumctorinfo)>

### prop enumType

```cangjie
public prop enumType: EnumType
```

功能：与此定义对应的实例化 [EnumType](#class-enumtype)。

类型：[EnumType](#class-enumtype)

### func appendEnumCtorInfo(mangledName: String, name: String, argTypes!: Array\<Type>)

```cangjie
public func appendEnumCtorInfo(mangledName: String, name: String, argTypes!: Array<Type> = Array<Type>()): EnumCtorInfo
```

功能：追加一个枚举变元；无参变元可省略 `argTypes` 或传空数组。

参数：

- mangledName: String - 内部 mangled 名。
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
    println("${c.srcCodeName}, params: ${c.funcType.paramTypes.size}")
}
```

运行结果：

```text
A, params: 0
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

```cangjie
public static func get(def: EnumDef, genericTypeParams: Array<Type>): EnumType
```

功能：按枚举定义与泛型实参取得或创建缓存实例。

参数：

- def: EnumDef - 枚举定义。
- genericTypeParams: Array\<Type> - 泛型实参。

返回值：

- EnumType - 实例化枚举类型。

### prop enumDef

```cangjie
public prop enumDef: EnumDef
```

功能：对应的 [EnumDef](#class-enumdef)。

类型：[EnumDef](#class-enumdef)

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
    let t = EnumType.get(d, [])
    println(t.enumDef.srcCodeName)
}
```

运行结果：

```text
E
```

---

## class ExtendDef

```cangjie
public class ExtendDef <: CustomTypeDef
```

功能：**扩展（extend）**定义：对某类型增加实现等，带 `extendedType` 与泛型参数。

父类型：

- CustomTypeDef

### prop extendedType

```cangjie
public prop extendedType: Type
```

功能：被扩展的目标类型（`extend T { ... }` 中的 `T`）。

类型：[Type](#class-type)

**说明**：其余 API 继承 [CustomTypeDef](#class-customtypedef)；extend 节点的 `srcCodeName` 等字段语义见源码。

### 完整用例

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let ext = pkg.addExtend("ext_m", IntType.getInt32())
    println(ext.extendedType.toString())
    println(ext.identifier.size > 0)
}
```

运行结果：

```text
Int32
true
```

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

### prop hasVarArg

```cangjie
public prop hasVarArg: Bool
```

功能：是否为可变参数函数类型。

类型：Bool

### prop isCFunc

```cangjie
public prop isCFunc: Bool
```

功能：是否表示 C 函数类型（影响 `toString()` 前缀 `CFunc<...>`）。

类型：Bool

### prop paramTypes

```cangjie
public prop paramTypes: Array<Type>
```

功能：形参类型数组。

类型：Array\<Type>

### prop returnType

```cangjie
public prop returnType: Type
```

功能：返回类型。

类型：Type

### func toString()

```cangjie
public func toString(): String
```

功能：形如 `(T1, T2) -> R` 或 `CFunc<(T1)-> R>` 的字符串（见源码）。

返回值：

- String - 函数类型文本。

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
    let f = FuncType.get([i32], i32)
    println("${f}, varArg=${f.hasVarArg}, cFunc=${f.isCFunc}")
}
```

运行结果：

```text
(Int32) -> Int32, varArg=false, cFunc=false
```

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

```cangjie
public static func get(identifier: String, srcCodeName: String): GenericType
```

功能：按内部 `identifier` 缓存取得或创建泛型形参类型（如 `T`）。

参数：

- identifier: String - 内部唯一键（mangling 用）。
- srcCodeName: String - 源码中的形参名。

返回值：

- GenericType - 泛型形参类型。

### prop srcCodeName

```cangjie
public prop srcCodeName: String
```

功能：源码中的泛型参数名（如 `T`）。

类型：String

### mut prop upperBounds

```cangjie
public mut prop upperBounds: Array<Type>
```

功能：上界类型列表；赋值时会拒绝**值类型**上界（见源码校验）。

类型：Array\<Type>

### func toString()

```cangjie
public func toString(): String
```

功能：内部调试用字符串（含 kind 与 identifier）。

返回值：

- String - 文本形式。

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
    let t = GenericType.get("g:T", "T")
    println("${t.srcCodeName}, bounds=${t.upperBounds.size}")
}
```

运行结果：

```text
T, bounds=0
```

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

功能：描述自定义类型上的**实例成员变量**（名称、类型、调试位置、注解与访问修饰等）。

父类型：

- ToString

**说明**：无独立公开构造器；通过 [CustomTypeDef](#class-customtypedef) 的 **`appendInstanceMemberVar(name:ty:)`** 在定义上追加实例成员后获得 `MemberVar` 实例。

### prop name

```cangjie
public prop name: String
```

功能：成员源码名。

类型：String

### prop ty

```cangjie
public prop ty: Type
```

功能：成员类型。

类型：[Type](#class-type)

### prop location

```cangjie
public prop location: DebugLocation
```

功能：源码位置；未设置时可能为无效区间（见 [DebugLocation](#class-debuglocation)）。

类型：[DebugLocation](#class-debuglocation)

### mut prop annotations

```cangjie
public mut prop annotations: Array<Annotation>
```

功能：成员上的注解实例列表（内部由 `AnnoInfo` 存储，对外为 `Array<Annotation>`）；`set` 时整体替换。

类型：Array\<[Annotation](#class-annotation)>

### prop outerDef

```cangjie
public prop outerDef: CustomTypeDef
```

功能：包含该成员的外层类型定义。

类型：[CustomTypeDef](#class-customtypedef)

### func setReadOnly(enable: Bool)

```cangjie
public func setReadOnly(enable: Bool): Unit
```

功能：设置或清除只读（`let` 语义）标记。

### func setInternal()

```cangjie
public func setInternal(): Unit
```

功能：将成员标为 `internal`。

### func setPublic()

```cangjie
public func setPublic(): Unit
```

功能：将成员标为 `public`。

### func setPrivate()

```cangjie
public func setPrivate(): Unit
```

功能：将成员标为 `private`。

### func setProtected()

```cangjie
public func setProtected(): Unit
```

功能：将成员标为 `protected`。

### func isReadOnly()

```cangjie
public func isReadOnly(): Bool
```

功能：是否为只读成员。

### func isInternal()

```cangjie
public func isInternal(): Bool
```

功能：是否为 `internal`。

### func isPublic()

```cangjie
public func isPublic(): Bool
```

功能：是否为 `public`。

### func isPrivate()

```cangjie
public func isPrivate(): Bool
```

功能：是否为 `private`。

### func isProtected()

```cangjie
public func isProtected(): Bool
```

功能：是否为 `protected`。

### func toString()

```cangjie
public func toString(): String
```

功能：属性前缀 + `let`/`var`、名称、类型及位置注释。

返回值：

- String - 单行成员描述。

### func dump()

```cangjie
public func dump(): Unit
```

功能：打印 `toString()`。

### 完整用例

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.name)
    println(mv.outerDef.srcCodeName)
    println(st.instanceVars.size)
}
```

运行结果：

```text
x
S
1
```

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

```cangjie
public init(name: String, accessLevel: AccessLevel)
```

功能：创建空包，指定逻辑包名与 [AccessLevel](chir_package_enums.md#enum-accesslevel)。

参数：

- name: String - 包名。
- accessLevel: AccessLevel - 包访问级别。

### prop name

```cangjie
public prop name: String
```

功能：包逻辑名。

类型：String

### prop accessLevel

```cangjie
public prop accessLevel: AccessLevel
```

功能：包访问级别。

类型：[AccessLevel](chir_package_enums.md#enum-accesslevel)

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

### func addClass(mangledName: String, srcCodeName: String, isClass: Bool, genericTypeParams!: Array\<GenericType>)

```cangjie
public func addClass(mangledName: String, srcCodeName: String, isClass: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ClassLikeDef
```

功能：在本包中新建类或接口定义并加入 `classDefs`。

返回值：

- [ClassLikeDef](#class-classlikedef) - 新定义。

### func addImportedClass(mangledName: String, srcCodeName: String, packageName: String, isClass: Bool, genericTypeParams!: Array\<GenericType>)

```cangjie
public func addImportedClass(mangledName: String, srcCodeName: String, packageName: String, isClass: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ClassLikeDef
```

功能：登记导入的类/接口定义（带 `Imported` 标记）。

返回值：

- [ClassLikeDef](#class-classlikedef) - 新定义。

### func addStruct(mangledName: String, srcCodeName: String, genericTypeParams!: Array\<GenericType>)

```cangjie
public func addStruct(mangledName: String, srcCodeName: String, genericTypeParams!: Array<GenericType> = Array<GenericType>()): StructDef
```

功能：在本包中新建结构体定义。

返回值：

- [StructDef](#class-structdef) - 新定义。

### func addImportedStruct(mangledName: String, srcCodeName: String, packageName: String, genericTypeParams!: Array\<GenericType>)

```cangjie
public func addImportedStruct(mangledName: String, srcCodeName: String, packageName: String, genericTypeParams!: Array<GenericType> = Array<GenericType>()): StructDef
```

功能：登记导入的结构体定义。

返回值：

- [StructDef](#class-structdef) - 新定义。

### func addEnum(mangledName: String, srcCodeName: String, isExhaustive: Bool, genericTypeParams!: Array\<GenericType>)

```cangjie
public func addEnum(mangledName: String, srcCodeName: String, isExhaustive: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): EnumDef
```

功能：在本包中新建枚举定义。

返回值：

- [EnumDef](#class-enumdef) - 新定义。

### func addImportedEnum(mangledName: String, srcCodeName: String, packageName: String, isExhaustive: Bool, genericTypeParams!: Array\<GenericType>)

```cangjie
public func addImportedEnum(mangledName: String, srcCodeName: String, packageName: String, isExhaustive: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): EnumDef
```

功能：登记导入的枚举定义。

返回值：

- [EnumDef](#class-enumdef) - 新定义。

### func addExtend(mangledName: String, extendedType: Type, genericTypeParams!: Array\<GenericType>)

```cangjie
public func addExtend(mangledName: String, extendedType: Type, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ExtendDef
```

功能：在本包中新建 extend 定义。

返回值：

- [ExtendDef](#class-extenddef) - 新定义。

### func addImportedExtend(mangledName: String, packageName: String, extendedType: Type, genericTypeParams!: Array\<GenericType>)

```cangjie
public func addImportedExtend(mangledName: String, packageName: String, extendedType: Type, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ExtendDef
```

功能：登记导入的 extend 定义。

返回值：

- [ExtendDef](#class-extenddef) - 新定义。

### func getSpecifiedClassDef(packageName: String, srcCodeName: String)

```cangjie
public func getSpecifiedClassDef(packageName: String, srcCodeName: String): ?ClassLikeDef
```

功能：在导入与本包 `classDefs` 中按「声明包名 + 源码类型名」查找类/接口定义。

返回值：

- ?ClassLikeDef - 命中则 `Some`，否则 `None`。

### func getSpecifiedStructDef(packageName: String, srcCodeName: String)

```cangjie
public func getSpecifiedStructDef(packageName: String, srcCodeName: String): ?StructDef
```

功能：同上，查找结构体定义。

返回值：

- ?StructDef - 可选结果。

### func getSpecifiedEnumDef(packageName: String, srcCodeName: String)

```cangjie
public func getSpecifiedEnumDef(packageName: String, srcCodeName: String): ?EnumDef
```

功能：同上，查找枚举定义。

返回值：

- ?EnumDef - 可选结果。

### func toString()

```cangjie
public func toString(): String
```

功能：输出包名、访问级别、导入区与本地类型区的拼接文本（调试用）。

返回值：

- String - 完整包描述。

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
    println(pkg.name)
    println("${pkg.classDefs.size}")
}
```

运行结果：

```text
my.pkg
1
```

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

### prop elementType

```cangjie
public prop elementType: Type
```

功能：数组元素类型。

类型：Type

### prop dims

```cangjie
public prop dims: UInt32
```

功能：原始数组维数。

类型：UInt32

### func toString()

```cangjie
public func toString(): String
```

功能：类型的字符串形式（如多维 `[[[T]]]` 风格，见源码）。

返回值：

- String - 文本表示。

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
    let t = RawArrayType.get(IntType.getInt32(), 2)
    println("${t}, dims=${t.dims}")
}
```

运行结果：

```text
..., dims=2
```

（完整 `toString()` 格式以源码为准。）

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

### prop structType

```cangjie
public prop structType: StructType
```

功能：与此定义对应的实例化 [StructType](#class-structtype)。

类型：[StructType](#class-structtype)

### mut prop isCStruct

```cangjie
public mut prop isCStruct: Bool
```

功能：是否标记为与 C 互操作的结构体。

类型：Bool

### operator func==(StructDef)

```cangjie
public operator func==(other: StructDef): Bool
```

功能：比较是否同一结构体定义。

参数：

- other: StructDef - 另一结构体定义。

返回值：

- Bool - 是否相等。

### 完整用例

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let s = pkg.addStruct("S_m", "S")
    s.isCStruct = true
    println(s.structType.structDef == s)
    println(s.isCStruct)
}
```

运行结果：

```text
true
true
```

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

```cangjie
public static func get(def: StructDef, genericTypeParams: Array<Type>): StructType
```

功能：按结构体定义与泛型实参取得或创建缓存实例。

参数：

- def: StructDef - 结构体定义。
- genericTypeParams: Array\<Type> - 泛型实参。

返回值：

- StructType - 实例化结构体类型。

### prop structDef

```cangjie
public prop structDef: StructDef
```

功能：对应的 [StructDef](#class-structdef)。

类型：[StructDef](#class-structdef)

### operator func==(StructType)

```cangjie
public operator func==(other: StructType): Bool
```

功能：比较是否为同一实例化结构体类型。

参数：

- other: StructType - 另一结构体类型。

返回值：

- Bool - 是否相等。

### 完整用例

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addStruct("S_m", "S")
    let st = StructType.get(def, [])
    println(st.structDef.srcCodeName)
    println(st == StructType.get(def, []))
}
```

运行结果：

```text
S
true
```

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

```cangjie
public static func get(): ThisType
```

功能：返回 `This` 类型的唯一单例。

返回值：

- ThisType - 单例。

### operator func==(_: ThisType)

```cangjie
public operator func==(_: ThisType): Bool
```

功能：与另一 `ThisType` 比较（单例恒等）。

参数：

- _: ThisType - 另一实例。

返回值：

- Bool - 恒为 `true`。

### 完整用例

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t1 = ThisType.get()
    let t2 = ThisType.get()
    println(t1 == t2)
}
```

运行结果：

```text
true
```

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

```cangjie
public static func get(elementTypes: Array<Type>): TupleType
```

功能：按元素类型序列取得或创建唯一元组类型。

参数：

- elementTypes: Array\<Type> - 从左到右的元素类型。

返回值：

- TupleType - 元组类型实例。

### prop elementTypes

```cangjie
public prop elementTypes: Array<Type>
```

功能：元组各位置上的类型。

类型：Array\<Type>

### func toString()

```cangjie
public func toString(): String
```

功能：元组类型的字符串表示。

返回值：

- String - 文本形式。

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
    let tup = TupleType.get([IntType.getInt32(), u])
    println("${tup.elementTypes.size}")
}
```

运行结果：

```text
2
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
- Equatable\<Type>

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

### prop elementType

```cangjie
public prop elementType: Type
```

功能：元素类型。

类型：Type

### prop size

```cangjie
public prop size: Int64
```

功能：编译期固定长度。

类型：Int64

### func toString()

```cangjie
public func toString(): String
```

功能：定长 VArray 的字符串表示。

返回值：

- String - 文本形式。

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
    let v = VArrayType.get(IntType.getInt32(), 8)
    println("size=${v.size}")
}
```

运行结果：

```text
size=8
```

---
