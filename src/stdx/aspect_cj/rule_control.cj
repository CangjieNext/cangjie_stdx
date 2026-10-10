/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj

import std.collection.*
import stdx.chir.*

private const CONTROL_PREFIX = "stdx.aspect_cj."

/** Only semantically resolved declarations from this package are controls. */
protected func controlAnnotationKind(annotation: ResolvedAnnotation): ?String {
    if (!annotation.qualifiedClassName.startsWith(CONTROL_PREFIX) ||
        annotation.declarationSymbol.isEmpty()) { return None }
    let kind = annotation.qualifiedClassName[CONTROL_PREFIX.size..]
    match (kind) {
        case "PointcutRule" | "PointcutExpression" | "InsertAtEntryByRule" |
            "InsertAtExitByRule" | "InsertAtEntry" | "InsertAtExit" | "ReplaceFuncBody" => Some(kind)
        case _ => None
    }
}

/** Validated named values; no positional legacy-argValues interpretation. */
protected class RuleControlFields {
    private let strings: HashMap<String, String>
    private let bools: HashMap<String, Bool>

    internal init(strings: HashMap<String, String>, bools: HashMap<String, Bool>) {
        this.strings = strings
        this.bools = bools
    }

    public func string(name: String): String {
        return strings.get(name).getOrThrow({ => IllegalArgumentException("invalid-control-field: ${name}") })
    }

    public func boolean(name: String): Bool {
        return bools.get(name).getOrThrow({ => IllegalArgumentException("invalid-control-field: ${name}") })
    }
}

protected func readControlFields(annotation: ResolvedAnnotation, kind: String): RuleControlFields {
    if (controlAnnotationKind(annotation) != Some(kind)) {
        throw IllegalArgumentException("invalid-control-identity: ${annotation.qualifiedClassName}")
    }
    var requiredStrings: Array<String> = []
    var requiredBools: Array<String> = []
    match (kind) {
        case "PointcutRule" =>
            requiredStrings = ["packageName", "className", "methodName", "funcTypeStr", "targetKind", "annotationName"]
            requiredBools = ["recursive"]
        case "PointcutExpression" =>
            requiredStrings = ["packageScope", "expression"]
            requiredBools = []
        case "InsertAtEntryByRule" | "InsertAtExitByRule" =>
            requiredStrings = ["rule"]
            requiredBools = []
        case "InsertAtEntry" | "InsertAtExit" =>
            requiredStrings = ["packageName", "className", "methodName", "funcTypeStr"]
            requiredBools = ["isStatic", "recursive"]
        case "ReplaceFuncBody" =>
            requiredStrings = ["packageName", "className", "methodName"]
            requiredBools = ["isStatic", "recursive"]
        case _ => throw IllegalArgumentException("invalid-control-identity: ${kind}")
    }
    let fields = annotation.scalarFields.getOrThrow({ =>
        IllegalArgumentException("annotation-fields-unavailable: ${annotation.qualifiedClassName}") })
    if (fields.size != requiredStrings.size + requiredBools.size) {
        throw IllegalArgumentException("invalid-control-field-count: ${annotation.qualifiedClassName}")
    }
    let strings = HashMap<String, String>()
    let bools = HashMap<String, Bool>()
    let names = HashSet<String>()
    for (field in fields) {
        if (!names.add(field.name)) {
            throw IllegalArgumentException("duplicate-control-field: ${field.name}")
        }
        match (field.value) {
            case AnnotationScalarValue.StringValue(value) =>
                if (!requiredStrings.contains(field.name)) {
                    throw IllegalArgumentException("invalid-control-field-type: ${field.name}")
                }
                strings[field.name] = value
            case AnnotationScalarValue.BoolValue(value) =>
                if (!requiredBools.contains(field.name)) {
                    throw IllegalArgumentException("invalid-control-field-type: ${field.name}")
                }
                bools[field.name] = value
        }
    }
    for (name in requiredStrings) {
        if (!strings.contains(name)) { throw IllegalArgumentException("missing-control-field: ${name}") }
    }
    for (name in requiredBools) {
        if (!bools.contains(name)) { throw IllegalArgumentException("missing-control-field: ${name}") }
    }
    return RuleControlFields(strings, bools)
}

protected func atomFromControl(fields: RuleControlFields): RuleAtomSpec {
    let atom = RuleAtomSpec(fields.string("packageName"), fields.string("className"),
        fields.string("methodName"), fields.string("funcTypeStr"), fields.string("targetKind"),
        fields.boolean("recursive"), fields.string("annotationName"))
    validateRuleAtom(atom)
    return atom
}
