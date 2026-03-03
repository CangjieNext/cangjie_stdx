/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

/**
 * @brief Represents information about an annotation class.
 *
 * This class stores the source code name and field values of an annotation class.
 */
public class Annotation <: ToString {
    internal let _classSrcCodeName: String = ""

    internal var _fields = HashMap<String, String>()

    /**
     * @brief Converts this Annotation to its string representation.
     * @return A string representation in the format "@ClassName[field1=value1, field2=value2]".
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
     * @brief Gets the source code name of the annotation class.
     * @return The source code name of the annotation class.
     */
    public prop classSrcCodeName: String {
        get() {
            return _classSrcCodeName
        }
    }

    /**
     * @brief Gets the value of a field in the annotation.
     * @param fieldName The name of the field to retrieve.
     * @return The field value as a string.
     * @throws Exception if the field does not exist.
     */
    public func getFieldValue(fieldName: String): String {
        return _fields.get(fieldName).getOrThrow()
    }

    internal init() {}

}

/**
 * @brief Represents an annotation attached to a CHIR node.
 *
 * An annotation contains an identifier and a list of annotation class information.
 * It is used to store metadata about nodes in the CHIR representation.
 */
public class AnnoInfo <: ToString {
    // annotation factory function mangled name
    internal var _identifier: String = "none"
    // @class1Name[field1=value1, field2=value2]
    // @class2Name[field1=value1, field2=value2]
    // func foo() { ... }

    internal var _annoClasses = ArrayList<Annotation>()

    /**
     * @brief Converts this AnnoInfo to its string representation.
     * @return A string representation with each annotation class on a new line.
     */
    public func toString(): String {
        let result = StringBuilder()
        for (annoClass in _annoClasses) {
            result.append(annoClass.toString())
            result.append("\n")
        }
        return result.toString()
    }

    /**
     * @brief Gets the list of annotation class information.
     * @return An array of Annotation objects representing the annotation classes.
     */
    public prop annoClasses: Array<Annotation> {
        get() {
            return _annoClasses.toArray()
        }
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