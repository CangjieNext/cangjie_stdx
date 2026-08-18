/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.encoding.json

import std.collection.*
import std.convert.*

const MAX_JSON_PARSE_DEPTH = 100
const INITIAL_JSON_OBJECT_CAPACITY = 8
const INITIAL_JSON_ARRAY_CAPACITY = 8
const PARSED_FLAT_STORAGE_SLAB_CONTAINERS = 32
const PARSED_FLAT_STORAGE_SLOTS = PARSED_FLAT_STORAGE_SLAB_CONTAINERS * 8

// JSON null and booleans are immutable values.  The parser sees them very
// frequently, so keep one process-wide instance of each instead of allocating
// three short-lived objects for every occurrence.
let SHARED_JSON_NULL = JsonNull()
let SHARED_JSON_TRUE = JsonBool(true)
let SHARED_JSON_FALSE = JsonBool(false)

@FastNative
foreign func CJ_JSON_ReplaceEscapeChar(input: CPointer<UInt8>, inputlen: Int64, buffer: CPointer<UInt8>, htmlSafe: Bool): Int64

@FastNative
foreign func CJ_JSON_WriteBufferAppendInt(buffer: CPointer<UInt8>, num: Int64): Int64

@FastNative
foreign func CJ_JSON_FloatPrint(num: Float64, dest: CPointer<UInt8>, destSize: Int64): Int64

@FastNative
foreign func CJ_JSON_StringEscapeCharNumGet(input: CPointer<UInt8>, inputlen: Int64, htmlSafe: Bool): Int64

@FastNative
foreign func CJ_JSON_ParseInt64(data: CPointer<UInt8>, start: Int64, end: Int64): Int64

@FastNative
foreign func CJ_JSON_ParseFloat64(data: CPointer<UInt8>, start: Int64, end: Int64): Float64

@FastNative
foreign func CJ_JSON_ValidateUtf8AndCopy(input: CPointer<UInt8>, output: CPointer<UInt8>, size: Int64): Bool

/**
 * @brief Get rows and columns of the error position
 *
 * @param Array<UInt8> JSON string array
 * @param Int64 The order of the error characters in the string
 * @return (Int64, Int64) Rows and columns of the error position
 * @throws IllegalArgumentException if there is no valid utf8 leading code in array `strArr`.
 */
func getErrRowAndCol(strArr: Array<UInt8>, errPos: Int64): (Int64, Int64) {
    var tempPos: Int64 = 0
    var errRow: Int64 = 1
    var errCol: Int64 = 1
    var lineStartPos: Int64 = 0
    while (tempPos < errPos) {
        let temp = Rune.fromUtf8(strArr, tempPos)
        let tempChr = temp[0]
        if (tempChr == r'\n') {
            errRow += 1
            lineStartPos = tempPos + 1
        }
        tempPos += temp[1]
    }
    while (lineStartPos < errPos) {
        let tempChr = Rune.fromUtf8(strArr, lineStartPos)[0]
        if (tempChr == r' ') {
            lineStartPos += 1
        } else {
            break
        }
    }
    while (lineStartPos < errPos) {
        let temp = Rune.fromUtf8(strArr, lineStartPos)
        let tempSize = temp[1]
        errCol += 1
        lineStartPos += tempSize
    }
    return (errRow, errCol)
}

/**
 * @brief Handle Escape Characters and Multibyte Characters
 *
 * @param Rune error characters
 * @return String Escaped character string
 */
func handleErrChr(errChr: Rune): String {
    match (errChr) {
        case r'\0' => return "\\0"
        case r'\b' => return "\\b"
        case r'\t' => return "\\t"
        case r'\n' => return "\\n"
        case r'\f' => return "\\f"
        case r'\r' => return "\\r"
        case r'\v' => return "\\v"
        case _ => return "${errChr}"
    }
}

enum NumberSystem {
    Binary |
    Octal |
    Decimal |
    Hex
}

// Parsed small containers keep independent eight-slot Array views while their
// backing storage is allocated in chunks. A view retains its slab after the
// parser advances to the next chunk or is discarded.
class ParsedFlatStorageArena {
    private var objectFieldsSlab = Array<(String, JsonValue)>()
    private var objectFieldsNext: Int64 = PARSED_FLAT_STORAGE_SLOTS
    private var arrayItemsSlab = Array<JsonValue>()
    private var arrayItemsNext: Int64 = PARSED_FLAT_STORAGE_SLOTS

