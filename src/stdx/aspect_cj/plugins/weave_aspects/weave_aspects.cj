/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj.plugins.weave_aspects

import std.collection.*
import std.convert.*
import std.fs.*
import std.io.*
import stdx.aspect_cj.*
import stdx.chir.*
import stdx.plugin.*

private class MetadataReadState {
    var success: Bool = true
    var records: Int64 = 0
    var bytes: Int64 = 0
}

@CHIRPlugin
class WeaveAspects {
    var processInfos = ArrayList<OutputInfo>()
    var pkgInitFuncMangledNames = HashMap<String, String>()
    var workBudget = RuleWorkBudget()

    public override func run(pkg: Package): Bool {
        try {
            processInfos.clear()
            pkgInitFuncMangledNames.clear()
            workBudget = RuleWorkBudget()
            return weavePackage(pkg)
        } catch (error: Exception) {
            printError("aspect_cj ${pkg.name} legacy weave failed: ${error.message}")
            return false
        }
    }

    private func weavePackage(pkg: Package): Bool {
        if (!readAnnoInfo(pkg.name)) {
            return false
        }
        callUpstreamPkgInitFunc(pkg)
        for (f in pkg.functions) {
            if (f.body.isNone()) {
                continue
            }
            for (pi in processInfos) {
                if (!meets(f, pi)) {
                    continue
                }
                if (!weaveFuncBody(pkg, f, pi)) {
                    return false
                }
            }
        }
        return true
    }

    private func weaveFuncBody(pkg: Package, f: Function, pi: OutputInfo): Bool {
        let (args, success) = prepareArguments(pkg, f, pi)
        if (!success) {
            return false
        }
        let callee = getCallee(pkg, pi, f, args)
        let funcCallCxt = FuncCallContext(args, Array<Type>(), computeThisTypeOfCallee(callee, args))
        if (pi.annoClassName == INSERT_AT_ENTRY_ANNO_CLASS_NAME) {
            var insertPosition = InsertPosition.AtStart(f.body.getOrThrow().entryBlock)
            if (pi.insert.usesPointcutArgsArray) {
                if (args.isEmpty()) {
                    throw IllegalArgumentException("invalid-advice-arguments: missing Array<Any> snapshot")
                }
                if (let Some(snapshot) <- (args[args.size - 1] as LocalVar)) {
                    insertPosition = InsertPosition.After(snapshot.expr)
                } else {
                    throw IllegalArgumentException("invalid-advice-arguments: invalid Array<Any> snapshot")
                }
            }
            let builder = CHIRBuilder(insertPosition)
            builder.createApply(callee, funcCallCxt)
        } else if (pi.annoClassName == INSERT_AT_EXIT_ANNO_CLASS_NAME) {
            let visitor = InsertAtExitVisitor(callee, funcCallCxt)
            visitor.walk(f.body.getOrThrow())
        } else if (isReplaceBodyAnno(pi.annoClassName)) {
            weaveReplacementBody(pkg, f, callee)
        } else {
            printError("Unknown annotation class name '${pi.annoClassName}'.")
            return false
        }
        return true
    }


    private func computeThisTypeOfCallee(callee: Function, args: Array<Value>): ?Type {
        if (callee.isMemberMethod()) {
            if (callee.isStatic()) {
                return addRefIfFuncIsMutOrClass(callee.outerType.getOrThrow(), callee)
            }
            return args[0].ty
        }
        return None
    }

    private func getCallee(pkg: Package, pi: OutputInfo, f: Function, args: Array<Value>): Function {
        if (let Some(v) <- pkg.getSpecifiedFunction(pi.insert.methodMangledName)) {
            return v
        }
        let paramTypes = mapArrayTo(args, {arg => arg.ty})
        var returnType: Type = UnitType.get()
        if (isReplaceBodyAnno(pi.annoClassName)) {
            // Imported advice also takes a bound callback without the receiver.
            // The temporary target value in args still has the raw CHIR type.
            paramTypes[paramTypes.size - 1] = f.funcSrcCodeType
            returnType = f.funcType.returnType
        }
        let funcType = FuncType.get(paramTypes, returnType)
        let callee = pkg.addFunction(funcType, pi.insert.methodMangledName, "", pi.insert.packageName)
        callee.setImported(true)
        return callee
    }

    private func printError(message: String): Unit {
        println(message)
    }

