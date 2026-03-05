# cangjie_stdx::string_intern

## Feature Description

The string_intern package provides pooled caching capability for string objects. The cached string object can be retrieved through code invocation, thereby reducing the memory risk caused by an excessive number of temporary strings during program execution.

This feature requires the construction of two global string cache pools：

1. Constant Pool: Default implementation in the standard library, only allows queries.

2. Dynamic Cache Pool: Enabled through code, it allows for the creation and caching of string objects at runtime.

This function primarily achieves the aforementioned effects through the following mechanisms：

1. During the compilation phase, string constants are cached in the constant pool.

2. During the runtime phase, users can invoke the extended method (intern) of String to utilize cached string objects.

3. If during the runtime phase, users generate strings that cannot be recognized by the compiler, it is necessary to manually enable the runtime string caching. This can be achieved by actively invoking the extension method (configInternPool) of the String class to activate this feature, and then calling the intern method to create (only on the first call) and retrieve the cached string objects.

## API List

### Interfaces

| Interface Name                                               | Description                  |
| -------------------------------------------------------------------------------------------------- | -------------------------------------- |
| [Internable](./string_intern_package_api/string_intern_package_interfaces.md#interface-internable) | Extend struct String with functions such as intern and configInternPool. |
