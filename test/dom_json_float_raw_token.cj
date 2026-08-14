import stdx.encoding.json.*

func ensure(value: Bool): Unit {
    if (!value) {
        throw Exception("DOM JSON float raw-token assertion failed")
    }
}

func testParsedFloatTokenIsPreserved(): Unit {
    let source = "{\"v\":1.2300e+03,\"z\":-0.0}"
    let result = JsonValue.fromStr(source).toString()
    ensure(result == source)
}

func testExplicitOutputCapacityPreservesJson(): Unit {
    let source = "{\"v\":1.2300e+03,\"z\":-0.0}"
    let result = JsonValue.fromStr(source).toStringWithCapacity(source.size + 64)
    ensure(result == source)
}

main() {
    testParsedFloatTokenIsPreserved()
    testExplicitOutputCapacityPreservesJson()
}
