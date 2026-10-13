/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj

import std.collection.*
import std.fs.*
import stdx.chir.*

private func ruleRecordLocation(annotation: ResolvedAnnotation): (String, Int64, Int64) {
    let location = annotation.location
    if (!location.isValid()) { return ("", 0, 0) }
    // The wire location is diagnostic only; never publish an absolute source
    // path into a build artifact or use it as an input path later.
    return (location.filePath.fileName, location.start.line, location.start.column)
}

/** Collects all rule declarations, including unreferenced ones, without mutating CHIR. */
protected func collectRuleDeclarations(pkg: Package): Array<RuleWireRecord> {
    if (pkg.annotationMetadataVersion != 1) {
        throw IllegalArgumentException("annotation-metadata-unavailable: compiler capability 1 is required")
    }
    let records = ArrayList<RuleWireRecord>()
    for (def in pkg.allCustomTypeDefs) {
        // Imported declarations belong to their source package and have no
        // trustworthy local annotation snapshot to collect here.
        if (def.isImported()) { continue }
        let snapshot = def.annotationSnapshot
        if (!snapshot.isComplete) {
            throw IllegalArgumentException("annotation-metadata-unavailable: class ${def.srcCodeName}")
        }
        var found = false
        for (annotation in snapshot.items.getOrThrow()) {
            let kind = controlAnnotationKind(annotation)
            if (kind != Some("PointcutRule") && kind != Some("PointcutExpression")) { continue }
            if (found) {
                throw IllegalArgumentException("invalid-rule-carrier: multiple controls on ${def.srcCodeName}")
            }
            found = true
            if (!def.isClass() || def.isGeneric() || def.genericDecl.isSome() ||
                def.srcCodeName.isEmpty() || (def as ClassLikeDef).getOrThrow().isAnnotation) {
                throw IllegalArgumentException("invalid-rule-carrier: ${def.srcCodeName}")
            }
            let id = pkg.name + "." + def.srcCodeName
            let fields = readControlFields(annotation, kind.getOrThrow())
            let (sourceFile, line, column) = ruleRecordLocation(annotation)
            if (kind == Some("PointcutRule")) {
                let atom = atomFromControl(fields)
                records.add(RuleWireRecord("R", sourceFile, line, column, [id, atom.packageName, atom.className,
                    atom.methodName, atom.funcTypeStr, atom.targetKind, atom.recursive.toString(),
                    atom.annotationName]))
            } else {
                let scope = fields.string("packageScope")
                if (!isValidPackageNamePattern(scope)) {
                    throw IllegalArgumentException("invalid-rule-field: packageScope")
                }
                let program = parseRuleExpression(pkg.name, fields.string("expression"))
                let raw = ArrayList<String>([id, scope, program.size.toString()])
                for (token in program) { raw.add(token.operation) }
                records.add(RuleWireRecord("C", sourceFile, line, column, raw.toArray()))
            }
        }
    }
    return records.toArray()
}

private func isNewAdviceArrayAny(ty: Type): Bool {
    if (let Some(arrayType) <- (ty.stripAllRefs() as StructType)) {
        let args = arrayType.typeArgs
        return arrayType.structDef.packageName == "std.core" &&
            arrayType.structDef.srcCodeName == "Array" && args.size == 1 &&
            args[0].stripAllRefs().isAnyTypeInStd()
    }
    return false
}

private func checkNewAdviceSignature(f: Function): String {
    if (!f.isPublic() || !f.isExternalLinkage() || f.isForeign() || f.isAbstract() ||
        f.isGeneric() || (f.declaredParent.isSome() && f.declaredParent.getOrThrow().isGeneric()) ||
        (f.isMemberMethod() && !f.isStatic()) || f.funcType.returnType != UnitType.get()) {
        throw IllegalArgumentException("invalid-advice-signature: ${f.srcCodeName}")
    }
    let parameters = f.parameters
    if (parameters.isEmpty()) { return "none" }
    if (parameters.size == 1 && isNewAdviceArrayAny(parameters[0].ty)) { return "array-any" }
    throw IllegalArgumentException("invalid-advice-signature: ${f.srcCodeName} requires zero or Array<Any> parameters")
}

