/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj

import std.collection.*
import stdx.chir.*

protected struct RulePlannedCall {
    let record: RuleWireRecord
    let callee: Function
    let sourcePackage: String
    public init(record: RuleWireRecord, callee: Function, sourcePackage: String) {
        this.record = record
        this.callee = callee
        this.sourcePackage = sourcePackage
    }
}

protected struct RuleTargetPlan {
    let target: Function
    let calls: Array<RulePlannedCall>
    public init(target: Function, calls: Array<RulePlannedCall>) {
        this.target = target
        this.calls = calls
    }
}

protected class RuleMatchStatistics {
    var preparedSources: Int64 = 0
    var evaluatedTargets: Int64 = 0
    var workUnits: Int64 = 0
}

private func legacyParameterMatches(target: Function, call: RulePlannedCall, index: Int64): Bool {
    let actual = target.parameters[index].ty
    let expected = call.callee.parameters[index].ty
    if (qualifiedNameWithTypeArgs(actual) == qualifiedNameWithTypeArgs(expected)) { return true }
    if (index != 0 || !target.isInstanceMemberMethod()) { return false }
    if (actual.stripAllRefs() == expected.stripAllRefs()) { return true }
    if (call.record.fields[0] != REPLACE_FUNC_BODY_ANNO_CLASS_NAME) { return false }
    return canUpcastReplacementReceiver(actual, expected)
}

private func isRuleTarget(f: Function): Bool {
    if (!f.isAspectExecutableSourceBody() || f.srcCodeName == "main") { return false }
    let snapshot = f.annotationSnapshot
    if (!snapshot.isComplete) { throw IllegalArgumentException("annotation-metadata-unavailable: ${f.srcCodeName}") }
    for (annotation in snapshot.items.getOrThrow()) {
        if (let Some(kind) <- controlAnnotationKind(annotation)) {
            if (kind == "InsertAtEntryByRule" || kind == "InsertAtExitByRule" ||
                kind == "InsertAtEntry" || kind == "InsertAtExit" || kind == "ReplaceFuncBody") {
                return false
            }
        }
    }
    return true
}

private func needsSnapshot(call: RulePlannedCall): Bool {
    match (call.record.kind) {
        case "A" => return call.record.fields[3] == "array-any"
        case "L" => return call.record.fields[6] == "true"
        case _ => return false
    }
}

private func isActualArrayAny(ty: Type): Bool {
    if (let Some(arrayType) <- (ty.stripAllRefs() as StructType)) {
        let typeArgs = arrayType.typeArgs
        return arrayType.structDef.packageName == "std.core" &&
            arrayType.structDef.srcCodeName == "Array" && typeArgs.size == 1 &&
            typeArgs[0].stripAllRefs().isAnyTypeInStd()
    }
    return false
}

private func checkActualAdvice(call: RulePlannedCall): Unit {
    let callee = call.callee
    let record = call.record
    if (callee.packageName != call.sourcePackage || !callee.isPublic() || !callee.isExternalLinkage()) {
        throw IllegalArgumentException("invalid exported advice: ${callee.identifierWithoutPrefix}")
    }
    if (record.kind == "A") {
        let fields = record.fields
        if (callee.funcType.returnType != UnitType.get() ||
            (fields[2] == "global" && callee.isMemberMethod()) ||
            (fields[2] == "static" && !callee.isStaticMemberMethod())) {
            throw IllegalArgumentException("invalid A export: ${callee.identifierWithoutPrefix}")
        }
        let params = callee.parameters
        if ((fields[3] == "none" && !params.isEmpty()) ||
            (fields[3] == "array-any" &&
                (params.size != 1 || !isActualArrayAny(params[0].ty)))) {
            throw IllegalArgumentException("invalid A export signature: ${callee.identifierWithoutPrefix}")
        }
    } else if (record.kind == "L") {
        let fields = record.fields
        if (callee.parameters.size.toString() != fields[3] ||
            callee.isMemberMethod().toString() != fields[4] ||
            callee.isStatic().toString() != fields[5]) {
            throw IllegalArgumentException("invalid L export signature: ${callee.identifierWithoutPrefix}")
        }
        if (fields[0] != REPLACE_FUNC_BODY_ANNO_CLASS_NAME &&
            callee.funcType.returnType != UnitType.get()) {
            throw IllegalArgumentException("invalid L Insert return: ${callee.identifierWithoutPrefix}")
        }
        if (fields[6] == "true") {
            let params = callee.parameters
            if (params.isEmpty() || !isActualArrayAny(params[params.size - 1].ty)) {
                throw IllegalArgumentException("invalid L Array<Any> export: ${callee.identifierWithoutPrefix}")
            }
        }
    }
}