    private func readRequiredMetadataLine<T>(reader: StringReader<T>, fieldName: String, fileName: String): String
        where T <: InputStream {
        if (let Some(value) <- readMetadataLine(reader)) {
            return value
        }
        printError("Missing `${fieldName}` in aspect metadata `${fileName}`.")
        throw IllegalArgumentException("Missing aspect metadata field: ${fieldName}")
    }

    private func readMetadataLine<T>(reader: StringReader<T>): ?String where T <: InputStream {
        let line = reader.readln()
        if (let Some(value) <- line) {
            if (value.size > RULE_WIRE_FIELD_LIMIT) {
                throw IllegalArgumentException("metadata-format: field size limit")
            }
        }
        return line
    }

    private func prepareArguments(pkg: Package, f: Function, pi: OutputInfo): (Array<Value>, Bool) {
        if (pi.insert.usesPointcutArgsArray) {
            return preparePointcutArgsArray(pkg, f, pi)
        }
        var expectedParamsNum = pi.insert.paramsNum
        if (isReplaceBodyAnno(pi.annoClassName)) {
            expectedParamsNum -= 1
        }
        let args = ArrayList<Value>()
        if (expectedParamsNum != 0) {
            if (f.parameters.size != expectedParamsNum) {
                printError("Parameter count mismatch: target function '${f.srcCodeName}' has '${f.parameters.size}' parameters, expected '${expectedParamsNum}' parameters from aspect metadata '${pi.insert.methodMangledName}'.")
                return (Array<Value>(), false)
            }
            for (param in f.parameters) {
                args.add(param)
            }
        }
        if (isReplaceBodyAnno(pi.annoClassName)) {
            args.add(f)
        }
        return (args.toArray(), true)
    }

    private func preparePointcutArgsArray(pkg: Package, f: Function, pi: OutputInfo): (Array<Value>, Bool) {
        let anyDef = pkg.getSpecifiedClassDef("std.core", "Any")
        let arrayDef = pkg.getSpecifiedStructDef("std.core", "Array")
        if (anyDef.isNone() || arrayDef.isNone()) {
            printError("Failed to prepare Array<Any> for ${f.srcCodeName}: required std.core definitions are unavailable.")
            return (Array<Value>(), false)
        }
        let anyType = RefType.get(anyDef.getOrThrow().ty)
        let arrayType = StructType.get(arrayDef.getOrThrow(), [anyType])
        let entry = f.body.getOrThrow().entryBlock
        let builder = CHIRBuilder(InsertPosition.AtStart(entry))
        var params = f.parameters
        if (f.isInstanceMemberMethod()) {
            (_, params) = params.splitAt(1)
        }

        let size = builder.createConstant(IntLiteral.get(IntType.getInt64(), UInt64(params.size)))
        let rawArray = builder.createRawArrayAllocate(anyType, size.result)
        var index: UInt64 = 0
        for (param in params) {
            var element: Value = param
            let sourceType = param.ty
            var sourceIsValueType = sourceType.isValueType()
            if (let Some(refType) <- (sourceType as RefType)) {
                sourceIsValueType = refType.baseType.isValueType()
            }
            if (sourceIsValueType) {
                if (sourceType.isRefType()) {
                    element = builder.createLoad(param).result
                }
                element = builder.createBox(element, anyType).result
            }
            builder.createStoreElementRef(element, rawArray.result, ArrayList<UInt64>([index]))
            index++
        }

        let arrayRef = builder.createAllocate(arrayType)
        let zero = builder.createConstant(IntLiteral.get(IntType.getInt64(), 0))
        var arrayInit: ?Function = None
        for (method in arrayDef.getOrThrow().methods) {
            if (method.srcCodeName == "init" && method.parameters.size == 4) {
                arrayInit = Some(method)
                break
            }
        }
        if (arrayInit.isNone()) {
            printError("Failed to prepare Array<Any> for ${f.srcCodeName}: Array constructor is unavailable.")
            return (Array<Value>(), false)
        }
        let arrayRefType = arrayRef.result.ty
        let initContext = FuncCallContext(
            [arrayRef.result, rawArray.result, zero.result, size.result],
            Array<Type>(),
            Some(arrayRefType))
        builder.createApply(arrayInit.getOrThrow(), initContext)
        let arrayValue = builder.createLoad(arrayRef.result).result

        let args = ArrayList<Value>()
        if (pi.insert.isMemberFunc && !pi.insert.isStatic) {
            if (!f.isInstanceMemberMethod()) {
                printError("Do not weave ${pi.insert.methodMangledName}, which is an instance advice, into a global or static function.")
                return (Array<Value>(), false)
            }
            args.add(f.parameters[0])
        }
        args.add(arrayValue)
        return (args.toArray(), true)
    }

