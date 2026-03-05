# Classes

## class BoolType

```cangjie
public class BoolType <: BuiltinType & Equatable<BoolType>
```

Function: Represents the boolean type in the type system. This is a singleton type representing the Bool type.

Parent Types:

- BuiltinType
- Equatable\<BoolType>

### static func get()

```cangjie
public static func get(): BoolType
```

Function: Gets the singleton instance of BoolType.

Return Value:

- BoolType - The BoolType instance.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let boolType = BoolType.get()
    println("Boolean type: ${boolType.toString()}")
}
```

Output:

```text
Boolean type: Bool
```

### operator func==(BoolType)

```cangjie
public operator func==(_: BoolType): Bool
```

Function: Checks if this BoolType is equal to another BoolType.

Parameters:

- _: BoolType - The other BoolType to compare with (unused, always returns true).

Return Value:

- Bool - Always returns true since all BoolType instances are equal.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let boolType1 = BoolType.get()
    let boolType2 = BoolType.get()
    println("Two BoolType instances are equal: ${boolType1 == boolType2}")
}
```

Output:

```text
Two BoolType instances are equal: true
```

## class CPointerType

```cangjie
public class CPointerType <: BuiltinType & Equatable<CPointerType>
```

Function: Represents a C pointer type in the type system. This type represents a pointer to a C type, used for interoperability with C code. The class maintains a cache of all CPointer types to ensure uniqueness.

Parent Types:

- BuiltinType
- Equatable\<CPointerType>

### prop elementType

```cangjie
public prop elementType: Type
```

Function: Gets the element type that this C pointer type points to.

Return Value:

- Type - The element type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let cPointerType = CPointerType.get(intType)
    let elementType = cPointerType.elementType
    println("C pointer type: ${cPointerType.toString()}")
    println("Element type: ${elementType.toString()}")
}
```

Output:

```text
C pointer type: CPointer<Int32>
Element type: Int32
```

### operator func==(CPointerType)

```cangjie
public operator func==(other: CPointerType): Bool
```

Function: Checks if this CPointerType is equal to another CPointerType.

Parameters:

- other: CPointerType - The CPointerType to compare with.

Return Value:

- Bool - Returns true if the types are equal, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let cPointerType1 = CPointerType.get(intType)
    let cPointerType2 = CPointerType.get(intType)
    println("Two C pointer types are equal: ${cPointerType1 == cPointerType2}")
}
```

Output:

```text
Two C pointer types are equal: true
```

### static func get(Type)

```cangjie
public static func get(elementType: Type): CPointerType
```

Function: Gets or creates a CPointerType for the given element type.

This method ensures that only one CPointerType instance exists for each element type.

Parameters:

- elementType: Type - The type that the pointer points to.

Return Value:

- CPointerType - The CPointerType instance for the given element type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let cPointerType = CPointerType.get(intType)
    println("C pointer type: ${cPointerType.toString()}")
}
```

Output:

```text
C pointer type: CPointer<Int32>
```

### func toString()

```cangjie
public func toString(): String
```

Function: Converts this CPointerType to its string representation.

Return Value:

- String - A string representation of the C pointer type (CPointer\<elementType>).

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let cPointerType = CPointerType.get(intType)
    println("C pointer type string: ${cPointerType.toString()}")
}
```

Output:

```text
C pointer type string: CPointer<Int32>
```

## class CStringType

```cangjie
public class CStringType <: BuiltinType & Equatable<CStringType>
```

Function: Represents the C string type in the type system. This type represents a C-style null-terminated string, used for interoperability with C code. This is a singleton type representing the built-in C string type.

Parent Types:

- BuiltinType
- Equatable\<CStringType>

### operator func==(CStringType)

```cangjie
public operator func==(_: CStringType): Bool
```

Function: Checks if this CStringType is equal to another CStringType.

Parameters:

- _: CStringType - The other CStringType to compare with (unused, always returns true).

Return Value:

- Bool - Always returns true since all CStringType instances are equal.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let cStringType1 = CStringType.get()
    let cStringType2 = CStringType.get()
    println("Two CStringType instances are equal: ${cStringType1 == cStringType2}")
}
```

Output:

```text
Two CStringType instances are equal: true
```

### static func get()

```cangjie
public static func get(): CStringType
```

Function: Gets the singleton instance of CStringType.

Return Value:

- CStringType - The CStringType instance.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let cStringType = CStringType.get()
    println("C string type: ${cStringType.toString()}")
}
```

