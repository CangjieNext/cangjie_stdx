# stdx.chir

> **说明：**
>
> 当前处于开发阶段，尚不具备完整功能。

## 功能介绍

chir 包提供类型系统的基础类型定义，包括抽象类型基类、内置类型（整数、浮点数、布尔、字符等）以及引用类型等。该包为仓颉语言的类型系统提供核心支持。

## API 列表

### 类

| 类名                                                                    | 功能                                 |
| ----------------------------------------------------------------------- | ------------------------------------ |
| [BoolType](./chir_package_api/chir_package_classes.md#class-booltype)   | 表示布尔类型。                       |
| [CPointerType](./chir_package_api/chir_package_classes.md#class-cpointertype) | 表示 C 指针类型，用于与 C 代码互操作。 |
| [CStringType](./chir_package_api/chir_package_classes.md#class-cstringtype) | 表示 C 字符串类型，用于与 C 代码互操作。 |
| [FloatType](./chir_package_api/chir_package_classes.md#class-floattype) | 表示浮点类型（Float16、Float32、Float64）。 |
| [IntType](./chir_package_api/chir_package_classes.md#class-inttype)     | 表示整数类型（有符号和无符号）。     |
| [NothingType](./chir_package_api/chir_package_classes.md#class-nothingtype) | 表示 Nothing 类型（底部类型）。      |
| [NumericType](./chir_package_api/chir_package_classes.md#class-numerictype) | 数值类型的抽象基类。                 |
| [RefType](./chir_package_api/chir_package_classes.md#class-reftype)     | 表示引用类型。                       |
| [RuneType](./chir_package_api/chir_package_classes.md#class-runetype)   | 表示字符类型。                       |
| [Type](./chir_package_api/chir_package_classes.md#class-type)           | 类型系统中所有类型的抽象基类。       |
| [UnitType](./chir_package_api/chir_package_classes.md#class-unittype)   | 表示 Unit 类型（类似 C 语言中的 void）。 |