private func validateSnapshotTypes(pkg: Package): Unit {
    let anyDef = pkg.getSpecifiedClassDef("std.core", "Any")
    let arrayDef = pkg.getSpecifiedStructDef("std.core", "Array")
    if (anyDef.isNone() || arrayDef.isNone()) {
        throw IllegalArgumentException("missing std.core.Array/Any declaration")
    }
    var hasConstructor = false
    for (method in arrayDef.getOrThrow().methods) {
        if (method.srcCodeName == "init" && method.parameters.size == 4) { hasConstructor = true; break }
    }
    if (!hasConstructor) { throw IllegalArgumentException("missing std.core.Array constructor") }
}

/** Select source packages without importing advice symbols or changing target CHIR. */
protected func preselectRuleSources(pkg: Package, wires: Array<RuleWirePackage>): Array<String> {
    if (pkg.annotationMetadataVersion != 1) {
        throw IllegalArgumentException("annotation-metadata-unavailable: target package ${pkg.name}")
    }
    if (pkg.aspectWeaveState != 0 || pkg.aspectWeavePlanDigest != "") {
        throw IllegalArgumentException("already-woven: target package ${pkg.name}")
    }
    let sources = prepareRuleSourceSet(wires)
    let selectedSources = HashSet<String>()
    let budget = RuleWorkBudget()
    let instantiatedOrigins = HashSet<String>()
    for (f in pkg.functions) {
        if (!f.isImported() && !f.aspectSourceOrigin.isEmpty() && f.body.isSome()) {
            instantiatedOrigins.add(f.aspectSourceOrigin)
        }
    }
    for (f in pkg.functions) {
        if (f.isGeneric() && instantiatedOrigins.contains(f.identifierWithoutPrefix)) { continue }
        if (!isRuleTarget(f)) { continue }
        let target = ruleTargetFromFunction(f)
        for (selection in selectPreparedRuleAdvicesAcrossSources(sources, target, true, budget)) {
            selectedSources.add(selection.sourcePackage)
        }
    }
    let ordered = ArrayList<String>()
    for (wire in wires) {
        if (selectedSources.contains(wire.sourcePackage)) { ordered.add(wire.sourcePackage) }
    }
    return ordered.toArray()
}

