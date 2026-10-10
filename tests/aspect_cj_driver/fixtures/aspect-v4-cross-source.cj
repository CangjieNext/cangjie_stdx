// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_cross_source

import stdx.aspect_cj.*

@PointcutRule[packageName: "aspect_v4_target", className: "", methodName: "handle",
    funcTypeStr: "(Int64)->Unit", targetKind: "global", recursive: false,
    annotationName: "aspect_v4_target.RequireLogin"]
class Login {}

@PointcutRule[packageName: "aspect_v4_target", className: "", methodName: "handleInternal",
    funcTypeStr: "(**)->*", targetKind: "global", recursive: false, annotationName: ""]
class Internal {}

@PointcutExpression[packageScope: "aspect_v4_target", expression: "Login AND NOT Internal"]
class Selected {}

@InsertAtEntryByRule[rule: "aspect_v4_cross_source.Selected"]
public func before(args: Array<Any>): Unit {
    println("cross-entry:${(args[0] as Int64).getOrThrow()}")
    args[0] = 8
}

@InsertAtEntryByRule[rule: "aspect_v4_cross_source.Selected"]
public func beforeSecond(args: Array<Any>): Unit {
    println("cross-entry-second:${(args[0] as Int64).getOrThrow()}")
}

@InsertAtExitByRule[rule: "aspect_v4_cross_source.Selected"]
public func after(): Unit { println("cross-exit") }

@PointcutRule[packageName: "aspect_v4_target", className: "*Service", methodName: "run",
    funcTypeStr: "(Int64)->Unit", targetKind: "instance", recursive: false,
    annotationName: "aspect_v4_target.RequireLogin"]
class ServiceInstance {}

@PointcutRule[packageName: "aspect_v4_target", className: "*Service", methodName: "staticRun",
    funcTypeStr: "(Int64)->Unit", targetKind: "static", recursive: false,
    annotationName: "aspect_v4_target.RequireLogin"]
class ServiceStatic {}

public class Hooks {
    @InsertAtEntryByRule[rule: "aspect_v4_cross_source.ServiceInstance"]
    public static func instanceEntry(args: Array<Any>): Unit {
        println("instance-entry:${(args[0] as Int64).getOrThrow()}")
    }

    @InsertAtEntryByRule[rule: "aspect_v4_cross_source.ServiceStatic"]
    public static func staticEntry(args: Array<Any>): Unit {
        println("static-entry:${(args[0] as Int64).getOrThrow()}")
    }
}
