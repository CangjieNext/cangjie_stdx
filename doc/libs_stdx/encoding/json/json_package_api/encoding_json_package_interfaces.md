# 接口

## interface ToJson

```cangjie
public interface ToJson {
    static func fromJson(jv: JsonValue): DataModel
    func toJson(): JsonValue
}
```

功能：用于实现 [JsonValue](encoding_json_package_classes.md#class-jsonvalue) 和 [DataModel](../../../serialization/serialization_package_api/serialization_package_classes.md#class-datamodel) 的相互转换。

### static func fromJson(JsonValue)

```cangjie
static func fromJson(jv: JsonValue): DataModel
```

功能：将 [JsonValue](encoding_json_package_classes.md#class-jsonvalue) 转化为对象 [DataModel](../../../serialization/serialization_package_api/serialization_package_classes.md#class-datamodel)。

参数：

- jv: [JsonValue](encoding_json_package_classes.md#class-jsonvalue) - 待转换的 [JsonValue](encoding_json_package_classes.md#class-jsonvalue)。

返回值：

- [DataModel](../../../serialization/serialization_package_api/serialization_package_classes.md#class-datamodel) - 转换后的 [DataModel](../../../serialization/serialization_package_api/serialization_package_classes.md#class-datamodel)。

### func toJson()

```cangjie
func toJson(): JsonValue
```

功能：将自身转化为 [JsonValue](encoding_json_package_classes.md#class-jsonvalue)。

返回值：

- [JsonValue](encoding_json_package_classes.md#class-jsonvalue) - 转换后的 [JsonValue](encoding_json_package_classes.md#class-jsonvalue)。

异常：

- [JsonException](encoding_json_package_exceptions.md#class-jsonexception) - 如果转换失败，抛出异常。

### extend DataModel <: ToJson

```cangjie
extend DataModel <: ToJson
```

功能：为 [DataModel](../../../serialization/serialization_package_api/serialization_package_classes.md#class-datamodel) 类型实现 ToJson 接口。

父类型：

- [ToJson](#interface-tojson)

#### static func fromJson(JsonValue)

```cangjie
public static func fromJson(jv: JsonValue): DataModel
```

功能：将 [JsonValue](encoding_json_package_classes.md#class-jsonvalue) 转化为对象 [DataModel](../../../serialization/serialization_package_api/serialization_package_classes.md#class-datamodel)。

参数：

- jv: [JsonValue](encoding_json_package_classes.md#class-jsonvalue) - 待转换的 [JsonValue](encoding_json_package_classes.md#class-jsonvalue)。

返回值：

- [DataModel](../../../serialization/serialization_package_api/serialization_package_classes.md#class-datamodel) - 转换后的 [DataModel](../../../serialization/serialization_package_api/serialization_package_classes.md#class-datamodel)。

示例：

<!-- verify -->
```cangjie
import stdx.serialization.serialization.*
import stdx.encoding.json.*
import std.collection.*

main() {
    var fields = HashMap<String, JsonValue>()
    fields.add("name", JsonString("张三"))
    fields.add("tel", JsonString("10000000000"))

    // 使用HashMap创建新的JsonValue对象
    var jsonObject: JsonObject = JsonObject(fields)

    // JsonValue还原回DataModel
    let dataModel = DataModel.fromJson(jsonObject)
    let data = HashMap<String, String>.deserialize(dataModel)
    println("数据: ${data}")
    return 0
}
```

运行结果：

```text
数据: [(name, 张三), (tel, 10000000000)]
```

#### func toJson()

```cangjie
public func toJson(): JsonValue
```

功能：将自身转化为 [JsonValue](encoding_json_package_classes.md#class-jsonvalue)。

返回值：

- [JsonValue](encoding_json_package_classes.md#class-jsonvalue) - 转换后的 [JsonValue](encoding_json_package_classes.md#class-jsonvalue)。

异常：

- [JsonException](encoding_json_package_exceptions.md#class-jsonexception) - 如果转换失败，抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.serialization.serialization.*
import std.collection.*
import stdx.encoding.json.*

main() {
    // 创建一个ArrayList并添加一些DataModel
    let list = ArrayList<DataModel>()
    list.add(DataModelString("元素1"))
    list.add(DataModelString("元素2"))

    // 使用ArrayList创建DataModelSeq实例
    let dataModel = DataModelSeq(list)

    // 将DataModelSeq转换为JsonValue
    let jsonValue = dataModel.toJson()

    let kind = jsonValue.kind()
    match (kind) {
        case JsonKind.JsArray => println("JsonValue的类型是JsArray")
        case _ => println("JsonValue的类型不是JsArray")
    }
    println("JsonValue: ${jsonValue.toJsonString()}")
    return 0
}
```

运行结果：

```text
JsonValue的类型是JsArray
JsonValue: [
  "元素1",
  "元素2"
]
```