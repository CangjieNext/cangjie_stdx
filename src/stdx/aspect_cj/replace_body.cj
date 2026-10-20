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

/** Original callbacks use source parameters only; their receiver is captured during weaving. */
protected func replacementPointcutType(advice: Function): FuncType {
    return (advice.parameters[advice.parameters.size - 1].ty as FuncType).getOrThrow()
}

protected func replacementCallbackMatches(target: Function, callback: FuncType): Bool {
    return callback == target.funcSrcCodeType
}

protected func canUpcastReplacementReceiver(actual: Type, expected: Type): Bool {
    if (!actual.isRefType() || !expected.isRefType() ||
        !actual.stripAllRefs().isClassLikeType() || !expected.stripAllRefs().isClassLikeType()) {
        return false
    }
    return actual.isEqualOrSubTypeOf(expected)
}

private func adaptReplacementArgument(builder: CHIRBuilder, value: Value, expected: Type): Value {
    if (value.ty == expected) { return value }
    // recursive:true may apply a base-class advice to an overriding method.
    // Keep the derived receiver for original, but upcast it when calling advice.
    if (canUpcastReplacementReceiver(value.ty, expected)) {
        return builder.createStaticCast(value, expected).result
    }
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
    // Every instance target receives a bound callback, including global/static
    // advice. The moved implementation is a private global helper, so it has
    // no member ThisType; its explicit first parameter carries the receiver.
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
        if (callee.isStatic()) {
            Some(addRefIfFuncIsMutOrClass(callee.outerType.getOrThrow(), callee))
        } else { Some(args[0].ty) }
    } else { None }
    let call = builder.createApply(callee, FuncCallContext(args.toArray(), [], receiver))
    builder.createStore(call.result, slot.result)
    builder.createExit()
}
