/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

import std.collection.*
import std.deriving.*
import std.sort.*

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
            case Invalid =>       0
            case `Int8` =>        1
            case `Int16` =>       2
            case `Int32` =>       3
            case `Int64` =>       4
            case `IntNative` =>   5
            case `UInt8` =>       6
            case `UInt16` =>      7
            case `UInt32` =>      8
            case `UInt64` =>      9
            case `UIntNative` => 10
            case `Float16` =>    11
            case `Float32` =>    12
            case `Float64` =>    13
            case `Bool` =>       14
            case `Rune` =>       15
            case `Unit` =>       16
            case `Nothing` =>    17
            case CPointer =>     18
            case CString =>      19
            case Class =>        20
            case Enum =>         21
            case Struct =>       22
            case Tuple =>        23
            case RawArray =>     24
            case `VArray` =>     25
            case Generic =>      26
            case Ref =>          27
            case Box =>          28
            case `This` =>       29
            case Func =>         30
        }
    }

    /**
     * @brief Checks if this type kind is a C type.
     * @return true if the type kind is a C type, false otherwise.
     */
    internal func isCType(): Bool {
        match (this) {
            case `Int8` | `Int16` | `Int32` | `Int64` | `IntNative` |
                `UInt8` | `UInt16` | `UInt32` | `UInt64` | `UIntNative` |
                `Float16` | `Float32` | `Float64` |
                `Bool` | `Rune` | `Unit` | CPointer | CString => true
            case _ => false
        }
    }
    /**
     * @brief Converts the type kind to its string representation.
     * @return A string representation of the type kind.
     */
    public func toString(): String {
        match (this) {
            case Invalid =>      "Invalid"
            case `Int8` =>       "Int8"
            case `Int16` =>      "Int16"
            case `Int32` =>      "Int32"
            case `Int64` =>      "Int64"
            case `IntNative` =>  "IntNative"
            case `UInt8` =>      "UInt8"
            case `UInt16` =>     "UInt16"
            case `UInt32` =>     "UInt32"
            case `UInt64` =>     "UInt64"
            case `UIntNative` => "UIntNative"
            case `Float16` =>    "Float16"
            case `Float32` =>    "Float32"
            case `Float64` =>    "Float64"
            case `Bool` =>       "Bool"
            case `Rune` =>       "Rune"
            case `Unit` =>       "Unit"
            case `Nothing` =>    "Nothing"
            case Class =>        "Class"
            case Enum =>         "Enum"
            case Struct =>       "Struct"
            case Tuple =>        "Tuple"
            case CPointer =>     "CPointer"
            case CString =>      "CString"
            case RawArray =>     "RawArray"
            case `VArray` =>     "VArray"
            case Generic =>      "Generic"
            case Ref =>          "Ref"
            case Box =>          "Box"
            case `This` =>       "This"
            case Func =>         "Func"
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

    /**
     * @brief Gets the qualified name of this type.
     * @return A string representation of the qualified name.
     */
    public prop qualifiedName: String {
        get() {
            match (this) {
                case t: RawArrayType =>
                    return "RawArray<" + t.elementType.qualifiedName + ">"
                case t: RefType =>
                    return t.baseType.qualifiedName
                case t: VArrayType =>
                    return "VArray<" + t.elementType.qualifiedName + "," + t.size.toString() + ">"
                case t: CPointerType =>
                    return "CPointer<" + t.elementType.qualifiedName + ">"
                case t: TupleType =>
                    let elementTypeStr = String.join(t.elementTypes.map({ ty => ty.qualifiedName }).toArray(), delimiter: ",")
                    return "Tuple<" + elementTypeStr + ">"
                case t: CustomType =>
                    return qualifiedNameOfCustomType(t)
                case t: FuncType =>
                    let paramTypeStr = String.join(t.paramTypes.map({ ty => ty.qualifiedName }).toArray(), delimiter: ",")
                    let retType = t.returnType.qualifiedName
                    return "(" + paramTypeStr + ")->" + retType
                case t: GenericType =>
                    return t.srcCodeIdentifier
                case t: BoxType =>
                    return "Box<" + t.baseType.qualifiedName + ">"
                case _ =>
                    return toString()
            }
        }
    }

    /**
     * @brief Checks if this type is a builtin type.
     * @return true if the type is a builtin type, false otherwise.
     */
    public func isBuiltinType(): Bool {
        return _kind == TypeKind.`Int8` || _kind == TypeKind.`Int16` || _kind == TypeKind.`Int32` || _kind == TypeKind.`Int64` ||
            _kind == TypeKind.`IntNative` || _kind == TypeKind.`UInt8` || _kind == TypeKind.`UInt16` || _kind == TypeKind.`UInt32` ||
            _kind == TypeKind.`UInt64` || _kind == TypeKind.`UIntNative` || _kind == TypeKind.`Float16` || _kind == TypeKind.`Float32` ||
            _kind == TypeKind.`Float64` || _kind == TypeKind.`Bool` || _kind == TypeKind.`Rune` || _kind == TypeKind.`Unit` ||
            _kind == TypeKind.`Nothing` || _kind == TypeKind.RawArray || _kind == TypeKind.`VArray` || _kind == TypeKind.CPointer ||
            _kind == TypeKind.CString
    }

    /**
     * @brief Checks if this type is a custom type (class, enum, or struct).
     * @return true if the type is a custom type, false otherwise.
     */
    public func isCustomType(): Bool {
        return isClassType() || isEnumType() || isStructType()
    }

    /**
     * @brief Checks if this type is a class type.
     * @return true if the type is a class type, false otherwise.
     */
    public func isClassType(): Bool {
        return _kind == TypeKind.Class
    }

    /**
     * @brief Checks if this type is an enum type.
     * @return true if the type is an enum type, false otherwise.
     */
    public func isEnumType(): Bool {
        return _kind == TypeKind.Enum
    }

    /**
     * @brief Checks if this type is a struct type.
     * @return true if the type is a struct type, false otherwise.
     */
    public func isStructType(): Bool {
        return _kind == TypeKind.Struct
    }

    /**
     * @brief Checks if this type is a tuple type.
     * @return true if the type is a tuple type, false otherwise.
     */
    public func isTupleType(): Bool {
        return _kind == TypeKind.Tuple
    }

    /**
     * @brief Checks if this type is a C pointer type.
     * @return true if the type is a C pointer type, false otherwise.
     */
    public func isCPointerType(): Bool {
        return _kind == TypeKind.CPointer
    }

    /**
     * @brief Checks if this type is a C string type.
     * @return true if the type is a C string type, false otherwise.
     */
    public func isCStringType(): Bool {
        return _kind == TypeKind.CString
    }

    /**
     * @brief Checks if this type is a raw array type.
     * @return true if the type is a raw array type, false otherwise.
     */
    public func isRawArrayType(): Bool {
        return _kind == TypeKind.RawArray
    }

    /**
     * @brief Checks if this type is a VArray type.
     * @return true if the type is a VArray type, false otherwise.
     */
    public func isVArrayType(): Bool {
        return _kind == TypeKind.`VArray`
    }

    /**
     * @brief Checks if this type is a generic type.
     * @return true if the type is a generic type, false otherwise.
     */
    public func isGenericType(): Bool {
        return _kind == TypeKind.Generic
    }

    /**
     * @brief Checks if this type is a box type.
     * @return true if the type is a box type, false otherwise.
     */
    public func isBoxType(): Bool {
        return _kind == TypeKind.Box
    }

    /**
     * @brief Checks if this type is a This type.
     * @return true if the type is a This type, false otherwise.
     */
    public func isThisType(): Bool {
        return _kind == TypeKind.`This`
    }

    /**
     * @brief Checks if this type is a function type.
     * @return true if the type is a function type, false otherwise.
     */
    public func isFuncType(): Bool {
        return _kind == TypeKind.Func
    }

    /**
     * @brief Checks if this type is a C function type.
     * @return true if the type is a C function type, false otherwise.
     */
    public func isCFuncType(): Bool {
        if (!isFuncType()) {
            return false
        }
        return (this as FuncType).getOrThrow().isCFunc
    }

    internal func isClosureType(): Bool {
        if (_kind != TypeKind.Class) {
            return false
        }
        return ((this as ClassType).getOrThrow().classDef.getAnno<IsAutoEnvClass>() as Bool).getOrThrow()
    }

    internal func isClosureBaseType(): Bool {
        if (!isClosureType()) {
            return false
        }
        return (this as ClassType).getOrThrow().classDef.isAbstract()
    }

    internal func isClosureGenericBaseType(): Bool {
        return isClosureBaseType() && !typeArgs.isEmpty()
    }

    internal func isClosureInstBaseType(): Bool {
        return isClosureBaseType() && typeArgs.isEmpty()
    }

    internal func isAnyTypeInStd(): Bool {
        if (_kind != TypeKind.Class) {
            return false
        }
        return (this as ClassType).getOrThrow().classDef.defIsExpected(CORE_PACKAGE_NAME, ANY_NAME_IN_STD)
    }

    internal func isCTypeInStd(): Bool {
        if (_kind != TypeKind.Class) {
            return false
        }
        return (this as ClassType).getOrThrow().classDef.defIsExpected(CORE_PACKAGE_NAME, CTYPE_NAME_IN_STD)
    }

    internal func isValueType(): Bool {
        return isPrimitiveType() || isEnumType() || isTupleType() ||
            isStructType() || isVArrayType() || isCPointerType() ||
            isCStringType() || isFuncType()
    }

    internal func isReferenceType(): Bool {
        return isClassType() || isRawArrayType() || isBoxType() || isThisType()
    }

    internal func isGenericRelated(): Bool {
        if (isGenericType()) {
            return true
        }
        for (arg in _typeArgs) {
            if (arg.isGenericRelated()) {
                return true
            }
        }
        return false
    }

    internal func isEqualOrInstantiatedTypeOf(genericRelatedType: Type, visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Bool {
        if (this == genericRelatedType) {
            return true
        }
        let (success, instMap) = genericRelatedType.calculateGeneric2InstTypeMap(this)
        if (!success) {
            return false
        }
        for ((genericType, instType) in instMap) {
            if (!instType.satisfyGenericConstraints(genericType, instMap, visited: visited)) {
                return false
            }
        }
        return true
    }

    internal func calculateGeneric2InstTypeMap(instType: Type): (Bool, HashMap<GenericType, Type>) {
        var result: HashMap<GenericType, Type> = HashMap<GenericType, Type>()
        if (!calculateGeneric2InstTypeMapImpl(instType, result)) {
            return (false, HashMap<GenericType, Type>())
        }
        return (true, result)
    }

    internal func satisfyGenericConstraints(gType: GenericType, instMap: HashMap<GenericType, Type>, visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Bool {
        for (upperBound in gType.upperBounds) {
            let instType = getInstType(upperBound, instMap)
            if (!this.isEqualOrSubTypeOf(instType, visited: visited)) {
                return false
            }
        }
        return true
    }

    internal func isEqualOrSubTypeOf(parent: Type, visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Bool {
        if (this == parent) {
            return true
        }
        /**
         *  there may be an unresolvable inheritance relationship:
         *  interface I<T> {}
         *  abstract class C<T> {}
         *  extend<T> C<T> <: I<T> where T <: I<T> {}
         *  class D <: C<D> {}
         *  main() {0}
         *
         *  if you want to know if class D is sub type of I<D>, that will be a disaster, because
         *  parent type of class D is C<D>, and in `extend<T> C<T> <: I<T>`, interface I is class C's parent type,
         *  so you only need to know if `C<D> <: I<D>` satisfy generic constraints which `T <: I<T>`, then you need to
         *  compute if the `T` can be class D, that means you have to know if class D is sub type of I<D>, tail bites head.
         *  so we need to check if the sub type and parent type have been visited, if visited, we don't think they have a
         *  parent-child relationship and Sema does the same
         */
        for (i in visited) {
            if (i == (this, parent)) {
                return false
            }
        }
        visited.add((this, parent))
        if (this.isRefType() && parent.isRefType()) {
            let subBaseType = (this as RefType).getOrThrow().baseType
            let parentBaseType = (parent as RefType).getOrThrow().baseType
            return subBaseType.isEqualOrSubTypeOf(parentBaseType, visited: visited)
        }
        let subDeref = this.stripAllRefs()
        let parentDeref = parent.stripAllRefs()
        // we can't think class-A and class-A& is equal
        if ((this.isRefType() || parent.isRefType()) && subDeref == parentDeref) {
            return false
        }
        // Nothing type is all types' sub type, Any type is all types' parent type
        if (subDeref.isNothingType() || parentDeref.isAnyTypeInStd()) {
            return true
        }
        // if parent type is generic type, that means it can be any type, even if it has upper bounds
        if (subDeref.isGenericType()) {
            return false
        }
        if (parentDeref.isCTypeInStd()) {
            return this.satisfyCType()
        }
        if (subDeref.isGenericType()) {
            for (upperBound in (subDeref as GenericType).getOrThrow().upperBounds) {
                if (!upperBound.stripAllRefs().isEqualOrSubTypeOf(parentDeref, visited: visited)) {
                    return false
                }
            }
            return true
        }
        if (subDeref.isTupleType()) {
            if (!parentDeref.isTupleType()) {
                return false
            }
            return tupleTypeIsEqualOrSubTypeOf((subDeref as TupleType).getOrThrow(), (parentDeref as TupleType).getOrThrow(), visited)
        }
        if (subDeref.isFuncType()) {
            if (!parentDeref.isFuncType()) {
                return false
            }
            return funcTypeIsEqualOrSubTypeOf((subDeref as FuncType).getOrThrow(), (parentDeref as FuncType).getOrThrow(), visited)
        }
        if (subDeref.isClosureType()) {
            if (!parentDeref.isClosureType()) {
                return false
            }
            return closureTypeIsEqualOrSubTypeOf((subDeref as ClassType).getOrThrow(), (parentDeref as ClassType).getOrThrow(), visited)
        }
        var allParentTypes = Array<ClassType>()
        if (let bt <- (this as BuiltinType) && bt.isSome()) {
            allParentTypes = bt.getOrThrow().getSuperTypesRecusively(visited: visited)
        } else if (let ct <- (this as CustomType) && ct.isSome()) {
            allParentTypes = ct.getOrThrow().getSuperTypesRecusively(visited: visited)
        }
        for (parentType in allParentTypes) {
            if (parentDeref == parentType) {
                return true
            }
        }
        return false
    }

    internal func satisfyCType(): Bool {
        if (_kind.isCType()) {
            return true
        }
        if (let s <- (this as StructType) && s.isSome()) {
            return s.getOrThrow().structDef.isCStruct
        }
        if (let va <- (this as VArrayType) && va.isSome()) {
            return va.getOrThrow().elementType.satisfyCType()
        }
        if (this.isCFuncType()) {
            return true
        }
        return false
    }

    internal func isBoxRefTypeOf(other: Type): Bool {
        if (!this.isRefType()) {
            return false
        }
        let boxType = (this as RefType).getOrThrow().baseType
        if (!boxType.isBoxType()) {
            return false
        }
        let baseType = (boxType as BoxType).getOrThrow().baseType
        return baseType == other
    }

    private func calculateGeneric2InstTypeMapImpl(instType: Type, result: HashMap<GenericType, Type>): Bool {
        if (this == instType) {
            return true
        }
        if (this.isGenericType()) {
            let genericType = (this as GenericType).getOrThrow()
            if (let r <- result.get(genericType) && r.isSome()) {
                return r.getOrThrow() == instType
            } else {
                result.add(genericType, instType)
                return true
            }
        }
        if (!this.hasSameTypeKindWith(instType)) {
            return false
        }
        if (this.isCustomType()) {
            let thisCustomType = (this as CustomType).getOrThrow()
            let instCustomType = (instType as CustomType).getOrThrow()
            if (thisCustomType.def != instCustomType.def) {
                return false
            }
        }
        let thisTypeArgs = this.typeArgs
        let instTypeArgs = instType.typeArgs
        if (thisTypeArgs.size != instTypeArgs.size) {
            return false
        }
        for (i in 0..thisTypeArgs.size) {
            if (!thisTypeArgs[i].calculateGeneric2InstTypeMapImpl(instTypeArgs[i], result)) {
                return false
            }
        }
        return true
    }

    private func qualifiedNameOfCustomType(t: CustomType): String {
        let packageName = t.def.packageName.replace("::", "/")
        let defName = t.def.srcCodeIdentifier
        if (defName.isEmpty()) {
            return packageName + ":" + t.def.identifierWithoutPrefix
        }
        return packageName + ":" + defName
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

sealed abstract class BuiltinType <: Type & Equatable<BuiltinType> {
    internal let _extends = ArrayList<ExtendDef>()

    public operator func ==(other: BuiltinType): Bool {
        return hasSameTypeKindAndArgs(other)
    }

    internal func getSuperTypesRecusively(visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassType> {
        var result: ArrayList<ClassType> = ArrayList<ClassType>()
        for (exDef in getExtendDefs()) {
            for (p in exDef.implementedInterfaceTypes) {
                getAllInstantiatedParentTypes(p, result, visited: visited)
            }
        }
        return result.toArray()
    }

    protected open func getExtendDefs(): Array<ExtendDef> {
        return _extends.toArray()
    }

    internal func addExtend(extendDef: ExtendDef): Unit {
        _extends.add(extendDef)
    }

    internal init(kind: TypeKind) {
        super(kind)
    }

    internal init(kind: TypeKind, typeArgs: ArrayList<Type>) {
        super(kind, typeArgs)
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
        return hasSameTypeKindAndArgs(other)
    }

    protected override func getExtendDefs(): Array<ExtendDef> {
        var result: ArrayList<ExtendDef> = ArrayList<ExtendDef>()
        for ((_, cpType) in CACHE) {
            if (this.isEqualOrInstantiatedTypeOf(cpType)) {
                result.add(all: cpType._extends)
            }
        }
        return result.toArray()
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

/**
 * @brief Represents a box type in the type system.
 *
 * This type wraps another type in a box, used for heap allocation.
 * The class maintains a cache of all box types to ensure uniqueness.
 */
public class BoxType <: Type & Equatable<BoxType> {
    private static var ALL_BOX_TYPES = HashMap<BoxType, BoxType>()

    /**
     * @brief Gets or creates a BoxType for the given base type.
     *
     * This method ensures that only one BoxType instance exists for each base type.
     * @param baseType The base type to create a box for.
     * @return The BoxType instance for the given base type.
     */
    public static func get(baseType: Type): BoxType {
        let temp = BoxType(baseType)
        let res = ALL_BOX_TYPES.get(temp)
        if (res.isNone()) {
            ALL_BOX_TYPES.add(temp, temp)
            return temp
        }
        return res.getOrThrow()
    }

    /**
     * @brief Converts this BoxType to its string representation.
     * @return A string representation of the box type (Box<baseType>).
     */
    public func toString(): String {
        return "Box<" + baseType.toString() + ">"
    }

    /**
     * @brief Gets the base type that this box type wraps.
     * @return The base type.
     */
    public prop baseType: Type {
        get() {
            return _typeArgs[0]
        }
    }

    /**
     * @brief Checks if this BoxType is equal to another BoxType.
     * @param other The BoxType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: BoxType): Bool {
        return hasSameTypeKindAndArgs(other)
    }

    private init(baseType: Type) {
        super(TypeKind.Box, ArrayList<Type>([baseType]))
        setHashCode()
    }
}

/**
 * @brief Represents a raw array type in the type system.
 *
 * This type represents a multi-dimensional raw array with a specified number of dimensions.
 * The class maintains a cache of all raw array types to ensure uniqueness.
 */
public class RawArrayType <: BuiltinType & Equatable<RawArrayType> {
    internal let _dims: UInt32
    private static var ALL_RAW_ARRAY_TYPES = HashMap<RawArrayType, RawArrayType>()

    /**
     * @brief Gets or creates a RawArrayType for the given element type and dimensions.
     *
     * This method ensures that only one RawArrayType instance exists for each element type and dimension combination.
     * @param elementType The element type of the array.
     * @param dims The number of dimensions.
     * @return The RawArrayType instance.
     */
    public static func get(elementType: Type, dims: UInt32): RawArrayType {
        let temp = RawArrayType(elementType, dims)
        let res = ALL_RAW_ARRAY_TYPES.get(temp)
        if (res.isNone()) {
            ALL_RAW_ARRAY_TYPES.add(temp, temp)
            return temp
        }
        return res.getOrThrow()
    }

    /**
     * @brief Converts this RawArrayType to its string representation.
     * @return A string representation of the raw array type.
     */
    public func toString(): String {
        var prefix = ""
        var suffix = ""
        for (i in 0..dims) {
            prefix += "RawArray<"
            suffix += ">"
        }
        return prefix + elementType.toString() + suffix
    }

    /**
     * @brief Checks if this RawArrayType is equal to another RawArrayType.
     * @param other The RawArrayType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: RawArrayType): Bool {
        return hasSameTypeKindAndArgs(other) && this._dims == other._dims
    }

    /**
     * @brief Gets the element type of this raw array.
     * @return The element type.
     */
    public prop elementType: Type {
        get() {
            return _typeArgs[0]
        }
    }

    /**
     * @brief Gets the number of dimensions of this raw array.
     * @return The number of dimensions.
     */
    public prop dims: UInt32 {
        get() {
            return _dims
        }
    }

    private init(elementType: Type, dims: UInt32) {
        super(TypeKind.RawArray, ArrayList<Type>([elementType]))
        this._dims = dims
        setHashCode()
    }
}

/**
 * @brief Represents a VArray type in the type system.
 *
 * This type represents a variable-length array with a fixed size at compile time.
 * The class maintains a cache of all VArray types to ensure uniqueness.
 */
public class VArrayType <: BuiltinType & Equatable<VArrayType> {
    internal let _size: Int64
    private static var ALL_VARRAY_TYPES = HashMap<VArrayType, VArrayType>()

    /**
     * @brief Gets or creates a VArrayType for the given element type and size.
     *
     * This method ensures that only one VArrayType instance exists for each element type and size combination.
     * @param elementType The element type of the array.
     * @param size The size of the array.
     * @return The VArrayType instance.
     */
    public static func get(elementType: Type, size: Int64): VArrayType {
        let temp = VArrayType(elementType, size)
        let res = ALL_VARRAY_TYPES.get(temp)
        if (res.isNone()) {
            ALL_VARRAY_TYPES.add(temp, temp)
            return temp
        }
        return res.getOrThrow()
    }

    /**
     * @brief Converts this VArrayType to its string representation.
     * @return A string representation of the VArray type (VArray<elementType, $size>).
     */
    public func toString(): String {
        return "VArray<" + elementType.toString() + ", $" + size.toString() + ">"
    }

    /**
     * @brief Gets the element type of this VArray.
     * @return The element type.
     */
    public prop elementType: Type {
        get() {
            return _typeArgs[0]
        }
    }

    /**
     * @brief Gets the size of this VArray.
     * @return The size.
     */
    public prop size: Int64 {
        get() {
            return _size
        }
    }

    /**
     * @brief Checks if this VArrayType is equal to another VArrayType.
     * @param other The VArrayType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: VArrayType): Bool {
        return hasSameTypeKindAndArgs(other) && this._size == other._size
    }

    private init(elementType: Type, size: Int64) {
        super(TypeKind.`VArray`, ArrayList<Type>([elementType]))
        this._size = size
        setHashCode()
    }
}

/**
 * @brief Abstract base class for custom types (class, enum, struct).
 *
 * This class represents user-defined types in the type system.
 */
sealed abstract class CustomType <: Type & Equatable<CustomType> {
    internal var _def: CustomTypeDef

    /**
     * @brief Checks if this CustomType is equal to another CustomType.
     * @param other The CustomType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: CustomType): Bool {
        return hasSameTypeKindAndArgs(other) && this._def == other._def
    }

    /**
     * @brief Gets the definition of this custom type.
     * @return The CustomTypeDef instance.
     */
    public prop def: CustomTypeDef {
        get() {
            return _def
        }
    }

    /**
     * @brief Gets the generic type arguments of this custom type.
     * @return An array of generic type arguments.
     */
    public prop genericTypeArgs: Array<Type> {
        get() {
            return _typeArgs.toArray()
        }
    }

    internal prop allMemberVarNames: Array<String> {
        get() {
            var result: ArrayList<String> = ArrayList<String>()
            if (isClassType()) {
                let classDef = (def as ClassDef).getOrThrow()
                if (classDef.superClass.isSome()) {
                    result = ArrayList<String>.of(classDef.superClass.getOrThrow().allMemberVarNames)
                }
            }
            for (memberVar in def.instanceVars) {
                result.add(memberVar.name)
            }
            return result.toArray()
        }
    }

    internal func getExtendImplementedInterfaceTypes(visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassType> {
        var result: ArrayList<ClassType> = ArrayList<ClassType>()
        for (exDef in getExtendDefs(visited: visited)) {
            let (success, instMap) = exDef.extendedType.calculateGeneric2InstTypeMap(this)
            assert(success, "Failed to calculate generic 2 inst type map")
            for (p in exDef.implementedInterfaceTypes) {
                let instType = (getInstType(p, instMap) as ClassType).getOrThrow()
                result.add(instType)
            }
        }
        return result.toArray()
    }

    internal func getImplementedInterfaceTypes(visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassType> {
        var result = ArrayList<ClassType>.of(this.getExtendImplementedInterfaceTypes(visited: visited))
        for (p in _def.implementedInterfaceTypes) {
            let instType = (getInstType(p, generic2InstTypeMap) as ClassType).getOrThrow()
            result.add(instType)
        }
        return result.toArray()
    }

    internal func getInstantiatedMemberVarTypes(): Array<Type> {
        var result: ArrayList<Type> = ArrayList<Type>()
        if (isClassType()) {
            let cType = (this as ClassType).getOrThrow()
            if (cType.hasSuperClassType()) {
                result = ArrayList<Type>.of(cType.getSuperClassType().getInstantiatedMemberVarTypes())
            }
        }
        for (memberVar in def.instanceVars) {
            result.add(getInstType(memberVar.ty, generic2InstTypeMap))
        }
        return result.toArray()
    }

    internal func getMemberVarInstantiatedType(name: String): Type {
        let memberVarInstTypes = getInstantiatedMemberVarTypes()
        let memberVarNames = allMemberVarNames
        assert(memberVarInstTypes.size == memberVarNames.size, "Member variable size mismatch")
        for (i in memberVarNames.size - 1..=0 : -1) {
            if (memberVarNames[i] == name) {
                return memberVarInstTypes[i]
            }
        }
        throw Exception("Member variable " + name + " not found in " + toString())
    }

    /**
     * @brief Converts this CustomType to its string representation.
     * @return A string representation of the custom type.
     */
    public func toString(): String {
        return this._kind.toString() + "-" +
            _def.identifierWithoutPrefix + typeVecToString("<", genericTypeArgs, ">")
    }

    internal func getSuperTypesRecusively(visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassType> {
        var result: ArrayList<ClassType> = ArrayList<ClassType>()
        for (p in this.getImplementedInterfaceTypes(visited: visited)) {
            getAllInstantiatedParentTypes(p, result, visited: visited)
        }
        if (let c <- (this as ClassType) && c.isSome() && c.getOrThrow().hasSuperClassType()) {
            getAllInstantiatedParentTypes(c.getOrThrow().getSuperClassType(), result, visited: visited)
        }
        return result.toArray()
    }

    internal func getExtendDefs(visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ExtendDef> {
        var result: ArrayList<ExtendDef> = ArrayList<ExtendDef>()
        for (exDef in def.extends) {
            if (this.isEqualOrInstantiatedTypeOf(exDef.extendedType, visited: visited)) {
                result.add(exDef)
            }
        }
        return result.toArray()
    }

    internal prop generic2InstTypeMap: HashMap<GenericType, Type> {
        get() {
            let genericTypeParams = def.genericTypeParams
            assert(genericTypeParams.size == genericTypeArgs.size, "Generic type params size mismatch")
            var replaceTable: HashMap<GenericType, Type> = HashMap<GenericType, Type>()
            for (i in 0..genericTypeParams.size) {
                let genericTypeParam = genericTypeParams[i]
                let genericTypeArg = genericTypeArgs[i]
                replaceTable.add(genericTypeParam, genericTypeArg)
            }
            return replaceTable
        }
    }

    internal init(kind: TypeKind, def: CustomTypeDef, genericTypeParams: ArrayList<Type>) {
        super(kind, genericTypeParams)
        this._def = def
    }
}

/**
 * @brief Represents a class type in the type system.
 *
 * This type represents a user-defined class with optional generic type parameters.
 * The class maintains a cache of all class types to ensure uniqueness.
 */
public class ClassType <: CustomType & Equatable<ClassType> {
    private static var ALL_CLASS_TYPES = HashMap<ClassType, ClassType>()

    /**
     * @brief Gets the ClassDef associated with this class type.
     * @return The ClassDef instance.
     */
    public prop classDef: ClassDef {
        get() {
            return (def as ClassDef).getOrThrow()
        }
    }

    /**
     * @brief Checks if this class type has a super class.
     * @return true if the class has a super class, false otherwise.
     */
    internal func hasSuperClassType(): Bool {
        return classDef.superClass.isSome()
    }

    /**
     * @brief Gets the super class type of this class.
     * @return The super class type.
     */
    internal func getSuperClassType(): ClassType {
        let res = getInstType(classDef.superClass.getOrThrow(), generic2InstTypeMap)
        return (res as ClassType).getOrThrow()
    }

    /**
     * @brief Checks if this ClassType is equal to another ClassType.
     * @param other The ClassType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: ClassType): Bool {
        return hasSameTypeKindAndArgs(other) && this._def == other._def
    }

    /**
     * @brief Gets or creates a ClassType for the given class definition and generic type parameters.
     *
     * This method ensures that only one ClassType instance exists for each class definition and generic type parameter combination.
     * @param def The class definition.
     * @param genericTypeParams The generic type parameters.
     * @return The ClassType instance.
     */
    public static func get(def: ClassDef, genericTypeParams: Array<Type>): ClassType {
        let temp = ClassType(def, ArrayList<Type>.of(genericTypeParams))
        let res = ALL_CLASS_TYPES.get(temp)
        if (res.isNone()) {
            ALL_CLASS_TYPES.add(temp, temp)
            return temp
        }
        return res.getOrThrow()
    }

    private init(def: ClassDef, genericTypeParams: ArrayList<Type>) {
        super(TypeKind.Class, def, genericTypeParams)
        setHashCode()
    }
}

/**
 * @brief Represents a struct type in the type system.
 *
 * This type represents a user-defined struct with optional generic type parameters.
 * The class maintains a cache of all struct types to ensure uniqueness.
 */
public class StructType <: CustomType & Equatable<StructType> {
    private static var ALL_STRUCT_TYPES = HashMap<StructType, StructType>()

    /**
     * @brief Gets or creates a StructType for the given struct definition and generic type parameters.
     *
     * This method ensures that only one StructType instance exists for each struct definition and generic type parameter combination.
     * @param def The struct definition.
     * @param genericTypeParams The generic type parameters.
     * @return The StructType instance.
     */
    public static func get(def: StructDef, genericTypeParams: Array<Type>): StructType {
        let temp = StructType(def, ArrayList<Type>.of(genericTypeParams))
        let res = ALL_STRUCT_TYPES.get(temp)
        if (res.isNone()) {
            ALL_STRUCT_TYPES.add(temp, temp)
            return temp
        }
        return res.getOrThrow()
    }

    /**
     * @brief Gets the StructDef associated with this struct type.
     * @return The StructDef instance.
     */
    public prop structDef: StructDef {
        get() {
            return (def as StructDef).getOrThrow()
        }
    }

    /**
     * @brief Checks if this StructType is equal to another StructType.
     * @param other The StructType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: StructType): Bool {
        return hasSameTypeKindAndArgs(other) && this._def == other._def
    }

    private init(def: StructDef, genericTypeParams: ArrayList<Type>) {
        super(TypeKind.Struct, def, genericTypeParams)
        setHashCode()
    }
}

/**
 * @brief Represents an enum type in the type system.
 *
 * This type represents a user-defined enum with optional generic type parameters.
 * The class maintains a cache of all enum types to ensure uniqueness.
 */
public class EnumType <: CustomType & Equatable<EnumType> {
    private static var ALL_ENUM_TYPES = HashMap<EnumType, EnumType>()

    /**
     * @brief Gets or creates an EnumType for the given enum definition and generic type parameters.
     *
     * This method ensures that only one EnumType instance exists for each enum definition and generic type parameter combination.
     * @param def The enum definition.
     * @param genericTypeParams The generic type parameters.
     * @return The EnumType instance.
     */
    public static func get(def: EnumDef, genericTypeParams: Array<Type>): EnumType {
        let temp = EnumType(def, ArrayList<Type>.of(genericTypeParams))
        let res = ALL_ENUM_TYPES.get(temp)
        if (res.isNone()) {
            ALL_ENUM_TYPES.add(temp, temp)
            return temp
        }
        return res.getOrThrow()
    }

    /**
     * @brief Gets the EnumDef associated with this enum type.
     * @return The EnumDef instance.
     */
    public prop enumDef: EnumDef {
        get() {
            return (def as EnumDef).getOrThrow()
        }
    }

    /**
     * @brief Checks if this EnumType is equal to another EnumType.
     * @param other The EnumType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: EnumType): Bool {
        return hasSameTypeKindAndArgs(other) && this._def == other._def
    }

    private init(def: EnumDef, genericTypeParams: ArrayList<Type>) {
        super(TypeKind.Enum, def, genericTypeParams)
        setHashCode()
    }
}

/**
 * @brief Represents a function type in the type system.
 *
 * This type represents a function signature with parameter types and return type.
 * The class maintains a cache of all function types to ensure uniqueness.
 */
public class FuncType <: Type & Equatable<FuncType> {
    private static var ALL_FUNC_TYPES = HashMap<FuncType, FuncType>()
    private let _hasVarArg: Bool
    private let _isCFunc: Bool

    /**
     * @brief Gets or creates a FuncType for the given parameter types and return type.
     *
     * This method ensures that only one FuncType instance exists for each function signature.
     * @param paramTypes The parameter types.
     * @param retType The return type.
     * @param varArg Whether the function has variable arguments (default: false).
     * @param cFunc Whether this is a C function (default: false).
     * @return The FuncType instance.
     */
    public static func get(paramTypes: Array<Type>, retType: Type, varArg!: Bool = false, cFunc!: Bool = false): FuncType {
        let temp = FuncType(ArrayList<Type>.of(paramTypes), retType, varArg, cFunc)
        let res = ALL_FUNC_TYPES.get(temp)
        if (res.isNone()) {
            ALL_FUNC_TYPES.add(temp, temp)
            return temp
        }
        return res.getOrThrow()
    }

    /**
     * @brief Checks if this function type has variable arguments.
     * @return true if the function has variable arguments, false otherwise.
     */
    public prop hasVarArg: Bool {
        get() {
            return _hasVarArg
        }
    }

    /**
     * @brief Checks if this is a C function type.
     * @return true if this is a C function, false otherwise.
     */
    public prop isCFunc: Bool {
        get() {
            return _isCFunc
        }
    }

    /**
     * @brief Gets the parameter types of this function.
     * @return An array of parameter types.
     */
    public prop paramTypes: Array<Type> {
        get() {
            return _typeArgs[0..(_typeArgs.size - 1)].toArray()
        }
    }

    /**
     * @brief Gets the return type of this function.
     * @return The return type.
     */
    public prop returnType: Type {
        get() {
            return _typeArgs.last.getOrThrow()
        }
    }

    /**
     * @brief Converts this FuncType to its string representation.
     * @return A string representation of the function type.
     */
    public func toString(): String {
        let suffix = if (_hasVarArg) {
            "...)"
        } else {
            ")"
        }
        var paramTypesStr = typeVecToString("(", paramTypes, suffix)
        if (paramTypesStr.isEmpty()) {
            paramTypesStr = "()"
        }
        let str = paramTypesStr + " -> " + returnType.toString()
        return if (_isCFunc) {
            "CFunc<" + str + ">"
        } else {
            str
        }
    }

    /**
     * @brief Checks if this FuncType is equal to another FuncType.
     * @param other The FuncType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: FuncType): Bool {
        return hasSameTypeKindAndArgs(other) &&
            this._hasVarArg == other._hasVarArg &&
            this._isCFunc == other._isCFunc
    }

    private init(paramTypes: ArrayList<Type>, retType: Type, varArg: Bool, cFunc: Bool) {
        super(TypeKind.Func, paramTypes)
        this._hasVarArg = varArg
        this._isCFunc = cFunc
        _typeArgs.add(retType)
        setHashCode()
    }
}