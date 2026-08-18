import std.collection.*
import stdx.encoding.json.*

func ensure(value: Bool, message: String): Unit {
    if (!value) {
        throw Exception(message)
    }
}

func intValue(array: JsonArray, index: Int64): Int64 {
    return array.get(index).getOrThrow().asInt().getValue()
}

func testFlatInsertLookupAndSerialize(): Unit {
    let array = JsonArray()
    for (i in 0..8) {
        array.add(JsonInt(i))
    }

    ensure(array.size() == 8, "flat array size is incorrect")
    for (i in 0..8) {
        ensure(intValue(array, i) == i, "flat array lost item ${i}")
        ensure(array[i].asInt().getValue() == i, "flat array index operator lost item ${i}")
    }
    ensure(array.get(-1).isNone(), "negative flat index should return None")
    ensure(array.get(8).isNone(), "out-of-range flat index should return None")
    ensure(JsonValue.fromStr(array.toString()).asArray().size() == 8, "flat compact output is invalid")
    ensure(
        JsonValue.fromStr(array.toJsonString(0)).asArray().size() == 8,
        "flat formatted output is invalid"
    )
}

func testNinthItemPromotes(): Unit {
    let array = JsonArray()
    for (i in 0..9) {
        array.add(JsonInt(i))
    }

    ensure(array.size() == 9, "ninth item was not retained")
    for (i in 0..9) {
        ensure(intValue(array, i) == i, "promotion lost item ${i}")
    }
    ensure(JsonValue.fromStr(array.toString()).asArray().size() == 9, "promoted output is invalid")
}

func testListAliasesRemainMutable(): Unit {
    let source = ArrayList<JsonValue>()
    source.add(JsonInt(1))
    let fromList = JsonArray(source)
    source.add(JsonInt(2))
    ensure(fromList.size() == 2, "list constructor stopped retaining the caller list")
    ensure(intValue(fromList, 1) == 2, "caller-list mutation is not visible")

    let exposed = JsonArray()
    exposed.add(JsonInt(3))
    let items = exposed.getItems()
    items.add(JsonInt(4))
    ensure(exposed.size() == 2, "getItems mutation is not visible")
    ensure(intValue(exposed, 1) == 4, "getItems promotion lost the appended item")
    ensure(exposed.toString() == "[3,4]", "getItems mutation produced invalid JSON")
}

func testArrayConstructor(): Unit {
    let source: Array<JsonValue> = [JsonInt(5), JsonInt(6)]
    let array = JsonArray(source)
    ensure(array.size() == 2, "Array constructor size is incorrect")
    ensure(intValue(array, 0) == 5 && intValue(array, 1) == 6, "Array constructor lost items")
}

main() {
    testFlatInsertLookupAndSerialize()
    testNinthItemPromotes()
    testListAliasesRemainMutable()
    testArrayConstructor()
    println("PASS dom_json_flat_array")
}
