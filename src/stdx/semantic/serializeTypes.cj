package stdx.semantic
import std.collection.{HashMap, ArrayList}

func serializeNodeTypeInfoMap(declTypeInfoMap: HashMap<UInt64, SemanticType>): Array<UInt8> {
    var fb = Builder(0)
    let declMapList = serializeDeclTypeInfoMapList(fb, declTypeInfoMap)
    let nodeTypeMap = SemanticType_NodeTypeMap.createNodeTypeMap(
        fb, 
        declMapList,
        0,
        0)
    fb.finish(nodeTypeMap)
    fb.finishedBytes()
}

func serializeDeclTypeInfoMapList(fb: Builder, declTypeInfoMap: HashMap<UInt64, SemanticType>): UInt32 {
    let semanticTypeMapOffset = Array<UInt32>(declTypeInfoMap.size, repeat: 0) 
    let declTypeInfo = declTypeInfoMap.toArray()
    for(i in declTypeInfo.size - 1..=0 : -1) {
        let (key, value) = declTypeInfo[i]
        let tyOffset = serializeSemanticType(fb, value)
        semanticTypeMapOffset[i] = SemanticType_SemanticTypeMap.createSemanticTypeMap(fb, key, tyOffset)
    }

    fb.startVector(4, declTypeInfoMap.size, 4)
    for (i in semanticTypeMapOffset.size - 1..=0 : -1) {
        fb.prependUOffsetT(semanticTypeMapOffset[i])
    }
    fb.endVector(declTypeInfoMap.size)
}

func serializeSemanticType(fb: Builder, ty: SemanticType): UInt32 {
    return match (ty) {
        case classTy: ClassSType => let identifier = fb.createString(classTy.identifier)
                                    let typeArgs = serializeSemanticTypes(fb, classTy.typeArguments)
                                    SemanticType_ASTType.createASTType(fb, 28, identifier, typeArgs, 0 , 0)
        case int64Ty: Int64SType => SemanticType_ASTType.createASTType(fb, 5, 0, 0 , 0 , 0)
        case funcTy: FuncSType => let typeArguments = ArrayList<SemanticType>(funcTy.paramTypes)
                    typeArguments.add(funcTy.returnType)
                    let typeArgs = serializeSemanticTypes(fb, typeArguments.toArray())
                    SemanticType_ASTType.createASTType(fb, 22, 0, typeArgs, 0 , 0)
        case _ => throw Exception("serializeSemanticType not impl")
    }
}

func serializeSemanticTypes(fb: Builder, tys: Array<SemanticType>): UInt32 {
    let tyOffset = Array<UInt32>(tys.size, repeat: 0) 
    for (i in tys.size - 1..=0 : -1) {
        tyOffset[i] = serializeSemanticType(fb, tys[i])
    }
    fb.startVector(4, tys.size, 4)
    for (i in tys.size - 1..=0 : -1) {
        fb.prependUOffsetT(tyOffset[i])
    }
    fb.endVector(tys.size)
}