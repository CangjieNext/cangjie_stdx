/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.encoding.json.stream

import std.collection.ArrayList
import std.io.OutputStream
import std.time.*

enum JsonWriterState {
    | EmptyArray
    | NoEmptyArray
    | EmptyObject
    | NoEmptyObject
    | EmptyText
    | NoEmptyText
}

public class JsonWriter {
    static const DEFAULT_CAPACITY: Int64 = 4096
    // Scalar writers can emit at most 20 digits plus a separator. Keep this
    // amount of headroom while allowing compact documents to fill the buffer.
    static const FLUSH_THRESHOLD: Int64 = DEFAULT_CAPACITY - 32
    // Keep the existing direct-to-output cutover for large string values.
    static const LARGE_VALUE_THRESHOLD: Int64 = 3500

    var out: OutputStream
    var stack: ArrayList<JsonWriterState> = ArrayList<JsonWriterState>()

    var haveName = false

    var buffer = Array<UInt8>(DEFAULT_CAPACITY, repeat: 0)
    var curPos = 0

    public var writeConfig: WriteConfig = WriteConfig.compact

    public init(out: OutputStream) {
        this.out = out
        stack.add(EmptyText)
    }

    public func flush(): Unit {
        out.write(buffer, 0, curPos)
        curPos = 0
        out.flush()
    }

    @OverflowWrapping
    public func jsonValue(value: String): JsonWriter {
        beforeValue()
        if (value.size > JsonWriter.LARGE_VALUE_THRESHOLD) {
            flushOutBuf()
            unsafe { out.write(value.rawData()) }
        } else {
            if (curPos + value.size > JsonWriter.DEFAULT_CAPACITY - 1) {
                flushOutBuf()
            }
            unsafe { value.rawData().copyTo(buffer, 0, curPos, value.size) }
            curPos += value.size
        }
        this
    }

    // JsonReader.copyValueTo calls these two functions to append one already
    // encoded JSON value without materializing it as a String first.
    func beginRawValue(): Unit {
        beforeValue()
    }

    // JsonReader.copyNameTo uses this pair to preserve the already encoded
    // member name without decoding it into a String first.
    func beginRawName(): Unit {
        beforeName()
    }

    func endRawName(): Unit {
        writeRawByte(b':')
        haveName = true
        useSpaceAfterSeparators()
    }

    func writeRawByte(value: Byte): Unit {
        if (curPos >= buffer.size) {
            flushOutBuf()
        }
        buffer[curPos] = value
        curPos++
    }

    /**
     * Write one already encoded JSON value from a byte array.
     *
     * The caller is responsible for supplying valid JSON bytes, just as for
     * jsonValue. JsonReader uses appendRawBytes after it has entered the value
     * state so that one value can be appended in several contiguous spans.
     */
    public func writeRawBytes(value: Array<Byte>, offset: Int64, length: Int64): JsonWriter {
        beginRawValue()
        appendRawBytes(value, offset, length)
        this
    }

    /**
     * Write an ASCII/UTF-8 JSON member name whose bytes require no escaping.
     *
     * This is intended for static protocol field names. The caller is
     * responsible for providing valid, unescaped JSON-string content.
     */
    public func writeRawName(value: Array<Byte>, offset: Int64, length: Int64): JsonWriter {
        beginRawName()
        writeRawByte(b'"')
        appendRawBytes(value, offset, length)
        writeRawByte(b'"')
        endRawName()
        this
    }

    func appendRawBytes(value: Array<Byte>, offset: Int64, length: Int64): Unit {
        if (offset < 0 || length < 0 || offset + length > value.size) {
            throw IllegalArgumentException("The raw JSON byte range is out of bounds.")
        }
        var sourceOffset = offset
        var remaining = length
        while (remaining > 0) {
            if (curPos >= buffer.size) {
                flushOutBuf()
            }
            let copyLen = min(remaining, buffer.size - curPos)
            value.copyTo(buffer, sourceOffset, curPos, copyLen)
            sourceOffset += copyLen
            curPos += copyLen
            remaining -= copyLen
        }
    }

