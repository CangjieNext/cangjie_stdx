# stdx.net.tls

## Feature Description

The tls package is used for secure encrypted network communication, providing capabilities such as creating TLS servers, performing TLS handshakes based on protocols, sending/receiving encrypted data, and resuming TLS sessions.

This package supports TLS 1.2 and TLS 1.3 Transport Layer Security protocol communication.

To use this package, external dependencies on the `ssl` and `crypto` dynamic library files of `OpenSSL 3` are required. Therefore, the following tools must be installed beforehand:

- For **Linux** operating systems, refer to the following methods:
    - If the system's package manager supports installing the `OpenSSL 3` development toolkit, install it this way and ensure the system installation directory contains dynamic library files such as `libssl.so`, `libssl.so.3`, `libcrypto.so`, and `libcrypto.so.3`. For example, on `Ubuntu 22.04`, use the command `sudo apt install libssl-dev` to install the `libssl-dev` toolkit.
    - If installation via the above method is not possible, manually download the `OpenSSL 3.x.x` source code, compile, and install the package. Ensure the installation directory contains dynamic library files such as `libssl.so`, `libssl.so.3`, `libcrypto.so`, and `libcrypto.so.3`. Then, choose one of the following methods to ensure the system linker can locate these files:
        - For systems without OpenSSL installed, select the system path for installation.
        - For custom installation directories, add the directory containing these files to the environment variables `LD_LIBRARY_PATH` and `LIBRARY_PATH`.
- For **Windows** operating systems, follow these steps:
    - Manually download the `OpenSSL 3.x.x` source code, compile, and install the x64 architecture package, or download and install a third-party precompiled `OpenSSL 3.x.x` package for developers.
    - Ensure the installation directory contains library files such as `libssl.dll.a` (or `libssl.lib`), `libssl-3-x64.dll`, `libcrypto.dll.a` (or `libcrypto.lib`), and `libcrypto-3-x64.dll`.
    - Add the directory paths containing `libssl.dll.a` (or `libssl.lib`) and `libcrypto.dll.a` (or `libcrypto.lib`) to the `LIBRARY_PATH` environment variable. Add the directory paths containing `libssl-3-x64.dll` and `libcrypto-3-x64.dll` to the `PATH` environment variable.
- For **macOS** operating systems, refer to the following methods:
    - Use `brew install openssl@3` to install and ensure the system installation directory contains the dynamic library files `libcrypto.dylib` and `libcrypto.3.dylib`.
    - If installation via the above method is not possible, manually download the `OpenSSL 3.x.x` source code, compile, and install the package. Ensure the installation directory contains the dynamic library files `libcrypto.dylib` and `libcrypto.3.dylib`. Then, choose one of the following methods to ensure the system linker can locate these files:
        - For systems without OpenSSL installed, select the system path for installation.
        - For custom installation directories, add the directory containing these files to the environment variables `DYLD_LIBRARY_PATH` and `LIBRARY_PATH`.
- For **Android** operating systems:
    - Since `Android` ships with a stripped-down version of `OpenSSL` by default, some interfaces may throw exceptions due to missing symbols. Therefore, users need to compile and install a complete `OpenSSL 3.x.x` version themselves.
    - Download the `OpenSSL 3.x.x` source code and use Android NDK to cross-compile dynamic library files for the target architectures (currently only `arm64-v8a` is supported). Ensure the build artifacts include `libssl.so`, `libssl.so.3`, `libcrypto.so`, and `libcrypto.so.3`.
    - Add the directory containing these files to the environment variables `LD_LIBRARY_PATH`.
- For **HarmonyOS** operating systems:
    - Due to system restrictions in `HarmonyOS` 6.0 and above, `stdx` cannot directly access the system's built-in `OpenSSL`, users need to compile `OpenSSL` dynamic libraries for `HarmonyOS` and package them into the application.
    - For compiling `OpenSSL` for `HarmonyOS`, refer to [OHOS Cangjie SDK Build Guide](https://gitcode.com/Cangjie/cangjie_build/blob/main/docs/linux_ohos_toolchain.md).
    - Package the compiled dynamic library files `libcrypto_openssl.z.so` and `libssl_openssl.z.so` into the application and ensure they can be correctly loaded at runtime.

> **Note:**
>
> If the `OpenSSL 3` package is not installed or a lower version is installed, the program may fail to function and throw the exception `TlsException: Can not load openssl library or function xxx.`.

## API List

### Classes

| Class Name                                                                                | Functionality                                                                                                                                                       |
| ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [DefaultTlsKit](./tls_package_api/tls_package_classes.md#class-defaulttlskit)             | Default implementation of [TlsKit](../tls/common/tls_common_package_api/tls_common_package_interfaces.md#interface-tlskit). Used to obtain TLS server, client connections and server sessions. |
| [KeylessTlsServerConfig](./tls_package_api/tls_package_classes.md#class-keylesstlsserverconfig) | Keyless server configuration.       |
| [TlsClientSession](./tls_package_api/tls_package_classes.md#class-tlsclientsession)      | After successful TLS handshake on the client side, a session is generated. If the connection is lost for some reason, the client can reuse this session ID to resume the session, skipping the handshake process. |
| [TlsServerSession](./tls_package_api/tls_package_classes.md#class-tlsserversession)       | The server enables session resumption feature, storing sessions for client authentication purposes.                                                              |
| [TlsSocket](./tls_package_api/tls_package_classes.md#class-tlssocket)                     | Used to create encrypted transmission channels between client and server.                                                                                          |

### Enums

| Enum Name                                                                                                 | Functionality                                                                 |
| -------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| [SignatureAlgorithm](./tls_package_api/tls_package_enums.md#enum-signaturealgorithm)                     | Types of signature algorithms, used to ensure data authentication, integrity, and authenticity during transmission. |
| [SignatureSchemeType](./tls_package_api/tls_package_enums.md#enum-signatureschemetype)                   | Types of encryption algorithms, used to protect the security and privacy of network communications.               |
| [SignatureType](./tls_package_api/tls_package_enums.md#enum-signaturetype)                               | Types of signature algorithms, used for authenticity verification.                                               |
| [TlsClientIdentificationMode](./tls_package_api/tls_package_enums.md#enum-tlsclientidentificationmode)   | Server-side authentication modes for client certificates.                                                        |

### Structs

| Struct Name                                                                           | Functionality         |
| ------------------------------------------------------------------------------------ | -------------------- |
| [CipherSuite](./tls_package_api/tls_package_structs.md#struct-ciphersuite)           | Cipher suites in TLS. |
| [TlsClientConfig](./tls_package_api/tls_package_structs.md#struct-tlsclientconfig)   | Client configuration. |
| [TlsServerConfig](./tls_package_api/tls_package_structs.md#struct-tlsserverconfig)   | Server configuration. |

### Type Aliases

| Type Alias                                              | Functionality                             |
| ----------------------------------------------------- | -------------------------------- |
| [KeylessDecryptFunc](./tls_package_api/tls_package_type.md#type-keylessdecryptfunc) | Decryption callback function type for keyless handshake. |
| [KeylessSignFunc](./tls_package_api/tls_package_type.md#type-keylesssignfunc) | Signature callback function type for keyless handshake. |
