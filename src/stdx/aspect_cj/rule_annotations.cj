/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj

/** Describes one reusable, conjunctive pointcut on a top-level rule class. */
@Annotation[target: [Type]]
public class PointcutRule {
    let packageName: String
    let className: String
    let methodName: String
    let funcTypeStr: String
    let targetKind: String
    let recursive: Bool
    let annotationName: String

    public const init(packageName!: String, className!: String, methodName!: String,
        funcTypeStr!: String, targetKind!: String, recursive!: Bool, annotationName!: String) {
        this.packageName = packageName
        this.className = className
        this.methodName = methodName
        this.funcTypeStr = funcTypeStr
        this.targetKind = targetKind
        this.recursive = recursive
        this.annotationName = annotationName
    }
}

/** Combines rules from the same aspect package, within an explicit package scope. */
@Annotation[target: [Type]]
public class PointcutExpression {
    let packageScope: String
    let expression: String

    public const init(packageScope!: String, expression!: String) {
        this.packageScope = packageScope
        this.expression = expression
    }
}

/** Selects a package-qualified rule for a global or static Entry advice. */
@Annotation[target: [GlobalFunction, MemberFunction]]
public class InsertAtEntryByRule {
    let rule: String

    public const init(rule!: String) {
        this.rule = rule
    }
}

/** Selects a package-qualified rule for a normal-return Exit advice. */
@Annotation[target: [GlobalFunction, MemberFunction]]
public class InsertAtExitByRule {
    let rule: String

    public const init(rule!: String) {
        this.rule = rule
    }
}
