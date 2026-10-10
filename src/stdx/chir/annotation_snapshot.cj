/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

public enum AnnotationScalarValue {
    StringValue(String) | BoolValue(Bool)
}

public struct AnnotationScalarField {
    private let _name: String
    private let _value: AnnotationScalarValue
    public prop name: String { get() { _name } }
    public prop value: AnnotationScalarValue { get() { _value } }
    internal init(name: String, value: AnnotationScalarValue) {
        this._name = name
        this._value = value
    }
}

/** Compiler-resolved identity; neither a source alias nor reflection metadata. */
public struct ResolvedAnnotation {
    private let _qualifiedClassName: String
    private let _declarationSymbol: String
    private let _location: DebugLocation
    private let _scalarFields: ?Array<AnnotationScalarField>
    public prop qualifiedClassName: String { get() { _qualifiedClassName } }
    public prop declarationSymbol: String { get() { _declarationSymbol } }
    public prop location: DebugLocation { get() { copyAnnotationLocation(_location) } }
    // None = unavailable, Some([]) = complete and empty.
    public prop scalarFields: ?Array<AnnotationScalarField> {
        get() { _scalarFields.map({fields => fields.clone()}) }
    }

    internal init(qualifiedClassName: String, declarationSymbol: String, location: DebugLocation,
        scalarFields: ?Array<AnnotationScalarField>) {
        this._qualifiedClassName = qualifiedClassName
        this._declarationSymbol = declarationSymbol
        this._location = copyAnnotationLocation(location)
        this._scalarFields = scalarFields.map({fields => fields.clone()})
    }
}

// Copies the non-public mutable scope information too, not only the visible span.
private func copyAnnotationLocation(location: DebugLocation): DebugLocation {
    let copy = DebugLocation(location.start, location.end, location.filePath)
    copy._fileId = location._fileId
    copy._scopeInfo = location._scopeInfo.clone()
    return copy
}

/** An immutable snapshot. None is Unknown, never interchangeable with Some([]). */
public struct AnnotationSnapshot {
    private let _items: ?Array<ResolvedAnnotation>
    internal let sourcePackage: String
    internal let sourceDeclId: String
    public prop isComplete: Bool { get() { _items.isSome() } }
    public prop items: ?Array<ResolvedAnnotation> { get() { _items.map({items => items.clone()}) } }

    internal init() {
        this._items = None
        this.sourcePackage = ""
        this.sourceDeclId = ""
    }

    internal init(sourcePackage: String, sourceDeclId: String, items: Array<ResolvedAnnotation>) {
        if (sourcePackage.isEmpty() || sourceDeclId.isEmpty()) {
            throw IllegalArgumentException("complete annotation snapshot requires a source identity")
        }
        this.sourcePackage = sourcePackage
        this.sourceDeclId = sourceDeclId
        this._items = Some(items.clone())
    }
}

/** Tracks old mutable annotation objects without changing their aliasing semantics. */
internal class AnnotationSnapshotGuard {
    private var snapshot = AnnotationSnapshot()
    private var baseline: Array<(CustomAnnoInstance, UInt64)> = []

    internal func invalidate(): Unit {
        snapshot = AnnotationSnapshot()
        baseline = []
    }

    // Only a verified compiler/deserializer path may install a Complete snapshot.
    internal func install(value: AnnotationSnapshot, instances: Array<CustomAnnoInstance>): Unit {
        invalidate()
        for (instance in instances) {
            if (instance._revisionExhausted) { return }
        }
        baseline = Array<(CustomAnnoInstance, UInt64)>(instances.size, {i => (instances[i], instances[i]._revision)})
        snapshot = value
    }

    internal func read(instances: Array<CustomAnnoInstance>): AnnotationSnapshot {
        if (!snapshot.isComplete) { return snapshot }
        if (instances.size != baseline.size) {
            invalidate()
            return snapshot
        }
        for (i in 0..instances.size) {
            let instance = instances[i]
            if (!refEq(instance, baseline[i][0]) || instance._revisionExhausted ||
                instance._revision != baseline[i][1]) {
                invalidate()
                break
            }
        }
        return snapshot
    }

    internal func copyForSource(instances: Array<CustomAnnoInstance>, sourcePackage: String,
        sourceDeclId: String, copiedInstances: Array<CustomAnnoInstance>): AnnotationSnapshotGuard {
        let copy = AnnotationSnapshotGuard()
        let current = read(instances)
        // Establish a new baseline only for the SAME source declaration. The
        // caller must also preserve the copied legacy annotation contents.
        if (current.isComplete && current.sourcePackage == sourcePackage && current.sourceDeclId == sourceDeclId &&
            instances.size == copiedInstances.size) {
            var same = true
            for (i in 0..instances.size) {
                if (instances[i].classSrcCodeName != copiedInstances[i].classSrcCodeName ||
                    instances[i].argValues != copiedInstances[i].argValues) { same = false; break }
            }
            if (same) { copy.install(current, copiedInstances) }
        }
        return copy
    }
}
