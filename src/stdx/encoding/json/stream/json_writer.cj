/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.encoding.json.stream

import std.collection.{ArrayList, HashMap}
import std.io.{ByteBuffer, OutputStream}
import std.time.*

/*
 * Native chunk formatter for compact integer arrays.  One call formats as
 * many elements as fit into the writable buffer region, so the per-element
 * capacity checks collapse into one check per chunk.  The element kinds
 * mirror the native side (json_int_array.c).
 */
@FastNative
foreign func CJ_JSON_FormatIntegerArray(input: CPointer<UInt8>, kind: Int64, startIndex: Int64,
    count: Int64, output: CPointer<UInt8>, outputCapacity: Int64, firstElement: Bool): Int64

/*
 * Native chunk formatter for compact Float64 arrays, sharing the packed
 * return contract of CJ_JSON_FormatIntegerArray; a negative value marks a
 * non-finite element.
 */
@FastNative
foreign func CJ_JSON_FormatFloat64Array(input: CPointer<UInt8>, startIndex: Int64, count: Int64,
    output: CPointer<UInt8>, outputCapacity: Int64, firstElement: Bool): Int64

/*
 * Native chunk formatter for compact Float32 arrays: each 4-byte element is
 * widened to double before the same Ryu round trip, matching the
 * element-wise Float64(value) output byte for byte.
 */
@FastNative
foreign func CJ_JSON_FormatFloat32Array(input: CPointer<UInt8>, startIndex: Int64, count: Int64,
    output: CPointer<UInt8>, outputCapacity: Int64, firstElement: Bool): Int64

let JSON_INT_ARRAY_KIND_I8: Int64 = 0
let JSON_INT_ARRAY_KIND_I16: Int64 = 1
let JSON_INT_ARRAY_KIND_I32: Int64 = 2
let JSON_INT_ARRAY_KIND_I64: Int64 = 3
let JSON_INT_ARRAY_KIND_U8: Int64 = 4
let JSON_INT_ARRAY_KIND_U16: Int64 = 5
let JSON_INT_ARRAY_KIND_U32: Int64 = 6
let JSON_INT_ARRAY_KIND_U64: Int64 = 7

/*
 * Arrays below this size keep the inline per-element writer.  The native
 * chunk formatter's input/output pinning and FFI transition are fixed
 * costs that only pay off once enough elements amortize them; measured
 * crossover on T9.3.1/T9.3.2/T9.3.7 is around 20 elements.
 */
let JSON_INT_ARRAY_MIN_CHUNK_ELEMENTS: Int64 = 32

/*
 * Same amortization rationale as the integer threshold: Float64 elements
 * cost more to format (Ryu round trip), so the native chunk formatter pays
 * off from a similar array size.
 */
let JSON_FLOAT64_ARRAY_MIN_CHUNK_ELEMENTS: Int64 = 32

enum JsonWriterState {
    | EmptyArray
    | NoEmptyArray
    | EmptyObject
    | NoEmptyObject
    | CompactSchemaObject
    | CompactSchemaValue
    | EmptyText
    | NoEmptyText
}

public class JsonWriter {
    static const DEFAULT_CAPACITY: Int64 = 4096
    static const DIRECT_SMALL_DOCUMENT_CAPACITY: Int64 = 512
    // Scalar writers can emit at most 20 digits plus a separator. Keep this
    // amount of headroom while allowing compact documents to fill the buffer.
    static const FLUSH_THRESHOLD: Int64 = DEFAULT_CAPACITY - 32
    // Keep the existing direct-to-output cutover for large string values.
    static const LARGE_VALUE_THRESHOLD: Int64 = 3500

    var out: OutputStream
    var stack: ArrayList<JsonWriterState> = ArrayList<JsonWriterState>()

    var haveName = false