/** Freeze and check every selected call before any target CHIR is changed. */
protected func preflightRuleWeave(pkg: Package, wires: Array<RuleWirePackage>,
    statistics!: ?RuleMatchStatistics = None): Array<RuleTargetPlan> {
    if (pkg.annotationMetadataVersion != 1) {
        throw IllegalArgumentException("annotation-metadata-unavailable: target package ${pkg.name}")
    }
    if (pkg.aspectWeaveState != 0 || pkg.aspectWeavePlanDigest != "") {
        throw IllegalArgumentException("already-woven: target package ${pkg.name}")
    }
    let sources = prepareRuleSourceSet(wires)
    if (let Some(stats) <- statistics) { stats.preparedSources = sources.size }
    let plans = ArrayList<RuleTargetPlan>()
    let budget = RuleWorkBudget()
    var total: Int64 = 0
    let instantiatedOrigins = HashSet<String>()
    for (f in pkg.functions) {
        if (!f.isImported() && !f.aspectSourceOrigin.isEmpty() && f.body.isSome()) {
            instantiatedOrigins.add(f.aspectSourceOrigin)
        }
    }
    for (f in pkg.functions) {
        if (f.isGeneric() && instantiatedOrigins.contains(f.identifierWithoutPrefix)) { continue }
        if (!isRuleTarget(f)) { continue }
        let target = ruleTargetFromFunction(f)
        if (let Some(stats) <- statistics) { stats.evaluatedTargets++ }
        let selected = selectPreparedRuleAdvicesAcrossSources(sources, target, true, budget)
        if (selected.isEmpty()) { continue }
        let calls = ArrayList<RulePlannedCall>()
        for (selection in selected) {
            let record = selection.record
            if (total >= 262144) { throw IllegalArgumentException("rule-limit: target package plan") }
            total++
            let fields = record.fields
            let symbol = if (record.kind == "A") { fields[1] } else { fields[2] }
            let callee = pkg.getSpecifiedFunction(symbol).getOrThrow({ =>
                IllegalArgumentException("unresolved advice symbol: ${symbol}")
            })
            if (callee.packageName != selection.sourcePackage ||
                (callee.body.isNone() && !callee.isImported())) {
                throw IllegalArgumentException("invalid advice symbol: ${symbol}")
            }
            let call = RulePlannedCall(record, callee, selection.sourcePackage)
            checkActualAdvice(call)
            if (needsSnapshot(call)) { validateSnapshotTypes(pkg) }
            if (record.kind == "L" && fields[6] != "true") {
                let expected = if (fields[0] == REPLACE_FUNC_BODY_ANNO_CLASS_NAME) {
                    call.callee.parameters.size - 1
                } else { call.callee.parameters.size }
                if (expected != 0 && f.parameters.size != expected) {
                    throw IllegalArgumentException("legacy typed parameter count mismatch: ${symbol}")
                }
                if (fields[0] == REPLACE_FUNC_BODY_ANNO_CLASS_NAME &&
                    call.callee.funcType.returnType != f.funcType.returnType) {
                    throw IllegalArgumentException("legacy Replace return mismatch: ${symbol}")
                }
                if (expected > 0) {
                    for (index in 0..expected) {
                        if (!legacyParameterMatches(f, call, index)) {
                            throw IllegalArgumentException("legacy typed parameter mismatch: ${symbol}")
                        }
                    }
                }
                if (fields[0] == REPLACE_FUNC_BODY_ANNO_CLASS_NAME) {
                    let originalType = call.callee.parameters[call.callee.parameters.size - 1].ty
                    if (let Some(functionType) <- (originalType as FuncType)) {
                        if (!replacementCallbackMatches(f, functionType)) {
                            throw IllegalArgumentException("legacy Replace original mismatch: ${symbol}")
                        }
                    } else { throw IllegalArgumentException("legacy Replace original is not function: ${symbol}") }
                }
            }
            calls.add(call)
        }
        plans.add(RuleTargetPlan(f, calls.toArray()))
    }
    // All source initializers must be verified during preflight, not discovered
    // after inserting the first target call.
    if (!plans.isEmpty()) {
        let targetInit = pkg.packageInitFunc.getOrThrow({ =>
            IllegalArgumentException("missing target package init: ${pkg.name}")
        })
        if (targetInit.body.isNone()) {
            throw IllegalArgumentException("missing target package init body: ${pkg.name}")
        }
        for (wire in wires) {
            if (wire.sourcePackage == pkg.name) { continue }
            var used = false
            for (plan in plans) {
                for (call in plan.calls) {
                    if (call.sourcePackage == wire.sourcePackage) { used = true; break }
                }
                if (used) { break }
            }
            if (!used) { continue }
            let sourceInit = pkg.getSpecifiedFunction(wire.initSymbol).getOrThrow({ =>
                IllegalArgumentException("unresolved source package init: ${wire.sourcePackage}")
            })
            if (sourceInit.packageName != wire.sourcePackage || !sourceInit.parameters.isEmpty() ||
                sourceInit.funcType.returnType != UnitType.get()) {
                throw IllegalArgumentException("invalid source package init: ${wire.sourcePackage}")
            }
        }
    }
    if (let Some(stats) <- statistics) { stats.workUnits = budget.used }
    return plans.toArray()
}

