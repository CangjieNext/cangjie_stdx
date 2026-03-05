# cangjie_stdx::log

## Introduction

The `cangjie_stdx::log` module provides a single logging API for Cangjie applications. It offers a unified interface for logging operations across the application.

## Features

- **Unified API**: Provides a single, consistent logging interface
- **Multiple Log Levels**: Supports various log levels (debug, info, warning, error, fatal)
- **Flexible Configuration**: Allows for customizable logging behavior
- **Performance**: Optimized for minimal performance impact

## Usage

To use the log module in your project, add the following dependency to your `cjpm.toml`:

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

Then import the log module:

```cj
import cangjie_stdx::log
```

## Documentation

For detailed API documentation, please refer to the [stdx API Documentation](../../doc/summary_cjnative_EN.md).

## License

This module is part of the Cangjie stdx project and follows the same license terms.
