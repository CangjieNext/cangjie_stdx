import stdx.encoding.json.*

func ensure(value: Bool, message: String): Unit {
    if (!value) {
        throw Exception(message)
    }
}

let SOURCE = "[" +
    "{\"v\":0,\"a\":[0]},{\"v\":1,\"a\":[1]},{\"v\":2,\"a\":[2]}," +
    "{\"v\":3,\"a\":[3]},{\"v\":4,\"a\":[4]},{\"v\":5,\"a\":[5]}," +
    "{\"v\":6,\"a\":[6]},{\"v\":7,\"a\":[7]},{\"v\":8,\"a\":[8]}," +
    "{\"v\":9,\"a\":[9]},{\"v\":10,\"a\":[10]},{\"v\":11,\"a\":[11]}," +
    "{\"v\":12,\"a\":[12]},{\"v\":13,\"a\":[13]},{\"v\":14,\"a\":[14]}," +
    "{\"v\":15,\"a\":[15]},{\"v\":16,\"a\":[16]},{\"v\":17,\"a\":[17]}," +
    "{\"v\":18,\"a\":[18]},{\"v\":19,\"a\":[19]},{\"v\":20,\"a\":[20]}," +
    "{\"v\":21,\"a\":[21]},{\"v\":22,\"a\":[22]},{\"v\":23,\"a\":[23]}," +
    "{\"v\":24,\"a\":[24]},{\"v\":25,\"a\":[25]},{\"v\":26,\"a\":[26]}," +
    "{\"v\":27,\"a\":[27]},{\"v\":28,\"a\":[28]},{\"v\":29,\"a\":[29]}," +
    "{\"v\":30,\"a\":[30]},{\"v\":31,\"a\":[31]},{\"v\":32,\"a\":[32]}]"

func objectAt(root: JsonArray, index: Int64): JsonObject {
    return root[index].asObject()
}

func arrayAt(root: JsonArray, index: Int64): JsonArray {
    return objectAt(root, index)["a"].asArray()
}

func testCrossSlabIsolationAndPromotion(): Unit {
    let root = JsonValue.fromOwnedUtf8Bytes(SOURCE.toArray()).asArray()
    ensure(root.size() == 33, "parser lost a container across the slab boundary")
    for (i in 0..33) {
        ensure(objectAt(root, i)["v"].asInt().getValue() == i, "object slice overlap at ${i}")
        ensure(arrayAt(root, i)[0].asInt().getValue() == i, "array slice overlap at ${i}")
    }

    let firstObject = objectAt(root, 0)
    for (i in 0..7) {
        firstObject.put("k${i}", JsonInt(i + 100))
    }
    ensure(firstObject.size() == 9, "object promotion at the slab boundary failed")
    ensure(objectAt(root, 1).size() == 2, "object promotion modified a sibling slice")

    let firstArray = arrayAt(root, 0)
    for (i in 0..8) {
        firstArray.add(JsonInt(i + 100))
    }
    ensure(firstArray.size() == 9, "array promotion at the slab boundary failed")
    ensure(arrayAt(root, 1).size() == 1, "array promotion modified a sibling slice")

    let reparsed = JsonValue.fromStr(root.toString()).asArray()
    ensure(reparsed.size() == 33, "slab-backed DOM serialization is invalid")
    ensure(objectAt(reparsed, 32)["v"].asInt().getValue() == 32, "last slab value was lost")
}

main() {
    testCrossSlabIsolationAndPromotion()
    println("PASS dom_json_parser_slab_arena")
}
