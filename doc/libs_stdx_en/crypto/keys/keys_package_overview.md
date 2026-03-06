# stdx.crypto.keys

## Functionality Overview

The keys package provides asymmetric encryption and signature algorithms, including RSA and SM2 asymmetric encryption algorithms, as well as the ECDSA signature algorithm.

Using this package requires external dependencies on OpenSSL 3's crypto dynamic library files. Therefore, relevant tools must be installed before use.

- For Linux operating systems, refer to the following methods:
    - If the system's package manager supports installing the OpenSSL 3 development toolkit, you can install it this way. Ensure the system installation directory contains the dynamic library files `libcrypto.so` and `libcrypto.so.3`. For example, on Ubuntu 22.04, you can use the command `sudo apt install libssl-dev` to install the libssl-dev toolkit.
    - If installation via the above method is not possible, download the OpenSSL 3.x.x source code and compile/install the package manually. Ensure the installation directory contains `libcrypto.so` and `libcrypto.so.3`. Then, choose one of the following methods to ensure the system linker can locate these files:
        - If OpenSSL is not installed on the system, select direct installation to the system path during installation.
        - For custom directory installations, add the directory containing these files to the environment variables `LD_LIBRARY_PATH` and `LIBRARY_PATH`.

- For Windows operating systems, follow these steps:
    - Download the OpenSSL 3.x.x source code and compile/install the x64 architecture package, or download and install a third-party precompiled OpenSSL 3.x.x package for developers.
    - Ensure the installation directory contains the library files `libcrypto.dll.a` (or `libcrypto.lib`) and `libcrypto-3-x64.dll`.
    - Add the directory path containing `libcrypto.dll.a` (or `libcrypto.lib`) to the `LIBRARY_PATH` environment variable, and add the directory path containing `libcrypto-3-x64.dll` to the `PATH` environment variable.

- For macOS operating systems, refer to the following methods:
    - Use `brew install openssl@3` to install, and ensure the system installation directory contains the dynamic library files `libcrypto.dylib` and `libcrypto.3.dylib`.
    - If installation via the above method is not possible, download the OpenSSL 3.x.x source code and compile/install the package manually. Ensure the installation directory contains `libcrypto.dylib` and `libcrypto.3.dylib`. Then, choose one of the following methods to ensure the system linker can locate these files:
        - If OpenSSL is not installed on the system, select direct installation to the system path during installation.
        - For custom directory installations, add the directory containing these files to the environment variables `DYLD_LIBRARY_PATH` and `LIBRARY_PATH`.

- For Android operating systems:
    - Since Android ships with a stripped-down version of OpenSSL by default, some interfaces may throw exceptions due to missing symbols. Therefore, users need to compile and install a complete `OpenSSL 3.x.x` version themselves.
    - Download the `OpenSSL 3.x.x` source code and use Android NDK to cross-compile dynamic library files for the target architectures (currently only `arm64-v8a` is supported). Ensure the build artifacts include `libcrypto.so` and `libcrypto.so.3`.
    - Add the directory containing these files to the environment variables `LD_LIBRARY_PATH`.

> **Note:**
>
> If the OpenSSL 3 package is not installed or a lower version is installed, the program may fail to function and throw the related exception `CryptoException: Can not load openssl library or function xxx`.

## API List

### Classes

|                 Class Name                |               Functionality               |
| ---------------------------------------- | ----------------------------------------- |
| [ECDSAPrivateKey](./keys_package_api/keys_package_classes.md#class-ecdsaprivatekey) | ECDSA private key class. |
| [ECDSAPublicKey](./keys_package_api/keys_package_classes.md#class-ecdsapublickey) | ECDSA public key class. |
| [RSAPrivateKey](./keys_package_api/keys_package_classes.md#class-rsaprivatekey) | RSA private key class. |
| [RSAPublicKey](./keys_package_api/keys_package_classes.md#class-rsapublickey) | RSA public key class. |
| [SM2PrivateKey](./keys_package_api/keys_package_classes.md#class-sm2privatekey) | SM2 private key class. |
| [SM2PublicKey](./keys_package_api/keys_package_classes.md#class-sm2publickey) | SM2 public key class. |

### Enums

| Enum Name                                                                                          | Functionality                 |
|---------------------------------------------------------------------------------------------------|-------------------------------|
| [Curve](./keys_package_api/keys_package_enums.md#enum-curve)                  | The enum `Curve` is used to select the elliptic curve type for generating ECDSA keys. |
| [PadOption](./keys_package_api/keys_package_enums.md#enum-padoption)                  | Used to set the padding mode for RSA. |

### Structs

| Struct Name                                                                                |           Functionality           |
|-------------------------------------------------------------------------------------------|-----------------------------------|
| [OAEPOption](./keys_package_api/keys_package_structs.md#struct-oaepoption)                     |  Optimal Asymmetric Encryption Padding. |
| [PSSOption](./keys_package_api/keys_package_structs.md#struct-pssoption)                     |  Probabilistic Signature Scheme. |