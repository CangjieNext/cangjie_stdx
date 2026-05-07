/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

public class FuncSigInfo {
    internal var _name: String
    internal var _type: FuncType
    internal var _genericTypeParams: ArrayList<GenericType>

    public init(name: String, ty: FuncType, genericTypeParams: Array<GenericType>) {
        this._name = name
        this._type = ty
        this._genericTypeParams = ArrayList<GenericType>.of(genericTypeParams)
    }

    public prop name: String {
        get() {
            return _name
        }
    }

    public prop ty: FuncType {
        get() {
            return _type
        }
    }

    public prop genericTypeParams: Array<GenericType> {
        get() {
            return _genericTypeParams.toArray()
        }
    }

    public func toString(): String {
        var result = StringBuilder()
        result.append(_name)
        result.append(typeVecToString("<", genericTypeParams, ">"))
        result.append("(")
        result.append(typeVecToString("", _type.paramTypes, ""))
        result.append(") -> ")
        result.append(_type.returnType.toString())
        return result.toString()
    }

    public func dump(): Unit {
        println(toString())
    }
}