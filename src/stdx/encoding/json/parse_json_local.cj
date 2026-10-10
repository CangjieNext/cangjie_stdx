package stdx.encoding.json

import std.collection.*
import std.convert.*

exclave func parseString(str: String @local!): JsonValue @local! {
    if (str.size == 0) {
        throw JsonException("Json String is empty!")
    }
    let parser = JsonParser(str) @local!
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

private exclave func parseJson(parser: JsonParser @local!): JsonValue @local! {
    skipWhiteSpace(parser)
    let start = requireCurrentByte(parser)
    match {
        case start == b'{' => return parseNestedJson(parser, parseJsonObject)
        case start == b'[' => return parseNestedJson(parser, parseJsonArray)
        case start == b'n' => return parseJsonNull(parser)
        case start == b't' => return parseJsonTrue(parser)
        case start == b'f' => return parseJsonFalse(parser)
        case start == b'\"' => return parseJsonString(parser)
        case start >= b'0' && start <= b'9' || start == b'-' => return parseJsonNumber(parser)
        case _ => throw JsonException()
    }
}

private exclave func parseNestedJson(parser: JsonParser @local!, block: (JsonParser @local!) -> JsonValue @local!)
    : JsonValue @local! {
    parser.depth++
    if (parser.depth > MAX_JSON_PARSE_DEPTH) {
        throw JsonException("Json nested depth exceeds ${MAX_JSON_PARSE_DEPTH}.")
    }
    try {
        return block(parser)
    } finally {
        parser.depth--
    }
}

private exclave func parseJsonObject(parser: JsonParser @local!): JsonObject @local! {
    parser.offset++
    skipWhiteSpace(parser)
    let obj = JsonObject(INITIAL_JSON_OBJECT_CAPACITY) @local!
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
        let key = parseJsonString(parser)
        skipWhiteSpace(parser)
        if (requireCurrentByte(parser) != b':') {
            throw JsonException()
        }
        parser.offset++
        let value = parseJson(parser)
        skipWhiteSpace(parser)
        obj.put(key.getValue(), value)
    }
    parser.offset++
    return obj
}

private exclave func parseJsonArray(parser: JsonParser @local!): JsonArray @local! {
    parser.offset++
    skipWhiteSpace(parser)
    let arr = JsonArray(INITIAL_JSON_ARRAY_CAPACITY) @local!
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

private exclave func parseJsonNull(parser: JsonParser @local!): JsonNull @local! {
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
    return JsonNull()
}

private exclave func parseJsonTrue(parser: JsonParser @local!): JsonBool @local! {
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
    return JsonBool(true)
}

private exclave func parseJsonFalse(parser: JsonParser @local!): JsonBool @local! {
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
    return JsonBool(false)
}

private exclave func tryParseJsonIntFast(parser: JsonParser @local!): (Bool, Int64) {
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

private exclave func parseJsonNumberSlow(parser: JsonParser @local!): JsonValue @local! {
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
            return JsonFloat(ensureFiniteJsonFloat(value))
        }
    }
    let numStr = unsafe { String.fromUtf8UncheckedLocal(parser.data[leftIndex..rightIndex]) }
    return JsonInt(Int64.parse(numStr))
}

private exclave func parseJsonNumber(parser: JsonParser @local!): JsonValue @local! {
    let (success, value) = tryParseJsonIntFast(parser)
    if (success) {
        return JsonInt(value)
    }
    return parseJsonNumberSlow(parser)
}

private exclave func parseSign(parser: JsonParser @local!): Unit {
    if (parser.offset < parser.size && parser.data[parser.offset] == b'-') {
        parser.offset++
    }
}

