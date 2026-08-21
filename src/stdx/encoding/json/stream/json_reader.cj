/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.encoding.json.stream

import std.io.InputStream
import std.math.*
import std.time.*
import std.collection.{ArrayList, HashMap}

@FastNative
foreign func CJ_ReadString(buffer: CPointer<Byte>, left: Int64, right: Int64): Int64

/*
 * Native batch parser for JSON arrays of plain decimal Int64 elements.
 * One call parses as many elements as fit into the output chunk, collapsing
 * the per-element peeked/stacks state machine into a single scan; the
 * element kinds and stop reasons mirror the native side (json_int_array.c).
 */
@FastNative
foreign func CJ_JSON_ParseInt64Array(input: CPointer<Byte>, len: Int64, out: CPointer<Int64>,
    outCap: Int64): Int64

@FastNative
foreign func CJ_JSON_ParseUInt64Array(input: CPointer<Byte>, len: Int64, out: CPointer<UInt64>,
    outCap: Int64): Int64

@FastNative
foreign func CJ_JSON_ParseStringInt64Members(input: CPointer<Byte>, len: Int64,
    keyStarts: CPointer<Int64>, keyLens: CPointer<Int64>, values: CPointer<Int64>, outCap: Int64): Int64

/** Parse a contiguous, ordinary JSON Float64 through Ryu without a temporary String. */
@FastNative
foreign func CJ_JSON_TryParseFloat64(input: CPointer<Byte>, start: Int64, end: Int64): Float64

/*
 * Small arrays dominate nested-object payloads. Start with a compact scratch
 * buffer, then promote to the throughput-oriented chunk only on overflow.
 */
const JSON_PARSE_INT64_INITIAL_CHUNK_ELEMS: Int64 = 16
const JSON_PARSE_INT64_CHUNK_ELEMS: Int64 = 256
const JSON_PARSE_MAP_CHUNK_ELEMS: Int64 = 32

const HIGH_1_UInt8: UInt8 = 0b10000000 // 0x80
const HIGH_3_UInt8: UInt8 = 0b11100000 // 0xe0
const HIGH_4_UInt8: UInt8 = 0b11110000 // 0xf0
const HIGH_5_UInt8: UInt8 = 0b11111000 // 0xf8
const HIGH_6_UInt8: UInt8 = 0b11111100 // 0xfc
const MAX_JSON_STREAM_STRING_BUFFER_SIZE: Int64 = 32 * 1024 * 1024

func ensureFiniteJsonFloat(value: Float64): Float64 {
    if (value.isNaN() || value.isInf()) {
        throw IllegalStateException("Invalid float detected.")
    }
    return value
}

func isHighSurrogate(num: UInt32): Bool {
    return num >= 0xD800u32 && num <= 0xDBFFu32 // UTF-16 high-surrogate range: D800..DBFF.
}

func isLowSurrogate(num: UInt32): Bool {
    return num >= 0xDC00u32 && num <= 0xDFFFu32 // UTF-16 low-surrogate range: DC00..DFFF.
}

public class JsonReader {
    var inputStream: InputStream // the input stream
    let buffer: Array<Byte> = Array<Byte>(1024, repeat: 0)
    let stacks = JsonStateStack() // a stack of json types(object/array)
    let stringBuffer: StringBuffer = StringBuffer() // a buffer for readed string

    var peeked: Int64 = PEEK_STATE_NONE // peeked state
    var availLen: Int64 = 0 // The amount of valid data in the buffer
    var index: Int64 = 0 // The start position of valid data in the buffer
    // Span of the most recently consumed simple field name.  It is valid only
    // until the caller advances the reader again and supports the hash-based
    // static-name dispatch fast path below without materializing a String.
    var lastFieldNameStart: Int64 = -1
    var lastFieldNameLen: Int64 = -1

    var dateTimeFormat: ?DateTimeFormat = None

    public init(inputStream: InputStream) {
        this.inputStream = inputStream
    }

    /**
     * Rebind this reader to a new input stream while retaining its internal
     * byte/string buffers and state-stack allocation.  The caller owns the
     * stream lifetime and must not reset a reader concurrently with a read.
     */
    public func reset(inputStream: InputStream): Unit {
        this.inputStream = inputStream
        availLen = 0
        index = 0
        peeked = PEEK_STATE_NONE
        lastFieldNameStart = -1
        lastFieldNameLen = -1
        dateTimeFormat = None
        stacks.reset()
        stringBuffer.clear()
    }

    @Frozen
    public func readValue<T>(): T where T <: JsonDeserializable<T> {
        beforeRead()
        let res = T.fromJson(this)
        afterValueRead()
        return res
    }

    /**
     * Read an Int64 without the generic ``JsonDeserializable`` dispatch.
     *
     * This is the scalar counterpart to the array batch reader: macro-generated
     * object fields use it after their name has been consumed.  Range checking
     * and delimiter/state handling are intentionally identical to
     * ``readValue<Int64>``.
     */
    @OverflowWrapping
    public func readInt64Value(): Int64 {
        return readDirectInt64Value()
    }

    /**
     * Read a contiguous ordinary decimal Int64 without entering the generic
     * number-system parser.  Tokens that are buffer-spanning, overflow, or
     * use any non-decimal spelling deliberately fall back before consuming
     * input, preserving the existing parser's value/error semantics.
     */
    @OverflowWrapping
    public func readDirectInt64Value(): Int64 {
        beforeRead()
        if (let Some(value) <- tryReadDirectDecimalInt64()) {
            afterValueRead()
            return value
        }
        let (res, overflow) = readInt()
        if (overflow) {
            throw OverflowException("The next number is out of range for Int64.")
        }
        afterValueRead()
        return res
    }

    @OverflowWrapping
    private func tryReadDirectDecimalInt64(): Option<Int64> {
        let originalIndex = index
        var pos = originalIndex
        let limit = index + availLen
        if (peeked == PEEK_STATE_NONE || peeked == PEEK_STATE_VALUE) {
            while (pos < limit && isJsonWhiteSpace(buffer[pos])) {
                pos++
            }
            // The generic stream parser owns whitespace that reaches a
            // buffer edge, including its precise end-of-stream diagnostic.
            if (pos >= limit) { return None }
        } else if (peeked != PEEK_STATE_NUMBER) {
            return None
        }

        var negative = false
        if (buffer[pos] == b'-') {
            negative = true
            pos++
            if (pos >= limit) { return None }
        }
        if (buffer[pos] < b'0' || buffer[pos] > b'9') {
            return None
        }
        var magnitude = 0u64
        var overflow = false
        while (pos < limit && buffer[pos] >= b'0' && buffer[pos] <= b'9') {
            let digit = UInt64(buffer[pos] - b'0')
            if (magnitude > (MAXVAL_UI64 - digit) / 10) {
                overflow = true
            } else {
                magnitude = magnitude * 10 + digit
            }
            pos++
        }
        // Require an in-buffer delimiter.  This also rejects number-system
        // prefixes, exponents and fractions without disturbing the reader.
        if (pos >= limit) { return None }
        let delimiter = buffer[pos]
        if (!isJsonWhiteSpace(delimiter) && delimiter != b',' && delimiter != b']' && delimiter != b'}') {
            return None
        }
        if (overflow || (!negative && magnitude > MAXVAL_I64) ||
            (negative && magnitude > MAXABSVAL_I64)) {
            return None
        }
        index = pos
        availLen -= pos - originalIndex
        peeked = PEEK_STATE_NUMBER
        return Some(if (negative) { Int64(-magnitude) } else { Int64(magnitude) })
    }

    /**
     * Read a Float64 through the native Ryu parser when its complete token is
     * already in the reader buffer.  Non-standard, malformed, long, and
     * buffer-spanning input deliberately falls back to ``readFloat`` so this
     * typed entry point keeps the existing stream semantics.
     */
    @OverflowWrapping
    public func readFloat64Value(): Float64 {
        beforeRead()
        let _ = peek()
        if (let Some(value) <- tryReadFloat64ValueFast()) {
            afterValueRead()
            return value
        }
        let value = ensureFiniteJsonFloat(readFloat())
        afterValueRead()
        return value
    }

