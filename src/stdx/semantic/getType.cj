package stdx.semantic

import std.collection.HashMap
import std.collection.ArrayList

func generateSemanticType(t: Option<SemanticType_ASTType>): SemanticType {
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
        typeArgs.add(generateSemanticType(arg))
    }
    return match(kind) {
        case TYPE_INT64 => Int64SType(rawPointer)
        case _ => throw Exception("Not Impl")
    }

}