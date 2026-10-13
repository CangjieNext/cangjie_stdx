// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package stdx.aspect_cj

import std.collection.*
import std.env.*

var checks = 0
var failures = 0

private func check(value: Bool, label: String): Unit {
    checks++
    if (!value) { failures++; println("FAIL: ${label}") }
}

private func rejected(action: () -> Unit, contains: String): Bool {
    try {
        action()
    } catch (e: IllegalArgumentException) {
        return e.message.contains(contains)
    }
    return false
}

@PointcutRule[packageName: "shop.**", className: "*Service", methodName: "handle*",
    funcTypeStr: "(**)->*", targetKind: "instance", recursive: false, annotationName: "shop.auth.RequireLogin"]
class LoginOperations {}

@PointcutExpression[packageScope: "shop.**", expression: "LoginOperations AND NOT InternalOperations"]
class PublicOperations {}

@InsertAtEntryByRule[rule: "stdx.aspect_cj.PublicOperations"]
public func entry(): Unit {}

@InsertAtExitByRule[rule: "stdx.aspect_cj.PublicOperations"]
public func leave(args: Array<Any>): Unit { if (args.size < 0) { throw Exception("unreachable") } }

private func graphTests(): Unit {
    let validationVisits = ArrayList<String>()
    let validateAtom = {id: String => validationVisits.add(id); ()}
    let validateScope = {scope: String =>
        if (scope.isEmpty()) { throw IllegalArgumentException("bad-scope") }
    }
    let defs = [
        RuleDefinition("p.Outer", "shop", parseRuleExpression("p", "NOT Inner")),
        RuleDefinition("p.Shared", "shop", parseRuleExpression("p", "A OR A")),
        RuleDefinition("p.Inner", "internal", parseRuleExpression("p", "Shared")),
        RuleDefinition("p.A", "shop"), RuleDefinition("p.Unused", "shop")]
    let graph = RuleGraph("p", defs, validateAtom, validateScope)
    check(graph.size == 5 && validationVisits.size == 2, "unreachable atom validated before pruning")
    let visits = [0]
    let scope = {pattern: String, _: RuleWorkBudget => pattern == "shop"}
    let atom = {_: String, _: RuleWorkBudget => visits[0]++; true}
    let result = graph.evaluate(["p.Outer", "p.Shared", "p.Outer"], true, scope, atom, RuleWorkBudget())
    check(result == [true, true, true], "nested scope respected under NOT; duplicate roots stable")
    check(visits[0] == 1, "shared atom evaluated once, unused atom pruned")
    let second = graph.evaluate(["p.Shared"], true, scope, {_, _ => false}, RuleWorkBudget())
    check(second == [false], "memo is not reused for next target")
    check(rejected({ => graph.evaluate(["p.Shared"], false, scope, atom, RuleWorkBudget()); () },
        "annotation-metadata-unknown"), "Unknown never coerced to false under OR")
    check(rejected({ => graph.evaluate(["p.Outer"], false, scope, atom, RuleWorkBudget()); () },
        "annotation-metadata-unknown"), "Unknown never negated to true")
    check(graph.evaluate(["p.Outer"], false, {_, _ => false}, atom, RuleWorkBudget()) == [false],
        "outside root scope is not a candidate even under NOT")
    check(graph.evaluate([], false, scope, atom, RuleWorkBudget()).isEmpty(), "empty roots")
    check(rejected({ => graph.evaluate(["p.Shared", "p.Absent"], true, scope, atom, RuleWorkBudget()); () },
        "unknown-root"), "all roots checked up front")
    check(rejected({ => graph.evaluate(["p.Shared"], true, scope, atom, RuleWorkBudget(limit: 1)); () },
        "rule-limit"), "reference and token work charged")
    let program = parseRuleExpression("p", "A")
    let copied = RuleDefinition("p.B", "shop", program)
    program[0] = RuleToken("REF:p.Absent")
    let frozen = RuleGraph("p", [RuleDefinition("p.A", "shop"), copied], validateAtom, validateScope)
    copied.program[0] = RuleToken("REF:p.Absent")
    check(frozen.evaluate(["p.B"], true, scope, atom, RuleWorkBudget()) == [true], "deep copy of programs")
    check(rejected({ => RuleGraph("p", [RuleDefinition("p.A", "shop"), RuleDefinition("p.A", "shop")],
        validateAtom, validateScope); () }, "duplicate-rule"), "duplicate IDs")
    for (badId in ["p.A-B", "p.A B", "p.other.A", "q.A", "p._", "p.NOT", "p.AND", "p.OR"]) {
        check(rejected({ => RuleGraph("p", [RuleDefinition(badId, "shop")], validateAtom, validateScope); () }, ""),
            "invalid declaration ID ${badId}")
    }
    check(rejected({ => RuleGraph("p", [RuleDefinition("p.A", "shop", parseRuleExpression("p", "B"))],
        validateAtom, validateScope); () }, "unknown-rule: p.A -> p.B"), "unknown forward reference")
    check(rejected({ => RuleGraph("p", [RuleDefinition("p.A", "shop", parseRuleExpression("p", "A"))],
        validateAtom, validateScope); () }, "p.A -> p.A"), "self cycle diagnostic")
    check(rejected({ => RuleGraph("p", [
        RuleDefinition("p.A", "shop", parseRuleExpression("p", "B")),
        RuleDefinition("p.B", "shop", parseRuleExpression("p", "C")),
        RuleDefinition("p.C", "shop", parseRuleExpression("p", "B"))], validateAtom, validateScope); () },
        "p.B -> p.C -> p.B"), "unreferenced cycle with exact path")
    let chain = {length: Int64 => Array<RuleDefinition>(length, {i =>
        if (i == 0) { RuleDefinition("p.R0", "shop") }
        else { RuleDefinition("p.R${i}", "shop", parseRuleExpression("p", "R${i - 1}")) }
    })}
    check(RuleGraph("p", chain(64), validateAtom, validateScope).size == 64, "64 node reference path")
    check(rejected({ => RuleGraph("p", chain(65), validateAtom, validateScope); () }, "path exceeds 64"),
        "longest path includes previously finished subtree")
    let diamond = Array<RuleDefinition>(64, {i =>
        if (i == 0) { RuleDefinition("p.R0", "shop") }
        else { RuleDefinition("p.R${i}", "shop", parseRuleExpression("p", "R${i - 1} OR R${i - 1}")) }
    })
    let dag = RuleGraph("p", diamond, validateAtom, validateScope)
    let work = RuleWorkBudget(limit: 1000)
    check(dag.evaluate(["p.R63"], true, scope, atom, work) == [true] && work.used == 635,
        "shared exponential expression remains a linear DAG with exact work accounting")
    dag.validateRoots(["p.R0", "p.R63"])
    check(rejected({ => dag.validateRoots(["p.Absent"]); () }, "unknown-root"),
        "root validation rejects an unknown ID without evaluating targets")
    check(rejected({ => dag.evaluate(["p.R63"], true, {_, _ => false}, atom,
        RuleWorkBudget(limit: 256)); () }, "scratch"), "zero-match evaluation charges scratch before allocation")
    check(RuleGraph("p", Array<RuleDefinition>(4096, {i => RuleDefinition("p.A${i}", "shop")}),
        validateAtom, validateScope).size == 4096, "4096 rules")
    check(rejected({ => RuleGraph("p", Array<RuleDefinition>(4097, {i => RuleDefinition("p.A${i}", "shop")}),
        validateAtom, validateScope); () }, "4096 rules"), "4097 rules rejected before allocation")
    check(rejected({ => RuleGraph("p", [RuleDefinition("p.A", "")], validateAtom, validateScope); () },
        "bad-scope"), "unreferenced scope validated")
    check(rejected({ => RuleGraph("p", [RuleDefinition("p.A", "shop")],
        {_ => throw IllegalArgumentException("bad-atom")}, validateScope); () }, "bad-atom"),
        "unreferenced atomic fields validated")
    let fullProgram = parseRuleExpression("p", "NOT " + String.join(Array<String>(128, repeat: "A"), delimiter: " AND "))
    let fullPackage = Array<RuleDefinition>(1025, {i =>
        if (i == 0) { RuleDefinition("p.A", "shop") }
        else { RuleDefinition("p.C${i}", "shop", fullProgram) }
    })
    check(fullProgram.size == 256 && RuleGraph("p", fullPackage, validateAtom, validateScope).size == 1025,
        "exact 262144 token package budget")
    let overPackage = ArrayList<RuleDefinition>.of(fullPackage)
    overPackage.add(RuleDefinition("p.TooMany", "shop", fullProgram))
    check(rejected({ => RuleGraph("p", overPackage.toArray(), validateAtom, validateScope); () }, "262144 tokens"),
        "aggregate token limit checked before graph expansion")
    for (badPackage in ["", "p..q", "p.", "p q", "1p", "p._", "p/x"]) {
        check(rejected({ => RuleGraph(badPackage, [], validateAtom, validateScope); () }, "invalid-rule-package"),
            "invalid namespace ${badPackage}")
    }
    for (badReference in ["p._", "p.AND", "p.A-B", "p.A B", "p.3A"]) {
        check(rejected({ => validateRuleProgram("p", [RuleToken("REF:" + badReference)]); () }, "rule reference"),
            "wire reference spelling ${badReference}")
    }
}

