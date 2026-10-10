// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_anno_target

import aspect_v4_anno_right.Mark as RightMark
import aspect_v4_anno_wrong.Mark as WrongMark

@RightMark[code: 7, values: [1, 2]]
@WrongMark
public func handleRight(value: Int64): Unit { println("right-body:${value}") }

@WrongMark
public func handleWrong(value: Int64): Unit { println("wrong-body:${value}") }

public func handlePlain(value: Int64): Unit { println("plain-body:${value}") }

main() {
    handleRight(1)
    handleWrong(2)
    handlePlain(3)
}
