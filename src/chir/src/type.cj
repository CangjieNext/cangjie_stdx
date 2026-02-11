/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package cangjie_stdx::chir

import std.collection.{ArrayList, HashMap}
import std.deriving.Derive

/**
 * @brief Enumeration of all type kinds in the type system.
 *
 * This enum represents the different categories of types that can exist
 * in the Cangjie type system, including primitive types, composite types,
 * and special types.
 */
@Derive[Equatable]
internal enum TypeKind <: ToString {
    Invalid
    | `Int8`
    | `Int16`
    | `Int32`
    | `Int64`
    | `IntNative`
    | `UInt8`
    | `UInt16`
    | `UInt32`
    | `UInt64`
    | `UIntNative`
    | `Float16`
    | `Float32`
    | `Float64`
    | `Bool`
    | `Rune`
    | `Unit`
    | `Nothing`
    | CPointer
    | CString
    | Class
    | Enum
    | Struct
    | Tuple
    | RawArray
    | `VArray`
    | Generic
    | Ref
    | Box
    | `This`
    | Func

    internal func toUInt(): UInt32 {
        match (this) {
            case Invalid =>     0
            case `Int8` =>        1
            case `Int16` =>       2
            case `Int32` =>       3
            case `Int64` =>       4
            case `IntNative` =>  5
            case `UInt8` =>       6
            case `UInt16` =>      7
            case `UInt32` =>      8
            case `UInt64` =>      9
            case `UIntNative` => 10
            case `Float16` =>     11
            case `Float32` =>     12
            case `Float64` =>     13
            case `Bool` =>        14
            case `Rune` =>        15
            case `Unit` =>        16
            case `Nothing` =>     17
            case CPointer =>    18
            case CString =>     19
            case Class =>       20
            case Enum =>        21
            case Struct =>      22
            case Tuple =>       23
            case RawArray =>   24
            case `VArray` =>      25
            case Generic =>     26
            case Ref =>         27
            case Box =>         28
            case `This` =>        29
            case Func =>        30
        }
    }
    /**
     * @brief Converts the type kind to its string representation.
     * @return A string representation of the type kind.
     */
    public func toString(): String {
        match (this) {
            case Invalid =>     "Invalid"
            case `Int8` =>        "Int8"
            case `Int16` =>       "Int16"
            case `Int32` =>       "Int32"
            case `Int64` =>       "Int64"
            case `IntNative` =>  "IntNative"
            case `UInt8` =>       "UInt8"
            case `UInt16` =>      "UInt16"
            case `UInt32` =>      "UInt32"
            case `UInt64` =>      "UInt64"
            case `UIntNative` => "UIntNative"
            case `Float16` =>     "Float16"
            case `Float32` =>     "Float32"
            case `Float64` =>     "Float64"
            case `Bool` =>        "Bool"
            case `Rune` =>        "Rune"
            case `Unit` =>        "Unit"
            case `Nothing` =>     "Nothing"
            case Class =>       "Class"
            case Enum =>        "Enum"
            case Struct =>      "Struct"
            case Tuple =>       "Tuple"
            case CPointer =>    "CPointer"
            case CString =>     "CString"
            case RawArray =>   "RawArray"
            case `VArray` =>      "VArray"
            case Generic =>     "Generic"
            case Ref =>         "Ref"
            case Box =>         "Box"
            case `This` =>        "This"
            case Func =>        "Func"
        }
    }
}

/**
 * @brief Abstract base class representing a type in the type system.
 *
 * This class provides the foundation for all types in Cangjie, including
 * primitive types, composite types, and special types. It implements
 * equality comparison, hashing, and string conversion.
 */
sealed abstract class Type <: ToString & Hashable & Equatable<Type> {
    internal let _kind: TypeKind
    internal let _typeArgs: ArrayList<Type>
    internal var _hashCode: Int64 = 0

    /**
     * @brief Checks if this type is equal to another type.
     * @param other The type to compare with.
     * @return true if the types have the same kind and type arguments, false otherwise.
     */
    public open operator func ==(other: Type): Bool {
        return hasSameTypeKindAndArgs(other)
    }

    /**
     * @brief Gets the type arguments of this type.
     * @return An array of type arguments.
     */
    public prop typeArgs: Array<Type> {
        get() {
            return _typeArgs.toArray()
        }
    }

