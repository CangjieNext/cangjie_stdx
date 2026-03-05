# 仓颉编程语言扩展库概述

仓颉编程语言扩展库（stdx）包含若干包，提供相关功能。

标准库为开发者提供了最通用的 API，而扩展库则专注于某一领域。如 compress 包提供压缩与解压缩能力，crypto 包提供加解密相关能力，net 包则专注于提供高效的网络协议解析和网络通信能力。

> **说明：**
>
> 目前，官方提供的扩展库不随仓颉编译器、工具链一起发布，需要用户单独下载。

## 平台支持说明

扩展库提供的 API 支持在如下操作系统上运行：

> **注意：**
>
> 部分 API 不支持在特定的操作系统运行，详情请参见对应 API 描述。

| 操作系统       | CPU 架构  | 环境及其版本要求 |
| ------------- | --------- | --------------- |
| Linux         | x86_64    | glibc 2.22；Linux Kernel 4.12 或更高版本；系统安装 libstdc++ 6.0.24 或更高版本 |
| Linux         | aarch64   | glibc 2.27；Linux Kernel 4.15 或更高版本；系统安装 libstdc++ 6.0.24 或更高版本 |
| Windows       | x86_64    | Windows 10 或更高版本 |
| macOS         | aarch64   | macOS 12.0 或更高版本 |
| OpenHarmony   | aarch64   | OpenHarmony 5.1 或更高版本 |
| OpenHarmony   | arm32     | OpenHarmony 5.1 或更高版本 |
| HarmonyOS     | aarch64   | HarmonyOS 5.1 或更高版本 |
| iOS           | aarch64   | iOS 11 或更高版本（ast 库需要 iOS 12 或更高版本） |
| Android       | aarch64   | Android API 26 或更高版本 |

## 使用指导

仓颉编程语言扩展库 stdx 二进制包包含静态（static）和 动态 （dynamic） 两部分，请按需引用。

### 二进制产物结构

二进制包解压出来的目录包含 dynamic 和 static 两个目录：

dynamic/stdx 是动态产物，包含动态文件、cjo、bc 文件。

static/stdx 是静态产物，包含静态文件、cjo、bc 文件。

#### 使用 Openssl 静态库链接

假设存放 Openssl 静态库的目录为 `STATIC_OPENSSL_DIR`，则命令如下。

```bash
# GNU ld64
cjc -L $STATIC_OPENSSL_DIR --link-option "-Bstatic" --link-option "--whole-archive" -lssl -lcrypto --link-option "--no-whole-archive" --link-option "-Bdynamic" main.cj

# Apple ld64
cjc -L $STATIC_OPENSSL_DIR --link-option "-force_load" --link-option "$STATIC_OPENSSL_DIR/libssl.a" --link-option "-force_load" --link-option "$STATIC_OPENSSL_DIR/libcrypto.a" main.cj
```

### 包依赖

