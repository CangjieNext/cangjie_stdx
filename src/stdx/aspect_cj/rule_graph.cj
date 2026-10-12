/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj

import std.collection.*

// The collector supplies resolved source declaration IDs, not import aliases.
// Wire readers must apply the same declaration/field validators before using
// this graph; syntactic name validation alone does not prove a rule carrier.
protected struct RuleDefinition {
    let id: String
    let packageScope: String
    let isAtom: Bool
    let program: Array<RuleToken>

    public init(id: String, packageScope: String) {
        this.id = id
        this.packageScope = packageScope
        this.isAtom = true
        this.program = []
    }

    public init(id: String, packageScope: String, program: Array<RuleToken>) {
        this.id = id
        this.packageScope = packageScope
        this.isAtom = false
        this.program = program.clone()
    }
}

/** Validated, immutable DAG. No recursive DFS and no expansion of shared rules. */
protected class RuleGraph {
    private let nodes: Array<RuleDefinition>
    private let byId: HashMap<String, Int64>
    private let edges: Array<Array<Int64>>
    private let order: Array<Int64>

    public init(sourcePackage: String, definitions: Array<RuleDefinition>,
        validateAtom: (String) -> Unit, validateScope: (String) -> Unit) {
        if (definitions.size > RULE_PACKAGE_COUNT) {
            throw IllegalArgumentException("rule-limit: source package exceeds 4096 rules")
        }
        validateRuleSourcePackage(sourcePackage)
        // Own the postfix arrays: a caller retaining its input must not be able
        // to change references after validation or while evaluating a target.
        let owned = Array<RuleDefinition>(definitions.size, {i =>
            let d = definitions[i]
            if (d.isAtom) { RuleDefinition(d.id, d.packageScope) }
            else { RuleDefinition(d.id, d.packageScope, d.program) }
        })
        let index = HashMap<String, Int64>()
        let references = Array<Array<Int64>>(owned.size, {_ => []})
        var tokens: Int64 = 0
        for (i in 0..owned.size) {
            let d = owned[i]
            validateRuleId(sourcePackage, d.id)
            if (index.contains(d.id)) {
                throw IllegalArgumentException("duplicate-rule: ${d.id}")
            }
            index[d.id] = i
            // Validate even unreferenced definitions, before any pruning.
            validateScope(d.packageScope)
            if (d.isAtom) {
                validateAtom(d.id)
            } else {
                if (d.program.size > RULE_PACKAGE_TOKENS - tokens) {
                    throw IllegalArgumentException("rule-limit: source package exceeds 262144 tokens")
                }
                tokens += d.program.size
                validateRuleProgram(sourcePackage, d.program)
            }
        }
        for (i in 0..owned.size) {
            let unique = HashSet<Int64>()
            let dependencies = ArrayList<Int64>()
            for (token in owned[i].program) {
                if (!token.operation.startsWith("REF:")) { continue }
                let id = token.operation[4..]
                validateRuleId(sourcePackage, id)
                let next = index.get(id).getOrThrow({ =>
                    IllegalArgumentException("unknown-rule: ${owned[i].id} -> ${id}, UTF-8 byte ${token.byteOffset}")
                })
                if (!unique.contains(next)) {
                    unique.add(next)
                    dependencies.add(next)
                }
            }
            references[i] = dependencies.toArray()
        }
        this.nodes = owned
        this.byId = index
        this.edges = references
        this.order = checkRuleGraph(owned, references)
    }

    public prop size: Int64 { get() { nodes.size } }

    /** Root validation is an index lookup, not a whole-graph evaluation. */
    public func validateRoots(roots: Array<String>): Unit {
        if (roots.size > RULE_PACKAGE_COUNT) {
            throw IllegalArgumentException("rule-limit: source package exceeds 4096 advice roots")
        }
        for (id in roots) {
            if (!byId.contains(id)) { throw IllegalArgumentException("unknown-root: ${id}") }
        }
    }

