/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.logger

import std.collection.ArrayList
import std.time.DateTime
import std.io.{OutputStream, BufferedOutputStream}
import stdx.log.*

public class TextLogger <: Logger {
    let cl: CommonLogger
    init(cl: CommonLogger) {
        this.cl = cl
    }
    public init(output: OutputStream) {
        cl = CommonLogger(output, LogStyle.TEXT)
    }
    public mut prop level: LogLevel {
        get() {
            cl.level
        }
        set(v) {
            cl.level = v
        }
    }
    public func withAttrs(attrs: Array<Attr>): Logger {
        return TextLogger(cl.withAttrs(attrs))
    }
    public func isClosed(): Bool {
        cl.isClosed()
    }
    public func close(): Unit {
        cl.close()
    }
    public func log(record: LogRecord): Unit {
        cl.log(record)
    }
}

enum LogWriterState {
    | EmptyArray
    | NoEmptyArray
    | EmptyObject
    | NoEmptyObject
    | EmptyText
    | NoEmptyText
}

class TextLogWriter <: LogWriter {
    var out: OutputStream
    var stack: ArrayList<LogWriterState> = ArrayList<LogWriterState>()

    var bo: BufferedOutputStream<OutputStream>
    var haveName = false

    init(out: OutputStream) {
        this.out = out
        stack.add(EmptyText)
        bo = BufferedOutputStream(out)
    }
    func writeMessage(v: String): Unit {
        bo.write(unsafe { v.rawData() })
    }
    public func writeNone(): Unit {
        beforeValue()
        bo.write("None".toArray())
    }
    public func writeInt(v: Int64): Unit {
        beforeValue()
        bo.write(v.toString().toArray())
    }
    public func writeBool(v: Bool): Unit {
        beforeValue()
        bo.write(v.toString().toArray())
    }
    public func writeFloat(v: Float64): Unit {
        beforeValue()
        bo.write(v.toString().toArray())
    }
    public func writeString(v: String): Unit {
        beforeValue()
        bo.write([b'"'])
        quotedReplace(bo, v)
        bo.write([b'"'])
    }
    public func writeDateTime(v: DateTime): Unit {
        beforeValue()
        bo.write(unsafe { v.toString().rawData() })
    }
    public func writeDuration(v: Duration): Unit {
        beforeValue()
        bo.write(v.toString().toArray())
    }
    public func writeException(v: Exception): Unit {
        writeValue(v.stackToString())
    }
    public func writeKey(v: String): Unit {
        beforeName()
        haveName = true
        let nq = needsQuoting(v)
        if (nq) {
            bo.write([b'"'])
        }
        quotedReplace(bo, v)
        if (nq) {
            bo.write([b'"'])
        }
        if (stack.size > 1) {
            bo.write([b':'])
        } else {
            bo.write([b'='])
        }
    }
    public func writeValue(lv: LogValue): Unit {
        lv.writeTo(this)
        haveName = false
    }
    public func startArray(): Unit {
        beforeValue()
        bo.write([b'['])
        put(EmptyArray)
    }
    public func endArray(): Unit {
        match (top()) {
            case EmptyArray | NoEmptyArray => bo.write([b']'])
            case _ => throw IllegalStateException("Cannot end array: startArray() must be called first.")
        }
        pop()
    }
    public func startObject(): Unit {
        beforeValue()
        bo.write([b'{'])
        put(EmptyObject)
    }
    public func endObject(): Unit {
        if (haveName) {
            throw IllegalStateException("Cannot end object: a name was written but no value follows.")
        }
        match (top()) {
            case EmptyObject | NoEmptyObject => bo.write([b'}'])
            case _ => throw IllegalStateException("Cannot end object: startObject() must be called first.")
        }
        pop()
    }

    func beforeName(): Unit {
        if (haveName) {
            throw IllegalStateException("Cannot write name: a name was already written but no value follows.")
        }
        match (top()) {
            case EmptyObject => stack[stack.size - 1] = NoEmptyObject
            case NoEmptyObject =>
                if (stack.size > 1) {
                    bo.write([b','])
                } else {
                    bo.write([b' '])
                }
            case _ => throw IllegalStateException("Cannot write name: current position is not in an object.")
        }
    }

    func beforeValue(): Unit {
        match (top()) {
            case NoEmptyArray => bo.write([b','])
            case EmptyArray => stack[stack.size - 1] = NoEmptyArray
            case NoEmptyText => throw IllegalStateException("Cannot write value: text already has a top-level value.")
            case EmptyText => stack[stack.size - 1] = NoEmptyText
            case EmptyObject => stack[stack.size - 1] = NoEmptyObject
            case NoEmptyObject => // write value in object must write name first
                if (!haveName) {
                    throw IllegalStateException("Cannot write value in object: name must be written first.")
                }
                haveName = false
        }
    }
    
    func start(): Unit {
        stack.clear()
        bo.flush()
        haveName = false
        put(EmptyObject)
    }

    func end(): Unit {
        pop()
    }

    func top(): LogWriterState {
        return stack[stack.size - 1]
    }

    func put(scope: LogWriterState) {
        stack.add(scope)
    }

    func pop(): Unit {
        stack.remove(at: stack.size - 1)
    }

    public func flush(): Unit {
        bo.write([b'\n'])
        bo.flush()
    }
}