| 导入库名                                  | 依赖包                                                                                                                                                                                                                         |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| import cangjie_stdx::actors.*                      | cangjie_stdx::actors                                                                                                                                                                                                                    |
| import cangjie_stdx::actors.macros.*               | cangjie_stdx::actors.macros                                                                                                                                                                                                             |
| import cangjie_stdx::aspectCJ.*                    | cangjie_stdx::aspectCJ                                                                                                                                                                                                                  |
| import cangjie_stdx::compress.zlib.*               | cangjie_stdx::compress.zlib                                                                                                                                                                                                             |
| import cangjie_stdx::crypto.common.*               | cangjie_stdx::crypto.common、cangjie_stdx::encoding.base64                                                                                                                                                                                       |
| import cangjie_stdx::crypto.crypto.*               | cangjie_stdx::crypto.crypto、cangjie_stdx::crypto.digest、cangjie_stdx::crypto.common、cangjie_stdx::encoding.base64                                                                                                                                               |
| import cangjie_stdx::crypto.digest.*               | cangjie_stdx::crypto.digest、cangjie_stdx::crypto.common、cangjie_stdx::encoding.base64                                                                                                                                                                   |
| import cangjie_stdx::crypto.keys.*                 | cangjie_stdx::crypto.keys、cangjie_stdx::crypto.x509、cangjie_stdx::encoding.hex、cangjie_stdx::crypto.crypto、cangjie_stdx::crypto.digest、cangjie_stdx::crypto.common、cangjie_stdx::encoding.base64                                                                                        |
| import cangjie_stdx::crypto.kit.*                  | cangjie_stdx::crypto.keys、cangjie_stdx::crypto.x509、cangjie_stdx::encoding.hex、cangjie_stdx::crypto.crypto、cangjie_stdx::crypto.digest、cangjie_stdx::crypto.common、cangjie_stdx::encoding.base64                                                                                        |
| import cangjie_stdx::crypto.x509.*                 | cangjie_stdx::crypto.x509、cangjie_stdx::encoding.hex、cangjie_stdx::crypto.crypto、cangjie_stdx::crypto.digest、cangjie_stdx::crypto.common、cangjie_stdx::encoding.base64                                                                                                          |
| import cangjie_stdx::effect.*                      | cangjie_stdx::effect                                                                                                                                                                                                                    |
| import cangjie_stdx::encoding.hex.*                | cangjie_stdx::encoding.hex                                                                                                                                                                                                              |
| import cangjie_stdx::encoding.base64.*             | cangjie_stdx::encoding.base64                                                                                                                                                                                                           |
| import cangjie_stdx::encoding.json.*               | cangjie_stdx::encoding.json、cangjie_stdx::serialization.serialization                                                                                                                                                                           |
| import cangjie_stdx::encoding.json.stream.*        | cangjie_stdx::encoding.json.stream                                                                                                                                                                                                      |
| import cangjie_stdx::encoding.url.*                | cangjie_stdx::encoding.url                                                                                                                                                                                                              |
| import cangjie_stdx::log.*                         | cangjie_stdx::log                                                                                                                                                                                                                       |
| import cangjie_stdx::logger.*                      | cangjie_stdx::logger                                                                                                                                                                                                                    |
| import cangjie_stdx::serialization.serialization.* | cangjie_stdx::serialization.serialization                                                                                                                                                                                               |
| import cangjie_stdx::syntax.*                      | cangjie_stdx::syntax                                                                                                                                                                                               |
| import cangjie_stdx::fuzz.fuzz.*                   | cangjie_stdx::fuzz.fuzz                                                                                                                                                                                                                 |
| import cangjie_stdx::net.http .*                   | cangjie_stdx::net.http、cangjie_stdx::net.tls.common、cangjie_stdx::logger、cangjie_stdx::log、cangjie_stdx::encoding.url、cangjie_stdx::encoding.json.stream、cangjie_stdx::crypto.x509、cangjie_stdx::encoding.hex、cangjie_stdx::crypto.crypto、cangjie_stdx::crypto.digest、cangjie_stdx::crypto.common、cangjie_stdx::encoding.base64 |
| import cangjie_stdx::net.tls.*                     | cangjie_stdx::net.tls、cangjie_stdx::net.tls.common、cangjie_stdx::crypto.x509、cangjie_stdx::encoding.hex、cangjie_stdx::crypto.crypto、cangjie_stdx::crypto.digest、cangjie_stdx::crypto.common、cangjie_stdx::encoding.base64                                                                       |
| import cangjie_stdx::net.tls.common.*              | cangjie_stdx::net.tls.common、cangjie_stdx::crypto.x509、cangjie_stdx::encoding.hex、cangjie_stdx::crypto.crypto、cangjie_stdx::crypto.digest、cangjie_stdx::crypto.common、cangjie_stdx::encoding.base64                                                                                     |
| import cangjie_stdx::unittest.data.*               | cangjie_stdx::encoding.json、cangjie_stdx::serialization.serialization                                                                                                                                                                           |

代码中导入上述包，用 cjc 命令去编译代码，需要严格按照上述包的依赖的顺序去链接。 如果是用 cjpm 则无需关注。

如果使用静态库，在导入 crypto 和 net 库时，由于需要依赖系统符号，所以 `Windows` 操作系统 需要额外添加 `-lcrypt32`，`Linux` 操作系统 需要额外添加 `-ldl`。

### cjc 使用命令示例

cjc 的介绍和编译请查看 cangjie 用户手册

