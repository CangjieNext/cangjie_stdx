// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_self

import stdx.aspect_cj.*

@PointcutRule[packageName: "aspect_v4_self", className: "", methodName: "business",
    funcTypeStr: "(Int64)->Unit", targetKind: "global", recursive: false, annotationName: ""]
class Business {}

@InsertAtEntryByRule[rule: "aspect_v4_self.Business"]
public func before(args: Array<Any>): Unit {
    println("self-entry:${(args[0] as Int64).getOrThrow()}")
}

public func business(value: Int64): Unit { println("self-body:${value}") }

main() { business(3) }