Output:

```text
C string type: CString
```

## class FloatType

```cangjie
public class FloatType <: NumericType & Equatable<FloatType>
```

Function: Represents floating-point types in the type system. This class represents the three floating-point types: Float16, Float32, and Float64.

Parent Types:

- [NumericType](#class-numerictype)
- Equatable\<FloatType>

### static func getFloat16()

```cangjie
public static func getFloat16(): FloatType
```

Function: Gets the Float16 type instance.

Return Value:

- FloatType - The Float16 type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let float16Type = FloatType.getFloat16()
    println("Float16 type: ${float16Type.toString()}")
}
```

Output:

```text
Float16 type: Float16
```

### static func getFloat32()

```cangjie
public static func getFloat32(): FloatType
```

Function: Gets the Float32 type instance.

Return Value:

- FloatType - The Float32 type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let float32Type = FloatType.getFloat32()
    println("Float32 type: ${float32Type.toString()}")
}
```

Output:

```text
Float32 type: Float32
```

### static func getFloat64()

```cangjie
public static func getFloat64(): FloatType
```

Function: Gets the Float64 type instance.

Return Value:

- FloatType - The Float64 type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let float64Type = FloatType.getFloat64()
    println("Float64 type: ${float64Type.toString()}")
}
```

Output:

```text
Float64 type: Float64
```

### operator func==(FloatType)

```cangjie
public operator func==(other: FloatType): Bool
```

Function: Checks if this FloatType is equal to another FloatType.

Parameters:

- other: FloatType - The FloatType to compare with.

Return Value:

- Bool - Returns true if the types are equal, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let float32Type1 = FloatType.getFloat32()
    let float32Type2 = FloatType.getFloat32()
    let float64Type = FloatType.getFloat64()
    println("Two Float32 types are equal: ${float32Type1 == float32Type2}")
    println("Float32 and Float64 are equal: ${float32Type1 == float64Type}")
}
```

Output:

```text
Two Float32 types are equal: true
Float32 and Float64 are equal: false
```

## class IntType

```cangjie
public class IntType <: NumericType & Equatable<IntType>
```

Function: Represents integer types in the type system. This class represents both signed and unsigned integer types of various sizes.

Parent Types:

- [NumericType](#class-numerictype)
- Equatable\<IntType>

### static func getInt16()

```cangjie
public static func getInt16(): IntType
```

Function: Gets the Int16 type instance.

Return Value:

- IntType - The Int16 type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let int16Type = IntType.getInt16()
    println("Int16 type: ${int16Type.toString()}")
}
```

Output:

```text
Int16 type: Int16
```

### static func getInt32()

```cangjie
public static func getInt32(): IntType
```

Function: Gets the Int32 type instance.

Return Value:

- IntType - The Int32 type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let int32Type = IntType.getInt32()
    println("Int32 type: ${int32Type.toString()}")
}
```

Output:

```text
Int32 type: Int32
```

### static func getInt64()

```cangjie
public static func getInt64(): IntType
```

Function: Gets the Int64 type instance.

Return Value:

- IntType - The Int64 type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let int64Type = IntType.getInt64()
    println("Int64 type: ${int64Type.toString()}")
}
```

Output:

```text
Int64 type: Int64
```

### static func getInt8()

```cangjie
public static func getInt8(): IntType
```

Function: Gets the Int8 type instance.

Return Value:

- IntType - The Int8 type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let int8Type = IntType.getInt8()
    println("Int8 type: ${int8Type.toString()}")
}
```

Output:

```text
Int8 type: Int8
```

### static func getIntNative()

```cangjie
public static func getIntNative(): IntType
```

Function: Gets the IntNative type instance.

Return Value:

- IntType - The IntNative type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intNativeType = IntType.getIntNative()
    println("IntNative type: ${intNativeType.toString()}")
}
```

Output:

```text
IntNative type: IntNative
```

### static func getUInt16()

```cangjie
public static func getUInt16(): IntType
```

Function: Gets the UInt16 type instance.

Return Value:

- IntType - The UInt16 type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let uint16Type = IntType.getUInt16()
    println("UInt16 type: ${uint16Type.toString()}")
}
```