```cangjie
import cangjie_stdx::actors.*
import cangjie_stdx::actors.macros.*
import cangjie_stdx::aspectCJ.*
import cangjie_stdx::compress.zlib.*
import cangjie_stdx::crypto.crypto.*
import cangjie_stdx::crypto.digest.*
import cangjie_stdx::crypto.keys.*
import cangjie_stdx::crypto.x509.*
import cangjie_stdx::effect.*
import cangjie_stdx::encoding.hex.*
import cangjie_stdx::encoding.base64.*
import cangjie_stdx::encoding.json.*
import cangjie_stdx::encoding.url.*
import cangjie_stdx::encoding.json.stream.*
import cangjie_stdx::net.tls.*
import cangjie_stdx::net.http.*
import cangjie_stdx::log.*
import cangjie_stdx::logger.*
import cangjie_stdx::syntax.*
import cangjie_stdx::serialization.serialization.*
main() {
    0
}
```

Linux 和 mac 的编译命令：

```shell
cjc main.cj -L $CANGJIE_STDX_PATH -lactors@cangjie_stdx -laspectCJ@cangjie_stdx -leffect@cangjie_stdx -lencoding.json@cangjie_stdx -lserialization.serialization@cangjie_stdx -lnet.http@cangjie_stdx -lnet.tls@cangjie_stdx -lnet.tls.common@cangjie_stdx -llogger@cangjie_stdx -llog@cangjie_stdx -lencoding.url@cangjie_stdx -lencoding.json.stream@cangjie_stdx -lcrypto.kit@cangjie_stdx -lcrypto.keys@cangjie_stdx -lcrypto.x509@cangjie_stdx -lencoding.hex@cangjie_stdx -lcrypto.crypto@cangjie_stdx -lcrypto.digest@cangjie_stdx -lcrypto.common@cangjie_stdx -lencoding.base64@cangjie_stdx -lcompress.zlib@cangjie_stdx -lcompress@cangjie_stdx -lsyntax@cangjie_stdx -lsyntaxFFI@cangjie_stdx -ldl --import-path $CANGJIE_STDX_PATH -o main.out
```

windows 编译命令：

```shell
cjc main.cj -L $CANGJIE_STDX_PATH -lactors@cangjie_stdx -laspectCJ@cangjie_stdx -leffect@cangjie_stdx -lencoding.json@cangjie_stdx -lserialization.serialization@cangjie_stdx -lnet.http@cangjie_stdx -lnet.tls@cangjie_stdx -lnet.tls.common@cangjie_stdx -llogger@cangjie_stdx -llog@cangjie_stdx -lencoding.url@cangjie_stdx -lencoding.json.stream@cangjie_stdx -lcrypto.kit@cangjie_stdx -lcrypto.keys@cangjie_stdx -lcrypto.x509@cangjie_stdx -lencoding.hex@cangjie_stdx -lcrypto.crypto@cangjie_stdx -lcrypto.digest@cangjie_stdx -lcrypto.common@cangjie_stdx -lencoding.base64@cangjie_stdx -lcompress.zlib@cangjie_stdx -lcompress@cangjie_stdx -lsyntax@cangjie_stdx -lsyntaxFFI@cangjie_stdx -lcrypt32 --import-path $CANGJIE_STDX_PATH -o main.out
```

CANGJIE_STDX_PATH 是设置的 stdx 路径。

例如在 linux 系统中设置：

```shell
export CANGJIE_STDX_PATH=/target/linux_x86_64_cjnative/dynamic/stdx
```

运行前 Linux 操作系统需要在 LD_LIBRARY_PATH 中设置扩展库的路径，Windows 操作系统需要在 PATH 中设置扩展库的路径，macOS 操作系统需要在 DYLD_LIBRARY_PATH 中设置扩展库的路径。

例如在 linux 系统中设置：

```shell
export LD_LIBRARY_PATH=/target/linux_x86_64_cjnative/dynamic/stdx:$LD_LIBRARY_PATH
```

### cjpm 使用示例

cjpm 的介绍和使用请查看 cjpm 手册。

cjpm.toml 增加如下配置：

```text
[target.x86_64-unknown-linux-gnu]
  [target.x86_64-unknown-linux-gnu.bin-dependencies]
    path-option = ["${CANGJIE_STDX_PATH}"]
```

上面配置中 x86_64-unknown-linux-gnu 表示的是系统架构信息，需要通过 cjc -v 获取，并替换成自己获取的系统架构信息。
CANGJIE_STDX_PATH 是设置的 stdx 路径。

## 包列表

stdx 含若干包，提供了丰富的扩展功能：

