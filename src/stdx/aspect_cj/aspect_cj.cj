/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0 
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj

import std.collection.*
import stdx.chir.*

protected const ANNO_INFO_FILE_SUFFIX = ".annoinfo"
protected const PACKAGE_NAME_CONNECTOR = "-"
protected const INSERT_AT_ENTRY_ANNO_CLASS_NAME = "InsertAtEntry"
protected const INSERT_AT_EXIT_ANNO_CLASS_NAME = "InsertAtExit"
protected const REPLACE_FUNC_BODY_ANNO_CLASS_NAME = "ReplaceFuncBody"
protected const ANNO_INFO_VERSION_HEADER = "#aspect_cj_annoinfo_v2"
protected const WILDCARD_ANNO_INFO_TARGET = "__aspect_cj_wildcard__"

@Annotation
public class InsertAtEntry {
    let packageName: String
    let className: String
    let methodName: String
    let isStatic: Bool
    let recursive: Bool
    let funcTypeStr: String
    public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool, funcTypeStr!: String) {
        this.packageName = packageName
        this.className = className
        this.methodName = methodName
        this.isStatic = isStatic
        this.recursive = recursive
        this.funcTypeStr = funcTypeStr
    }
}

@Annotation
public class InsertAtExit {
    let packageName: String
    let className: String
    let methodName: String
    let isStatic: Bool
    let recursive: Bool
    let funcTypeStr: String
    public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool, funcTypeStr!: String) {
        this.packageName = packageName
        this.className = className
        this.methodName = methodName
        this.isStatic = isStatic
        this.recursive = recursive
        this.funcTypeStr = funcTypeStr
    }
}

@Annotation
public class ReplaceFuncBody {
    let packageName: String
    let className: String
    let methodName: String
    let isStatic: Bool
    let recursive: Bool
    public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool) {
        this.packageName = packageName
        this.className = className
        this.methodName = methodName
        this.isStatic = isStatic
        this.recursive = recursive
    }
}

protected struct To {
    let packageName: String
    let className: String
    let methodName: String
    let funcTypeStr: String
    let isStatic: Bool
    let recursively: Bool
    public init(packageName: String, className: String, methodName: String, funcTypeStr: String, isStatic: Bool, recursively: Bool) {
        this.packageName = packageName
        this.className = className
        this.methodName = methodName
        this.funcTypeStr = funcTypeStr
        this.isStatic = isStatic
        this.recursively = recursively
    }
}

protected struct Insert {
    let packageName: String
    let methodMangledName: String
    let paramsNum: Int64
    let isMemberFunc: Bool
    let isStatic: Bool
    let usesPointcutArgsArray: Bool
    public init(packageName: String, methodMangledName: String, paramsNum: Int64, isMemberFunc: Bool, isStatic: Bool, usesPointcutArgsArray!: Bool = false) {
        this.packageName = packageName
        this.methodMangledName = methodMangledName
        this.paramsNum = paramsNum
        this.isMemberFunc = isMemberFunc
        this.isStatic = isStatic
        this.usesPointcutArgsArray = usesPointcutArgsArray
    }
}

protected struct OutputInfo {
    let annoClassName: String
    let insert: Insert
    let to: To
    public init(annoClassName: String, insert: Insert, to: To) {
        this.annoClassName = annoClassName
        this.insert = insert
        this.to = to
    }
}

protected func getFuncOuterTypeName(f: Function): String {
    if (!f.isMemberMethod()) {
        return ""
    }
    let outerType = f.declaredParent.getOrThrow().ty
    if (let Some(c) <- (outerType as CustomType)) {
        return c.def.srcCodeName
    } else {
        return outerType.qualifiedName
    }
}

protected func mapArrayTo<T, R>(array: Array<T>, f: (T) -> R): Array<R> {
    var result = ArrayList<R>()
    for (i in array) {
        result.add(f(i))
    }
    return result.toArray()
}

protected func isInsertAnno(item: String): Bool {
    return item == INSERT_AT_ENTRY_ANNO_CLASS_NAME || item == INSERT_AT_EXIT_ANNO_CLASS_NAME
}

