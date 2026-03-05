# cangjie_stdx::encoding

## Introduction

The `cangjie_stdx::encoding` module provides a basic utility library for data encoding and decoding. It includes support for various encoding formats including base64, hex, JSON, and URL encoding.

## Features

- **Base64 Encoding**: Provides Base64 encoding and decoding functions
- **Hex Encoding**: Supports hexadecimal encoding and decoding
- **JSON Encoding**: Offers JSON serialization and deserialization
- **URL Encoding**: Provides URL encoding and decoding for web applications
- **Stream Processing**: Supports streaming operations for large data

## Submodules

- **cangjie_stdx::encoding.base64**: Base64 encoding and decoding
- **cangjie_stdx::encoding.hex**: Hexadecimal encoding and decoding
- **cangjie_stdx::encoding.json**: JSON serialization and deserialization
- **cangjie_stdx::encoding.json.stream**: Streaming JSON processing
- **cangjie_stdx::encoding.url**: URL encoding and decoding

## Usage

To use the encoding module in your project, add the following dependency to your `cjpm.toml`:

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

Then import the encoding module:

```cj
import cangjie_stdx::encoding
```

## Documentation

For detailed API documentation, please refer to the [stdx API Documentation](../../doc/summary_cjnative_EN.md).

## License

This module is part of the Cangjie stdx project and follows the same license terms.
