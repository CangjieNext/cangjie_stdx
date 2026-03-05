# WriteConfig Usage Example

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::encoding.json.stream.{JsonWriter, WriteConfig, JsonSerializable}
import std.io.ByteBuffer

main() {
    /* Create JsonWriter */
    let buffer = ByteBuffer()
    let writer = JsonWriter(buffer)

    /* Set JSON writing format configuration */
    let fmtCfg = WriteConfig.pretty
    writer.writeConfig = fmtCfg

    /* Write JSON */
    writer.writeValue(MyObj())

    /* Print JSON serialized string */
    println(String.fromUtf8(buffer.bytes()))
}

class MyObj <: JsonSerializable {
    public func toJson(w: JsonWriter): Unit {
        w.startObject()
        w.writeName("Name").writeValue("zhangsan")
        w.writeName("Age").writeValue(18)
        w.writeName("Scores").writeValue([88.8, 99.9])
        w.writeName("Class")
        w.startObject()
        w.writeName("Name").writeValue("Class A")
        w.writeName("Students Number").writeValue(33)
        w.endObject()
        w.endObject()
        w.flush()
    }
}
```

Execution Result:

```text
{
    "Name": "zhangsan",
    "Age": 18,
    "Scores": [
        88.8,
        99.9
    ],
    "Class": {
        "Name": "Class A",
        "Students Number": 33
    }
}
```