/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj

import stdx.chir.*

/** A validated atomic rule. All conditions are conjunctive. */
protected struct RuleAtomSpec {
    let packageName: String
    let className: String
    let methodName: String
    let funcTypeStr: String
    let targetKind: String
    let recursive: Bool
    let annotationName: String

    public init(packageName: String, className: String, methodName: String,
        funcTypeStr: String, targetKind: String, recursive: Bool, annotationName: String) {
        this.packageName = packageName
        this.className = className
        this.methodName = methodName
        this.funcTypeStr = funcTypeStr
        this.targetKind = targetKind
        this.recursive = recursive
        this.annotationName = annotationName
    }
}

/** Frozen source-declaration facts supplied by the target-package preflight. */
protected struct RuleTargetSpec {
    let sourcePackage: String
    let receiverName: String
    let ancestorNames: Array<String>
    let methodName: String
    let concreteSignature: String
    let isMember: Bool
    let isStatic: Bool
    let annotationNames: Array<String>

    public init(sourcePackage: String, receiverName: String, ancestorNames: Array<String>,
        methodName: String, concreteSignature: String, isMember: Bool, isStatic: Bool,
        annotationNames: Array<String>) {
        this.sourcePackage = sourcePackage
        this.receiverName = receiverName
        this.ancestorNames = ancestorNames.clone()
        this.methodName = methodName
        this.concreteSignature = concreteSignature
        this.isMember = isMember
        this.isStatic = isStatic
        this.annotationNames = annotationNames.clone()
    }
}

protected func validateRuleAtom(spec: RuleAtomSpec): Unit {
    if (!isValidPackageNamePattern(spec.packageName)) {
        throw IllegalArgumentException("invalid-rule-field: packageName")
    }
    if (!isValidMetadataPatternText(spec.className) ||
        !isValidMetadataPatternText(spec.methodName) || spec.methodName.isEmpty()) {
        throw IllegalArgumentException("invalid-rule-field: className or methodName")
    }
    if (!isValidMetadataPatternText(spec.funcTypeStr) ||
        !isValidFunctionTypePattern(spec.funcTypeStr)) {
        throw IllegalArgumentException("invalid-rule-field: funcTypeStr")
    }
    if (spec.targetKind != "any" && spec.targetKind != "global" &&
        spec.targetKind != "static" && spec.targetKind != "instance") {
        throw IllegalArgumentException("invalid-rule-field: targetKind")
    }
    if ((spec.targetKind == "global" && !spec.className.isEmpty()) ||
        (spec.recursive && (spec.className.isEmpty() || spec.targetKind == "global"))) {
        throw IllegalArgumentException("invalid-rule-field: className/targetKind/recursive")
    }
    if (!spec.annotationName.isEmpty()) {
        if (spec.annotationName.contains("*") || spec.annotationName.contains("\\") ||
            containsMetadataControlCharacter(spec.annotationName) || !spec.annotationName.contains(".")) {
            throw IllegalArgumentException("invalid-rule-field: annotationName")
        }
        try {
            validateRuleSourcePackage(spec.annotationName)
        } catch (_: IllegalArgumentException) {
            throw IllegalArgumentException("invalid-rule-field: annotationName")
        }
    }
}

/** New-rule glob work is charged per DP cell, before the row is allocated. */
protected func matchNamePatternBudgeted(pattern: String, value: String,
    budget: RuleWorkBudget): Bool {
    if (pattern == value || pattern == "*") {
        budget.charge(1, "glob equality")
        return true
    }
    let patternChars = pattern.toArray()
    let valueChars = value.toArray()
    var previous = Array<Bool>(valueChars.size + 1, repeat: false)
    previous[0] = true
    for (patternChar in patternChars) {
        budget.charge(valueChars.size + 1, "glob DP row")
        var current = Array<Bool>(valueChars.size + 1, repeat: false)
        if (patternChar == 42) {
            current[0] = previous[0]
            for (valueIndex in 1..valueChars.size + 1) {
                current[valueIndex] = previous[valueIndex] || current[valueIndex - 1]
            }
        } else {
            for (valueIndex in 1..valueChars.size + 1) {
                current[valueIndex] = previous[valueIndex - 1] && patternChar == valueChars[valueIndex - 1]
            }
        }
        previous = current
    }
    return previous[valueChars.size]
}

