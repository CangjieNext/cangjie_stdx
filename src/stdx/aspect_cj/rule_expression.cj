/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj

import std.collection.*

protected const RULE_EXPRESSION_BYTES: Int64 = 4096
protected const RULE_EXPRESSION_TOKENS: Int64 = 256
protected const RULE_EXPRESSION_NESTING: Int64 = 32
protected const RULE_PACKAGE_COUNT: Int64 = 4096
protected const RULE_PACKAGE_TOKENS: Int64 = 262144
protected const RULE_REFERENCE_PATH: Int64 = 64

protected struct RuleToken {
    let operation: String
    let byteOffset: Int64

    public init(operation: String, byteOffset!: Int64 = 0) {
        this.operation = operation
        this.byteOffset = byteOffset
    }
}

// One budget belongs to the entire target package, not one expression/function.
protected class RuleWorkBudget {
    let limit: Int64
    private var consumed: Int64 = 0

    public init(limit!: Int64 = 100000000) {
        if (limit < 0) {
            throw IllegalArgumentException("rule-limit: negative work budget")
        }
        this.limit = limit
    }

    public prop used: Int64 { get() { consumed } }

    public func charge(units: Int64, context: String): Unit {
        // Subtraction avoids overflow before checking the limit.
        if (units < 0 || units > limit - consumed) {
            throw IllegalArgumentException("rule-limit: work ${consumed}/${limit}, ${context}")
        }
        consumed += units
    }
}

private func expressionError(offset: Int64, reason: String): Nothing {
    throw IllegalArgumentException("invalid-rule-expression: UTF-8 byte ${offset}: ${reason}")
}

private func ruleOperatorPrecedence(operation: String): Int64 {
    match (operation) {
        case "NOT" => 3
        case "AND" => 2
        case "OR" => 1
        case _ => 0
    }
}

private func isRuleSpace(ch: UInt8): Bool {
    return ch == 32 || ch == 9 || ch == 10 || ch == 13
}

private func isRuleNameByte(ch: UInt8, first: Bool): Bool {
    // Non-ASCII names are resolved against real source declarations by the
    // graph validator. Do not normalize their UTF-8 spelling or split a rune.
    return ch >= 128 || ch == 95 || (ch >= 65 && ch <= 90) || (ch >= 97 && ch <= 122) ||
        (!first && ch >= 48 && ch <= 57)
}

protected func validateRuleSourcePackage(sourcePackage: String): Unit {
    if (sourcePackage.isEmpty() || sourcePackage.size > 512) {
        throw IllegalArgumentException("invalid-rule-package")
    }
    for (segment in sourcePackage.split(".", removeEmpty: false)) {
        if (segment.isEmpty() || segment == "_") { throw IllegalArgumentException("invalid-rule-package") }
        let bytes = segment.toArray()
        for (i in 0..bytes.size) {
            if (!isRuleNameByte(bytes[i], i == 0)) { throw IllegalArgumentException("invalid-rule-package") }
        }
    }
}

