// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_exception_smoke

import stdx.aspect_cj.*

@PointcutRule[packageName: "aspect_v4_exception_smoke", className: "", methodName: "handle*",
    funcTypeStr: "(Int64)->Unit", targetKind: "global", recursive: false, annotationName: ""]
class AllHandlers {}

@InsertAtEntryByRule[rule: "aspect_v4_exception_smoke.AllHandlers"]
public func before(args: Array<Any>): Unit {
    let value = (args[0] as Int64).getOrThrow()
    println("entry:${value}")
    if (value == 99) { throw Exception("entry-failure") }
}

@InsertAtExitByRule[rule: "aspect_v4_exception_smoke.AllHandlers"]
public func after(args: Array<Any>): Unit {
    let value = (args[0] as Int64).getOrThrow()
    println("exit:${value}")
    if (value == 88) { throw Exception("exit-failure") }
}

public func handlePlain(value: Int64): Unit { println("body:${value}") }

public func handleThrow(value: Int64): Unit {
    println("body-throw:${value}")
    throw Exception("body-failure")
}

public func handleCaught(value: Int64): Unit {
    try { throw Exception("inner-failure") }
    catch (_: Exception) { println("body-caught:${value}") }
}

public func handleReturns(value: Int64): Unit {
    if (value > 0) {
        println("body-branch:${value}")
        return
    }
    println("body-fallthrough:${value}")
}

public func handleRecursive(value: Int64): Unit {
    println("body-recursive:${value}")
    if (value > 0) { handleRecursive(value - 1) }
}

main() {
    try { handlePlain(99) } catch (_: Exception) { println("caught-entry") }
    try { handlePlain(88) } catch (_: Exception) { println("caught-exit") }
    try { handleThrow(2) } catch (_: Exception) { println("caught-body") }
    handleCaught(3)
    handleReturns(4)
    handleReturns(0)
    handleRecursive(1)
}
