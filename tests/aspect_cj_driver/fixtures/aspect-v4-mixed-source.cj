// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_mixed_source

import stdx.aspect_cj.*

@PointcutRule[packageName: "aspect_v4_mixed_target", className: "", methodName: "handle",
    funcTypeStr: "(Int64)->Unit", targetKind: "global", recursive: false,
    annotationName: ""]
class EveryHandle {}

@InsertAtEntry[packageName: "aspect_v4_mixed_target", className: "", methodName: "handle",
    isStatic: false, recursive: false, funcTypeStr: "(Int64)->Unit"]
public func legacyBefore(value: Int64): Unit { println("legacy-entry:${value}") }

@InsertAtEntryByRule[rule: "aspect_v4_mixed_source.EveryHandle"]
public func newBefore(args: Array<Any>): Unit {
    println("new-entry:${(args[0] as Int64).getOrThrow()}")
    args[0] = 99
}

@InsertAtExit[packageName: "aspect_v4_mixed_target", className: "", methodName: "handle",
    isStatic: false, recursive: false, funcTypeStr: "(Int64)->Unit"]
public func legacyAfter(): Unit { println("legacy-exit") }

@InsertAtExitByRule[rule: "aspect_v4_mixed_source.EveryHandle"]
public func newAfter(): Unit { println("new-exit") }