Output:

```text
UInt16 type: UInt16
```

### static func getUInt32()

```cangjie
public static func getUInt32(): IntType
```

Function: Gets the UInt32 type instance.

Return Value:

- IntType - The UInt32 type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let uint32Type = IntType.getUInt32()
    println("UInt32 type: ${uint32Type.toString()}")
}
```

Output:

```text
UInt32 type: UInt32
```

### static func getUInt64()

```cangjie
public static func getUInt64(): IntType
```

Function: Gets the UInt64 type instance.

Return Value:

- IntType - The UInt64 type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let uint64Type = IntType.getUInt64()
    println("UInt64 type: ${uint64Type.toString()}")
}
```

Output:

```text
UInt64 type: UInt64
```

### static func getUInt8()

```cangjie
public static func getUInt8(): IntType
```

Function: Gets the UInt8 type instance.

Return Value:

- IntType - The UInt8 type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let uint8Type = IntType.getUInt8()
    println("UInt8 type: ${uint8Type.toString()}")
}
```

Output:

```text
UInt8 type: UInt8
```

### static func getUIntNative()

```cangjie
public static func getUIntNative(): IntType
```

Function: Gets the UIntNative type instance.

Return Value:

- IntType - The UIntNative type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let uintNativeType = IntType.getUIntNative()
    println("UIntNative type: ${uintNativeType.toString()}")
}
```

Output:

```text
UIntNative type: UIntNative
```

### operator func==(IntType)

```cangjie
public operator func==(other: IntType): Bool
```

Function: Checks if this IntType is equal to another IntType.

Parameters:

- other: IntType - The IntType to compare with.

Return Value:

- Bool - Returns true if the types are equal, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let int32Type1 = IntType.getInt32()
    let int32Type2 = IntType.getInt32()
    let int64Type = IntType.getInt64()
    println("Two Int32 types are equal: ${int32Type1 == int32Type2}")
    println("Int32 and Int64 are equal: ${int32Type1 == int64Type}")
}
```

Output:

```text
Two Int32 types are equal: true
Int32 and Int64 are equal: false
```

### func isSigned()

```cangjie
public func isSigned(): Bool
```

Function: Checks if this integer type is signed.

Return Value:

- Bool - Returns true if the type is signed, false if it is unsigned.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let int32Type = IntType.getInt32()
    let uint32Type = IntType.getUInt32()
    println("Int32 is signed: ${int32Type.isSigned()}")
    println("UInt32 is signed: ${uint32Type.isSigned()}")
}
```

Output:

```text
Int32 is signed: true
UInt32 is signed: false
```

## class NothingType

```cangjie
public class NothingType <: BuiltinType & Equatable<NothingType>
```

Function: Represents the nothing type in the type system. This type represents the bottom type, used for expressions that never return.

Parent Types:

- BuiltinType
- Equatable\<NothingType>

### static func get()

```cangjie
public static func get(): NothingType
```

Function: Gets the singleton instance of NothingType.

Return Value:

- NothingType - The NothingType instance.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let nothingType = NothingType.get()
    println("Nothing type: ${nothingType.toString()}")
}
```

Output:

```text
Nothing type: Nothing
```

### operator func==(NothingType)

```cangjie
public operator func==(_: NothingType): Bool
```

Function: Checks if this NothingType is equal to another NothingType.

Parameters:

- _: NothingType - The other NothingType to compare with (unused, always returns true).

Return Value:

- Bool - Always returns true since all NothingType instances are equal.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let nothingType1 = NothingType.get()
    let nothingType2 = NothingType.get()
    println("Two NothingType instances are equal: ${nothingType1 == nothingType2}")
}
```

Output:

```text
Two NothingType instances are equal: true
```

## class NumericType

```cangjie
sealed abstract class NumericType <: BuiltinType & Equatable<NumericType>
```

Function: Abstract base class for numeric types. This class represents types that are numeric, including both integer and floating-point types.

Parent Types:

- BuiltinType
- Equatable\<NumericType>

### operator func==(NumericType)

```cangjie
public operator func==(other: NumericType): Bool
```