    private func callUpstreamPkgInitFunc(pkg: Package): Unit {
        let curPkgInitFunc = pkg.packageInitFunc.getOrThrow()
        let bb = curPkgInitFunc.body.getOrThrow().entryBlock
        let builder = CHIRBuilder(InsertPosition.AtStart(bb))
        for ((pkgName, initFuncMangledName) in pkgInitFuncMangledNames) {
            if (pkgName == pkg.name) {
                continue
            }
            // Reuse an existing declaration when present (e.g. target already imported the
            // aspect package) to avoid duplicated CHIR identifiers. Always emit the apply:
            // presence of the symbol does not guarantee the current package init already
            // calls it (indirect import / opt / DCE). Package inits are expected to be
            // idempotent, so an extra apply is safe.
            let importedInitFunc = if (let Some(existing) <- pkg.getSpecifiedFunction(initFuncMangledName)) {
                existing
            } else {
                let funcType = FuncType.get(Array<Type>(), UnitType.get())
                let added = pkg.addFunction(funcType, initFuncMangledName, "", pkgName)
                added.setImported(true)
                added
            }
            let funcCallCxt = FuncCallContext(Array<Value>(), Array<Type>(), None)
            builder.createApply(importedInitFunc, funcCallCxt)
        }
    }

    private func meets(f: Function, pi: OutputInfo): Bool {
        if (!matchQualifiedNamePatternBudgeted(pi.to.packageName, f.packageName, workBudget)) {
            return false
        }
        if (!outerTypeNameMeets(f, pi)) {
            return false
        }
        if (!matchNamePatternBudgeted(pi.to.methodName, f.srcCodeName, workBudget)) {
            return false
        }
        if (pi.to.isStatic != f.isStatic()) {
            return false
        }
        var params = f.parameters
        if (f.isInstanceMemberMethod()) {
            (_, params) = params.splitAt(1)
        }
        let paramTypes = mapArrayTo(params, {param => param.ty})
        let funcType = FuncType.get(paramTypes, f.funcType.returnType)
        let funcTypeStr = if (pi.to.funcTypeStr.contains("<")) {
            qualifiedNameWithTypeArgs(funcType)
        } else {
            funcType.qualifiedName
        }
        if (!matchFunctionTypePatternBudgeted(pi.to.funcTypeStr, funcTypeStr, workBudget)) {
            return false
        }
        return true
    }

    private func outerTypeNameMeets(f: Function, pi: OutputInfo): Bool {
        if (matchNamePatternBudgeted(pi.to.className, getFuncOuterTypeName(f), workBudget)) {
            return true
        }
        if (let Some(outerType) <- f.outerType && pi.to.recursively) {
            let superTypes: Array<ClassLikeType>
            if (let Some(bt) <- (outerType as BuiltinType)) {
                superTypes = bt.getSuperTypesRecusively()
            } else if (let Some(ct) <- (outerType as CustomType)) {
                superTypes = ct.getSuperTypesRecusively()
            } else {
                return false
            }
            for (superType in superTypes) {
                if (matchNamePatternBudgeted(pi.to.className, superType.def.srcCodeName, workBudget)) {
                    return true
                }
            }
        }
        return false
    }

