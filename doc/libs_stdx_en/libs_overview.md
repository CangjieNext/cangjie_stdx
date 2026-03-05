# Cangjie Programming Language Extension Library Overview

The Cangjie programming language extension library (stdx) contains several packages that provide related functionalities.

The standard library offers the most commonly used APIs for developers, while the extension library focuses on specific domains. For example, the `compress` package provides compression and decompression capabilities, the `crypto` package offers encryption and decryption functionalities, and the `net` package specializes in efficient network protocol parsing and communication.

> **Note:**
>
> Currently, the officially provided extension libraries are not bundled with the Cangjie compiler and toolchain. Users need to download them separately.

## Usage Guide

The Cangjie programming language extension library stdx binary package includes both static and dynamic components. Please reference them as needed.

### Binary Artifact Structure

The extracted directory of the binary package contains two subdirectories: `dynamic` and `static`:

- `dynamic/stdx` contains dynamic artifacts, including dynamic files, cjo, and bc files.
- `static/stdx` contains static artifacts, including static files, cjo, and bc files.

#### Linking with OpenSSL static libraries

Assume the OpenSSL static libraries are located in `STATIC_OPENSSL_DIR`. Use the following commands.

```bash
# GNU ld64
cjc -L $STATIC_OPENSSL_DIR --link-option "-Bstatic" --link-option "--whole-archive" -lssl -lcrypto --link-option "--no-whole-archive" --link-option "-Bdynamic" main.cj

# Apple ld64
cjc -L $STATIC_OPENSSL_DIR --link-option "-force_load" --link-option "$STATIC_OPENSSL_DIR/libssl.a" --link-option "-force_load" --link-option "$STATIC_OPENSSL_DIR/libcrypto.a" main.cj
```

### Package Dependencies

| Import Library Name                                                            |  Dependent Packages |
| ------------------------------------------------------------------ | ------------------    |
| import cangjie_stdx::actors.* | cangjie_stdx::actors |
| import cangjie_stdx::actors.macros.* | cangjie_stdx::actors.macros |
| import cangjie_stdx::aspectCJ.* | cangjie_stdx::aspectCJ |
| import cangjie_stdx::compress.zlib.* | cangjie_stdx::compress.zlib |
| import cangjie_stdx::crypto.common.* | cangjie_stdx::crypto.common、cangjie_stdx::encoding.base64 |
| import cangjie_stdx::crypto.crypto.* | cangjie_stdx::crypto.crypto、cangjie_stdx::crypto.digest |
| import cangjie_stdx::crypto.digest.* | cangjie_stdx::crypto.digest |
| import cangjie_stdx::crypto.keys.* | cangjie_stdx::crypto.keys、cangjie_stdx::crypto.x509、cangjie_stdx::encoding.hex、cangjie_stdx::encoding.base64、cangjie_stdx::crypto.crypto、cangjie_stdx::crypto.digest |
| import cangjie_stdx::crypto.kit.*  | cangjie_stdx::crypto.keys、cangjie_stdx::crypto.x509、cangjie_stdx::encoding.hex、cangjie_stdx::crypto.crypto、cangjie_stdx::crypto.digest、cangjie_stdx::crypto.common、cangjie_stdx::encoding.base64 |
| import cangjie_stdx::crypto.x509.* | cangjie_stdx::crypto.x509、cangjie_stdx::encoding.hex、cangjie_stdx::encoding.base64、cangjie_stdx::crypto.crypto、cangjie_stdx::crypto.digest |
| import cangjie_stdx::effect.*   | cangjie_stdx::effect |
| import cangjie_stdx::encoding.hex.* | cangjie_stdx::encoding.hex |
| import cangjie_stdx::encoding.base64.* | cangjie_stdx::encoding.base64 |
| import cangjie_stdx::encoding.json.* | cangjie_stdx::encoding.json、cangjie_stdx::serialization.serialization |
| import cangjie_stdx::encoding.json.stream.* | cangjie_stdx::encoding.json.stream|
| import cangjie_stdx::encoding.url.* | cangjie_stdx::encoding.url |
| import cangjie_stdx::log.* | cangjie_stdx::log |
| import cangjie_stdx::logger.* | cangjie_stdx::logger |
| import cangjie_stdx::serialization.serialization.* | cangjie_stdx::serialization.serialization |
| import cangjie_stdx::fuzz.fuzz.* | cangjie_stdx::fuzz.fuzz |
| import cangjie_stdx::net.http .* | cangjie_stdx::net.http、cangjie_stdx::net.tls、cangjie_stdx::logger、cangjie_stdx::log、cangjie_stdx::encoding.url、cangjie_stdx::encoding.json.stream、cangjie_stdx::crypto.x509 、cangjie_stdx::encoding.hex、cangjie_stdx::encoding.base64、cangjie_stdx::crypto.crypto、cangjie_stdx::crypto.digest |
| import cangjie_stdx::net.tls.* | cangjie_stdx::net.tls、cangjie_stdx::crypto.x509、cangjie_stdx::encoding.hex、cangjie_stdx::encoding.base64、cangjie_stdx::crypto.crypto、cangjie_stdx::crypto.digest |
| import cangjie_stdx::net.tls.common.* | cangjie_stdx::net.tls.common、cangjie_stdx::crypto.x509、cangjie_stdx::encoding.hex、cangjie_stdx::crypto.crypto、cangjie_stdx::crypto.digest、cangjie_stdx::crypto.common、cangjie_stdx::encoding.base64 |
| import cangjie_stdx::unittest.data.* | cangjie_stdx::encoding.json、cangjie_stdx::serialization.serialization |