    @OverflowWrapping
    private func tryReadFloat64ValueFast(): Option<Float64> {
        if (peeked != PEEK_STATE_NUMBER) {
            return None
        }
        let start = index
        let limit = index + availLen
        var end = start
        while (end < limit) {
            let b = buffer[end]
            if ((b >= b'0' && b <= b'9') || b == b'-' || b == b'+' || b == b'.' ||
                b == b'e' || b == b'E') {
                end++
            } else {
                break
            }
        }
        // The native path needs both a full token and its delimiter in this
        // buffer; otherwise the original streaming parser owns the input.
        if (end == start || end == limit || end - start < 16) {
            return None
        }
        let delimiter = buffer[end]
        if (delimiter != b',' && delimiter != b']' && delimiter != b'}' &&
            delimiter != b' ' && delimiter != b'\n' && delimiter != b'\r' && delimiter != b'\t') {
            return None
        }
        var value = Float64.NaN
        unsafe {
            let handle = acquireArrayRawData<Byte>(buffer)
            try {
                value = CJ_JSON_TryParseFloat64(handle.pointer, start, end)
            } finally {
                releaseArrayRawData(handle)
            }
        }
        if (value.isNaN()) {
            return None
        }
        availLen -= end - start
        index = end
        return Some(ensureFiniteJsonFloat(value))
    }

    // Shared completion logic for generic and typed scalar reads.  This is
    // intentionally stricter than afterRead(), preserving readValue's comma
    // validation for every public value-reading API.
    private func afterValueRead(): Unit {
        let nextByte: Byte = if (let Some(v) <- tryNextNonJsonWhitespace()) {
            v
        } else {
            peeked = PEEK_STATE_NONE
            return
        }
        if (nextByte == b',') {
            index++
            availLen--
            match (stacks.top) {
                case 1 => peeked = PEEK_STATE_NAME /* JsonStateStack.JSON_OBJECT */
                case 2 => peeked = PEEK_STATE_VALUE /* JsonStateStack.JSON_ARRAY */
                case _ => ()
            }
        } else if (nextByte == b']' && stacks.top == JsonStateStack.JSON_ARRAY) {
            peeked = PEEK_STATE_ARRAY_END
        } else if (nextByte == b'}' && stacks.top == JsonStateStack.JSON_OBJECT) {
            peeked = PEEK_STATE_OBJECT_END
        } else {
            if (nextByte != b']' && nextByte != b'}') {
                match (stacks.top) {
                    case 1 where peeked != PEEK_STATE_NAME => throw IllegalStateException("Commas are required to separate values in arrays and object members.")// json object
                    case 2 where peeked != PEEK_STATE_VALUE => throw IllegalStateException("Commas are required to separate values in arrays and object members.") // json array
                    case _ => () // top level value
                }
            }
            peeked = PEEK_STATE_NONE
        }
    }

    /**
     * read the json raw data directly without specifying the type
     */
    public func readValueBytes(): Array<Byte> {
        // 1. the leading whitespaces will be skipped in the peek() function
        // 2. the peek() will return None when read to the end of stream
        if (let Some(token) <- peek()) {
            match (token) {
                case JsonNull | JsonBool | JsonNumber => nextValue(stringBuffer)
                case JsonString => nextString(stringBuffer)
                case BeginArray => nextArray(stringBuffer)
                case BeginObject => nextObject(stringBuffer)
                case EndArray | EndObject => ()
                case Name =>
                    nextName(stringBuffer)
                    nextNonJsonWhitespace(stringBuffer) // keep the whitespaces between ':' to start of the next token
                    let token = peek().getOrThrow(
                        {
                            => throw IllegalStateException("The JSON stream ends at an incorrect location.")
                        })
                    match (token) {
                        case JsonNull | JsonBool | JsonNumber => nextValue(stringBuffer)
                        case JsonString => nextString(stringBuffer)
                        case BeginArray => nextArray(stringBuffer)
                        case BeginObject => nextObject(stringBuffer)
                        case _ => throw IllegalStateException("The name must be followed by JSON value.")
                    }
            }
        }
        afterRead()

        let ret = stringBuffer.data[0..stringBuffer.size].clone()
        stringBuffer.clear()

        return ret
    }

    /**
     * Copy the next JSON value to a JsonWriter without creating an intermediate
     * Array<Byte> or String. The copied value keeps its original JSON encoding.
     */
    public func copyValueTo(writer: JsonWriter): Unit {
        beforeRead()
        if (let Some(token) <- peek()) {
            writer.beginRawValue()
            match (token) {
                case JsonNull | JsonBool | JsonNumber =>
                    copyValue(writer)
                case JsonString =>
                    copyString(writer)
                case BeginArray =>
                    copyArray(writer)
                case BeginObject =>
                    copyObject(writer)
                case Name | EndArray | EndObject =>
                    throw IllegalStateException("The next token is not a JSON value.")
            }
            afterRead()
        }
    }

    /**
     * Copy the next object member name to a JsonWriter without creating a
     * decoded String. Whitespace before ':' is normalized just as it is by
     * JsonWriter.writeName.
     */
    public func copyNameTo(writer: JsonWriter): Unit {
        if (peeked != PEEK_STATE_NAME && peek() != Some(Name)) {
            throw IllegalStateException("Failed to read name.")
        }
        writer.beginRawName()
        copyString(writer)
        if (nextNonJsonWhitespace() != b':') {
            throw IllegalStateException("Missing ':' after name.")
        }
        index++
        availLen--
        peeked = PEEK_STATE_VALUE
        writer.endRawName()
    }

    /**
     * Fast-path comparison for a short, unescaped object name. The method
     * never consumes input; names that cross the reader buffer or contain
     * escapes simply return false and can be copied with copyNameTo.
     */
    public func nextNameEquals(name: Array<Byte>): Bool {
        if (peeked != PEEK_STATE_NAME && peek() != Some(Name)) {
            return false
        }
        if (availLen < name.size + 2 || buffer[index] != b'"' || buffer[index + name.size + 1] != b'"') {
            return false
        }
        var i = 0
        while (i < name.size) {
            if (buffer[index + i + 1] != name[i]) {
                return false
            }
            i++
        }
        return true
    }

    /**
     * 尝试读取字段名到调用方缓冲区（零分配快速路径）。
     *
     * 仅当 upcoming token 为字段名、名字完整落在当前 buffer 内、不含转义
     * 反斜杠、长度不超过 ``buf.size`` 且冒号紧跟右引号（无空白）时，拷贝
     * 原始字节到 ``buf``、消费 ``"name":`` 并置 ``peeked = PEEK_STATE_VALUE``，
     * 返回名字字节长度。
     * 其余情况（转义名、跨界名、名字后有空白等）返回 -1 且不移动任何状态，
     * 调用方回退 ``readName`` 完整路径。
     */
    @OverflowWrapping
    public func tryReadNameInto(buf: Array<Byte>): Int64 {
        if (peeked != PEEK_STATE_NAME && peek() != Some(Name)) {
            return -1
        }
        // buffer[index] is the opening quote; scan for the closing quote.
        var end = index + 1
        let limit = index + availLen
        while (end < limit) {
            let b = buffer[end]
            if (b == b'"') {
                break
            }
            if (b == b'\\') {
                return -1 // escaped name: fallback to readName
            }
            end++
        }
        if (end >= limit) {
            return -1 // closing quote not in buffer: fallback
        }
        let len = end - (index + 1)
        if (len > buf.size) {
            return -1
        }
        // ':' must immediately follow the closing quote (no whitespace fast path).
        if (end + 1 >= limit || buffer[end + 1] != b':') {
            return -1
        }
        var i = 0
        while (i < len) {
            buf[i] = buffer[index + 1 + i]
            i++
        }
        index += len + 3
        availLen -= len + 3
        peeked = PEEK_STATE_VALUE
        return len
    }

    /**
     * Advance an object decoder to its next member name in one state-machine
     * operation.
     *
     * Return values are deliberately compact for macro-generated decode loops:
     * a non-negative value is the byte length returned by ``tryReadNameInto``;
     * ``-1`` means that the name needs the existing ``readName`` slow path
     * (escaped, split across the buffer, too long, or whitespace before ':');
     * ``-2`` means that the next token is ``EndObject``.  The slow-path result
     * leaves reader state untouched, while the end result leaves the end token
     * peeked so a following ``endObject`` has the normal semantics.
     */
    @OverflowWrapping
    public func nextFieldInto(buf: Array<Byte>): Int64 {
        match (peek()) {
            case Some(JsonToken.EndObject) => return -2
            case Some(JsonToken.Name) => return tryReadNameInto(buf)
            case _ => throw IllegalStateException("Expect an object member name or EndObject.")
        }
    }

