/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

public enum TypeActionMode {
    CONTINUE | SKIP | STOP
}

abstract class TypeVisitor {
    private var isStop = false
    public func walk(ty: Type): Unit {
        if (isStop) {
            return
        }
        match (action(ty)) {
            case CONTINUE =>
                for (arg in ty.typeArgs) {
                    walk(arg)
                }
            case SKIP => return
            case STOP =>
                isStop = true
                return
        }
    }
    public open func action(ty: Type): TypeActionMode {
        return TypeActionMode.CONTINUE
    }
}