private func atomTests(): Unit {
    let atom = RuleAtomSpec("shop.**", "*Service", "handle*", "(Array<*>)->Unit", "instance",
        false, "shop.auth.RequireLogin")
    validateRuleAtom(atom)
    let target = RuleTargetSpec("shop.web", "OrderService", [], "handleOrder", "(Array<Int64>)->Unit",
        true, false, ["shop.auth.RequireLogin"])
    check(matchRuleAtom(atom, target, RuleWorkBudget()), "business annotation and generic signature")
    check(!matchRuleAtom(atom, RuleTargetSpec("shop.web", "OrderService", [], "handleOrder",
        "(Array<Int64>)->Unit", true, false, ["other.RequireLogin"]), RuleWorkBudget()),
        "same short annotation name does not match")
    check(!matchRuleAtom(atom, RuleTargetSpec("other.web", "OrderService", [], "handleOrder",
        "(Array<Int64>)->Unit", true, false, ["shop.auth.RequireLogin"]), RuleWorkBudget()),
        "source package scope is enforced")
    check(!matchRuleAtom(atom, RuleTargetSpec("shop.web", "OrderService", [], "handleOrder",
        "(Array<Int64>)->Unit", true, true, ["shop.auth.RequireLogin"]), RuleWorkBudget()),
        "instance kind excludes static target")
    let recursive = RuleAtomSpec("shop.**", "*Service", "*", "(**)->*", "any", true, "")
    validateRuleAtom(recursive)
    check(matchRuleAtom(recursive, RuleTargetSpec("shop.web", "Worker", ["OrderService"], "run",
        "()->Unit", true, false, []), RuleWorkBudget()), "ancestor receiver matches when recursive")
    check(!matchRuleAtom(RuleAtomSpec("shop.**", "*Service", "*", "(**)->*", "any", false, ""),
        RuleTargetSpec("shop.web", "Worker", ["OrderService"], "run", "()->Unit", true, false, []),
        RuleWorkBudget()), "ancestor receiver does not match by default")
    check(!matchRuleAtom(recursive, RuleTargetSpec("shop.web", "", ["OrderService"], "run",
        "()->Unit", false, false, []), RuleWorkBudget()), "empty class name is not a global member")
    let globBudget = RuleWorkBudget(limit: 88)
    check(matchNamePatternBudgeted("a*a*a*a*", "aaaaaaaaaa", globBudget) && globBudget.used == 88,
        "glob DP charges every computed row cell")
    check(rejected({ => matchNamePatternBudgeted("a*a*a*a*", "aaaaaaaaaa",
        RuleWorkBudget(limit: 87)); () }, "rule-limit"),
        "glob DP stops before over-budget work")
    check(matchFunctionTypePatternBudgeted("(Array<*>)->Unit", "(Array<Int64>)->Unit",
        RuleWorkBudget()), "budgeted nested type matching agrees with legacy")
    check(!matchFunctionTypePatternBudgeted("(Array<String>)->Unit", "(Array<Int64>)->Unit",
        RuleWorkBudget()), "budgeted nested type mismatch")
    check(rejected({ => matchFunctionTypePatternBudgeted("(Array<*>)->Unit",
        "(Array<Int64>)->Unit", RuleWorkBudget(limit: 10)); () }, "rule-limit"),
        "type parser charges work before unbounded nested scans")
    check(matchFunctionTypePattern("(Array<*>)->Unit", "(Array<Int64>)->Unit"),
        "legacy generic matching uses the shared matcher")
    check(!matchTypePattern("Array<String>", "Array<Int64>"), "legacy generic mismatch")
    check(matchTypePattern("Array", "Array<Int64>"), "legacy constructor matching preserved")
    let opens = String.join(Array<String>(80, repeat: "Array<"), delimiter: "")
    let closes = String.join(Array<String>(80, repeat: ">"), delimiter: "")
    let nestedPattern = opens + "*" + closes
    let nestedValue = opens + "Int64" + closes
    check(rejected({ => matchTypePattern(nestedPattern, nestedValue); () }, "type nesting"),
        "legacy type recursion rejects over-budget nesting")
    check(rejected({ => matchFunctionTypePattern("(" + nestedPattern + ")->Unit",
        "(" + nestedValue + ")->Unit"); () }, "type nesting"),
        "legacy function recursion rejects over-budget nesting")
    for (bad in [
        RuleAtomSpec("", "", "*", "(**)->*", "any", false, ""),
        RuleAtomSpec("shop", "X", "*", "(**)->*", "global", false, ""),
        RuleAtomSpec("shop", "", "*", "(**)->*", "any", true, ""),
        RuleAtomSpec("shop", "", "*", "(**)->*", "other", false, ""),
        RuleAtomSpec("shop", "", "*", "(**)->*", "any", false, "shop.auth.*"),
        RuleAtomSpec("shop", "", "*", "bad", "any", false, "")]) {
        check(rejected({ => validateRuleAtom(bad) }, "invalid-rule-field"), "invalid atomic rule field")
    }
}

