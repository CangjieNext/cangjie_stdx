import stdx.encoding.json.*

func ensure(value: Bool): Unit {
    if (!value) {
        throw Exception("DOM JSON float Ryu assertion failed")
    }
}

func testSmallFiniteFloatRoundTrips(): Unit {
    let value: Float64 = 0.0000001
    let root = JsonObject()
    root.put("value", JsonFloat(value))
    let text = root.toString()
    let restored = JsonValue.fromStr(text).asObject().get("value").getOrThrow().asFloat().getValue()
    ensure(restored.toBits() == value.toBits())
}

main() {
    testSmallFiniteFloatRoundTrips()
}
