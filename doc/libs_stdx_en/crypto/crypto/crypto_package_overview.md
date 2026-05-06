# stdx.crypto.crypto

## Feature Description

The crypto package provides secure random number generation and supports the SM4 symmetric encryption/decryption algorithm (Chinese National Standard).

This package requires the OpenSSL 3 crypto dynamic library as an external dependency. Therefore, related tools must be installed before use.

- For Linux operating systems:
    - If the system's package manager supports installing the OpenSSL 3 development toolkit, you can install it this way. Ensure the system installation directory contains both `libcrypto.so` and `libcrypto.so.3` dynamic library files. For example, on Ubuntu 22.04, you can use the command `sudo apt install libssl-dev` to install the libssl-dev toolkit;
    - If the above method is unavailable, you can download and compile the OpenSSL 3.x.x source code yourself. Ensure the installation directory contains both `libcrypto.so` and `libcrypto.so.3` dynamic library files. Then choose one of the following methods to ensure the system linker can locate these files:
        - For systems without OpenSSL installed, select the system path during installation;
        - For custom installation directories, add the directory containing these files to the `LD_LIBRARY_PATH` and `LIBRARY_PATH` environment variables.

- For Windows operating systems:
    - Download and compile the OpenSSL 3.x.x source code for x64 architecture or obtain a third-party precompiled OpenSSL 3.x.x developer package;
    - Ensure the installation directory contains both `libcrypto.dll.a` (or `libcrypto.lib`) and `libcrypto-3-x64.dll` library files;
    - Add the directory containing `libcrypto.dll.a` (or `libcrypto.lib`) to the `LIBRARY_PATH` environment variable and the directory containing `libcrypto-3-x64.dll` to the `PATH` environment variable.

- For macOS operating systems:
    - Use `brew install openssl@3` to install and ensure the system installation directory contains both `libcrypto.dylib` and `libcrypto.3.dylib` dynamic library files;
    - If the above method is unavailable, download and compile the OpenSSL 3.x.x source code yourself. Ensure the installation directory contains both `libcrypto.dylib` and `libcrypto.3.dylib` dynamic library files. Then choose one of the following methods to ensure the system linker can locate these files:
        - For systems without OpenSSL installed, select the system path during installation;
        - For custom installation directories, add the directory containing these files to the `DYLD_LIBRARY_PATH` and `LIBRARY_PATH` environment variables.

- For Android operating systems:
    - Since Android ships with a stripped-down version of OpenSSL by default, some interfaces may throw exceptions due to missing symbols. Therefore, users need to compile and install a complete `OpenSSL 3.x.x` version themselves.
    - Download the `OpenSSL 3.x.x` source code and use Android NDK to cross-compile dynamic library files for the target architectures (currently only `arm64-v8a` is supported). Ensure the build artifacts include `libcrypto.so` and `libcrypto.so.3`.
    - Add the directory containing these files to the environment variables `LD_LIBRARY_PATH`.

- For HarmonyOS operating systems:
    - Due to system restrictions in `HarmonyOS` 6.0 and above, `stdx` cannot directly access the system's built-in `OpenSSL`, users need to compile `OpenSSL` dynamic libraries for `HarmonyOS` and package them into the application.
    - For compiling `OpenSSL` for `HarmonyOS`, refer to [OHOS Cangjie SDK Build Guide](https://gitcode.com/Cangjie/cangjie_build/blob/dev/docs/linux_ohos_toolchain.md).
    - Package the compiled dynamic library files `libcrypto_openssl.z.so` and `libssl_openssl.z.so` into the application and ensure they can be correctly loaded at runtime.

> **Note:**
>
> If OpenSSL 3 is not installed or an older version is installed, the program may fail to function and throw a `SecureRandomException`: `Can not load openssl library or function xxx`.

## API List

### Classes

|                 Class Name              |                Function                |
| --------------------------------------- | -------------------------------------- |
| [SecureRandom](./crypto_package_api/crypto_package_classes.md#class-securerandom) | Secure random number generation.       |
| [SM4](./crypto_package_api/crypto_package_classes.md#class-sm4) | Provides SM4 symmetric encryption/decryption. |

### Structs

| Struct Name                                                                                |           Function          |
|------------------------------------------------------------------------------------------| ---------------------------- |
| [OperationMode](./crypto_package_api/crypto_package_structs.md#struct-operationmode)     | Working modes for symmetric encryption/decryption algorithms. |
| [PaddingMode](./crypto_package_api/crypto_package_structs.md#struct-paddingmode)         | Padding modes for symmetric encryption/decryption algorithms. |

### Exception Classes

|                 Exception Class Name              |                Function                |
| ------------------------------------------------ | -------------------------------------- |
| [SecureRandomException](./crypto_package_api/crypto_package_exceptions.md#class-securerandomexception) | Secure random number exception class.  |