protected func isReplaceBodyAnno(item: String): Bool {
    return item == REPLACE_FUNC_BODY_ANNO_CLASS_NAME
}

protected func matchNamePattern(pattern: String, value: String): Bool {
    if (pattern == value || pattern == "*") {
        return true
    }
    let patternChars = pattern.toArray()
    let valueChars = value.toArray()
    var previous = Array<Bool>(valueChars.size + 1, repeat: false)
    previous[0] = true
    for (patternChar in patternChars) {
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

protected func matchQualifiedNamePattern(pattern: String, value: String): Bool {
    if (pattern == value) {
        return true
    }
    let patternSegments = pattern.split(".", removeEmpty: false)
    let valueSegments = value.split(".", removeEmpty: false)
    var previous = Array<Bool>(valueSegments.size + 1, repeat: false)
    previous[0] = true
    for (patternSegment in patternSegments) {
        var current = Array<Bool>(valueSegments.size + 1, repeat: false)
        if (patternSegment == "**") {
            current[0] = previous[0]
            for (valueIndex in 1..valueSegments.size + 1) {
                current[valueIndex] = previous[valueIndex] || current[valueIndex - 1]
            }
        } else {
            for (valueIndex in 1..valueSegments.size + 1) {
                current[valueIndex] = previous[valueIndex - 1] &&
                    matchNamePattern(patternSegment, valueSegments[valueIndex - 1])
            }
        }
        previous = current
    }
    return previous[valueSegments.size]
}

private func splitTopLevelParameters(value: String): ?Array<String> {
    let text = value.trimAscii()
    if (text.isEmpty()) {
        return Some(Array<String>())
    }
    let result = ArrayList<String>()
    let bytes = text.toArray()
    var parameterStart: Int64 = 0
    var parenthesisDepth: Int64 = 0
    var angleDepth: Int64 = 0
    var squareDepth: Int64 = 0
    for (index in 0..bytes.size) {
        let ch = bytes[index]
        if (ch == 40) {
            parenthesisDepth++
        } else if (ch == 41) {
            parenthesisDepth--
        } else if (ch == 60) {
            angleDepth++
        } else if (ch == 62 && (index == 0 || bytes[index - 1] != 45)) {
            angleDepth--
        } else if (ch == 91) {
            squareDepth++
        } else if (ch == 93) {
            squareDepth--
        }
        if (parenthesisDepth < 0 || angleDepth < 0 || squareDepth < 0) {
            return None
        }
        if (ch == 44 && parenthesisDepth == 0 && angleDepth == 0 && squareDepth == 0) {
            let parameter = unsafe { String.fromUtf8Unchecked(bytes[parameterStart..index]) }.trimAscii()
            if (parameter.isEmpty()) {
                return None
            }
            result.add(parameter)
            parameterStart = index + 1
        }
    }
    let parameter = unsafe { String.fromUtf8Unchecked(bytes[parameterStart..]) }.trimAscii()
    if (parenthesisDepth != 0 || angleDepth != 0 || squareDepth != 0 || parameter.isEmpty()) {
        return None
    }
    result.add(parameter)
    return Some(result.toArray())
}

protected struct FunctionTypePattern {
    let parameters: Array<String>
    let returnType: String
    public init(parameters: Array<String>, returnType: String) {
        this.parameters = parameters
        this.returnType = returnType
    }
}

protected func parseFunctionTypePattern(value: String): ?FunctionTypePattern {
    let text = value.trimAscii()
    if (text.size < 4 || !text.startsWith("(")) {
        return None
    }
    let bytes = text.toArray()
    var depth: Int64 = 0
    var close: ?Int64 = None
    for (index in 0..bytes.size) {
        let ch = bytes[index]
        if (ch == 40) {
            depth++
        } else if (ch == 41) {
            depth--
        }
        if (depth < 0) {
            return None
        }
        if (depth == 0) {
            close = Some(index)
            break
        }
    }
    if (close.isNone()) {
        return None
    }
    let closeIndex = close.getOrThrow()
    let suffix = unsafe { String.fromUtf8Unchecked(bytes[closeIndex + 1..]) }.trimAscii()
    if (!suffix.startsWith("->")) {
        return None
    }
    let returnType = suffix[2..].trimAscii()
    let parameters = splitTopLevelParameters(unsafe { String.fromUtf8Unchecked(bytes[1..closeIndex]) })
    if (parameters.isNone() || returnType.isEmpty()) {
        return None
    }
    return Some(FunctionTypePattern(parameters.getOrThrow(), returnType))
}

private func normalizeStdCoreTypeName(value: String): String {
    let prefix = "std.core."
    return if (!value.contains("*") && value.startsWith(prefix)) {
        value[prefix.size..]
    } else {
        value
    }
}

protected func matchTypePattern(pattern: String, value: String): Bool {
    return pattern == "*" || matchQualifiedNamePattern(pattern, value) ||
        normalizeStdCoreTypeName(pattern) == normalizeStdCoreTypeName(value)
}

protected func matchFunctionTypePattern(pattern: String, value: String): Bool {
    if (pattern.trimAscii() == value.trimAscii()) {
        return true
    }
    let parsedPattern = parseFunctionTypePattern(pattern)
    let parsedValue = parseFunctionTypePattern(value)
    if (parsedPattern.isNone() || parsedValue.isNone()) {
        return false
    }
    let expected = parsedPattern.getOrThrow()
    let actual = parsedValue.getOrThrow()
    if (!matchTypePattern(expected.returnType, actual.returnType)) {
        return false
    }
    var previous = Array<Bool>(actual.parameters.size + 1, repeat: false)
    previous[0] = true
    for (expectedParameter in expected.parameters) {
        var current = Array<Bool>(actual.parameters.size + 1, repeat: false)
        if (expectedParameter == "**") {
            current[0] = previous[0]
            for (actualIndex in 1..actual.parameters.size + 1) {
                current[actualIndex] = previous[actualIndex] || current[actualIndex - 1]
            }
        } else {
            for (actualIndex in 1..actual.parameters.size + 1) {
                current[actualIndex] = previous[actualIndex - 1] &&
                    matchTypePattern(expectedParameter, actual.parameters[actualIndex - 1])
            }
        }
        previous = current
    }
    return previous[actual.parameters.size]
}

protected func isValidFunctionTypePattern(value: String): Bool {
    let parsed = parseFunctionTypePattern(value)
    if (parsed.isNone() || parsed.getOrThrow().returnType == "**") {
        return false
    }
    // The return type is one type, not another parameter list. Reuse the
    // delimiter-depth check so malformed nested types fail during collection.
    let returnTypes = splitTopLevelParameters(parsed.getOrThrow().returnType)
    if (returnTypes.isNone() || returnTypes.getOrThrow().size != 1) {
        return false
    }
    var variadicWildcards: Int64 = 0
    for (parameter in parsed.getOrThrow().parameters) {
        if (parameter == "**") {
            variadicWildcards++
        }
    }
    return variadicWildcards <= 1
}

protected func containsMetadataControlCharacter(value: String): Bool {
    for (ch in value.toArray()) {
        if (ch == 0 || ch == 10 || ch == 13) {
            return true
        }
    }
    return false
}

protected func isValidPackageNamePattern(value: String): Bool {
    if (value.isEmpty() || value.contains("/") || value.contains("\\") || value.contains("..")) {
        return false
    }
    for (segment in value.split(".", removeEmpty: false)) {
        if (segment.isEmpty()) {
            return false
        }
        if (segment == "**") {
            continue
        }
        var index: Int64 = 0
        for (ch in segment) {
            if (ch == 42) {
                index++
                continue
            }
            if (index == 0) {
                if (!ch.isAsciiLetter() && ch != 95) {
                    return false
                }
            } else if (!ch.isAsciiNumberOrLetter() && ch != 95 && ch != 45) {
                return false
            }
            index++
        }
    }
    return true
}
