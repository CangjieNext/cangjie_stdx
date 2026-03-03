/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

import std.fs.*

internal class Position <: ToString {
    private let _line: Int64
    private let _column: Int64
    public init() {
        this._line = 0
        this._column = 0
    }
    public init(line: Int64, column: Int64) {
        this._line = line
        this._column = column
    }
    public prop line: Int64 {
        get() {
            return _line
        }
    }
    public prop column: Int64 {
        get() {
            return _column
        }
    }
    public func isValid(): Bool {
        return line > 0 && column > 0
    }
    public func toString(): String {
        return "-" + line.toString() + "-" + column.toString()
    }
}

internal class DebugLocation <: ToString {
    private let _start: Position
    private let _end: Position
    private let _filePath: Path
    internal var _fileId: UInt64 = 0
    internal var _scopeInfo: ArrayList<Int64> = ArrayList<Int64>()
    public init() {
        this._start = Position()
        this._end = Position()
        this._filePath = Path("")
    }
    public init(start: Position, end: Position, filePath: Path) {
        this._start = start
        this._end = end
        this._filePath = filePath;
    }
    public prop start: Position {
        get() {
            return _start
        }
    }
    public prop end: Position {
        get() {
            return _end
        }
    }
    public prop filePath: Path {
        get() {
            return _filePath
        }
    }
    public func isValid(): Bool {
        return start.isValid() && end.isValid()
    }
    public func toString(): String {
        if (!isValid()) {
            return ""
        }
        var str = filePath.fileName + start.toString()
        if (_scopeInfo.isEmpty()) {
            return str
        }
        if (!_scopeInfo.isEmpty()) {
            var scopeStr = ArrayList<String>()
            for (info in _scopeInfo) {
                scopeStr.add(info.toString())
            }
            str += ", scope: " + String.join(scopeStr.toArray(), delimiter: "-")
        }
        return str
    }
    internal static func invalid(): DebugLocation {
        return DebugLocation()
    }
}