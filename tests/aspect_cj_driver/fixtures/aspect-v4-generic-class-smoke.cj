// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_generic_class

import stdx.aspect_cj.*

@Annotation[target: [MemberFunction]]
public class TraceBox { public const init() {} }

@PointcutRule[packageName: "aspect_v4_generic_class", className: "Box", methodName: "take",
    funcTypeStr: "(**)->*", targetKind: "instance", recursive: false,
    annotationName: "aspect_v4_generic_class.TraceBox"]
class AllBoxCalls {}

@PointcutRule[packageName: "aspect_v4_generic_class", className: "Box", methodName: "take",
    funcTypeStr: "(Int64)->Int64", targetKind: "instance", recursive: false,
    annotationName: "aspect_v4_generic_class.TraceBox"]
class IntBoxCalls {}

@InsertAtEntryByRule[rule: "aspect_v4_generic_class.AllBoxCalls"]
public func beforeAny(args: Array<Any>): Unit { println("box-any:${args.size}") }

@InsertAtEntryByRule[rule: "aspect_v4_generic_class.IntBoxCalls"]
public func beforeInt(): Unit { println("box-int") }

public class Box<T> {
    public init() {}

    @TraceBox
    public func take(value: T): T {
        println("box-body")
        return value
    }
}

main() {
    let first = Box<Int64>().take(7)
    println("box-result:${first}")
    let second = Box<String>().take("second")
    println("box-result:${second}")
}
