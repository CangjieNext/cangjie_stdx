/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.encoding.json.stream

import std.io.InputStream
import std.time.*

@FastNative
foreign func CJ_ReadString(buffer: CPointer<Byte>, left: Int64, right: Int64): Int64

const HIGH_1_UInt8: UInt8 = 0b10000000 // 0x80
const HIGH_3_UInt8: UInt8 = 0b11100000 // 0xe0
const HIGH_4_UInt8: UInt8 = 0b11110000 // 0xf0
const HIGH_5_UInt8: UInt8 = 0b11111000 // 0xf8
const HIGH_6_UInt8: UInt8 = 0b11111100 // 0xfc
const MAX_JSON_STREAM_STRING_BUFFER_SIZE: Int64 = 32 * 1024 * 1024
const INVALID_JSON_STRING_CONTROL_CHARACTER = "Unescaped control character in JSON string."
const JSON_STRING_CONTROL_CHARACTER_INDEX: Int64 = -2

// NaN and Infinity are not valid JSON number literals (RFC 8259). Call sites
// keep their own exception type and message (read side and serialization side
// deliberately differ).
func isJsonFloatInfinite(value: Float64): Bool {
    return value.isNaN() || value.isInf()
}

func isHighSurrogate(num: UInt32): Bool {
    return num >= 0xD800u32 && num <= 0xDBFFu32 // UTF-16 high-surrogate range: D800..DBFF.
}

func isLowSurrogate(num: UInt32): Bool {
    return num >= 0xDC00u32 && num <= 0xDFFFu32 // UTF-16 low-surrogate range: DC00..DFFF.
}

public class JsonReader {
    let inputStream: InputStream // the input stream
    let buffer: Array<Byte> = Array<Byte>(8192, repeat: 0)
    let stacks = JsonStateStack() // a stack of json types(object/array)
    let stringBuffer: StringBuffer = StringBuffer() // a buffer for readed string

    var peeked: Int64 = PEEK_STATE_NONE // peeked state
    var availLen: Int64 = 0 // The amount of valid data in the buffer
    var index: Int64 = 0 // The start position of valid data in the buffer

    var dateTimeFormat: ?DateTimeFormat = None

    public init(inputStream: InputStream) {
        this.inputStream = inputStream
    }