    private func readAnnoInfo(curPkgName: String): Bool {
        let state = MetadataReadState()
        Directory.walk(
            Path("."),
            {
                fileInfo =>
                let fileName = fileInfo.name
                let exactSuffix = PACKAGE_NAME_CONNECTOR + curPkgName + ANNO_INFO_FILE_SUFFIX
                let wildcardSuffix = PACKAGE_NAME_CONNECTOR + WILDCARD_ANNO_INFO_TARGET + ANNO_INFO_FILE_SUFFIX
                if (!fileName.endsWith(exactSuffix) && !fileName.endsWith(wildcardSuffix)) {
                    return true
                }
                try {
                    let bytes = readBoundedAspectMetadata(Path(fileName))
                    if (bytes.size > RULE_WIRE_FILE_LIMIT - state.bytes) {
                        throw IllegalArgumentException("metadata-format: aggregate file size limit")
                    }
                    state.bytes += bytes.size
                    let buffer = ByteBuffer()
                    buffer.write(bytes)
                    let reader = StringReader(buffer)
                    let firstLine = readMetadataLine(reader)
                    if (firstLine.isNone()) {
                        printError("Empty aspect metadata `${fileName}`.")
                        state.success = false
                        return false
                    }
                    let firstValue = firstLine.getOrThrow()
                    let isVersion2 = firstValue == ANNO_INFO_VERSION_HEADER
                    if (firstValue.startsWith("#aspect_cj_annoinfo_") && !isVersion2) {
                        printError("Unsupported aspect metadata version `${firstValue}` in `${fileName}`.")
                        state.success = false
                        return false
                    }
                    var pendingPkgName: ?String = if (isVersion2) {
                        readMetadataLine(reader)
                    } else {
                        Some(firstValue)
                    }
                    if (isVersion2 && pendingPkgName.isNone()) {
                        printError("Missing aspect record in metadata `${fileName}`.")
                        state.success = false
                        return false
                    }
                    while (let Some(pkgName) <- pendingPkgName) {
                        if (state.records >= RULE_WIRE_RECORD_LIMIT) {
                            throw IllegalArgumentException("metadata-format: record limit")
                        }
                        state.records++
                        // Package init function mangled name
                        let initFuncMangledName = readRequiredMetadataLine(reader, "initFuncMangledName", fileName)
                        // Anno class name
                        let annoClassName = readRequiredMetadataLine(reader, "annoClassName", fileName)
                        // Insert
                        let inPackageName = readRequiredMetadataLine(reader, "insertPackageName", fileName)
                        let methodMangledName = readRequiredMetadataLine(reader, "methodMangledName", fileName)
                        let paramsNumText = readRequiredMetadataLine(reader, "paramsNum", fileName)
                        let paramsNum = Int64.parse(paramsNumText)
                        if (paramsNum < 0) {
                            printError("Invalid `paramsNum` value `${paramsNumText}` in aspect metadata `${fileName}`.")
                            throw IllegalArgumentException("Negative aspect metadata parameter count")
                        }
                        let isMemberFunc = Bool.parse(readRequiredMetadataLine(reader, "isMemberFunc", fileName))
                        let inIsStatic = Bool.parse(readRequiredMetadataLine(reader, "insertIsStatic", fileName))
                        let usesPointcutArgsArray = if (isVersion2) {
                            Bool.parse(readRequiredMetadataLine(reader, "usesPointcutArgsArray", fileName))
                        } else {
                            false
                        }
                        let insert = Insert(inPackageName, methodMangledName, paramsNum,
                            isMemberFunc, inIsStatic, usesPointcutArgsArray: usesPointcutArgsArray)
                        // To
                        let toPackageName = readRequiredMetadataLine(reader, "packageName", fileName)
                        let className = readRequiredMetadataLine(reader, "className", fileName)
                        let methodName = readRequiredMetadataLine(reader, "methodName", fileName)
                        let funcTypeStr = readRequiredMetadataLine(reader, "funcTypeStr", fileName)
                        let toIsStatic = Bool.parse(readRequiredMetadataLine(reader, "isStatic", fileName))
                        let recursively = Bool.parse(readRequiredMetadataLine(reader, "recursive", fileName))
                        let to = To(toPackageName, className, methodName, funcTypeStr, toIsStatic, recursively)
                        // A wildcard-indexed file can also contain an exact package name
                        // equal to the reserved index. Do not import an unrelated advice
                        // package's initializer into the current package.
                        if (matchQualifiedNamePatternBudgeted(toPackageName, curPkgName, workBudget)) {
                            pkgInitFuncMangledNames.add(pkgName, initFuncMangledName)
                            processInfos.add(OutputInfo(annoClassName, insert, to))
                        }
                        pendingPkgName = readMetadataLine(reader)
                    }
                } catch (e: Exception) {
                    printError("Invalid aspect metadata `${fileName}`: ${e.message}")
                    state.success = false
                    return false
                }
                return true
            }
        )
        return state.success
    }
}

internal class InsertAtExitVisitor <: CHIRVisitor {
    let callee: Function
    let funcCallCxt: FuncCallContext
    public init(callee: Function, funcCallCxt: FuncCallContext) {
        this.callee = callee
        this.funcCallCxt = funcCallCxt
    }
    public override func action(e: Expression): IRActionMode {
        if (e.isLambda()) {
            return IRActionMode.Skip
        }
        if (e.isExit()) {
            let builder = CHIRBuilder(InsertPosition.Before(e))
            builder.createApply(callee, funcCallCxt)
        }
        return IRActionMode.Continue
    }
}
