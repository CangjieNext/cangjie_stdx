/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

/**
 * One annotation occurrence in CHIR, corresponding to source like `@ClassName[k1=v1, k2=v2]`.
 *
 * Stores the annotation class name as written in source and a map from parameter names to
 * string values. Callers may construct instances for tests or plugins; the compiler pipeline
 * also builds these when lowering source annotations.
 */
public class Annotation <: ToString {
    internal let _classSrcCodeName: String

    internal var _fields = HashMap<String, String>()

    /**
     * Renders this annotation as `@ClassName[k1=v1, k2=v2, ...]`.
     * @return Text form suitable for debugging and dumps.
     */
    public func toString(): String {
        let result = StringBuilder()
        result.append("@")
        result.append(_classSrcCodeName)
        result.append("[")
        result.append(String.join(
            _fields.toArray().map<String>({ pair => pair[0] + "=" + pair[1] }), delimiter: ", "))
        result.append("]")
        return result.toString()
    }

    /**
     * Source-level name of the annotation class (e.g. `MyAnno`).
     * @type { String }
     */
    public prop classSrcCodeName: String {
        get() {
            return _classSrcCodeName
        }
    }

    /**
     * Looks up the value for a named annotation parameter.
     * @param fieldName Parameter name as in source (matches keys in `toString()` output).
     * @return `Some(value)` if the parameter exists, otherwise `None`.
     */
    public func getFieldValue(fieldName: String): ?String {
        return _fields.get(fieldName)
    }

    /**
     * Sets or overwrites an annotation parameter value.
     * @param fieldName Parameter name.
     * @param value String form of the value (as stored for CHIR).
     */
    public func setFieldValue(fieldName: String, value: String): Unit {
        _fields[fieldName] = value
    }

    /**
     * Creates an annotation with the given class name and an empty parameter map.
     * @param classSrcCodeName Annotation class name as written in source.
     */
    public init(classSrcCodeName: String) {
        this._classSrcCodeName = classSrcCodeName
    }
}

/**
 * Package-internal holder for a list of `Annotation` on one CHIR node.
 *
 * Not exported as public API: external code should use `Array<Annotation>` exposed on
 * `MemberVar` and `EnumCtorInfo`. This type backs those views and may still appear in
 * internal compiler APIs inside `stdx.chir`.
 */
internal class AnnoInfo <: ToString {
    // annotation factory function mangled name
    internal var _identifier: String = "none"

    // @class1Name[field1=value1, field2=value2]
    // @class2Name[field1=value1, field2=value2]
    // func foo() { ... }
    internal var _annoClasses = ArrayList<Annotation>()

    /**
     * Concatenates each annotation's `toString()` on its own line.
     * @return Multi-line debug text; may end with a trailing newline when non-empty.
     */
    public func toString(): String {
        let result = StringBuilder()
        result.append(String.join(
            _annoClasses.toArray().map<String>({ anno => anno.toString() }), delimiter: "\n"))
        return result.toString()
    }

    internal init() {
        this._identifier = "none"
        this._annoClasses = ArrayList<Annotation>()
    }

    internal init(identifier: String) {
        this._identifier = identifier
        this._annoClasses = ArrayList<Annotation>()
    }

    internal init(identifier: String, annoClasses: Array<Annotation>) {
        this._identifier = identifier
        this._annoClasses = ArrayList<Annotation>.of(annoClasses)
    }
}
