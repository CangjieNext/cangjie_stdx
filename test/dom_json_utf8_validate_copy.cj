import stdx.encoding.json.*

@FastNative
foreign func CJ_JSON_ValidateUtf8AndCopy(
    input: CPointer<UInt8>, output: CPointer<UInt8>, size: Int64
): Bool

func ensure(value: Bool, message: String): Unit {
    if (!value) {
        throw Exception(message)
    }
}

func testValidateAndCopyAcceptsStrictUtf8(): Unit {
    let input: Array<UInt8> = "{\"message\":\"hello, 世界 😀\"}".toArray()
    let output = Array<UInt8>(input.size, repeat: 0)
    let accepted = unsafe {
        let inputHandle = acquireArrayRawData(input)
        let outputHandle = acquireArrayRawData(output)
        let result = CJ_JSON_ValidateUtf8AndCopy(inputHandle.pointer, outputHandle.pointer, input.size)
        releaseArrayRawData(outputHandle)
        releaseArrayRawData(inputHandle)
        result
    }
    ensure(accepted, "valid UTF-8 rejected")
    for (i in 0..input.size) {
        ensure(input[i] == output[i], "validated bytes were not copied")
    }
}

func testValidateAndCopyRejectsMalformedUtf8(): Unit {
    let invalidSequences: Array<Array<UInt8>> = [
        [0x80],                 // standalone continuation byte
        [0xc0, 0x80],           // overlong NUL
        [0xe0, 0x80, 0x80],     // overlong three-byte sequence
        [0xed, 0xa0, 0x80],     // UTF-16 surrogate
        [0xf0, 0x80, 0x80, 0x80], // overlong four-byte sequence
        [0xf4, 0x90, 0x80, 0x80], // above U+10FFFF
        [0xe4, 0xb8]            // truncated sequence
    ]
    for (input in invalidSequences) {
        let output = Array<UInt8>(input.size, repeat: 0)
        let accepted = unsafe {
            let inputHandle = acquireArrayRawData(input)
            let outputHandle = acquireArrayRawData(output)
            let result = CJ_JSON_ValidateUtf8AndCopy(inputHandle.pointer, outputHandle.pointer, input.size)
            releaseArrayRawData(outputHandle)
            releaseArrayRawData(inputHandle)
            result
        }
        ensure(!accepted, "invalid UTF-8 accepted")
    }
}

func testDomDoesNotAliasCallerBytes(): Unit {
    let input: Array<Byte> = "{\"message\":\"stable\"}".toArray()
    let value = JsonValue.fromUtf8Bytes(input)
    input[12] = b'X'
    let message = value.asObject().get("message").getOrThrow().asString().getValue()
    ensure(message == "stable", "parsed DOM aliases caller bytes")
}

func testOwnedDomRetainsCallerBytes(): Unit {
    let input: Array<Byte> = "{\"message\":\"stable\"}".toArray()
    let value = JsonValue.fromOwnedUtf8Bytes(input)
    let original = value.asObject().get("message").getOrThrow().asString().getValue()
    ensure(original == "stable", "owned DOM parsed the wrong string")
    input[12] = b'X'
    let mutated = value.asObject().get("message").getOrThrow().asString().getValue()
    ensure(mutated == "Xtable", "owned DOM did not retain the supplied backing array")
}

func testInvalidBytesStillThrowJsonException(): Unit {
    let invalid: Array<Byte> = [b'{', b'\"', 0xc0, 0x80, b'\"', b'}']
    var rejected = false
    try {
        let _ = JsonValue.fromUtf8Bytes(invalid)
    } catch (e: JsonException) {
        rejected = e.message == "Json byte array is not valid UTF-8."
    }
    ensure(rejected, "invalid bytes did not preserve JsonException semantics")
}

func testOwnedDomRejectsMalformedUtf8(): Unit {
    let invalidDocuments: Array<Array<Byte>> = [
        [b'{', b'\"', b'v', b'\"', b':', b'\"', 0x80, b'\"', b'}'],
        [b'{', b'\"', b'v', b'\"', b':', b'\"', 0xc0, 0x80, b'\"', b'}'],
        [b'{', b'\"', b'v', b'\"', b':', b'\"', 0xed, 0xa0, 0x80, b'\"', b'}'],
        [b'{', b'\"', b'v', b'\"', b':', b'\"', b'\\', b'n', 0xf4, 0x90, 0x80, 0x80, b'\"', b'}'],
        [b'{', b'\"', 0xe4, 0xb8, b'\"', b':', b'1', b'}'],
        [b'n', b'u', b'l', b'l', 0xc0, 0x80]
    ]
    for (invalid in invalidDocuments) {
        var rejected = false
        try {
            let _ = JsonValue.fromOwnedUtf8Bytes(invalid)
        } catch (e: JsonException) {
            rejected = e.message == "Json byte array is not valid UTF-8."
        }
        ensure(rejected, "owned DOM accepted invalid UTF-8 or changed its error message")
    }
}

func testOwnedDomAcceptsValidUtf8(): Unit {
    let value = JsonValue.fromOwnedUtf8Bytes("{\"message\":\"hello, 世界 😀\"}".toArray())
    let message = value.asObject().get("message").getOrThrow().asString().getValue()
    ensure(message == "hello, 世界 😀", "owned DOM rejected or changed valid UTF-8")
}

func testOwnedDomRejectsUnescapedControl(): Unit {
    let rawNewline: Array<Byte> = [
        b'{', b'\"', b'v', b'\"', b':', b'\"', b'a', 0x0a, b'b', b'\"', b'}'
    ]
    var rejected = false
    try {
        let _ = JsonValue.fromOwnedUtf8Bytes(rawNewline)
    } catch (_: JsonException) {
        rejected = true
    }
    ensure(rejected, "owned DOM accepted an unescaped control byte")
}

main() {
    testValidateAndCopyAcceptsStrictUtf8()
    testValidateAndCopyRejectsMalformedUtf8()
    testDomDoesNotAliasCallerBytes()
    testOwnedDomRetainsCallerBytes()
    testInvalidBytesStillThrowJsonException()
    testOwnedDomRejectsMalformedUtf8()
    testOwnedDomAcceptsValidUtf8()
    testOwnedDomRejectsUnescapedControl()
    println("PASS dom_json_utf8_validate_copy")
}