    func allocateObjectFields(): Array<(String, JsonValue)> {
        if (objectFieldsNext + 8 > objectFieldsSlab.size) {
            objectFieldsSlab = Array<(String, JsonValue)>(
                PARSED_FLAT_STORAGE_SLOTS,
                repeat: unsafe { zeroValue<(String, JsonValue)>() }
            )
            objectFieldsNext = 0
        }
        let fields = objectFieldsSlab.slice(objectFieldsNext, 8)
        objectFieldsNext += 8
        return fields
    }

    func allocateArrayItems(): Array<JsonValue> {
        if (arrayItemsNext + 8 > arrayItemsSlab.size) {
            arrayItemsSlab = Array<JsonValue>(
                PARSED_FLAT_STORAGE_SLOTS,
                repeat: unsafe { zeroValue<JsonValue>() }
            )
            arrayItemsNext = 0
        }
        let items = arrayItemsSlab.slice(arrayItemsNext, 8)
        arrayItemsNext += 8
        return items
    }
}

const MAXVAL_I64: UInt64 = 0x7FFF_FFFF_FFFF_FFFF
const MAXVAL_UI64: UInt64 = 0xFFFF_FFFF_FFFF_FFFF
const MAXABSVAL_I64: UInt64 = MAXVAL_I64 + 1
const MINVAL_I64: Int64 = -0x8000_0000_0000_0000
const DECIMAL_OVERFLOW_LIMIT_UI64 = MAXVAL_UI64 / 10

class JsonParser {
    var data: Array<Byte>
    var size: Int64
    var offset: Int64
    var depth: Int64
    // Safe byte parsing validates before constructing this parser. The owned
    // path validates high-byte sequences while scanning JSON strings so it
    // does not need a separate whole-input pass.
    var integratedUtf8Validation: Bool
    var invalidUtf8: Bool
    var lastStringHtmlSafe: Bool
    var flatStorageArena: ParsedFlatStorageArena
    // Escaped strings are uncommon for the DOM workload.  Do not reserve a
    // fraction of every input until parsing actually encounters a backslash.
    var strCache: ?ArrayList<Byte> = None

    init(str: String) {
        this.data = unsafe { str.rawData() }
        this.size = data.size
        this.offset = 0
        this.depth = 0
        this.integratedUtf8Validation = false
        this.invalidUtf8 = false
        this.lastStringHtmlSafe = false
        this.flatStorageArena = ParsedFlatStorageArena()
    }

    init(data: Array<Byte>) {
        this.data = data
        this.size = data.size
        this.offset = 0
        this.depth = 0
        this.integratedUtf8Validation = false
        this.invalidUtf8 = false
        this.lastStringHtmlSafe = false
        this.flatStorageArena = ParsedFlatStorageArena()
    }

    init(data: Array<Byte>, integratedUtf8Validation: Bool) {
        this.data = data
        this.size = data.size
        this.offset = 0
        this.depth = 0
        this.integratedUtf8Validation = integratedUtf8Validation
        this.invalidUtf8 = false
        this.lastStringHtmlSafe = false
        this.flatStorageArena = ParsedFlatStorageArena()
    }

    func reset(): Unit {
        this.offset = 0
        this.depth = 0
        this.invalidUtf8 = false
        this.lastStringHtmlSafe = false
        this.flatStorageArena = ParsedFlatStorageArena()
        if (let Some(cache) <- this.strCache) {
            cache.clear()
        }
    }

    func reinit(str: String): Unit {
        this.data = unsafe { str.rawData() }
        this.size = data.size
        this.integratedUtf8Validation = false
        reset()
    }
}

func ensureStrCache(parser: JsonParser): ArrayList<Byte> {
    return match (parser.strCache) {
        case Some(cache) => cache
        case None =>
            let cache = ArrayList<Byte>(64)
            parser.strCache = cache
            cache
    }
}