private func wireTests(): Unit {
    let hash = String.join(Array<String>(64, repeat: "a"), delimiter: "")
    let session = String.join(Array<String>(32, repeat: "b"), delimiter: "")
    let records = [
        RuleWireRecord("R", "src/rules.cj", 3, 1,
            ["aspect.Login", "shop.**", "*Service", "handle*", "(**)->*", "instance", "false",
                "shop.auth.RequireLogin"]),
        RuleWireRecord("C", "src/rules.cj", 8, 1,
            ["aspect.Public", "shop.**", "1", "REF:aspect.Login"]),
        RuleWireRecord("A", "src/advice.cj", 12, 1,
            ["ENTRY", "_advice", "global", "array-any", "aspect.Public"])]
    let wire = RuleWirePackage("READY", session, "aspect", hash, hash, "_init", records)
    let text = encodeRuleWire(wire)
    let copy = decodeRuleWire(text)
    check(copy.records.size == 3 && copy.records[1].fields[3] == "REF:aspect.Login",
        "wire v4 R/C/A exact round trip")
    let readRecords = wire.records
    readRecords[0] = RuleWireRecord("R", "", 0, 0,
        ["aspect.Other", "shop", "", "handle", "()->Unit", "global", "false", ""])
    check(wire.records[0].fields[0] == "aspect.Login", "wire record array is owned")
    let readFields = wire.records[0].fields
    readFields[0] = "aspect.Other"
    check(wire.records[0].fields[0] == "aspect.Login", "wire field array is owned")
    check(rejected({ => decodeRuleWire(text + "extra\n"); () }, "trailing data"), "wire rejects extra line")
    check(rejected({ => decodeRuleWire(text[0..text.size - 1]); () }, "newline"), "wire requires final LF")
    check(rejected({ => decodeRuleWire(text.replace("#aspect_cj_annoinfo_v4", "#aspect_cj_annoinfo_v3")); () },
        "magic"), "wire does not accept unpublished v3")
    check(rejected({ => decodeRuleWire(text.replace("\n3\nR\n", "\n03\nR\n")); () },
        "noncanonical unsigned decimal"), "wire rejects leading zero counts")
    check(rejected({ => decodeRuleWire(text.replace("\n3\nR\n", "\n9223372036854775808\nR\n")); () },
        "decimal overflow"), "wire rejects overflowing counts before allocation")
    let duplicateAdvice = RuleWirePackage("READY", session, "aspect", hash, hash, "_init",
        [records[0], records[1], records[2], records[2]])
    check(rejected({ => encodeRuleWire(duplicateAdvice); () }, "duplicate A"), "wire A uniqueness")
    let legacy = RuleWireRecord("L", "", 0, 0, [INSERT_AT_ENTRY_ANNO_CLASS_NAME, "aspect", "_advice",
        "0", "false", "false", "false", "shop", "", "handle", "()->Unit", "false", "false"])
    let repeatedLegacy = decodeRuleWire(encodeRuleWire(RuleWirePackage("READY", session, "aspect",
        hash, hash, "_init", [legacy, legacy])))
    check(repeatedLegacy.records.size == 2, "wire L preserves legacy repeated occurrences")
    let oldLines = ["aspect", "_init", "InsertAtEntry", "aspect", "_advice", "0",
        "false", "false", "shop", "", "handle", "()->Unit", "false", "false"]
    let v1 = decodeLegacyRuleWire(String.join(oldLines, delimiter: "\n") + "\n",
        session, "aspect", hash, hash)
    check(v1.records.size == 1 && v1.records[0].fields[6] == "false",
        "v1 adapter preserves legacy advice")
    let v2Lines = [ANNO_INFO_VERSION_HEADER, "aspect", "_init", "InsertAtEntry", "aspect",
        "_advice", "0", "false", "false", "true", "shop", "", "handle", "()->Unit",
        "false", "false"]
    let v2 = decodeLegacyRuleWire(String.join(v2Lines, delimiter: "\n") + "\n",
        session, "aspect", hash, hash)
    check(v2.records.size == 1 && v2.records[0].fields[6] == "true",
        "v2 adapter preserves Array<Any> mode")
    check(rejected({ => decodeLegacyRuleWire(String.join(oldLines, delimiter: "\n") + "\n",
        session, "other", hash, hash); () }, "mismatch"), "legacy source identity is checked")
    check(rejected({ => encodeRuleWire(RuleWirePackage("READY", session, "aspect", hash, hash,
        "_init", [records[0], records[1], records[2], legacy])); () }, "old/new advice mix"),
        "wire rejects one advice symbol shared by old and new controls")
    check(rejected({ => encodeRuleWire(RuleWirePackage("PENDING", session, "aspect", hash, hash,
        "", records)); () }, "PENDING"), "PENDING cannot carry records")
    check(rejected({ => encodeRuleWire(RuleWirePackage("READY", session, "aspect", hash, hash,
        "", records)); () }, "initializer"), "advice needs initializer")
    let wrongNamespace = RuleWirePackage("READY", session, "aspect", hash, hash, "_init",
        [RuleWireRecord("R", "", 0, 0, ["other.Login", "shop", "", "*", "(**)->*", "any", "false", ""])])
    check(rejected({ => encodeRuleWire(wrongNamespace); () }, "cross-package"), "rule IDs stay in source package")
}

