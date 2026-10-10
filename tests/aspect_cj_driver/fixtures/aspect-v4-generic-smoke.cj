// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_generic

import stdx.aspect_cj.*

@Annotation[target: [GlobalFunction]]
public class TraceGeneric { public const init() {} }

@PointcutRule[packageName: "aspect_v4_generic", className: "", methodName: "handle*",
    funcTypeStr: "(**)->*", targetKind: "global", recursive: false,
    annotationName: "aspect_v4_generic.TraceGeneric"]
class GenericCalls {}

@PointcutRule[packageName: "aspect_v4_generic", className: "", methodName: "handleGeneric",
    funcTypeStr: "(Int64)->Int64", targetKind: "global", recursive: false,
    annotationName: "aspect_v4_generic.TraceGeneric"]
class ExactGenericCall {}

@InsertAtEntryByRule[rule: "aspect_v4_generic.GenericCalls"]
public func before(args: Array<Any>): Unit {
    println("generic-entry:${args.size}")
}

@InsertAtEntryByRule[rule: "aspect_v4_generic.ExactGenericCall"]
public func beforeExact(): Unit { println("generic-exact-entry") }

@TraceGeneric
public func handleGeneric<T>(value: T): T {
    println("generic-body")
    return value
}

main() {
    let result = handleGeneric(7)
    println("generic-result:${result}")
    let other = handleGeneric("second")
    println("generic-result:${other}")
}