func validateUtf8SequenceAt(parser: JsonParser, offset: Int64): Int64 {
    let byte1 = parser.data[offset]
    if (byte1 >= 0xc2 && byte1 <= 0xdf) {
        if (offset + 1 >= parser.size) {
            parser.invalidUtf8 = true
            throw JsonException()
        }
        let byte2 = parser.data[offset + 1]
        if (byte2 < 0x80 || byte2 > 0xbf) {
            parser.invalidUtf8 = true
            throw JsonException()
        }
        return 2
    }
    if (byte1 >= 0xe0 && byte1 <= 0xef) {
        if (offset + 2 >= parser.size) {
            parser.invalidUtf8 = true
            throw JsonException()
        }
        let byte2 = parser.data[offset + 1]
        let byte3 = parser.data[offset + 2]
        let secondValid = match {
            case byte1 == 0xe0 => byte2 >= 0xa0 && byte2 <= 0xbf
            case byte1 == 0xed => byte2 >= 0x80 && byte2 <= 0x9f
            case _ => byte2 >= 0x80 && byte2 <= 0xbf
        }
        if (!secondValid || byte3 < 0x80 || byte3 > 0xbf) {
            parser.invalidUtf8 = true
            throw JsonException()
        }
        return 3
    }
    if (byte1 >= 0xf0 && byte1 <= 0xf4) {
        if (offset + 3 >= parser.size) {
            parser.invalidUtf8 = true
            throw JsonException()
        }
        let byte2 = parser.data[offset + 1]
        let byte3 = parser.data[offset + 2]
        let byte4 = parser.data[offset + 3]
        let secondValid = match {
            case byte1 == 0xf0 => byte2 >= 0x90 && byte2 <= 0xbf
            case byte1 == 0xf4 => byte2 >= 0x80 && byte2 <= 0x8f
            case _ => byte2 >= 0x80 && byte2 <= 0xbf
        }
        if (!secondValid || byte3 < 0x80 || byte3 > 0xbf || byte4 < 0x80 || byte4 > 0xbf) {
            parser.invalidUtf8 = true
            throw JsonException()
        }
        return 4
    }
    parser.invalidUtf8 = true
    throw JsonException()
}

func requireCurrentByte(parser: JsonParser): Byte {
    if (parser.offset >= parser.size) {
        throw JsonException()
    }
    let current = parser.data[parser.offset]
    if (parser.integratedUtf8Validation && current >= 0x80) {
        let _ = validateUtf8SequenceAt(parser, parser.offset)
    }
    return current
}

func isHighSurrogate(num: UInt32): Bool {
    return num >= 0xD800u32 && num <= 0xDBFFu32 // UTF-16 high-surrogate range: D800..DBFF.
}

func isLowSurrogate(num: UInt32): Bool {
    return num >= 0xDC00u32 && num <= 0xDFFFu32 // UTF-16 low-surrogate range: DC00..DFFF.
}

func ensureFiniteJsonFloat(value: Float64): Float64 {
    if (value.isNaN() || value.isInf()) {
        throw JsonException("Invalid float detected.")
    }
    return value
}

func skipWhiteSpace(parser: JsonParser): Unit {
    if (parser.offset >= parser.size) {
        return
    }
    var tmp = parser.data[parser.offset]
    while (tmp == b' ' || tmp == b'\t' || tmp == b'\n' || tmp == b'\r') {
        parser.offset++
        if (parser.offset >= parser.size) {
            return
        }
        tmp = parser.data[parser.offset]
    }
}

func buildParseErrorMessage(parser: JsonParser): String {
    let strArr = parser.data
    var errPos = parser.offset
    if (errPos >= strArr.size) {
        errPos = strArr.size - 1
    }
    let errRowAndCol = getErrRowAndCol(strArr, errPos)
    let (errChr, _) = Rune.fromUtf8(strArr, errPos)
    let errStr = handleErrChr(errChr)
    return "Parse Error: [Line]: ${errRowAndCol[0]}, [Pos]: ${errRowAndCol[1]}, [Error]: Unexpected character: \'${errStr}\'."
}

func parseString(str: String): JsonValue {
    if (str.size == 0) {
        throw JsonException("Json String is empty!")
    }
    let parser = JsonParser(str)
    try {
        let res = parseJson(parser)
        if (parser.offset <= (parser.size - 1)) {
            skipWhiteSpace(parser)
        }
        if (parser.offset <= (parser.size - 1)) {
            throw JsonException()
        }
        return res
    } catch (_: Exception) {
        let errMsg = buildParseErrorMessage(parser)
        throw JsonException("The json data is Non-standard, please check:\n${errMsg}")
    }
}