    func flushOutBuf() {
        out.write(buffer, 0, curPos)
        curPos = 0
        0
    }

    public func writeValue<T>(v: T): JsonWriter where T <: JsonSerializable {
        v.toJson(this)
        haveName = false
        this
    }

    /**
     * Write one Int64 array without repeating generic JsonSerializable
     * dispatch and compact-array state handling for every element.
     */
    @OverflowWrapping
    public func writeInt64Array(values: Array<Int64>): Unit {
        startArray()
        if (writeConfig.newline.isEmpty() && !writeConfig.useSpaceAfterSeparators) {
            writeCompactInt64Array(values)
        } else {
            for (value in values) {
                writeInt64(value)
            }
        }
        endArray()
    }

    @OverflowWrapping
    public func writeInt8Array(values: Array<Int8>): Unit {
        startArray()
        if (writeConfig.newline.isEmpty() && !writeConfig.useSpaceAfterSeparators) {
            writeCompactInt8Array(values)
        } else {
            for (value in values) {
                writeInt64(Int64(value))
            }
        }
        endArray()
    }

    @OverflowWrapping
    public func writeInt16Array(values: Array<Int16>): Unit {
        startArray()
        if (writeConfig.newline.isEmpty() && !writeConfig.useSpaceAfterSeparators) {
            writeCompactInt16Array(values)
        } else {
            for (value in values) {
                writeInt64(Int64(value))
            }
        }
        endArray()
    }

    @OverflowWrapping
    public func writeInt32Array(values: Array<Int32>): Unit {
        startArray()
        if (writeConfig.newline.isEmpty() && !writeConfig.useSpaceAfterSeparators) {
            writeCompactInt32Array(values)
        } else {
            for (value in values) {
                writeInt64(Int64(value))
            }
        }
        endArray()
    }

    @OverflowWrapping
    public func writeIntNativeArray(values: Array<IntNative>): Unit {
        startArray()
        if (writeConfig.newline.isEmpty() && !writeConfig.useSpaceAfterSeparators) {
            writeCompactIntNativeArray(values)
        } else {
            for (value in values) {
                writeInt64(Int64(value))
            }
        }
        endArray()
    }

    @OverflowWrapping
    public func writeUInt8Array(values: Array<UInt8>): Unit {
        startArray()
        if (writeConfig.newline.isEmpty() && !writeConfig.useSpaceAfterSeparators) {
            writeCompactUInt8Array(values)
        } else {
            for (value in values) {
                writeUInt64(UInt64(value))
            }
        }
        endArray()
    }

    @OverflowWrapping
    public func writeUInt16Array(values: Array<UInt16>): Unit {
        startArray()
        if (writeConfig.newline.isEmpty() && !writeConfig.useSpaceAfterSeparators) {
            writeCompactUInt16Array(values)
        } else {
            for (value in values) {
                writeUInt64(UInt64(value))
            }
        }
        endArray()
    }

    @OverflowWrapping
    public func writeUInt32Array(values: Array<UInt32>): Unit {
        startArray()
        if (writeConfig.newline.isEmpty() && !writeConfig.useSpaceAfterSeparators) {
            writeCompactUInt32Array(values)
        } else {
            for (value in values) {
                writeUInt64(UInt64(value))
            }
        }
        endArray()
    }

    @OverflowWrapping
    public func writeUInt64Array(values: Array<UInt64>): Unit {
        startArray()
        if (writeConfig.newline.isEmpty() && !writeConfig.useSpaceAfterSeparators) {
            writeCompactUInt64Array(values)
        } else {
            for (value in values) {
                writeUInt64(value)
            }
        }
        endArray()
    }

    @OverflowWrapping
    public func writeUIntNativeArray(values: Array<UIntNative>): Unit {
        startArray()
        if (writeConfig.newline.isEmpty() && !writeConfig.useSpaceAfterSeparators) {
            writeCompactUIntNativeArray(values)
        } else {
            for (value in values) {
                writeUInt64(UInt64(value))
            }
        }
        endArray()
    }

