// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_replace_conflict_source

import stdx.aspect_cj.*

@PointcutRule[packageName: "aspect_v4_mixed_target", className: "", methodName: "handle",
    funcTypeStr: "(Int64)->Unit", targetKind: "global", recursive: false,
    annotationName: ""]
class Handle {}

@InsertAtEntryByRule[rule: "aspect_v4_replace_conflict_source.Handle"]
public func before(): Unit { println("before") }

@ReplaceFuncBody[packageName: "aspect_v4_mixed_target", className: "",
    methodName: "handle", isStatic: false, recursive: false]
public func around(original: (Int64)->Unit): Unit { original(7) }