    /**
     * Consume a simple object member name and return its bounded DJB2 hash.
     *
     * A non-negative result means the unescaped name and following ':' were
     * consumed.  ``lastFieldNameEquals`` must immediately confirm the chosen
     * static literal before dispatching; this keeps hash collisions harmless.
     * ``-1`` leaves the reader unchanged for the existing ``readName`` slow
     * path, and ``-2`` denotes ``EndObject`` just like ``nextFieldInto``.
     */
    @OverflowWrapping
    public func nextFieldHash(): Int64 {
        match (peek()) {
            case Some(JsonToken.EndObject) => return -2
            case Some(JsonToken.Name) => ()
            case _ => throw IllegalStateException("Expect an object member name or EndObject.")
        }
        var end = index + 1
        let limit = index + availLen
        var hash: Int64 = 5381
        while (end < limit) {
            let b = buffer[end]
            if (b == b'"') {
                break
            }
            if (b == b'\\') {
                return -1
            }
            // Keep the return value non-negative so -1/-2 remain sentinels.
            hash = ((hash * 33) + Int64(b)) & 0x7fffffff
            end++
        }
        if (end >= limit || end + 1 >= limit || buffer[end + 1] != b':') {
            return -1
        }
        lastFieldNameStart = index + 1
        lastFieldNameLen = end - lastFieldNameStart
        let consumed = end - index + 2
        index += consumed
        availLen -= consumed
        peeked = PEEK_STATE_VALUE
        return hash
    }

    /**
     * Exact confirmation for the name returned by ``nextFieldHash``.
     *
     * The comparison reads the current reader buffer directly and does not
     * allocate a temporary byte array or String.  It is intentionally public
     * so generated decoders can use it, but callers must invoke it before
     * reading/skipping the corresponding value.
     */
    @OverflowWrapping
    public func lastFieldNameEquals(name: String): Bool {
        if (lastFieldNameStart < 0) {
            return false
        }
        let raw = unsafe { name.rawData() }
        if (raw.size != lastFieldNameLen) {
            return false
        }
        var i = 0
        while (i < lastFieldNameLen) {
            if (buffer[lastFieldNameStart + i] != raw[i]) {
                return false
            }
            i++
        }
        return true
    }

    /**
     * Consume and verify the next object member name against an exact fixed
     * schema literal without allocating a temporary String for the input name.
     *
     * This is deliberately strict: end-of-object, escaped names, whitespace
     * between a name and ':', cross-buffer names, or a different literal all
     * fail instead of taking the ordinary permissive reader fallback.
     */
    @OverflowWrapping
    public func expectNextFieldName(name: String): Unit {
        let hash = nextFieldHash()
        if (hash < 0 || !lastFieldNameEquals(name)) {
            throw IllegalStateException("Fixed JSON schema field name mismatch.")
        }
    }

    /**
     * Consume one exact, unescaped fixed-schema member name in a single scan.
     *
     * Unlike ``expectNextFieldName``, this route does not calculate a dispatch
     * hash and then scan the same bytes again for confirmation.  It is only
     * for generated strict decoders that already know the one legal next
     * literal.  Any escaped name, whitespace before ':', cross-buffer name,
     * end-of-object, or mismatch is rejected.
     */
    @OverflowWrapping
    public func expectNextFixedFieldName(name: String): Unit {
        if (peeked != PEEK_STATE_NAME && peek() != Some(Name)) {
            throw IllegalStateException("Fixed JSON schema field name mismatch.")
        }
        let raw = unsafe { name.rawData() }
        let limit = index + availLen
        var pos = index + 1
        var i = 0
        while (i < raw.size) {
            if (pos >= limit || buffer[pos] != raw[i]) {
                throw IllegalStateException("Fixed JSON schema field name mismatch.")
            }
            pos++
            i++
        }
        if (pos + 1 >= limit || buffer[pos] != b'"' || buffer[pos + 1] != b':') {
            throw IllegalStateException("Fixed JSON schema field name mismatch.")
        }
        let consumed = pos - index + 2
        index += consumed
        availLen -= consumed
        lastFieldNameStart = -1
        lastFieldNameLen = -1
        peeked = PEEK_STATE_VALUE
    }

    /**
     * 尝试直接物化一个简单字段名并消费其后的冒号。
     *
     * 与 ``tryReadNameInto`` 的接受条件相同，但不经过调用方的临时字节
     * 缓冲区：字段名完整位于当前 buffer、无转义且右引号后紧跟冒号时，
     * 直接从输入 span 创建 ``String``，消费 ``"name":`` 并返回 ``Some``。
     * 其余情况返回 ``None``，且 reader 状态完全不变，调用方必须回退到
     * ``readName`` 保持转义、跨 buffer 与空白场景的既有语义。
     */
    @OverflowWrapping
    public func tryReadNameString(): Option<String> {
        if (peeked != PEEK_STATE_NAME && peek() != Some(Name)) {
            return None
        }
        var end = index + 1
        let limit = index + availLen
        // M3: Map keys are commonly short ASCII names (for example key0,
        // key99).  Scan four bytes per iteration in pure Cangjie before the
        // scalar tail; this avoids a loop back-edge and two delimiter checks
        // for every byte without adding a per-key native/FFI call.
        while (end + 4 <= limit) {
            let b0 = buffer[end]
            let b1 = buffer[end + 1]
            let b2 = buffer[end + 2]
            let b3 = buffer[end + 3]
            if (b0 == b'"' || b0 == b'\\' || b1 == b'"' || b1 == b'\\' ||
                b2 == b'"' || b2 == b'\\' || b3 == b'"' || b3 == b'\\') {
                break
            }
            end += 4
        }
        while (end < limit) {
            let b = buffer[end]
            if (b == b'"') {
                break
            }
            if (b == b'\\') {
                return None
            }
            end++
        }
        if (end >= limit || end + 1 >= limit || buffer[end + 1] != b':') {
            return None
        }
        let result = unsafe { String.fromUtf8Unchecked(buffer[index + 1..end]) }
        let consumed = end - index + 2
        index += consumed
        availLen -= consumed
        peeked = PEEK_STATE_VALUE
        return Some(result)
    }

    /**
     * Batch-read an object whose ordinary members are ``String:Int64``.
     *
     * The native scanner consumes only simple unescaped keys and decimal
     * Int64 values.  Any other legal JSON spelling resumes through the
     * established name/value reader, so this method remains semantically
     * equivalent to a normal object loop after it has accepted a prefix.
     */
    @OverflowWrapping
    public func tryReadStringInt64Map(capacityHint: Int64): Option<HashMap<String, Int64>> {
        if (peeked != PEEK_STATE_OBJECT_BEGIN && peek() != Some(BeginObject)) {
            return None
        }
        beforeRead()
        index++
        availLen--
        stacks.put(JsonStateStack.JSON_OBJECT)
        peeked = PEEK_STATE_NONE

        let capacity = if (capacityHint > 0) { capacityHint } else { 0 }
        let values = HashMap<String, Int64>(capacity)
        let keyStarts = Array<Int64>(JSON_PARSE_MAP_CHUNK_ELEMS, repeat: 0)
        let keyLens = Array<Int64>(JSON_PARSE_MAP_CHUNK_ELEMS, repeat: 0)
        let intValues = Array<Int64>(JSON_PARSE_MAP_CHUNK_ELEMS, repeat: 0)
        var complete = false
        while (!complete) {
            if (availLen <= 0) {
                fillInBuf()
                if (availLen <= 0) { break }
            }
            var packed = Int64(0)
            unsafe {
                let inHandle = acquireArrayRawData<Byte>(buffer)
                let startHandle = acquireArrayRawData<Int64>(keyStarts)
                let lenHandle = acquireArrayRawData<Int64>(keyLens)
                let valueHandle = acquireArrayRawData<Int64>(intValues)
                try {
                    packed = CJ_JSON_ParseStringInt64Members(inHandle.pointer + index, availLen,
                        startHandle.pointer, lenHandle.pointer, valueHandle.pointer, intValues.size)
                } finally {
                    releaseArrayRawData(valueHandle)
                    releaseArrayRawData(lenHandle)
                    releaseArrayRawData(startHandle)
                    releaseArrayRawData(inHandle)
                }
            }
            let reason = packed & 0x3
            let consumed = (packed >> 2) & 0xFFFFFFFF
            let count = packed >> 34
            let start = index
            var i = Int64(0)
            while (i < count) {
                let name = unsafe {
                    String.fromUtf8Unchecked(buffer[start + keyStarts[i]..start + keyStarts[i] + keyLens[i]])
                }
                values.add(name, intValues[i])
                i++
            }
            index += consumed
            availLen -= consumed
            if (reason == 0) {
                complete = true
                break
            }
            if (reason == 2) {
                if (refillCompact() <= 0) { break }
                continue
            }
            if (reason == 3) { continue }
            break
        }
        if (!complete) {
            while (let Some(token) <- peek()) {
                match (token) {
                    case EndObject =>
                        endObject()
                        return Some(values)
                    case _ =>
                        let key = match (tryReadNameString()) {
                            case Some(name) => name
                            case None => readName()
                        }
                        values.add(key, readInt64Value())
                }
            }
            return Some(values)
        }
        endObject()
        return Some(values)
    }

