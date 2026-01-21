/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.semantic

import std.collection.ArrayList
import stdx.syntax.*

public enum TypeKind <: ToString {
    TYPE_INVALID
    |TYPE_UNIT
    |TYPE_INT8
    |TYPE_INT16
    |TYPE_INT32
    |TYPE_INT64
    |TYPE_INT_NATIVE
    |TYPE_IDEAL_INT
    |TYPE_UINT8
    |TYPE_UINT16
    |TYPE_UINT32
    |TYPE_UINT64
    |TYPE_UINT_NATIVE
    |TYPE_FLOAT16
    |TYPE_FLOAT32
    |TYPE_FLOAT64
    |TYPE_IDEAL_FLOAT
    |TYPE_RUNE
    |TYPE_NOTHING
    |TYPE_BOOLEAN
    |TYPE_TUPLE
    |TYPE_ENUM
    |TYPE_FUNC
    |TYPE_STRUCT
    |TYPE_ARRAY
    |TYPE_VARRAY
    |TYPE_POINTER       // CPointer
    |TYPE_CSTRING
    |TYPE_CLASS    // ClassDecl is too much
    |TYPE_INTERFACE
    |TYPE_ALIAS
    |TYPE_GENERICS
    |TYPE_ANY
    |TYPE_INTERSECTION
    |TYPE_UNION
    |TYPE_QUEST
    |TYPE_INITIAL

    public func toString() : String {
        return match (this) {
            case TYPE_INVALID => "invalid"
            case TYPE_UNIT => "Unit"
            case TYPE_INT8 => "Int8"
            case TYPE_INT16 => "Int16"
            case TYPE_INT32 => "Int32"
            case TYPE_INT64 => "Int64"
            case TYPE_INT_NATIVE => "IntNative"
            case TYPE_IDEAL_INT => "Int"
            case TYPE_UINT8 => "UInt8"
            case TYPE_UINT16 => "UInt16"
            case TYPE_UINT32 => "UInt32"
            case TYPE_UINT64 => "UInt64"
            case TYPE_UINT_NATIVE => "UIntNative"
            case TYPE_FLOAT16 => "Float16"
            case TYPE_FLOAT32 => "Float32"
            case TYPE_FLOAT64 => "Float64"
            case TYPE_IDEAL_FLOAT => "Float"
            case TYPE_RUNE => "Rune"
            case TYPE_NOTHING => "Nothing"
            case TYPE_BOOLEAN => "Bool"
            case TYPE_TUPLE => "tuple"
            case TYPE_ENUM => "enum"
            case TYPE_FUNC => "func"
            case TYPE_STRUCT => "struct"
            case TYPE_ARRAY => "Array"
            case TYPE_VARRAY => "VArray"
            case TYPE_POINTER => "CPointer"
            case TYPE_CSTRING => "CString"
            case TYPE_CLASS => "class"
            case TYPE_INTERFACE => "interface"
            case TYPE_ALIAS => "type"
            case TYPE_GENERICS => "generics"
            case TYPE_ANY => "any"
            case TYPE_INTERSECTION => "intersection"
            case TYPE_UNION => "union"
            case TYPE_QUEST => "quest"
            case TYPE_INITIAL => "initial"
        }
    }
}


public func convertInt2TypeKind(value: UInt16) : TypeKind{
    return match(value) {
        case 0 => TYPE_INVALID
        case 1 => TYPE_UNIT
        case 2 => TYPE_INT8
        case 3 => TYPE_INT16
        case 4 => TYPE_INT32
        case 5 => TYPE_INT64
        case 6 => TYPE_INT_NATIVE
        case 7 => TYPE_IDEAL_INT
        case 8 => TYPE_UINT8
        case 9 => TYPE_UINT16
        case 10 => TYPE_UINT32
        case 11 => TYPE_UINT64
        case 12 => TYPE_UINT_NATIVE
        case 13 => TYPE_FLOAT16
        case 14 => TYPE_FLOAT32
        case 15 => TYPE_FLOAT64
        case 16 => TYPE_IDEAL_FLOAT
        case 17 => TYPE_RUNE
        case 18 => TYPE_NOTHING
        case 19 => TYPE_BOOLEAN
        case 20 => TYPE_TUPLE
        case 21 => TYPE_ENUM
        case 22 => TYPE_FUNC
        case 23 => TYPE_STRUCT
        case 24 => TYPE_ARRAY
        case 25 => TYPE_VARRAY
        case 26 => TYPE_POINTER
        case 27 => TYPE_CSTRING
        case 28 => TYPE_CLASS
        case 29 => TYPE_INTERFACE
        case 30 => TYPE_ALIAS
        case 31 => TYPE_GENERICS
        case 32 => TYPE_ANY
        case 33 => TYPE_INTERSECTION
        case 34 => TYPE_UNION
        case 35 => TYPE_QUEST
        case 36 => TYPE_INITIAL
        case _ => TYPE_INVALID
    }
}

