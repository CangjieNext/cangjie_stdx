# cangjie_stdx::string_intern

## Introduction

The `cangjie_stdx::string_intern` module provides pooled caching capability for string objects. It enables efficient string storage and comparison by maintaining a pool of unique string instances.

## Features

- **String Pooling**: Maintains a pool of unique string instances
- **Memory Efficiency**: Reduces memory usage by sharing identical strings
- **Fast Comparison**: Enables fast string comparison through reference equality
- **Deduplication**: Automatically deduplicates identical strings

## Usage

To use the string_intern module in your project, add the following dependency to your `cjpm.toml`:

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

Then import the string_intern module:

```cj
import cangjie_stdx::string_intern
```

## Documentation

For detailed API documentation, please refer to the [stdx API Documentation](../../doc/summary_cjnative_EN.md).

## License

This module is part of the the Cangjie stdx project and follows the same license terms.
