// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_anno_source

import stdx.aspect_cj.*

@PointcutRule[packageName: "aspect_v4_anno_target", className: "", methodName: "handle*",
    funcTypeStr: "(Int64)->Unit", targetKind: "global", recursive: false,
    annotationName: "aspect_v4_anno_right.Mark"]
class RightOnly {}

@InsertAtEntryByRule[rule: "aspect_v4_anno_source.RightOnly"]
public func before(): Unit { println("right-entry") }
