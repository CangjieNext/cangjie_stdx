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

/** Owned, validated source program. Reused only within one package compilation. */
protected class PreparedRuleSource {
    let sourcePackage: String
    let sessionId: String
    let toolchainAbiKey: String
    let encodedSize: Int64
    let ruleCount: Int64
    let adviceCount: Int64
    let tokenCount: Int64
    private let records: Array<RuleWireRecord>
    private let atoms: HashMap<String, RuleAtomSpec>
    private let graph: RuleGraph
    private let roots: Array<String>

    public init(wire: RuleWirePackage) {
        let owned = wire.records
        let validated = validatedRuleWireGraph(wire, owned)
        if (wire.state != "READY") {
            throw IllegalArgumentException("metadata-pending: ${wire.sourcePackage}")
        }
        let atomic = HashMap<String, RuleAtomSpec>()
        let rootList = ArrayList<String>()
        var rules: Int64 = 0
        var advices: Int64 = 0
        var tokens: Int64 = 0
        for (record in owned) {
            let fields = record.fields
            match (record.kind) {
                case "R" =>
                    rules++
                    atomic[fields[0]] = RuleAtomSpec(fields[1], fields[2], fields[3], fields[4],
                        fields[5], fields[6] == "true", fields[7])
                case "C" => rules++; tokens += fields.size - 3
                case "A" => advices++; rootList.add(fields[4])
                case "L" => advices++
                case _ => ()
            }
        }
        this.sourcePackage = wire.sourcePackage
        this.sessionId = wire.sessionId
        this.toolchainAbiKey = wire.toolchainAbiKey
        this.encodedSize = validatedRuleWireSize(wire, owned)
        this.ruleCount = rules
        this.adviceCount = advices
        this.tokenCount = tokens
        this.records = owned
        this.atoms = atomic
        this.graph = validated
        this.roots = rootList.toArray()
    }

    public func select(target: RuleTargetSpec, annotationsComplete: Bool,
        budget: RuleWorkBudget): Array<RuleWireRecord> {
        let selected = graph.evaluate(roots, annotationsComplete,
            {scope, sharedBudget =>
                sharedBudget.charge(1, "package scope ${scope}")
                matchQualifiedNamePatternBudgeted(scope, target.sourcePackage, sharedBudget)
            }, {id, sharedBudget => matchRuleAtom(atoms[id], target, sharedBudget)}, budget)
        let result = ArrayList<RuleWireRecord>()
        var newIndex: Int64 = 0
        budget.charge(records.size, "source advice scan")
        for (record in records) {
            match (record.kind) {
                case "A" =>
                    if (selected[newIndex]) { result.add(record) }
                    newIndex++
                case "L" => if (matchesLegacyRule(record, target, budget)) { result.add(record) }
                case _ => ()
            }
        }
        return result.toArray()
    }
}

/** Convenience entry point for one target; production prepares before its target loop. */
protected func selectRuleAdvices(wire: RuleWirePackage, target: RuleTargetSpec,
    annotationsComplete: Bool, budget: RuleWorkBudget): Array<RuleWireRecord> {
    return PreparedRuleSource(wire).select(target, annotationsComplete, budget)
}

/** Validate every declared source, then share one budget across the target plan. */
protected func selectRuleAdvicesAcrossSources(wires: Array<RuleWirePackage>, target: RuleTargetSpec,
    annotationsComplete: Bool, budget: RuleWorkBudget): Array<RuleSelectedAdvice> {
    return selectPreparedRuleAdvicesAcrossSources(prepareRuleSourceSet(wires), target, annotationsComplete, budget)
}

/** Check the entire declared source set even when the target has zero eligible functions. */
protected func validateRuleSourceSet(wires: Array<RuleWirePackage>): Unit {
    prepareRuleSourceSet(wires)
}

protected func prepareRuleSourceSet(wires: Array<RuleWirePackage>): Array<PreparedRuleSource> {
    if (wires.size > 128) { throw IllegalArgumentException("rule-limit: source packages exceed 128") }
    let seen = HashSet<String>()
    var bytes: Int64 = 0
    var rules: Int64 = 0
    var advices: Int64 = 0
    var tokens: Int64 = 0
    var session = ""
    var abi = ""
    let prepared = ArrayList<PreparedRuleSource>()
    for (wire in wires) {
        let source = PreparedRuleSource(wire)
        if (!session.isEmpty() && (wire.sessionId != session || wire.toolchainAbiKey != abi)) {
            throw IllegalArgumentException("build-input-mismatch: source session or toolchain ABI")
        }
        session = wire.sessionId
        abi = wire.toolchainAbiKey
        if (!seen.add(wire.sourcePackage)) {
            throw IllegalArgumentException("duplicate-source: ${wire.sourcePackage}")
        }
        let size = source.encodedSize
        if (size > 67108864 - bytes) { throw IllegalArgumentException("rule-limit: aggregate metadata exceeds 64 MiB") }
        bytes += size
        rules += source.ruleCount
        advices += source.adviceCount
        tokens += source.tokenCount
        if (rules > 32768) { throw IllegalArgumentException("rule-limit: aggregate rules exceed 32768") }
        if (advices > 32768) { throw IllegalArgumentException("rule-limit: aggregate advices exceed 32768") }
        if (tokens > 1048576) { throw IllegalArgumentException("rule-limit: aggregate tokens exceed 1048576") }
        prepared.add(source)
    }
    return prepared.toArray()
}

/** Caller must have validated the complete source set before entering the target loop. */
protected func selectPreparedRuleAdvicesAcrossSources(sources: Array<PreparedRuleSource>, target: RuleTargetSpec,
    annotationsComplete: Bool, budget: RuleWorkBudget): Array<RuleSelectedAdvice> {
    let result = ArrayList<RuleSelectedAdvice>()
    var hasNew = false
    var hasOldReplace = false
    for (source in sources) {
        for (record in source.select(target, annotationsComplete, budget)) {
            if (result.size >= 1024) { throw IllegalArgumentException("rule-limit: target calls exceed 1024") }
            if (record.kind == "A") { hasNew = true }
            if (record.kind == "L") {
                if (record.fields[0] == REPLACE_FUNC_BODY_ANNO_CLASS_NAME) { hasOldReplace = true }
            }
            result.add(RuleSelectedAdvice(source.sourcePackage, record))
        }
    }
    if (hasNew && hasOldReplace) {
        throw IllegalArgumentException("replace-rule-conflict: new advice and old ReplaceFuncBody select the same target")
    }
    return result.toArray()
}