func parseValidatedUtf8Bytes(data: Array<Byte>, integratedUtf8Validation: Bool): JsonValue {
    let parser = JsonParser(data, integratedUtf8Validation)
    try {
        let res = parseJson(parser)
        if (parser.offset <= (parser.size - 1)) {
            skipWhiteSpace(parser)
        }
        if (parser.offset <= (parser.size - 1)) {
            let _ = requireCurrentByte(parser)
            throw JsonException()
        }
        return res
    } catch (_: Exception) {
        if (parser.invalidUtf8) {
            throw JsonException("Json byte array is not valid UTF-8.")
        }
        let errMsg = buildParseErrorMessage(parser)
        throw JsonException("The json data is Non-standard, please check:\n${errMsg}")
    }
}

func parseUtf8Bytes(data: Array<Byte>): JsonValue {
    if (data.size == 0) {
        throw JsonException("Json byte array is empty!")
    }
    // Unescaped DOM strings retain slices of parser.data.  Keep one private
    // backing array, but validate while copying it so UTF-8 input is read once.
    let parserData = Array<Byte>(data.size, repeat: 0)
    let isValidUtf8 = unsafe {
        let input = acquireArrayRawData(data)
        let output = acquireArrayRawData(parserData)
        let result = CJ_JSON_ValidateUtf8AndCopy(input.pointer, output.pointer, data.size)
        releaseArrayRawData(output)
        releaseArrayRawData(input)
        result
    }
    if (!isValidUtf8) {
        throw JsonException("Json byte array is not valid UTF-8.")
    }
    return parseValidatedUtf8Bytes(parserData, false)
}

func parseOwnedUtf8Bytes(data: Array<Byte>): JsonValue {
    if (data.size == 0) {
        throw JsonException("Json byte array is empty!")
    }
    return parseValidatedUtf8Bytes(data, true)
}

func parseJson(parser: JsonParser): JsonValue {
    skipWhiteSpace(parser)
    let start = requireCurrentByte(parser)
    match {
        case start == b'{' =>
            parser.depth++
            if (parser.depth > MAX_JSON_PARSE_DEPTH) {
                throw JsonException("Json nested depth exceeds ${MAX_JSON_PARSE_DEPTH}.")
            }
            let value = parseJsonObject(parser)
            parser.depth--
            return value
        case start == b'[' =>
            parser.depth++
            if (parser.depth > MAX_JSON_PARSE_DEPTH) {
                throw JsonException("Json nested depth exceeds ${MAX_JSON_PARSE_DEPTH}.")
            }
            let value = parseJsonArray(parser)
            parser.depth--
            return value
        case start == b'n' => return parseJsonNull(parser)
        case start == b't' => return parseJsonTrue(parser)
        case start == b'f' => return parseJsonFalse(parser)
        case start == b'\"' => return parseJsonString(parser)
        case start >= b'0' && start <= b'9' || start == b'-' => return parseJsonNumber(parser)
        case _ => throw JsonException()
    }
}

func parseJsonObject(parser: JsonParser): JsonObject {
    parser.offset++
    skipWhiteSpace(parser)
    let obj = JsonObject(parser.flatStorageArena.allocateObjectFields(), 0)
    var first = true
    while (requireCurrentByte(parser) != b'}') {
        if (first) {
            first = false
        } else if (requireCurrentByte(parser) == b',') {
            parser.offset++
        } else {
            throw JsonException()
        }
        skipWhiteSpace(parser)
        let key = parseJsonObjectKey(parser)
        let keyHtmlSafe = parser.lastStringHtmlSafe
        skipWhiteSpace(parser)
        if (requireCurrentByte(parser) != b':') {
            throw JsonException()
        }
        parser.offset++
        let value = parseJson(parser)
        skipWhiteSpace(parser)
        obj.putParsed(key, value, keyHtmlSafe)
    }
    parser.offset++
    return obj
}

func parseJsonArray(parser: JsonParser): JsonArray {
    parser.offset++
    skipWhiteSpace(parser)
    let arr = JsonArray(parser.flatStorageArena.allocateArrayItems(), 0)
    var first = true
    while (requireCurrentByte(parser) != b']') {
        if (first) {
            first = false
        } else if (requireCurrentByte(parser) == b',') {
            parser.offset++
        } else {
            throw JsonException()
        }
        let item = parseJson(parser)
        skipWhiteSpace(parser)
        arr.add(item)
    }
    parser.offset++
    return arr
}

func parseJsonNull(parser: JsonParser): JsonNull {
    if (requireCurrentByte(parser) != b'n') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'u') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'l') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'l') {
        throw JsonException()
    }
    parser.offset++
    return SHARED_JSON_NULL
}