private func checkSourceGlobalVars(pkg: Package): Unit {
    for (gv in pkg.globalVars) {
        if (gv.isImported() || gv.isCompilerAdd()) { continue }
        if (!gv.ty.stripAllRefs().isPrimitiveType() || gv.initializer.isNone() ||
            !gv.initializer.getOrThrow().isLiteral()) {
            throw IllegalArgumentException("invalid-advice-global-variable: ${pkg.name}")
        }
    }
}

/** New A records are collected from resolved identities, not legacy short names. */
protected func collectRuleAdvices(pkg: Package): Array<RuleWireRecord> {
    if (pkg.annotationMetadataVersion != 1) {
        throw IllegalArgumentException("annotation-metadata-unavailable: compiler capability 1 is required")
    }
    let records = ArrayList<RuleWireRecord>()
    var checkedGlobals = false
    for (f in pkg.functions) {
        if (f.isImported() || f.isCompilerAdd()) { continue }
        let snapshot = f.annotationSnapshot
        if (!snapshot.isComplete) {
            throw IllegalArgumentException("annotation-metadata-unavailable: function ${f.srcCodeName}")
        }
        let controls = ArrayList<(String, ResolvedAnnotation)>()
        var oldCount: Int64 = 0
        for (annotation in snapshot.items.getOrThrow()) {
            if (let Some(kind) <- controlAnnotationKind(annotation)) {
                if (kind == "InsertAtEntryByRule" || kind == "InsertAtExitByRule") {
                    controls.add((kind, annotation))
                } else if (kind == "InsertAtEntry" || kind == "InsertAtExit" || kind == "ReplaceFuncBody") {
                    oldCount++
                }
            }
        }
        if (oldCount > 0 && !controls.isEmpty()) {
            throw IllegalArgumentException("invalid-advice-signature: old/new controls mixed on ${f.srcCodeName}")
        }
        if (controls.isEmpty()) { continue }
        if (!checkedGlobals) { checkSourceGlobalVars(pkg); checkedGlobals = true }
        let mode = checkNewAdviceSignature(f)
        var seenEntry = false
        var seenExit = false
        for ((kind, annotation) in controls) {
            let entry = kind == "InsertAtEntryByRule"
            if ((entry && seenEntry) || (!entry && seenExit)) {
                throw IllegalArgumentException("duplicate-advice: ${f.srcCodeName} ${kind}")
            }
            if (entry) { seenEntry = true } else { seenExit = true }
            let rule = readControlFields(annotation, kind).string("rule")
            let targetKind = if (f.isMemberMethod()) { "static" } else { "global" }
            let (sourceFile, line, column) = ruleRecordLocation(annotation)
            records.add(RuleWireRecord("A", sourceFile, line, column,
                [if (entry) { "ENTRY" } else { "EXIT" }, f.identifierWithoutPrefix, targetKind, mode, rule]))
        }
    }
    return records.toArray()
}

private func legacyOuterDef(f: Function): ?CustomTypeDef {
    if (let Some(parent) <- f.declaredParent) {
        if (let Some(extension) <- (parent as ExtendDef)) {
            if (let Some(custom) <- (extension.extendedType as CustomType)) { return Some(custom.def) }
            return None
        }
        return Some(parent)
    }
    return None
}

private func checkLegacyAdviceFunction(f: Function): Unit {
    if (!f.isPublic() || !f.isExternalLinkage() || f.isForeign() || f.isAbstract() ||
        f.isGeneric() || (legacyOuterDef(f).isSome() && legacyOuterDef(f).getOrThrow().isGeneric())) {
        throw IllegalArgumentException("invalid-advice-signature: legacy ${f.srcCodeName}")
    }
}

private func legacyUsesArgsArray(f: Function): Bool {
    var params = f.funcType.paramTypes
    if (f.isInstanceMemberMethod()) {
        if (params.isEmpty()) { return false }
        (_, params) = params.splitAt(1)
    }
    return params.size == 1 && isNewAdviceArrayAny(params[0])
}