Function: Checks if this numeric type is equal to another numeric type.

Parameters:

- other: NumericType - The numeric type to compare with.

Return Value:

- Bool - Returns true if the types are equal, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType1 = IntType.getInt32()
    let intType2 = IntType.getInt32()
    let floatType = FloatType.getFloat32()
    println("Two Int32 types are equal: ${intType1 == intType2}")
    println("Int32 and Float32 are equal: ${intType1 == floatType}")
}
```

Output:

```text
Two Int32 types are equal: true
Int32 and Float32 are equal: false
```

## class RefType

```cangjie
public class RefType <: Type & Equatable<RefType>
```

Function: Represents a reference type in the type system. This type wraps another type to represent a reference to that type. The class maintains a cache of all reference types to ensure uniqueness.

Parent Types:

- [Type](#class-type)
- Equatable\<RefType>

### prop baseType

```cangjie
public prop baseType: Type
```

Function: Gets the base type that this reference type refers to.

Return Value:

- Type - The base type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let refType = RefType.get(intType)
    let baseType = refType.baseType
    println("Reference type: ${refType.toString()}")
    println("Base type: ${baseType.toString()}")
}
```

Output:

```text
Reference type: Int32&
Base type: Int32
```

### operator func==(RefType)

```cangjie
public operator func==(other: RefType): Bool
```

Function: Checks if this RefType is equal to another RefType.

Parameters:

- other: RefType - The RefType to compare with.

Return Value:

- Bool - Returns true if the types are equal, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let refType1 = RefType.get(intType)
    let refType2 = RefType.get(intType)
    println("Two reference types are equal: ${refType1 == refType2}")
}
```

Output:

```text
Two reference types are equal: true
```

### static func get(Type)

```cangjie
public static func get(baseType: Type): RefType
```

Function: Gets or creates a RefType for the given base type.

This method ensures that only one RefType instance exists for each base type.

Parameters:

- baseType: Type - The base type to create a reference to.

Return Value:

- RefType - The RefType instance for the given base type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let refType = RefType.get(intType)
    println("Reference type: ${refType.toString()}")
}
```

Output:

```text
Reference type: Int32&
```

### func toString()

```cangjie
public func toString(): String
```

Function: Converts this RefType to its string representation.

Return Value:

- String - 引用类型的字符串表示（基类型后跟 '&'）。

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let refType = RefType.get(intType)
    println("Reference type string: ${refType.toString()}")
}
```

Output:

```text
Reference type string: Int32&
```

## class RuneType

```cangjie
public class RuneType <: BuiltinType & Equatable<RuneType>
```

Function: Represents the rune type in the type system. This type represents a character type.

Parent Types:

- BuiltinType
- Equatable\<RuneType>

### static func get()

```cangjie
public static func get(): RuneType
```

Function: Gets the singleton instance of RuneType.

Return Value:

- RuneType - The RuneType instance.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let runeType = RuneType.get()
    println("Rune type: ${runeType.toString()}")
}
```

Output:

```text
Rune type: Rune
```

### operator func==(RuneType)

```cangjie
public operator func==(_: RuneType): Bool
```

Function: Checks if this RuneType is equal to another RuneType.

Parameters:

- _: RuneType - The other RuneType to compare with (unused, always returns true).

Return Value:

- Bool - Always returns true since all RuneType instances are equal.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let runeType1 = RuneType.get()
    let runeType2 = RuneType.get()
    println("Two RuneType instances are equal: ${runeType1 == runeType2}")
}
```

Output:

```text
Two RuneType instances are equal: true
```

## class Type

```cangjie
sealed abstract class Type <: ToString & Hashable & Equatable<Type>
```

Function: Abstract base class representing a type in the type system. This class provides the foundation for all types in Cangjie, including primitive types, composite types, and special types. It implements equality comparison, hashing, and string conversion.

Parent Types:

- ToString
- Hashable
- Equatable\<Type>

### prop typeArgs

```cangjie
public prop typeArgs: Array<Type>
```

Function: Gets the type arguments of this type.

Return Value:

- Array\<Type> - An array of type arguments.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    println("Number of type arguments: ${intType.typeArgs.size}")
}
```

Output:

