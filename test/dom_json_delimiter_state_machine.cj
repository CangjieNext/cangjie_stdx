import stdx.encoding.json.*

func ensure(value: Bool, message: String): Unit {
    if (!value) {
        throw Exception(message)
    }
}

func ensureRejected(source: String): Unit {
    var rejected = false
    try {
        let _ = JsonValue.fromStr(source)
    } catch (_: JsonException) {
        rejected = true
    }
    ensure(rejected, "invalid JSON was accepted: ${source}")
}

func testValidContainers(): Unit {
    ensure(JsonValue.fromStr("{}").asObject().size() == 0, "empty object failed")
    ensure(JsonValue.fromStr("[ ]").asArray().size() == 0, "empty array with whitespace failed")

    let root = JsonValue.fromStr(" { \"a\" : 1 , \"b\" : [ 2 , { \"c\" : 3 } ] } ").asObject()
    ensure(root.get("a").getOrThrow().asInt().getValue() == 1, "object field was lost")
    let nested = root.get("b").getOrThrow().asArray()
    ensure(nested.size() == 2, "nested array size changed")
    ensure(
        nested.get(1).getOrThrow().asObject().get("c").getOrThrow().asInt().getValue() == 3,
        "nested object value changed"
    )

    let duplicate = JsonValue.fromStr("{\"same\":1,\"same\":2}").asObject()
    ensure(duplicate.size() == 1, "duplicate key changed object size")
    ensure(
        duplicate.get("same").getOrThrow().asInt().getValue() == 2,
        "duplicate key stopped using last-write-wins"
    )
}

func testInvalidDelimiters(): Unit {
    let invalid: Array<String> = [
        "{\"a\":1 \"b\":2}",
        "{\"a\":1,}",
        "{\"a\":1,,\"b\":2}",
        "{\"a\" 1}",
        "[1 2]",
        "[1,]",
        "[1,,2]",
        "[1:2]"
    ]
    for (source in invalid) {
        ensureRejected(source)
    }
}

main() {
    testValidContainers()
    testInvalidDelimiters()
    println("PASS dom_json_delimiter_state_machine")
}