private func checkLegacyTarget(f: Function, fields: RuleControlFields): Unit {
    let packageName = fields.string("packageName")
    let className = fields.string("className")
    let methodName = fields.string("methodName")
    let isStatic = fields.boolean("isStatic")
    let recursive = fields.boolean("recursive")
    if (!isValidPackageNamePattern(packageName) || !isValidMetadataPatternText(className) ||
        !isValidMetadataPatternText(methodName) || (className.isEmpty() && recursive)) {
        throw IllegalArgumentException("invalid-rule-field: legacy target ${f.srcCodeName}")
    }
    if (f.isInstanceMemberMethod()) {
        if (packageName.contains("*") || className.contains("*") || className.isEmpty() ||
            isStatic || f.packageName != packageName || getFuncOuterTypeName(f) != className) {
            throw IllegalArgumentException("invalid-advice-signature: legacy receiver ${f.srcCodeName}")
        }
    }
}

private func checkLegacyInsert(f: Function, fields: RuleControlFields, usesArray: Bool): Unit {
    let className = fields.string("className")
    let isStatic = fields.boolean("isStatic")
    let signature = fields.string("funcTypeStr")
    if (f.funcType.returnType != UnitType.get() || !isValidMetadataPatternText(signature) ||
        (signature.contains("*") && !usesArray)) {
        throw IllegalArgumentException("invalid-advice-signature: legacy Insert ${f.srcCodeName}")
    }
    if (!isValidFunctionTypePattern(signature)) {
        throw IllegalArgumentException("invalid-advice-signature: legacy Insert ${f.srcCodeName}")
    }
    if (usesArray) { return }
    var params = f.funcType.paramTypes
    if (f.isInstanceMemberMethod()) {
        if (params.isEmpty()) {
            throw IllegalArgumentException("invalid-advice-signature: legacy receiver ${f.srcCodeName}")
        }
        (_, params) = params.splitAt(1)
    } else if (!className.isEmpty() && !isStatic) {
        if (params.isEmpty()) {
            throw IllegalArgumentException("invalid-advice-signature: legacy receiver ${f.srcCodeName}")
        }
        let (receiverParams, explicitParams) = params.splitAt(1)
        if (let Some(custom) <- (receiverParams[0].stripAllRefs() as CustomType)) {
            if (custom.def.srcCodeName != className) {
                throw IllegalArgumentException("invalid-advice-signature: legacy receiver ${f.srcCodeName}")
            }
        } else {
            throw IllegalArgumentException("invalid-advice-signature: legacy receiver ${f.srcCodeName}")
        }
        params = explicitParams
    }
    if (params.isEmpty()) { return }
    let actual = FuncType.get(params, UnitType.get())
    let actualName = if (signature.contains("<")) { qualifiedNameWithTypeArgs(actual) } else {
        actual.qualifiedName
    }
    let configured = parseFunctionTypePattern(signature).getOrThrow()
    let matches = matchFunctionTypePattern(
        "(" + String.join(configured.parameters, delimiter: ",") + ")->Unit", actualName)
    if (!matches) { throw IllegalArgumentException("invalid-advice-signature: legacy types ${f.srcCodeName}") }
}

private func checkLegacyReplace(f: Function, fields: RuleControlFields): String {
    let params = f.parameters
    if (params.isEmpty()) {
        throw IllegalArgumentException("invalid-advice-signature: legacy Replace ${f.srcCodeName}")
    }
    let className = fields.string("className")
    let isStatic = fields.boolean("isStatic")
    let packageName = fields.string("packageName")
    if (!className.isEmpty() && !isStatic &&
        params[0].ty.qualifiedName != "${packageName}.${className}") {
        throw IllegalArgumentException("invalid-advice-signature: legacy Replace receiver ${f.srcCodeName}")
    }
    let lastType = params[params.size - 1].ty
    if (let Some(wovenType) <- (lastType as FuncType)) {
        if (wovenType.returnType != f.funcType.returnType) {
            throw IllegalArgumentException("invalid-advice-signature: legacy Replace return ${f.srcCodeName}")
        }
        var (aspectParams, _) = params.splitAt(params.size - 1)
        if (f.isInstanceMemberMethod()) {
            if (aspectParams.isEmpty()) {
                throw IllegalArgumentException("invalid-advice-signature: legacy Replace receiver ${f.srcCodeName}")
            }
            (_, aspectParams) = aspectParams.splitAt(1)
        }
        let aspectTypes = mapArrayTo(aspectParams, {parameter => parameter.ty})
        if (!aspectTypes.isEmpty() &&
            FuncType.get(aspectTypes, f.funcType.returnType).toString() != lastType.toString()) {
            throw IllegalArgumentException("invalid-advice-signature: legacy Replace types ${f.srcCodeName}")
        }
        return replacementPointcutType(f, !className.isEmpty() && !isStatic).qualifiedName
    }
    throw IllegalArgumentException("invalid-advice-signature: legacy Replace function parameter ${f.srcCodeName}")
}