private func contextTests(): Unit {
    let valid = ##"{"schemaVersion":1,"sessionId":"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","action":"collect","packageName":"aspect","sourceActionKey":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","toolchainAbiKey":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","sessionRoot":"/tmp/aspect-session","outputRelativePath":"metadata/aspect.annoinfo","expectedPlanDigest":"","sources":[]}"##
    let context = parseRuleActionContext(valid.toArray())
    check(context.action == "collect" && context.sources.isEmpty(), "strict build context parses")
    check(rejected({ => parseRuleActionContext(valid.replace("\"schemaVersion\":1,",
        "\"schemaVersion\":1,\"schemaVersion\":1,").toArray()); () }, "duplicate key"),
        "duplicate JSON keys are rejected before map overwrite")
    check(rejected({ => parseRuleActionContext(valid.replace("metadata/aspect.annoinfo",
        "../escape.annoinfo").toArray()); () }, "build-phase-invalid"),
        "context rejects output parent traversal")
    let hashA = String.join(Array<String>(64, repeat: "a"), delimiter: "")
    let hashB = String.join(Array<String>(64, repeat: "b"), delimiter: "")
    let sourceA = RuleSourceInput("aspect.one", "/source/one", hashA, hashA)
    let sourceB = RuleSourceInput("aspect.two", "/source/two", hashB, hashB)
    let buildA = RuleActionContext(context.sessionId, "preflight", "shop", hashA, hashA,
        "/tmp/aspect-session", "metadata/plan", "", [sourceA, sourceB])
    let buildReordered = RuleActionContext(context.sessionId, "preflight", "shop", hashA, hashA,
        "/tmp/aspect-session", "metadata/plan", "", [sourceB, sourceA])
    let buildChanged = RuleActionContext(context.sessionId, "preflight", "shop", hashA, hashA,
        "/tmp/aspect-session", "metadata/plan", "", [sourceA,
            RuleSourceInput("aspect.two", "/source/two", hashA, hashB)])
    let emptyPlan: Array<RuleTargetPlan> = []
    check(ruleBuildPlanDigest(emptyPlan, buildA) == ruleBuildPlanDigest(emptyPlan, buildReordered),
        "build digest ignores source enumeration order")
    check(ruleBuildPlanDigest(emptyPlan, buildA) != ruleBuildPlanDigest(emptyPlan, buildChanged),
        "build digest binds unused source metadata too")
}