When importing the above packages in code and compiling with the `cjc` command, the linking order must strictly follow the package dependencies listed above. If using `cjpm`, this is not necessary.

When using static libraries, importing `crypto` and `net` libraries requires additional system symbols. On `Windows` OS, add `-lcrypt32`, and on `Linux` OS, add `-ldl`.

### cjc Command Example

For an introduction to `cjc` and compilation, refer to the Cangjie User Manual.

```cangjie
import cangjie_stdx::actors.*
import cangjie_stdx::actors.macros.*
import cangjie_stdx::aspectCJ.*
import cangjie_stdx::compress.zlib.*
import cangjie_stdx::crypto.crypto.*
import cangjie_stdx::crypto.digest.*
import cangjie_stdx::crypto.keys.*
import cangjie_stdx::crypto.x509.*
import cangjie_stdx::encoding.hex.*
import cangjie_stdx::encoding.base64.*
import cangjie_stdx::encoding.json.*
import cangjie_stdx::encoding.url.*
import cangjie_stdx::encoding.json.stream.*
import cangjie_stdx::net.tls.*
import cangjie_stdx::net.http.*
import cangjie_stdx::log.*
import cangjie_stdx::logger.*
import cangjie_stdx::serialization.serialization.*
main() {
    0
}
```

Compilation commands for Linux and macOS:

```shell
cjc main.cj -L $CANGJIE_STDX_PATH -lactors@cangjie_stdx -laspectCJ@cangjie_stdx -lencoding.json@cangjie_stdx -lserialization.serialization@cangjie_stdx -lnet.http@cangjie_stdx -lnet.tls@cangjie_stdx -llogger@cangjie_stdx -llog@cangjie_stdx -lencoding.url@cangjie_stdx -lencoding.json.stream@cangjie_stdx -lcrypto.keys@cangjie_stdx -lcrypto.x509@cangjie_stdx -lencoding.hex@cangjie_stdx -lencoding.base64@cangjie_stdx -lcrypto.crypto@cangjie_stdx -lcrypto.digest@cangjie_stdx -lcompress.zlib@cangjie_stdx -lcompress@cangjie_stdx -ldl --import-path $CANGJIE_STDX_PATH -o main.out
```

Windows compilation command:

```shell
cjc main.cj -L $CANGJIE_STDX_PATH -lactors@cangjie_stdx -laspectCJ@cangjie_stdx -lencoding.json@cangjie_stdx -lserialization.serialization@cangjie_stdx -lnet.http@cangjie_stdx -lnet.tls@cangjie_stdx -llogger@cangjie_stdx -llog@cangjie_stdx -lencoding.url@cangjie_stdx -lencoding.json.stream@cangjie_stdx -lcrypto.keys@cangjie_stdx -lcrypto.x509@cangjie_stdx -lencoding.hex@cangjie_stdx -lencoding.base64@cangjie_stdx -lcrypto.crypto@cangjie_stdx -lcrypto.digest@cangjie_stdx -lcompress.zlib@cangjie_stdx -lcompress@cangjie_stdx -lcrypt32 --import-path $CANGJIE_STDX_PATH -o main.out
```

`CANGJIE_STDX_PATH` is the path to the stdx library.

For example, on Linux systems:

```shell
export CANGJIE_STDX_PATH=/target/linux_x86_64_cjnative/dynamic/stdx
```

Before running, ensure the extension library path is set:

