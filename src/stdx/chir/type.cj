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
                    return t.srcCodeName
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
        return (this as ClassLikeType).getOrThrow().classLikeDef.getAnno<IsAutoEnvClass, Bool>()
    }

    internal func isClosureBaseType(): Bool {
        if (!isClosureType()) {
            return false
        }
        return (this as ClassLikeType).getOrThrow().classLikeDef.isAbstract()
    }

    internal func isClosureGenericBaseType(): Bool {
        return isClosureBaseType() && !typeArgs.isEmpty()
    }

    internal func isClosureInstBaseType(): Bool {
        return isClosureBaseType() && typeArgs.isEmpty()
    }

    public func isAnyTypeInStd(): Bool {
        if (_kind != TypeKind.Class) {
            return false
        }
        return (this as ClassLikeType).getOrThrow().classLikeDef.defIsExpected(CORE_PACKAGE_NAME, ANY_NAME_IN_STD)
    }

    public func isCTypeInStd(): Bool {
        if (_kind != TypeKind.Class) {
            return false
        }
        return (this as ClassLikeType).getOrThrow().classLikeDef.defIsExpected(CORE_PACKAGE_NAME, CTYPE_NAME_IN_STD)
    }

    public func isValueType(): Bool {
        return isPrimitiveType() || isEnumType() || isTupleType() ||
            isStructType() || isVArrayType() || isCPointerType() ||
            isCStringType() || isFuncType()
    }

    public func isReferenceType(): Bool {
        return isClassType() || isRawArrayType() || isBoxType() || isThisType()
    }

    public func isGenericRelated(): Bool {
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

    public func isEqualOrInstantiatedTypeOf(genericRelatedType: Type, visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Bool {
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

    public func satisfyGenericConstraints(gType: GenericType, instMap: HashMap<GenericType, Type>, visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Bool {
        for (upperBound in gType.upperBounds) {
            let instType = getInstType(upperBound, instMap)
            if (!this.isEqualOrSubTypeOf(instType, visited: visited)) {
                return false
            }
        }
        return true
    }

    public func isEqualOrSubTypeOf(parent: Type, visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Bool {
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
        if (parentDeref.isGenericType()) {
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
            return closureTypeIsEqualOrSubTypeOf((subDeref as ClassLikeType).getOrThrow(), (parentDeref as ClassLikeType).getOrThrow(), visited)
        }
        var allParentTypes = Array<ClassLikeType>()
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

    public func satisfyCType(): Bool {
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

    public func isBoxRefTypeOf(other: Type): Bool {
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
        let defName = t.def.srcCodeName
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

    public func getSuperTypesRecusively(visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType> {
        var result: ArrayList<ClassLikeType> = ArrayList<ClassLikeType>()
        for (exDef in getExtendDefs()) {
            for (p in exDef.implementedInterfaceTypes) {
                getAllInstantiatedParentTypes(p, result, visited)
            }
        }
        return result.toArray()
    }

    protected open func getExtendDefs(): Array<ExtendDef> {
        return _extends.toArray()
    }

    public func addExtend(extendDef: ExtendDef): Unit {
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
        let result = StringBuilder()
        result.append("CPointer<")
        result.append(elementType.toString())
        result.append(">")
        return result.toString()
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
        let result = StringBuilder()
        result.append(baseType.toString())
        result.append("&")
        return result.toString()
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
    //                             baseType -> BoxType
    private static var CACHE = HashMap<Type, BoxType>()

    /**
     * @brief Gets or creates a BoxType for the given base type.
     *
     * This method ensures that only one BoxType instance exists for each base type.
     * @param baseType The base type to create a box for.
     * @return The BoxType instance for the given base type.
     */
    public static func get(baseType: Type): BoxType {
        if (let Some(boxType) <- CACHE.get(baseType)) {
            return boxType
        }
        let newBoxType = BoxType(baseType)
        CACHE[baseType] = newBoxType
        return newBoxType
    }

    /**
     * @brief Converts this BoxType to its string representation.
     * @return A string representation of the box type (Box<baseType>).
     */
    public func toString(): String {
        let result = StringBuilder()
        result.append("Box<")
        result.append(baseType.toString())
        result.append(">")
        return result.toString()
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
    //                          element type -> (dims, RawArrayType)
    private static var CACHE = HashMap<Type, HashMap<UInt32, RawArrayType>>()

    /**
     * @brief Gets or creates a RawArrayType for the given element type and dimensions.
     *
     * This method ensures that only one RawArrayType instance exists for each element type and dimension combination.
     * @param elementType The element type of the array.
     * @param dims The number of dimensions.
     * @return The RawArrayType instance.
     */
    public static func get(elementType: Type, dims: UInt32): RawArrayType {
        if (let Some(rawArrayTypes) <- CACHE.get(elementType)) {
            if (let Some(rawArrayType) <- rawArrayTypes.get(dims)) {
                return rawArrayType
            } else {
                let newRawArrayType = RawArrayType(elementType, dims)
                rawArrayTypes[dims] = newRawArrayType
                return newRawArrayType
            }
        }
        let newRawArrayType = RawArrayType(elementType, dims)
        CACHE[elementType] = HashMap<UInt32, RawArrayType>((dims, newRawArrayType))
        return newRawArrayType
    }

    /**
     * @brief Converts this RawArrayType to its string representation.
     * @return A string representation of the raw array type.
     */
    public func toString(): String {
        let result = StringBuilder()
        for (_ in 0..dims) {
            result.append("RawArray<")
        }
        result.append(elementType.toString())
        for (_ in 0..dims) {
            result.append(">")
        }
        return result.toString()
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
    private static var CACHE = HashMap<Type, HashMap<Int64, VArrayType>>()

    /**
     * @brief Gets or creates a VArrayType for the given element type and size.
     *
     * This method ensures that only one VArrayType instance exists for each element type and size combination.
     * @param elementType The element type of the array.
     * @param size The size of the array.
     * @return The VArrayType instance.
     */
    public static func get(elementType: Type, size: Int64): VArrayType {
        if (let Some(vArrayTypes) <- CACHE.get(elementType)) {
            if (let Some(vArrayType) <- vArrayTypes.get(size)) {
                return vArrayType
            } else {
                let newVArrayType = VArrayType(elementType, size)
                vArrayTypes[size] = newVArrayType
                return newVArrayType
            }
        }
        let newVArrayType = VArrayType(elementType, size)
        CACHE[elementType] = HashMap<Int64, VArrayType>((size, newVArrayType))
        return newVArrayType
    }

    /**
     * @brief Converts this VArrayType to its string representation.
     * @return A string representation of the VArray type (VArray<elementType, $size>).
     */
    public func toString(): String {
        let result = StringBuilder()
        result.append("VArray<")
        result.append(elementType.toString())
        result.append(", $")
        result.append(size.toString())
        result.append(">")
        return result.toString()
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

    public prop allMemberVarNames: Array<String> {
        get() {
            var result: ArrayList<String> = ArrayList<String>()
            if (isClassType()) {
                let classLikeDef = (def as ClassLikeDef).getOrThrow()
                if (classLikeDef.superClass.isSome()) {
                    result = ArrayList<String>.of(classLikeDef.superClass.getOrThrow().allMemberVarNames)
                }
            }
            for (memberVar in def.instanceVars) {
                result.add(memberVar.name)
            }
            return result.toArray()
        }
    }

    public func getExtendImplementedInterfaceTypes(visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType> {
        var result: ArrayList<ClassLikeType> = ArrayList<ClassLikeType>()
        for (exDef in getExtendDefs(visited: visited)) {
            let (success, instMap) = exDef.extendedType.calculateGeneric2InstTypeMap(this)
            assert(success, "Failed to calculate generic 2 inst type map")
            for (p in exDef.implementedInterfaceTypes) {
                let instType = (getInstType(p, instMap) as ClassLikeType).getOrThrow()
                result.add(instType)
            }
        }
        return result.toArray()
    }

    public func getImplementedInterfaceTypes(visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType> {
        var result = ArrayList<ClassLikeType>.of(this.getExtendImplementedInterfaceTypes(visited: visited))
        for (p in _def.implementedInterfaceTypes) {
            let instType = (getInstType(p, generic2InstTypeMap) as ClassLikeType).getOrThrow()
            result.add(instType)
        }
        return result.toArray()
    }

    public func getInstantiatedMemberVarTypes(): Array<Type> {
        var result: ArrayList<Type> = ArrayList<Type>()
        if (isClassType()) {
            let cType = (this as ClassLikeType).getOrThrow()
            if (cType.hasSuperClassType()) {
                result = ArrayList<Type>.of(cType.getSuperClassType().getInstantiatedMemberVarTypes())
            }
        }
        for (memberVar in def.instanceVars) {
            result.add(getInstType(memberVar.ty, generic2InstTypeMap))
        }
        return result.toArray()
    }

    public func getMemberVarInstantiatedType(name: String): Type {
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
        let result = StringBuilder()
        result.append(this._kind.toString())
        result.append("-")
        result.append(_def.identifierWithoutPrefix)
        result.append(typeVecToString("<", genericTypeArgs, ">"))
        return result.toString()
    }

    public func getSuperTypesRecusively(visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType> {
        var result: ArrayList<ClassLikeType> = ArrayList<ClassLikeType>()
        for (p in this.getImplementedInterfaceTypes(visited: visited)) {
            getAllInstantiatedParentTypes(p, result, visited)
        }
        if (let c <- (this as ClassLikeType) && c.isSome() && c.getOrThrow().hasSuperClassType()) {
            getAllInstantiatedParentTypes(c.getOrThrow().getSuperClassType(), result, visited)
        }
        return result.toArray()
    }

    public func getExtendDefs(visited !: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ExtendDef> {
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
public class ClassLikeType <: CustomType & Equatable<ClassLikeType> {
    //                    def -> (generic type args signature -> ClassLikeType)
    private static var CACHE = HashMap<ClassLikeDef, HashMap<String, ClassLikeType>>()

    /**
     * @brief Gets the ClassLikeDef associated with this class type.
     * @return The ClassLikeDef instance.
     */
    public prop classLikeDef: ClassLikeDef {
        get() {
            return (def as ClassLikeDef).getOrThrow()
        }
    }

    /**
     * @brief Checks if this class type has a super class.
     * @return true if the class has a super class, false otherwise.
     */
    internal func hasSuperClassType(): Bool {
        return classLikeDef.superClass.isSome()
    }

    /**
     * @brief Gets the super class type of this class.
     * @return The super class type.
     */
    internal func getSuperClassType(): ClassLikeType {
        let res = getInstType(classLikeDef.superClass.getOrThrow(), generic2InstTypeMap)
        return (res as ClassLikeType).getOrThrow()
    }

    /**
     * @brief Checks if this ClassLikeType is equal to another ClassLikeType.
     * @param other The ClassLikeType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: ClassLikeType): Bool {
        return hasSameTypeKindAndArgs(other) && this._def == other._def
    }

    /**
     * @brief Gets or creates a ClassLikeType for the given class definition and generic type parameters.
     *
     * This method ensures that only one ClassLikeType instance exists for each class definition and generic type parameter combination.
     * @param def The class definition.
     * @param genericTypeParams The generic type parameters.
     * @return The ClassLikeType instance.
     */
    public static func get(def: ClassLikeDef, genericTypeParams: Array<Type>): ClassLikeType {
        let key = typeVecToString("<", genericTypeParams, ">")
        if (let Some(classTypes) <- CACHE.get(def)) {
            if (let Some(classType) <- classTypes.get(key)) {
                return classType
            } else {
                let newClassType = ClassLikeType(def, ArrayList<Type>.of(genericTypeParams))
                classTypes[key] = newClassType
                return newClassType
            }
        }
        let newClassType = ClassLikeType(def, ArrayList<Type>.of(genericTypeParams))
        CACHE[def] = HashMap<String, ClassLikeType>((key, newClassType))
        return newClassType
    }

    private init(def: ClassLikeDef, genericTypeParams: ArrayList<Type>) {
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
    //                def -> (generic type args signature -> StructType)
    private static var CACHE = HashMap<StructDef, HashMap<String, StructType>>()

    /**
     * @brief Gets or creates a StructType for the given struct definition and generic type parameters.
     *
     * This method ensures that only one StructType instance exists for each struct definition and generic type parameter combination.
     * @param def The struct definition.
     * @param genericTypeParams The generic type parameters.
     * @return The StructType instance.
     */
    public static func get(def: StructDef, genericTypeParams: Array<Type>): StructType {
        let key = typeVecToString("<", genericTypeParams, ">")
        if (let Some(structTypes) <- CACHE.get(def)) {
            if (let Some(structType) <- structTypes.get(key)) {
                return structType
            } else {
                let newStructType = StructType(def, ArrayList<Type>.of(genericTypeParams))
                structTypes[key] = newStructType
                return newStructType
            }
        }
        let newStructType = StructType(def, ArrayList<Type>.of(genericTypeParams))
        CACHE[def] = HashMap<String, StructType>((key, newStructType))
        return newStructType
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
    //              def -> (generic type args signature -> EnumType)
    private static var CACHE = HashMap<EnumDef, HashMap<String, EnumType>>()

    /**
     * @brief Gets or creates an EnumType for the given enum definition and generic type parameters.
     *
     * This method ensures that only one EnumType instance exists for each enum definition and generic type parameter combination.
     * @param def The enum definition.
     * @param genericTypeParams The generic type parameters.
     * @return The EnumType instance.
     */
    public static func get(def: EnumDef, genericTypeParams: Array<Type>): EnumType {
        let key = typeVecToString("<", genericTypeParams, ">")
        if (let Some(enumTypes) <- CACHE.get(def)) {
            if (let Some(enumType) <- enumTypes.get(key)) {
                return enumType
            } else {
                let newEnumType = EnumType(def, ArrayList<Type>.of(genericTypeParams))
                enumTypes[key] = newEnumType
                return newEnumType
            }
        }
        let newEnumType = EnumType(def, ArrayList<Type>.of(genericTypeParams))
        CACHE[def] = HashMap<String, EnumType>((key, newEnumType))
        return newEnumType
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
    //                             signature -> FuncType
    private static var CACHE = HashMap<String, FuncType>()
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
        var key = typeVecToString("(", paramTypes, ")") + "->" + retType.toString()
        key += if (varArg) { "|1" } else { "|0" }
        key += if (cFunc)  { "|1" } else { "|0" }
        if (let Some(funcType) <- CACHE.get(key)) {
            return funcType
        }
        let newFuncType = FuncType(ArrayList<Type>.of(paramTypes), retType, varArg, cFunc)
        CACHE[key] = newFuncType
        return newFuncType
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
        let result = StringBuilder()
        let suffix = if (_hasVarArg) {
            "...)"
        } else {
            ")"
        }
        var paramTypesStr = typeVecToString("(", paramTypes, suffix)
        if (paramTypesStr.isEmpty()) {
            paramTypesStr = "()"
        }
        if (_isCFunc) {
            result.append("CFunc<")
        }
        result.append(paramTypesStr)
        result.append(" -> ")
        result.append(returnType.toString())
        if (_isCFunc) {
            result.append(">")
        }
        return result.toString()
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

/**
 * @brief Represents a generic type parameter in the type system.
 *
 * This type represents a generic type parameter with optional upper bounds.
 * The class maintains a cache of all generic types to ensure uniqueness.
 */
public class GenericType <: Type & Equatable<GenericType> {
    //                            identifier -> GenericType
    private static var CACHE = HashMap<String, GenericType>()
    internal let _identifier: String
    private let _srcCodeName: String
    internal var _upperBounds: ArrayList<Type> = ArrayList<Type>()

    /**
     * @brief Gets or creates a GenericType for the given identifier.
     *
     * This method ensures that only one GenericType instance exists for each identifier.
     * @param identifier The internal identifier of the generic type.
     * @param srcCodeName The source code identifier of the generic type.
     * @return The GenericType instance.
     */
    public static func get(identifier: String, srcCodeName: String): GenericType {
        if (let Some(gType) <- CACHE.get(identifier)) {
            return gType
        }
        let newGType = GenericType(identifier, srcCodeName)
        CACHE[identifier] = newGType
        return newGType
    }

    /**
     * @brief Gets the source code identifier of this generic type.
     * @return The source code identifier.
     */
    public prop srcCodeName: String {
        get() {
            return _srcCodeName
        }
    }

    /**
     * @brief Gets or sets the upper bounds of this generic type.
     *
     * Upper bounds specify the types that this generic type parameter must be a subtype of.
     * @return An array of upper bound types.
     */
    public mut prop upperBounds: Array<Type> {
        get() {
            return _upperBounds.toArray()
        }
        set(v) {
            for (bound in v) {
                if (bound.stripAllRefs().isValueType()) {
                    throw IllegalArgumentException("Generic type upper bound should NOT be value type!")
                }
            }
            _upperBounds = ArrayList<Type>.of(v)
            sort(_upperBounds,
                by: { l, r =>
                    let lstring = l.toString()
                    let rstring = r.toString()
                    if (lstring == rstring) {
                        return Ordering.EQ
                    } else if (lstring < rstring) {
                        return Ordering.LT
                    } else {
                        return Ordering.GT
                    }
                },
                stable: true,
                descending: false
            )
        }
    }

    /**
     * @brief Converts this GenericType to its string representation.
     * @return A string representation of the generic type.
     */
    public func toString(): String {
        let result = StringBuilder()
        result.append(this._kind.toString())
        result.append("-")
        result.append(this._identifier)
        return result.toString()
    }

    /**
     * @brief Checks if this GenericType is equal to another GenericType.
     * @param other The GenericType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: GenericType): Bool {
        return this._identifier == other._identifier &&
            this._srcCodeName == other.srcCodeName &&
            this._upperBounds == other._upperBounds
    }

    private init(identifier: String, srcCodeName: String) {
        super(TypeKind.Generic)
        this._identifier = identifier
        this._srcCodeName = srcCodeName
        setHashCode()
    }
}

/**
 * @brief Represents the This type in the type system.
 *
 * This type represents the current instance type within a class or struct.
 * This is a singleton type.
 */
public class ThisType <: Type & Equatable<ThisType> {
    private static let THIS_TYPE = ThisType()

    /**
     * @brief Gets the singleton instance of ThisType.
     * @return The ThisType instance.
     */
    public static func get(): ThisType {
        return THIS_TYPE
    }

    /**
     * @brief Checks if this ThisType is equal to another ThisType.
     * @param _ The other ThisType to compare with (unused, always returns true).
     * @return Always returns true since all ThisType instances are equal.
     */
    public operator func ==(_: ThisType): Bool {
        return true
    }

    private init() {
        super(TypeKind.`This`)
        setHashCode()
    }
}

/**
 * @brief Represents a tuple type in the type system.
 *
 * This type represents a tuple with multiple element types.
 * The class maintains a cache of all tuple types to ensure uniqueness.
 */
public class TupleType <: Type & Equatable<TupleType> {
    //                 arity -> (signature -> TupleType)
    private static var CACHE = HashMap<Int64, HashMap<String, TupleType>>()

    /**
     * @brief Gets or creates a TupleType for the given element types.
     *
     * This method ensures that only one TupleType instance exists for each element type combination.
     * @param elementTypes The element types of the tuple.
     * @return The TupleType instance.
     */
    public static func get(elementTypes: Array<Type>): TupleType {
        let arity: Int64 = Int64(elementTypes.size)
        let key = typeVecToString("(", elementTypes, ")")
        if (let Some(tupleTypes) <- CACHE.get(arity)) {
            if (let Some(tupleType) <- tupleTypes.get(key)) {
                return tupleType
            } else {
                let newTupleType = TupleType(ArrayList<Type>.of(elementTypes))
                tupleTypes[key] = newTupleType
                return newTupleType
            }
        }
        let newTupleType = TupleType(ArrayList<Type>.of(elementTypes))
        CACHE[arity] = HashMap<String, TupleType>((key, newTupleType))
        return newTupleType
    }

    /**
     * @brief Converts this TupleType to its string representation.
     * @return A string representation of the tuple type.
     */
    public func toString(): String {
        let result = StringBuilder()
        result.append(this._kind.toString())
        result.append(typeVecToString("(", elementTypes, ")"))
        return result.toString()
    }

    /**
     * @brief Gets the element types of this tuple.
     * @return An array of element types.
     */
    public prop elementTypes: Array<Type> {
        get() {
            return _typeArgs.toArray()
        }
    }

    /**
     * @brief Checks if this TupleType is equal to another TupleType.
     * @param other The TupleType to compare with.
     * @return true if the types are equal, false otherwise.
     */
    public operator func ==(other: TupleType): Bool {
        return hasSameTypeKindAndArgs(other)
    }

    private init(elementType: ArrayList<Type>) {
        super(TypeKind.Tuple, elementType)
        setHashCode()
    }
}

private func tupleTypeIsEqualOrSubTypeOf(subType: TupleType, parentType: TupleType, visited: ArrayList<(Type, Type)>): Bool {
    let subElementTypes = subType.elementTypes
    let parentElementTypes = parentType.elementTypes
    if (subElementTypes.size != parentElementTypes.size) {
        return false
    }
    for (i in 0..subElementTypes.size) {
        if (!subElementTypes[i].isEqualOrSubTypeOf(parentElementTypes[i], visited: visited)) {
            return false
        }
    }
    return true
}

private func funcTypeIsEqualOrSubTypeOf(subType: FuncType, parentType: FuncType, visited: ArrayList<(Type, Type)>): Bool {
    if (subType.hasVarArg != parentType.hasVarArg) {
        return false
    }
    if (subType.isCFunc != parentType.isCFunc) {
        return false
    }
    let subParamTypes = subType.paramTypes
    let parentParamTypes = parentType.paramTypes
    if (subParamTypes.size != parentParamTypes.size) {
        return false
    }
    for (i in 0..subParamTypes.size) {
        if (!parentParamTypes[i].isEqualOrSubTypeOf(subParamTypes[i], visited: visited)) {
            return false
        }
    }
    return subType.returnType.isEqualOrSubTypeOf(parentType.returnType, visited: visited)
}

private func getClosureGenericBaseType(closureType: ClassLikeType): ClassLikeType {
    if (closureType.isClosureGenericBaseType()) {
        return closureType
    }
    return getClosureGenericBaseType(closureType.getSuperClassType())
}

private func convertClosureType2FuncType(closureType: ClassLikeType): FuncType {
    let baseType = getClosureGenericBaseType(closureType)
    let typeArgs = baseType.genericTypeArgs
    let (paramTypes, returnType) = typeArgs.splitAt(typeArgs.size - 1)
    return FuncType.get(paramTypes, returnType[0])
}

private func closureTypeIsEqualOrSubTypeOf(subType: ClassLikeType, parentType: ClassLikeType, visited: ArrayList<(Type, Type)>): Bool {
    let subFuncType = convertClosureType2FuncType(subType)
    let parentFuncType = convertClosureType2FuncType(parentType)
    return funcTypeIsEqualOrSubTypeOf(subFuncType, parentFuncType, visited)
}