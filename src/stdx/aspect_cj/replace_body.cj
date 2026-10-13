/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj

import std.collection.*
import stdx.chir.*

/** The receiver in a global replacement callback is not a source-level pointcut parameter. */
protected func replacementPointcutType(advice: Function, instanceTarget: Bool): FuncType {
    let callback = (advice.parameters[advice.parameters.size - 1].ty as FuncType).getOrThrow()
    if (instanceTarget && !advice.isInstanceMemberMethod()) {
        let (_, explicitTypes) = callback.paramTypes.splitAt(1)
        return FuncType.get(explicitTypes, callback.returnType)
    }
    return callback
}

protected func replacementCallbackMatches(target: Function, callback: FuncType): Bool {
    if (callback == target.funcType || callback == target.funcSrcCodeType) { return true }
    if (!target.isInstanceMemberMethod() || callback.paramTypes.size != target.parameters.size ||
        callback.returnType != target.funcType.returnType) { return false }
    for (i in 0..callback.paramTypes.size) {
        let expected = target.parameters[i].ty
        let actual = callback.paramTypes[i]
        if (actual != expected && (i != 0 || actual.stripAllRefs() != expected.stripAllRefs())) { return false }
    }
    return true
}

private func adaptReplacementArgument(builder: CHIRBuilder, value: Value, expected: Type): Value {
    if (value.ty == expected) { return value }
    if (value.ty.stripAllRefs() != expected.stripAllRefs() || !expected.stripAllRefs().isValueType()) {
        throw IllegalArgumentException("ReplaceFuncBody argument type mismatch.")
    }
    if (!expected.isRefType()) { return builder.createLoad(value).result }
    let slot = builder.createAllocate(expected.stripAllRefs())
    builder.createStore(value, slot.result)
    return slot.result
}

private func originalBodyCallback(builder: CHIRBuilder, target: Function,
    original: Function, callbackType: FuncType): Value {
    if (callbackType == original.funcType) { return original }
    // An instance advice receives a bound function, not a raw method whose
    // hidden receiver would otherwise be missing from the callback call.
    let callback = builder.createLambda(callbackType,
        original.identifierWithoutPrefix + ".bound", "")
    let bodyBuilder = CHIRBuilder(callback.body.entryBlock)
    let slot = bodyBuilder.createAllocate(callbackType.returnType)
    callback.returnValue = slot.result
    let args = ArrayList<Value>()
    if (callback.parameters.size < original.parameters.size) { args.add(target.parameters[0]) }
    for (parameter in callback.parameters) {
        args.add(adaptReplacementArgument(bodyBuilder, parameter, original.parameters[args.size].ty))
    }
    let call = bodyBuilder.createApply(original, FuncCallContext(args.toArray(), [], None))
    bodyBuilder.createStore(call.result, slot.result)
    bodyBuilder.createExit()
    return callback.result
}

/** Preserve the target's member identity and dispatch entry when replacing its body. */
protected func weaveReplacementBody(pkg: Package, target: Function, callee: Function): Unit {
    let callbackType = (callee.parameters[callee.parameters.size - 1].ty as FuncType).getOrThrow()
    if (!replacementCallbackMatches(target, callbackType)) {
        throw IllegalArgumentException("ReplaceFuncBody callback type does not match ${target.srcCodeName}.")
    }
    var name = target.identifierWithoutPrefix + ".original"
    while (pkg.getSpecifiedFunction(name).isSome()) { name += ".original" }
    let original = pkg.addFunction(target.funcType, name, "", target.packageName)
    original.setPrivate()
    target.moveBodyTo(original)
    target.initBody()
    let builder = CHIRBuilder(target.body.getOrThrow().entryBlock)
    let slot = builder.createAllocate(target.funcType.returnType)
    target.returnValue = slot.result
    let callback = originalBodyCallback(builder, target, original, callbackType)
    let args = ArrayList<Value>()
    for (i in 0..callee.parameters.size - 1) {
        args.add(adaptReplacementArgument(builder, target.parameters[i], callee.parameters[i].ty))
    }
    args.add(callback)
    let receiver: ?Type = if (callee.isMemberMethod()) {
        if (callee.isStatic()) { callee.outerType } else { Some(args[0].ty) }
    } else { None }
    let call = builder.createApply(callee, FuncCallContext(args.toArray(), [], receiver))
    builder.createStore(call.result, slot.result)
    builder.createExit()
}