/** Shunting-yard parser: no recursive descent or expansion of shared rules. */
protected func parseRuleExpression(sourcePackage: String, expression: String): Array<RuleToken> {
    validateRuleSourcePackage(sourcePackage)
    if (expression.size > RULE_EXPRESSION_BYTES) {
        expressionError(RULE_EXPRESSION_BYTES, "expression exceeds 4096 bytes")
    }
    let bytes = expression.toArray()
    let output = ArrayList<RuleToken>()
    let operators = ArrayList<RuleToken>()
    var index: Int64 = 0
    var tokenCount: Int64 = 0
    var nesting: Int64 = 0
    var needsOperand = true
    while (index < bytes.size) {
        if (isRuleSpace(bytes[index])) {
            index++
            continue
        }
        let start = index
        if (bytes[index] == 40) {
            if (!needsOperand) { expressionError(index, "expected AND or OR") }
            operators.add(RuleToken("(", byteOffset: index))
            nesting++
            if (nesting > RULE_EXPRESSION_NESTING) { expressionError(index, "nesting exceeds 32") }
            index++
            continue
        }
        if (bytes[index] == 41) {
            if (needsOperand) { expressionError(index, "expected a rule before ')'") }
            while (!operators.isEmpty() && operators[operators.size - 1].operation != "(") {
                let token = operators.remove(at: operators.size - 1)
                output.add(token)
                if (token.operation == "NOT") { nesting-- }
            }
            if (operators.isEmpty()) { expressionError(index, "unmatched ')'") }
            operators.remove(at: operators.size - 1)
            nesting--
            index++
            while (!operators.isEmpty() && operators[operators.size - 1].operation == "NOT") {
                output.add(operators.remove(at: operators.size - 1))
                nesting--
            }
            continue
        }
        if (!isRuleNameByte(bytes[index], true)) { expressionError(index, "invalid rule-name character") }
        index++
        while (index < bytes.size && isRuleNameByte(bytes[index], false)) { index++ }
        let word = String.fromUtf8(bytes[start..index])
        tokenCount++
        if (tokenCount > RULE_EXPRESSION_TOKENS) { expressionError(start, "token count exceeds 256") }
        if (word == "NOT") {
            if (!needsOperand) { expressionError(start, "expected AND or OR") }
            operators.add(RuleToken(word, byteOffset: start))
            nesting++
            if (nesting > RULE_EXPRESSION_NESTING) { expressionError(start, "nesting exceeds 32") }
        } else if (word == "AND" || word == "OR") {
            if (needsOperand) { expressionError(start, "binary operator has no left operand") }
            while (!operators.isEmpty() &&
                ruleOperatorPrecedence(operators[operators.size - 1].operation) >= ruleOperatorPrecedence(word)) {
                let token = operators.remove(at: operators.size - 1)
                output.add(token)
                if (token.operation == "NOT") { nesting-- }
            }
            operators.add(RuleToken(word, byteOffset: start))
            needsOperand = true
        } else {
            if (!needsOperand) { expressionError(start, "expected AND or OR") }
            let id = sourcePackage + "." + word
            if (id.size > 512 || word == "_") { expressionError(start, "invalid rule ID or ID exceeds 512 bytes") }
            output.add(RuleToken("REF:" + id, byteOffset: start))
            needsOperand = false
            while (!operators.isEmpty() && operators[operators.size - 1].operation == "NOT") {
                output.add(operators.remove(at: operators.size - 1))
                nesting--
            }
        }
    }
    if (needsOperand) { expressionError(index, "expected a rule") }
    while (!operators.isEmpty()) {
        let token = operators.remove(at: operators.size - 1)
        if (token.operation == "(") { expressionError(token.byteOffset, "unclosed '('") }
        output.add(token)
    }
    return output.toArray()
}

/** Shared validator for parser output and wire-v4 postfix input. */
protected func validateRuleProgram(sourcePackage: String, program: Array<RuleToken>): Array<String> {
    validateRuleSourcePackage(sourcePackage)
    if (program.isEmpty() || program.size > RULE_EXPRESSION_TOKENS) {
        throw IllegalArgumentException("rule-limit: invalid postfix token count")
    }
    let refs = ArrayList<String>()
    var depth: Int64 = 0
    for (token in program) {
        let op = token.operation
        if (op.startsWith("REF:")) {
            let id = op[4..]
            let prefix = sourcePackage + "."
            if (id.size > 512 || !id.startsWith(prefix) || id.size == prefix.size || id[prefix.size..].contains(".")) {
                expressionError(token.byteOffset, "cross-package or invalid rule reference")
            }
            let name = id[prefix.size..]
            let bytes = name.toArray()
            if (name == "_" || name == "AND" || name == "OR" || name == "NOT") {
                expressionError(token.byteOffset, "reserved or invalid rule reference")
            }
            for (i in 0..bytes.size) {
                if (!isRuleNameByte(bytes[i], i == 0)) { expressionError(token.byteOffset, "invalid rule reference") }
            }
            refs.add(id)
            depth++
        } else if (op == "NOT") {
            if (depth < 1) { expressionError(token.byteOffset, "postfix NOT underflow") }
        } else if (op == "AND" || op == "OR") {
            if (depth < 2) { expressionError(token.byteOffset, "postfix binary operator underflow") }
            depth--
        } else {
            expressionError(token.byteOffset, "unknown postfix operator")
        }
    }
    if (depth != 1) { expressionError(0, "postfix program must yield one result") }
    return refs.toArray()
}

/** Iterative postfix evaluation; every operand is visited (no unknown-data short circuit). */
protected func evaluateRuleProgram(program: Array<RuleToken>, resolve: (String) -> Bool,
    budget: RuleWorkBudget): Bool {
    let values = ArrayList<Bool>()
    for (token in program) {
        budget.charge(1, "postfix token")
        let op = token.operation
        if (op.startsWith("REF:")) {
            values.add(resolve(op[4..]))
        } else if (op == "NOT" && !values.isEmpty()) {
            values[values.size - 1] = !values[values.size - 1]
        } else if ((op == "AND" || op == "OR") && values.size >= 2) {
            let right = values.remove(at: values.size - 1)
            let left = values[values.size - 1]
            values[values.size - 1] = if (op == "AND") { left && right } else { left || right }
        } else {
            expressionError(token.byteOffset, "invalid postfix program")
        }
    }
    if (values.size != 1) { expressionError(0, "postfix program must yield one result") }
    return values[0]
}
