/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

import std.collection.*

internal func getFieldOfType(baseTy: Type, path: ArrayList<Int64>): Type {
    var resType = baseTy
    for (i in path) {
        resType = getFieldOfTypeImpl(resType, i)
    }
    return resType
}

internal func isOptionLike(def: EnumDef): Bool {
    if (!def.isExhaustive) {
        return false
    }
    let ctors = def.constructors
    if (ctors.size != 2) {
        return false
    }
    // `enum EA { A(xxx) | B }` or `enum EA { A | B(xxx) }`
    return ctors[0].funcType.paramTypes.size + ctors[1].funcType.paramTypes.size == 1
}

internal func getEnumSelectorType(def: EnumDef): TypeKind {
    if (isOptionLike(def)) {
        return TypeKind.`Bool`
    }
    return TypeKind.`UInt32`
}

private func getFieldOfTypeImpl(baseTy: Type, index: Int64): Type {
    if (baseTy.isRefType()) {
        return getFieldOfTypeImpl(baseTy.stripAllRefs(), index)
    } else if (baseTy.isTupleType()) {
        return (baseTy as TupleType).getOrThrow().elementTypes[index]
    } else if (baseTy.isStructType() || baseTy.isClassLikeType()) {
        let memberVarTypes = (baseTy as CustomType).getOrThrow().getInstantiatedMemberVarTypes()
        assert(memberVarTypes.size > index, "Member variable size mismatch, ${memberVarTypes.size} vs ${index}")
        return memberVarTypes[index]
    } else if (baseTy.isEnumType()) {
        assert(index == 0, "Enum type can only have one element")
        let enumType = (baseTy as EnumType).getOrThrow()
        if (getEnumSelectorType(enumType.enumDef) == TypeKind.`Bool`) {
            return BoolType.get()
        }
        return IntType.getUInt32()
    } else if (baseTy.isRawArrayType()) {
        return (baseTy as RawArrayType).getOrThrow().elementType
    }
    throw Exception("Invalid type: " + baseTy.toString())
}

internal func getFieldOfType(baseTy: Type, fieldNames: ArrayList<String>): Type {
    var resType = baseTy
    for (name in fieldNames) {
        resType = getFieldOfTypeImpl(resType, name)
    }
    return resType
}

private func getFieldOfTypeImpl(baseTy: Type, name: String): Type {
    if (baseTy.isRefType()) {
        return getFieldOfTypeImpl(baseTy.stripAllRefs(), name)
    } else if (baseTy.isStructType() || baseTy.isClassLikeType()) {
        return (baseTy as CustomType).getOrThrow().getMemberVarInstantiatedType(name)
    }
    throw Exception("Invalid type: " + baseTy.toString())
}

internal func getInstMapFromCurDefAndExDefToCurType(curType: CustomType): HashMap<GenericType, Type> {
    let (res, instMap) = curType.def.ty.calculateGeneric2InstTypeMap(curType)
    assert(res, "Failed to calculate generic 2 inst type map")
    for (exDef in curType.def.extends) {
        // maybe we can meet `extend<T> A<B<T>> {}`, and `curType` is A<Int32>, then ignore this def,
        // so not need to check `res`
        let (_, tempTable) = exDef.extendedType.calculateGeneric2InstTypeMap(curType)
        instMap.add(all: tempTable)
    }
    return instMap
}

internal func paramTypeIsEquivalent(paramType: Type, argType: Type): Bool {
    if (paramType == argType) {
        return true
    }
    // `NothingType` is any type's sub type, so it's equivalent to any type
    if (argType.isNothingType()) {
        return true
    }
    if (paramType.isBoxRefTypeOf(argType) || argType.isBoxRefTypeOf(paramType)) {
        return true
    }
    return meetClosureType(argType.stripAllRefs(), paramType.stripAllRefs())
}

internal func meetClosureType(subType: Type, parentType: Type): Bool {
    return subType.isClosureInstBaseType() && parentType.isClosureGenericBaseType() &&
        (subType as ClassLikeType).getOrThrow().classLikeDef.superClass.getOrThrow() == parentType
}

internal func getInstType(genericType: Type, replaceTable: HashMap<GenericType, Type>): Type {
    if (!genericType.isGenericRelated()) {
        return genericType
    }
    if (genericType.isGenericType()) {
        let res = replaceTable.get((genericType as GenericType).getOrThrow())
        if (let Some(r) <- res) {
            return r
        }
        return genericType
    }
    var newTypeArgs: ArrayList<Type> = ArrayList<Type>()
    for (arg in genericType.typeArgs) {
        newTypeArgs.add(getInstType(arg, replaceTable))
    }
    return createNewTypeWithArgs(genericType, newTypeArgs)
}

internal func createNewTypeWithArgs(oldType: Type, newTypeArgs: ArrayList<Type>): Type {
    if (newTypeArgs.isEmpty()) {
        return oldType
    }
    match (oldType._kind) {
        case TypeKind.Tuple =>
            return TupleType.get(newTypeArgs.toArray())
        case TypeKind.Struct =>
            let def = (oldType as StructType).getOrThrow().structDef
            return StructType.get(def, newTypeArgs.toArray())
        case TypeKind.ClassLike =>
            let def = (oldType as ClassLikeType).getOrThrow().classLikeDef
            return ClassLikeType.get(def, newTypeArgs.toArray())
        case TypeKind.Enum =>
            let def = (oldType as EnumType).getOrThrow().enumDef
            return EnumType.get(def, newTypeArgs.toArray())
        case TypeKind.Func =>
            let paramTypes = newTypeArgs[0..(newTypeArgs.size - 1)]
            let returnType = newTypeArgs.last.getOrThrow()
            let varArg = (oldType as FuncType).getOrThrow().hasVarArg
            let cFunc = (oldType as FuncType).getOrThrow().isCFunc
            return FuncType.get(paramTypes.toArray(), returnType, varArg: varArg, cFunc: cFunc)
        case TypeKind.Ref =>
            return RefType.get(newTypeArgs.first.getOrThrow())
        case TypeKind.Box =>
            return BoxType.get(newTypeArgs.first.getOrThrow())
        case TypeKind.CPointer =>
            return CPointerType.get(newTypeArgs.first.getOrThrow())
        case TypeKind.RawArray =>
            let elementType = newTypeArgs.first.getOrThrow()
            let dims = (oldType as RawArrayType).getOrThrow().dims
            return RawArrayType.get(elementType, dims)
        case TypeKind.`VArray` =>
            let elementType = newTypeArgs.first.getOrThrow()
            let size = (oldType as VArrayType).getOrThrow().size
            return VArrayType.get(elementType, size)
        case _ =>
            throw Exception(oldType.toString() + " doesn't have type args")
    }
}

internal func getAllInstantiatedParentTypes(cur: ClassLikeType, parentTypes: ArrayList<ClassLikeType>, visited: ArrayList<(Type, Type)>): Unit {
    if (parentTypes.contains(cur)) {
        return
    }
    parentTypes.add(cur)
    for (p in cur.getImplementedInterfaceTypes(visited: visited)) {
        getAllInstantiatedParentTypes(p, parentTypes, visited)
    }
    if (cur.hasSuperClassType()) {
        getAllInstantiatedParentTypes(cur.getSuperClassType(), parentTypes, visited)
    }
}

internal func assert(condition: Bool, message: String): Unit {
    if (!condition) {
        throw Exception(message)
    }
}