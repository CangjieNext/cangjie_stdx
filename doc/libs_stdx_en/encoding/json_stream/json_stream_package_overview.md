# cangjie_stdx::encoding.json.stream

## Feature Description

The json.stream package is primarily used for bidirectional conversion between Cangjie objects and JSON data streams.

This package provides the JsonWriter and JsonReader classes. JsonWriter offers serialization capabilities for converting Cangjie objects to JSON data streams, while JsonReader provides deserialization capabilities for converting JSON data streams back to Cangjie objects.

The current implementation supports the following types for bidirectional conversion with JSON data streams:

- Basic data types: String, Int8, Int16, Int32, Int64, Float16, Float32, Float64, UInt8, UInt16, UInt32, UInt64.

- Collection types: Array\<T>, ArrayList\<T>, HashMap\<String, T>.

- Other types: Option\<T>, BigInt, Decimal.

## API List

### Interfaces

| Interface Name | Function |
|-------| ------|
|[JsonDeserializable\<T>](./json_stream_package_api/encoding_json_stream_package_interfaces.md#interface-jsondeserializablet)| This interface is used to implement reading a Cangjie object from [JsonReader](./json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader). |
|[JsonSerializable](./json_stream_package_api/encoding_json_stream_package_interfaces.md#interface-jsonserializable)| Provides an interface for serializing types to JSON data streams. |

### Classes

|  Class Name | Function  |
| ------------ | ------------ |
| [JsonReader](./json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonreader) | This class provides deserialization capabilities for converting JSON data streams to Cangjie objects. |
| [JsonWriter](./json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonwriter) | Constructor, creates an instance that writes data to the output stream. |

### Enums

|  Enum Name | Function  |
| ------------ | ------------ |
| [JsonToken](./json_stream_package_api/encoding_json_stream_package_enums.md#enum-jsontoken) | Represents the structure, name, or value type in JSON-encoded strings. |

### Structs

|            Struct Name          |           Function           |
| --------------------------- | ------------------------ |
| [WriteConfig](./json_stream_package_api/encoding_json_stream_package_structs.md#struct-writeconfig) | Used to represent the serialization format configuration for [JsonWriter](./json_stream_package_api/encoding_json_stream_package_classes.md#class-jsonwriter). |