private exclave func parseNumberSystem(parser: JsonParser @local!): NumberSystem {
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

private exclave func parseInteger(parser: JsonParser @local!, isNumber: (Byte) -> Bool): Unit {
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

private exclave func parseDecimal(parser: JsonParser @local!, numSystem: NumberSystem): Bool {
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

private exclave func parseExponent(parser: JsonParser @local!, numSystem: NumberSystem): Bool {
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

private exclave func parseDigit(parser: JsonParser @local!): Bool {
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

private exclave func parseJsonString(parser: JsonParser @local!): JsonString @local! {
    if (requireCurrentByte(parser) != b'\"') {
        throw JsonException("Fail to parseJsonString")
    }
    parser.offset++
    let start = parser.offset

    while (parser.offset < parser.size) {
        let next = parser.data[parser.offset]
        if (next == b'\"') {
            parser.offset++
            return unsafe { JsonString(String.fromUtf8UncheckedLocal(parser.data[start..(parser.offset - 1)])) @local! }
        }
        if (next == b'\\') {
            break
        }
        parser.offset++
    }

    if (parser.offset >= parser.size) {
        throw JsonException()
    }

    var next = parser.data[parser.offset]
    var tmpStart = start
    while (next != b'\"') {
        if (next == b'\\') {
            // Array @local! has no iterator; copy by index.
            var i = tmpStart
            while (i < parser.offset) {
                parser.strCache.add(parser.data[i])
                i++
            }
            parser.offset++
            handleEscape(parser)
            tmpStart = parser.offset + 1
        }
        parser.offset++
        next = requireCurrentByte(parser)
    }
    parser.offset++
    var j = tmpStart
    while (j < parser.offset - 1) {
        parser.strCache.add(parser.data[j])
        j++
    }
    let res = unsafe { JsonString(String.fromUtf8UncheckedLocal(parser.strCache.getRawArray()[0..parser.strCache.size])) @local! }
    parser.strCache.clear()
    return res
}

private exclave func getNextHexNum(parser: JsonParser @local!): Byte {
    parser.offset++
    let byte = requireCurrentByte(parser)
    if (!isHexNum(byte)) {
        throw JsonException()
    }
    return byte
}

private exclave func handleEscape(parser: JsonParser @local!): Unit {
    match (requireCurrentByte(parser)) {
        case '\"' => parser.strCache.add(b'\"')
        case '\\' => parser.strCache.add(b'\\')
        case '/' => parser.strCache.add(b'/')
        case 'b' => parser.strCache.add(b'\b')
        case 'f' => parser.strCache.add(b'\f')
        case 'n' => parser.strCache.add(b'\n')
        case 'r' => parser.strCache.add(b'\r')
        case 't' => parser.strCache.add(b'\t')
        case 'u' =>
            let byte1 = getNextHexNum(parser)
            let byte2 = getNextHexNum(parser)
            let byte3 = getNextHexNum(parser)
            let byte4 = getNextHexNum(parser)
            let arr: Array<Byte> @local! = [b'\'', b'\\', b'u', b'{',
                byte1, byte2, byte3, byte4, b'}', b'\'']
            try {
                // Rune.parse has no local! overload yet; clone escape text to ~local for parse only.
                let chr = unsafe { Rune.parse(String.fromUtf8Unchecked(arr)) }
                if (UInt32(chr) <= 127) {
                    parser.strCache.add(UInt8(UInt32(chr)))
                } else {
                    let str = chr.toString()
                    unsafe {
                        let raw = str.rawData()
                        var k = 0
                        while (k < raw.size) {
                            parser.strCache.add(raw[k])
                            k++
                        }
                    }
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
                let hex1: Array<Byte> @local! = [b'0', b'x', byte1, byte2, byte3, byte4]
                let hex2: Array<Byte> @local! = [b'0', b'x', byte5, byte6, byte7, byte8]
                let str1 = unsafe { String.fromUtf8UncheckedLocal(hex1) }
                let str2 = unsafe { String.fromUtf8UncheckedLocal(hex2) }
                let rawNum1 = UInt32.parse(str1)
                let rawNum2 = UInt32.parse(str2)
                if (!isHighSurrogate(rawNum1) || !isLowSurrogate(rawNum2)) {
                    throw JsonException()
                }
                let num1 = rawNum1 & 0b0000001111111111
                let num2 = rawNum2 & 0b0000001111111111
                let str = Rune((((UInt32(num1)) << 10) | (UInt32(num2))) + 0x10000).toString()
                unsafe {
                    let raw = str.rawData()
                    var k = 0
                    while (k < raw.size) {
                        parser.strCache.add(raw[k])
                        k++
                    }
                }
            }
        case _ => throw JsonException("Fail to parseJsonString")
    }
}
