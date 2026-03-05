# cangjie_stdx::compress

## Introduction

The `cangjie_stdx::compress` module provides compression and decompression functions for various compression algorithms. It enables efficient data storage and transmission by reducing the size of data.

## Features

- **Multiple Compression Formats**: Supports various compression algorithms including zlib, tar, and gzip
- **Stream-based Processing**: Provides both streaming and in-memory compression/decompression
- **High Performance**: Optimized for performance with native implementations
- **Easy Integration**: Simple API for seamless integration into applications

## Supported Formats

- **zlib**: DEFLATE compression algorithm
- **tar**: Archive format for multiple files
- **gzip**: GNU zip compression format

## Usage

To use the compress module in your project, add the following dependency to your `cjpm.toml`:

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

Then import the compress module:

```cj
import cangjie_stdx::compress
```

## Documentation

For detailed API documentation, please refer to the [stdx API Documentation](../../doc/summary_cjnative_EN.md).

## License

This module is part of the Cangjie stdx project and follows the same license terms.
