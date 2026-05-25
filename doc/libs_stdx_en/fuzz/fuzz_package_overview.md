# stdx.fuzz

## Function Description

Fuzz technology is an automated software testing method designed to uncover vulnerabilities and errors in software. It continuously executes software programs by inputting random or mutated test cases, and guides the testing direction based on the program's coverage information.

The fuzz package provides developers with a coverage-guided Cangjie fuzz engine and corresponding interfaces, enabling developers to write code for API testing. Currently, it supports fuzz testing by passing mutated byte streams (Array\<UInt8>) through the fuzz engine or using Cangjie-compliant standard data types (FuzzDataProvider).

Using this package requires the SanitizerCoverage instrumentation feature. Developers need to have some understanding of fuzz testing. Beginners are advised to first learn about C language fuzz tools.

This package has an external dependency on the `libclang_rt.fuzzer_no_main.a` static library provided by the LLVM suite `compiler-rt`. Currently, it supports Linux and macOS, but not Windows.

Typically, installation can be completed using package management tools. For example, on `Ubuntu 22.04`, you can use `sudo apt install clang` for installation. After installation, the corresponding `libclang_rt.fuzzer_no_main.a` file can be found in the directory pointed to by `clang -print-runtime-dir`, such as `/usr/lib/llvm-14/lib/clang/14.0.0/lib/linux/libclang_rt.fuzzer_no_main-x86_64.a`. This file will be needed during linking.

## API List

### Classes

|                 Class Name                |                Function                |
| ----------------------------------------- | ------------------------------------- |
| [Fuzzer](./fuzz_package_api/fuzz_package_classes.md#class-fuzzer) | The Fuzzer class provides creation of fuzz tools. |
| [FuzzerBuilder](./fuzz_package_api/fuzz_package_classes.md#class-fuzzerbuilder) | This class is used for constructing the Fuzzer class. |
| [FuzzDataProvider](./fuzz_package_api/fuzz_package_classes.md#class-fuzzdataprovider) | FuzzDataProvider is a utility class designed to convert mutated byte streams into standard Cangjie basic data. |
| [DebugDataProvider](./fuzz_package_api/fuzz_package_classes.md#class-debugdataprovider) | This class inherits from FuzzDataProvider and adds additional debugging information. |

### Exception Classes

|               Exception Class Name               |                Function                |
| ----------------------------------------------- | ------------------------------------- |
| [ExhaustedException](./fuzz_package_api/fuzz_package_exceptions.md#class-exhaustedexception) | This exception is thrown when there is insufficient remaining data during data conversion. |