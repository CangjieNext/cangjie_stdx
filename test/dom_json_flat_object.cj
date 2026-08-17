import std.collection.*
import stdx.encoding.json.*

func ensure(value: Bool, message: String): Unit {
    if (!value) {
        throw Exception(message)
    }
}

func intValue(object: JsonObject, key: String): Int64 {
    return object.get(key).getOrThrow().asInt().getValue()
}

func testFlatInsertLookupAndReplace(): Unit {
    let object = JsonObject()
    for (i in 0..8) {
        object.put("k${i}", JsonInt(i))
    }
    object.put("k3", JsonInt(33))

    ensure(object.size() == 8, "replacing a flat field changed object size")
    ensure(object.containsKey("k0"), "flat containsKey missed an existing key")
    ensure(!object.containsKey("missing"), "flat containsKey found a missing key")
    ensure(intValue(object, "k3") == 33, "flat replacement did not update the value")
    ensure(JsonValue.fromStr(object.toString()).asObject().size() == 8, "flat compact output is invalid")
    ensure(
        JsonValue.fromStr(object.toJsonString(0)).asObject().size() == 8,
        "flat formatted output is invalid"
    )
}

func testNinthDistinctKeyPromotes(): Unit {
    let object = JsonObject()
    for (i in 0..9) {
        object.put("k${i}", JsonInt(i))
    }

    ensure(object.size() == 9, "ninth distinct key was not retained")
    for (i in 0..9) {
        ensure(intValue(object, "k${i}") == i, "promotion lost field k${i}")
    }
    ensure(JsonValue.fromStr(object.toString()).asObject().size() == 9, "promoted output is invalid")
}

func testMapAliasesRemainMutable(): Unit {
    let source = HashMap<String, JsonValue>()
    source.add("before", JsonInt(1))
    let fromMap = JsonObject(source)
    source.add("after", JsonInt(2))
    ensure(intValue(fromMap, "after") == 2, "map constructor stopped retaining the caller map")

    let exposed = JsonObject()
    exposed.put("flat", JsonInt(3))
    let fields = exposed.getFields()
    fields.add("escaped\"&", JsonInt(4))
    ensure(intValue(exposed, "escaped\"&") == 4, "getFields mutation is not visible")
    ensure(
        JsonValue.fromStr(exposed.toString()).asObject().containsKey("escaped\"&"),
        "escaped key added through getFields produced invalid JSON"
    )
}

main() {
    testFlatInsertLookupAndReplace()
    testNinthDistinctKeyPromotes()
    testMapAliasesRemainMutable()
    println("PASS dom_json_flat_object")
}
