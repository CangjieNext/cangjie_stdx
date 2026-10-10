// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_invalid_advice_source

import stdx.aspect_cj.*

@PointcutRule[packageName: "aspect_v4_target", className: "", methodName: "handle",
    funcTypeStr: "(Int64)->Unit", targetKind: "global", recursive: false,
    annotationName: ""]
class ValidRule {}

@InsertAtEntryByRule[rule: "aspect_v4_invalid_advice_source.ValidRule"]
public func invalidAdvice(args: Array<Int64>): Unit { println(args.size) }
