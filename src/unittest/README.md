# cangjie_stdx::unittest

## Introduction

The `cangjie_stdx::unittest` module provides the capability to supply test data in serialized input formats when writing unit test code for Cangjie projects. It extends the standard unit testing capabilities with additional features for test data management.

## Features

- **Serialized Test Data**: Supports providing test data in serialized formats
- **Data-Driven Testing**: Enables data-driven testing with multiple test cases
- **Test Data Management**: Provides utilities for managing and organizing test data
- **Integration**: Seamlessly integrates with Cangjie's unit testing framework

## Usage

To use the unittest module in your project, add the following dependency to your `cjpm.toml`:

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

Then import the unittest module:

```cj
import cangjie_stdx::unittest
```

## Documentation

For detailed API documentation, please refer to the [stdx API Documentation](../../doc/summary_cjnative_EN.md).

## License

This module is part of the Cangjie stdx project and follows the same license terms.
