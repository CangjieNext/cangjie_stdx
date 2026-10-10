/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj

import std.collection.*

protected struct RuleSelectedAdvice {
    let sourcePackage: String
    let record: RuleWireRecord

    public init(sourcePackage: String, record: RuleWireRecord) {
        this.sourcePackage = sourcePackage
        this.record = record
    }
}

/** Keep the v2 target predicates and repeated-record semantics for L records. */
private func matchesLegacyRule(record: RuleWireRecord, target: RuleTargetSpec,
    budget: RuleWorkBudget): Bool {
    let fields = record.fields
    budget.charge(1, "legacy package")
    if (!matchQualifiedNamePatternBudgeted(fields[7], target.sourcePackage, budget)) { return false }
    budget.charge(1, "legacy receiver")
    var receiverMatches = matchNamePatternBudgeted(fields[8], target.receiverName, budget)
    if (!receiverMatches && fields[12] == "true") {
        for (ancestor in target.ancestorNames) {
            budget.charge(1, "legacy ancestor")
            if (matchNamePatternBudgeted(fields[8], ancestor, budget)) { receiverMatches = true; break }
        }
    }
    if (!receiverMatches) { return false }
    budget.charge(1, "legacy method")
    if (!matchNamePatternBudgeted(fields[9], target.methodName, budget) ||
        (fields[11] == "true") != target.isStatic) { return false }
    budget.charge(1, "legacy signature")
    return matchFunctionTypePatternBudgeted(fields[10], target.concreteSignature, budget)
}

/** A pure per-target selection: no CHIR mutation, symbol import or init call. */
protected func selectRuleAdvices(wire: RuleWirePackage, target: RuleTargetSpec,
    annotationsComplete: Bool, budget: RuleWorkBudget): Array<RuleWireRecord> {
    validateWirePackage(wire)
    let records = wire.records
    if (wire.state != "READY") {
        throw IllegalArgumentException("metadata-pending: ${wire.sourcePackage}")
    }
    let definitions = ArrayList<RuleDefinition>()
    let atoms = HashMap<String, RuleAtomSpec>()
    let advices = ArrayList<RuleWireRecord>()
    let roots = ArrayList<String>()
    for (record in records) {
        let fields = record.fields
        match (record.kind) {
            case "R" =>
                atoms[fields[0]] = RuleAtomSpec(fields[1], fields[2], fields[3], fields[4],
                    fields[5], fields[6] == "true", fields[7])
                definitions.add(RuleDefinition(fields[0], fields[1]))
            case "C" =>
                let program = Array<RuleToken>(fields.size - 3, {i => RuleToken(fields[i + 3])})
                definitions.add(RuleDefinition(fields[0], fields[1], program))
            case "A" =>
                advices.add(record)
                roots.add(fields[4])
            case _ => () // Legacy L is handled by the independent old matcher.
        }
    }
    let graph = RuleGraph(wire.sourcePackage, definitions.toArray(),
        {id => if (!atoms.contains(id)) { throw IllegalArgumentException("unknown-rule: ${id}") } },
        {scope => if (!isValidPackageNamePattern(scope)) {
            throw IllegalArgumentException("invalid-rule-field: packageScope")
        } })
    let selected = graph.evaluate(roots.toArray(), annotationsComplete,
        {scope, sharedBudget =>
            sharedBudget.charge(1, "package scope ${scope}")
            matchQualifiedNamePatternBudgeted(scope, target.sourcePackage, sharedBudget)
        },
        {id, sharedBudget => matchRuleAtom(atoms[id], target, sharedBudget)}, budget)
    let result = ArrayList<RuleWireRecord>()
    var newIndex: Int64 = 0
    for (record in records) {
        match (record.kind) {
            case "A" =>
                if (selected[newIndex]) { result.add(record) }
                newIndex++
            case "L" =>
                if (matchesLegacyRule(record, target, budget)) { result.add(record) }
            case _ => ()
        }
    }
    return result.toArray()
}

/** Validate every declared source, then share one budget across the target plan. */
protected func selectRuleAdvicesAcrossSources(wires: Array<RuleWirePackage>, target: RuleTargetSpec,
    annotationsComplete: Bool, budget: RuleWorkBudget): Array<RuleSelectedAdvice> {
    validateRuleSourceSet(wires)
    return selectPreparedRuleAdvicesAcrossSources(wires, target, annotationsComplete, budget)
}

/** Check the entire declared source set even when the target has zero eligible functions. */
protected func validateRuleSourceSet(wires: Array<RuleWirePackage>): Unit {
    if (wires.size > 128) { throw IllegalArgumentException("rule-limit: source packages exceed 128") }
    let seen = HashSet<String>()
    var bytes: Int64 = 0
    var rules: Int64 = 0
    var advices: Int64 = 0
    var tokens: Int64 = 0
    var session = ""
    var abi = ""
    for (wire in wires) {
        validateWirePackage(wire)
        let records = wire.records
        if (wire.state != "READY") {
            throw IllegalArgumentException("metadata-pending: ${wire.sourcePackage}")
        }
        if (!session.isEmpty() && (wire.sessionId != session || wire.toolchainAbiKey != abi)) {
            throw IllegalArgumentException("build-input-mismatch: source session or toolchain ABI")
        }
        session = wire.sessionId
        abi = wire.toolchainAbiKey
        if (!seen.add(wire.sourcePackage)) {
            throw IllegalArgumentException("duplicate-source: ${wire.sourcePackage}")
        }
        let size = encodeRuleWire(wire).size
        if (size > 67108864 - bytes) { throw IllegalArgumentException("rule-limit: aggregate metadata exceeds 64 MiB") }
        bytes += size
        for (record in records) {
            match (record.kind) {
                case "R" | "C" =>
                    if (rules >= 32768) { throw IllegalArgumentException("rule-limit: aggregate rules exceed 32768") }
                    rules++
                    if (record.kind == "C") {
                        let count = record.fields.size - 3
                        if (count > 1048576 - tokens) {
                            throw IllegalArgumentException("rule-limit: aggregate tokens exceed 1048576")
                        }
                        tokens += count
                    }
                case "A" | "L" =>
                    if (advices >= 32768) {
                        throw IllegalArgumentException("rule-limit: aggregate advices exceed 32768")
                    }
                    advices++
                case _ => ()
            }
        }
    }
}

/** Caller must have validated the complete source set before entering the target loop. */
protected func selectPreparedRuleAdvicesAcrossSources(wires: Array<RuleWirePackage>, target: RuleTargetSpec,
    annotationsComplete: Bool, budget: RuleWorkBudget): Array<RuleSelectedAdvice> {
    let result = ArrayList<RuleSelectedAdvice>()
    var hasNew = false
    var hasOldReplace = false
    for (wire in wires) {
        for (record in selectRuleAdvices(wire, target, annotationsComplete, budget)) {
            if (result.size >= 1024) { throw IllegalArgumentException("rule-limit: target calls exceed 1024") }
            if (record.kind == "A") { hasNew = true }
            if (record.kind == "L" && record.fields[0] == REPLACE_FUNC_BODY_ANNO_CLASS_NAME) {
                hasOldReplace = true
            }
            result.add(RuleSelectedAdvice(wire.sourcePackage, record))
        }
    }
    if (hasNew && hasOldReplace) {
        throw IllegalArgumentException("replace-rule-conflict: new advice and old ReplaceFuncBody select the same target")
    }
    return result.toArray()
}