func parseJsonTrue(parser: JsonParser): JsonBool {
    if (requireCurrentByte(parser) != b't') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'r') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'u') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'e') {
        throw JsonException()
    }
    parser.offset++
    return SHARED_JSON_TRUE
}

func parseJsonFalse(parser: JsonParser): JsonBool {
    if (requireCurrentByte(parser) != b'f') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'a') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'l') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b's') {
        throw JsonException()
    }
    parser.offset++
    if (requireCurrentByte(parser) != b'e') {
        throw JsonException()
    }
    parser.offset++
    return SHARED_JSON_FALSE
}

func tryParseJsonIntFast(parser: JsonParser): (Bool, Int64) {
    let start = parser.offset
    var isNegative = false
    if (parser.data[parser.offset] == b'-') {
        isNegative = true
        parser.offset++
        if (parser.offset >= parser.size) {
            parser.offset = start
            return (false, 0)
        }
    }

    let firstDigit = parser.data[parser.offset]
    if (firstDigit < b'0' || firstDigit > b'9') {
        parser.offset = start
        return (false, 0)
    }

    if (firstDigit == b'0' && parser.offset + 1 < parser.size) {
        let nextByte = parser.data[parser.offset + 1]
        if (nextByte >= b'0' && nextByte <= b'9') {
            throw JsonException()
        }
        if (nextByte == b'b' || nextByte == b'B' || nextByte == b'o' || nextByte == b'O' || nextByte == b'x' ||
            nextByte == b'X' || nextByte == b'd' || nextByte == b'D') {
            parser.offset = start
            return (false, 0)
        }
    }

    var result: UInt64 = 0
    while (parser.offset < parser.size) {
        let nextByte = parser.data[parser.offset]
        if (nextByte < b'0' || nextByte > b'9') {
            break
        }
        let digit = UInt64(nextByte - b'0')
        if (result > DECIMAL_OVERFLOW_LIMIT_UI64) {
            parser.offset = start
            return (false, 0)
        }
        result = result * 10
        if (MAXVAL_UI64 - result < digit) {
            parser.offset = start
            return (false, 0)
        }
        result += digit
        parser.offset++
    }

    if (parser.offset < parser.size) {
        let tail = parser.data[parser.offset]
        if (tail == b'.' || tail == b'e' || tail == b'E') {
            parser.offset = start
            return (false, 0)
        }
    }

    if (isNegative) {
        if (result > MAXABSVAL_I64) {
            parser.offset = start
            return (false, 0)
        }
        if (result == MAXABSVAL_I64) {
            return (true, MINVAL_I64)
        }
        return (true, -Int64(result))
    }
    if (result > MAXVAL_I64) {
        parser.offset = start
        return (false, 0)
    }
    return (true, Int64(result))
}

func parseJsonNumberSlow(parser: JsonParser): JsonValue {
    var isFloat = false
    let leftIndex = parser.offset
    var rightIndex = parser.offset
    parseSign(parser)
    let numSystem = parseNumberSystem(parser)
    let isNumber = checkNumberSystem(numSystem)
    parseInteger(parser, isNumber)
    isFloat = parseDecimal(parser, numSystem)
    if (isFloat) {
        parseExponent(parser, numSystem)
    } else {
        isFloat = parseExponent(parser, numSystem)
    }
    rightIndex = parser.offset
    unsafe {
        if (isFloat) {
            let ptr = acquireArrayRawData(parser.data)
            let value = CJ_JSON_ParseFloat64(ptr.pointer, leftIndex, rightIndex)
            releaseArrayRawData(ptr)
            return JsonFloat(ensureFiniteJsonFloat(value), parser.data, leftIndex, rightIndex - leftIndex)
        }
    }
    let numStr = unsafe { String.fromUtf8Unchecked(parser.data[leftIndex..rightIndex]) }
    return JsonInt(Int64.parse(numStr))
}

