/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.encoding.json.stream



let hex = "0123456789abcdef".toArray()
const HIGH_1_MASK: UInt32 = 0b10000000 // 0x80
const HIGH_2_MASK: UInt32 = 0b11000000 // 0xc0
const HIGH_3_MASK: UInt32 = 0b11100000 // 0xe0
const HIGH_4_MASK: UInt32 = 0b11110000 // 0xf0
const HIGH_5_MASK: UInt32 = 0b11111000 // 0xf8
const HIGH_6_MASK: UInt32 = 0b11111100 // 0xfc
const SHIFT_30: UInt32 = 30
const SHIFT_24: UInt32 = 24
const SHIFT_18: UInt32 = 18
const SHIFT_12: UInt32 = 12
const SHIFT_6: UInt32 = 6
const LOW_6_MASK: UInt32 = 0b00111111 // 0x3f
const LOW_5_MASK: UInt32 = 0b00011111 // 0x1f
const LOW_4_MASK: UInt32 = 0b00001111 // 0x0f
const LOW_3_MASK: UInt32 = 0b00000111 // 0x07
const LOW_2_MASK: UInt32 = 0b00000011 // 0x03
const LOW_1_MASK: UInt32 = 0b00000001 // 0x01

const UTF8_5_MAX: UInt32 = 0x3FFFFFF
const UTF8_4_MAX: UInt32 = 0x10FFFF
const UTF8_3_MAX: UInt32 = 0xFFFF
const UTF8_2_MAX: UInt32 = 0x07FF
const UTF8_1_MAX: UInt32 = 0x7F
const ESCAPE_SIZE_2: Int64 = 2
const ESCAPE_SIZE_6: Int64 = 6
// The native chunk writer scans, escapes and copies one buffer region in a
// single foreign call, so its fixed pinning + FFI cost only pays off for
// payload-sized strings.  Smaller strings keep the inlined Cangjie scan.
const NATIVE_STRING_CHUNK_THRESHOLD: Int64 = 64

// Plain runs of at least one staging buffer in size bypass the buffer
// entirely: the vectorized scanner locates the run and the raw bytes are
// appended to the output stream with one copy, so long strings never pay
// the staging double hop.  Keep in sync with JsonWriter.DEFAULT_CAPACITY.
const NATIVE_STRING_DIRECT_THRESHOLD: Int64 = 4096

@FastNative
foreign func CJ_JSON_EscapeStringChunk(input: CPointer<UInt8>, inputLen: Int64,
    output: CPointer<UInt8>, outputCapacity: Int64): Int64

@FastNative
foreign func CJ_JSON_StringFindFirstEscape(input: CPointer<UInt8>, from: Int64, end: Int64): Int64

func newEscapeTable(): Array<Byte> {
    let escapeTable: Array<Byte> = Array<Byte>(128, repeat: 0)
    escapeTable[Int64(b'\b')] = b'b'
    escapeTable[Int64(b'\t')] = b't'
    escapeTable[Int64(b'\n')] = b'n'
    escapeTable[Int64(b'\f')] = b'f'
    escapeTable[Int64(b'\r')] = b'r'
    escapeTable[Int64(b'\"')] = b'\"'
    escapeTable[Int64(b'\\')] = b'\\'
    return escapeTable
}

let escapeTable = newEscapeTable()

/*
 * Chunk loop for the native string writer: each pass reserves buffer space,
 * pins the input and output raw data, and lets the native helper fill the
 * writable region.  Plain strings complete in one call; escaped strings stop
 * before the region can no longer hold the worst-case expansion of one byte,
 * and the loop continues from the consumed offset.  The worst-case escape is
 * six bytes, so reserving at least that much guarantees forward progress.
 *
 * When the unconsumed tail is large enough, a vectorized native scan first
 * locates the next escape byte.  A plain run of at least one staging buffer
 * in size is flushed and appended to the output stream directly, skipping
 * the staging buffer's second copy; shorter runs (and escape bytes) fall
 * through to the chunk writer as before.
 */
@OverflowWrapping
func writeNativeStringChunks(w: JsonWriter, value: String): Unit {
    var consumed = 0
    let total = value.size
    let canDirectWrite = true //w.directByteBuffer.isNone()
    while (consumed < total) {
        let remaining = total - consumed
        if (canDirectWrite && remaining >= NATIVE_STRING_DIRECT_THRESHOLD) {
            let escapePos = unsafe {
                let input = acquireArrayRawData(value.rawData())
                try {
                    CJ_JSON_StringFindFirstEscape(input.pointer, consumed, total)
                } finally {
                    releaseArrayRawData(input)
                }
            }
            let plainLen = escapePos - consumed
            if (plainLen >= NATIVE_STRING_DIRECT_THRESHOLD) {
                w.flushOutBuf()
                unsafe { w.out.write(value.rawData()[consumed..consumed+plainLen]) }
                consumed += plainLen
                continue
            }
        }
        let wanted = if (remaining < JsonWriter.DEFAULT_CAPACITY) {
            remaining
        } else {
            JsonWriter.DEFAULT_CAPACITY
        }
        w.ensureBufferSpace(max(wanted, ESCAPE_SIZE_6))
        let packed = unsafe {
            let input = acquireArrayRawData(value.rawData())
            let output = acquireArrayRawData(w.buffer)
            try {
                CJ_JSON_EscapeStringChunk(input.pointer + consumed, remaining,
                    output.pointer + w.curPos, w.buffer.size - w.curPos)
            } finally {
                releaseArrayRawData(output)
                releaseArrayRawData(input)
            }
        }
        let consumedNow = packed >> 32
        if (consumedNow <= 0) {
            throw IllegalStateException("String escape chunk writer made no progress.")
        }
        consumed += consumedNow
        w.curPos += packed & 0xFFFFFFFF
    }
}