    @OverflowWrapping
    func writeCompactInt64Array(values: Array<Int64>): Unit {
        for (index in 0..values.size) {
            if (curPos >= FLUSH_THRESHOLD) {
                flushOutBuf()
            }
            if (index > 0) {
                buffer[curPos] = b','
                curPos++
            }
            let value = values[index]
            if (value < 0) {
                buffer[curPos] = b'-'
                curPos++
                curPos += appendUInt64(UInt64(-(value + 1)) + 1)
            } else {
                curPos += appendUInt64(UInt64(value))
            }
        }
    }

    @OverflowWrapping
    func writeCompactInt8Array(values: Array<Int8>): Unit {
        for (index in 0..values.size) {
            writeCompactInt64Element(Int64(values[index]), index)
        }
    }

    @OverflowWrapping
    func writeCompactInt16Array(values: Array<Int16>): Unit {
        for (index in 0..values.size) {
            writeCompactInt64Element(Int64(values[index]), index)
        }
    }

    @OverflowWrapping
    func writeCompactInt32Array(values: Array<Int32>): Unit {
        for (index in 0..values.size) {
            writeCompactInt64Element(Int64(values[index]), index)
        }
    }

    @OverflowWrapping
    func writeCompactIntNativeArray(values: Array<IntNative>): Unit {
        for (index in 0..values.size) {
            writeCompactInt64Element(Int64(values[index]), index)
        }
    }

    @OverflowWrapping
    func writeCompactUInt8Array(values: Array<UInt8>): Unit {
        for (index in 0..values.size) {
            writeCompactUInt64Element(UInt64(values[index]), index)
        }
    }

    @OverflowWrapping
    func writeCompactUInt16Array(values: Array<UInt16>): Unit {
        for (index in 0..values.size) {
            writeCompactUInt64Element(UInt64(values[index]), index)
        }
    }

    @OverflowWrapping
    func writeCompactUInt32Array(values: Array<UInt32>): Unit {
        for (index in 0..values.size) {
            writeCompactUInt64Element(UInt64(values[index]), index)
        }
    }

    @OverflowWrapping
    func writeCompactUInt64Array(values: Array<UInt64>): Unit {
        for (index in 0..values.size) {
            writeCompactUInt64Element(values[index], index)
        }
    }

    @OverflowWrapping
    func writeCompactUIntNativeArray(values: Array<UIntNative>): Unit {
        for (index in 0..values.size) {
            writeCompactUInt64Element(UInt64(values[index]), index)
        }
    }

    @OverflowWrapping
    func writeCompactInt64Element(value: Int64, index: Int64): Unit {
        beforeCompactArrayElement(index)
        if (value < 0) {
            buffer[curPos] = b'-'
            curPos++
            curPos += appendUInt64(UInt64(-(value + 1)) + 1)
        } else {
            curPos += appendUInt64(UInt64(value))
        }
    }

    @OverflowWrapping
    func writeCompactUInt64Element(value: UInt64, index: Int64): Unit {
        beforeCompactArrayElement(index)
        curPos += appendUInt64(value)
    }

    @OverflowWrapping
    func beforeCompactArrayElement(index: Int64): Unit {
        if (curPos >= FLUSH_THRESHOLD) {
            flushOutBuf()
        }
        if (index > 0) {
            buffer[curPos] = b','
            curPos++
        }
    }

    @OverflowWrapping
    func writeInt64(value: Int64): Unit {
        beforeValue()
        if (value < 0) {
            buffer[curPos] = b'-'
            curPos++
            curPos += appendUInt64(UInt64(-(value + 1)) + 1)
        } else {
            curPos += appendUInt64(UInt64(value))
        }
    }

    @OverflowWrapping
    func writeUInt64(value: UInt64): Unit {
        beforeValue()
        curPos += appendUInt64(value)
    }