    /**
     * One call evaluates all advice roots for ONE eligible target. Scratch
     * arrays are local to the call, so memoized values cannot leak across
     * targets. The caller owns one shared budget for the whole target package.
     * Callbacks must charge their internal glob/type/ancestor work as well.
     */
    public func evaluate(roots: Array<String>, annotationsComplete: Bool,
        scopeMatches: (String, RuleWorkBudget) -> Bool,
        atomMatches: (String, RuleWorkBudget) -> Bool, budget: RuleWorkBudget): Array<Bool> {
        if (roots.size > RULE_PACKAGE_COUNT) {
            throw IllegalArgumentException("rule-limit: source package exceeds 4096 advice roots")
        }
        // Account for scratch initialization and the complete order scan even
        // when no scope matches. Charge before allocating per-target arrays.
        budget.charge(nodes.size * 4 + roots.size, "rule evaluation scratch and order scan")
        let selected = ArrayList<Int64>()
        // Validate every root before performing matching work.
        for (id in roots) {
            selected.add(byId.get(id).getOrThrow({ => IllegalArgumentException("unknown-root: ${id}") }))
        }
        let scopes = Array<?Bool>(nodes.size, repeat: None)
        let needed = Array<Bool>(nodes.size, repeat: false)
        let pending = ArrayList<Int64>()
        for (i in selected) {
            if (scopes[i].isNone()) {
                scopes[i] = Some(scopeMatches(nodes[i].packageScope, budget))
            }
            if (scopes[i].getOrThrow() && !needed[i]) {
                if (!annotationsComplete) {
                    throw IllegalArgumentException("annotation-metadata-unknown: root ${nodes[i].id}")
                }
                needed[i] = true
                pending.add(i)
            }
        }
        while (!pending.isEmpty()) {
            let current = pending.remove(at: pending.size - 1)
            for (next in edges[current]) {
                budget.charge(1, "rule reference ${nodes[current].id} -> ${nodes[next].id}")
                if (!needed[next]) { needed[next] = true; pending.add(next) }
            }
        }
        let values = Array<Bool>(nodes.size, repeat: false)
        for (i in order) {
            if (!needed[i]) { continue }
            if (scopes[i].isNone()) {
                scopes[i] = Some(scopeMatches(nodes[i].packageScope, budget))
            }
            if (!scopes[i].getOrThrow()) { continue }
            if (nodes[i].isAtom) {
                values[i] = atomMatches(nodes[i].id, budget)
            } else {
                values[i] = evaluateRuleProgram(nodes[i].program, {id =>
                    budget.charge(1, "rule operand ${id}")
                    values[byId[id]]
                }, budget)
            }
        }
        return Array<Bool>(selected.size, {i => values[selected[i]]})
    }
}

private func validateRuleId(sourcePackage: String, id: String): Unit {
    let prefix = sourcePackage + "."
    if (!id.startsWith(prefix) || id.size <= prefix.size || id.size > 512) {
        throw IllegalArgumentException("invalid-rule-id: ${id}")
    }
    let name = id[prefix.size..]
    let parsed = parseRuleExpression(sourcePackage, name)
    if (parsed.size != 1 || parsed[0].operation != "REF:" + id) {
        throw IllegalArgumentException("invalid-rule-id: ${id}")
    }
}

private func checkRuleGraph(nodes: Array<RuleDefinition>, edges: Array<Array<Int64>>): Array<Int64> {
    // 0 = unseen, 1 = on explicit DFS stack, 2 = finished.
    let colors = Array<UInt8>(nodes.size, repeat: 0)
    let heights = Array<Int64>(nodes.size, repeat: 1)
    let stack = ArrayList<Int64>()
    let cursors = ArrayList<Int64>()
    let result = ArrayList<Int64>()
    for (start in 0..nodes.size) {
        if (colors[start] != 0) { continue }
        stack.add(start); cursors.add(0); colors[start] = 1
        while (!stack.isEmpty()) {
            let top = stack.size - 1
            let current = stack[top]
            if (cursors[top] < edges[current].size) {
                let next = edges[current][cursors[top]]
                cursors[top]++
                if (colors[next] == 1) {
                    let path = ArrayList<String>()
                    var inCycle = false
                    for (node in stack) {
                        if (node == next) { inCycle = true }
                        if (inCycle) { path.add(nodes[node].id) }
                    }
                    path.add(nodes[next].id)
                    throw IllegalArgumentException("rule-cycle: " + String.join(path.toArray(), delimiter: " -> "))
                }
                if (colors[next] == 0) {
                    stack.add(next); cursors.add(0); colors[next] = 1
                }
            } else {
                for (next in edges[current]) {
                    heights[current] = max(heights[current], heights[next] + 1)
                }
                if (heights[current] > RULE_REFERENCE_PATH) {
                    throw IllegalArgumentException("rule-limit: reference path exceeds 64 at ${nodes[current].id}")
                }
                colors[current] = 2
                result.add(current)
                stack.remove(at: top); cursors.remove(at: top)
            }
        }
    }
    return result.toArray()
}
