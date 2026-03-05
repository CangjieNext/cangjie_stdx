# cangjie_stdx::encoding.json

## Function Description

The json package is used for processing JSON data, enabling mutual conversion between String, JsonValue, and DataModel.

JsonValue encapsulates JSON data formats, including object, array, string, number, true, false, and null.

For details about DataModel, refer to: [serialization package documentation](../../serialization/serialization_package_api/serialization_package_classes.md#class-datamodel).

JSON syntax rules can be found at: [Introducing JSON](https://www.json.org/json-zh.html).

JSON data interchange standards can be found at: [ECMA-404 The JSON Data Interchange Standard](https://www.ecma-international.org/publications-and-standards/standards/ecma-404/).

## API List

### Interfaces

| Interface Name | Function |
| ------------ | ------------ |
| [ToJson](./json_package_api/encoding_json_package_interfaces.md#interface-tojson) | Used for implementing mutual conversion between JsonValue and DataModel. |

### Classes

| Class Name | Function |
| ------------ | ------------ |
| [JsonArray](./json_package_api/encoding_json_package_classes.md#class-jsonarray) | Creates an empty JsonArray. |
| [JsonBool](./json_package_api/encoding_json_package_classes.md#class-jsonbool) | Encapsulates a specified Bool type instance into a JsonBool instance. |
| [JsonFloat](./json_package_api/encoding_json_package_classes.md#class-jsonfloat) | Encapsulates a specified Float64 type instance into a JsonFloat instance. |
| [JsonInt](./json_package_api/encoding_json_package_classes.md#class-jsonint) | Encapsulates a specified Int64 type instance into a JsonInt instance. |
| [JsonNull](./json_package_api/encoding_json_package_classes.md#class-jsonnull) | Converts JsonNull to a string. |
| [JsonObject](./json_package_api/encoding_json_package_classes.md#class-jsonobject) | Creates an empty JsonObject. |
| [JsonString](./json_package_api/encoding_json_package_classes.md#class-jsonstring) | Encapsulates a specified String type instance into a JsonString instance. |
| [JsonValue](./json_package_api/encoding_json_package_classes.md#class-jsonvalue) | This class serves as the JSON data layer, primarily used for mutual conversion between JsonValue and String data. |

### Enums

| Enum Name | Function |
| ------------ | ------------ |
| [JsonKind](./json_package_api/encoding_json_package_enums.md#enum-jsonkind) | Represents the specific type of JsonValue. |

### Exception Classes

| Exception Class Name | Function |
| ------------ | ------------ |
|[JsonException](./json_package_api/encoding_json_package_exceptions.md#class-jsonexception)| Used for scenarios where exceptions occur during JsonValue type usage. |