protected func matchQualifiedNamePatternBudgeted(pattern: String, value: String,
    budget: RuleWorkBudget): Bool {
    if (pattern == value) {
        budget.charge(1, "qualified name equality")
        return true
    }
    let patternSegments = pattern.split(".", removeEmpty: false)
    let valueSegments = value.split(".", removeEmpty: false)
    var previous = Array<Bool>(valueSegments.size + 1, repeat: false)
    previous[0] = true
    for (patternSegment in patternSegments) {
        budget.charge(valueSegments.size + 1, "qualified name DP row")
        var current = Array<Bool>(valueSegments.size + 1, repeat: false)
        if (patternSegment == "**") {
            current[0] = previous[0]
            for (valueIndex in 1..valueSegments.size + 1) {
                current[valueIndex] = previous[valueIndex] || current[valueIndex - 1]
            }
        } else {
            for (valueIndex in 1..valueSegments.size + 1) {
                current[valueIndex] = previous[valueIndex - 1] &&
                    matchNamePatternBudgeted(patternSegment, valueSegments[valueIndex - 1], budget)
            }
        }
        previous = current
    }
    return previous[valueSegments.size]
}

/** The v4 matcher charges nested type parsing and every parameter DP row. */
protected func matchTypePatternBudgeted(pattern: String, value: String,
    budget: RuleWorkBudget): Bool {
    return matchTypeBudgetedDepth(pattern, value, budget, 0)
}

private func matchTypeBudgetedDepth(pattern: String, value: String,
    budget: RuleWorkBudget, depth: Int64): Bool {
    if (depth > 64) { throw IllegalArgumentException("rule-limit: type nesting exceeds 64") }
    budget.charge(pattern.size + value.size + 1, "type pattern scan")
    if (pattern == "*") { return true }
    if (pattern.startsWith("(") || value.startsWith("(")) {
        return matchFunctionTypeBudgetedDepth(pattern, value, budget, depth + 1)
    }
    if (!pattern.contains("<") && value.contains("<")) {
        let actual = parseParameterizedTypeName(value)
        return actual.isSome() && matchTypeBudgetedDepth(pattern,
            actual.getOrThrow().base, budget, depth + 1)
    }
    if (pattern.contains("<") || value.contains("<")) {
        let expected = parseParameterizedTypeName(pattern)
        let actual = parseParameterizedTypeName(value)
        if (expected.isNone() || actual.isNone()) { return false }
        let left = expected.getOrThrow()
        let right = actual.getOrThrow()
        if (left.arguments.size != right.arguments.size ||
            !matchTypeBudgetedDepth(left.base, right.base, budget, depth + 1)) { return false }
        for (index in 0..left.arguments.size) {
            if (!matchTypeBudgetedDepth(left.arguments[index], right.arguments[index], budget, depth + 1)) {
                return false
            }
        }
        return true
    }
    return matchQualifiedNamePatternBudgeted(pattern, value, budget) ||
        normalizeStdCoreTypeName(pattern) == normalizeStdCoreTypeName(value)
}

protected func matchFunctionTypePatternBudgeted(pattern: String, value: String,
    budget: RuleWorkBudget): Bool {
    return matchFunctionTypeBudgetedDepth(pattern, value, budget, 0)
}

private func matchFunctionTypeBudgetedDepth(pattern: String, value: String,
    budget: RuleWorkBudget, depth: Int64): Bool {
    if (depth > 64) { throw IllegalArgumentException("rule-limit: type nesting exceeds 64") }
    budget.charge(pattern.size + value.size + 1, "function type scan")
    if (pattern.trimAscii() == value.trimAscii()) { return true }
    let parsedPattern = parseFunctionTypePattern(pattern)
    let parsedValue = parseFunctionTypePattern(value)
    if (parsedPattern.isNone() || parsedValue.isNone()) { return false }
    let expected = parsedPattern.getOrThrow()
    let actual = parsedValue.getOrThrow()
    if (!matchTypeBudgetedDepth(expected.returnType, actual.returnType, budget, depth + 1)) {
        return false
    }
    var previous = Array<Bool>(actual.parameters.size + 1, repeat: false)
    previous[0] = true
    for (expectedParameter in expected.parameters) {
        budget.charge(actual.parameters.size + 1, "function type DP row")
        var current = Array<Bool>(actual.parameters.size + 1, repeat: false)
        if (expectedParameter == "**") {
            current[0] = previous[0]
            for (actualIndex in 1..actual.parameters.size + 1) {
                current[actualIndex] = previous[actualIndex] || current[actualIndex - 1]
            }
        } else {
            for (actualIndex in 1..actual.parameters.size + 1) {
                current[actualIndex] = previous[actualIndex - 1] &&
                    matchTypeBudgetedDepth(expectedParameter,
                        actual.parameters[actualIndex - 1], budget, depth + 1)
            }
        }
        previous = current
    }
    return previous[actual.parameters.size]
}

