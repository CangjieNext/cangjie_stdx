// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_target

@Annotation[target: [GlobalFunction, MemberFunction]]
public class RequireLogin {
    let name: String
    public const init(name!: String) { this.name = name }
}

@RequireLogin[name: "admin"]
public func handle(id: Int64): Unit { println("target:${id}") }

public class AccountService {
    @RequireLogin[name: "member"]
    public func run(id: Int64): Unit { println("instance-body:${id}") }

    @RequireLogin[name: "static"]
    public static func staticRun(id: Int64): Unit { println("static-body:${id}") }
}

main() {
    handle(7)
    AccountService().run(9)
    AccountService.staticRun(11)
}