// Scan a standard JSON decimal once. The old path first scanned every token
// as an integer and then restored parser.offset for fractional/exponent
// tokens, causing all floating-point values to be scanned a second time by
// parseJsonNumberSlow. A false result restores the original offset so callers
// can preserve the extension-number and overflow slow paths unchanged.
func tryParseJsonDecimalNumber(parser: JsonParser): (Bool, Int64, Int64, Bool, UInt64, Bool) {
    let start = parser.offset
    var negative = false
    if (parser.data[parser.offset] == b'-') {
        negative = true
        parser.offset++
        if (parser.offset >= parser.size) {
            parser.offset = start
            return (false, start, start, false, 0, negative)
        }
    }

    let first = parser.data[parser.offset]
    if (first < b'0' || first > b'9') {
        parser.offset = start
        return (false, start, start, false, 0, negative)
    }
    if (first == b'0' && parser.offset + 1 < parser.size) {
        let next = parser.data[parser.offset + 1]
        if (next >= b'0' && next <= b'9') {
            throw JsonException()
        }
        if (next == b'b' || next == b'B' || next == b'o' || next == b'O' || next == b'x' ||
            next == b'X' || next == b'd' || next == b'D') {
            parser.offset = start
            return (false, start, start, false, 0, negative)
        }
    }

    var integerValue: UInt64 = 0
    var overflow = false
    while (parser.offset < parser.size) {
        let next = parser.data[parser.offset]
        if (next < b'0' || next > b'9') {
            break
        }
        let digit = UInt64(next - b'0')
        if (!overflow) {
            if (integerValue > DECIMAL_OVERFLOW_LIMIT_UI64) {
                overflow = true
            } else {
                let multiplied = integerValue * 10
                if (MAXVAL_UI64 - multiplied < digit) {
                    overflow = true
                } else {
                    integerValue = multiplied + digit
                }
            }
        }
        parser.offset++
    }

    var isFloat = false
    if (parser.offset < parser.size && parser.data[parser.offset] == b'.') {
        isFloat = true
        parser.offset++
        let fractionStart = parser.offset
        while (parser.offset < parser.size) {
            let next = parser.data[parser.offset]
            if (next < b'0' || next > b'9') {
                break
            }
            parser.offset++
        }
        if (parser.offset == fractionStart) {
            throw JsonException()
        }
    }
    if (parser.offset < parser.size &&
        (parser.data[parser.offset] == b'e' || parser.data[parser.offset] == b'E')) {
        isFloat = true
        parser.offset++
        if (parser.offset < parser.size &&
            (parser.data[parser.offset] == b'+' || parser.data[parser.offset] == b'-')) {
            parser.offset++
        }
        let exponentStart = parser.offset
        while (parser.offset < parser.size) {
            let next = parser.data[parser.offset]
            if (next < b'0' || next > b'9') {
                break
            }
            parser.offset++
        }
        if (parser.offset == exponentStart) {
            throw JsonException()
        }
    }

    let end = parser.offset
    if (!isFloat) {
        if (overflow || (negative && integerValue > MAXABSVAL_I64) ||
            (!negative && integerValue > MAXVAL_I64)) {
            parser.offset = start
            return (false, start, start, false, 0, negative)
        }
    }
    return (true, start, end, isFloat, integerValue, negative)
}

func parseJsonNumber(parser: JsonParser): JsonValue {
    let (success, start, end, isFloat, integerValue, negative) = tryParseJsonDecimalNumber(parser)
    if (!success) {
        return parseJsonNumberSlow(parser)
    }
    if (!isFloat) {
        if (negative && integerValue == MAXABSVAL_I64) {
            return JsonInt(MINVAL_I64)
        }
        let result = if (negative) {
            -Int64(integerValue)
        } else {
            Int64(integerValue)
        }
        return JsonInt(result)
    }
    unsafe {
        let input = acquireArrayRawData(parser.data)
        let value = CJ_JSON_ParseFloat64(input.pointer, start, end)
        releaseArrayRawData(input)
        return JsonFloat(ensureFiniteJsonFloat(value), parser.data, start, end - start)
    }
}

func parseSign(parser: JsonParser): Unit {
    if (parser.offset < parser.size && parser.data[parser.offset] == b'-') {
        parser.offset++
    }
}

func parseNumberSystem(parser: JsonParser): NumberSystem {
    if (requireCurrentByte(parser) == b'0') {
        parser.offset++
        if (parser.offset >= parser.size) {
            parser.offset--
            return Decimal
        }
        match (parser.data[parser.offset]) {
            case 'b' | 'B' =>
                parser.offset++
                return Binary
            case 'o' | 'O' =>
                parser.offset++
                return Octal
            case 'x' | 'X' =>
                parser.offset++
                return Hex
            case _ => parser.offset--
        }
    }
    return Decimal
}

