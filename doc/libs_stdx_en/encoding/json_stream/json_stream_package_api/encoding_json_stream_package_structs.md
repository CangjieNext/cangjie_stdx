# Struct

## struct WriteConfig

```cangjie
public struct WriteConfig {
    public static let compact: WriteConfig
    public static let pretty: WriteConfig
}
```

Function: Used to represent the serialization format configuration for [JsonWriter](./encoding_json_stream_package_classes.md#class-jsonwriter).

Example:

For usage examples, see [WriteConfig Usage Example](../json_stream_samples/sample_json_writeconfig.md).

### static let compact

```cangjie
public static let compact: WriteConfig
```

Function: Provides compact serialization format.

> **Note:**
>
> The property values for compact are:
>
> - newline: "" (empty string).
> - indent: "" (empty string).
> - useSpaceAfterSeparators: false.
> - htmlSafe: false.
> - dateTimeFormat: DateTimeFormat.RFC3339.

Type: [WriteConfig](#struct-writeconfig)

Example:

```text
{"Name":"zhangsan","Age":18,"Scores":[88.8,99.9],"Class":{"Name":"Class A","Students Number":33}}
```

### static let pretty

```cangjie
public static let pretty: WriteConfig
```

Function: Provides neatly formatted serialization.

> **Note:**
>
> The property values for pretty are:
>
> - newline: "\n".
> - indent: "&emsp;&emsp;&emsp;&emsp;" (string containing 4 spaces).
> - useSpaceAfterSeparators: true.
> - htmlSafe: false.
> - dateTimeFormat: DateTimeFormat.RFC3339.

Type: [WriteConfig](#struct-writeconfig)

Example:

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

### prop dateTimeFormat

```cangjie
public mut prop dateTimeFormat: String
```

Function: Controls the format when serializing DateTime types, with functionality consistent with DateTime's func toString(DateTimeFormat).

Type: String

### prop htmlSafe

```cangjie
public mut prop htmlSafe: Bool
```

Function: Indicates whether to escape HTML characters `<`, `>`, `&`, `=`, and `'`.

When set to true, HTML characters will be escaped to their corresponding Unicode-encoded strings.

This option only affects string literals within JSON values.

Type: Bool

### prop indent

```cangjie
public mut prop indent: String
```

Function: Specifies the indentation string used for each indentation level during serialization. The value should match the regex `^[ \t]*$`.

When newline is enabled, this value will be used as the padding after line breaks.

Type: String

Exceptions:

- IllegalArgumentException - Thrown if the provided string contains characters other than ' ' or '\t'.

### prop newline

```cangjie
public mut prop newline: String
```

Function: Specifies the newline character used during serialization. The value should match the regex `^[\r\n]*$`.

When this value is not an empty string and is valid, JsonWriter will insert new lines when calling startObject and startArray operations, inserting elements, and their corresponding closing operations.

When this value is an empty string, no new lines will be inserted.

Type: String

Exceptions:

- IllegalArgumentException - Thrown if the provided string contains characters other than '\r' or '\n'.

### prop useSpaceAfterSeparators

```cangjie
public mut prop useSpaceAfterSeparators: Bool
```

Function: Indicates whether to add a space after ':' and ',' during serialization.

When set to true, a space will automatically be written after each field name or array element insertion.

This option only affects fields within JSON Objects and elements within JSON Arrays.

Type: Bool