private func snapshotArgs(pkg: Package, target: Function, anchor: ?Expression): (Value, Expression) {
    let anyDef = pkg.getSpecifiedClassDef("std.core", "Any").getOrThrow()
    let arrayDef = pkg.getSpecifiedStructDef("std.core", "Array").getOrThrow()
    let anyType = RefType.get(anyDef.ty)
    let arrayType = StructType.get(arrayDef, [anyType])
    let position = if (let Some(previous) <- anchor) { InsertPosition.After(previous) } else {
        InsertPosition.AtStart(target.body.getOrThrow().entryBlock)
    }
    let builder = CHIRBuilder(position)
    var params = target.parameters
    if (target.isInstanceMemberMethod()) { (_, params) = params.splitAt(1) }
    let count = builder.createConstant(IntLiteral.get(IntType.getInt64(), UInt64(params.size)))
    let raw = builder.createRawArrayAllocate(anyType, count.result)
    var index: UInt64 = 0
    for (param in params) {
        var item: Value = param
        let ty = param.ty
        var isValue = ty.isValueType() || ty.isGenericType()
        if (let Some(refType) <- (ty as RefType)) {
            isValue = refType.baseType.isValueType() || refType.baseType.isGenericType()
        }
        if (isValue) {
            if (ty.isRefType()) { item = builder.createLoad(param).result }
            item = builder.createBox(item, anyType).result
        }
        builder.createStoreElementRef(item, raw.result, ArrayList<UInt64>([index]))
        index++
    }
    let arrayRef = builder.createAllocate(arrayType)
    let zero = builder.createConstant(IntLiteral.get(IntType.getInt64(), 0))
    var constructor: ?Function = None
    for (method in arrayDef.methods) {
        if (method.srcCodeName == "init" && method.parameters.size == 4) {
            constructor = Some(method)
            break
        }
    }
    builder.createApply(constructor.getOrThrow(), FuncCallContext(
        [arrayRef.result, raw.result, zero.result, count.result], Array<Type>(), Some(arrayRef.result.ty)))
    let loaded = builder.createLoad(arrayRef.result)
    return (loaded.result, loaded)
}

private func callArgs(target: Function, call: RulePlannedCall, snapshot: ?Value): Array<Value> {
    if (needsSnapshot(call)) {
        let args = ArrayList<Value>()
        if (call.record.kind == "L") {
            let fields = call.record.fields
            let needsReceiver = fields[4] == "true" && fields[5] == "false"
            if (needsReceiver) { args.add(target.parameters[0]) }
        }
        args.add(snapshot.getOrThrow())
        return args.toArray()
    }
    if (call.record.kind == "A") { return [] }
    let replace = call.record.fields[0] == REPLACE_FUNC_BODY_ANNO_CLASS_NAME
    let explicitCount = call.callee.parameters.size - if (replace) { 1 } else { 0 }
    let args = ArrayList<Value>()
    if (explicitCount > 0) { for (param in target.parameters) { args.add(param) } }
    if (replace) { args.add(target) }
    return args.toArray()
}

private func callContext(callee: Function, args: Array<Value>): FuncCallContext {
    let receiver: ?Type = if (callee.isMemberMethod()) {
        if (callee.isStatic()) {
            Some(addRefIfFuncIsMutOrClass(callee.outerType.getOrThrow(), callee))
        } else { Some(args[0].ty) }
    } else { None }
    return FuncCallContext(args, Array<Type>(), receiver)
}

private class RuleExitVisitor <: CHIRVisitor {
    let callee: Function
    let context: FuncCallContext
    public init(callee: Function, context: FuncCallContext) {
        this.callee = callee
        this.context = context
    }
    public override func action(expr: Expression): IRActionMode {
        if (expr.isLambda()) { return IRActionMode.Skip }
        if (expr.isExit()) {
            CHIRBuilder(InsertPosition.Before(expr)).createApply(callee, context)
        }
        return IRActionMode.Continue
    }
}

