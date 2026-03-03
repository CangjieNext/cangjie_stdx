/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

internal interface CHIRAnnoBase <: ToString {
    func toString(): String
}

internal interface CHIRAnno<T> <: CHIRAnnoBase {
    func get(): T
    func set(value: T): Unit
    func toString(): String
    static func defaultValue(): T
    static func create(value: T): CHIRAnno<T>
}

internal class IsAutoEnvClass <: CHIRAnno<Bool> {
    private var v: Bool
    internal init(value: Bool) {
        this.v = value
    }
    public func get(): Bool {
        return v
    }
    public func set(value: Bool): Unit {
        this.v = value
    }
    public func toString(): String {
        let result = StringBuilder()
        result.append("IsAutoEnvClass: ")
        result.append(v.toString())
        return result.toString()
    }
    static public func defaultValue(): Bool {
        return false
    }
    static public func create(value: Bool): CHIRAnno<Bool> {
        return IsAutoEnvClass(value)
    }
}