func checkNumberSystem(numSystem: NumberSystem): (Byte) -> Bool {
    match (numSystem) {
        case Binary => return {byte: Byte => byte >= b'0' && byte <= b'1'}
        case Octal => return {byte: Byte => byte >= b'0' && byte <= b'7'}
        case Decimal => return {byte: Byte => byte >= b'0' && byte <= b'9'}
        case Hex => return {
            byte: Byte => byte >= b'0' && byte <= b'9' || byte >= b'a' &&
                byte <= b'f' || byte >= b'A' && byte <= b'F'
        }
    }
}

func parseInteger(parser: JsonParser, isNumber: (Byte) -> Bool): Unit {
    var nextByte = requireCurrentByte(parser)
    var hasNumber = false
    if (nextByte == b'0') {
        parser.offset++
        return
    }
    while (isNumber(nextByte)) {
        hasNumber = true
        parser.offset++
        if (parser.offset >= parser.size) {
            return
        }
        nextByte = parser.data[parser.offset]
    }
    if (!hasNumber) {
        throw JsonException()
    }
}

func parseDecimal(parser: JsonParser, numSystem: NumberSystem): Bool {
    if (parser.offset >= parser.size) {
        return false
    }
    if (parser.data[parser.offset] != b'.') {
        return false
    }
    match (numSystem) {
        case Decimal => ()
        case _ => throw JsonException()
    }
    parser.offset++
    return parseDigit(parser)
}

func parseExponent(parser: JsonParser, numSystem: NumberSystem): Bool {
    if (parser.offset >= parser.size) {
        return false
    }
    var nextByte = requireCurrentByte(parser)
    if (nextByte != b'e' && nextByte != b'E') {
        return false
    }
    match (numSystem) {
        case Decimal => ()
        case _ => throw JsonException()
    }
    parser.offset++
    nextByte = requireCurrentByte(parser)
    if (nextByte == b'+' || nextByte == b'-') {
        parser.offset++
    }
    return parseDigit(parser)
}

func parseDigit(parser: JsonParser): Bool {
    var nextByte = requireCurrentByte(parser)
    var hasNumber = false
    while (nextByte >= b'0' && nextByte <= b'9') {
        hasNumber = true
        parser.offset++
        if (parser.offset >= parser.size) {
            return true
        }
        nextByte = parser.data[parser.offset]
    }
    if (!hasNumber) {
        throw JsonException()
    }
    return true
}

func isHexNum(char: UInt8): Bool {
    if (!((char >= b'0' && char <= b'9') || (char >= b'a' && char <= b'f') ||
        (char >= b'A' && char <= b'F'))) {
        return false
    }
    return true
}

func parseJsonString(parser: JsonParser): JsonString {
    let value = parseJsonStringValue(parser)
    return JsonString(value)
}

func parseJsonStringValue(parser: JsonParser): String {
    if (requireCurrentByte(parser) != b'\"') {
        throw JsonException("Fail to parseJsonString")
    }
    parser.offset++
    let start = parser.offset
    // Most JSON keys and values in the DOM benchmark are short and contain no
    // escape. Keep the scan state in locals so the common path only publishes
    // the parser offset once, after finding the closing quote.
    let size = parser.size
    var offset = start
    while (offset < size) {
        let next = parser.data[offset]
        if (next == b'\"') {
            parser.offset = offset + 1
            // Keep the established field-based raw-data expression: the
            // String retains this Array's storage after parser returns.
            return unsafe { String.withRawData(parser.data[start..(parser.offset - 1)]) }
        }
        if (next == b'\\') {
            parser.offset = offset
            break
        }
        if (next < 0x20) {
            parser.offset = offset
            throw JsonException()
        }
        if (parser.integratedUtf8Validation && next >= 0x80) {
            offset += validateUtf8SequenceAt(parser, offset)
        } else {
            offset++
        }
    }

    if (offset >= size) {
        parser.offset = offset
        throw JsonException()
    }

    return finishEscapedJsonString(parser, start)
}

func parseJsonObjectKey(parser: JsonParser): String {
    if (requireCurrentByte(parser) != b'\"') {
        throw JsonException("Fail to parseJsonString")
    }
    parser.offset++
    let start = parser.offset
    parser.lastStringHtmlSafe = false
    let size = parser.size
    var offset = start
    var htmlSafe = true
    while (offset < size) {
        let next = parser.data[offset]
        if (next == b'\"') {
            parser.offset = offset + 1
            parser.lastStringHtmlSafe = htmlSafe
            return unsafe { String.withRawData(parser.data[start..(parser.offset - 1)]) }
        }
        if (next == b'\\') {
            parser.offset = offset
            break
        }
        if (next < 0x20) {
            parser.offset = offset
            throw JsonException()
        }
        if (next == 127 || next == b'&') {
            htmlSafe = false
        }
        if (parser.integratedUtf8Validation && next >= 0x80) {
            offset += validateUtf8SequenceAt(parser, offset)
        } else {
            offset++
        }
    }

    if (offset >= size) {
        parser.offset = offset
        throw JsonException()
    }

    return finishEscapedJsonString(parser, start)
}

