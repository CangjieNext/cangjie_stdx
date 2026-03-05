# cangjie_stdx::effect

## Introduction

The `cangjie_stdx::effect` module provides a powerful non-local control operation mechanism. It offers user-level APIs for handling the Effect Handler feature. This is an experimental feature that requires the use of a Cangjie compiler that supports this mechanism.

## Features

- **Effect Handlers**: Provides a mechanism for handling effects in a controlled manner
- **Non-local Control Flow**: Enables non-local control operations beyond traditional exception handling
- **Composable Effects**: Supports composition of multiple effects
- **Type Safety**: Ensures type-safe effect handling

## Experimental Status

This module is currently experimental and may undergo significant changes in future versions. It requires a Cangjie compiler that supports the Effect Handler mechanism.

## Usage

To use the effect module in your project, add the following dependency to your `cjpm.toml`:

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

Then import the effect module:

```cj
import cangjie_stdx::effect
```

## Documentation

For detailed API documentation, please refer to the [stdx API Documentation](../../doc/summary_cjnative_EN.md).

## License

This module is part of the Cangjie stdx project and follows the same license terms.
