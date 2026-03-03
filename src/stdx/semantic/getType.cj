package stdx.semantic

import std.convert.*
import std.collection.HashMap
import std.collection.ArrayList
import stdx.syntax.*


func parseVArrayLength(name: String): Int64 {
    let dollarPos = name.indexOf("$")
    var gtPos: Option<Int64> = 0
    
    if (let Some(pos) <- dollarPos) {
        gtPos = name.indexOf(">", pos)
    }

    if (let Some(startPos) <- dollarPos && let Some(endPos) <- gtPos) {
        let lengthStr = name[startPos + 1..endPos]
        let length = Int64.parse(lengthStr)
        return length
    }
    
    // If name is just "$3" format, parse directly
    if (let Some(pos) <- dollarPos) {
        let lengthStr = name[pos + 1..]
        let length = Int64.parse(lengthStr)
        return length
    }
    
    return 0
}

func generateSemanticType(t: Option<SemanticType_ASTType>, pkgAST: Package): SemanticType {
    let semanticType = match (t) {
        case Some(v) => v
        case None => throw Exception("no semanticType")
    }
    let kindValue = semanticType.GetKind()
    let kind = convertInt2TypeKind(kindValue)

    let name = semanticType.GetName()
    let rawPointer = semanticType.GetRawPointer()

    let typeArgsNode = semanticType.GetTypeArgs()
    let typeArgs = ArrayList<SemanticType>()

    for (arg in typeArgsNode) {
        typeArgs.add(generateSemanticType(arg, pkgAST))
    }

    return match(kind) {
        case TYPE_INVALID => 
                println("Invalid type")
                NothingSType(rawPointer)
        case TYPE_UNIT => UnitSType(rawPointer)
        case TYPE_INT8 => Int8SType(rawPointer)
        case TYPE_INT16 => Int16SType(rawPointer)
        case TYPE_INT32 => Int32SType(rawPointer)
        case TYPE_INT64 => Int64SType(rawPointer)
        case TYPE_INT_NATIVE => IntNativeSType(rawPointer)
        case TYPE_IDEAL_INT => Int64SType(rawPointer)
        case TYPE_UINT8 => UInt8SType(rawPointer)
        case TYPE_UINT16 => UInt16SType(rawPointer)
        case TYPE_UINT32 => UInt32SType(rawPointer)
        case TYPE_UINT64 => UInt64SType(rawPointer)
        case TYPE_UINT_NATIVE => UIntNativeSType(rawPointer)
        case TYPE_FLOAT16 => Float16SType(rawPointer)
        case TYPE_FLOAT32 => Float32SType(rawPointer)
        case TYPE_FLOAT64 => Float64SType(rawPointer)
        case TYPE_IDEAL_FLOAT => Float64SType(rawPointer)
        case TYPE_RUNE => RuneSType(rawPointer)
        case TYPE_NOTHING => NothingSType(rawPointer)
        case TYPE_BOOLEAN => BoolSType(rawPointer)
        case TYPE_TUPLE => TupleSType(typeArgs.toArray(), rawPointer)
        case TYPE_ENUM =>
            let nf = TopDeclFinder(pkgAST, semanticType.GetDeclId())
            EnumSType(name, typeArgs.toArray(), nf, rawPointer)
        case TYPE_FUNC => FuncSType(typeArgs.toArray(), rawPointer)
        case TYPE_STRUCT =>
            let nf = TopDeclFinder(pkgAST, semanticType.GetDeclId())
            StructSType(name, typeArgs.toArray(), nf, rawPointer)
        case TYPE_ARRAY => ArraySType(typeArgs[0], rawPointer)
        case TYPE_VARRAY => 
            let length = if (typeArgsNode.size > 1) {
                match (typeArgsNode[1]) {
                    case Some(arg) => parseVArrayLength(arg.GetName())
                    case None => 0
                }
            } else {
                0
            }
            VArraySType(typeArgs[0], length, rawPointer)
        case TYPE_POINTER => CPointerSType(typeArgs[0], rawPointer)
        case TYPE_CSTRING => CStringSType(rawPointer)
        case TYPE_CLASS =>
            let nf = TopDeclFinder(pkgAST, semanticType.GetDeclId())
            ClassSType(name, typeArgs.toArray(), nf, rawPointer)
        case TYPE_INTERFACE =>
            let nf = TopDeclFinder(pkgAST, semanticType.GetDeclId())
            InterfaceSType(name, typeArgs.toArray(), nf, rawPointer)
        case TYPE_ALIAS => 
                    println("Alias type not implemented")
                    NothingSType(rawPointer)
        case TYPE_GENERICS => GenericSTypeParameter(name, typeArgs.toArray(), rawPointer)
        case TYPE_ANY => AnySType(rawPointer)
        case TYPE_INTERSECTION => 
                    println("Intersection type not implemented")
                    NothingSType(rawPointer)
        case TYPE_UNION => 
                    println("Union type not implemented")
                    NothingSType(rawPointer)
        case TYPE_QUEST => 
                    println("Quest type not implemented")
                    NothingSType(rawPointer)        
        case TYPE_INITIAL => 
                    println("Initial type not implemented")
                    NothingSType(rawPointer)
        case _ => 
                    println("Not Impl")
                    NothingSType(rawPointer)
    }
}