    /*
     * Fast path: batch-decode a JSON array of Int64 values.
     *
     * Returns None when the next token is not BeginArray, leaving all state
     * untouched so the caller can fall back to the generic element-wise
     * reader (which raises the proper error for non-array tokens).  Once the
     * '[' is consumed the method always returns Some: plain decimal elements
     * are parsed natively in chunks, and anything the native parser does not
     * accept (floats, strings, 0x-style prefixes, Int64 overflow, trailing
     * commas, end-of-stream truncation, ...) is finished element-wise with
     * readValue<Int64>, reproducing the original behavior byte for byte.
     */
    @OverflowWrapping
    public func tryReadInt64Array(): Option<Array<Int64>> {
        if (peeked != PEEK_STATE_ARRAY_BEGIN && peek() != Some(BeginArray)) {
            return None
        }
        // peeked == PEEK_STATE_ARRAY_BEGIN and index points at '['; consume
        // it exactly like startArray() (beforeRead included).
        beforeRead()
        index++
        availLen--
        stacks.put(JsonStateStack.JSON_ARRAY)
        peeked = PEEK_STATE_NONE

        // Avoid allocating two 256-element containers for short nested
        // arrays. The native parser reports CHUNK_FULL before consuming the
        // next item, so switching buffers preserves reader state exactly.
        var elems = ArrayList<Int64>(JSON_PARSE_INT64_INITIAL_CHUNK_ELEMS)
        var chunk = Array<Int64>(JSON_PARSE_INT64_INITIAL_CHUNK_ELEMS, repeat: 0)
        var complete = false
        while (!complete) {
            if (availLen <= 0) {
                fillInBuf()
                if (availLen <= 0) {
                    break // stream exhausted mid-array: element-wise tail
                }
            }
            var packed = Int64(0)
            unsafe {
                let inHandle = acquireArrayRawData<Byte>(buffer)
                let outHandle = acquireArrayRawData<Int64>(chunk)
                try {
                    packed = CJ_JSON_ParseInt64Array(inHandle.pointer + index, availLen,
                        outHandle.pointer, chunk.size)
                } finally {
                    releaseArrayRawData(outHandle)
                    releaseArrayRawData(inHandle)
                }
            }
            let reason = packed & 0x3
            let consumed = (packed >> 2) & 0xFFFFFFFF
            let count = packed >> 34
            var i = Int64(0)
            while (i < count) {
                elems.add(chunk[i])
                i++
            }
            index += consumed
            availLen -= consumed
            // Keep the peeked state consistent with the element-wise reader:
            // after a consumed ',' the next token must be a value, and a ']'
            // there is a trailing comma the element-wise reader rejects.
            if (reason != 0 && consumed > 0 && buffer[index - 1] == b',') {
                peeked = PEEK_STATE_VALUE
            }
            if (reason == 0) { // DONE: ']' consumed
                complete = true
                break
            }
            if (reason == 2) { // TRUNCATED: refill and retry
                if (refillCompact() <= 0) {
                    break // no more input: element-wise tail (EOF semantics)
                }
                continue
            }
            if (reason == 3) { // CHUNK_FULL: promote only once, then retry
                if (chunk.size < JSON_PARSE_INT64_CHUNK_ELEMS) {
                    let promotedElems = ArrayList<Int64>(JSON_PARSE_INT64_CHUNK_ELEMS)
                    for (value in elems) {
                        promotedElems.add(value)
                    }
                    elems = promotedElems
                    chunk = Array<Int64>(JSON_PARSE_INT64_CHUNK_ELEMS, repeat: 0)
                }
                continue
            }
            break // COMPLEX: element-wise tail preserves exact semantics
        }
        if (!complete) {
            // Element-wise tail: the same loop the generic readArray helper
            // generates, including its lenient end-of-stream behavior.
            while (let Some(token) <- peek()) {
                match (token) {
                    case EndArray =>
                        endArray()
                        return Some(elems.toArray())
                    case _ =>
                        elems.add(readValue<Int64>())
                }
            }
            return Some(elems.toArray())
        }
        stacks.pop()
        peeked = PEEK_STATE_NONE
        afterRead()
        return Some(elems.toArray())
    }

    /**
     * Fast path for arrays of non-negative decimal UInt64 values.  Every
     * token the native scanner cannot prove equivalent is completed by the
     * existing readValue<UInt64> path, including its error behavior.
     */
    @OverflowWrapping
    public func tryReadUInt64Array(): Option<Array<UInt64>> {
        if (peeked != PEEK_STATE_ARRAY_BEGIN && peek() != Some(BeginArray)) {
            return None
        }
        beforeRead()
        index++
        availLen--
        stacks.put(JsonStateStack.JSON_ARRAY)
        peeked = PEEK_STATE_NONE

        let elems = ArrayList<UInt64>(JSON_PARSE_INT64_CHUNK_ELEMS)
        let chunk = Array<UInt64>(JSON_PARSE_INT64_CHUNK_ELEMS, repeat: 0u64)
        var complete = false
        while (!complete) {
            if (availLen <= 0) {
                fillInBuf()
                if (availLen <= 0) { break }
            }
            var packed = Int64(0)
            unsafe {
                let inHandle = acquireArrayRawData<Byte>(buffer)
                let outHandle = acquireArrayRawData<UInt64>(chunk)
                try {
                    packed = CJ_JSON_ParseUInt64Array(inHandle.pointer + index, availLen,
                        outHandle.pointer, chunk.size)
                } finally {
                    releaseArrayRawData(outHandle)
                    releaseArrayRawData(inHandle)
                }
            }
            let reason = packed & 0x3
            let consumed = (packed >> 2) & 0xFFFFFFFF
            let count = packed >> 34
            var i = Int64(0)
            while (i < count) {
                elems.add(chunk[i])
                i++
            }
            index += consumed
            availLen -= consumed
            if (reason != 0 && consumed > 0 && buffer[index - 1] == b',') {
                peeked = PEEK_STATE_VALUE
            }
            if (reason == 0) {
                complete = true
                break
            }
            if (reason == 2) {
                if (refillCompact() <= 0) { break }
                continue
            }
            if (reason == 3) { continue }
            break
        }
        if (!complete) {
            while (let Some(token) <- peek()) {
                match (token) {
                    case EndArray =>
                        endArray()
                        return Some(elems.toArray())
                    case _ => elems.add(readValue<UInt64>())
                }
            }
            return Some(elems.toArray())
        }
        stacks.pop()
        peeked = PEEK_STATE_NONE
        afterRead()
        return Some(elems.toArray())
    }

    /*
     * Compact the remaining buffer bytes to offset 0 and read more input into
     * the free tail.  Returns the number of new bytes read (<= 0 at end of
     * stream).  Unlike fillInBuf(min) this never throws, so the batch parser
     * can degrade to the element-wise tail at end of stream.
     */
    private func refillCompact(): Int64 {
        if (availLen >= buffer.size) {
            // Buffer already full without a terminator: a single element
            // longer than the buffer; degrade to the element-wise reader.
            return 0
        }
        for (i in 0..availLen) {
            buffer[i] = buffer[index + i]
        }
        index = 0
        let readLen = inputStream.read(buffer[availLen..])
        if (readLen > 0) {
            availLen += readLen
            return readLen
        }
        return 0
    }

    /**
     * Return the next token without consuming it.
     * if returns None, means the end of the stream.
     */
    public func peek(): Option<JsonToken> {
        // fast return first
        if (peeked != PEEK_STATE_NONE && peeked != PEEK_STATE_NAME && peeked != PEEK_STATE_VALUE) {
            return PEEKSTATE2TOKEN[peeked]
        }

        let nextByte: Byte = if (let Some(v) <- tryNextNonJsonWhitespace()) {
            v
        } else {
            return None
        }
        match (stacks.top) {
            case 1 where peeked == PEEK_STATE_NAME || peeked == PEEK_STATE_NONE => // json object
                if (nextByte == b'"') {
                    peeked = PEEK_STATE_NAME
                    return JsonToken.Name
                } else if (nextByte == b'}') {
                    peeked = PEEK_STATE_OBJECT_END
                    return JsonToken.EndObject
                }
                throw IllegalStateException("Expect a string as Json Name, but peeked '${Rune(nextByte)}'.")

            case 2 where peeked != PEEK_STATE_VALUE && nextByte == b']' => // json array
                peeked = PEEK_STATE_ARRAY_END
                return JsonToken.EndArray
            case _ => () // top level value
        }

        match (nextByte) {
            case b'n' =>
                peeked = PEEK_STATE_NULL
                return JsonToken.JsonNull
            case b't' =>
                peeked = PEEK_STATE_TRUE
                return JsonToken.JsonBool
            case b'f' =>
                peeked = PEEK_STATE_FALSE
                return JsonToken.JsonBool
            case b'0' | b'1' | b'2' | b'3' | b'4' | b'5' | b'6' | b'7' | b'8' | b'9' | b'-' =>
                peeked = PEEK_STATE_NUMBER
                return JsonToken.JsonNumber
            case b'\"' =>
                peeked = PEEK_STATE_STRING
                return JsonToken.JsonString
            case b'{' =>
                peeked = PEEK_STATE_OBJECT_BEGIN
                return JsonToken.BeginObject
            case b'[' =>
                peeked = PEEK_STATE_ARRAY_BEGIN
                return JsonToken.BeginArray
            case _ => throw IllegalStateException("Character not expected: '${Rune(nextByte)}'.")
        }
    }

