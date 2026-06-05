# stdx.plugin

> **Note:**
>
> Currently in development stage, not yet with full functionality.

## Feature Introduction

The plugin package provides CHIR plugin registration, management, and execution mechanisms, including:

- **Plugin base class** (`CHIRPluginBase`): Abstract base class for all CHIR plugins; subclasses must implement the `run` method.
- **Plugin manager** (`PluginManager`): Provides CHIR plugin registration functionality.
- **Plugin registration macro** (`CHIRPlugin`): Automatically transforms a class declaration into a CHIRPluginBase subclass and registers it.
- **Plugin execution** (`executeCHIRPlugins`): Executes all registered plugins on CHIR package binary data sequentially.
- **Execution result** (`PluginResult`): Contains processed data, length, and success status.

## API List

### Classes

| Class name | Description |
| --- | --- |
| [CHIRPluginBase](./plugin_package_api/plugin_package_classes.md#class-chirpluginbase) | Abstract base class for CHIR plugins. |
| [PluginManager](./plugin_package_api/plugin_package_classes.md#class-pluginmanager) | Plugin manager, providing plugin registration. |

### Top-level Functions

| Function name | Description |
| --- | --- |
| [executeCHIRPlugins](./plugin_package_api/plugin_package_classes.md#func-executechirplugins) | Execute all registered CHIR plugins on package data. |

### Macros

| Macro name | Description |
| --- | --- |
| [CHIRPlugin](./plugin_package_api/plugin_package_classes.md#macro-chirplugin) | CHIR plugin registration macro. |

### Structs

| Struct name | Description |
| --- | --- |
| [PluginResult](./plugin_package_api/plugin_package_structs.md#struct-pluginresult) | CHIR plugin execution result. |