    /**
     * @brief Gets the hash code of this type.
     * @return The hash code as an Int64.
     */
    public func hashCode(): Int64 {
        return _hashCode
    }

    /**
     * @brief Prints the string representation of this type to standard output.
     */
    public func dump(): Unit {
        println(toString())
    }

    /**
     * @brief Converts this type to its string representation.
     * @return A string representation of the type.
     */
    public open func toString(): String {
        return _kind.toString()
    }

    /**
     * @brief Checks if this type is a floating-point type.
     * @return true if the type is Float16, Float32, or Float64, false otherwise.
     */
    public func isFloatType(): Bool {
        return _kind == TypeKind.`Float16` || _kind == TypeKind.`Float32` || _kind == TypeKind.`Float64`
    }

    /**
     * @brief Checks if this type is an integer type (signed or unsigned).
     * @return true if the type is any integer type, false otherwise.
     */
    public func isIntType(): Bool {
        let kindId = this._kind.toUInt()
        return kindId >= TypeKind.`Int8`.toUInt() && kindId <= TypeKind.`UIntNative`.toUInt()
    }

    /**
     * @brief Checks if this type is a signed integer type.
     * @return true if the type is a signed integer type, false otherwise.
     */
    public func isSignedIntType(): Bool {
        let kindId = this._kind.toUInt()
        return kindId >= TypeKind.`Int8`.toUInt() && kindId <= TypeKind.`IntNative`.toUInt()
    }

    /**
     * @brief Checks if this type is an unsigned integer type.
     * @return true if the type is an unsigned integer type, false otherwise.
     */
    public func isUnsignedIntType(): Bool {
        let kindId = this._kind.toUInt()
        return kindId >= TypeKind.`UInt8`.toUInt() && kindId <= TypeKind.`UIntNative`.toUInt()
    }

    /**
     * @brief Checks if this type is a numeric type (integer or floating-point).
     * @return true if the type is numeric, false otherwise.
     */
    public func isNumericType(): Bool {
        return isFloatType() || isIntType()
    }

    /**
     * @brief Checks if this type is the boolean type.
     * @return true if the type is Bool, false otherwise.
     */
    public func isBoolType(): Bool {
        return _kind == TypeKind.`Bool`
    }

    /**
     * @brief Checks if this type is the rune type.
     * @return true if the type is Rune, false otherwise.
     */
    public func isRuneType(): Bool {
        return _kind == TypeKind.`Rune`
    }

    /**
     * @brief Checks if this type is the unit type.
     * @return true if the type is Unit, false otherwise.
     */
    public func isUnitType(): Bool {
        return _kind == TypeKind.`Unit`
    }

    /**
     * @brief Checks if this type is the nothing type.
     * @return true if the type is Nothing, false otherwise.
     */
    public func isNothingType(): Bool {
        return _kind == TypeKind.`Nothing`
    }

    /**
     * @brief Checks if this type is a reference type.
     * @return true if the type is a reference type, false otherwise.
     */
    public func isRefType(): Bool {
        return _kind == TypeKind.Ref
    }

    /**
     * @brief Checks if this type is a primitive type.
     * @return true if the type is primitive (Int, Float, Bool, Rune, Unit, or Nothing), false otherwise.
     */
    public func isPrimitiveType(): Bool {
        let kindId = this._kind.toUInt()
        return kindId >= TypeKind.`Int8`.toUInt() && kindId <= TypeKind.`Nothing`.toUInt()
    }

    /**
     * @brief Strips all reference wrappers from this type.
     *
     * Recursively removes all Ref type wrappers until a non-reference type is reached.
     * @return The base type after removing all reference wrappers.
     */
    public func stripAllRefs(): Type {
        var baseTy: Type = this
        while (baseTy.isRefType()) {
            baseTy = baseTy._typeArgs[0]
        }
        return baseTy
    }

    internal init(kind: TypeKind) {
        this._kind = kind
        this._typeArgs = ArrayList<Type>()
    }

    internal init(kind: TypeKind, args: ArrayList<Type>) {
        this._kind = kind
        this._typeArgs = args
    }

    internal func setHashCode(): Unit {
        _hashCode = toString().hashCode()
    }