private func selectionTests(): Unit {
    let hash = String.join(Array<String>(64, repeat: "a"), delimiter: "")
    let session = String.join(Array<String>(32, repeat: "b"), delimiter: "")
    let rule = RuleWireRecord("R", "", 0, 0, ["aspect.Login", "shop.**", "*Service", "handle*",
        "(std.core.Array<*>)->Unit", "instance", "false", "shop.auth.RequireLogin"])
    let excluded = RuleWireRecord("R", "", 0, 0, ["aspect.Internal", "shop.**", "*Service",
        "handleInternal*", "(**)->*", "instance", "false", ""])
    let expression = RuleWireRecord("C", "", 0, 0, ["aspect.Visible", "shop.**", "4",
        "REF:aspect.Login", "REF:aspect.Internal", "NOT", "AND"])
    let entry = RuleWireRecord("A", "", 0, 0, ["ENTRY", "_before", "global", "none", "aspect.Visible"])
    let exit = RuleWireRecord("A", "", 0, 0, ["EXIT", "_after", "global", "array-any", "aspect.Visible"])
    let wire = RuleWirePackage("READY", session, "aspect", hash, hash, "_init",
        [rule, excluded, expression, entry, exit])
    let target = RuleTargetSpec("shop.service", "UserService", [], "handleLogin",
        "(std.core.Array<Int64>)->Unit", true, false, ["shop.auth.RequireLogin"])
    let chosen = selectRuleAdvices(wire, target, true, RuleWorkBudget())
    let prepared = PreparedRuleSource(wire)
    check(prepared.encodedSize == encodeRuleWire(wire).size, "prepared metadata size matches the wire bytes")
    check(prepared.select(target, true, RuleWorkBudget()).size == chosen.size,
        "prepared source preserves selection")
    check(chosen.size == 2 && chosen[0].fields[1] == "_before" && chosen[1].fields[1] == "_after",
        "rule DAG selects both advices once for generic annotated method")
    let internalTarget = RuleTargetSpec("shop.service", "UserService", [], "handleInternalLogin",
        "(std.core.Array<Int64>)->Unit", true, false, ["shop.auth.RequireLogin"])
    check(selectRuleAdvices(wire, internalTarget, true, RuleWorkBudget()).isEmpty(),
        "NOT excludes internal method")
    let homonym = RuleTargetSpec("shop.service", "UserService", [], "handleLogin",
        "(std.core.Array<Int64>)->Unit", true, false, ["other.auth.RequireLogin"])
    check(selectRuleAdvices(wire, homonym, true, RuleWorkBudget()).isEmpty(),
        "business annotation requires exact qualified identity")
    check(rejected({ => selectRuleAdvices(wire, target, false, RuleWorkBudget()); () },
        "annotation-metadata-unknown"), "in-scope Unknown aborts before NOT")
    let outside = RuleTargetSpec("other.service", "UserService", [], "handleLogin",
        "(std.core.Array<Int64>)->Unit", true, false, [])
    check(selectRuleAdvices(wire, outside, false, RuleWorkBudget()).isEmpty(),
        "outside scope Unknown does not broaden a rule")
    let second = RuleWirePackage("READY", session, "other", hash, hash, "_other_init", [
        RuleWireRecord("R", "", 0, 0, ["other.All", "shop.**", "", "handle*", "(**)->*",
            "any", "false", ""]),
        RuleWireRecord("A", "", 0, 0, ["ENTRY", "_other_before", "global", "none", "other.All"])])
    let all = selectRuleAdvicesAcrossSources([wire, second], target, true, RuleWorkBudget())
    check(all.size == 3 && all[0].sourcePackage == "aspect" && all[2].sourcePackage == "other",
        "multiple validated source packages share a target plan")
    let oldEntry = RuleWireRecord("L", "", 0, 0,
        [INSERT_AT_ENTRY_ANNO_CLASS_NAME, "legacy", "_old_before", "0", "false", "false", "false",
            "shop.**", "*Service", "handle*", "(**)->*", "false", "false"])
    let oldWire = RuleWirePackage("READY", session, "legacy", hash, hash, "_legacy_init",
        [oldEntry, oldEntry])
    let oldSelected = selectRuleAdvices(oldWire, target, false, RuleWorkBudget())
    check(oldSelected.size == 2 && oldSelected[0].kind == "L" && oldSelected[1].kind == "L",
        "old duplicate records retain both occurrences without requiring a new snapshot")
    let mixed = selectRuleAdvicesAcrossSources([wire, oldWire], target, true, RuleWorkBudget())
    check(mixed.size == 4 && mixed[2].record.kind == "L" && mixed[3].record.kind == "L",
        "old Entry and new A share one pure plan without losing repeated old records")
    let oldReplace = RuleWireRecord("L", "", 0, 0,
        [REPLACE_FUNC_BODY_ANNO_CLASS_NAME, "legacy", "_old_replace", "1", "false", "false", "false",
            "shop.**", "*Service", "handle*", "(**)->*", "false", "false"])
    let replaceWire = RuleWirePackage("READY", session, "legacy", hash, hash, "_legacy_init", [oldReplace])
    check(rejected({ => selectRuleAdvicesAcrossSources([wire, replaceWire], target, true,
        RuleWorkBudget()); () }, "replace-rule-conflict"),
        "old Replace and new A conflict before any CHIR application")
    check(selectRuleAdvicesAcrossSources([replaceWire], target, false, RuleWorkBudget()).size == 1,
        "pure old Replace retains its independent selection path")
    check(rejected({ => selectRuleAdvicesAcrossSources([wire, wire], target, true, RuleWorkBudget()); () },
        "duplicate-source"), "duplicate source is not silently woven twice")
    let otherSession = RuleWirePackage("READY", String.join(Array<String>(32, repeat: "c"),
        delimiter: ""), "other", hash, hash, "_other_init", second.records)
    check(rejected({ => validateRuleSourceSet([wire, otherSession]) }, "build-input-mismatch"),
        "source packages from different build sessions are rejected")
    let otherAbi = RuleWirePackage("READY", session, "other", hash,
        String.join(Array<String>(64, repeat: "d"), delimiter: ""), "_other_init", second.records)
    check(rejected({ => validateRuleSourceSet([wire, otherAbi]) }, "build-input-mismatch"),
        "source packages with different ABI keys are rejected")
    check(rejected({ => selectRuleAdvicesAcrossSources([wire, second], target, true,
        RuleWorkBudget(limit: 0)); () }, "rule-limit"), "one work budget covers all sources")
    check(rejected({ => selectRuleAdvicesAcrossSources(Array<RuleWirePackage>(129, {_ => wire}),
        target, true, RuleWorkBudget()); () }, "source packages exceed 128"),
        "aggregate source limit is checked before allocation or matching")
    check(rejected({ => selectRuleAdvices(RuleWirePackage("PENDING", session, "aspect", hash, hash,
        "", []), target, true, RuleWorkBudget()); () }, "metadata-pending"),
        "PENDING is never selectable")
}

