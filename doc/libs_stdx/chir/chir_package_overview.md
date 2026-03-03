# stdx.chir

> **说明：**
>
> 当前处于开发阶段，尚不具备完整功能。

## 功能介绍

chir（Cangjie High-level IR）包提供类型系统与 CHIR 声明表示，包括：

- **类型节点**（`Type` 及其子类）：内置标量、引用/装箱、原始数组与 VArray、类/接口/结构体/枚举实例化类型、函数类型、泛型形参、元组、`This` 等；
- **类型定义**（`CustomTypeDef` 系）：类、接口、结构体、枚举、扩展及成员变量；
- **包**（`Package`）与访问级别（`AccessLevel`）；
- **注解**（`Annotation`、`AnnoInfo`）与**调试位置**（`Position`、`DebugLocation`）。

源码目录：[src/stdx/chir](../../../src/stdx/chir)。

## 文档目录（与其它 `libs_stdx` 包一致；下列文件名列**字母序**）

| 文档 | 内容 |
|------|------|
| [chir_package_api/chir_package_classes.md](./chir_package_api/chir_package_classes.md) | 公开 **class** |
| [chir_package_api/chir_package_enums.md](./chir_package_api/chir_package_enums.md) | 公开 **enum** |
| [chir_package_api/chir_package_structs.md](./chir_package_api/chir_package_structs.md) | 公开 **struct** |
| [chir_package_overview.md](./chir_package_overview.md) | 本页：包概述与索引 |

## 公开类型索引

### 类（`chir_package_classes.md`，按类型名**字母序**）

| 类型 | 说明 |
|------|------|
| [Annotation](./chir_package_api/chir_package_classes.md#class-annotation) | 注解类实例信息。 |
| [AnnoInfo](./chir_package_api/chir_package_classes.md#class-annoinfo) | 节点附加注解集合。 |
| [BoolType](./chir_package_api/chir_package_classes.md#class-booltype) | 布尔类型。 |
| [BoxType](./chir_package_api/chir_package_classes.md#class-boxtype) | 装箱类型。 |
| [BuiltinType](./chir_package_api/chir_package_classes.md#class-builtintype) | 内置类型基类。 |
| [CPointerType](./chir_package_api/chir_package_classes.md#class-cpointertype) | C 指针类型。 |
| [CStringType](./chir_package_api/chir_package_classes.md#class-cstringtype) | C 字符串类型。 |
| [ClassLikeDef](./chir_package_api/chir_package_classes.md#class-classlikedef) | 类/接口定义。 |
| [ClassLikeType](./chir_package_api/chir_package_classes.md#class-classliketype) | 类/接口实例化类型。 |
| [CustomType](./chir_package_api/chir_package_classes.md#class-customtype) | 自定义类型抽象基类。 |
| [CustomTypeDef](./chir_package_api/chir_package_classes.md#class-customtypedef) | 自定义类型定义抽象基类。 |
| [DebugLocation](./chir_package_api/chir_package_classes.md#class-debuglocation) | 源码区间位置。 |
| [EnumCtorInfo](./chir_package_api/chir_package_classes.md#class-enumctorinfo) | 枚举构造器/变体信息。 |
| [EnumDef](./chir_package_api/chir_package_classes.md#class-enumdef) | 枚举定义。 |
| [EnumType](./chir_package_api/chir_package_classes.md#class-enumtype) | 枚举实例化类型。 |
| [ExtendDef](./chir_package_api/chir_package_classes.md#class-extenddef) | 扩展定义。 |
| [FloatType](./chir_package_api/chir_package_classes.md#class-floattype) | 浮点类型。 |
| [FuncType](./chir_package_api/chir_package_classes.md#class-functype) | 函数类型。 |
| [GenericType](./chir_package_api/chir_package_classes.md#class-generictype) | 泛型形参类型。 |
| [IntType](./chir_package_api/chir_package_classes.md#class-inttype) | 整数类型。 |
| [MemberVar](./chir_package_api/chir_package_classes.md#class-membervar) | 成员变量描述。 |
| [NothingType](./chir_package_api/chir_package_classes.md#class-nothingtype) | Nothing 底类型。 |
| [NumericType](./chir_package_api/chir_package_classes.md#class-numerictype) | 数值类型抽象基类。 |
| [Package](./chir_package_api/chir_package_classes.md#class-package) | CHIR 包。 |
| [RawArrayType](./chir_package_api/chir_package_classes.md#class-rawarraytype) | 原始数组类型。 |
| [RefType](./chir_package_api/chir_package_classes.md#class-reftype) | 引用类型 `T&`。 |
| [RuneType](./chir_package_api/chir_package_classes.md#class-runetype) | 字符类型。 |
| [StructDef](./chir_package_api/chir_package_classes.md#class-structdef) | 结构体定义。 |
| [StructType](./chir_package_api/chir_package_classes.md#class-structtype) | 结构体实例化类型。 |
| [ThisType](./chir_package_api/chir_package_classes.md#class-thistype) | `This` 类型。 |
| [TupleType](./chir_package_api/chir_package_classes.md#class-tupletype) | 元组类型。 |
| [Type](./chir_package_api/chir_package_classes.md#class-type) | 所有类型的密封抽象基类。 |
| [UnitType](./chir_package_api/chir_package_classes.md#class-unittype) | Unit 类型。 |
| [VArrayType](./chir_package_api/chir_package_classes.md#class-vartype) | 定长 VArray 类型。 |

### 结构体（`chir_package_structs.md`）

| 类型 | 说明 |
|------|------|
| [Position](./chir_package_api/chir_package_structs.md#struct-position) | 源码行列位置。 |

### 枚举（`chir_package_enums.md`）

| 类型 | 说明 |
|------|------|
| [AccessLevel](./chir_package_api/chir_package_enums.md#enum-accesslevel) | 包访问级别。 |