    internal func hasSameTypeKindAndArgs(other: Type): Bool {
        return this._kind == other._kind && this._typeArgs == other._typeArgs
    }

    internal func hasSameTypeKindWith(other: Type): Bool {
        return this._kind == other._kind
    }
}

internal abstract class BuiltinType <: Type {
    internal init(kind: TypeKind) {
        super(kind)
    }

    internal init(kind: TypeKind, args: ArrayList<Type>) {
        super(kind, args)
    }
}

/**
 * @brief Represents the Bool type in the type system.
 *
 * This is a singleton type representing the Bool type.
 */
public class BoolType <: BuiltinType & Equatable<BoolType> {
    private static let BOOL_TYPE = BoolType()

    /**
     * @brief Gets the singleton instance of BoolType.
     * @return The BoolType instance.
     */
    public static func get(): BoolType {
        return BOOL_TYPE
    }

    /**
     * @brief Checks if this BoolType is equal to another BoolType.
     * @param _ The other BoolType to compare with (unused, always returns true).
     * @return Always returns true since all BoolType instances are equal.
     */
    public operator func ==(_: BoolType): Bool {
        return true
    }

    private init() {
        super(TypeKind.`Bool`)
        setHashCode()
    }
}

/**
 * @brief Represents a C pointer type in the type system.
 *
 * This type represents a pointer to a C type, used for interoperability with C code.
 * The class maintains a cache of all CPointer types to ensure uniqueness.
 */
public class CPointerType <: BuiltinType & Equatable<CPointerType> {
    //                          elementType -> CPointerType
    private static var CACHE = HashMap<Type, CPointerType>()

    /**
     * @brief Gets or creates a CPointerType for the given element type.
     *
     * This method ensures that only one CPointerType instance exists for each element type.
     * @param elementType The type that the pointer points to.
     * @return The CPointerType instance for the given element type.
     */
    public static func get(elementType: Type): CPointerType {
        if (let Some(cPointer) <- CACHE.get(elementType)) {
            return cPointer
        }
        let newCPointerType = CPointerType(elementType)
        CACHE[elementType] = newCPointerType
        return newCPointerType
    }

    /**
     * @brief Converts this CPointerType to its string representation.
     * @return A string representation of the CPointerType (CPointer<elementType>).
     */
    public func toString(): String {
        return "CPointer<" + elementType.toString() + ">"
    }

    /**
     * @brief Gets the element type that this CPointerType points to.
     * @return The element type.
     */
    public prop elementType: Type {
        get() {
            return _typeArgs[0]
        }
    }

    /**
     * @brief Checks if this CPointerType is equal to another CPointerType.
     * @param other The CPointerType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: CPointerType): Bool {
        return this._typeArgs[0] == other._typeArgs[0]
    }

    private init(elementType: Type) {
        super(TypeKind.CPointer, ArrayList<Type>([elementType]))
        setHashCode()
    }
}

/**
 * @brief Represents the C string type in the type system.
 *
 * This type represents a C-style null-terminated string, used for interoperability with C code.
 * This is a singleton type representing the built-in C string type.
 */
public class CStringType <: BuiltinType & Equatable<CStringType> {
    private static let C_STRING_TYPE = CStringType()

    /**
     * @brief Gets the singleton instance of CStringType.
     * @return The CStringType instance.
     */
    public static func get(): CStringType {
        return C_STRING_TYPE
    }

    /**
     * @brief Checks if this CStringType is equal to another CStringType.
     * @param _ The other CStringType to compare with (unused, always returns true).
     * @return Always returns true since all CStringType instances are equal.
     */
    public operator func ==(_: CStringType): Bool {
        return true
    }

    private init() {
        super(TypeKind.CString)
        setHashCode()
    }
}

/**
 * @brief Represents the nothing type in the type system.
 *
 * This type represents the bottom type, used for expressions that never return.
 */
public class NothingType <: BuiltinType & Equatable<NothingType> {
    private static let NOTHING_TYPE = NothingType()

    /**
     * @brief Gets the singleton instance of NothingType.
     * @return The NothingType instance.
     */
    public static func get(): NothingType {
        return NOTHING_TYPE
    }

