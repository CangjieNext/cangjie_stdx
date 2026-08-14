import stdx.encoding.json.*

func ensure(value: Bool): Unit {
    if (!value) {
        throw Exception("short JSON string escape assertion failed")
    }
}

func testShortStrings(): Unit {
    ensure(JsonValue.fromStr("\"plain-short-value\"").toString() == "\"plain-short-value\"")
    ensure(JsonValue.fromStr("\"0123456789abcdef\"").toString() == "\"0123456789abcdef\"")
    ensure(JsonValue.fromStr("\"0123456789\\nabcdef\"").toString() == "\"0123456789\\nabcdef\"")
    ensure(JsonValue.fromStr("\"a\\n\\\"b\\\\c\"").toString() == "\"a\\n\\\"b\\\\c\"")
    ensure(JsonValue.fromStr("\"a&b\"").toString() == "\"a\\u0026b\"")
    ensure(JsonValue.fromStr("\"\\u007f\"").toString() == "\"\\u007f\"")
}

main() {
    testShortStrings()
}
