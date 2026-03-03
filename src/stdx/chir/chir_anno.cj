/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

protected interface CHIRAnno <: ToString {
    func get(): Any
    func set(value: Any): Unit
    func toString(): String
    static func defaultValue(): Any
    static func create(value: Any): CHIRAnno
}

internal class IsAutoEnvClass <: CHIRAnno {
    private var v: Bool
    internal init(value: Bool) {
        this.v = value
    }
    public func get(): Any {
        return v
    }
    public func set(value: Any): Unit {
        this.v = (value as Bool).getOrThrow()
    }
    public func toString(): String {
        return "IsAutoEnvClass: " + v.toString()
    }
    static public func defaultValue(): Any {
        return false
    }
    static public func create(value: Any): CHIRAnno {
        return IsAutoEnvClass((value as Bool).getOrThrow())
    }
}