import std.collection.*
import stdx.encoding.json.*

func ensure(value: Bool, message: String): Unit {
    if (!value) {
        throw Exception(message)
    }
}

func testStringHtmlSafeModes(): Unit {
    let value = JsonString("plain&text")
    ensure(value.toString() == "\"plain\\u0026text\"", "html-safe string output changed")
    ensure(value.toStringWithoutEscaping() == "\"plain&text\"", "compact-safe string output changed")
}

func testStringMutationReclassifies(): Unit {
    let value = JsonString("plain")
    value.setValue("quote=\" amp=& line=\n")
    ensure(
        value.toString() == "\"quote=\\\" amp=\\u0026 line=\\n\"",
        "JsonString.setValue did not preserve escaping"
    )
}

func testParsedStringsPreserveEscaping(): Unit {
    let source = "{\"safe\":\"plain\",\"amp\":\"a&b\",\"escaped\":\"a\\\"b\",\"line\":\"a\\nb\"}"
    let parsed = JsonValue.fromOwnedUtf8Bytes(source.toArray()).asObject()
    let encoded = parsed.toStringWithCapacity(source.size + 64)
    let reparsed = JsonValue.fromStr(encoded).asObject()
    ensure(reparsed.get("safe").getOrThrow().asString().getValue() == "plain", "safe parsed string changed")
    ensure(reparsed.get("amp").getOrThrow().asString().getValue() == "a&b", "ampersand parsed string changed")
    ensure(reparsed.get("escaped").getOrThrow().asString().getValue() == "a\"b", "escaped parsed string changed")
    ensure(reparsed.get("line").getOrThrow().asString().getValue() == "a\nb", "control parsed string changed")
}

func testObjectPutClassifiesKeys(): Unit {
    let safe = JsonObject()
    safe.put("plain", JsonInt(1))
    ensure(safe.toString() == "{\"plain\":1}", "safe key output changed")

    let unsafeObject = JsonObject()
    unsafeObject.put("quote\"&", JsonInt(2))
    ensure(unsafeObject.toString() == "{\"quote\\\"\\u0026\":2}", "unsafe key escaping changed")
}

func testExternalMapAndGetFieldsStayConservative(): Unit {
    let map = HashMap<String, JsonValue>()
    map.add("external\"&", JsonInt(3))
    let fromMap = JsonObject(map)
    let fromMapEncoded = fromMap.toString()
    ensure(
        JsonValue.fromStr(fromMapEncoded).asObject().containsKey("external\"&"),
        "external-map key was not escaped"
    )

    let exposed = JsonObject()
    exposed.put("safe", JsonInt(1))
    let fields = exposed.getFields()
    fields.add("mutated\"&", JsonInt(4))
    let exposedEncoded = exposed.toString()
    ensure(
        JsonValue.fromStr(exposedEncoded).asObject().containsKey("mutated\"&"),
        "getFields mutation bypassed key escaping"
    )
}

main() {
    testStringHtmlSafeModes()
    testStringMutationReclassifies()
    testParsedStringsPreserveEscaping()
    testObjectPutClassifiesKeys()
    testExternalMapAndGetFieldsStayConservative()
    println("PASS dom_json_escape_classification")
}