func finishEscapedJsonString(parser: JsonParser, start: Int64): String {
    var next = parser.data[parser.offset]
    var tmpStart = start
    while (next != b'\"') {
        if (next == b'\\') {
            ensureStrCache(parser).add(all: parser.data[tmpStart..parser.offset])
            parser.offset++
            handleEscape(parser)
            tmpStart = parser.offset + 1
        } else if (next < 0x20) {
            throw JsonException()
        } else if (parser.integratedUtf8Validation && next >= 0x80) {
            parser.offset += validateUtf8SequenceAt(parser, parser.offset)
            next = requireCurrentByte(parser)
            continue
        }
        parser.offset++
        next = requireCurrentByte(parser)
    }
    parser.offset++
    let strCache = ensureStrCache(parser)
    strCache.add(all: parser.data[tmpStart..parser.offset - 1])
    let res = unsafe { String.fromUtf8Unchecked(strCache.getRawArray()[0..strCache.size]) }
    strCache.clear()
    return res
}

func getNextHexNum(parser: JsonParser): Byte {
    parser.offset++
    let byte = requireCurrentByte(parser)
    if (!isHexNum(byte)) {
        throw JsonException()
    }
    return byte
}

func handleEscape(parser: JsonParser): Unit {
    match (requireCurrentByte(parser)) {
        case '\"' => ensureStrCache(parser).add(b'\"')
        case '\\' => ensureStrCache(parser).add(b'\\')
        case '/' => ensureStrCache(parser).add(b'/')
        case 'b' => ensureStrCache(parser).add(b'\b')
        case 'f' => ensureStrCache(parser).add(b'\f')
        case 'n' => ensureStrCache(parser).add(b'\n')
        case 'r' => ensureStrCache(parser).add(b'\r')
        case 't' => ensureStrCache(parser).add(b'\t')
        case 'u' =>
            let byte1 = getNextHexNum(parser)
            let byte2 = getNextHexNum(parser)
            let byte3 = getNextHexNum(parser)
            let byte4 = getNextHexNum(parser)
            let arr: Array<Byte> = [b'\'', b'\\', b'u', b'{',
                byte1, byte2, byte3, byte4, b'}', b'\'']
            try {
                let chr = unsafe { Rune.parse(String.fromUtf8Unchecked(arr)) }
                if (UInt32(chr) <= 127) {
                    ensureStrCache(parser).add(UInt8(UInt32(chr)))
                } else {
                    let str = chr.toString()
                    unsafe { ensureStrCache(parser).add(all: str.rawData()) }
                }
            } catch (_: Exception) {
                parser.offset++
                if (requireCurrentByte(parser) != b'\\') {
                    throw JsonException()
                }
                parser.offset++
                if (requireCurrentByte(parser) != b'u') {
                    throw JsonException()
                }
                let byte5 = getNextHexNum(parser)
                let byte6 = getNextHexNum(parser)
                let byte7 = getNextHexNum(parser)
                let byte8 = getNextHexNum(parser)
                let str1 = unsafe { String.fromUtf8Unchecked([b'0', b'x', byte1, byte2, byte3, byte4]) }
                let str2 = unsafe { String.fromUtf8Unchecked([b'0', b'x', byte5, byte6, byte7, byte8]) }
                let rawNum1 = UInt32.parse(str1)
                let rawNum2 = UInt32.parse(str2)
                if (!isHighSurrogate(rawNum1) || !isLowSurrogate(rawNum2)) {
                    throw JsonException()
                }
                let num1 = rawNum1 & 0b0000001111111111
                let num2 = rawNum2 & 0b0000001111111111
                let str = Rune((((UInt32(num1)) << 10) | (UInt32(num2))) + 0x10000).toString()
                unsafe { ensureStrCache(parser).add(all: str.rawData()) }
            }
        case _ => throw JsonException("Fail to parseJsonString")
    }
}