- On Linux: Set in `LD_LIBRARY_PATH`
- On Windows: Set in `PATH`
- On macOS: Set in `DYLD_LIBRARY_PATH`

### cjpm Usage Example

For an introduction to `cjpm` and usage, refer to the cjpm manual.

Add the following configuration to `cjpm.toml`:

```text
[target.x86_64-unknown-linux-gnu]
  [target.x86_64-unknown-linux-gnu.bin-dependencies]
    path-option = ["${CANGJIE_STDX_PATH}"]
```

In the above configuration, `x86_64-unknown-linux-gnu` represents the system architecture information, which can be obtained via `cjc -v`. Replace it with your system's architecture information.
`CANGJIE_STDX_PATH` is the path to the stdx library.

## Package List

stdx includes several packages that offer rich extension functionalities:

| Package Name                                                     | Functionality      |
| ---------------------------------------------------------- | --------- |
| [actors](./actors/actors_package_overview.md)    | The `actors` package provides the foundational capabilities for the actor programming model. |
| [actors.macros](./actors/macros/macros_package_overview.md) | The `actors.macros` package provides the ability to transform a class into an active object. |
| [aspectCJ](./aspectCJ/aspectCJ_package_overview.md) | The aspectCJ package provides Aspect-Oriented Programming (AOP) capabilities in Cangjie. |
| [compress.zlib](./compress/zlib/zlib_package_overview.md)                        | The compress package provides compression and decompression functionalities. |
| [crypto.common](./crypto/common/crypto_common_package_overview.md)             | The common package provides interfaces related to encryption and decryption.  |
| [crypto.crypto](./crypto/crypto/crypto_package_overview.md)                        | The crypto package provides secure encryption capabilities. |
| [crypto.digest](./crypto/digest/crypto_digest_package_overview.md)                        | The digest package provides commonly used message digest algorithms. |
| [crypto.keys](./crypto/keys/keys_package_overview.md)                        | The keys package provides asymmetric encryption and signature algorithms. |
| [crypto.kit](./crypto/kit/crypto_kit_package_overview.md)                      | The kit package provides a default implementation of [CryptoKit](./crypto/common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-cryptokit), along with the capabilities of a random number generator and decoding DER and PEM. |
| [crypto.x509](./crypto/x509/x509_package_overview.md)                        | The x509 package provides functionalities for handling digital certificates. |
| [effect](./effect/effect_package_overview.md)                                | The effect package is a user-level API in Cangjie for using Effect Handlers. It is an experimental feature and requires the use of a Cangjie compiler that supports this mechanism. |
| [encoding.base64](./encoding/base64/base64_package_overview.md)                        | The base package provides Base64 encoding and decoding for strings.|
| [encoding.hex](./encoding/hex/hex_package_overview.md)                        | The hex package provides Hex encoding and decoding for strings.|
| [encoding.json](./encoding/json/json_package_overview.md)                        | The json package is used for processing JSON data, enabling mutual conversion between String, JsonValue, and DataModel.|
| [encoding.json.stream](./encoding/json_stream/json_stream_package_overview.md)                        | The json.stream package is primarily used for mutual conversion between Cangjie objects and JSON data streams.|
| [encoding.url](./encoding/url/url_package_overview.md)                        | The url package provides URL-related capabilities, including parsing URL components, encoding and decoding URLs, and merging URLs or paths.|
| [fuzz](./fuzz/fuzz_package_overview.md)                        | The fuzz package provides developers with a coverage-guided fuzz engine for Cangjie and corresponding interfaces, allowing developers to write code to test APIs. |
| [log](./log/log_package_overview.md) | The log package provides logging-related capabilities. |
| [logger](./logger/logger_package_overview.md) | The logger package provides text and JSON format logging functionalities. |
| [net.http](./net/http/http_package_overview.md)                        | The http package provides server and client implementations for HTTP/1.1, HTTP/2, and WebSocket protocols. |
| [net.tls](./net/tls/tls_package_overview.md)                        | The tls package is used for secure encrypted network communication, providing capabilities such as creating TLS servers, performing TLS handshakes based on protocols, sending and receiving encrypted data, and resuming TLS sessions.|
| [net.tls.common](./net/tls/common/tls_common_package_overview.md)   | The common package provides TLS-related abstract interfaces for adapting to multiple TLS implementations. |
| [serialization](./serialization/serialization_package_overview.md)                        | The serialization package provides serialization and deserialization capabilities. |
| [unittest.data](./unittest/data/data_package_overview.md)                        | The unittest module provides extended unit testing capabilities. |
