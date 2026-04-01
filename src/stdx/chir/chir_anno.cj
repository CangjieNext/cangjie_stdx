/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

internal interface CHIRAnnoBase <: ToString {
}

internal interface CHIRAnno<T> <: CHIRAnnoBase {
    func get(): T
    func set(value: T): Unit
    static func defaultValue(): T
    static func create(value: T): CHIRAnno<T>
}

internal class IsAutoEnvClass <: CHIRAnno<Bool> {
    private var v: Bool

    /** Current value of the IsAutoEnvClass CHIR annotation. */
    public func get(): Bool {
        return v
    }

    /** Updates the IsAutoEnvClass CHIR annotation value. */
    public func set(value: Bool): Unit {
        this.v = value
    }

    /** Debug string for this annotation instance. */
    public func toString(): String {
        let result = StringBuilder()
        result.append("IsAutoEnvClass: ")
        result.append(v.toString())
        return result.toString()
    }

    internal init(value: Bool) {
        this.v = value
    }

    /** Default when no annotation is present (false). */
    static public func defaultValue(): Bool {
        return false
    }

    /** Constructs a new IsAutoEnvClass annotation box with the given value. */
    static public func create(value: Bool): CHIRAnno<Bool> {
        return IsAutoEnvClass(value)
    }
}