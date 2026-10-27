// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package stdx.chir

var checks = 0
var failures = 0
private func check(value: Bool, message: String): Unit {
    checks++
    if (!value) { failures++; println("FAIL: ${message}") }
}

private func checkBodyTransfer(): Unit {
    let pkg = Package("transfer", AccessLevel.Public)
    let ty = FuncType.get([IntType.getInt64()], IntType.getInt64())
    let source = pkg.addFunction(ty, "source", "source", "transfer")
    let helper = pkg.addFunction(ty, "helper", "", "transfer")
    source.initBody()
    let builder = CHIRBuilder(source.body.getOrThrow().entryBlock)
    let slot = builder.createAllocate(IntType.getInt64())
    source.returnValue = slot.result
    builder.createStore(source.parameters[0], slot.result)
    builder.createExit()
    let oldParameter = source.parameters[0]
    source.moveBodyTo(helper)
    check(source.body.isNone() && source.parameters.isEmpty(), "source ownership cleared after body move")
    check(helper.parameters.size == 1 && helper.parameters[0] == oldParameter,
        "destination parameter list is not cleared through an alias")
    check(helper.body.getOrThrow().owner == helper && oldParameter.topLevelFunc == helper &&
        helper.returnValue.getOrThrow().topLevelFunc == helper, "moved body and parameters belong to destination")
    source.initBody()
    check(source.parameters.size == 1 && source.parameters[0] != oldParameter &&
        source.parameters[0].topLevelFunc == source, "reinitialized source has independent parameters")
    let (data, length) = serializePackage(pkg)
    let restored = deserializePackage(data, length)
    check(restored.functions[1].parameters.size == 1 &&
        restored.functions[1].body.getOrThrow().owner == restored.functions[1],
        "moved ownership survives CHIR serialization")
    unsafe { freeSerializedMemory() }
    helper.moveBodyTo(helper)
    check(helper.body.isSome() && helper.parameters.size == 1, "self move is non-destructive")
    check(!helper.isAspectExecutableSourceBody() && source.isAspectExecutableSourceBody(),
        "unnamed plugin helper is not a source candidate; named function remains a candidate")
}

