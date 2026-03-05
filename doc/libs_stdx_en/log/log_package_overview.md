# cangjie_stdx::log

## Feature Description

The log package provides a unified logging API that abstracts the actual logging implementation.

## API List

### Functions

| Function Name                                                | Description                 |
| ------------------------------------------------------------ | --------------------------- |
| [getGlobalLogger(Array\<Attr>)](./log_package_api/log_package_funcs.md#func-getgloballoggerarrayattr) | Gets the global Logger object. |
| [setGlobalLogger(Logger)](./log_package_api/log_package_funcs.md#func-setgloballoggerlogger) | Sets the global Logger object. |

### Type Aliases

| Type Alias                  | Description                |
| --------------------------- | -------------------------- |
| [Attr](./log_package_api/log_package_types.md#type-attr) | Key-value pair type for log messages, which is an alias for (String, [LogValue](./log_package_api/log_package_interfaces.md#interface-logvalue)). |

### Interfaces

| Interface Name               | Description                |
| --------------------------- | -------------------------- |
| [LogValue](./log_package_api/log_package_interfaces.md#interface-logvalue) | Provides an interface for serializing Cangjie data types to log output targets. |

### Classes

| Class Name                   | Description                |
| --------------------------- | -------------------------- |
| [Logger](./log_package_api/log_package_classes.md#class-logger) | This abstract class provides basic logging and management functionality. |
| [LogRecord](./log_package_api/log_package_classes.md#class-logrecord) | The "payload" of log messages. |
| [LogWriter](./log_package_api/log_package_classes.md#class-logwriter) | [LogWriter](./log_package_api/log_package_classes.md#class-logwriter) provides the capability to serialize Cangjie data types to log output targets. |
| [NoopLogger](./log_package_api/log_package_classes.md#class-nooplogger) | A NO-OP (No Operation) implementation of [Logger](./log_package_api/log_package_classes.md#class-logger). |

### Structs

| Struct Name                  | Description                |
| --------------------------- | -------------------------- |
| [LogLevel](./log_package_api/log_package_structs.md#struct-loglevel) | [LogLevel](./log_package_api/log_package_structs.md#struct-loglevel) is the struct for log levels. |

### Exception Classes

| Exception Class Name         | Description                |
| --------------------------- | -------------------------- |
| [LogException](./log_package_api/log_package_exceptions.md#class-logexception) | Used to handle log-related exceptions. |