/** The graph evaluates this only after validation and Complete-snapshot checks. */
protected func matchRuleAtom(spec: RuleAtomSpec, target: RuleTargetSpec, budget: RuleWorkBudget): Bool {
    budget.charge(1, "atomic rule package")
    if (!matchQualifiedNamePatternBudgeted(spec.packageName, target.sourcePackage, budget)) { return false }
    budget.charge(1, "atomic rule target kind")
    match (spec.targetKind) {
        case "global" => if (target.isMember) { return false }
        case "static" => if (!target.isMember || !target.isStatic) { return false }
        case "instance" => if (!target.isMember || target.isStatic) { return false }
        case _ => ()
    }
    if (!spec.className.isEmpty()) {
        if (!target.isMember) { return false }
        budget.charge(1, "atomic rule receiver")
        var matches = matchNamePatternBudgeted(spec.className, target.receiverName, budget)
        if (!matches && spec.recursive) {
            for (name in target.ancestorNames) {
                budget.charge(1, "atomic rule ancestor")
                if (matchNamePatternBudgeted(spec.className, name, budget)) { matches = true; break }
            }
        }
        if (!matches) { return false }
    }
    budget.charge(1, "atomic rule method")
    if (!matchNamePatternBudgeted(spec.methodName, target.methodName, budget)) { return false }
    budget.charge(1, "atomic rule signature")
    if (!matchFunctionTypePatternBudgeted(spec.funcTypeStr, target.concreteSignature, budget)) { return false }
    if (!spec.annotationName.isEmpty()) {
        for (name in target.annotationNames) {
            budget.charge(1, "atomic rule annotation identity")
            if (name == spec.annotationName) { return true }
        }
        return false
    }
    return true
}

/** Derive source facts from the actual CHIR declaration, never from an import alias. */
protected func ruleTargetFromFunction(f: Function): RuleTargetSpec {
    if (f.isImported() || (f.isCompilerAdd() && f.aspectSourceOrigin.isEmpty()) || f.body.isNone()) {
        throw IllegalArgumentException("invalid-rule-target: not a source execution body ${f.srcCodeName}")
    }
    let snapshot = f.annotationSnapshot
    if (!snapshot.isComplete) {
        throw IllegalArgumentException("annotation-metadata-unavailable: function ${f.srcCodeName}")
    }
    let annotations = mapArrayTo(snapshot.items.getOrThrow(), {item => item.qualifiedClassName})
    var receiver = ""
    var ancestors: Array<String> = []
    if (let Some(parent) <- f.declaredParent) {
        let receiverDef: ?CustomTypeDef = if (let Some(ext) <- (parent as ExtendDef)) {
            if (let Some(custom) <- (ext.extendedType as CustomType)) { Some(custom.def) } else { None }
        } else { Some(parent) }
        if (let Some(def) <- receiverDef) {
            receiver = def.srcCodeName
            ancestors = mapArrayTo(def.getSuperTypesRecusively(), {parentType => parentType.classLikeDef.srcCodeName})
        }
    }
    var parameters = f.funcType.paramTypes
    if (f.isInstanceMemberMethod()) {
        if (parameters.isEmpty()) { throw IllegalArgumentException("invalid-rule-target: missing receiver") }
        (_, parameters) = parameters.splitAt(1)
    }
    let signature = qualifiedNameWithTypeArgs(FuncType.get(parameters, f.funcType.returnType))
    return RuleTargetSpec(f.packageName, receiver, ancestors, f.srcCodeName, signature,
        f.isMemberMethod(), f.isStatic(), annotations)
}