| 包名                                                                             | 功能                                                                                                                                                              |
|--------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [actors](./actors/actors_package_overview.md)                                  | actors 包提供 actor 编程模型的基础能力。                                                                                                                                     |
| [actors.macros](./actors/macros/macros_package_overview.md)                    | actors.macros 包提供把 class 变成 active object 的能力。                                                                                                                  |
| [aspectCJ](./aspectCJ/aspectCJ_package_overview.md)                            | aspectCJ 包提供 Cangjie 中面向切面编程（Aspect Oriented Programming, AOP）相关的能力。                                                                                            |
| [compress.zlib](./compress/zlib/zlib_package_overview.md)                      | compress 包提供压缩解压功能。                                                                                                                                             |
| [crypto.common](./crypto/common/crypto_common_package_overview.md)             | crypto.common 包提供了加解密相关接口。                                                                                                                                      |
| [crypto.crypto](./crypto/crypto/crypto_package_overview.md)                    | crypto 包提供安全加密能力。                                                                                                                                               |
| [crypto.digest](./crypto/digest/crypto_digest_package_overview.md)             | digest 包提供常用的消息摘要算法。                                                                                                                                            |
| [crypto.keys](./crypto/keys/keys_package_overview.md)                          | keys 包提供非对称加密和签名算法。                                                                                                                                             |
| [crypto.kit](./crypto/kit/crypto_kit_package_overview.md)                      | crypto.kit 包提供了一套 [CryptoKit](./crypto/common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-cryptokit) 的默认实现，提供随机数生成器及解码 DER、PEM 的能力。 |
| [crypto.x509](./crypto/x509/x509_package_overview.md)                          | x509 包提供处理数字证书功能。                                                                                                                                               |
| [effect](./effect/effect_package_overview.md)                                  | `cangjie_stdx::effect` 包是 Cangjie 中用于使用 Effect Handler 的用户级 API。这是一项实验性功能，需要配合支持该机制的 Cangjie 编译器使用。                                                                      |
| [encoding.base64](./encoding/base64/base64_package_overview.md)                | base 包提供字符串的 Base64 编码及解码。                                                                                                                                      |
| [encoding.hex](./encoding/hex/hex_package_overview.md)                         | hex 包提供字符串的 Hex 编码及解码。                                                                                                                                          |
| [encoding.json](./encoding/json/json_package_overview.md)                      | json 包用于对 json 数据的处理，实现 String, JsonValue, DataModel 之间的相互转换。                                                                                                   |
| [encoding.json.stream](./encoding/json_stream/json_stream_package_overview.md) | json.stream 包主要用于仓颉对象和 JSON 数据流之间的互相转换。                                                                                                                         |
| [encoding.url](./encoding/url/url_package_overview.md)                         | url 包提供了 URL 相关的能力，包括解析 URL 的各个组件，对 URL 进行编解码，合并 URL 或路径等。 。                                                                                                    |
| [fuzz](./fuzz/fuzz_package_overview.md)                                        | fuzz 包为开发者提供基于覆盖率反馈的仓颉 fuzz 引擎及对应的接口，开发者可以编写代码对 API 进行测试。                                                                                                       |
| [log](./log/log_package_overview.md)                                           | log 包提供了日志记录相关的能力。                                                                                                                                              |
| [logger](./logger/logger_package_overview.md)                                  | logger  包提供文本格式和 JSON 格式日志打印功能。                                                                                                                                 |
| [net.http](./net/http/http_package_overview.md)                                | http 包提供 HTTP/1.1，HTTP/2，WebSocket 协议的 server、client 端实现。                                                                                                       |
| [net.tls](./net/tls/tls_package_overview.md)                                   | tls 包用于进行安全加密的网络通信，提供创建 TLS 服务器、基于协议进行 TLS 握手、收发加密数据、恢复 TLS 会话等能力。                                                                                              |
| [net.tls.common](./net/tls/common/tls_common_package_overview.md)              | tls.common 包提供了 TLS 相关的抽象接口，用于适配多种 TLS 实现。                                                                                                                      |
| [serialization](./serialization/serialization_package_overview.md)             | serialization 包提供了序列化和反序列化能力。                                                                                                                                   |
| [syntax](./syntax/syntax_package_overview.md)                                  | syntax 包主要包含了仓颉源码的语法解析器和仓颉语法树节点，提供语法解析函数。                                                                                                                       |
| [unittest.data](./unittest/data/data_package_overview.md)                      | unittest 模块提供了单元测试扩展能力。                                                                                                                                         |
| [string_intern](./string_intern/string_intern_package_overview.md)             | string_intern 模块提供字符串内联缓存能力。                                                                                                                                    |
