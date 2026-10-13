// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package stdx.aspect_cj.tests

import std.fs.*
import stdx.aspect_cj.*

main(args: Array<String>): Int64 {
    try {
        let context = RuleActionContext("", "", "", "", "", args[1], "", "", [])
        let path = if (args[0] == "path") {
            ruleContextInputPath(context, args[2])
        } else { Path(args[2]) }
        println("bytes=${readBoundedAspectMetadata(path).size}")
        return 0
    } catch (error: Exception) {
        println(error.message)
        return 1
    }
}