    @OverflowWrapping
    public func startArray(): Unit {
        beforeRead()
        match (peeked) {
            case 5 => () // PEEK_STATE_ARRAY_BEGIN
            case 11 | 10 => // PEEK_STATE_NONE or PEEK_STATE_VALUE
                if (nextNonJsonWhitespace() != b'[') {
                    throw IllegalStateException("The next Token is not BeginArray.")
                }
            case 4 => // PEEK_STATE_NAME
                throw IllegalStateException("In an object, the name must be handled before the value.")
            case _ => // others
                throw IllegalStateException("The next Token is not BeginArray.")
        }

        availLen--
        index++
        stacks.put(JsonStateStack.JSON_ARRAY)
        peeked = PEEK_STATE_NONE
    }

    @OverflowWrapping
    public func endArray(): Unit {
        match {
            case peeked == PEEK_STATE_ARRAY_END => ()
            case peeked == PEEK_STATE_NONE => if (stacks.top != JsonStateStack.JSON_ARRAY) {
                throw IllegalStateException("Failed to end array.")
            }
            case _ => throw IllegalStateException("The next Token is not EndArray.")
        }
        availLen--
        index++
        stacks.pop()
        peeked = PEEK_STATE_NONE
        afterRead()
        return
    }

    @OverflowWrapping
    public func startObject(): Unit {
        beforeRead()
        match (peeked) {
            case 7 => () // PEEK_STATE_OBJECT_BEGIN
            case 11 | 10 => // PEEK_STATE_NONE or PEEK_STATE_VALUE
                if (nextNonJsonWhitespace() != b'{') {
                    throw IllegalStateException("The next Token is not BeginObject.")
                }
            case _ => throw IllegalStateException("The next Token is not BeginObject.")
        }
        availLen--
        index++
        stacks.put(JsonStateStack.JSON_OBJECT)
        peeked = PEEK_STATE_NONE
    }

    @OverflowWrapping
    public func endObject(): Unit {
        match (peeked) {
            case 8 => () // PEEK_STATE_OBJECT_END
            case 11 => // PEEK_STATE_NONE
                if (stacks.top == JsonStateStack.JSON_OBJECT) {
                    if (nextNonJsonWhitespace() != b'}') {
                        throw IllegalStateException("The next Token is not EndObject.")
                    }
                } else {
                    throw IllegalStateException("Failed to end object.")
                }
            case _ => // others
                throw IllegalStateException("The next Token is not EndObject.")
        }

        availLen--
        index++
        stacks.pop()
        afterRead()
    }

    @OverflowWrapping
    public func readName(): String {
        match (peeked) {
            case 10 => // PEEK_STATE_VALUE
                throw IllegalStateException("Expect readValue after readName.")
            case 11 => // PEEK_STATE_NONE
                if (stacks.top != JsonStateStack.JSON_OBJECT) {
                    throw IllegalStateException("Failed to read name.")
                }
            case 9 => () // PEEK_STATE_NAME
            case _ => // others
                throw IllegalStateException("Failed to read name.")
        }
        let result = readString()
        if (nextNonJsonWhitespace() != b':') {
            throw IllegalStateException("Missing ':' after name.")
        }
        peeked = PEEK_STATE_VALUE
        index++
        availLen--
        return result
    }

    public func skip(): Unit {
        if (let Some(token) <- peek()) {
            match (token) {
                case JsonNull | JsonBool | JsonNumber => skipValue()
                case JsonString => skipString()
                case BeginArray => skipArray()
                case BeginObject => skipObject()
                case EndArray | EndObject => return
                case Name =>
                    skipName()
                    if (let Some(token) <- peek()) {
                        match (token) {
                            case JsonNull | JsonBool | JsonNumber => skipValue()
                            case JsonString => skipString()
                            case BeginArray => skipArray()
                            case BeginObject => skipObject()
                            case _ => throw IllegalStateException("The name must be followed by JSON value.")
                        }
                    } else {
                        throw IllegalStateException("The JSON stream ends at an incorrect location.")
                    }
            }
        }
        afterRead()
    }

    // check the stack state of Json text
    func beforeRead(): Unit {
        if (peeked == PEEK_STATE_NONE && stacks.top == JsonStateStack.JSON_OBJECT || peeked == PEEK_STATE_NAME) {
            throw IllegalStateException("In an object, the name must be handled before the value.")
        }
    }

    /**
     * skip the comma after each value
     */
    func afterRead(): Unit {
        // if next character is a comma, it means it's not a end of object/array
        let nextByte = tryNextNonJsonWhitespace()
        if (nextByte == b',') {
            index++
            availLen--
            match (stacks.top) {
                case 1 => return peeked = PEEK_STATE_NAME /* JsonStateStack.JSON_OBJECT */
                case 2 => return peeked = PEEK_STATE_VALUE /* JsonStateStack.JSON_ARRAY */
                case _ => ()
            }
        } else if (nextByte == b']' && stacks.top == JsonStateStack.JSON_ARRAY) {
            peeked = PEEK_STATE_ARRAY_END
            return
        } else if (nextByte == b'}' && stacks.top == JsonStateStack.JSON_OBJECT) {
            peeked = PEEK_STATE_OBJECT_END
            return
        }
        peeked = PEEK_STATE_NONE
    }

    func fillInBuf() {
        if (availLen > 0) {
            return
        }
        let readLen = inputStream.read(buffer)
        if (readLen > 0) {
            index = 0
            availLen = readLen
        }
    }

    @OverflowWrapping
    private func fillInBuf(min: Int64) {
        if (availLen >= min) {
            return
        }
        for (i in 0..availLen) {
            buffer[i] = buffer[index + i]
        }
        index = 0
        availLen += inputStream.read(buffer[index + availLen..])
        if (availLen < min) {
            throw IllegalStateException("The JSON stream ends at an incorrect location.")
        }
    }

    func peekNext(): ?Byte {
        fillInBuf()
        return if (availLen > 0) {
            buffer[index]
        } else {
            None
        }
    }

    @OverflowWrapping
    private func readNext(): Byte {
        if (availLen <= 0) {
            fillInBuf()
            if (availLen <= 0) {
                throw IllegalStateException("The JSON stream ends at an incorrect location.")
            }
        }
        let res = buffer[index]
        availLen--
        index++
        return res
    }

    // ensure the buffer is not empty
    private func checkBuffer() {
        if (availLen <= 0) {
            fillInBuf()
            if (availLen <= 0) {
                throw IllegalStateException("The JSON stream ends at an incorrect location.")
            }
        }
    }

    func readNextHexNum(): Byte {
        let byte = readNext()
        if (!byte.isAsciiHex()) {
            throw IllegalStateException("Illegal escape character.")
        }
        return byte
    }

    @OverflowWrapping
    private func byteToUint(byte: Byte): UInt32 {
        if (byte.isAsciiNumber()) {
            return UInt32(byte - b'0')
        }
        if (byte.isAsciiLowerCase()) {
            return UInt32(byte - b'a' + 10)
        }
        if (byte.isAsciiUpperCase()) {
            return UInt32(byte - b'A' + 10)
        }
        throw IllegalStateException("Illegal escape character.")
    }

    @OverflowWrapping
    private func handleEscape() {
        match (readNext()) {
            case b'\"' => stringBuffer.append(b'\"')
            case b'\\' => stringBuffer.append(b'\\')
            case b'/' => stringBuffer.append(b'/')
            case b'b' => stringBuffer.append(b'\b')
            case b'f' => stringBuffer.append(b'\f')
            case b'n' => stringBuffer.append(b'\n')
            case b'r' => stringBuffer.append(b'\r')
            case b't' => stringBuffer.append(b'\t')
            case b'u' =>
                let byte1 = readNextHexNum()
                let byte2 = readNextHexNum()
                let byte3 = readNextHexNum()
                let byte4 = readNextHexNum()
                try {
                    let ch = Rune((byteToUint(byte1) << 12) + (byteToUint(byte2) << 8) + (byteToUint(byte3) << 4) +
                    byteToUint(byte4))
                    charToByteArr(UInt32(ch))
                } catch (_: Exception) {
                    if (readNext() != b'\\') {
                        throw IllegalStateException("Illegal escape character.")
                    }
                    if (readNext() != b'u') {
                        throw IllegalStateException("Illegal escape character.")
                    }
                    let byte5 = readNextHexNum()
                    let byte6 = readNextHexNum()
                    let byte7 = readNextHexNum()
                    let byte8 = readNextHexNum()
                    let rawNum1 = (byteToUint(byte1) << 12) + (byteToUint(byte2) << 8) + (byteToUint(byte3) << 4) +
                        byteToUint(byte4)
                    let rawNum2 = (byteToUint(byte5) << 12) + (byteToUint(byte6) << 8) + (byteToUint(byte7) << 4) +
                        byteToUint(byte8)
                    if (!isHighSurrogate(rawNum1) || !isLowSurrogate(rawNum2)) {
                        throw IllegalStateException("Illegal escape character.")
                    }
                    let num1 = rawNum1 & 0b0000001111111111
                    let num2 = rawNum2 & 0b0000001111111111
                    let ch = Rune(((num1 << 10) | num2) + 0x10000)
                    charToByteArr(UInt32(ch))
                }
            case _ => throw IllegalStateException("Illegal escape character.")
        }
        0
    }