    // The ByteBuffer constructor replaces this with an append-region view.
    // Keep the field empty so that path does not first allocate a discarded
    // 4 KiB staging array.
    var buffer = Array<Byte>()
    var curPos = 0
    // A ByteBuffer destination can expose its append region directly.  Keep
    // this separate from the generic OutputStream path: only committed bytes
    // contribute to the ByteBuffer length, so a growth can preserve pending
    // JSON bytes before they become visible to callers.
    var directByteBuffer: ?ByteBuffer = None

    public var writeConfig: WriteConfig = WriteConfig.compact

    public init(out: OutputStream) {
        this.out = out
        buffer = Array<Byte>(DEFAULT_CAPACITY, repeat: 0)
        stack.add(EmptyText)
    }

    public init(out: ByteBuffer) {
        this.out = out
        directByteBuffer = Some(out)
        buffer = out.writableRegion(0, 0)
        stack.add(EmptyText)
    }

    public func flush(): Unit {
        flushOutBuf()
        out.flush()
    }

    /**
     * Discard the current JSON document and prepare this writer for another
     * top-level value. The destination stream is intentionally not flushed:
     * callers that want the previous document must materialize it first.
     */
    public func reset(): Unit {
        curPos = 0
        stack.clear()
        stack.add(EmptyText)
        haveName = false
    }