    @OverflowWrapping
    func appendUInt64(value: UInt64): Int64 {
        if (value < 10) {
            buffer[curPos] = b'0' + UInt8(value)
            return 1
        }

        if (value < 100) {
            let index = Int64(value * 2)
            buffer[curPos] = digits100[index]
            buffer[curPos + 1] = digits100[index + 1]
            return 2
        }

        if (value < 10000) {
            let high = value / 100
            let low = value - high * 100
            let lowIndex = Int64(low * 2)
            if (high < 10) {
                buffer[curPos] = b'0' + UInt8(high)
                buffer[curPos + 1] = digits100[lowIndex]
                buffer[curPos + 2] = digits100[lowIndex + 1]
                return 3
            }

            let highIndex = Int64(high * 2)
            buffer[curPos] = digits100[highIndex]
            buffer[curPos + 1] = digits100[highIndex + 1]
            buffer[curPos + 2] = digits100[lowIndex]
            buffer[curPos + 3] = digits100[lowIndex + 1]
            return 4
        }

        let len = uitoalen(value)
        var next = curPos + len
        var remaining = value
        while (remaining >= 100) {
            let quotient = remaining / 100
            let pair = remaining - quotient * 100
            let index = Int64(pair * 2)
            next -= 2
            buffer[next] = digits100[index]
            buffer[next + 1] = digits100[index + 1]
            remaining = quotient
        }

        if (remaining < 10) {
            buffer[curPos] = b'0' + UInt8(remaining)
        } else {
            let index = Int64(remaining * 2)
            buffer[curPos] = digits100[index]
            buffer[curPos + 1] = digits100[index + 1]
        }
        return len
    }

    @OverflowWrapping
    public func writeNullValue(): JsonWriter {
        beforeValue()
        buffer[curPos] = b'n'
        buffer[curPos + 1] = b'u'
        buffer[curPos + 2] = b'l'
        buffer[curPos + 3] = b'l'
        curPos += 4
        this
    }

    protected func writeWrap(): JsonWriter {
        if (curPos + 1 > JsonWriter.DEFAULT_CAPACITY - 1) {
            flushOutBuf()
        }
        buffer[curPos] = b'\n'
        curPos += 1
        this
    }

    @OverflowWrapping
    public func writeName(name: String): JsonWriter {
        beforeName()
        haveName = true
        name.toJson(this)
        buffer[curPos] = b':'
        curPos++
        haveName = true // reuse String.toJson, need to keep name state
        useSpaceAfterSeparators()
        this
    }

    @OverflowWrapping
    public func startArray(): Unit {
        beforeValue()
        buffer[curPos] = b'['
        curPos++
        put(EmptyArray)
    }

    // end array need to check if the state is after an array
    @OverflowWrapping
    public func endArray(): Unit {
        if (curPos >= FLUSH_THRESHOLD) {
            flushOutBuf()
        }
        match (top()) {
            case EmptyArray | NoEmptyArray =>
                newlineWithIndent(stack.size - 2)
                buffer[curPos] = b']'
                curPos++
            case _ => throw IllegalStateException("End array must be directly after Start array")
        }
        pop()
    }

    @OverflowWrapping
    public func startObject(): Unit {
        beforeValue()
        buffer[curPos] = b'{'
        curPos++
        put(EmptyObject)
    }

    @OverflowWrapping
    public func endObject(): Unit {
        if (curPos >= FLUSH_THRESHOLD) {
            flushOutBuf()
        }
        if (haveName) {
            throw IllegalStateException("End object cannot directly after a name.")
        }
        match (top()) {
            case EmptyObject | NoEmptyObject =>
                newlineWithIndent(stack.size - 2)
                buffer[curPos] = b'}'
                curPos++
            case _ => throw IllegalStateException("End object must be directly after Start object.")
        }
        pop()
    }

    @OverflowWrapping
    func beforeName() {
        if (curPos >= FLUSH_THRESHOLD) {
            flushOutBuf()
        }
        if (haveName) {
            throw IllegalStateException("Already wrote a name, expecting a value.")
        }
        match (top()) {
            case EmptyObject => stack[stack.size - 1] = NoEmptyObject
                newlineWithIndent(stack.size - 1)
            case NoEmptyObject =>
                buffer[curPos] = b','
                curPos++
                newlineWithIndent(stack.size - 1)
            case _ => throw IllegalStateException("The name must be within an object.")
        }
    }