    @OverflowWrapping
    private func charToByteArr(ch: UInt32) {
        if (ch <= UTF8_1_MAX) {
            stringBuffer.append(UInt8(ch))
            return 0
        } else if (ch <= UTF8_2_MAX) {
            stringBuffer.append(UInt8(((ch >> SHIFT_6) & LOW_5_MASK) | HIGH_2_MASK))
            stringBuffer.append(UInt8(((ch) & LOW_6_MASK) | HIGH_1_MASK))
            return 0
        } else if (ch <= UTF8_3_MAX) {
            stringBuffer.append(UInt8(((ch >> SHIFT_12) & LOW_4_MASK) | HIGH_3_MASK))
            stringBuffer.append(UInt8(((ch >> SHIFT_6) & LOW_6_MASK) | HIGH_1_MASK))
            stringBuffer.append(UInt8((ch & LOW_6_MASK) | HIGH_1_MASK))
            return 0
        } else if (ch <= UTF8_4_MAX) {
            stringBuffer.append(UInt8(((ch >> SHIFT_18) & LOW_3_MASK) | HIGH_4_MASK))
            stringBuffer.append(UInt8(((ch >> SHIFT_12) & LOW_6_MASK) | HIGH_1_MASK))
            stringBuffer.append(UInt8(((ch >> SHIFT_6) & LOW_6_MASK) | HIGH_1_MASK))
            stringBuffer.append(UInt8((ch & LOW_6_MASK) | HIGH_1_MASK))
            return 0
        } else {
            throw IllegalStateException("Maximum of 4 bytes allowed for UTF-8.")
        }
    }

    private func isJsonWhiteSpace(b: Byte): Bool {
        return b == b' ' || b == b'\t' || b == b'\n' || b == b'\r'
    }

    /**
     * Return the next non-whitespace character in the stream
     * throws IllegalStateException when the stream ends.
     */
    @OverflowWrapping
    func nextNonJsonWhitespace(): Byte {
        checkBuffer()
        while (isJsonWhiteSpace(buffer[index])) {
            availLen--
            index++
            checkBuffer()
        }
        return buffer[index]
    }

    /**
     * Return the next non-whitespace character in the stream
     * return None when the stream ends.
     */
    @OverflowWrapping
    func tryNextNonJsonWhitespace(): Option<Byte> {
        do {
            if (availLen <= 0) {
                fillInBuf()
                if (availLen <= 0) {
                    return None
                }
            }
            if (!isJsonWhiteSpace(buffer[index])) {
                break
            }
            availLen--
            index++
        } while (true)
        return buffer[index]
    }

    @OverflowWrapping
    func nextNonJsonWhitespace(sb: StringBuffer): Byte {
        checkBuffer()
        while (isJsonWhiteSpace(buffer[index])) {
            sb.append(buffer[index])
            availLen--
            index++
            checkBuffer()
        }
        return buffer[index]
    }

    @OverflowWrapping
    func nextValue(sb: StringBuffer) {
        var whitespaceCount = 0
        while (let Some(nextByte) <- peekNext()) {
            if (nextByte == b',' || nextByte == b']' || nextByte == b'}') {
                break
            }
            if (isJsonWhiteSpace(nextByte)) {
                whitespaceCount++
            } else {
                whitespaceCount = 0
            }
            sb.append(nextByte)
            index++
            availLen--
        }
        // trim right whitespaces
        sb.size -= whitespaceCount
    }

    @OverflowWrapping
    func copyValue(writer: JsonWriter) {
        while (let Some(nextByte) <- peekNext()) {
            if (nextByte == b',' || nextByte == b']' || nextByte == b'}') {
                break
            }
            // JSON scalars cannot contain whitespace. Dropping it here also
            // preserves readValueBytes' behavior of trimming trailing spaces.
            if (isJsonWhiteSpace(nextByte)) {
                index++
                availLen--
                continue
            }
            let spanStart = index
            while (availLen > 0) {
                let byte = buffer[index]
                if (byte == b',' || byte == b']' || byte == b'}' || isJsonWhiteSpace(byte)) {
                    break
                }
                index++
                availLen--
            }
            let spanLength = index - spanStart
            if (spanLength > 0) {
                writer.appendRawBytes(buffer, spanStart, spanLength)
            }
        }
    }

    @OverflowWrapping
    func nextString(sb: StringBuffer) {
        var count = 0
        var nextByte: Byte
        while (count < 2) {
            nextByte = readNext()
            sb.append(nextByte)
            if (nextByte == b'"') {
                count++
                continue
            }
            if (nextByte == b'\\') {
                sb.append(readNext())
            }
        }
    }

    @OverflowWrapping
    func copyString(writer: JsonWriter) {
        var count = 0
        while (count < 2) {
            checkBuffer()
            let spanStart = index
            while (availLen > 0 && buffer[index] != b'"' && buffer[index] != b'\\') {
                index++
                availLen--
            }
            let spanLength = index - spanStart
            if (spanLength > 0) {
                writer.appendRawBytes(buffer, spanStart, spanLength)
            }
            if (availLen <= 0) {
                continue
            }
            let nextByte = readNext()
            writer.writeRawByte(nextByte)
            if (nextByte == b'"') {
                count++
                continue
            }
            if (nextByte == b'\\') {
                writer.writeRawByte(readNext())
            }
        }
    }

    @OverflowWrapping
    func nextName(sb: StringBuffer) {
        if (peeked != PEEK_STATE_NAME) {
            if (peeked != PEEK_STATE_NONE || stacks.top != JsonStateStack.JSON_OBJECT) {
                throw IllegalStateException("Failed to read name.")
            }
        }

        nextString(sb) // JSON name is a string
        if (nextNonJsonWhitespace(sb) != b':') {
            throw IllegalStateException("Missing ':' after name.")
        }
        sb.append(b':')
        index++
        availLen--
        peeked = PEEK_STATE_VALUE
    }

    func nextArray(sb: StringBuffer) {
        nextSymmetrySegment(sb, start: b'[', end: b']')
    }

    func nextObject(sb: StringBuffer) {
        nextSymmetrySegment(sb, start: b'{', end: b'}')
    }

    func copyArray(writer: JsonWriter) {
        copySymmetrySegment(writer, start: b'[', end: b']')
    }

    func copyObject(writer: JsonWriter) {
        copySymmetrySegment(writer, start: b'{', end: b'}')
    }

    func nextSymmetrySegment(sb: StringBuffer, start!: Byte, end!: Byte) {
        let depth = stacks.depth
        var endTag = end
        var inString = false // the flag indicating the start or end of an escape string
        while (true) {
            let nextByte = readNext()
            sb.append(nextByte)
            match (nextByte) {
                case b'\\' =>
                    if (inString) {
                        sb.append(readNext())
                        continue
                    }
                    throw IllegalStateException("Characters not expected: '\\'.")
                case b'\"' => inString = !inString
                case b'{' | b'[' =>
                    if (!inString) {
                        stacks.put(tagStackState(nextByte))
                    }
                case b'}' | b']' =>
                    if (inString) {
                        continue
                    }
                    if (stacks.top == tagStackState(nextByte)) {
                        stacks.pop()
                        if (stacks.depth == depth) {
                            endTag = nextByte
                            break
                        }
                        continue
                    }
                    throw IllegalStateException("Failed to read symmetry end of '${Rune(start)}'.")
                case _ => ()
            }
        }

        // Non-symmetry end of segment, throw error
        if (endTag != end) {
            throw IllegalStateException("Failed to read symmetry end of '${Rune(start)}'.")
        }
    }