private func benchmarkPreparedSource(): Int64 {
    let session = String.fromUtf8(Array<UInt8>(32, repeat: 97))
    let hash = String.fromUtf8(Array<UInt8>(64, repeat: 97))
    let records = ArrayList<RuleWireRecord>()
    for (i in 0..1024) {
        records.add(RuleWireRecord("R", "", 0, 0, ["bench.R${i}", "shop", "", "*",
            "(**)->*", "global", "false", ""]))
    }
    for (i in 0..512) {
        records.add(RuleWireRecord("A", "", 0, 0,
            ["ENTRY", "advice${i}", "global", "none", "bench.R${i}"]))
    }
    let prepared = PreparedRuleSource(RuleWirePackage("READY", session, "bench", hash, hash, "init", records.toArray()))
    let target = RuleTargetSpec("elsewhere", "", [], "business", "()->Unit", false, false, [])
    let budget = RuleWorkBudget()
    for (_ in 0..1000) {
        if (!prepared.select(target, true, budget).isEmpty()) { return 1 }
    }
    println("prepared-sources=1 rules=1024 advices=512 targets=1000 work=${budget.used}")
    return 0
}

main() {
    if (getCommandLine().contains("--benchmark")) { return benchmarkPreparedSource() }
    contextTests()
    for (a in [false, true]) {
        for (b in [false, true]) {
            for (c in [false, true]) {
                let resolve = {id: String => match (id) {
                    case "p.A" => a
                    case "p.B" => b
                    case "p.C" => c
                    case _ => throw IllegalArgumentException("unknown-rule: ${id}")
                }}
                for ((text, expected) in [
                    ("A AND B OR C", (a && b) || c), ("A OR B AND C", a || (b && c)),
                    ("NOT A AND B", (!a) && b), ("NOT (A OR B) AND C", !(a || b) && c),
                    ("A OR A", a), ("NOT NOT A", a), ("A AND NOT (B OR C)", a && !(b || c)),
                    ("(A OR B) AND (A OR C)", (a || b) && (a || c))]) {
                    let program = parseRuleExpression("p", text)
                    validateRuleProgram("p", program)
                    check(evaluateRuleProgram(program, resolve, RuleWorkBudget()) == expected, text)
                }
            }
        }
    }
    check(parseRuleExpression("p", " 甲\tAND\nNOT 乙\r")[0].operation == "REF:p.甲", "Unicode names")
    for (bad in ["", " ", "A B", "A(B)", "A NOT B", "A AND", "OR A", "()", "(A", "A)",
        "A && B", "A || B", "a.b", "A-B", "_", "3Rule", "A, B"]) {
        check(rejected({ => parseRuleExpression("p", bad); () }, "UTF-8 byte"), "reject ${bad}")
    }
    check(rejected({ => parseRuleExpression("p", "甲 AND @乙"); () }, "byte 8"), "byte not rune offset")
    let nested32 = String.fromUtf8(Array<UInt8>(32, repeat: 40)) + "A" + String.fromUtf8(Array<UInt8>(32, repeat: 41))
    check(parseRuleExpression("p", nested32).size == 1, "32 brackets")
    check(rejected({ => parseRuleExpression("p", "(" + nested32 + ")"); () }, "nesting"), "33 brackets")
    let longAnd = String.join(Array<String>(128, repeat: "A"), delimiter: " AND ")
    check(parseRuleExpression("p", longAnd).size == 255, "long left associative chain")
    check(rejected({ => parseRuleExpression("p", longAnd + " AND A"); () }, "token count"), "257 tokens")
    let longSpace = String.fromUtf8(Array<UInt8>(4095, repeat: 32)) + "A"
    check(parseRuleExpression("p", longSpace).size == 1, "4096 bytes")
    check(rejected({ => parseRuleExpression("p", longSpace + " "); () }, "4096 bytes"), "4097 bytes")
    check(rejected({ => validateRuleProgram("p", [RuleToken("REF:other.A")]); () }, "cross-package"), "namespace")
    check(rejected({ => validateRuleProgram("p", [RuleToken("AND")]); () }, "underflow"), "wire underflow")
    check(rejected({ => validateRuleProgram("p", [RuleToken("REF:p.A"), RuleToken("REF:p.B")]); () }, "one result"), "wire leftovers")
    let visits = [0]
    let orProgram = parseRuleExpression("p", "A OR B")
    check(evaluateRuleProgram(orProgram, {id => visits[0]++; id == "p.A"}, RuleWorkBudget()), "OR result")
    check(visits[0] == 2, "OR does not hide unknown annotation state")
    let budget = RuleWorkBudget(limit: 3)
    evaluateRuleProgram(orProgram, {_ => false}, budget)
    check(budget.used == 3, "exact budget allowed")
    check(rejected({ => budget.charge(1, "next"); () }, "rule-limit"), "budget overrun")
    check(rejected({ => RuleWorkBudget(limit: -1); () }, "rule-limit"), "negative budget")
    graphTests()
    atomTests()
    wireTests()
    selectionTests()
    println("checks=${checks}, failures=${failures}")
    return if (failures == 0) { 0 } else { 1 }
}