    /**
     * @brief Checks if this NothingType is equal to another NothingType.
     * @param _ The other NothingType to compare with (unused, always returns true).
     * @return Always returns true since all NothingType instances are equal.
     */
    public operator func ==(_: NothingType): Bool {
        return true
    }

    private init() {
        super(TypeKind.`Nothing`)
        setHashCode()
    }
}

/**
 * @brief Abstract base class for numeric types.
 *
 * This class represents types that are numeric, including both
 * integer and floating-point types.
 */
sealed abstract class NumericType <: BuiltinType & Equatable<NumericType> {
    /**
     * @brief Checks if this numeric type is equal to another numeric type.
     * @param other The numeric type to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: NumericType): Bool {
        return this._kind == other._kind
    }

    internal init(kind: TypeKind) {
        super(kind)
    }
}

/**
 * @brief Represents floating-point types in the type system.
 *
 * This class represents the three floating-point types: Float16, Float32, and Float64.
 */
public class FloatType <: NumericType & Equatable<FloatType> {
    private static let FLOAT16_TYPE = FloatType(TypeKind.`Float16`)
    private static let FLOAT32_TYPE = FloatType(TypeKind.`Float32`)
    private static let FLOAT64_TYPE = FloatType(TypeKind.`Float64`)

    /**
     * @brief Gets the Float16 type instance.
     * @return The Float16 type.
     */
    public static func getFloat16(): FloatType {
        return FLOAT16_TYPE
    }

    /**
     * @brief Gets the Float32 type instance.
     * @return The Float32 type.
     */
    public static func getFloat32(): FloatType {
        return FLOAT32_TYPE
    }

    /**
     * @brief Gets the Float64 type instance.
     * @return The Float64 type.
     */
    public static func getFloat64(): FloatType {
        return FLOAT64_TYPE
    }

    /**
     * @brief Checks if this FloatType is equal to another FloatType.
     * @param other The FloatType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: FloatType): Bool {
        return other._kind == this._kind
    }

    private init(kind: TypeKind) {
        super(kind)
        setHashCode()
    }
}

/**
 * @brief Represents integer types in the type system.
 *
 * This class represents both signed and unsigned integer types of various sizes.
 */
public class IntType <: NumericType & Equatable<IntType> {
    private static let INT8_TYPE = IntType(TypeKind.`Int8`)
    private static let INT16_TYPE = IntType(TypeKind.`Int16`)
    private static let INT32_TYPE = IntType(TypeKind.`Int32`)
    private static let INT64_TYPE = IntType(TypeKind.`Int64`)
    private static let INT_NATIVE_TYPE = IntType(TypeKind.`IntNative`)
    private static let UINT8_TYPE = IntType(TypeKind.`UInt8`)
    private static let UINT16_TYPE = IntType(TypeKind.`UInt16`)
    private static let UINT32_TYPE = IntType(TypeKind.`UInt32`)
    private static let UINT64_TYPE = IntType(TypeKind.`UInt64`)
    private static let UINT_NATIVE_TYPE = IntType(TypeKind.`UIntNative`)

    /**
     * @brief Gets the Int8 type instance.
     * @return The Int8 type.
     */
    public static func getInt8(): IntType {
        return INT8_TYPE
    }

    /**
     * @brief Gets the Int16 type instance.
     * @return The Int16 type.
     */
    public static func getInt16(): IntType {
        return INT16_TYPE
    }

    /**
     * @brief Gets the Int32 type instance.
     * @return The Int32 type.
     */
    public static func getInt32(): IntType {
        return INT32_TYPE
    }

    /**
     * @brief Gets the Int64 type instance.
     * @return The Int64 type.
     */
    public static func getInt64(): IntType {
        return INT64_TYPE
    }

    /**
     * @brief Gets the IntNative type instance.
     * @return The IntNative type.
     */
    public static func getIntNative(): IntType {
        return INT_NATIVE_TYPE
    }

    /**
     * @brief Gets the UInt8 type instance.
     * @return The UInt8 type.
     */
    public static func getUInt8(): IntType {
        return UINT8_TYPE
    }

    /**
     * @brief Gets the UInt16 type instance.
     * @return The UInt16 type.
     */
    public static func getUInt16(): IntType {
        return UINT16_TYPE
    }