    func copySymmetrySegment(writer: JsonWriter, start!: Byte, end!: Byte) {
        let depth = stacks.depth
        var endTag = end
        var inString = false
        while (true) {
            // Bytes other than JSON structure markers do not affect nesting or
            // string state. Copy such a contiguous span with one bulk copy.
            checkBuffer()
            let spanStart = index
            while (availLen > 0) {
                let nextByte = buffer[index]
                if (nextByte == b'\\' || nextByte == b'"' || nextByte == b'{' || nextByte == b'[' ||
                    nextByte == b'}' || nextByte == b']') {
                    break
                }
                index++
                availLen--
            }
            let spanLength = index - spanStart
            if (spanLength > 0) {
                writer.appendRawBytes(buffer, spanStart, spanLength)
            }
            if (availLen <= 0) {
                continue
            }
            let nextByte = readNext()
            writer.writeRawByte(nextByte)
            match (nextByte) {
                case b'\\' =>
                    if (inString) {
                        writer.writeRawByte(readNext())
                        continue
                    }
                    throw IllegalStateException("Characters not expected: '\\'.")
                case b'"' => inString = !inString
                case b'{' | b'[' =>
                    if (!inString) {
                        stacks.put(tagStackState(nextByte))
                    }
                case b'}' | b']' =>
                    if (inString) {
                        continue
                    }
                    if (stacks.top == tagStackState(nextByte)) {
                        stacks.pop()
                        if (stacks.depth == depth) {
                            endTag = nextByte
                            break
                        }
                        continue
                    }
                    throw IllegalStateException("Failed to read symmetry end of '${Rune(start)}'.")
                case _ => ()
            }
        }

        if (endTag != end) {
            throw IllegalStateException("Failed to read symmetry end of '${Rune(start)}'.")
        }
    }

    func tagStackState(stackTag: Byte) {
        if (stackTag == b'{' || stackTag == b'}') {
            return JsonStateStack.JSON_OBJECT
        } else if (stackTag == b'[' || stackTag == b']') {
            return JsonStateStack.JSON_ARRAY
        } else {
            return JsonStateStack.JSON_UNDEFINE
        }
    }

    @OverflowWrapping
    func skipValue() {
        while (true) {
            if (let Some(nextByte) <- peekNext()) {
                if (nextByte == b',' || nextByte == b']' || nextByte == b'}') {
                    break
                }
                index++
                availLen--
            } else {
                break
            }
        }
    }

    @OverflowWrapping
    func skipString() {
        var count = 0
        var nextByte: Byte
        while (count < 2) {
            nextByte = readNext()
            if (nextByte == b'"') {
                count++
                continue
            }
            if (nextByte == b'\\') {
                readNext()
            }
        }
    }

    @OverflowWrapping
    public func skipName() {
        if (peeked != PEEK_STATE_NAME) {
            if (peeked != PEEK_STATE_NONE || stacks.top != JsonStateStack.JSON_OBJECT) {
                throw IllegalStateException("Failed to read name.")
            }
        }

        skipString() // JSON name is a string
        if (nextNonJsonWhitespace() != b':') {
            throw IllegalStateException("Missing ':' after name.")
        }
        index++
        availLen--
        peeked = PEEK_STATE_VALUE
    }

    /**
     * Discard the unread JSON bytes without parsing their structure.
     *
     * This is intended for protocols that have already validated an early
     * response marker but still need to consume the HTTP body before reusing
     * the connection. Bytes already prefetched in this reader are dropped;
     * the reader buffer is then reused to drain the wrapped input stream.
     */
    public func discardRemaining(): Unit {
        availLen = 0
        index = 0
        while (inputStream.read(buffer) > 0) {}
        peeked = PEEK_STATE_NONE
    }

    func skipArray() {
        skipSymmetrySegment(start: b'[', end: b']')
    }

    func skipObject() {
        skipSymmetrySegment(start: b'{', end: b'}')
    }

    func skipSymmetrySegment(start!: Byte, end!: Byte) {
        let depth = stacks.depth
        startArray()
        skipSymmetrySegment(end: b']', depth: depth)
    }

    func skipObject() {
        let depth = stacks.depth
        startObject()
        skipSymmetrySegment(end: b'}', depth: depth)
    }

    func skipSymmetrySegment(end!: Byte, depth!: Int64) {
        var inString = false
        while (true) {
            // Ordinary bytes cannot change the JSON nesting state. Move over
            // them as a span and only inspect quotes, escapes and brackets.
            checkBuffer()
            while (availLen > 0) {
                let nextByte = buffer[index]
                if (nextByte == b'\\' || nextByte == b'\"' || nextByte == b'{' || nextByte == b'[' ||
                    nextByte == b'}' || nextByte == b']') {
                    break
                }
                index++
                availLen--
            }
            if (availLen <= 0) {
                continue
            }
            let nextByte = readNext()
            match (nextByte) {
                case b'\\' =>
                    if (inString) {
                        readNext()
                        continue
                    }
                    throw IllegalStateException("Characters not expected: '\\'.")
                case b'\"' => inString = !inString
                case b'{' =>
                    if (!inString) {
                        stacks.put(JsonStateStack.JSON_OBJECT)
                    }
                case b'[' =>
                    if (!inString) {
                        stacks.put(JsonStateStack.JSON_ARRAY)
                    }
                case b'}' =>
                    if (inString) {
                        continue
                    }
                    if (stacks.top == JsonStateStack.JSON_OBJECT) {
                        stacks.pop()
                        if (stacks.depth == depth) {
                            if (nextByte == end) {
                                return
                            }
                            throw IllegalStateException("Failed to skip.")
                        }
                        continue
                    }
                    throw IllegalStateException("Failed to skip.")
                case b']' =>
                    if (inString) {
                        continue
                    }
                    if (stacks.top == JsonStateStack.JSON_ARRAY) {
                        stacks.pop()
                        if (stacks.depth == depth) {
                            if (nextByte == end) {
                                return
                            }
                            throw IllegalStateException("Failed to skip.")
                        }
                        continue
                    }
                    throw IllegalStateException("Failed to skip.")
                case _ => ()
            }
        }
    }

    @OverflowWrapping
    func readString(): String {
        let nextByte = nextNonJsonWhitespace()
        if (nextByte != b'\"') {
            throw IllegalStateException("The next Token is not JSON String.")
        }
        index++
        availLen--
        return readStringQuoted()
    }

    @OverflowWrapping
    func readStringQuoted(): String {
        var breakIndex = 0
        while (true) {
            checkBuffer()
            breakIndex = index
            unsafe {
                let handle = acquireArrayRawData<Byte>(buffer)
                try {
                    breakIndex = CJ_ReadString(handle.pointer, index, index + availLen)
                } finally {
                    releaseArrayRawData(handle)
                }
            }
            if (breakIndex == index + availLen) { // read till the end of buffer, fill buffer and continue
                stringBuffer.appendAll(buffer[index..breakIndex])
                availLen = 0
            // and continue
            } else if (breakIndex < 0) { // utf 8 check err
                throw IllegalStateException("Invalid utf8 byte sequence.")
            } else if (buffer[breakIndex] == b'\\') { // read till some character need escape
                stringBuffer.appendAll(buffer[index..breakIndex])
                availLen = availLen - (breakIndex - index) - 1
                index = breakIndex + 1
                handleEscape()
            // and continue
            } else if (buffer[breakIndex] == b'\"') { // end of read string, break
                break
            } else { // unexpected end of an utf-8 sequence
                stringBuffer.appendAll(buffer[index..breakIndex])
                availLen = availLen - (breakIndex - index)
                index = breakIndex
                let utf8Size = utf8SizeUnchecked(buffer[breakIndex])
                if (utf8Size == 1 || utf8Size > 4) {
                    throw IllegalStateException("Invalid utf8 byte sequence.")
                }
                fillInBuf(utf8Size) // if end, throw exception, continue
                // and continue
            }
        }

        if (stringBuffer.size > 0) { // if buffered, append data left and return all
            stringBuffer.appendAll(buffer[index..breakIndex])
            availLen = availLen - (breakIndex - index) - 1
            index = breakIndex + 1
            let result = unsafe { String.fromUtf8Unchecked(stringBuffer.data[0..stringBuffer.size]) }
            stringBuffer.clear()
            return result
        } else { // return data directly
            let result = unsafe { String.fromUtf8Unchecked(buffer[index..breakIndex]) }
            availLen = availLen - (breakIndex - index) - 1
            index = breakIndex + 1
            return result
        }
    }

    @OverflowWrapping
    func readInt(): (Int64, Bool) {
        var nextByte = if (peeked == PEEK_STATE_NONE || peeked == PEEK_STATE_VALUE) {
            fillInBuf()
            if (availLen <= 0) {
                throw IllegalStateException("The JSON stream ends at an incorrect location.")
            }
            nextNonJsonWhitespace()
        } else if (peeked == PEEK_STATE_NUMBER) {
            buffer[index]
        } else {
            throw IllegalStateException("Failed to read json number.")
        }

        var isNegative = false
        if (nextByte == b'-') {
            isNegative = true
            index++
            availLen--
        }
        peeked = PEEK_STATE_NUMBER
        var (result, overflow) = readUInt()
        if (overflow) {
            return (0, true)
        }
        if (isNegative) {
            if (result > MAXABSVAL_I64) {
                return (0, true)
            }
            return (Int64(-result), false)
        }
        if (result > MAXVAL_I64) {
            return (0, true)
        }
        return (Int64(result), false)
    }