    @Frozen
    public func readValue<T>(): T where T <: JsonDeserializable<T> {
        if (peeked == PEEK_STATE_NONE && stacks.top == JsonStateStack.JSON_OBJECT || peeked == PEEK_STATE_NAME) {
            throw IllegalStateException("Cannot read value in object: name must be handled first.")
        }
        let res = T.fromJson(this)
        // manual inline func afterRead
        let nextByte: Byte = if (let Some(v) <- tryNextNonJsonWhitespace()) {
            v
        } else {
            peeked = PEEK_STATE_NONE
            return res
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
                    case 1 where peeked != PEEK_STATE_NAME => throw IllegalStateException("Missing comma between values in object.")
                    case 2 where peeked != PEEK_STATE_VALUE => throw IllegalStateException("Missing comma between values in array.")
                    case _ => () // top level value
                }
            }
            peeked = PEEK_STATE_NONE
        }

        return res
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
                        case _ => throw IllegalStateException("Name must be followed by JSON value.")
                    }
            }
        }
        afterRead()

        let ret = stringBuffer.data[0..stringBuffer.size].clone()
        stringBuffer.clear()

        return ret
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
                throw IllegalStateException("Expected a string as JSON name, but peeked '${Rune(nextByte)}'.")

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
            case _ => throw IllegalStateException("Unexpected character: '${Rune(nextByte)}'.")
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
                throw IllegalStateException("Cannot read value in object: name must be handled first.")
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
                throw IllegalStateException("Expected readValue after readName.")
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
                            case _ => throw IllegalStateException("Name must be followed by JSON value.")
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
            throw IllegalStateException("Cannot read value in object: name must be handled first.")
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
        fillInBuf(1)
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
            throw IllegalStateException("UTF-8 sequence exceeds maximum of 4 bytes.")
        }
    }

    private func isJsonWhiteSpace(b: Byte): Bool {
        return b == b' ' || b == b'\t' || b == b'\n' || b == b'\r'
    }

    private func checkJsonStringCharacter(b: Byte): Unit {
        if (b < 0x20) {
            throw IllegalStateException(INVALID_JSON_STRING_CONTROL_CHARACTER)
        }
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
    func nextString(sb: StringBuffer) {
        var count = 0
        var nextByte: Byte
        while (count < 2) {
            nextByte = readNext()
            sb.append(nextByte)
            if (count > 0) {
                checkJsonStringCharacter(nextByte)
            }
            if (nextByte == b'"') {
                count++
                continue
            }
            if (nextByte == b'\\') {
                nextByte = readNext()
                checkJsonStringCharacter(nextByte)
                sb.append(nextByte)
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
                        let escapedByte = readNext()
                        checkJsonStringCharacter(escapedByte)
                        sb.append(escapedByte)
                        continue
                    }
                    throw IllegalStateException("Unexpected character: '\\'.")
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
                case _ =>
                    if (inString) {
                        checkJsonStringCharacter(nextByte)
                    }
            }
        }

        // Non-symmetry end of segment, throw error
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
            if (count > 0) {
                checkJsonStringCharacter(nextByte)
            }
            if (nextByte == b'"') {
                count++
                continue
            }
            if (nextByte == b'\\') {
                nextByte = readNext()
                checkJsonStringCharacter(nextByte)
            }
        }
    }

    @OverflowWrapping
    func skipName() {
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

    func skipArray() {
        skipSymmetrySegment(start: b'[', end: b']')
    }

    func skipObject() {
        skipSymmetrySegment(start: b'{', end: b'}')
    }

    func skipSymmetrySegment(start!: Byte, end!: Byte) {
        let depth = stacks.depth
        if (start == b'[') {
            startArray()
        } else {
            startObject()
        }
        var inString = false
        while (true) {
            let nextByte = readNext()
            match (nextByte) {
                case b'\\' =>
                    if (inString) {
                        let escapedByte = readNext()
                        checkJsonStringCharacter(escapedByte)
                        continue
                    }
                    throw IllegalStateException("Unexpected character: '\\'.")
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
                case _ =>
                    if (inString) {
                        checkJsonStringCharacter(nextByte)
                    }
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
            } else if (breakIndex == JSON_STRING_CONTROL_CHARACTER_INDEX) {
                throw IllegalStateException(INVALID_JSON_STRING_CONTROL_CHARACTER)
            } else if (breakIndex < 0) { // utf 8 check err
                throw IllegalStateException("Invalid UTF-8 byte sequence.")
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
                    throw IllegalStateException("Invalid UTF-8 byte sequence.")
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
            nextNonJsonWhitespace()
        } else if (peeked == PEEK_STATE_NUMBER) {
            checkBuffer()
            buffer[index]
        } else {
            throw IllegalStateException("Failed to read JSON number.")
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
            nextNonJsonWhitespace()
        } else if (peeked == PEEK_STATE_NUMBER) {
            checkBuffer()
            buffer[index]
        } else {
            throw IllegalStateException("Failed to read JSON number.")
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
                    // `0d` decimal prefix: a Cangjie extension covered by the
                    // radix-path LLT tests (0d33 -> 33), same family as 0b/0o/0x.
                    index++
                    availLen--
                    return readUIntDecimal()
                case _ => ()
            }
            // Strict JSON (RFC 8259) forbids leading zeros: `01` is invalid,
            // matching the String-based parser.
            if (isDecimalDigit(prefix)) {
                throw IllegalStateException("Invalid number format.")
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
        // Lazy boundary handling: stop at the first non-digit and return the
        // prefix. What follows is the next token-level read's problem
        // (peek() rejects any byte that cannot start a token); see also
        // readUIntRadix.
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
        // The literal stops at the first byte that cannot continue it and the
        // in-radix prefix is returned (`0b12` -> 1, `0o18` -> 1, `0x1g` -> 1,
        // as locked by the existing LLT tests). Validating what follows is
        // the next token-level read's job (peek() rejects any byte that
        // cannot start a token); the decimal paths share this semantics.
        return (result, false)
    }

    private func readFloatEx(): Float64 {
        let sign = match (nextNonJsonWhitespace()) {
            case b'-' =>
                index++
                availLen--
                -1.0
            case _ => 1.0 // a leading '+' is invalid, matching the String parser
        }

        fillInBuf()
        var result = 0.0
        var pointNum = 0
        var leftMove = 1.0
        var hasIntDigit = false
        var hasFracDigit = false
        var leadingZero = false
        while (availLen > 0) {
            if (pointNum > 1) {
                throw IllegalStateException("Invalid number format.")
            }
            let c = buffer[index]
            if (c >= b'0' && c <= b'9') {
                if (pointNum == 0) {
                    if (!hasIntDigit) {
                        leadingZero = (c == b'0')
                        hasIntDigit = true
                    } else if (leadingZero) {
                        // Strict JSON forbids leading zeros in the integer part.
                        throw IllegalStateException("Invalid number format.")
                    }
                } else {
                    hasFracDigit = true
                }
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
            fillInBuf()
        }
        if (!hasIntDigit || (pointNum == 1 && !hasFracDigit)) {
            // Rejects bare signs, `.5`, `5.` and similar fragments the
            // String-based parser rejects as well.
            throw IllegalStateException("Invalid number format.")
        }
        let value = sign * result / leftMove
        if (isJsonFloatInfinite(value)) {
            throw IllegalStateException("Invalid float detected.")
        }
        return value
    }

    @OverflowWrapping
    func readFloat(): Float64 {
        if (peeked != PEEK_STATE_NONE && peeked != PEEK_STATE_VALUE && peeked != PEEK_STATE_NUMBER) {
            throw IllegalStateException("Failed to read JSON number.")
        }

        let result = readFloatEx()
        // Exponent is parsed from the direct byte (no whitespace skipping):
        // JSON numbers contain no internal whitespace, so `1e +5` is invalid,
        // exactly like in the String-based parser.
        if (availLen <= 0) {
            fillInBuf()
        }
        if (availLen > 0 && (buffer[index] == b'e' || buffer[index] == b'E')) {
            index++
            availLen--
            let exponent = readFloatExponent()
            let value = result * (10.0 ** exponent)
            if (isJsonFloatInfinite(value)) {
                throw IllegalStateException("Invalid float detected.")
            }
            return value
        }
        return result
    }

    // Parses `exp = [ sign ] 1*DIGIT` after the exponent marker has been
    // consumed and returns the signed exponent. Leading zeros stay valid
    // (`1e05`); a missing digit (`1e` / `1e+`) is rejected; a magnitude at
    // or beyond Int64's range reports OverflowException.
    @OverflowWrapping
    private func readFloatExponent(): Int64 {
        if (availLen <= 0) {
            fillInBuf()
        }
        var negative = false
        if (availLen > 0 && buffer[index] == b'+') {
            index++
            availLen--
        } else if (availLen > 0 && buffer[index] == b'-') {
            negative = true
            index++
            availLen--
        }
        var expMag: UInt64 = 0
        var hasExpDigit = false
        var expOverflow = false
        while (true) {
            if (availLen <= 0) {
                fillInBuf()
                if (availLen <= 0) {
                    break
                }
            }
            let c = buffer[index]
            if (!isDecimalDigit(c)) {
                break
            }
            hasExpDigit = true
            if (!expOverflow) {
                if (expMag > DECIMAL_OVERFLOW_LIMIT_UI64) {
                    expOverflow = true
                } else {
                    expMag = expMag * 10
                    if (MAXVAL_UI64 - expMag < UInt64(c - b'0')) {
                        expOverflow = true
                    } else {
                        expMag += UInt64(c - b'0')
                    }
                }
            }
            index++
            availLen--
        }
        if (!hasExpDigit) {
            throw IllegalStateException("Invalid number format.")
        }
        // Per-sign magnitude limits, mirroring the pre-RFC8259 readInt path
        // exactly: a positive exponent must fit Int64 (anything above
        // Int64.Max overflows), while a negative exponent may use the full
        // magnitude up to 2^63 — at exactly MAXABSVAL_I64 the Int64
        // conversion wraps to Int64.Min and the negation wraps back, netting
        // Int64.Min (all under @OverflowWrapping). Anything larger overflows
        // for both signs.
        if (expOverflow) {
            throw OverflowException("Overflow while reading JSON number.")
        }
        if (negative) {
            if (expMag > MAXABSVAL_I64) {
                throw OverflowException("Overflow while reading JSON number.")
            }
            return -Int64(expMag)
        }
        if (expMag > MAXVAL_I64) {
            throw OverflowException("Overflow while reading JSON number.")
        }
        return Int64(expMag)
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
            throw IllegalStateException("JSON string length '${minCapacity}' exceeds maximum '${MAX_JSON_STREAM_STRING_BUFFER_SIZE}'.")
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
            throw IllegalStateException("JSON string length '${size + cSize}' exceeds maximum '${MAX_JSON_STREAM_STRING_BUFFER_SIZE}'.")
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
            throw IllegalStateException("JSON string length '${size}' exceeds maximum '${MAX_JSON_STREAM_STRING_BUFFER_SIZE}'.")
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
