/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

internal abstract class Base {
    internal var _attributes: AttributeInfo = AttributeInfo()
    internal var _annotation: Annotation = Annotation()
    internal var _chirAnno = ArrayList<CHIRAnno>()
    internal var _debugLocation: DebugLocation = DebugLocation.invalid()

    internal prop attributes: AttributeInfo {
        get() {
            return _attributes
        }
    }

    internal prop annotation: Annotation {
        get() {
            return _annotation
        }
    }

    internal func baseCommentToString(): String {
        var result = ArrayList<String>()
        if (let str <- chirAnnoToString() && !str.isEmpty()) {
            result.add(str)
        }
        if (_debugLocation.isValid()) {
            result.add("loc: " + _debugLocation.toString())
        }
        return String.join(result.toArray(), delimiter: ", ")
    }

    internal func chirAnnoToString(): String {
        var result = ArrayList<String>()
        for (anno in _chirAnno) {
            result.add(anno.toString())
        }
        return String.join(result.toArray(), delimiter: ", ")
    }

    internal mut prop debugLocation: DebugLocation {
        get() {
            return _debugLocation
        }
        set(v) {
            _debugLocation = v
        }
    }

    internal func getAnno<T>(): Any where T <: CHIRAnno {
        for (anno in _chirAnno) {
            if (anno is T) {
                return anno.get()
            }
        }
        return T.defaultValue()
    }

    internal func setAnno<T>(value: Any): Unit where T <: CHIRAnno {
        for (anno in _chirAnno) {
            if (anno is T) {
                anno.set(value)
                return
            }
        }
        _chirAnno.add(T.create(value))
    }
}