@OverflowWrapping
func writeEscapeAscii(w: JsonWriter, byte: Int64) {
    if (escapeTable[byte] != 0) {
        w.ensureBufferSpace(ESCAPE_SIZE_2)
        w.buffer[w.curPos + 1] = escapeTable[byte]
        w.buffer[w.curPos] = b'\\'
        w.curPos += 2
    } else {
        w.ensureBufferSpace(ESCAPE_SIZE_6)
        w.buffer[w.curPos + 5] = hex[byte & 0xF] // num of low 4 bits
        w.buffer[w.curPos + 4] = hex[byte >> 4] // num of high 4 bits
        w.buffer[w.curPos + 3] = b'0'
        w.buffer[w.curPos + 2] = b'0'
        w.buffer[w.curPos + 1] = b'u'
        w.buffer[w.curPos] = b'\\'
        w.curPos += 6
    }
}

@OverflowWrapping
func writeStringValue(w: JsonWriter, value: String): Unit {
    w.ensureBufferSpace(1)
    w.buffer[w.curPos] = b'\"'
    w.curPos++

    // In the default compact mode the native chunk writer has the same
    // escape classification as the stream writer, so a long string is
    // scanned, escaped and copied in one foreign call per buffer region.
    // htmlSafe keeps the complete stream-side classifier because it
    // additionally escapes <, >, = and '.
    if (value.size >= NATIVE_STRING_CHUNK_THRESHOLD && !w.writeConfig.htmlSafe) {
        writeNativeStringChunks(w, value)
        w.ensureBufferSpace(1)
        w.buffer[w.curPos] = b'\"'
        w.curPos++
        return
    }

    var beforePos = 0
    let backslash = Int64(b'\\')
    var escapeMask = 0u64
    escapeMask |= 1u64 << Int64(b'\"')
    escapeMask |= (1u64 << 32) - 1u64

    if (w.writeConfig.htmlSafe) {
        var htmlEscapeMask = 0u64
        htmlEscapeMask |= (1u64 << Int64(b'<'))
        htmlEscapeMask |= (1u64 << Int64(b'>'))
        htmlEscapeMask |= (1u64 << Int64(b'&'))
        htmlEscapeMask |= (1u64 << Int64(b'='))
        htmlEscapeMask |= (1u64 << Int64(b'\''))
        escapeMask |= htmlEscapeMask
    }
    for (index in 0..value.size) {
        let byte = Int64(value[index])
        if (byte > 127) {
            continue
        }
        if (byte == 127 || byte == backslash || (byte < 64 && ((1u64 << byte) & escapeMask) != 0)) {
            flushStringSegment(w, value, index, beforePos)
            writeEscapeAscii(w, byte)
            beforePos = index + 1
        }
    }

    flushStringSegment(w, value, value.size, beforePos)
    w.ensureBufferSpace(1)
    w.buffer[w.curPos] = b'\"'
    w.curPos++
}

@OverflowWrapping
func flushStringSegment(w: JsonWriter, value: String, curPos: Int64, beforePos: Int64) {
    if (curPos <= beforePos) {
        return
    }
    let length = curPos - beforePos
    // if (let Some(_) <- w.directByteBuffer) {
    //     w.ensureBufferSpace(length)
    //     unsafe { value.rawData().copyTo(w.buffer, beforePos, w.curPos, length) }
    //     w.curPos += length
    // } else 
    if (length >= JsonWriter.LARGE_VALUE_THRESHOLD) {
        // write directly to the stream if the string is too long
        w.flushOutBuf()
        unsafe { w.out.write(value.rawData()[beforePos..curPos]) }
    } else {
        w.ensureBufferSpace(length)
        unsafe { value.rawData().copyTo(w.buffer, beforePos, w.curPos, length) }
        w.curPos += length
        // flush if the buffer is nearly full
        if (w.curPos >= JsonWriter.FLUSH_THRESHOLD) {
            w.flushOutBuf()
        }
    }
}

extend String <: JsonSerializable {
    @OverflowWrapping
    public func toJson(w: JsonWriter): Unit {
        w.beforeValue()
        writeStringValue(w, this)
    }
}

extend String <: JsonDeserializable<String> {
    public static func fromJson(r: JsonReader): String {
        const TRUE = "true"
        const FALSE = "false"
        const NULL = "null"
        match (r.peek()) {
            case Some(JsonToken.JsonString) => return r.readString()
            case Some(JsonToken.JsonBool) =>
                return if (r.readBool()) {
                    TRUE
                } else {
                    FALSE
                }
            case Some(JsonToken.JsonNull) =>
                r.readNull()
                return NULL
            case Some(JsonToken.JsonNumber) =>
                r.nextValue(r.stringBuffer)
                let value = unsafe { String.fromUtf8Unchecked(r.stringBuffer.data[0..r.stringBuffer.size]) }
                r.stringBuffer.clear()
                return value
            case _ => throw IllegalStateException("The next Token is not JSON String.")
        }
    }
}
