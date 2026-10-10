// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_invalid_rule_source

import stdx.aspect_cj.*

// It is deliberately unreferenced. Collection must still reject it.
@PointcutRule[packageName: "", className: "", methodName: "handle",
    funcTypeStr: "(Int64)->Unit", targetKind: "global", recursive: false,
    annotationName: ""]
class InvalidUnreferencedRule {}