    @OverflowWrapping
    public func jsonValue(value: String): JsonWriter {
        beforeValue()
        if (let Some(_) <- directByteBuffer) {
            ensureBufferSpace(value.size)
            unsafe { value.rawData().copyTo(buffer, 0, curPos, value.size) }
            curPos += value.size
        } else if (value.size > JsonWriter.LARGE_VALUE_THRESHOLD) {
            flushOutBuf()
            unsafe { out.write(value.rawData()) }
        } else {
            ensureBufferSpace(value.size)
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
        ensureBufferSpace(1)
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

    /**
     * Write one unescaped static object member name and its Int64 value in a
     * single state-machine transition. The name bytes must be valid JSON
     * string content without escaping, as with writeRawName.
     */
    @OverflowWrapping
    public func writeRawNameInt64(value: Array<Byte>, offset: Int64, length: Int64, number: Int64): JsonWriter {
        writeRawNamePrefix(value, offset, length)
        ensureBufferSpace(32)
        if (number < 0) {
            buffer[curPos] = b'-'
            curPos++
            curPos += appendUInt64(UInt64(-(number + 1)) + 1)
        } else {
            curPos += appendUInt64(UInt64(number))
        }
        this
    }

    /**
     * Write one unescaped static object member name and its UInt64 value in a
     * single state-machine transition. The name bytes have the same contract
     * as writeRawName.
     */
    @OverflowWrapping
    public func writeRawNameUInt64(value: Array<Byte>, offset: Int64, length: Int64, number: UInt64): JsonWriter {
        writeRawNamePrefix(value, offset, length)
        ensureBufferSpace(32)
        curPos += appendUInt64(number)
        this
    }

    /**
     * Write one unescaped static object member name and its Bool value in a
     * single state-machine transition. The name bytes have the same contract
     * as writeRawName.
     */
    @OverflowWrapping
    public func writeRawNameBool(value: Array<Byte>, offset: Int64, length: Int64, flag: Bool): JsonWriter {
        writeRawNamePrefix(value, offset, length)
        ensureBufferSpace(5)
        if (flag) {
            buffer[curPos] = b't'
            buffer[curPos + 1] = b'r'
            buffer[curPos + 2] = b'u'
            buffer[curPos + 3] = b'e'
            curPos += 4
        } else {
            buffer[curPos] = b'f'
            buffer[curPos + 1] = b'a'
            buffer[curPos + 2] = b'l'
            buffer[curPos + 3] = b's'
            buffer[curPos + 4] = b'e'
            curPos += 5
        }
        this
    }

    /**
     * Write one unescaped static object member name and a dynamically escaped
     * String value in a single state-machine transition.
     */
    @OverflowWrapping
    public func writeRawNameString(value: Array<Byte>, offset: Int64, length: Int64, text: String): JsonWriter {
        writeRawNamePrefix(value, offset, length)
        writeStringValue(this, text)
        this
    }

    /**
     * Write one unescaped static object member name and a finite Float64 value
     * in a single state-machine transition.
     */
    @OverflowWrapping
    public func writeRawNameFloat64(value: Array<Byte>, offset: Int64, length: Int64, number: Float64): JsonWriter {
        writeRawNamePrefix(value, offset, length)
        writeFloat64Value(this, number)
        this
    }

    /**
     * Start an object whose members are emitted by a compile-time generated
     * compact schema. Schema member prefixes include their own comma/name/
     * colon bytes, so this mode intentionally skips per-member object-state
     * transitions. It is incompatible with pretty-print formatting.
     */
    @OverflowWrapping
    public func startCompactSchemaObject(): JsonWriter {
        beforeValue()
        writeRawByte(b'{')
        put(CompactSchemaObject)
        this
    }

    @OverflowWrapping
    public func endCompactSchemaObject(): JsonWriter {
        match (top()) {
            case CompactSchemaObject =>
                writeRawByte(b'}')
                pop()
            case _ => throw IllegalStateException("End compact schema object must directly follow its start.")
        }
        this
    }

    @OverflowWrapping
    public func writeCompactSchemaInt64(prefix: Array<Byte>, offset: Int64, length: Int64, number: Int64): JsonWriter {
        writeCompactSchemaPrefix(prefix, offset, length)
        ensureBufferSpace(32)
        if (number < 0) {
            buffer[curPos] = b'-'
            curPos++
            curPos += appendUInt64(UInt64(-(number + 1)) + 1)
        } else {
            curPos += appendUInt64(UInt64(number))
        }
        this
    }

    @OverflowWrapping
    public func writeCompactSchemaUInt64(prefix: Array<Byte>, offset: Int64, length: Int64, number: UInt64): JsonWriter {
        writeCompactSchemaPrefix(prefix, offset, length)
        ensureBufferSpace(32)
        curPos += appendUInt64(number)
        this
    }

    @OverflowWrapping
    public func writeCompactSchemaBool(prefix: Array<Byte>, offset: Int64, length: Int64, flag: Bool): JsonWriter {
        writeCompactSchemaPrefix(prefix, offset, length)
        ensureBufferSpace(5)
        if (flag) {
            buffer[curPos] = b't'
            buffer[curPos + 1] = b'r'
            buffer[curPos + 2] = b'u'
            buffer[curPos + 3] = b'e'
            curPos += 4
        } else {
            buffer[curPos] = b'f'
            buffer[curPos + 1] = b'a'
            buffer[curPos + 2] = b'l'
            buffer[curPos + 3] = b's'
            buffer[curPos + 4] = b'e'
            curPos += 5
        }
        this
    }

    @OverflowWrapping
    public func writeCompactSchemaString(prefix: Array<Byte>, offset: Int64, length: Int64, text: String): JsonWriter {
        writeCompactSchemaPrefix(prefix, offset, length)
        writeStringValue(this, text)
        this
    }

    @OverflowWrapping
    public func writeCompactSchemaFloat64(prefix: Array<Byte>, offset: Int64, length: Int64, number: Float64): JsonWriter {
        writeCompactSchemaPrefix(prefix, offset, length)
        writeFloat64Value(this, number)
        this
    }

    /**
     * Write a compile-time generated compact-schema member prefix and arm one
     * ordinary JSON value.  The next value writer consumes CompactSchemaValue
     * in beforeValue(), so arrays, maps and nested @Codable objects can reuse
     * their normal serialization implementations without per-member name
     * state transitions.
     */
    @OverflowWrapping
    public func beginCompactSchemaValue(prefix: Array<Byte>, offset: Int64, length: Int64): JsonWriter {
        writeCompactSchemaPrefix(prefix, offset, length)
        put(CompactSchemaValue)
        this
    }

    @OverflowWrapping
    func writeRawNamePrefix(value: Array<Byte>, offset: Int64, length: Int64): Unit {
        beginRawName()
        writeRawByte(b'"')
        appendRawBytes(value, offset, length)
        writeRawByte(b'"')
        endRawName()
        // The following scalar is the value paired with this name, so it can
        // skip the second beforeValue state-machine transition.
        haveName = false
    }

    @OverflowWrapping
    func writeCompactSchemaPrefix(value: Array<Byte>, offset: Int64, length: Int64): Unit {
        match (top()) {
            case CompactSchemaObject => appendRawBytes(value, offset, length)
            case _ => throw IllegalStateException("Compact schema field must be within a compact schema object.")
        }
    }

    func appendRawBytes(value: Array<Byte>, offset: Int64, length: Int64): Unit {
        if (offset < 0 || length < 0 || offset + length > value.size) {
            throw IllegalArgumentException("The raw JSON byte range is out of bounds.")
        }
        if (let Some(_) <- directByteBuffer) {
            ensureBufferSpace(length)
            value.copyTo(buffer, offset, curPos, length)
            curPos += length
        } else {
            var sourceOffset = offset
            var remaining = length
            while (remaining > 0) {
                ensureBufferSpace(1)
                let copyLen = min(remaining, buffer.size - curPos)
                value.copyTo(buffer, sourceOffset, curPos, copyLen)
                sourceOffset += copyLen
                curPos += copyLen
                remaining -= copyLen
            }
        }
    }

    func ensureBufferSpace(additional: Int64): Unit {
        if (additional < 0) {
            throw IllegalArgumentException("The required JSON buffer space cannot be negative.")
        }
        if (let Some(output) <- directByteBuffer) {
            // Array.slice creates a new view. Reuse the current view until it
            // is actually full; scalar writers call this helper frequently.
            if (buffer.size - curPos < additional) {
                let required = curPos + additional
                let reserve = if (required <= JsonWriter.DIRECT_SMALL_DOCUMENT_CAPACITY) {
                    max(additional, JsonWriter.DIRECT_SMALL_DOCUMENT_CAPACITY - curPos)
                } else if (required <= JsonWriter.DEFAULT_CAPACITY) {
                    max(additional, JsonWriter.DEFAULT_CAPACITY - curPos)
                } else {
                    additional
                }
                buffer = output.writableRegion(curPos, reserve)
            }
        } else if (curPos + additional > buffer.size) {
            flushOutBuf()
        }
    }

    func flushOutBuf(): Unit {
        if (let Some(output) <- directByteBuffer) {
            output.commitWrite(curPos)
            curPos = 0
            buffer = output.writableRegion(0, 0)
        } else {
            out.write(buffer, 0, curPos)
            curPos = 0
        }
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

    /**
     * Write a HashMap<String, Int64> without generic JsonSerializable
     * dispatch for every integer value. Dynamic map names intentionally keep
     * writeName so their JSON escaping semantics remain unchanged.
     */
    @OverflowWrapping
    public func writeStringInt64Map(values: HashMap<String, Int64>): Unit {
        startObject()
        if (writeConfig.newline.isEmpty() && !writeConfig.useSpaceAfterSeparators) {
            writeCompactStringInt64Map(values)
        } else {
            for ((name, value) in values) {
                writeName(name)
                writeInt64(value)
            }
        }
        endObject()
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

    /**
     * Write one Float64 array without repeating generic JsonSerializable
     * dispatch and per-element pinning for every value.
     */
    @OverflowWrapping
    public func writeFloat64Array(values: Array<Float64>): Unit {
        startArray()
        if (writeConfig.newline.isEmpty() && !writeConfig.useSpaceAfterSeparators) {
            writeCompactFloat64Array(values)
        } else {
            for (value in values) {
                writeValue<Float64>(value)
            }
        }
        endArray()
    }

    /**
     * Write one Float32 array through the native chunk formatter, widening
     * every element to double so the digits match writeValue<Float64>.
     */
    @OverflowWrapping
    public func writeFloat32Array(values: Array<Float32>): Unit {
        startArray()
        if (writeConfig.newline.isEmpty() && !writeConfig.useSpaceAfterSeparators) {
            writeCompactFloat32Array(values)
        } else {
            for (value in values) {
                writeValue<Float32>(value)
            }
        }
        endArray()
    }

    /**
     * Write one Float16 array.  Large arrays widen into a temporary
     * Float64 array and reuse its chunk formatter: Float16 is not a CType,
     * so its raw data cannot be pinned directly, and the half-to-double
     * conversion is exact, keeping the output byte-identical to the
     * element-wise path.
     */
    @OverflowWrapping
    public func writeFloat16Array(values: Array<Float16>): Unit {
        startArray()
        if (writeConfig.newline.isEmpty() && !writeConfig.useSpaceAfterSeparators) {
            writeCompactFloat16Array(values)
        } else {
            for (value in values) {
                writeValue<Float16>(value)
            }
        }
        endArray()
    }

    /*
     * Chunk loop for the compact Float64 array writer, mirroring the integer
     * chunk loop: each pass reserves the worst-case output for the remaining
     * elements (capped by the default capacity), pins both arrays and lets
     * the native Ryu-based formatter fill the region.
     */
    func writeFloat64ArrayChunks(values: Array<Float64>): Unit {
        var consumed = 0
        let count = values.size
        while (consumed < count) {
            let remaining = count - consumed
            // 33 bytes cover the worst element: comma + 32 print bytes.
            let wanted = if (remaining <= DEFAULT_CAPACITY / 33) {
                remaining * 33
            } else {
                DEFAULT_CAPACITY
            }
            ensureBufferSpace(wanted)
            let packed = unsafe {
                let input = acquireArrayRawData(values)
                let output = acquireArrayRawData(buffer)
                try {
                    CJ_JSON_FormatFloat64Array(CPointer<UInt8>(input.pointer), consumed, remaining,
                        output.pointer + curPos, buffer.size - curPos, consumed == 0)
                } finally {
                    releaseArrayRawData(output)
                    releaseArrayRawData(input)
                }
            }
            if (packed < 0) {
                throw IllegalStateException("Failed to serialize JSON float.")
            }
            let writtenElements = packed >> 32
            if (writtenElements <= 0) {
                throw IllegalStateException("Float64 array formatter made no progress.")
            }
            consumed += writtenElements
            curPos += packed & 0xFFFFFFFF
        }
    }

    /*
     * Chunk loop for the compact Float32 array writer, mirroring the
     * Float64 loop: the native side widens each element to double before
     * formatting, so the worst-case per-element output is identical.
     */
    func writeFloat32ArrayChunks(values: Array<Float32>): Unit {
        var consumed = 0
        let count = values.size
        while (consumed < count) {
            let remaining = count - consumed
            // 33 bytes cover the worst element: comma + 32 print bytes.
            let wanted = if (remaining <= DEFAULT_CAPACITY / 33) {
                remaining * 33
            } else {
                DEFAULT_CAPACITY
            }
            ensureBufferSpace(wanted)
            let packed = unsafe {
                let input = acquireArrayRawData(values)
                let output = acquireArrayRawData(buffer)
                try {
                    CJ_JSON_FormatFloat32Array(CPointer<UInt8>(input.pointer), consumed, remaining,
                        output.pointer + curPos, buffer.size - curPos, consumed == 0)
                } finally {
                    releaseArrayRawData(output)
                    releaseArrayRawData(input)
                }
            }
            if (packed < 0) {
                throw IllegalStateException("Failed to serialize JSON float.")
            }
            let writtenElements = packed >> 32
            if (writtenElements <= 0) {
                throw IllegalStateException("Float32 array formatter made no progress.")
            }
            consumed += writtenElements
            curPos += packed & 0xFFFFFFFF
        }
    }

    /*
     * Shared chunk loop for the compact integer array writers: each pass
     * reserves buffer space, pins the current view and lets the native
     * formatter fill it.  The input and output raw-data handles are acquired
     * only after the current output region has been selected, then released
     * immediately after that one foreign call.  This keeps the FFI pinning
     * scope free of buffer growth, stream flushing, and other Cangjie work.
     */
    func writeIntegerArrayChunks<T>(values: Array<T>, kind: Int64): Unit where T <: CType {
        var consumed = 0
        let count = values.size
        while (consumed < count) {
            let remaining = count - consumed
            // 21 bytes cover the worst element: comma + minus + 20 digits.
            let wanted = if (remaining <= DEFAULT_CAPACITY / 21) {
                remaining * 21
            } else {
                DEFAULT_CAPACITY
            }
            ensureBufferSpace(wanted)
            let packed = unsafe {
                let input = acquireArrayRawData(values)
                let output = acquireArrayRawData(buffer)
                try {
                    CJ_JSON_FormatIntegerArray(CPointer<UInt8>(input.pointer), kind, consumed, remaining,
                        output.pointer + curPos, buffer.size - curPos, consumed == 0)
                } finally {
                    releaseArrayRawData(output)
                    releaseArrayRawData(input)
                }
            }
            if (packed < 0) {
                throw IllegalStateException("Unsupported integer array kind: ${kind}")
            }
            let writtenElements = packed >> 32
            if (writtenElements <= 0) {
                throw IllegalStateException("Integer array formatter made no progress.")
            }
            consumed += writtenElements
            curPos += packed & 0xFFFFFFFF
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
        ensureBufferSpace(32)
        if (index > 0) {
            buffer[curPos] = b','
            curPos++
        }
    }

    @OverflowWrapping
    func writeCompactInt64Array(values: Array<Int64>): Unit {
        if (values.size < JSON_INT_ARRAY_MIN_CHUNK_ELEMENTS) {
            // Keep the original flat per-element loop for small arrays: the
            // helper call per element measurably regressed nested small-array
            // documents (T9.3.7), while the chunk formatter's pinning + FFI
            // overhead only pays off once enough elements amortize it.
            for (index in 0..values.size) {
                ensureBufferSpace(32)
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
            return
        }
        writeIntegerArrayChunks(values, JSON_INT_ARRAY_KIND_I64)
    }

    @OverflowWrapping
    func writeCompactFloat64Array(values: Array<Float64>): Unit {
        if (values.size < JSON_FLOAT64_ARRAY_MIN_CHUNK_ELEMENTS) {
            // Small arrays keep the per-element writer, matching the integer
            // array threshold rationale: the chunk formatter's pinning + FFI
            // overhead only pays off once enough elements amortize it.
            for (index in 0..values.size) {
                beforeCompactArrayElement(index)
                writeFloat64Value(this, values[index])
            }
            return
        }
        writeFloat64ArrayChunks(values)
    }

    @OverflowWrapping
    func writeCompactFloat32Array(values: Array<Float32>): Unit {
        if (values.size < JSON_FLOAT64_ARRAY_MIN_CHUNK_ELEMENTS) {
            for (index in 0..values.size) {
                beforeCompactArrayElement(index)
                writeFloat64Value(this, Float64(values[index]))
            }
            return
        }
        writeFloat32ArrayChunks(values)
    }

    @OverflowWrapping
    func writeCompactFloat16Array(values: Array<Float16>): Unit {
        if (values.size < JSON_FLOAT64_ARRAY_MIN_CHUNK_ELEMENTS) {
            for (index in 0..values.size) {
                beforeCompactArrayElement(index)
                writeFloat64Value(this, Float64(values[index]))
            }
            return
        }
        // Float16 is not a CType, so its array cannot be pinned for the
        // native formatter.  Widen once into a temporary Float64 array
        // (the conversion is exact) and reuse the chunk formatter; the
        // O(n) widen pass is far cheaper than per-element FFI.
        let widened = Array<Float64>(values.size, repeat: 0.0)
        for (index in 0..values.size) {
            widened[index] = Float64(values[index])
        }
        writeFloat64ArrayChunks(widened)
    }

    @OverflowWrapping
    func writeCompactStringInt64Map(values: HashMap<String, Int64>): Unit {
        for ((name, value) in values) {
            writeName(name)
            writeInt64(value)
        }
    }

    @OverflowWrapping
    func writeCompactInt8Array(values: Array<Int8>): Unit {
        if (values.size < JSON_INT_ARRAY_MIN_CHUNK_ELEMENTS) {
            for (index in 0..values.size) {
                writeCompactInt64Element(Int64(values[index]), index)
            }
            return
        }
        writeIntegerArrayChunks(values, JSON_INT_ARRAY_KIND_I8)
    }

    func writeCompactInt16Array(values: Array<Int16>): Unit {
        if (values.size < JSON_INT_ARRAY_MIN_CHUNK_ELEMENTS) {
            for (index in 0..values.size) {
                writeCompactInt64Element(Int64(values[index]), index)
            }
            return
        }
        writeIntegerArrayChunks(values, JSON_INT_ARRAY_KIND_I16)
    }

    func writeCompactInt32Array(values: Array<Int32>): Unit {
        if (values.size < JSON_INT_ARRAY_MIN_CHUNK_ELEMENTS) {
            for (index in 0..values.size) {
                writeCompactInt64Element(Int64(values[index]), index)
            }
            return
        }
        writeIntegerArrayChunks(values, JSON_INT_ARRAY_KIND_I32)
    }

    @OverflowWrapping
    func writeCompactIntNativeArray(values: Array<IntNative>): Unit {
        if (values.size < JSON_INT_ARRAY_MIN_CHUNK_ELEMENTS) {
            for (index in 0..values.size) {
                writeCompactInt64Element(Int64(values[index]), index)
            }
            return
        }
        let kind = if (Int64(sizeOf<IntNative>()) == 8) {
            JSON_INT_ARRAY_KIND_I64
        } else {
            JSON_INT_ARRAY_KIND_I32
        }
        writeIntegerArrayChunks(values, kind)
    }

    func writeCompactUInt8Array(values: Array<UInt8>): Unit {
        if (values.size < JSON_INT_ARRAY_MIN_CHUNK_ELEMENTS) {
            for (index in 0..values.size) {
                writeCompactUInt64Element(UInt64(values[index]), index)
            }
            return
        }
        writeIntegerArrayChunks(values, JSON_INT_ARRAY_KIND_U8)
    }

    @OverflowWrapping
    func writeCompactUInt16Array(values: Array<UInt16>): Unit {
        if (values.size < JSON_INT_ARRAY_MIN_CHUNK_ELEMENTS) {
            for (index in 0..values.size) {
                writeCompactUInt64Element(UInt64(values[index]), index)
            }
            return
        }
        writeIntegerArrayChunks(values, JSON_INT_ARRAY_KIND_U16)
    }

    func writeCompactUInt32Array(values: Array<UInt32>): Unit {
        if (values.size < JSON_INT_ARRAY_MIN_CHUNK_ELEMENTS) {
            for (index in 0..values.size) {
                writeCompactUInt64Element(UInt64(values[index]), index)
            }
            return
        }
        writeIntegerArrayChunks(values, JSON_INT_ARRAY_KIND_U32)
    }

    @OverflowWrapping
    func writeCompactUInt64Array(values: Array<UInt64>): Unit {
        if (values.size < JSON_INT_ARRAY_MIN_CHUNK_ELEMENTS) {
            for (index in 0..values.size) {
                writeCompactUInt64Element(values[index], index)
            }
            return
        }
        writeIntegerArrayChunks(values, JSON_INT_ARRAY_KIND_U64)
    }

    @OverflowWrapping
    func writeCompactUIntNativeArray(values: Array<UIntNative>): Unit {
        if (values.size < JSON_INT_ARRAY_MIN_CHUNK_ELEMENTS) {
            for (index in 0..values.size) {
                writeCompactUInt64Element(UInt64(values[index]), index)
            }
            return
        }
        let kind = if (Int64(sizeOf<UIntNative>()) == 8) {
            JSON_INT_ARRAY_KIND_U64
        } else {
            JSON_INT_ARRAY_KIND_U32
        }
        writeIntegerArrayChunks(values, kind)
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
        ensureBufferSpace(1)
        buffer[curPos] = b'\n'
        curPos += 1
        this
    }

    @OverflowWrapping
    public func writeName(name: String): JsonWriter {
        beforeName()
        haveName = true
        name.toJson(this)
        ensureBufferSpace(1)
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
        ensureBufferSpace(1)
        match (top()) {
            case EmptyArray | NoEmptyArray =>
                newlineWithIndent(stack.size - 2)
                ensureBufferSpace(1)
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
        ensureBufferSpace(1)
        if (haveName) {
            throw IllegalStateException("End object cannot directly after a name.")
        }
        match (top()) {
            case EmptyObject | NoEmptyObject =>
                newlineWithIndent(stack.size - 2)
                ensureBufferSpace(1)
                buffer[curPos] = b'}'
                curPos++
            case _ => throw IllegalStateException("End object must be directly after Start object.")
        }
        pop()
    }

    @OverflowWrapping
    func beforeName() {
        ensureBufferSpace(32)
        if (haveName) {
            throw IllegalStateException("Already wrote a name, expecting a value.")
        }
        match (top()) {
            case EmptyObject => stack[stack.size - 1] = NoEmptyObject
                newlineWithIndent(stack.size - 1)
                ensureBufferSpace(1)
            case NoEmptyObject =>
                buffer[curPos] = b','
                curPos++
                newlineWithIndent(stack.size - 1)
                ensureBufferSpace(1)
            case _ => throw IllegalStateException("The name must be within an object.")
        }
    }

    @OverflowWrapping
    func beforeValue() {
        ensureBufferSpace(32)
        match (top()) {
            case NoEmptyArray =>
                buffer[curPos] = b','
                curPos++

                if (writeConfig.newline.isEmpty()) {
                    useSpaceAfterSeparators()
                }
                newlineWithIndent(stack.size - 1)
                ensureBufferSpace(1)
            case EmptyArray => stack[stack.size - 1] = NoEmptyArray
                newlineWithIndent(stack.size - 1)
                ensureBufferSpace(1)
            case NoEmptyText => throw IllegalStateException("JSON text must have only one top-level value.")
            case EmptyText => stack[stack.size - 1] = NoEmptyText
            case EmptyObject => stack[stack.size - 1] = NoEmptyObject
            case NoEmptyObject => // write value in object must write name first
                if (!haveName) {
                    throw IllegalStateException("Value in Json object must after a name.")
                }
                haveName = false
            case CompactSchemaValue => pop()
            case CompactSchemaObject =>
                throw IllegalStateException("Compact schema object accepts only compact schema fields.")
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
            ensureBufferSpace(1)
            buffer[curPos] = b
            curPos++
        }

        // indent
        if (writeConfig.indent.isEmpty()) {
            return
        }
        for (_ in 0..indentLevel) {
            for (b in writeConfig.indent) {
                ensureBufferSpace(1)
                buffer[curPos] = b
                curPos++
            }
        }
    }

    func useSpaceAfterSeparators(): Unit {
        if (writeConfig.useSpaceAfterSeparators) {
            ensureBufferSpace(1)
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
