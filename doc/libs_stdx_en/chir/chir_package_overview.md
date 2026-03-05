# cangjie_stdx::chir

> **Note:**
>
> Currently under development and does not have complete functionality.

## Function Description

The chir package provides fundamental type definitions for the type system, including abstract type base classes, built-in types (integers, floating-point numbers, booleans, characters, etc.), and reference types. This package provides core support for the Cangjie language's type system.

## API List

### Classes

| Class Name                                                                    | Function                                 |
| ----------------------------------------------------------------------- | ------------------------------------ |
| [BoolType](./chir_package_api/chir_package_classes.md#class-booltype)   | Represents the boolean type.                       |
| [CPointerType](./chir_package_api/chir_package_classes.md#class-cpointertype) | Represents a C pointer type for interoperability with C code. |
| [CStringType](./chir_package_api/chir_package_classes.md#class-cstringtype) | Represents a C string type for interoperability with C code. |
| [FloatType](./chir_package_api/chir_package_classes.md#class-floattype) | Represents floating-point types (Float16, Float32, Float64). |
| [IntType](./chir_package_api/chir_package_classes.md#class-inttype)     | Represents integer types (signed and unsigned).     |
| [NothingType](./chir_package_api/chir_package_classes.md#class-nothingtype) | Represents the Nothing type (bottom type).      |
| [NumericType](./chir_package_api/chir_package_classes.md#class-numerictype) | Abstract base class for numeric types.                 |
| [RefType](./chir_package_api/chir_package_classes.md#class-reftype)     | Represents a reference type.                       |
| [RuneType](./chir_package_api/chir_package_classes.md#class-runetype)   | Represents the character type.                       |
| [Type](./chir_package_api/chir_package_classes.md#class-type)           | Abstract base class for all types in the type system.       |
| [UnitType](./chir_package_api/chir_package_classes.md#class-unittype)   | Represents the Unit type (similar to void in C). |