main() {
    check(Attribute.ObjCExport.toUInt64() == 38 && Attribute.MatchPattern.toUInt64() == 39 &&
        Attribute.PluginAdded.toUInt64() == 40, "attribute ABI matches current compiler including ObjCExport")
    checkBodyTransfer()
    let empty = AnnotationSnapshot("shop", "function1", [])
    check(empty.isComplete && empty.items.getOrThrow().isEmpty(), "known-empty is Complete")
    check(!AnnotationSnapshot().isComplete && AnnotationSnapshot().items.isNone(), "missing is Unknown")
    let loc = DebugLocation.invalid()
    loc._scopeInfo.add(7)
    let fields = [AnnotationScalarField("name", AnnotationScalarValue.StringValue("original")),
        AnnotationScalarField("enabled", AnnotationScalarValue.BoolValue(true))]
    let item = ResolvedAnnotation("shop.auth.RequireLogin", "_type_symbol", loc, Some(fields))
    fields[0] = AnnotationScalarField("name", AnnotationScalarValue.StringValue("changed"))
    let fieldIsOriginal = {f: AnnotationScalarField => match (f.value) {
        case AnnotationScalarValue.StringValue(v) => v == "original"
        case _ => false
    }}
    check(fieldIsOriginal(item.scalarFields.getOrThrow()[0]), "input field array owned")
    item.scalarFields.getOrThrow()[0] = fields[0]
    check(fieldIsOriginal(item.scalarFields.getOrThrow()[0]), "returned field array copied")
    loc._scopeInfo[0] = 8
    item.location._scopeInfo[0] = 9
    check(item.location._scopeInfo[0] == 7, "source location copied both directions")
    let items = [item]
    let complete = AnnotationSnapshot("shop", "function1", items)
    items[0] = ResolvedAnnotation("other.Annotation", "symbol", loc, None)
    complete.items.getOrThrow()[0] = items[0]
    check(complete.items.getOrThrow()[0].qualifiedClassName == "shop.auth.RequireLogin", "snapshot array owned")
    check(items[0].scalarFields.isNone(), "complex business annotation may lack scalar fields")

    let legacy = CustomAnnoInstance("RequireLogin")
    legacy.argValues = ["a"]
    let first = AnnotationSnapshotGuard()
    let second = AnnotationSnapshotGuard()
    first.install(complete, [legacy]); second.install(complete, [legacy])
    check(first.read([legacy]).isComplete && second.read([legacy]).isComplete, "shared unchanged object")
    let view = legacy.argValues
    view[0] = "b"
    check(legacy.argValues == ["a"] && first.read([legacy]).isComplete, "legacy getter remains array copy")
    legacy.argValues = ["b"]
    check(!first.read([legacy]).isComplete && !second.read([legacy]).isComplete, "shared setter invalidates both")
    legacy.argValues = ["a"]
    check(!first.read([legacy]).isComplete, "changing back cannot resurrect a stale snapshot")
    first.install(complete, [legacy])
    let substituted = CustomAnnoInstance("RequireLogin")
    substituted.argValues = ["a"]
    check(!first.read([substituted]).isComplete, "equal-content object replacement is detected")
    first.install(complete, [legacy])
    check(!first.read([]).isComplete, "list length mutation detected")
    first.install(complete, [legacy])
    let clone = first.copyForSource([legacy], "shop", "function1", [substituted])
    check(clone.read([substituted]).isComplete, "same-source clone receives its own baseline")
    legacy.argValues = ["changed"]
    check(clone.read([substituted]).isComplete && !first.read([legacy]).isComplete, "independent clone baseline")
    second.install(complete, [substituted])
    check(!second.copyForSource([substituted], "shop", "function2", [substituted]).read([substituted]).isComplete,
        "different-source clone is Unknown")
    check(!second.copyForSource([substituted], "other", "function1", [substituted]).read([substituted]).isComplete,
        "different-package clone is Unknown")
    check(!second.copyForSource([substituted], "shop", "function1", [legacy]).read([legacy]).isComplete,
        "changed legacy contents cannot acquire a valid cloned snapshot")
    let exhausted = CustomAnnoInstance("RequireLogin")
    exhausted._revision = UInt64.Max
    first.install(complete, [exhausted])
    check(first.read([exhausted]).isComplete, "maximum revision is representable")
    exhausted.argValues = ["overflow"]
    check(exhausted._revision == UInt64.Max && exhausted._revisionExhausted && !first.read([exhausted]).isComplete,
        "overflow poisons rather than wraps")
    first.install(complete, [exhausted])
    check(!first.read([exhausted]).isComplete, "exhaustion is permanently invalid")

    let info = AnnoInfo()
    info.installSnapshot(empty)
    check(info._identifier == "none" && info.snapshot.isComplete, "no reflection factory still permits Complete-empty")
    info._annoInstances = ArrayList<CustomAnnoInstance>.of([substituted])
    check(!info.snapshot.isComplete, "actual AnnoInfo list setter invalidates")
    info.installSnapshot(complete)
    info.addInstance(legacy)
    check(!info.snapshot.isComplete, "actual AnnoInfo append helper invalidates")
    info.installSnapshot(complete)
    substituted.argValues = ["modified through shared reference"]
    check(!info.snapshot.isComplete, "actual AnnoInfo read checks element revision")
    let pkg = Package("shop", AccessLevel.Public)
    pkg._annotationMetadataVersion = 1
    let target = pkg.addFunction(FuncType.get([], UnitType.get()), "_target", "target", "shop")
    target._annoInfo.installSnapshot(empty)
    let (emptyData, emptyLength) = serializePackage(pkg)
    let emptyRestored = deserializePackage(emptyData, emptyLength)
    check(emptyRestored.annotationMetadataVersion == 1 &&
        emptyRestored.functions[0]._annoInfo.snapshot.items.getOrThrow().isEmpty(),
        "known-empty snapshot and capability survive roundtrip")
    check(emptyRestored.aspectWeaveState == 0 && emptyRestored.aspectWeavePlanDigest == "",
        "raw weave state survives roundtrip")
    unsafe { freeSerializedMemory() }

    let applied = Package("woven", AccessLevel.Public)
    let digest = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    applied.markAspectWeaveApplied(digest)
    let (appliedData, appliedLength) = serializePackage(applied)
    let appliedRestored = deserializePackage(appliedData, appliedLength)
    check(appliedRestored.aspectWeaveState == 1 && appliedRestored.aspectWeavePlanDigest == digest,
        "applied weave state and plan digest survive roundtrip")
    var doubleAppliedRejected = false
    try {
        appliedRestored.markAspectWeaveApplied(digest)
    } catch (e: IllegalArgumentException) {
        doubleAppliedRejected = e.message.contains("already-woven")
    }
    check(doubleAppliedRejected, "repeat application is rejected after roundtrip")
    unsafe { freeSerializedMemory() }

    target._annoInfo.installSnapshot(complete)
    target._aspectSourceOrigin = "_source_generic_function"
    let (fullData, fullLength) = serializePackage(pkg)
    let fullRestored = deserializePackage(fullData, fullLength)
    let fullSnapshot = fullRestored.functions[0]._annoInfo.snapshot
    check(fullSnapshot.isComplete && fullSnapshot.items.getOrThrow()[0].qualifiedClassName ==
        "shop.auth.RequireLogin", "resolved annotation identity survives roundtrip")
    check(fullRestored.functions[0].aspectSourceOrigin == "_source_generic_function",
        "concrete source origin survives roundtrip")
    let restoredFields = fullSnapshot.items.getOrThrow()[0].scalarFields.getOrThrow()
    check(restoredFields.size == 2 && fieldIsOriginal(restoredFields[0]), "String scalar survives roundtrip")
    check(match (restoredFields[1].value) { case AnnotationScalarValue.BoolValue(v) => v; case _ => false },
        "Bool scalar survives roundtrip")
    check(fullSnapshot.items.getOrThrow()[0].location._scopeInfo[0] == 7,
        "source scope survives roundtrip")
    unsafe { freeSerializedMemory() }

    target.customAnnoInstances = [legacy]
    check(!target._annoInfo.snapshot.isComplete, "real function setter invalidates complete snapshot")
    let (data, length) = serializePackage(pkg)
    let restored = deserializePackage(data, length)
    check(!restored.functions[0]._annoInfo.snapshot.isComplete, "old schema produces Unknown, not known-empty")
    check(restored.functions[0].customAnnoInstances[0].argValues == legacy.argValues, "legacy roundtrip preserved")
    unsafe { freeSerializedMemory() }
    println("snapshot checks=${checks}, failures=${failures}")
    return if (failures == 0) { 0 } else { 1 }
}
