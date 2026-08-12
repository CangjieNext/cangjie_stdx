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

main() {
    testValidateAndCopyAcceptsStrictUtf8()
    testValidateAndCopyRejectsMalformedUtf8()
    testDomDoesNotAliasCallerBytes()
    testInvalidBytesStillThrowJsonException()
    println("PASS dom_json_utf8_validate_copy")
}
