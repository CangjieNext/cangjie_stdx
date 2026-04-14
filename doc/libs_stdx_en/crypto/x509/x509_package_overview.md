# stdx.crypto.x509

## Feature Description

The x509 package provides functionality for handling digital certificates, including parsing and serializing X509 certificates, verifying certificates, creating self-signed certificates, and generating/validating certificate chains.

This package requires external dependencies on OpenSSL 3's crypto dynamic library files. Therefore, the relevant tools must be installed before use.

- For Linux operating systems, refer to the following methods:
    - If the system's package manager supports installing the OpenSSL 3 development toolkit, you can install it this way. Ensure the system installation directory contains both `libcrypto.so` and `libcrypto.so.3` dynamic library files. For example, on Ubuntu 22.04, you can use the command `sudo apt install libssl-dev` to install the `libssl-dev` toolkit;
    - If installation via the above method is not possible, download the OpenSSL 3.x.x source code and compile/install the package manually. Ensure the installation directory contains both `libcrypto.so` and `libcrypto.so.3` dynamic library files. Then, choose one of the following methods to ensure the system linker can locate these files:
        - For systems without OpenSSL installed, select direct installation to the system path during installation;
        - For custom directory installations, add the directory containing these files to the environment variables `LD_LIBRARY_PATH` and `LIBRARY_PATH`.

- For Windows operating systems, follow these steps:
    - Download the OpenSSL 3.x.x source code and compile/install the x64 architecture package, or download and install a third-party precompiled OpenSSL 3.x.x package for developers;
    - Ensure the installation directory contains both `libcrypto.dll.a` (or `libcrypto.lib`) and `libcrypto-3-x64.dll` library files;
    - Add the directory path containing `libcrypto.dll.a` (or `libcrypto.lib`) to the `LIBRARY_PATH` environment variable, and add the directory path containing `libcrypto-3-x64.dll` to the `PATH` environment variable.

- For macOS operating systems, refer to the following methods:
    - Use `brew install openssl@3` to install, ensuring the system installation directory contains both `libcrypto.dylib` and `libcrypto.3.dylib` dynamic library files;
    - If installation via the above method is not possible, download the OpenSSL 3.x.x source code and compile/install the package manually. Ensure the installation directory contains both `libcrypto.dylib` and `libcrypto.3.dylib` dynamic library files. Then, choose one of the following methods to ensure the system linker can locate these files:
        - For systems without OpenSSL installed, select direct installation to the system path during installation;
        - For custom directory installations, add the directory containing these files to the environment variables `DYLD_LIBRARY_PATH` and `LIBRARY_PATH`.

- For Android operating systems:
    - Since Android ships with a stripped-down version of OpenSSL by default, some interfaces may throw exceptions due to missing symbols. Therefore, users need to compile and install a complete `OpenSSL 3.x.x` version themselves.
    - Download the `OpenSSL 3.x.x` source code and use Android NDK to cross-compile dynamic library files for the target architectures (currently only `arm64-v8a` is supported). Ensure the build artifacts include `libcrypto.so` and `libcrypto.so.3`.
    - Add the directory containing these files to the environment variables `LD_LIBRARY_PATH`.

> **Note:**
>
> If the OpenSSL 3 package is not installed or a lower version is installed, the program may fail to function and throw the exception `X509Exception: Can not load openssl library or function xxx`.

## API List

### Type Aliases

| Type Alias                                                      | Functionality                     |
| ------------------------------------------------------------- | -------------------------------- |
| [IP](./x509_package_api/x509_package_type.md#type-ip) | x509 uses `Array<Byte>` to represent IP addresses. |

### Classes

| Class Name                                                   | Functionality                     |
| ---------------------------------------------------------- | -------------------------------- |
| [GeneralDHParameters](./x509_package_api/x509_package_classes.md#class-generaldhparameters)       | Implementation of generic DH key parameter encryption/decryption functionality.          |
| [X509Certificate](./x509_package_api/x509_package_classes.md#class-x509certificate) | X509 digital certificates are used for encrypted communications. |
| [X509CertificateRequest](./x509_package_api/x509_package_classes.md#class-x509certificaterequest) | Certificate signing requests. |
| [X509Name](./x509_package_api/x509_package_classes.md#class-x509name) | Distinguished names for certificate entities. |

### Enums

| Enum Name                                                                                     | Functionality                     |
| ------------------------------------------------------------------------------------------- | -------------------------------- |
| [PublicKeyAlgorithm](./x509_package_api/x509_package_enums.md#enum-publickeyalgorithm)       | Public key algorithms contained in digital certificates. |
| [SignatureAlgorithm](./x509_package_api/x509_package_enums.md#enum-signaturealgorithm)       | Certificate signature algorithms. |

### Structs

| Struct Name                                                                               | Functionality                     |
| --------------------------------------------------------------------------------------- | -------------------------------- |
| [ExtKeyUsage](./x509_package_api/x509_package_structs.md#struct-extkeyusage)             | Extended fields in digital certificates. |
| [KeyUsage](./x509_package_api/x509_package_structs.md#struct-keyusage)                   | Extended fields in digital certificates typically include usage descriptions for public keys. |
| [SerialNumber](./x509_package_api/x509_package_structs.md#struct-serialnumber)          | Serial numbers for digital certificates. |
| [Signature](./x509_package_api/x509_package_structs.md#struct-signature)                | Signatures for digital certificates. |
| [VerifyOption](./x509_package_api/x509_package_structs.md#struct-verifyoption)          | Verification options. |
| [X509CertificateInfo](./x509_package_api/x509_package_structs.md#struct-x509certificateinfo) | Certificate information. |
| [X509CertificateRequestInfo](./x509_package_api/x509_package_structs.md#struct-x509certificaterequestinfo) | Certificate request information. |

### Exception Classes

| Exception Class Name                                          | Functionality                     |
| ---------------------------------------------------------- | -------------------------------- |
| [X509Exception](./x509_package_api/x509_package_exceptions.md#class-x509exception) | The exception class for the `x509` package. |