/** Old controls are read by resolved identity and named scalar fields in v4. */
protected func collectLegacyAdvices(pkg: Package): Array<RuleWireRecord> {
    if (pkg.annotationMetadataVersion != 1) {
        throw IllegalArgumentException("annotation-metadata-unavailable: compiler capability 1 is required")
    }
    let records = ArrayList<RuleWireRecord>()
    var checkedGlobals = false
    for (f in pkg.functions) {
        if (f.isImported() || f.isCompilerAdd()) { continue }
        let snapshot = f.annotationSnapshot
        if (!snapshot.isComplete) {
            throw IllegalArgumentException("annotation-metadata-unavailable: function ${f.srcCodeName}")
        }
        var hasInsert = false
        var hasReplace = false
        for (annotation in snapshot.items.getOrThrow()) {
            if (let Some(kind) <- controlAnnotationKind(annotation)) {
                if (kind != "InsertAtEntry" && kind != "InsertAtExit" && kind != "ReplaceFuncBody") {
                    continue
                }
                hasInsert ||= kind != "ReplaceFuncBody"
                hasReplace ||= kind == "ReplaceFuncBody"
                if (hasInsert && hasReplace) {
                    throw IllegalArgumentException("invalid-advice-signature: old Insert and Replace mixed on ${f.srcCodeName}")
                }
                if (!checkedGlobals) { checkSourceGlobalVars(pkg); checkedGlobals = true }
                checkLegacyAdviceFunction(f)
                let fields = readControlFields(annotation, kind)
                checkLegacyTarget(f, fields)
                let usesArray = legacyUsesArgsArray(f)
                let signature = if (kind == "ReplaceFuncBody") { checkLegacyReplace(f, fields) } else {
                    checkLegacyInsert(f, fields, usesArray)
                    fields.string("funcTypeStr")
                }
                let (sourceFile, line, column) = ruleRecordLocation(annotation)
                records.add(RuleWireRecord("L", sourceFile, line, column,
                    [kind, pkg.name, f.identifierWithoutPrefix, f.parameters.size.toString(),
                        f.isMemberMethod().toString(), f.isStatic().toString(), usesArray.toString(),
                        fields.string("packageName"), fields.string("className"), fields.string("methodName"),
                        signature, fields.boolean("isStatic").toString(),
                        fields.boolean("recursive").toString()]))
            }
        }
    }
    return records.toArray()
}

/** Build a fully validated in-memory candidate. Publication remains the driver's job. */
protected func collectRuleWirePackage(pkg: Package, sessionId: String,
    sourceActionKey: String, toolchainAbiKey: String): RuleWirePackage {
    let records = ArrayList<RuleWireRecord>()
    for (record in collectRuleDeclarations(pkg)) { records.add(record) }
    for (record in collectRuleAdvices(pkg)) { records.add(record) }
    for (record in collectLegacyAdvices(pkg)) { records.add(record) }
    var hasAdvice = false
    for (record in records) { if (record.kind == "A" || record.kind == "L") { hasAdvice = true; break } }
    let initSymbol = if (hasAdvice) {
        pkg.packageInitFunc.getOrThrow({ =>
            IllegalArgumentException("invalid-advice-source: missing package initializer ${pkg.name}")
        }).identifierWithoutPrefix
    } else { "" }
    let wire = RuleWirePackage("READY", sessionId, pkg.name, sourceActionKey,
        toolchainAbiKey, initSymbol, records.toArray())
    validateWirePackage(wire)
    return wire
}