    /**
     * @brief Gets the UInt32 type instance.
     * @return The UInt32 type.
     */
    public static func getUInt32(): IntType {
        return UINT32_TYPE
    }

    /**
     * @brief Gets the UInt64 type instance.
     * @return The UInt64 type.
     */
    public static func getUInt64(): IntType {
        return UINT64_TYPE
    }

    /**
     * @brief Gets the UIntNative type instance.
     * @return The UIntNative type.
     */
    public static func getUIntNative(): IntType {
        return UINT_NATIVE_TYPE
    }

    /**
     * @brief Checks if this IntType is equal to another IntType.
     * @param other The IntType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: IntType): Bool {
        return this._kind == other._kind
    }

    /**
     * @brief Checks if this integer type is signed.
     * @return true if the type is signed, false if it is unsigned.
     */
    public func isSigned(): Bool {
        return isSignedIntType()
    }

    private init(kind: TypeKind) {
        super(kind)
        setHashCode()
    }
}

/**
 * @brief Represents the rune type in the type system.
 *
 * This type represents a character type.
 */
public class RuneType <: BuiltinType & Equatable<RuneType> {
    private static let RUNE_TYPE = RuneType()

    /**
     * @brief Gets the singleton instance of RuneType.
     * @return The RuneType instance.
     */
    public static func get(): RuneType {
        return RUNE_TYPE
    }

    /**
     * @brief Checks if this RuneType is equal to another RuneType.
     * @param _ The other RuneType to compare with (unused, always returns true).
     * @return Always returns true since all RuneType instances are equal.
     */
    public operator func ==(_: RuneType): Bool {
        return true
    }

    private init() {
        super(TypeKind.`Rune`)
        setHashCode()
    }
}

/**
 * @brief Represents the unit type in the type system.
 *
 * This type represents the absence of a meaningful value, similar to void in C.
 */
public class UnitType <: BuiltinType & Equatable<UnitType> {
    private static let UNIT_TYPE = UnitType()

    /**
     * @brief Gets the singleton instance of UnitType.
     * @return The UnitType instance.
     */
    public static func get(): UnitType {
        return UNIT_TYPE
    }

    /**
     * @brief Checks if this UnitType is equal to another UnitType.
     * @param _ The other UnitType to compare with (unused, always returns true).
     * @return Always returns true since all UnitType instances are equal.
     */
    public operator func ==(_: UnitType): Bool {
        return true
    }

    private init() {
        super(TypeKind.`Unit`)
        setHashCode()
    }
}

internal class InvalidType <: Type & Equatable<InvalidType> {
    private static let INVALID_TYPE = InvalidType()

    public static func get(): InvalidType {
        return INVALID_TYPE
    }

    private init() {
        super(TypeKind.Invalid)
    }

    public operator func ==(_: InvalidType): Bool {
        return true
    }
}

/**
 * @brief Represents a reference type in the type system.
 *
 * This type wraps another type to represent a reference to that type.
 * The class maintains a cache of all reference types to ensure uniqueness.
 */
public class RefType <: Type & Equatable<RefType> {
    //                             baseType -> RefType
    private static var CACHE = HashMap<Type, RefType>()

    /**
     * @brief Gets or creates a RefType for the given base type.
     *
     * This method ensures that only one RefType instance exists for each base type.
     * @param baseType The base type to create a reference to.
     * @return The RefType instance for the given base type.
     */
    public static func get(baseType: Type): RefType {
        if (let Some(refType) <- CACHE.get(baseType)) {
            return refType
        }
        let newRefType = RefType(baseType)
        CACHE[baseType] = newRefType
        return newRefType
    }

    /**
     * @brief Gets the base type that this reference type refers to.
     * @return The base type.
     */
    public prop baseType: Type {
        get() {
            return _typeArgs[0]
        }
    }

    /**
     * @brief Converts this RefType to its string representation.
     * @return A string representation of the reference type (base type followed by '&').
     */
    public func toString(): String {
        return baseType.toString() + "&"
    }

    /**
     * @brief Checks if this RefType is equal to another RefType.
     * @param other The RefType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: RefType): Bool {
        return this._typeArgs[0] == other._typeArgs[0]
    }

    private init(baseType: Type) {
        super(TypeKind.Ref, ArrayList<Type>([baseType]))
        setHashCode()
    }
}