private class RuleInitCallVisitor <: CHIRVisitor {
    let symbol: String
    var found = false
    public init(symbol: String) { this.symbol = symbol }
    public override func action(expr: Expression): IRActionMode {
        if (let Some(apply) <- (expr as Apply)) {
            if (let Some(callee) <- (apply.callee as Function)) {
                if (callee.identifierWithoutPrefix == symbol) { found = true }
            }
        }
        return IRActionMode.Continue
    }
}

private func ensureSourceInitialization(pkg: Package, wires: Array<RuleWirePackage>,
    plans: Array<RuleTargetPlan>): Unit {
    if (plans.isEmpty()) { return }
    let targetInit = pkg.packageInitFunc.getOrThrow()
    for (wire in wires) {
        if (wire.sourcePackage == pkg.name) { continue }
        var used = false
        for (plan in plans) {
            for (call in plan.calls) {
                if (call.sourcePackage == wire.sourcePackage) { used = true; break }
            }
            if (used) { break }
        }
        if (!used) { continue }
        let existing = RuleInitCallVisitor(wire.initSymbol)
        existing.walk(targetInit.body.getOrThrow())
        if (!existing.found) {
            let sourceInit = pkg.getSpecifiedFunction(wire.initSymbol).getOrThrow()
            CHIRBuilder(InsertPosition.AtStart(targetInit.body.getOrThrow().entryBlock)).createApply(
                sourceInit, FuncCallContext(Array<Value>(), Array<Type>(), None))
        }
    }
}

private func applyRuleTarget(pkg: Package, plan: RuleTargetPlan): Unit {
    let prepared = ArrayList<(RulePlannedCall, Array<Value>)>()
    var lastSnapshot: ?Expression = None
    // All per-call argument arrays are materialized before *any* Entry.
    for (call in plan.calls) {
        var snapshot: ?Value = None
        if (needsSnapshot(call)) {
            let (value, anchor) = snapshotArgs(pkg, plan.target, lastSnapshot)
            snapshot = Some(value)
            lastSnapshot = Some(anchor)
        }
        let args = callArgs(plan.target, call, snapshot)
        prepared.add((call, args))
    }
    let entryPosition = if (let Some(anchor) <- lastSnapshot) {
        InsertPosition.After(anchor)
    } else { InsertPosition.AtStart(plan.target.body.getOrThrow().entryBlock) }
    let entryBuilder = CHIRBuilder(entryPosition)
    for ((call, args) in prepared) {
        let entry = if (call.record.kind == "A") { call.record.fields[0] == "ENTRY" } else {
            call.record.fields[0] == INSERT_AT_ENTRY_ANNO_CLASS_NAME
        }
        if (entry) { entryBuilder.createApply(call.callee, callContext(call.callee, args)) }
    }
    for ((call, args) in prepared) {
        let exit = if (call.record.kind == "A") { call.record.fields[0] == "EXIT" } else {
            call.record.fields[0] == INSERT_AT_EXIT_ANNO_CLASS_NAME
        }
        if (exit) { RuleExitVisitor(call.callee, callContext(call.callee, args)).walk(plan.target.body.getOrThrow()) }
    }
    for ((call, args) in prepared) {
        if (call.record.kind != "L") { continue }
        if (call.record.fields[0] != REPLACE_FUNC_BODY_ANNO_CLASS_NAME) { continue }
        weaveReplacementBody(pkg, plan.target, call.callee)
    }
}

/** Apply only a plan already checked for every selected target and source. */
protected func applyRuleWeave(pkg: Package, wires: Array<RuleWirePackage>, plans: Array<RuleTargetPlan>): Unit {
    if (pkg.aspectWeaveState != 0 || pkg.aspectWeavePlanDigest != "") {
        throw IllegalArgumentException("already-woven: target package ${pkg.name}")
    }
    ensureSourceInitialization(pkg, wires, plans)
    for (plan in plans) { applyRuleTarget(pkg, plan) }
    pkg.markAspectWeaveApplied(rulePlanDigest(plans))
}