    @OverflowWrapping
    func beforeValue() {
        if (curPos >= FLUSH_THRESHOLD) {
            flushOutBuf()
        }
        match (top()) {
            case NoEmptyArray =>
                buffer[curPos] = b','
                curPos++

                if (writeConfig.newline.isEmpty()) {
                    useSpaceAfterSeparators()
                }
                newlineWithIndent(stack.size - 1)
            case EmptyArray => stack[stack.size - 1] = NoEmptyArray
                newlineWithIndent(stack.size - 1)
            case NoEmptyText => throw IllegalStateException("JSON text must have only one top-level value.")
            case EmptyText => stack[stack.size - 1] = NoEmptyText
            case EmptyObject => stack[stack.size - 1] = NoEmptyObject
            case NoEmptyObject => // write value in object must write name first
                if (!haveName) {
                    throw IllegalStateException("Value in Json object must after a name.")
                }
                haveName = false
        }
    }

    func top(): JsonWriterState {
        return stack[stack.size - 1]
    }

    func put(scope: JsonWriterState) {
        if (stack.size >= MAX_JSON_STREAM_DEPTH) {
            throw IllegalStateException("Json nested depth exceeds ${MAX_JSON_STREAM_DEPTH}.")
        }
        stack.add(scope)
    }

    func pop() {
        stack.remove(at: stack.size - 1)
    }

    func newlineWithIndent(indentLevel: Int64): Unit {
        // new line
        if (writeConfig.newline.isEmpty()) {
            return
        }
        for (b in writeConfig.newline) {
            buffer[curPos] = b
            curPos++

            if (curPos >= buffer.size) {
                flushOutBuf()
            }
        }

        // indent
        if (writeConfig.indent.isEmpty()) {
            return
        }
        for (_ in 0..indentLevel) {
            for (b in writeConfig.indent) {
                buffer[curPos] = b
                curPos++

                if (curPos >= buffer.size) {
                    flushOutBuf()
                }
            }
        }
    }

    func useSpaceAfterSeparators(): Unit {
        if (writeConfig.useSpaceAfterSeparators) {
            buffer[curPos] = b' '
            curPos++
        }
    }
}

public struct WriteConfig {
    private WriteConfig(
        var _newline!: String,
        var _indent!: String,
        var _usesSpaceAfterSeparators!: Bool,
        var _htmlSafe!: Bool,
        var _timeFormat!: String
    ) {}

    public mut prop newline: String {
        get() {
            _newline
        }
        set(v) {
            for (b in v where (b != b'\r' && b != b'\n')) {
                throw IllegalArgumentException("Invalid newline token: ${b}")
            }
            _newline = v
        }
    }

    public mut prop indent: String {
        get() {
            _indent
        }
        set(v) {
            for (b in v where (b != b' ' && b != b'\t')) {
                throw IllegalArgumentException("Invalid indent token: ${b}")
            }
            _indent = v
        }
    }

    public mut prop useSpaceAfterSeparators: Bool {
        get() {
            _usesSpaceAfterSeparators
        }
        set(v) {
            _usesSpaceAfterSeparators = v
        }
    }

    public mut prop htmlSafe: Bool {
        get() {
            _htmlSafe
        }
        set(v) {
            _htmlSafe = v
        }
    }

    public mut prop dateTimeFormat: String {
        get() {
            _timeFormat
        }
        set(v) {
            _timeFormat = v
        }
    }

    public static let compact: WriteConfig = WriteConfig(
        _newline: "",
        _indent: "",
        _usesSpaceAfterSeparators: false,
        _htmlSafe: false,
        _timeFormat: DateTimeFormat.RFC3339
    )

    public static let pretty: WriteConfig = WriteConfig(
        _newline: "\n",
        _indent: "    ",
        _usesSpaceAfterSeparators: true,
        _htmlSafe: false,
        _timeFormat: DateTimeFormat.RFC3339
    )
}
