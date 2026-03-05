# Serialization Using Json Stream

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::encoding.json.stream.*
import std.io.{ByteBuffer, readToEnd}

class Image <: JsonSerializable {
    var width: Int64
    var height: Int64
    var title: String
    var ids: Array<Int64>

    public init() {
        width = 0
        height = 0
        title = ""
        ids = Array<Int64>()
    }

    public func toJson(w: JsonWriter): Unit {
        w.startObject()
        w.writeName("Width").writeValue(width)
        w.writeName("Height").writeValue(height)
        w.writeName("Title").writeValue(title)
        w.writeName("Ids").writeValue<Array<Int64>>(ids)
        w.endObject()
    }
}

main() {
    let image = Image()
    image.width = 800
    image.height = 600
    image.title = "View from 15th Floor"
    image.ids = [116, 943, 234, 38793]

    let stream = ByteBuffer()
    let writer = JsonWriter(stream)

    /* Serialize the image */
    writer.writeValue(image)
    writer.flush()
    println(String.fromUtf8(readToEnd(stream)))
}
```

Execution Result:

```text
{"Width":800,"Height":600,"Title":"View from 15th Floor","Ids":[116,943,234,38793]}
```