public sealed abstract class SemanticType <: ToString {
    private let superSTys: Array<SemanticType>
    let rawPointer: UInt64

    init(r: UInt64) {
        rawPointer = r
        this.superSTys = Array<SemanticType>()
    }

    // public func isSubtypeOf(that: SemanticType): Bool {
    //     return superSTys.Contains(that)
    // }
    // public func getSuperSTys(): Array<SemanticType> {
    //     return superSTys
    // }

    public open func toString(): String
} 

public class UnitSType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    public func toString(): String {
        "Unit"
    }
}

public class Int8SType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    public func toString(): String {
        "Int8"
    }
}

public class Int16SType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "Int16"
    }
}

public class Int32SType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "Int32"
    }
}

public class Int64SType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "Int64"
    }
}

public class IntNativeSType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "IntNative"
    }
}

public class UInt8SType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "UInt8"
    }
}

public class UInt16SType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "UInt16"
    }
}

public class UInt32SType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "UInt32"
    }
}

public class UInt64SType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "UInt64"
    }
}

public class UIntNativeSType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "UIntNative"
    }
}

public class Float16SType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "Float16"
    }
}

public class Float32SType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "Float32"
    }
}

public class Float64SType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "Float64"
    }
}

public class RuneSType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "Rune"
    }
}

public class BoolSType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "Bool"
    }
}

public class StringSType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    

    public func toString(): String {
        "String"
    }
}

public class TupleSType <: SemanticType {
    

    public let elementTypes: Array<SemanticType>

    init(elementTypes: Array<SemanticType>, rawPointer: UInt64) {
        super(rawPointer)
        this.elementTypes = elementTypes
    }

    public func toString(): String {
        var eleStr = "("
        for (i in 0..elementTypes.size) {
            eleStr += "${elementTypes[i]}"
            if (i != elementTypes.size - 1) {
                eleStr += ", "
            }
        }
        eleStr += ")"
        return eleStr
    }
}


public class FuncSType <: SemanticType {
    
    /** The types of this function type's parameters. */
    public let paramTypes: Array<SemanticType>

    /** The return type of this function. */
    public let returnType: SemanticType

    init(typeArguments: Array<SemanticType>, rawPointer: UInt64) {
        super(rawPointer)
        paramTypes = typeArguments[0..typeArguments.size - 1]
        returnType = typeArguments[typeArguments.size - 1]
    }

    public func toString(): String {
        var str = "("
        for (i in 0..paramTypes.size) {
            str += paramTypes[i].toString()
            if (i != paramTypes.size - 1) {
                str += ", "
            }
        }
        str += ") -> "
        str += returnType.toString()
        return str
    }
}


public class ClassSType <: SemanticType {
    private let decl_: Option<ClassDecl>

    public let identifier: String
    public let typeArguments: Array<SemanticType>

    init(identifier: String, typeArguments: Array<SemanticType>, decl_: Option<ClassDecl>, rawPointer: UInt64) {
        super(rawPointer)
        this.decl_ = decl_
        this.identifier = identifier
        this.typeArguments = typeArguments
    }

    public func getDecl(): Option<ClassDecl> {
        return decl_
    }

    public func toString(): String {
        identifier + getGenericString(typeArguments)
    }
}


public class StructSType <: SemanticType {
    private let decl_: Option<StructDecl>

    public let identifier: String
    public let typeArguments: Array<SemanticType>

    init(identifier: String, typeArguments: Array<SemanticType>, decl_: Option<StructDecl>, rawPointer: UInt64) {
        super(rawPointer)
        this.decl_ = decl_
        this.identifier = identifier
        this.typeArguments = typeArguments
    }

    public func getDecl(): Option<StructDecl> {
        return decl_
    }