```text
Number of type arguments: 0
```

### func dump()

```cangjie
public func dump(): Unit
```

Function: Prints the string representation of this type to standard output.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    intType.dump()
}
```

Output:

```text
Int32
```

### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash code of this type.

Return Value:

- Int64 - The hash code as an Int64.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    println("Hash code: ${intType.hashCode()}")
}
```

Output:

```text
Hash code: -7959616418923165251
```

### func isBoolType()

```cangjie
public func isBoolType(): Bool
```

Function: Checks if this type is the boolean type.

Return Value:

- Bool - Returns true if the type is Bool, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let boolType = BoolType.get()
    let intType = IntType.getInt32()
    println("BoolType 是Boolean type: ${boolType.isBoolType()}")
    println("Int32 是Boolean type: ${intType.isBoolType()}")
}
```

Output:

```text
BoolType 是Boolean type: true
Int32 是Boolean type: false
```

### func isFloatType()

```cangjie
public func isFloatType(): Bool
```

Function: Checks if this type is a floating-point type.

Return Value:

- Bool - Returns true if the type is Float16, Float32, or Float64, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let floatType = FloatType.getFloat32()
    let intType = IntType.getInt32()
    println("Float32 is floating-point type: ${floatType.isFloatType()}")
    println("Int32 is floating-point type: ${intType.isFloatType()}")
}
```

Output:

```text
Float32 is floating-point type: true
Int32 is floating-point type: false
```

### func isIntType()

```cangjie
public func isIntType(): Bool
```

Function: Checks if this type is an integer type (signed or unsigned).

Return Value:

- Bool - Returns true if the type is any integer type, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let floatType = FloatType.getFloat32()
    println("Int32 is integer type: ${intType.isIntType()}")
    println("Float32 is integer type: ${floatType.isIntType()}")
}
```

Output:

```text
Int32 is integer type: true
Float32 is integer type: false
```

### func isNothingType()

```cangjie
public func isNothingType(): Bool
```

Function: Checks if this type is the nothing type.

Return Value:

- Bool - Returns true if the type is Nothing, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let nothingType = NothingType.get()
    let intType = IntType.getInt32()
    println("NothingType 是 Nothing type: ${nothingType.isNothingType()}")
    println("Int32 是 Nothing type: ${intType.isNothingType()}")
}
```

Output:

```text
NothingType 是 Nothing type: true
Int32 是 Nothing type: false
```

### func isNumericType()

```cangjie
public func isNumericType(): Bool
```

Function: Checks if this type is a numeric type (integer or floating-point).

Return Value:

- Bool - Returns true if the type is numeric, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let floatType = FloatType.getFloat32()
    let boolType = BoolType.get()
    println("Int32 is numeric type: ${intType.isNumericType()}")
    println("Float32 is numeric type: ${floatType.isNumericType()}")
    println("Bool is numeric type: ${boolType.isNumericType()}")
}
```

Output:

```text
Int32 is numeric type: true
Float32 is numeric type: true
Bool is numeric type: false
```

### func isPrimitiveType()

```cangjie
public func isPrimitiveType(): Bool
```

Function: Checks if this type is a primitive type.

Return Value:

- Bool - Returns true if the type is primitive (int, float, bool, rune, unit, or nothing), false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let boolType = BoolType.get()
    println("Int32 is primitive type: ${intType.isPrimitiveType()}")
    println("Bool is primitive type: ${boolType.isPrimitiveType()}")
}
```

Output:

```text
Int32 is primitive type: true
Bool is primitive type: true
```

### func isRefType()

```cangjie
public func isRefType(): Bool
```

Function: Checks if this type is a reference type.

Return Value:

- Bool - Returns true if the type is a reference type, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let refType = RefType.get(intType)
    println("Int32 是Reference type: ${intType.isRefType()}")
    println("Int32& 是Reference type: ${refType.isRefType()}")
}
```

Output:

```text
Int32 是Reference type: false
Int32& 是Reference type: true
```

### func isRuneType()

```cangjie
public func isRuneType(): Bool
```

Function: Checks if this type is the rune type.

Return Value:

- Bool - Returns true if the type is Rune, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let runeType = RuneType.get()
    let intType = IntType.getInt32()
    println("RuneType 是 Rune type: ${runeType.isRuneType()}")
    println("Int32 是 Rune type: ${intType.isRuneType()}")
}
```