    @OverflowWrapping
    func readUInt(): (UInt64, Bool) {
        var nextByte = if (peeked == PEEK_STATE_NONE || peeked == PEEK_STATE_VALUE) {
            fillInBuf()
            if (availLen <= 0) {
                throw IllegalStateException("The JSON stream ends at an incorrect location.")
            }
            nextNonJsonWhitespace()
        } else if (peeked == PEEK_STATE_NUMBER) {
            buffer[index]
        } else {
            throw IllegalStateException("Failed to read json number.")
        }

        if (nextByte == b'-') {
            return (0, true)
        }
        if (nextByte < b'0' || nextByte > b'9') {
            throw IllegalStateException("The next Token is not UInt64.")
        }

        if (nextByte != b'0') {
            return readUIntDecimal()
        }

        index++
        availLen--
        if (let Some(prefix) <- peekNext()) {
            match (prefix) {
                case b'b' | b'B' =>
                    index++
                    availLen--
                    return readUIntRadix(2, BINARY_OVERFLOW_LIMIT_UI64)
                case b'o' | b'O' =>
                    index++
                    availLen--
                    return readUIntRadix(8, OCTAL_OVERFLOW_LIMIT_UI64)
                case b'x' | b'X' =>
                    index++
                    availLen--
                    return readUIntRadix(16, HEXADECIMAL_OVERFLOW_LIMIT_UI64)
                case b'd' | b'D' =>
                    index++
                    availLen--
                    return readUIntDecimal()
                case _ => ()
            }
        }
        return readUIntDecimal(result: 0)
    }

    @OverflowWrapping
    private func readUIntDecimal(result!: UInt64 = 0): (UInt64, Bool) {
        var res = result
        while (true) {
            if (availLen <= 0) {
                fillInBuf()
                if (availLen <= 0) {
                    break
                }
            }
            let nextByte = buffer[index]
            if (!isDecimalDigit(nextByte)) {
                break
            }
            let digit = UInt64(nextByte - b'0')
            if (res > DECIMAL_OVERFLOW_LIMIT_UI64) {
                return (0, true)
            }
            res = res * 10
            if (MAXVAL_UI64 - res < digit) {
                return (0, true)
            }
            res += digit
            index++
            availLen--
        }
        return (res, false)
    }

    @OverflowWrapping
    private func readUIntRadix(numSys: UInt64, multmin: UInt64): (UInt64, Bool) {
        var result: UInt64 = 0
        while (true) {
            if (availLen <= 0) {
                fillInBuf()
                if (availLen <= 0) {
                    break
                }
            }
            let nextByte = buffer[index]
            let digit = DIGITS_UI64[Int64(nextByte)]
            if (digit >= numSys) { // digit cannot equal or bigger then number system
                break
            }
            if (result > multmin) {
                return (0, true)
            }
            result = result * numSys
            if (MAXVAL_UI64 - result < digit) {
                return (0, true)
            }
            result += digit
            index++
            availLen--
        }
        return (result, false)
    }

    private func readFloatEx(): Float64 {
        let sign = match (nextNonJsonWhitespace()) {
            case b'-' =>
                index++
                availLen--
                -1.0
            case b'+' =>
                index++
                availLen--
                1.0
            case _ => 1.0
        }

        fillInBuf()
        var result = 0.0
        var pointNum = 0
        var leftMove = 1.0
        while (availLen > 0) {
            if (pointNum > 1) {
                throw IllegalStateException("Invalid number format.")
            }
            let c = buffer[index]
            if (c >= b'0' && c <= b'9') {
                result = result * 10.0 + Float64(c - b'0')
                if (pointNum == 1) {
                    leftMove = leftMove * 10.0
                }
            } else if (c == b'.') {
                pointNum++
            } else {
                break
            }
            index++
            availLen--
            if (availLen <= 0) {
                fillInBuf()
            }
        }
        return sign * result / leftMove
    }

    @OverflowWrapping
    func readFloat(): Float64 {
        if (peeked == PEEK_STATE_NONE || peeked == PEEK_STATE_VALUE) {
            fillInBuf()
            if (availLen <= 0) {
                throw IllegalStateException("The JSON stream ends at an incorrect location.")
            }
            nextNonJsonWhitespace()
        } else if (peeked == PEEK_STATE_NUMBER) {
            buffer[index]
        } else {
            throw IllegalStateException("Failed to read json number.")
        }

        let result = ensureFiniteJsonFloat(readFloatEx())
        if (let Some(c) <- tryNextNonJsonWhitespace()) {
            if (c == b'e' || c == b'E') {
                index++
                availLen--
                let (exponent, overflow) = readInt()
                if (overflow) {
                    throw OverflowException("Overflow while reading JSON number.")
                }
                if (exponent > 308) {
                    throw IllegalStateException("Invalid float detected.")
                }
                if (exponent < -324) {
                    return 0.0
                }
                return ensureFiniteJsonFloat(result * pow(10.0, Float64(exponent)))
            }
        }
        return result
    }

    func readBool(): Bool {
        let nextByte = nextNonJsonWhitespace()
        return if (nextByte == b't') {
            readTrue()
        } else if (nextByte == b'f') {
            readFalse()
        } else {
            throw IllegalStateException("The next Token is not JSON bool.")
        }
    }

    @OverflowWrapping
    func readTrue() {
        fillInBuf(4)
        if (buffer[index + 3] == b'e' && buffer[index + 2] == b'u' && buffer[index + 1] == b'r') {
            index += 4
            availLen -= 4
            return true
        } else {
            throw IllegalStateException("Failed to read JSON bool.")
        }
    }

    @OverflowWrapping
    func readFalse() {
        fillInBuf(5)
        if (buffer[index + 4] == b'e' && buffer[index + 3] == b's' && buffer[index + 2] == b'l' && buffer[index + 1] ==
            b'a') {
            index += 5
            availLen -= 5
            return false
        } else {
            throw IllegalStateException("Failed to read JSON bool.")
        }
    }

    @OverflowWrapping
    func readNull(): Unit {
        fillInBuf(4)
        if (buffer[index + 3] == b'l' && buffer[index + 2] == b'l' && buffer[index + 1] == b'u') {
            index += 4
            availLen -= 4
            return
        } else {
            throw IllegalStateException("Failed to read JSON null.")
        }
    }

    func utf8SizeUnchecked(byte: Byte): Int64 {
        return match {
            case byte < HIGH_1_UInt8 => 1
            case byte < HIGH_3_UInt8 => 2
            case byte < HIGH_4_UInt8 => 3
            case byte < HIGH_5_UInt8 => 4
            case byte < HIGH_6_UInt8 => 5
            case _ => 6
        }
    }
}

class StringBuffer {
    var data = Array<Byte>(1024, repeat: 0)
    var size = 0

    func grow(minCapacity: Int64): Unit {
        if (minCapacity > MAX_JSON_STREAM_STRING_BUFFER_SIZE) {
            throw IllegalStateException("Json string length exceeds ${MAX_JSON_STREAM_STRING_BUFFER_SIZE}.")
        }
        let oldCapacity: Int64 = data.size
        var newCapacity: Int64 = oldCapacity << 1
        if (newCapacity < minCapacity) {
            newCapacity = minCapacity
        }
        let newArr: Array<Byte> = Array<Byte>(newCapacity, repeat: 0)
        data.copyTo(newArr, 0, 0, size)
        data = newArr
    }

    @OverflowWrapping
    func appendAll(elements: Array<Byte>) {
        let cSize: Int64 = elements.size

        if (cSize > MAX_JSON_STREAM_STRING_BUFFER_SIZE - size) {
            throw IllegalStateException("Json string length exceeds ${MAX_JSON_STREAM_STRING_BUFFER_SIZE}.")
        }
        if (size + cSize > data.size) {
            grow(size + cSize)
        }

        elements.copyTo(data, 0, size, cSize)
        size = size + cSize
    }

    @OverflowWrapping
    func append(element: Byte) {
        if (size >= MAX_JSON_STREAM_STRING_BUFFER_SIZE) {
            throw IllegalStateException("Json string length exceeds ${MAX_JSON_STREAM_STRING_BUFFER_SIZE}.")
        }
        if (size == data.size) {
            grow(size + 1)
        }
        data[size] = element
        size++
    }

    func clear() {
        size = 0
    }
}
