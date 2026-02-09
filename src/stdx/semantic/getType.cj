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
    // find ty->declaration
    let nf = NodeFinder(pkgAST, semanticType.GetDeclId())
    nf.walk(pkgAST)

    return match(kind) {
        case TYPE_INVALID => throw Exception("Invalid type")
        case TYPE_UNIT => UnitSType(rawPointer)
        case TYPE_INT8 => Int8SType(rawPointer)
        case TYPE_INT16 => Int16SType(rawPointer)
        case TYPE_INT32 => Int32SType(rawPointer)
        case TYPE_INT64 => Int64SType(rawPointer)
        case TYPE_INT_NATIVE => IntNativeSType(rawPointer)
        case TYPE_IDEAL_INT => throw Exception("Ideal int not implemented")
        case TYPE_UINT8 => UInt8SType(rawPointer)
        case TYPE_UINT16 => UInt16SType(rawPointer)
        case TYPE_UINT32 => UInt32SType(rawPointer)
        case TYPE_UINT64 => UInt64SType(rawPointer)
        case TYPE_UINT_NATIVE => UIntNativeSType(rawPointer)
        case TYPE_FLOAT16 => Float16SType(rawPointer)
        case TYPE_FLOAT32 => Float32SType(rawPointer)
        case TYPE_FLOAT64 => Float64SType(rawPointer)
        case TYPE_IDEAL_FLOAT => throw Exception("Ideal float not implemented")
        case TYPE_RUNE => RuneSType(rawPointer)
        case TYPE_NOTHING => NothingSType(rawPointer)
        case TYPE_BOOLEAN => BoolSType(rawPointer)
        case TYPE_TUPLE => TupleSType(typeArgs.toArray(), rawPointer)
        case TYPE_ENUM =>
            var decl = Option<EnumDecl>.None
            if (let Some(realRes) <- nf.res) {
                decl = realRes as EnumDecl
            }
            EnumSType(name, typeArgs.toArray(), decl, rawPointer)
        case TYPE_FUNC => FuncSType(typeArgs.toArray(), rawPointer)
        case TYPE_STRUCT =>
            var decl = Option<StructDecl>.None
            if (let Some(realRes) <- nf.res) {
                decl = realRes as StructDecl
            }
            StructSType(name, typeArgs.toArray(), decl, rawPointer)
        case TYPE_ARRAY => ArraySType(typeArgs[0], rawPointer)
        case TYPE_VARRAY => 
            // Parse length from name field, which format is "VArray<elementType, $length>"
            let length = parseVArrayLength(name)
            VArraySType(typeArgs[0], length, rawPointer)
        case TYPE_POINTER => CPointerSType(typeArgs[0], rawPointer)
        case TYPE_CSTRING => CStringSType(rawPointer)
        case TYPE_CLASS =>
            var decl = Option<ClassDecl>.None
            if (let Some(realRes) <- nf.res) {
                decl = realRes as ClassDecl
            }
            ClassSType(name, typeArgs.toArray(), decl, rawPointer)
        case TYPE_INTERFACE =>
            var decl = Option<InterfaceDecl>.None
            if (let Some(realRes) <- nf.res) {
                decl = realRes as InterfaceDecl
            }
            InterfaceSType(name, typeArgs.toArray(), decl, rawPointer)
        case TYPE_ALIAS => throw Exception("Alias type not implemented")
        case TYPE_GENERICS => GenericSTypeParameter(name, typeArgs.toArray(), rawPointer)
        case TYPE_ANY => AnySType(rawPointer)
        case TYPE_INTERSECTION => throw Exception("Intersection type not implemented")
        case TYPE_UNION => throw Exception("Union type not implemented")
        case TYPE_QUEST => throw Exception("Quest type not implemented")
        case TYPE_INITIAL => throw Exception("Initial type not implemented")
        case _ => throw Exception("Not Impl")
    }
}