Output:

```text
RuneType 是 Rune type: true
Int32 是 Rune type: false
```

### func isSignedIntType()

```cangjie
public func isSignedIntType(): Bool
```

Function: Checks if this type is a signed integer type.

Return Value:

- Bool - Returns true if the type is a signed integer type, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let uintType = IntType.getUInt32()
    println("Int32 is signed integer: ${intType.isSignedIntType()}")
    println("UInt32 is signed integer: ${uintType.isSignedIntType()}")
}
```

Output:

```text
Int32 is signed integer: true
UInt32 is signed integer: false
```

### func isUnitType()

```cangjie
public func isUnitType(): Bool
```

Function: Checks if this type is the unit type.

Return Value:

- Bool - Returns true if the type is Unit, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let unitType = UnitType.get()
    let intType = IntType.getInt32()
    println("UnitType is Unit type: ${unitType.isUnitType()}")
    println("Int32 is Unit type: ${intType.isUnitType()}")
}
```

Output:

```text
UnitType is Unit type: true
Int32 is Unit type: false
```

### func isUnsignedIntType()

```cangjie
public func isUnsignedIntType(): Bool
```

Function: Checks if this type is an unsigned integer type.

Return Value:

- Bool - Returns true if the type is an unsigned integer type, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let uintType = IntType.getUInt32()
    println("Int32 is unsigned integer: ${intType.isUnsignedIntType()}")
    println("UInt32 is unsigned integer: ${uintType.isUnsignedIntType()}")
}
```

Output:

```text
Int32 is unsigned integer: false
UInt32 is unsigned integer: true
```

### operator func==(Type)

```cangjie
public open operator func==(other: Type): Bool
```

Function: Checks if this type is equal to another type.

Parameters:

- other: Type - The type to compare with.

Return Value:

- Bool - Returns true if the types have the same kind and type arguments, false otherwise.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let type1 = IntType.getInt32()
    let type2 = IntType.getInt32()
    let type3 = IntType.getInt64()
    println("type1 == type2: ${type1 == type2}")
    println("type1 == type3: ${type1 == type3}")
}
```

Output:

```text
type1 == type2: true
type1 == type3: false
```

### func stripAllRefs()

```cangjie
public func stripAllRefs(): Type
```

Function: Strips all reference wrappers from this type.

Recursively removes all Ref type wrappers until a non-reference type is reached.

Return Value:

- Type - The base type after removing all reference wrappers.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    let refType = RefType.get(intType)
    let baseType = refType.stripAllRefs()
    println("Reference type: ${refType.toString()}")
    println("After stripping references: ${baseType.toString()}")
}
```

Output:

```text
Reference type: Int32&
After stripping references: Int32
```

### func toString()

```cangjie
public open func toString(): String
```

Function: Converts this type to its string representation.

Return Value:

- String - A string representation of the type.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let intType = IntType.getInt32()
    println("Type: ${intType.toString()}")
}
```

Output:

```text
Type: Int32
```

## class UnitType

```cangjie
public class UnitType <: BuiltinType & Equatable<UnitType>
```

Function: Represents the unit type in the type system. This type represents the absence of a meaningful value, similar to void in C.

Parent Types:

- BuiltinType
- Equatable\<UnitType>

### static func get()

```cangjie
public static func get(): UnitType
```

Function: Gets the singleton instance of UnitType.

Return Value:

- UnitType - The UnitType instance.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let unitType = UnitType.get()
    println("Unit Type: ${unitType.toString()}")
}
```

Output:

```text
Unit Type: Unit
```

### operator func==(UnitType)

```cangjie
public operator func==(_: UnitType): Bool
```

Function: Checks if this UnitType is equal to another UnitType.

Parameters:

- _: UnitType - The other UnitType to compare with (unused, always returns true).

Return Value:

- Bool - Always returns true since all UnitType instances are equal.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::chir.*

main() {
    let unitType1 = UnitType.get()
    let unitType2 = UnitType.get()
    println("Two UnitType instances are equal: ${unitType1 == unitType2}")
}
```

Output:

```text
Two UnitType instances are equal: true
```
