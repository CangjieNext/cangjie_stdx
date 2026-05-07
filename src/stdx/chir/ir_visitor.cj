/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

public enum IRActionMode {
    CONTINUE | STOP
}

public abstract class CHIRVisitor {
    private var isStop = false
    public func walk(f: Function): Unit {
        if (let Some(body) <- f.body) {
            walk(body)
        }
    }
    public func walk(bg: BlockGroup): Unit {
        for (b in bg.blocks) {
            if (isStop) {
                return
            }            
            walk(b)
        }
    }
    public func walk(b: Block): Unit {
        for (e in b.exprs) {
            action(e)
            if (isStop) {
                return
            }
            for (subBg in e.blockGroups) {
                walk(subBg)
                if (isStop) {
                    return
                }
            }
        }
    }
    public open func action(ty: Expression): IRActionMode {
        return IRActionMode.CONTINUE
    }
}