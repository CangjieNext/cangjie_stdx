import std.io.*
import stdx.encoding.json.stream.*

func ensure(value: Bool): Unit {
    if (!value) {
        throw Exception("raw JSON copy assertion failed")
    }
}

func largeJsonString(): Array<Byte> {
    let bytes = Array<Byte>(8_194, repeat: b'a')
    bytes[0] = b'"'
    bytes[bytes.size - 1] = b'"'
    return bytes
}

func testRawBytesAndSkipAcrossBuffers(): Unit {
    let raw = largeJsonString()
    let output = ByteBuffer()
    let writer = JsonWriter(output)
    writer.startObject()
    writer.writeName("blob")
    writer.writeRawBytes(raw, 0, raw.size)
    writer.endObject()
    writer.flush()

    let expected = ByteBuffer()
    expected.write(##"{"blob":"##.toArray())
    expected.write(raw)
    expected.write(##"}"##.toArray())
    if (String.fromUtf8(readToEnd(output)) != String.fromUtf8(readToEnd(expected))) {
        throw Exception("bulk raw JSON write assertion failed")
    }

    let input = ByteBuffer()
    input.write(##"{"payload":{"items":["##.toArray())
    input.write(raw)
    input.write(##",{"escaped":"a\\\"b","nested":[1,2,3]}]},"server_ok":true}"##.toArray())
    let reader = JsonReader(input)
    reader.startObject()
    if (reader.readName() != "payload") {
        throw Exception("skip root name assertion failed")
    }
    reader.skip()
    if (reader.readName() != "server_ok") {
        throw Exception("skip did not reach server_ok")
    }
    if (!reader.readValue<Bool>()) {
        throw Exception("skip server_ok assertion failed")
    }
    reader.endObject()
}

func testRawNameAndScalarCopy(): Unit {
    let input = ByteBuffer()
    input.write(##"{"payload":""##.toArray())
    input.write(Array<Byte>(8_194, repeat: b'a'))
    input.write(##"","ratio":-12.5e2,"enabled":true,"empty":null}"##.toArray())

    let output = ByteBuffer()
    let reader = JsonReader(input)
    let writer = JsonWriter(output)
    let payload = "payload".toArray()
    let ratio = "ratio".toArray()
    let enabled = "enabled".toArray()
    let empty = "empty".toArray()

    reader.startObject()
    writer.startObject()
    while (reader.peek() != Some(EndObject)) {
        if (reader.nextNameEquals(payload) || reader.nextNameEquals(ratio) ||
            reader.nextNameEquals(enabled) || reader.nextNameEquals(empty)) {
            reader.copyNameTo(writer)
            reader.copyValueTo(writer)
        } else {
            throw Exception("unexpected field name")
        }
    }
    reader.endObject()
    writer.endObject()
    writer.flush()

    let expected = ByteBuffer()
    expected.write(##"{"payload":""##.toArray())
    expected.write(Array<Byte>(8_194, repeat: b'a'))
    expected.write(##"","ratio":-12.5e2,"enabled":true,"empty":null}"##.toArray())
    ensure(String.fromUtf8(readToEnd(output)) == String.fromUtf8(readToEnd(expected)))
}

func testFloatReadWrite(): Unit {
    let input = ByteBuffer()
    input.write("[-12.5,0.125,3e2]".toArray())
    let reader = JsonReader(input)
    let output = ByteBuffer()
    let writer = JsonWriter(output)
    reader.startArray()
    writer.startArray()
    writer.writeValue<Float64>(reader.readValue<Float64>())
    writer.writeValue<Float64>(reader.readValue<Float64>())
    writer.writeValue<Float64>(reader.readValue<Float64>())
    reader.endArray()
    writer.endArray()
    writer.flush()
    ensure(String.fromUtf8(readToEnd(output)) == "[-12.5,0.125,300]")
}

func testShortestFloatWritePreservesSmallFiniteValue(): Unit {
    let value = 0.0000001
    let output = ByteBuffer()
    let writer = JsonWriter(output)
    writer.writeValue<Float64>(value)
    writer.flush()

    let text = String.fromUtf8(readToEnd(output))
    ensure(text != "0")
    let input = ByteBuffer(text.toArray())
    let reader = JsonReader(input)
    ensure(reader.readValue<Float64>().toBits() == value.toBits())
}

func testRawStaticNameWrite(): Unit {
    let output = ByteBuffer()
    let writer = JsonWriter(output)
    let name = "answer".toArray()
    writer.startObject()
    writer.writeRawName(name, 0, name.size).writeValue<Int64>(42)
    writer.endObject()
    writer.flush()
    ensure(String.fromUtf8(readToEnd(output)) == ##"{"answer":42}"##)
}

func testIntegerWriteBoundaries(): Unit {
    let output = ByteBuffer()
    let writer = JsonWriter(output)
    let minInt64 = -9223372036854775807 - 1
    writer.startArray()
    writer.writeValue<Int64>(0)
    writer.writeValue<Int64>(9)
    writer.writeValue<Int64>(10)
    writer.writeValue<Int64>(99)
    writer.writeValue<Int64>(100)
    writer.writeValue<Int64>(999)
    writer.writeValue<Int64>(1000)
    writer.writeValue<Int64>(9999)
    writer.writeValue<Int64>(10000)
    writer.writeValue<Int64>(9223372036854775807)
    writer.writeValue<Int64>(minInt64)
    writer.endArray()
    writer.flush()
    ensure(
        String.fromUtf8(readToEnd(output)) ==
        "[0,9,10,99,100,999,1000,9999,10000,9223372036854775807,-9223372036854775808]"
    )
}

func testInt64ArrayBatchWrite(): Unit {
    let values = [Int64(-100), 0, 9, 10, 999, 1000, 9223372036854775807]
    let compactOutput = ByteBuffer()
    let compactWriter = JsonWriter(compactOutput)
    compactWriter.writeInt64Array(values)
    compactWriter.flush()
    let compactText = String.fromUtf8(readToEnd(compactOutput))
    ensure(
        compactText ==
        "[-100,0,9,10,999,1000,9223372036854775807]"
    )

    let prettyOutput = ByteBuffer()
    let prettyWriter = JsonWriter(prettyOutput)
    prettyWriter.writeConfig = WriteConfig.pretty
    prettyWriter.writeInt64Array(values)
    prettyWriter.flush()
    let prettyText = String.fromUtf8(readToEnd(prettyOutput))
    ensure(
        prettyText ==
        "[\n    -100,\n    0,\n    9,\n    10,\n    999,\n    1000,\n    9223372036854775807\n]"
    )
}

func testOtherIntegerArrayBatchWrite(): Unit {
    let signedOutput = ByteBuffer()
    let signedWriter = JsonWriter(signedOutput)
    signedWriter.writeInt32Array([Int32(-2147483648), 0, 2147483647])
    signedWriter.flush()
    ensure(String.fromUtf8(readToEnd(signedOutput)) == "[-2147483648,0,2147483647]")

    let unsignedOutput = ByteBuffer()
    let unsignedWriter = JsonWriter(unsignedOutput)
    unsignedWriter.writeUInt32Array([UInt32(0), 4294967295])
    unsignedWriter.flush()
    ensure(String.fromUtf8(readToEnd(unsignedOutput)) == "[0,4294967295]")

    let wideUnsignedOutput = ByteBuffer()
    let wideUnsignedWriter = JsonWriter(wideUnsignedOutput)
    wideUnsignedWriter.writeUInt64Array([UInt64(0), 18446744073709551615])
    wideUnsignedWriter.flush()
    ensure(String.fromUtf8(readToEnd(wideUnsignedOutput)) == "[0,18446744073709551615]")
}

func testByteBufferRangeWriteWithoutGrowth(): Unit {
    let output = ByteBuffer(128)
    output.write("xxhello!".toArray(), 2, 5)
    ensure(output.capacity == 128)
    ensure(String.fromUtf8(readToEnd(output)) == "hello")
}

func testDiscardRemainingDrainsUnderlyingInput(): Unit {
    let input = ByteBuffer()
    input.write(##"{"server_ok":true,"payload":"##.toArray())
    input.write(Array<Byte>(8_194, repeat: b'a'))
    input.write(##""}"##.toArray())
    let reader = JsonReader(input)
    let serverOk = "server_ok".toArray()

    reader.startObject()
    ensure(reader.nextNameEquals(serverOk))
    reader.skipName()
    ensure(reader.readValue<Bool>())
    reader.discardRemaining()
    ensure(input.remainLength == 0)
}

main() {
    let input = ByteBuffer()
    input.write(##"{"raw":{"nested":[1,true,null]},"tail":7}"##.toArray())
    let output = ByteBuffer()
    let reader = JsonReader(input)
    let writer = JsonWriter(output)

    reader.startObject()
    writer.startObject()
    let rawName = reader.readName()
    writer.writeName(rawName)
    reader.copyValueTo(writer)
    let tailName = reader.readName()
    writer.writeName(tailName)
    reader.copyValueTo(writer)
    reader.endObject()
    writer.endObject()
    writer.flush()

    ensure(String.fromUtf8(readToEnd(output)) == ##"{"raw":{"nested":[1,true,null]},"tail":7}"##)
    testRawBytesAndSkipAcrossBuffers()
    testRawNameAndScalarCopy()
    testFloatReadWrite()
    testShortestFloatWritePreservesSmallFiniteValue()
    testRawStaticNameWrite()
    testIntegerWriteBoundaries()
    testInt64ArrayBatchWrite()
    testOtherIntegerArrayBatchWrite()
    testByteBufferRangeWriteWithoutGrowth()
    testDiscardRemainingDrainsUnderlyingInput()
}
