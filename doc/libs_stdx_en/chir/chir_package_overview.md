# stdx.chir

> **Note:**
>
> Under active development; functionality is not yet complete.

## Overview

The **chir** (Cangjie High-level IR) package provides the type system and CHIR declaration model, including:

- **Type nodes** (`Type` and subclasses): built-in scalars, reference/boxed types, raw arrays and VArray, class/interface/struct/enum instantiated types, function types, generic parameters, tuples, `This`, and more;
- **Type definitions** (`CustomTypeDef` family): classes, interfaces, structs, enums, extensions, and member variables;
- **Packages** (`Package`) and **access levels** (`AccessLevel`);
- **Annotations** (public type `Annotation`; multiple annotations on a node are exposed as `Array<Annotation>`) and **debug locations** (`Position`, `DebugLocation`).

## API index

### Classes

| Name | Description |
| --- | --- |
| [Annotation](./chir_package_api/chir_package_classes.md#class-annotation) | A single `@Anno[...]` annotation instance. |
| [BoolType](./chir_package_api/chir_package_classes.md#class-booltype) | Boolean type. |
| [BoxType](./chir_package_api/chir_package_classes.md#class-boxtype) | Boxed type. |
| [BuiltinType](./chir_package_api/chir_package_classes.md#class-builtintype) | Base class for built-in types. |
| [CPointerType](./chir_package_api/chir_package_classes.md#class-cpointertype) | C pointer type. |
| [CStringType](./chir_package_api/chir_package_classes.md#class-cstringtype) | C string type. |
| [ClassLikeDef](./chir_package_api/chir_package_classes.md#class-classlikedef) | Class or interface definition. |
| [ClassLikeType](./chir_package_api/chir_package_classes.md#class-classliketype) | Instantiated class/interface type. |
| [CustomType](./chir_package_api/chir_package_classes.md#class-customtype) | Abstract base for custom instantiated types. |
| [CustomTypeDef](./chir_package_api/chir_package_classes.md#class-customtypedef) | Abstract base for custom type definitions. |
| [DebugLocation](./chir_package_api/chir_package_classes.md#class-debuglocation) | Source span (debug location). |
| [EnumCtorInfo](./chir_package_api/chir_package_classes.md#class-enumctorinfo) | Enum constructor / variant info. |
| [EnumDef](./chir_package_api/chir_package_classes.md#class-enumdef) | Enum definition. |
| [EnumType](./chir_package_api/chir_package_classes.md#class-enumtype) | Instantiated enum type. |
| [ExtendDef](./chir_package_api/chir_package_classes.md#class-extenddef) | Extension definition. |
| [FloatType](./chir_package_api/chir_package_classes.md#class-floattype) | Floating-point type. |
| [FuncType](./chir_package_api/chir_package_classes.md#class-functype) | Function type. |
| [GenericType](./chir_package_api/chir_package_classes.md#class-generictype) | Generic parameter type. |
| [IntType](./chir_package_api/chir_package_classes.md#class-inttype) | Integer type. |
| [MemberVar](./chir_package_api/chir_package_classes.md#class-membervar) | Member variable description. |
| [NothingType](./chir_package_api/chir_package_classes.md#class-nothingtype) | Nothing (bottom) type. |
| [NumericType](./chir_package_api/chir_package_classes.md#class-numerictype) | Abstract base for numeric types. |
| [Package](./chir_package_api/chir_package_classes.md#class-package) | CHIR package. |
| [RawArrayType](./chir_package_api/chir_package_classes.md#class-rawarraytype) | Raw array type. |
| [RefType](./chir_package_api/chir_package_classes.md#class-reftype) | Reference type `T&`. |
| [RuneType](./chir_package_api/chir_package_classes.md#class-runetype) | Character type. |
| [StructDef](./chir_package_api/chir_package_classes.md#class-structdef) | Struct definition. |
| [StructType](./chir_package_api/chir_package_classes.md#class-structtype) | Instantiated struct type. |
| [ThisType](./chir_package_api/chir_package_classes.md#class-thistype) | `This` type. |
| [TupleType](./chir_package_api/chir_package_classes.md#class-tupletype) | Tuple type. |
| [Type](./chir_package_api/chir_package_classes.md#class-type) | Sealed abstract base for all types. |
| [UnitType](./chir_package_api/chir_package_classes.md#class-unittype) | Unit type. |
| [VArrayType](./chir_package_api/chir_package_classes.md#class-varraytype) | Fixed-size VArray type. |

### Enums

| Name | Description |
| --- | --- |
| [AccessLevel](./chir_package_api/chir_package_enums.md#enum-accesslevel) | Package access level. |

### Structs

| Name | Description |
| --- | --- |
| [Position](./chir_package_api/chir_package_structs.md#struct-position) | Source line/column position. |
