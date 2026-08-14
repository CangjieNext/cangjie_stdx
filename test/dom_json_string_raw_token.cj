import stdx.encoding.json.*

func ensure(value: Bool, message: String): Unit {
    if (!value) {
        throw Exception(message)
    }
}

func testRawStringTokenWrite(): Unit {
    let source = "{\"plain\":\"payload\",\"unicode\":\"\\u0061\",\"amp\":\"a&b\"}"
    let result = JsonValue.fromStr(source).toString()
    ensure(
        result == "{\"plain\":\"payload\",\"unicode\":\"\\u0061\",\"amp\":\"a\\u0026b\"}",
        "raw DOM JSON string token round-trip failed"
    )
}

func testRawStringTokenMaterializesOnAccess(): Unit {
    let value = JsonValue.fromStr("\"plain\"").asString().getValue()
    ensure(value == "plain", "lazy string materialization failed")
}

main() {
    testRawStringTokenWrite()
    testRawStringTokenMaterializesOnAccess()
    println("PASS dom_json_string_raw_token")
}
