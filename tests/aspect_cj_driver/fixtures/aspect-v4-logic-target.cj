// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_logic_target

@Annotation[target: [GlobalFunction]]
public class Hot {
    public const init() {}
}

@Annotation[target: [GlobalFunction]]
public class Cold {
    public const init() {}
}

@Hot
public func handleHot(value: Int64): Unit { println("body-hot:${value}") }

@Cold
public func handleCold(value: Int64): Unit { println("body-cold:${value}") }

public func handlePlain(value: Int64): Unit { println("body-plain:${value}") }

main() {
    handleHot(1)
    handleCold(2)
    handlePlain(3)
}
