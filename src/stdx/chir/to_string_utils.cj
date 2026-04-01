/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

internal const INDENT_SPACE: UInt64 = 2
internal func indentToString(indent: UInt64): String {
    return StringBuilder(r' ', Int64(indent)).toString()
}

internal func typeVecToString<T>(start: String, types: Array<T>, end: String): String where T <: Type {
    if (types.isEmpty()) {
        return String.empty
    }
    let result = StringBuilder()
    result.append(start)
    result.append(String.join(types.map({ ty => ty.toString() }), delimiter: ", "))
    result.append(end)
    return result.toString()
}

internal func genericTypeParamsConstraintToString(obj: Array<GenericType>): String {
    if (obj.isEmpty()) {
        return String.empty
    }
    var result = ArrayList<String>()
    for (gType in obj) {
        if (gType.upperBounds.isEmpty()) {
            continue
        }
        var upperBoundStr = ArrayList<String>()
        for (bound in gType.upperBounds) {
            upperBoundStr.add(bound.toString())
        }
        result.add(gType.srcCodeName + " <: " + String.join(upperBoundStr.toArray(), delimiter: " & "))
    }
    if (result.isEmpty()) {
        return String.empty
    }
    return " where " + String.join(result.toArray(), delimiter: ", ")
}