    public func toString(): String {
        identifier + getGenericString(typeArguments)
    }
}

public class EnumSType <: SemanticType {
    private let decl_: Option<EnumDecl>

    public let identifier: String
    public let typeArguments: Array<SemanticType>

    init(identifier: String, typeArguments: Array<SemanticType>, decl_: Option<EnumDecl>, rawPointer: UInt64) {
        super(rawPointer)
        this.decl_ = decl_
        this.identifier = identifier
        this.typeArguments = typeArguments
    }

    public func getDecl(): Option<EnumDecl> {
        return decl_
    }

    public func toString(): String {
        identifier + getGenericString(typeArguments)
    }
}

public class CPointerSType <: SemanticType {
    /**
     * The types with which this class type has been instantiated,
     * in the event it's a generic type. If not, an empty array.
     */
    public let typeArgument: SemanticType
    
    init(typeArgument: SemanticType, rawPointer: UInt64) {
        super(rawPointer)
        this.typeArgument = typeArgument
    }

    public func toString(): String {
        "CPointer<${typeArgument}>"
    }
}


public class InterfaceSType <: SemanticType {
    private let decl_: Option<InterfaceDecl>

    public let identifier: String
    public let typeArguments: Array<SemanticType>

    init(identifier: String, typeArguments: Array<SemanticType>, decl_: Option<InterfaceDecl>, rawPointer: UInt64) {
        super(rawPointer)
        this.decl_ = decl_
        this.identifier = identifier
        this.typeArguments = typeArguments
    }

    public func getDecl(): Option<InterfaceDecl> {
        return decl_
    }

    public func toString(): String {
        identifier + getGenericString(typeArguments)
    }
}

public class AnySType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    public func toString(): String {
        return "Any"
    }
}

public class NothingSType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    public func toString(): String {
        return "Nothing"
    }
}

public class ThisSType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    public func toString(): String {
        return "This"
    }
}

func getGenericString(typeArguments: Array<SemanticType>) {
    if (typeArguments.size == 0) {
        return ""
    }
    var argStr = "<"
    for (i in 0..typeArguments.size) {
        argStr += "${typeArguments[i]}"
        if (i != typeArguments.size - 1) {
            argStr += ", "
        }
    }
    argStr += ">"
    return argStr
}

public class RangeSType <: SemanticType {
    /** The type of this range type's elements. */
    public let typeArgument: SemanticType

    init(typeArgument: SemanticType, rawPointer: UInt64) {
        super(rawPointer)
        this.typeArgument = typeArgument
    }

    // public func extendDecls(): Array<ExtendDecl> {
    //     return GetExtendDecls(this)
    // }

    public func toString(): String {
        return "Range<${typeArgument}>"
    }
}

public class ArraySType <: SemanticType {
    /** The type of this array type's elements. */
    public let typeArgument: SemanticType

    init(typeArgument: SemanticType, rawPointer: UInt64) {
        super(rawPointer)
        this.typeArgument = typeArgument
    }

    public func toString(): String {
        return "Array<${typeArgument}>"
    }
}

public class VArraySType <: SemanticType {
    /** The type of this vArray type's elements. */
    public let elementType: SemanticType

    /** The length of this vArray type */
    public let length: Int64

    init(elementType: SemanticType, length: Int64, rawPointer: UInt64) {
        super(rawPointer)
        this.elementType = elementType
        this.length = length
    }

    public func toString(): String {
        return "VArray<${elementType}, \$${length}>"
    }
}

public class GenericSTypeParameter <: SemanticType {
    public let identifier: String
    public let upperBounds: Array<SemanticType>

    init(identifier: String, typeArguments: Array<SemanticType>, rawPointer: UInt64) {
        super(rawPointer)
        this.identifier = identifier
        this.upperBounds = typeArguments
    }

    public func toString(): String {
        return identifier
    }
}


public class CStringSType <: SemanticType {
    init(rawPointer: UInt64) {
        super(rawPointer)
    }

    public func toString(): String {
        return "CString"
    }
}


public class CFuncSType <: SemanticType {
    public let typeArgument: FuncSType

    init(typeArgument: FuncSType, rawPointer: UInt64) {
        super(rawPointer)
        this.typeArgument = typeArgument
    }

    public func toString(): String {
        return "CFunc<" + typeArgument.toString() + ">"
    }
}