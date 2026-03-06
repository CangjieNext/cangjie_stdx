# stdx.crypto.digest

## Function Overview

The digest package provides commonly used message digest algorithms, including MD5, SHA1, SHA224, SHA256, SHA384, SHA512, HMAC, SM3, etc.

This package requires the crypto dynamic library files from OpenSSL 3 as external dependencies, so relevant tools must be installed before use.

- For Linux operating systems, refer to the following methods:
    - If the system's package manager supports installing the OpenSSL 3 development toolkit, use this method to install it. Ensure the system installation directory contains both `libcrypto.so` and `libcrypto.so.3` dynamic library files. For example, on Ubuntu 22.04, you can use the command `sudo apt install libssl-dev` to install the `libssl-dev` toolkit;
    - If installation via the above method is not possible, manually download the OpenSSL 3.x.x source code, compile, and install the package. Ensure the installation directory contains both `libcrypto.so` and `libcrypto.so.3` dynamic library files. Then, choose one of the following methods to ensure the system linker can locate these files:
        - For systems without OpenSSL installed, select the system path for installation;
        - For custom installation directories, add the directory containing these files to the environment variables `LD_LIBRARY_PATH` and `LIBRARY_PATH`.

- For Windows operating systems, follow these steps:
    - Manually download the OpenSSL 3.x.x source code and compile the x64 architecture package, or download and install a third-party precompiled OpenSSL 3.x.x package for developers;
    - Ensure the installation directory contains both `libcrypto.dll.a` (or `libcrypto.lib`) and `libcrypto-3-x64.dll` library files;
    - Add the directory path containing `libcrypto.dll.a` (or `libcrypto.lib`) to the `LIBRARY_PATH` environment variable, and add the directory path containing `libcrypto-3-x64.dll` to the `PATH` environment variable.

- For macOS operating systems, refer to the following methods:
    - Use `brew install openssl@3` to install, and ensure the system installation directory contains both `libcrypto.dylib` and `libcrypto.3.dylib` dynamic library files;
    - If installation via the above method is not possible, manually download the OpenSSL 3.x.x source code, compile, and install the package. Ensure the installation directory contains both `libcrypto.dylib` and `libcrypto.3.dylib` dynamic library files. Then, choose one of the following methods to ensure the system linker can locate these files:
        - For systems without OpenSSL installed, select the system path for installation;
        - For custom installation directories, add the directory containing these files to the environment variables `DYLD_LIBRARY_PATH` and `LIBRARY_PATH`.

- For Android operating systems:
    - Since Android ships with a stripped-down version of OpenSSL by default, some interfaces may throw exceptions due to missing symbols. Therefore, users need to compile and install a complete `OpenSSL 3.x.x` version themselves.
    - Download the `OpenSSL 3.x.x` source code and use Android NDK to cross-compile dynamic library files for the target architectures (currently only `arm64-v8a` is supported). Ensure the build artifacts include `libcrypto.so` and `libcrypto.so.3`.
    - Add the directory containing these files to the environment variables `LD_LIBRARY_PATH`.

> **Note:**
>
> If the OpenSSL 3 package is not installed or a lower version is installed, the program may fail to function and throw the related exception `CryptoException: Can not load openssl library or function xxx`.

## API List

### Classes

|                 Class Name                 |                Function                |
| ----------------------------------------- | ------------------------------------- |
| [HMAC](./digest_package_api/digest_package_classes.md#class-hmac) | HMAC digest algorithm.    |
| [MD5](./digest_package_api/digest_package_classes.md#class-md5) | MD5 digest algorithm.    |
| [SHA1](./digest_package_api/digest_package_classes.md#class-sha1) | SHA1 digest algorithm.    |
| [SHA224](./digest_package_api/digest_package_classes.md#class-sha224) | SHA224 digest algorithm.    |
| [SHA256](./digest_package_api/digest_package_classes.md#class-sha256) | SHA256 digest algorithm.    |
| [SHA384](./digest_package_api/digest_package_classes.md#class-sha384) | SHA384 digest algorithm.    |
| [SHA512](./digest_package_api/digest_package_classes.md#class-sha512) | SHA512 digest algorithm.    |
| [SM3](./digest_package_api/digest_package_classes.md#class-sm3) | SM3 digest algorithm.    |

### Structs

|               Struct Name               |           Function           |
|----------------------------------------| ---------------------------- |
| [HashType](./digest_package_api/digest_package_structs.md#struct-hashtype) | Digest algorithm type. |

### Exception Classes

|                 Exception Class Name                 |                Function                |
| -------------------------------------------------- | ------------------------------------- |
| [CryptoException](./digest_package_api/digest_package_exceptions.md#class-cryptoexception) | Exception class for the `crypto` package.      |