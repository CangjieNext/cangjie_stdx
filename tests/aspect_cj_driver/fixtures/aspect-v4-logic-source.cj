// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_logic_source

import stdx.aspect_cj.*

private const func targetPackage(): String { "aspect_v4_logic_target" }

@PointcutRule[packageName: "aspect_v4_logic_target", className: "", methodName: "handle*",
    funcTypeStr: "(Int64)->Unit", targetKind: "global", recursive: false,
    annotationName: ""]
class AllHandles {}

@PointcutRule[annotationName: "aspect_v4_logic_target." + "Hot", recursive: false,
    targetKind: "global", funcTypeStr: "(Int64)->Unit", methodName: "handle*",
    className: "", packageName: targetPackage()]
class HotHandles {}

@PointcutExpression[packageScope: "aspect_v4_logic_target",
    expression: "AllHandles AND NOT HotHandles"]
class NonHotHandles {}

@PointcutExpression[packageScope: "aspect_v4_logic_target",
    expression: "HotHandles OR (HotHandles AND AllHandles)"]
class SharedHotHandles {}

@InsertAtEntryByRule[rule: "aspect_v4_logic_source.NonHotHandles"]
public func beforeNonHot(args: Array<Any>): Unit {
    println("nonhot:${(args[0] as Int64).getOrThrow()}")
}

@InsertAtEntryByRule[rule: "aspect_v4_logic_source.SharedHotHandles"]
public func beforeHot(args: Array<Any>): Unit {
    println("hot:${(args[0] as Int64).getOrThrow()}")
}

@InsertAtExitByRule[rule: "aspect_v4_logic_source.AllHandles"]
public func afterHandle(): Unit { println("exit") }
