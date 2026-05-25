# cangjie_stdx 对 OpenSSL 的依赖方式分析报告

## 一、概述

cangjie_stdx（仓颉语言扩展标准库）在加密、TLS/SSL、证书处理等核心功能上深度依赖 OpenSSL 库。项目采用了一套精心设计的 **运行时动态加载（dlopen/dlsym）+ 弱符号回退 + 强链接模式** 三种机制来引用 OpenSSL，提供两种产物变体供用户选择：

1. **默认变体**：运行时动态加载 OpenSSL，用户需自行安装 OpenSSL 3.x 共享库
2. **Strong 变体**：编译时静态链接 OpenSSL，用户无需安装 OpenSSL，但需在构建时提供 OpenSSL 静态库

## 二、版本要求

| 项目 | 要求 |
|------|------|
| OpenSSL 版本 | **≥ 3.0**（`find_package(OpenSSL 3 REQUIRED COMPONENTS Crypto SSL)`） |
| 环境变量 | 需配置 `OPENSSL_ROOT_DIR` 指向 OpenSSL 安装根目录 |

来源：`build/common/modules/PrepareOpenSSL.cmake:60` 和 `doc/libs_stdx/source_code_dependency.md`

## 三、链接方式：始终动态链接

### 3.1 设计决策

`build/common/modules/PrepareOpenSSL.cmake` 第 45-53 行有明确注释：

> *"Due to the vulnerability of OpenSSL library, we always link against shared libraries. Users are able to update OpenSSL by simply replace their local OpenSSL library with a later version."*

即：**出于安全漏洞考虑，始终链接 OpenSSL 动态库（.so/.dylib/.dll.a），不链接静态库**。用户只需替换系统中的 OpenSSL 共享库文件即可完成版本升级，无需重新编译 stdx。

### 3.2 各平台链接配置

| 平台 | 库查找后缀 | 链接方式 |
|------|-----------|----------|
| **Linux** | `.so` | `-L<dir> -l:<filename>` |
| **macOS** | `.dylib` | `-L<dir> -lcrypto` / `-lssl -lcrypto`（macOS ld 不支持 `-l:` 语法） |
| **Windows (MinGW)** | `.lib` / `.dll.a` | `-L<dir> -l:<filename>` |
| **OHOS** | N/A（手动指定） | `-lcrypto_openssl.z` / `-lssl_openssl.z -lcrypto_openssl.z` |
| **Android** | N/A（跳过查找） | `-lcrypto` / `-lssl -lcrypto` |

### 3.3 CMake 选项

`CMakeLists.txt` 第 40 行提供了 `CANGJIE_SKIP_FIND_OPENSSL` 选项：

```cmake
option(CANGJIE_SKIP_FIND_OPENSSL "Do not look for OpenSSL package, OpenSSL library will be searched by linker" OFF)
```

- **OFF（默认）**：调用 `PrepareOpenSSL.cmake` 查找 OpenSSL 3+ 并配置链接选项
- **ON**：跳过查找，仅设置 `-lcrypto` / `-lssl -lcrypto`，由链接器在构建时自行搜索（适用于 Android 等特殊平台）

## 四、核心架构：dynamicLoader 动态加载模块

### 4.1 设计动机

stdx 不直接调用 OpenSSL API，而是通过 `src/stdx/dynamicLoader` 模块在运行时动态加载 OpenSSL 符号。这种设计带来以下优势：

1. **解耦编译时依赖**：构建 stdx 时需要 OpenSSL 头文件，但运行时 OpenSSL 库可以不存在（功能降级而非崩溃）
2. **灵活的符号解析**：支持两种模式（普通模式 / Auto 模式），适配不同的部署场景
3. **安全升级**：始终动态链接，用户可随时替换 OpenSSL 版本

### 4.2 模块结构

```
src/stdx/dynamicLoader/
├── opensslSymbols.h      # 头文件，声明所有 DYN_* 动态加载函数
├── opensslSymbols.c      # 实现文件，dlopen/dlsym 加载逻辑
├── defineFunction.inc    # 宏定义文件，定义 200+ 个 OpenSSL 函数的动态加载包装
├── declareFunction.inc   # 对应的声明宏文件
└── CMakeLists.txt        # 构建配置
```

### 4.3 三种解析模式

#### 模式一：普通模式（共享库构建）

- 编译时不定义 `CANGJIE_OPENSSL_RESOLVE_AUTO` 或 `CANGJIE_OPENSSL_RESOLVE_STRONG`
- 库加载时（`__attribute__((constructor))`）自动调用 `dlopen` 加载 OpenSSL 共享库
- 所有 OpenSSL API 通过 `dlsym` 查找
- 用于**共享库（.so/.dylib/.dll）** 产物
- 运行时**必须**有 OpenSSL 3.x 共享库

#### 模式二：Auto 模式（默认静态库构建）

- 编译时定义 `CANGJIE_OPENSSL_RESOLVE_AUTO=1`
- 使用 GCC/Clang 的 `#pragma weak` 弱符号机制：
  - **优先**使用直接链接的 OpenSSL 符号（如果用户程序链接了 OpenSSL）
  - **回退**到 `dlopen/dlsym` 运行时查找
- 用于**默认静态库（.a）** 产物，使静态 stdx 可以在有无 OpenSSL 的环境中均能链接成功
- 运行时仍需 OpenSSL 共享库（除非用户程序自身静态链接了 OpenSSL）

#### 模式三：Strong 模式（强链接静态库构建）🆕

- 编译时定义 `CANGJIE_OPENSSL_RESOLVE_STRONG=1`
- **直接引用** OpenSSL 符号，不使用 `dlopen/dlsym`，不使用弱符号
- 所有 OpenSSL API 在编译时即绑定到具体的函数地址
- 用于 **Strong 变体静态库（`libstdx.*-strong.a`）** 产物
- **构建时**必须链接 OpenSSL 静态库（libcrypto.a / libssl.a）
- **运行时**无需系统安装 OpenSSL 共享库

来源：`src/stdx/dynamicLoader/opensslSymbols.c` 第 242-325 行（Auto/Strong 模式定义）

### 4.4 各平台加载的库文件名

| 平台 | libcrypto | libssl | 回退 |
|------|-----------|--------|------|
| **Windows** | `libcrypto-3-x64.dll` | `libssl-3-x64.dll` | 无 |
| **macOS** | `libcrypto.3.dylib` | `libssl.3.dylib` | `libcrypto.dylib` / `libssl.dylib` |
| **OHOS** | `libcrypto_openssl.z.so` | `libssl_openssl.z.so` | 无 |
| **Linux** | `libcrypto.so.3` | `libssl.so.3` | `libcrypto.so` / `libssl.so` |

来源：`src/stdx/dynamicLoader/opensslSymbols.c` 第 22-38 行

### 4.5 符号查找流程

#### 普通模式 / Auto 模式

```
FindFunction(name)
  │
  ├─ [Auto模式 + RTLD_DEFAULT可用] → 先尝试 dlsym(RTLD_DEFAULT, name)
  │   └─ 成功 → 返回（静态链接的符号优先）
  │
  ├─ [g_singletonHandle 为空] → 调用 EnsureLoaded() 执行 dlopen
  │
  ├─ dlsym(g_singletonHandle, name)  ← 在 libcrypto 中查找
  │   └─ 成功 → 返回
  │
  └─ dlsym(g_singletonHandleSsl, name)  ← 在 libssl 中查找
      └─ 成功 → 返回
      └─ 失败 → 返回 NULL（DynMsg.found = false）
```

#### Strong 模式 🆕

```
FINDFUNCTIONI(dynMsg, index, name, errCode)
  │
  ├─ 从原子缓存 funcBits##index 读取
  │   └─ 命中 → 直接返回缓存的函数指针
  │
  └─ 缓存未命中 → func##index = (SSLFunc##index)(name)
      │  直接引用编译时链接的 OpenSSL 符号（非 dlsym）
      ├─ PublishCachedFunctionBits() 写入原子缓存
      └─ CHECKFUNCTION → 符号为 NULL 则返回 errCode
```

Strong 模式的关键区别：
- **无 dlopen/dlsym**：不尝试运行时加载，所有符号必须在编译时可见
- **原子缓存**：使用 `_Atomic(uintptr_t)` 缓存已解析的函数指针，线程安全且避免重复查找
- **CJ_OpenSSL_SetPath 为空操作**：Strong 模式下该函数直接返回 0，因为不需要指定动态库路径

### 4.6 动态加载的 OpenSSL API 清单

`src/stdx/dynamicLoader/defineFunction.inc` 通过宏定义了约 **200+** 个 OpenSSL 函数的动态加载包装，涵盖以下类别：

| 类别 | 典型函数 | 数量（约） |
|------|---------|-----------|
| **对称加密** | `EVP_EncryptInit_ex`, `EVP_DecryptInit_ex`, `EVP_sm4_cbc`, `EVP_aes_256_cbc` | 15+ |
| **摘要算法** | `EVP_DigestInit_ex`, `EVP_sha256`, `EVP_md5`, `SHA256_Init` | 25+ |
| **HMAC** | `HMAC_CTX_new`, `HMAC_Init_ex`, `HMAC_Update`, `HMAC_Final` | 5 |
| **非对称加密/签名** | `EVP_PKEY_keygen`, `EVP_PKEY_encrypt`, `EVP_PKEY_sign`, `EVP_PKEY_verify` | 25+ |
| **RSA 特定** | `EVP_PKEY_CTX_set_rsa_padding`, `EVP_PKEY_CTX_set_rsa_oaep_md` | 8 |
| **EC 特定** | `EVP_PKEY_CTX_set_ec_paramgen_curve_nid` | 1 |
| **X509 证书** | `X509_new`, `X509_sign`, `d2i_X509`, `PEM_read_bio_X509` | 30+ |
| **SSL/TLS** | `SSL_CTX_new`, `SSL_new`, `SSL_read`, `SSL_write`, `SSL_do_handshake` | 35+ |
| **BIO I/O** | `BIO_new`, `BIO_read`, `BIO_write`, `BIO_ctrl` | 15+ |
| **Provider (3.0+)** | `OSSL_PROVIDER_load`, `OSSL_PARAM_construct_*` | 10+ |
| **PKCS** | `i2d_PKCS8PrivateKey_bio`, `d2i_PKCS8PrivateKey_bio` | 8+ |
| **随机数** | `RAND_bytes`, `RAND_priv_bytes` | 2 |
| **大数运算** | `BN_new`, `BN_bin2bn`, `BN_mod_exp` | 8+ |
| **错误处理** | `ERR_get_error`, `ERR_reason_error_string` | 4 |
| **内存管理** | `CRYPTO_malloc`, `CRYPTO_free`, `OPENSSL_cleanse` | 6+ |

## 五、依赖 OpenSSL 的模块清单

### 5.1 直接依赖模块

| 模块 | 包名 | 依赖方式 | 使用的 OpenSSL 功能 |
|------|------|---------|-------------------|
| **dynamicLoader** | `cangjie-dynamicLoader-opensslFFI` | 核心封装层 | 所有 OpenSSL 符号的动态加载 |
| **net.tls** | `stdx.net.tls` | 依赖 `opensslFFI-shared` + `tlsFFI-shared` | SSL/TLS 协议、证书验证、会话管理 |
| **net.http** | `stdx.net.http` | 依赖 `opensslFFI-shared` | HTTPS/TLS 连接 |
| **crypto.digest** | `stdx.crypto.digest` | 依赖 `opensslFFI-shared` | MD5/SHA/HMAC/SM3 摘要算法 |
| **crypto.keys** | `stdx.crypto.keys` | 依赖 `opensslFFI-shared` + `keysFFI-shared` | RSA/EC/SM2 密钥操作、PKCS |
| **crypto.crypto** | `stdx.crypto.crypto` | 依赖 `opensslFFI-shared` | SM4/AES 对称加密、安全随机数 |
| **crypto.x509** | `stdx.crypto.x509` | 依赖 `opensslFFI-shared` + `x509FFI-shared` | X509 证书解析/生成/验证 |

### 5.2 间接依赖模块

| 模块 | 包名 | 间接依赖路径 |
|------|------|-------------|
| **net.tls.common** | `stdx.net.tls.common` | ← net.tls |
| **crypto.common** | `stdx.crypto.common` | ← crypto.digest / crypto.keys |
| **crypto.kit** | `stdx.crypto.kit` | ← crypto.common + crypto.keys + crypto.crypto + crypto.x509 |

### 5.3 不依赖 OpenSSL 的模块

actors、aspectCJ、compress（zlib/tar）、effect、encoding（hex/base64/json/url）、fuzz、log、logger、serialization、string_intern、syntax、unittest、chir

## 六、构建系统集成

### 6.1 CMake 构建流程

```
CMakeLists.txt (根)
  │
  ├─ option(CANGJIE_SKIP_FIND_OPENSSL)  ← 控制是否查找 OpenSSL
  ├─ set(CANGJIE_OPENSSL_FFI_OBJECTS_TARGET "cangjie-dynamicLoader-opensslFFI-auto-objs")
  │
  └─ include(PrepareOpenSSL)  ← 查找 OpenSSL 3+，设置链接选项
       ├─ OHOS: -lcrypto_openssl.z / -lssl_openssl.z
       └─ 其他: find_package(OpenSSL 3) → OPENSSL_CRYPTO_LINK_OPTIONS / OPENSSL_SSL_LINK_OPTIONS
```

### 6.2 dynamicLoader 构建产物

`src/stdx/dynamicLoader/CMakeLists.txt` 生成以下产物：

| 产物 | 用途 | 编译定义 |
|------|------|---------|
| `cangjie-dynamicLoader-opensslFFI-objs` | 普通模式对象库 | 无特殊定义 |
| `cangjie-dynamicLoader-opensslFFI-auto-objs` | Auto 模式对象库 | `CANGJIE_OPENSSL_RESOLVE_AUTO=1` |
| `cangjie-dynamicLoader-opensslFFI-strong-objs` 🆕 | Strong 模式对象库 | `CANGJIE_OPENSSL_RESOLVE_STRONG=1` |
| `cangjie-dynamicLoader-opensslFFI` (静态库) | 合并 auto-objs | 用于默认静态库合并 |
| `cangjie-dynamicLoader-opensslFFI-strong` (静态库) 🆕 | 合并 strong-objs | 用于 Strong 变体静态库合并 |
| `cangjie-dynamicLoader-opensslFFI-shared` (共享库) | 合并普通 objs | 用于共享库链接 |

### 6.3 静态库合并策略

#### 默认变体（Auto 模式）

静态库构建时，将 `cangjie-dynamicLoader-opensslFFI-auto-objs` 的对象文件合并到各模块的静态库中。例如 `libstdx.net.tls.a` 包含：

```
libstdx.net.tls.a
  ├─ stdx.net.tlsFFI-objs      (TLS FFI 实现)
  ├─ stdx/net.tls.o            (仓颉编译产物)
  └─ cangjie-dynamicLoader-opensslFFI-auto-objs  (OpenSSL 动态加载器，Auto 模式)
```

#### Strong 变体 🆕

Strong 变体使用 `cangjie-dynamicLoader-opensslFFI-strong-objs` 合并到独立的 `-strong.a` 静态库中。例如 `libstdx.net.tls-strong.a` 包含：

```
libstdx.net.tls-strong.a
  ├─ stdx.net.tlsFFI-objs      (TLS FFI 实现，与默认变体相同)
  ├─ stdx/net.tls.o            (仓颉编译产物，与默认变体相同)
  └─ cangjie-dynamicLoader-opensslFFI-strong-objs  (OpenSSL 强链接加载器，Strong 模式)
```

Strong 变体的所有模块产物列表：

| 默认产物 | Strong 产物 | 说明 |
|---------|------------|------|
| `libcangjie-dynamicLoader-opensslFFI.a` | `libcangjie-dynamicLoader-opensslFFI-strong.a` | OpenSSL FFI 桥接库 |
| `libstdx.net.tlsFFI.a` | `libstdx.net.tlsFFI-strong.a` | TLS FFI 库 |
| `libstdx.crypto.keysFFI.a` | `libstdx.crypto.keysFFI-strong.a` | 密钥 FFI 库 |
| `libstdx.crypto.x509FFI.a` | `libstdx.crypto.x509FFI-strong.a` | X509 FFI 库 |
| `libstdx.net.tls.a` | `libstdx.net.tls-strong.a` | TLS 包静态库 |
| `libstdx.crypto.digest.a` | `libstdx.crypto.digest-strong.a` | 摘要包静态库 |
| `libstdx.crypto.keys.a` | `libstdx.crypto.keys-strong.a` | 密钥包静态库 |
| `libstdx.crypto.crypto.a` | `libstdx.crypto.crypto-strong.a` | 加密包静态库 |
| `libstdx.crypto.x509.a` | `libstdx.crypto.x509-strong.a` | X509 包静态库 |

### 6.4 Strong 变体安装布局 🆕

Strong 变体的静态库安装到独立目录，与默认变体共存互不干扰：

```
安装根目录/
  ├─ <triple>_cjnative/static/stdx/          ← 默认变体（Auto 模式）
  │    ├─ libcangjie-dynamicLoader-opensslFFI.a
  │    ├─ libstdx.net.tls.a
  │    ├─ libstdx.crypto.digest.a
  │    └─ ...
  │
  └─ <triple>_cjnative/static-static-link-extern/stdx/  ← Strong 变体 🆕
       ├─ libcangjie-dynamicLoader-opensslFFI.a    (实际是 -strong 版本)
       ├─ libstdx.net.tlsFFI.a                     (实际是 -strong 版本)
       ├─ libstdx.crypto.keysFFI.a                 (实际是 -strong 版本)
       ├─ libstdx.crypto.x509FFI.a                 (实际是 -strong 版本)
       ├─ libstdx.net.tls.a                        (实际是 -strong 版本)
       ├─ libstdx.crypto.digest.a                  (实际是 -strong 版本)
       ├─ libstdx.crypto.keys.a                    (实际是 -strong 版本)
       ├─ libstdx.crypto.crypto.a                  (实际是 -strong 版本)
       └─ libstdx.crypto.x509.a                   (实际是 -strong 版本)
```

安装逻辑（`AddCJNATIVELibrary.cmake` 第 1128-1149 行）：
1. 将默认 `static/stdx/` 目录完整复制到 `static-static-link-extern/stdx/`
2. 用 `-strong` 版本的 `.a` 文件覆盖对应文件（文件名去掉 `-strong` 后缀）
3. 这样用户只需指向不同的目录即可选择变体

### 6.5 cjpm.toml 链接配置

dev 分支的 `cjpm.toml` 采用了 `package-configuration` 方式按包配置链接选项，每个依赖 OpenSSL 的包都声明了 `-lcangjie-dynamicLoader-opensslFFI`：

```toml
[package.package-configuration."stdx"]
  compile-option = "-lcangjie-dynamicLoader-opensslFFI"

[package.package-configuration."stdx.crypto.keys"]
  compile-option = "-lstdx.crypto.keysFFI -lcangjie-dynamicLoader-opensslFFI"

[package.package-configuration."stdx.crypto.x509"]
  compile-option = "-lstdx.crypto.x509FFI -lcangjie-dynamicLoader-opensslFFI"

[package.package-configuration."stdx.crypto.digest"]
  compile-option = "-lcangjie-dynamicLoader-opensslFFI"

[package.package-configuration."stdx.crypto.crypto"]
  compile-option = "-lcangjie-dynamicLoader-opensslFFI"

[package.package-configuration."stdx.net.tls"]
  compile-option = "-lcangjie-dynamicLoader-opensslFFI -lstdx.net.tlsFFI -lstdx.crypto.keysFFI -lstdx.crypto.x509FFI"

[package.package-configuration."stdx.net.http"]
  compile-option = "-lcangjie-dynamicLoader-opensslFFI"
```

> **注意**：使用 Strong 变体时，用户需要将库搜索路径指向 `static-static-link-extern/stdx/` 目录，并额外链接 OpenSSL 静态库（`-lcrypto -lssl`）。

## 七、运行时行为分析

### 7.1 库加载时机

- **普通模式**：使用 `__attribute__((constructor))` 在库加载时自动执行 `dlopen`（dev 分支已改为延迟加载）
- **Auto 模式**：延迟加载，首次调用 `FindFunction` 时通过 `pthread_once` / `InitOnceExecuteOnce` 执行后端选择
- **Strong 模式** 🆕：无运行时加载，所有符号在编译时已绑定

### 7.2 后端选择机制（Auto/普通模式）🆕

dev 分支引入了 `OpenSslBackendMode` 状态机，通过 `pthread_once` 确保只选择一次后端：

| 后端模式 | 说明 | 触发条件 |
|---------|------|---------|
| `OPENSSL_BACKEND_UNINITIALIZED` | 初始状态 | 尚未执行后端选择 |
| `OPENSSL_BACKEND_MAIN_IMAGE` | 主镜像模式 | macOS Auto 模式下，主程序已链接 OpenSSL |
| `OPENSSL_BACKEND_DLOPEN` | 动态加载模式 | 成功 dlopen 了 OpenSSL 共享库 |
| `OPENSSL_BACKEND_UNAVAILABLE` | 不可用 | OpenSSL 未找到 |

macOS Auto 模式的 `MAIN_IMAGE` 后端：通过探测一组"锚点符号"（如 `TLS_client_method`、`SSL_CTX_new`、`CRYPTO_free` 等）判断主程序是否已链接 OpenSSL。一旦选择此模式，所有符号查找都限定在 `RTLD_MAIN_ONLY`，避免与 dlopen 加载的库混合。

### 7.3 用户自定义 OpenSSL 路径 🆕

dev 分支新增了 `CJ_OpenSSL_SetPath` API 和环境变量支持，允许用户在运行前指定 OpenSSL 库路径：

**API 方式**：
```c
int CJ_OpenSSL_SetPath(const char* cryptoPath, const char* sslPath);
```
- 必须在首次使用 OpenSSL 功能前调用
- 仅在 Auto/普通模式下有效（Strong 模式下为空操作）
- 线程安全（使用互斥锁保护）

**环境变量方式**：
```bash
export STDX_OPENSSL_CRYPTO_FILE=/path/to/libcrypto.so.3
export STDX_OPENSSL_SSL_FILE=/path/to/libssl.so.3
```
- 环境变量优先级高于 `CJ_OpenSSL_SetPath`

### 7.4 库卸载

- **Auto/普通模式**：使用 `__attribute__((destructor))` 在库卸载时自动 `dlclose` / `FreeLibrary`，仅释放自己 dlopen 的 handle（通过 `g_singletonHandleOwned` 标记）
- **Strong 模式** 🆕：无析构函数，无需卸载

### 7.5 错误处理

当 OpenSSL 符号无法加载时，`DynMsg.found` 被设为 `false`，仓颉层会抛出 `"Can not load openssl library or function"` 异常，而非直接崩溃。

### 7.6 libcrypto 与 libssl 分开加载

`opensslSymbols.c` 中，libcrypto 和 libssl 被分开加载，原因：
- 某些平台上 `dlsym` 不保证能解析 DT_NEEDED 依赖中的符号
- 部分用户可能只需要 crypto 功能（libcrypto 存在但 libssl 不存在）
- 如果只有一个库加载成功，两个 handle 互相指向对方，确保统一查找路径可用

### 7.7 符号分类优化 🆕

dev 分支新增了 `IsSslSymbol()` 函数，根据函数名前缀判断符号属于 libssl 还是 libcrypto：

```
SSL_ 前缀    → 优先在 libssl handle 中查找
TLS_ 前缀    → 优先在 libssl handle 中查找
DTLS_ 前缀   → 优先在 libssl handle 中查找
i2d_SSL_ 前缀 → 优先在 libssl handle 中查找
d2i_SSL_ 前缀 → 优先在 libssl handle 中查找
其他          → 优先在 libcrypto handle 中查找
```

如果首选 handle 查找失败，会回退到另一个 handle，确保正确性。

## 八、平台特殊处理

### 8.1 OHOS 平台

- OpenSSL 库名为 `libcrypto_openssl.z.so` / `libssl_openssl.z.so`（OHOS 特有命名）
- 不使用 `find_package`，手动指定链接选项
- 工具链文件定义 `OPENSSL_ARM64_PLATFORM` 宏

### 8.2 macOS 平台

- Auto 模式下**不使用弱符号**（`CANGJIE_OPENSSL_AUTO_WEAK_AVAILABLE=0`），因为 Apple lld 在链接时可能对弱导入报错
- 完全依赖 `dlsym(RTLD_DEFAULT)` + `dlopen/dlsym` 回退
- ld 不支持 `-l:<filename>` 语法，使用标准 `-l` 方式

### 8.3 Windows (MinGW) 平台

- 使用 `LoadLibraryA` / `GetProcAddress` 替代 `dlopen` / `dlsym`
- 库文件名为 `libcrypto-3-x64.dll` / `libssl-3-x64.dll`
- cjpm.toml 中使用 `-l:libcangjie-dynamicLoader-opensslFFI.dll` 格式

## 九、架构图

### 默认变体（Auto 模式 / 普通模式）

```
┌─────────────────────────────────────────────────────────┐
│                    仓颉应用层 (.cj)                       │
│  net.tls / net.http / crypto.* / ...                    │
└──────────────────────┬──────────────────────────────────┘
                       │ FFI 调用
                       ▼
┌─────────────────────────────────────────────────────────┐
│              C FFI 桥接层 (native/*.c)                    │
│  tls-impl.c / keys.c / der_cert.c / ...                │
│  调用 DYN_OPENSSL_* 函数                                │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│         dynamicLoader 模块 (opensslSymbols.c)            │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Auto 模式:  弱符号 → dlsym(RTLD_DEFAULT)       │   │
│  │              ↓ 失败                              │   │
│  │  普通模式:  dlopen → dlsym                       │   │
│  │  (支持 CJ_OpenSSL_SetPath / STDX_OPENSSL_* 环境变量)│   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  加载的库: libcrypto.so.3 / libssl.so.3 (Linux)         │
│           libcrypto.3.dylib / libssl.3.dylib (macOS)    │
│           libcrypto_openssl.z.so (OHOS)                 │
│           libcrypto-3-x64.dll (Windows)                 │
└──────────────────────┬──────────────────────────────────┘
                       │ 运行时动态加载
                       ▼
┌─────────────────────────────────────────────────────────┐
│              系统 OpenSSL 3.x 共享库                      │
│           libcrypto.so + libssl.so                       │
└─────────────────────────────────────────────────────────┘
```

### Strong 变体 🆕

```
┌─────────────────────────────────────────────────────────┐
│                    仓颉应用层 (.cj)                       │
│  net.tls / net.http / crypto.* / ...                    │
└──────────────────────┬──────────────────────────────────┘
                       │ FFI 调用
                       ▼
┌─────────────────────────────────────────────────────────┐
│              C FFI 桥接层 (native/*.c)                    │
│  tls-impl.c / keys.c / der_cert.c / ...                │
│  调用 DYN_OPENSSL_* 函数                                │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│     dynamicLoader 模块 (opensslSymbols.c, Strong 模式)    │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Strong 模式: 直接引用 OpenSSL 符号              │   │
│  │  无 dlopen/dlsym，编译时绑定                     │   │
│  │  原子缓存函数指针，线程安全                       │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  无运行时依赖，无需系统安装 OpenSSL                       │
└──────────────────────┬──────────────────────────────────┘
                       │ 编译时链接
                       ▼
┌─────────────────────────────────────────────────────────┐
│              OpenSSL 3.x 静态库                           │
│           libcrypto.a + libssl.a                         │
│           (构建时链接，嵌入最终可执行文件)                   │
└─────────────────────────────────────────────────────────┘
```

## 十、当前痛点与已解决问题

### 10.1 默认变体的痛点

cangjie_stdx 默认变体采用运行时 dlopen 动态加载 OpenSSL 3.x 共享库的方式，这意味着：

- 用户运行使用 `net.tls`、`net.http`、`crypto.*` 等模块的程序时，**系统必须已安装 OpenSSL 3.x**
- 如果系统只有 OpenSSL 1.1（如 CentOS 7、Ubuntu 20.04 默认版本），程序运行时会抛出 `"Can not load openssl library or function"` 异常
- 用户需要自行下载、编译或通过包管理器安装 OpenSSL 3.x，增加了使用门槛

### 10.2 dev 分支已落地的改进 🆕

| 改进 | 说明 | 解决的痛点 |
|------|------|-----------|
| **Strong 变体** | 编译时静态链接 OpenSSL，运行时无需系统 OpenSSL | 用户无需安装 OpenSSL |
| **CJ_OpenSSL_SetPath API** | 运行前指定 OpenSSL 库路径 | 可指定非系统路径的 OpenSSL |
| **STDX_OPENSSL_CRYPTO_FILE / STDX_OPENSSL_SSL_FILE 环境变量** | 通过环境变量指定 OpenSSL 路径 | 无需代码修改即可指定路径 |
| **后端选择状态机** | `pthread_once` 保证只选择一次后端，避免竞态 | 线程安全 |
| **macOS MAIN_IMAGE 后端** | 自动检测主程序已链接的 OpenSSL | macOS 静态链接场景更好支持 |
| **符号分类优化** | `IsSslSymbol()` 优先在正确的 handle 中查找 | 减少 dlsym 调用次数 |
| **原子缓存函数指针** | `_Atomic(uintptr_t)` 缓存已解析符号 | 线程安全且性能更优 |
| **Handle 所有权标记** | `g_singletonHandleOwned` 区分自己 dlopen 的 handle | 避免误释放系统 handle |

### 10.3 Strong 变体的使用方式 🆕

用户选择 Strong 变体时，需要：

1. **构建时**：确保有 OpenSSL 静态库（libcrypto.a / libssl.a）可用
2. **链接时**：将库搜索路径指向 `static-static-link-extern/stdx/` 目录
3. **链接时**：额外链接 OpenSSL 静态库（`-lcrypto -lssl`）及系统依赖（如 `-lpthread -ldl`）

Strong 变体适用于：
- 不希望要求用户安装 OpenSSL 的场景
- 容器化部署，追求自包含可执行文件
- 嵌入式环境，无包管理器可用
- 对运行时依赖有严格限制的场景

### 10.4 仍待解决的问题

- Strong 变体需要用户自行准备 OpenSSL 静态库，构建门槛较高
- Strong 变体丧失了 OpenSSL 安全热更新能力
- 默认变体（Auto 模式）仍需用户安装 OpenSSL 共享库
- 缺少自动化的 OpenSSL 安装/检测引导

## 十一、解决方案对比

### 方案一：随 stdx 发行包捆绑 OpenSSL 共享库

**做法**：在 stdx 的发行包中附带 OpenSSL 3.x 的共享库文件（`.so`/`.dylib`/`.dll`），安装 stdx 时自动部署到指定目录，`dlopen` 时优先从该目录加载。

**优点**：
- 用户零配置，开箱即用
- 版本完全可控，避免系统 OpenSSL 版本不匹配
- 安全更新可通过更新 stdx 发行包完成

**缺点**：
- 增加发行包体积（libcrypto + libssl 约 5-10MB）
- 与系统自带的 OpenSSL 可能产生版本冲突（两份 OpenSSL 共存）
- 需要为每个目标平台（Linux x86_64/ARM64、macOS、Windows、OHOS）分别维护捆绑库
- 许可证合规需注意（OpenSSL 是 Apache-2.0，相对友好）
- 如果其他库也链接了系统 OpenSSL，可能出现符号冲突或两份 OpenSSL 实例导致状态不一致

### 方案二：构建时静态链接 OpenSSL ✅ 已实现（Strong 变体）

**做法**：将 OpenSSL 静态库（`.a`/`.lib`）直接链接到 stdx 的静态库中，运行时不再依赖系统 OpenSSL。

dev 分支已通过 `CANGJIE_OPENSSL_RESOLVE_STRONG` 模式实现了此方案，产物为 `libstdx.*-strong.a` 系列静态库，安装到 `static-static-link-extern/stdx/` 目录。

**优点**：
- 用户无需安装任何 OpenSSL ✅
- 无运行时依赖，部署简单 ✅
- 无版本冲突风险 ✅

**缺点**：
- **丧失安全热更新能力**——OpenSSL 漏洞频发（如 Heartbleed），静态链接意味着每次 OpenSSL 安全补丁都需要重新发布 stdx
- 产物体积显著增大（libcrypto.a 约 30-50MB）
- 如果用户程序也链接了系统 OpenSSL，会出现**两份 OpenSSL 实例**共存，可能导致：
  - 全局状态不一致（SSL_CTX 初始化、错误队列等）
  - 内存泄漏（两套 `CRYPTO_malloc`/`CRYPTO_free` 不互通）
- 许可证合规风险更大（静态链接的传染性更强）
- 构建门槛较高：用户需要自行准备 OpenSSL 静态库

### 方案三：集成包管理器自动安装

**做法**：在 cjpm（仓颉包管理器）或 stdx 安装脚本中，自动检测系统 OpenSSL 版本，若不满足则通过系统包管理器（apt/yum/brew/vcpkg）自动安装。

**优点**：
- 不增加发行包体积
- 使用系统 OpenSSL，与系统其他组件一致
- 用户体验较好（自动处理）

**缺点**：
- 需要管理员/root 权限安装系统包
- 不同发行版的包名、版本不同，维护脚本复杂度高
- 某些环境（容器、嵌入式、离线环境）无法使用包管理器
- macOS 上 OpenSSL 3.x 需通过 Homebrew 安装，非默认存在
- Windows 上更复杂，无统一包管理器

### 方案四：从源码构建 OpenSSL（Vendored Build）

**做法**：类似 zlib 的处理方式（cangjie_stdx 已经在 CMakeLists.txt 中自动 clone zlib），在构建 stdx 时自动下载 OpenSSL 源码并编译。

**优点**：
- 版本完全可控，确保与 stdx 兼容
- 不依赖系统预装的 OpenSSL
- 已有先例（项目中 zlib 就是这么做的）

**缺点**：
- OpenSSL 编译耗时很长（10-30 分钟），显著增加构建时间
- OpenSSL 构建系统复杂（perl + Configure），跨平台维护成本高
- 产物仍然是动态库的话，用户运行时还是需要部署；静态库的话回到方案二的问题
- 需要为每个目标平台维护构建配置
- 安全更新仍需重新构建

### 方案五：替换为更轻量的 TLS/加密库

**做法**：用 BoringSSL、mbedTLS、rustls 等替代 OpenSSL。

| 替代库 | 特点 |
|--------|------|
| **BoringSSL** | Google 维护，Chrome/Android 使用，API 与 OpenSSL 部分兼容 |
| **mbedTLS** | 轻量级，适合嵌入式，API 完全不同 |
| **rustls** | Rust 实现，内存安全，无 C 依赖 |
| **wolfSSL** | 轻量，兼容 OpenSSL API 的包装层 |

**优点**：
- mbedTLS/wolfSSL 体积小，可静态链接且影响可控
- BoringSSL 安全更新活跃
- rustls 内存安全，避免 C 层漏洞

**缺点**：
- **迁移工作量巨大**——当前 defineFunction.inc 中有 200+ 个 OpenSSL API 调用，所有 FFI 层代码都需要重写
- BoringSSL 不提供稳定的 API/ABI 保证
- mbedTLS API 完全不同，需重写所有 crypto/tls 桥接层
- rustls 需要引入 Rust 工具链，增加构建复杂度
- 可能丧失 OpenSSL 的广泛兼容性和硬件加速支持
- OHOS 平台已内置 OpenSSL，替换后需要额外适配

### 方案六：使用平台原生安全 API

**做法**：各平台使用原生安全框架替代 OpenSSL：
- macOS/iOS：Security.framework / Secure Transport
- Windows：SChannel / CNG (Cryptography Next Generation)
- Linux：保持 OpenSSL 或使用 GnuTLS
- OHOS：保持系统内置 OpenSSL

**优点**：
- 无需额外安装，系统自带
- 跟随系统安全更新
- 平台优化（硬件加速、安全 enclave）

**缺点**：
- 需要为每个平台维护一套独立的 FFI 实现，工作量成倍增加
- API 差异大，统一抽象层设计复杂
- 功能覆盖度不同（如 macOS Secure Transport 不支持某些自定义证书验证）
- Linux 上没有统一的原生 TLS API，仍需依赖 OpenSSL 或 GnuTLS
- 测试矩阵爆炸

### 方案七：优雅降级 + 按需加载（增强当前方案）✅ 部分已实现

**做法**：在当前动态加载基础上，增加以下增强：
1. 更友好的错误提示，告知用户如何安装 OpenSSL
2. 不使用 TLS/crypto 的程序完全不受影响（当前已实现）
3. 提供环境变量让用户指定 OpenSSL 路径 ✅ 已实现（`STDX_OPENSSL_CRYPTO_FILE` / `STDX_OPENSSL_SSL_FILE`）
4. 提供 API 让用户指定 OpenSSL 路径 ✅ 已实现（`CJ_OpenSSL_SetPath`）
5. 提供一键安装脚本

**已实现的改进**：
- `CJ_OpenSSL_SetPath` API：允许在首次使用前指定 OpenSSL 库路径
- `STDX_OPENSSL_CRYPTO_FILE` / `STDX_OPENSSL_SSL_FILE` 环境变量：无需代码修改
- 后端选择状态机：线程安全的延迟加载
- macOS MAIN_IMAGE 后端：自动检测主程序已链接的 OpenSSL

**优点**：
- 改动最小，风险最低
- 保持当前架构的安全优势（动态链接可热更新）
- 不增加产物体积

**缺点**：
- 没有从根本上解决用户需要手动安装的问题（默认变体仍需 OpenSSL 共享库）
- 用户体验改善有限

## 十二、综合评估

### 评分说明

- ★★★★★ = 5 分（最优）
- ★★★★ = 4 分
- ★★★ = 3 分（中等）
- ★★ = 2 分
- ★ = 1 分（最差）

### 评分明细

| 方案 | 用户体验 | 实现成本 | 安全性 | 维护成本 | 兼容性 | 总分 | 状态 |
|------|---------|---------|--------|---------|--------|------|------|
| ① 捆绑共享库 | ★★★★★ (5) | ★★★ (3) | ★★★ (3) | ★★★ (3) | ★★★ (3) | **17** | 待评估 |
| ② 静态链接 | ★★★★★ (5) | ★★ (2) | ★★ (2) | ★★ (2) | ★★ (2) | **13** | ✅ 已实现（Strong 变体） |
| ③ 包管理器自动安装 | ★★★★ (4) | ★★★ (3) | ★★★★ (4) | ★★★ (3) | ★★ (2) | **16** | 待评估 |
| ④ Vendored 源码构建 | ★★★ (3) | ★★ (2) | ★★★ (3) | ★★ (2) | ★★★★ (4) | **14** | 待评估 |
| ⑤ 替换加密库 | ★★★★ (4) | ★ (1) | ★★★★ (4) | ★ (1) | ★★ (2) | **12** | 待评估 |
| ⑥ 平台原生 API | ★★★★★ (5) | ★ (1) | ★★★★ (4) | ★ (1) | ★★ (2) | **13** | 待评估 |
| ⑦ 增强当前方案 | ★★ (2) | ★★★★★ (5) | ★★★★★ (5) | ★★★★★ (5) | ★★★★★ (5) | **22** | ✅ 部分已实现 |

### 评分维度说明

| 维度 | 5 分 | 3 分 | 1 分 |
|------|------|------|------|
| **用户体验** | 用户无需任何操作即可使用 | 需少量配置或安装 | 需复杂手动操作 |
| **实现成本** | 改动极小，可快速落地 | 中等开发量 | 大规模重构或重写 |
| **安全性** | 可热更新，漏洞响应快 | 需重新构建/发布 | 静态绑定，安全更新困难 |
| **维护成本** | 几乎无需额外维护 | 需定期维护 | 持续大量维护工作 |
| **兼容性** | 全平台兼容，无冲突 | 部分平台有局限 | 严重兼容性问题 |

### 综合排名

| 排名 | 方案 | 总分 | 特点 |
|------|------|------|------|
| 1 | ⑦ 增强当前方案 | 22 | 改动最小、风险最低，但用户体验改善有限 |
| 2 | ① 捆绑共享库 | 17 | 用户体验好，但需维护多平台捆绑库 |
| 3 | ③ 包管理器自动安装 | 16 | 平衡方案，但平台覆盖有限 |
| 4 | ④ Vendored 源码构建 | 14 | 兼容性好，但构建复杂耗时 |
| 5 | ② 静态链接 | 13 | 已实现，但安全性和维护性差 |
| 5 | ⑥ 平台原生 API | 13 | 体验好，但实现和维护成本极高 |
| 7 | ⑤ 替换加密库 | 12 | 安全性好，但迁移成本巨大 |

> **注**：总分仅作参考，实际决策需根据项目阶段和优先级加权。例如若"用户体验"权重最高，则方案①和⑥更优；若"实现成本"权重最高，则方案⑦最优。

## 十三、推荐策略

### 已完成 ✅

- **方案② Strong 变体**：已实现编译时静态链接 OpenSSL 的能力，用户可选择使用
- **方案⑦ 增强当前方案**：已实现 `CJ_OpenSSL_SetPath` API、环境变量、后端选择状态机等

### 短期（低风险快速改善）

- 增强 Strong 变体的文档和使用引导，降低构建门槛
- 提供预编译的 OpenSSL 静态库下载，简化 Strong 变体的构建流程
- 在 stdx 发行包中**可选地**附带 OpenSSL 共享库，作为默认变体的 fallback
- 增强错误提示和安装引导

### 中期（根本改善）

- 类似 zlib 的处理方式，构建时自动下载编译 OpenSSL（Vendored Build）
- 提供预编译产物缓存，避免每次全量构建
- cjpm 集成 OpenSSL 自动检测和安装

### 长期（架构升级）

- 在 dynamicLoader 层增加抽象，支持多种后端
- 优先在特定平台（如 macOS、Windows）引入原生 API 后端
- Linux/OHOS 保持 OpenSSL 后端

---

## 十四、用户视角：OpenSSL 依赖场景分析

本节从**用户使用 stdx 的方式**出发，分析不同依赖场景下用户对 OpenSSL 的感知和需求。

### 14.1 依赖场景总览

```
用户使用 stdx
  │
  ├─ 源码依赖
  │   ├─ 直接代码依赖（git clone / 本地路径）
  │   └─ 通过中心仓依赖（cjpm version）
  │
  └─ 二进制依赖
      ├─ 动态库产物（output-type="dynamic"）
      └─ 静态库产物（output-type="static"）
          ├─ 默认变体（Auto 模式）
          └─ Strong 变体（静态链接 OpenSSL）
```

### 14.2 场景一：源码依赖 — 直接代码依赖

**用户配置**：

```toml
[dependencies]
  stdx = { git = "https://gitcode.com/Cangjie/cangjie_stdx.git", branch = "dev" }
  # 或
  stdx = { path = "/path/to/cangjie_stdx" }
```

**OpenSSL 依赖分析**：

| 阶段 | 是否需要 OpenSSL | 说明 |
|------|-----------------|------|
| **cjpm update / 同步源码** | ❌ 不需要 | 仅下载源码 |
| **cjpm build（构建 stdx 原生库）** | ✅ **需要** | CMake 构建需要 OpenSSL 3.x **头文件**和**库文件**（动态或静态均可） |
| **cjpm build（编译用户项目）** | ❌ 不需要 | stdx 原生库已预编译，仓颉编译器只做链接 |
| **运行用户程序（默认变体）** | ✅ **需要** | 运行时 dlopen 加载 OpenSSL 3.x 共享库 |
| **运行用户程序（Strong 变体）** | ❌ 不需要 | OpenSSL 已静态链接到可执行文件 |

**用户需要做的**：

1. 安装 OpenSSL 3.x 开发包（头文件 + 库文件）
2. 设置环境变量 `OPENSSL_ROOT_DIR` 指向 OpenSSL 安装根目录
3. 首次构建时，cjpm 会调用 `cjpm_build.py` 触发 CMake 构建，自动查找 OpenSSL
4. 若选择 Strong 变体，需额外提供 OpenSSL **静态库**（libcrypto.a / libssl.a）

**典型命令**：

```bash
# Ubuntu/Debian
sudo apt install libssl-dev

# macOS
brew install openssl@3
export OPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl@3

# CentOS/RHEL（需手动编译 OpenSSL 3.x）
export OPENSSL_ROOT_DIR=/usr/local/openssl-3
```

### 14.3 场景二：源码依赖 — 通过中心仓依赖

**用户配置**：

```toml
[dependencies]
  stdx = { version = "1.0.5" }
```

**OpenSSL 依赖分析**：

| 阶段 | 是否需要 OpenSSL | 说明 |
|------|-----------------|------|
| **cjpm update / 下载包** | ❌ 不需要 | 从中心仓下载源码 |
| **cjpm build（编译 stdx 原生库）** | ✅ **需要** | 中心仓是源码中心仓，pre-build 阶段需 CMake 编译原生 FFI 库，需要 OpenSSL 头文件+库 |
| **cjpm build（编译用户项目）** | ❌ 不需要 | 原生库已编译完成 |
| **运行用户程序（默认变体）** | ✅ **需要** | 运行时 dlopen 加载 OpenSSL 3.x 共享库 |
| **运行用户程序（Strong 变体）** | ❌ 不需要 | OpenSSL 已静态链接 |

> ⚠️ **重要**：仓颉中心仓是**源码中心仓**，不是二进制中心仓。下载的是 stdx 完整源码（含 .cj、.c、.h、CMakeLists.txt），构建时仍需执行 CMake 编译原生 FFI 库，因此**同样需要 OpenSSL 3.x 开发包**。

**用户需要做的**：

1. **构建时需安装 OpenSSL 3.x 开发包** — 中心仓分发源码，需编译原生库
2. **需设置 `OPENSSL_ROOT_DIR` 环境变量** — CMake 查找 OpenSSL 时需要
3. **运行时需确保系统有 OpenSSL 3.x 共享库**（默认变体）
4. 若选择 Strong 变体，运行时无需 OpenSSL，但构建时需 OpenSSL 静态库

**与直接代码依赖的关键区别**：

| 对比项 | 直接代码依赖 | 中心仓依赖 |
|--------|------------|-----------|
| 构建时需要 OpenSSL | ✅ 是（需编译原生库） | ✅ 是（同样需编译原生库） |
| 需设置 OPENSSL_ROOT_DIR | ✅ 是 | ✅ 是 |
| 运行时需要 OpenSSL（默认变体） | ✅ 是 | ✅ 是 |
| 运行时需要 OpenSSL（Strong 变体） | ❌ 否 | ❌ 否 |
| 构建时间 | 长（含 CMake 编译） | 长（同样含 CMake 编译） |
| 源码获取方式 | git clone / 本地路径 | cjpm 从中心仓下载 |

### 14.4 场景三：二进制依赖 — 动态库产物

**用户配置**：

```toml
[dependencies]
  stdx = { version = "1.0.5", output-type = "dynamic" }

[target.x86_64-unknown-linux-gnu]
  [target.x86_64-unknown-linux-gnu.bin-dependencies]
    path-option = ["/path/to/linux_x86_64_cjnative/dynamic/stdx"]
```

或通过下载脚本获取：

```bash
bash -c "$(curl -fsSL https://raw.gitcode.com/Cangjie/cangjie_stdx/raw/dev/downloader.sh)" -- 1.0.5
```

**OpenSSL 依赖分析**：

| 阶段 | 是否需要 OpenSSL | 说明 |
|------|-----------------|------|
| **下载/安装 stdx** | ❌ 不需要 | 预编译 zip 包 |
| **编译用户项目** | ❌ 不需要 | 动态库在链接时通过 -l 引用 |
| **运行用户程序** | ✅ **需要** | stdx 动态库 dlopen 加载 OpenSSL 3.x 共享库 |

**用户需要做的**：

1. 确保运行环境有 OpenSSL 3.x 共享库
2. 可通过 `STDX_OPENSSL_CRYPTO_FILE` / `STDX_OPENSSL_SSL_FILE` 环境变量指定路径
3. 可在代码中调用 `setOpenSslPath()` 指定路径（首次使用前）

**运行时依赖链**：

```
用户程序
  └─ libstdx.so (或 libcangjieStdx.so)
       └─ libcangjie-dynamicLoader-opensslFFI.so
            └─ dlopen → libcrypto.so.3 / libssl.so.3  ← 需要系统提供
```

### 14.5 场景四：二进制依赖 — 静态库产物（默认变体）

**用户配置**：

```toml
[target.x86_64-unknown-linux-gnu]
  [target.x86_64-unknown-linux-gnu.bin-dependencies]
    path-option = ["/path/to/linux_x86_64_cjnative/static/stdx"]
```

**OpenSSL 依赖分析**：

| 阶段 | 是否需要 OpenSSL | 说明 |
|------|-----------------|------|
| **下载/安装 stdx** | ❌ 不需要 | 预编译 zip 包 |
| **编译用户项目** | ❌ 不需要 | 静态库在链接时直接合并到可执行文件 |
| **运行用户程序** | ✅ **需要** | Auto 模式仍会 dlopen 加载 OpenSSL 3.x 共享库 |

**关键说明**：

默认变体的静态库（`static/stdx/`）使用 Auto 模式，内部包含 `cangjie-dynamicLoader-opensslFFI-auto-objs`。虽然链接时不需要 OpenSSL，但**运行时仍会尝试 dlopen OpenSSL 共享库**。如果用户程序自身静态链接了 OpenSSL，Auto 模式会优先使用已链接的符号（通过弱符号 / RTLD_DEFAULT），此时运行时不需要额外的 OpenSSL 共享库。

### 14.6 场景五：二进制依赖 — 静态库产物（Strong 变体）

**用户配置**：

```toml
[target.x86_64-unknown-linux-gnu]
  [target.x86_64-unknown-linux-gnu.bin-dependencies]
    path-option = ["/path/to/linux_x86_64_cjnative/static-static-link-extern/stdx"]
```

**OpenSSL 依赖分析**：

| 阶段 | 是否需要 OpenSSL | 说明 |
|------|-----------------|------|
| **下载/安装 stdx** | ❌ 不需要 | 预编译 zip 包 |
| **编译用户项目** | ✅ **需要** | Strong 变体直接引用 OpenSSL 符号，链接时需要 OpenSSL **静态库** |
| **运行用户程序** | ❌ 不需要 | OpenSSL 已静态链接到可执行文件 |

**用户需要做的**：

1. 安装 OpenSSL 3.x **静态库**（libcrypto.a / libssl.a）
2. 在链接选项中添加 `-lcrypto -lssl` 及系统依赖（如 `-lpthread -ldl`）
3. 确保 OpenSSL 静态库与 stdx 使用相同版本编译

**链接命令示例**：

```bash
cjc -o myapp main.cj \
  -L /path/to/static-static-link-extern/stdx \
  -lcangjie-dynamicLoader-opensslFFI \
  -lstdx.net.tlsFFI -lstdx.crypto.keysFFI -lstdx.crypto.x509FFI \
  -lcrypto -lssl -lpthread -ldl
```

### 14.7 各场景 OpenSSL 依赖汇总

| 场景 | 构建时 | 运行时 | 用户操作复杂度 |
|------|--------|--------|--------------|
| 源码依赖（直接代码） | ✅ 需 OpenSSL 头文件+库 | ✅ 需 OpenSSL 共享库 | ★★★★ 高 |
| 源码依赖（中心仓） | ✅ **需 OpenSSL 头文件+库** | ✅ 需 OpenSSL 共享库 | ★★★★ 高 |
| 二进制依赖（动态库） | ❌ 不需要 | ✅ 需 OpenSSL 共享库 | ★★ 低 |
| 二进制依赖（静态库-默认） | ❌ 不需要 | ✅ 需 OpenSSL 共享库 | ★★ 低 |
| 二进制依赖（静态库-Strong） | ✅ 需 OpenSSL 静态库 | ❌ 不需要 | ★★★ 中 |

### 14.8 用户使用 OpenSSL 相关功能的完整流程

#### 流程 A：源码依赖（直接代码）— 默认变体

```
1. 安装 OpenSSL 3.x 开发包
   └─ Ubuntu: sudo apt install libssl-dev
   └─ macOS:  brew install openssl@3 && export OPENSSL_ROOT_DIR=...

2. 配置 cjpm.toml
   └─ stdx = { git = "https://gitcode.com/Cangjie/cangjie_stdx.git", branch = "dev" }

3. cjpm update
   └─ 下载 stdx 源码

4. cjpm build
   └─ CMake 自动查找 OpenSSL 3.x（通过 OPENSSL_ROOT_DIR 或系统路径）
   └─ 编译原生 FFI 库（含 dynamicLoader-opensslFFI）
   └─ 编译仓颉代码并链接

5. 运行程序
   └─ 系统需有 libcrypto.so.3 / libssl.so.3
   └─ 若缺失：设置 STDX_OPENSSL_CRYPTO_FILE / STDX_OPENSSL_SSL_FILE
   └─ 或代码中调用 setOpenSslPath()
```

#### 流程 B：源码依赖（中心仓）— 默认变体

```
1. 配置 cjpm.toml
   └─ stdx = { version = "1.0.5" }

2. cjpm update
   └─ 从中心仓下载预编译产物（.cjo + .a）

3. cjpm build
   └─ 仅编译用户仓颉代码，链接 stdx 静态库
   └─ 无需 OpenSSL

4. 运行程序
   └─ 系统需有 libcrypto.so.3 / libssl.so.3
   └─ 若缺失：设置环境变量或调用 setOpenSslPath()
```

#### 流程 C：二进制依赖 — Strong 变体

```
1. 下载 stdx 二进制包
   └─ bash downloader.sh 1.0.5

2. 安装 OpenSSL 3.x 静态库
   └─ 需自行编译或从发行版获取 libcrypto.a / libssl.a

3. 配置 cjpm.toml
   └─ bin-dependencies.path-option 指向 static-static-link-extern/stdx
   └─ link-option 添加 -lcrypto -lssl -lpthread -ldl

4. cjpm build
   └─ 链接 stdx Strong 变体 + OpenSSL 静态库

5. 运行程序
   └─ 无需系统 OpenSSL ✅
```

### 14.9 用户可能遇到的问题与解决方案

| 问题 | 场景 | 原因 | 解决方案 |
|------|------|------|---------|
| 构建失败：找不到 OpenSSL | 源码依赖（直接代码） | 未安装 OpenSSL 3.x 或未设置 `OPENSSL_ROOT_DIR` | 安装 OpenSSL 3.x 并设置环境变量 |
| 构建失败：OpenSSL 版本过低 | 源码依赖（直接代码） | 系统默认 OpenSSL < 3.0 | 手动编译安装 OpenSSL 3.x |
| 运行时异常：Can not load openssl library | 默认变体 | 系统无 OpenSSL 3.x 共享库 | 安装 OpenSSL 3.x 或设置 `STDX_OPENSSL_*` 环境变量 |
| 运行时异常：Can not load openssl function | 默认变体 | OpenSSL 版本不匹配（如 1.1 而非 3.x） | 升级到 OpenSSL 3.x |
| 链接失败：undefined reference to OpenSSL 符号 | Strong 变体 | 未链接 OpenSSL 静态库 | 添加 `-lcrypto -lssl` |
| 链接失败：找不到 libcrypto.a | Strong 变体 | 未安装 OpenSSL 静态库 | 安装 OpenSSL 静态库开发包 |
| 两份 OpenSSL 实例冲突 | Strong 变体 + 系统 OpenSSL | 用户程序同时链接了静态和动态 OpenSSL | 避免混合链接，或使用默认变体 |
| macOS 上弱符号不生效 | 源码依赖 | macOS Auto 模式不使用弱符号 | 使用 `CJ_OpenSSL_SetPath` 或环境变量 |

---

## 十五、业界其他语言对 OpenSSL 的依赖方式对比

### 15.1 各语言方案总览

| 语言 | 标准库/生态 TLS/加密方案 | 是否依赖 OpenSSL | 链接方式 | 用户感知 |
|------|------------------------|-----------------|---------|---------|
| **Go** | `crypto/tls` + `crypto/*` 纯 Go 实现 | ❌ 不依赖 | 无 | 零感知，开箱即用 |
| **Rust** | 多种选择：`rustls` / `native-tls` / `openssl` | 可选 | 多种 | 取决于选择的 crate |
| **Node.js** | 内置 `crypto` + `tls` 模块 | ✅ 依赖（捆绑） | 静态链接到 Node 二进制 | 零感知 |
| **Python** | `cryptography` 包 + `ssl` 模块 | ✅ 依赖 | 动态链接系统库 | 需安装系统 OpenSSL |
| **Java** | JCA/JCE（内置）+ 可选 OpenSSL | ❌ 默认不依赖 | N/A | 零感知（默认） |
| **Kotlin** | 多平台：JCA / OpenSSL / WebCrypto | 可选 | 按平台 | 取决于目标平台 |
| **Swift** | `Security.framework` / `CryptoKit` | ❌ 不依赖 | 系统框架 | 零感知 |
| **C#/.NET** | `System.Security.Cryptography` | 部分依赖 | 动态链接 | Linux 上需安装 OpenSSL |
| **Cangjie** | `stdx.crypto.*` + `stdx.net.tls` | ✅ 依赖 | 动态加载/静态链接 | 需安装或配置 OpenSSL |

### 15.2 各语言详细方案

#### Go：纯 Go 实现（零 OpenSSL 依赖）

Go 是最彻底的方案。标准库 `crypto/tls`、`crypto/x509`、`crypto/rand` 等全部使用纯 Go 实现，**完全不依赖 OpenSSL**。

- **TLS 1.2 / 1.3**：纯 Go 实现，被许多密码学家视为参考实现
- **加密算法**：AES、RSA、ECDSA、Ed25519、ChaCha20-Poly1305 等全部纯 Go
- **国密支持**：通过第三方库 `github.com/tjfoc/gmsm` 提供 SM2/SM3/SM4
- **FIPS 模式**：通过 `GOEXPERIMENT=boringcrypto` 编译选项，使用 BoringCrypto（BoringSSL 核心）替代纯 Go 实现，满足 FIPS 140 合规要求

**优点**：
- 用户零感知，开箱即用
- 跨平台一致性，无版本冲突
- 部署简单，无运行时依赖
- 内存安全（Go 的垃圾回收和边界检查）

**缺点**：
- 某些场景性能不如 OpenSSL（如 AES-GCM 吞吐量、RSA 签名速度）
- 纯 Go 实现无法利用某些硬件加速指令（需依赖 Go 汇编优化）
- 国密算法需第三方库，非标准库内置

**对仓颉的启示**：Go 证明了纯自研 TLS/加密库是可行的，但需要大量工程投入。

#### Rust：多后端选择（用户自主决策）

Rust 生态提供了三种 TLS/加密方案，用户按需选择：

| 方案 | 依赖 | 特点 |
|------|------|------|
| **rustls** + **ring** | ❌ 不依赖 OpenSSL | 纯 Rust，内存安全，推荐方案 |
| **native-tls** | ✅ 依赖系统 OpenSSL/SChannel/Secure Transport | 使用平台原生 TLS，跨平台行为一致 |
| **openssl** crate | ✅ 依赖 OpenSSL | 直接绑定 OpenSSL API，功能最全 |

**vendored 模式**：`openssl` crate 支持 `features = ["vendored"]`，编译时自动下载 OpenSSL 源码并静态链接，消除运行时依赖。这是 Rust 社区解决"用户需安装 OpenSSL"问题的主要手段。

**rustls 性能对比**（vs OpenSSL 3.2.0）：
- 内存占用：rustls 约 13KiB/会话，OpenSSL 约 69KiB/会话（5x 差距）
- 恢复握手：rustls 快 80%-330%
- RSA 完整握手：rustls 慢 27%-30%
- AES 数据发送吞吐量：基本持平
- ChaCha20 数据传输：rustls 慢约 45%（OpenSSL 有 AVX-512 优化）

**对仓颉的启示**：Rust 的"多后端选择"模式值得借鉴——默认推荐无 OpenSSL 依赖的方案，同时保留 OpenSSL 后端作为可选项。

#### Node.js：捆绑 OpenSSL（用户零感知）

Node.js 将 OpenSSL **静态链接**到 Node 二进制文件中（`deps/` 目录），用户完全无感知。

- Node.js 22.x 捆绑 OpenSSL 3.5.2
- 用户无需安装任何 OpenSSL
- Node.js 的 `crypto` 和 `tls` 模块直接使用捆绑的 OpenSSL
- 第三方构建可选择链接外部 OpenSSL

**优点**：
- 用户零感知，开箱即用
- 版本完全可控
- 无系统 OpenSSL 版本冲突

**缺点**：
- OpenSSL 安全漏洞需等待 Node.js 发新版
- Node.js 二进制体积较大
- 与系统 OpenSSL 可能存在两份实例

**对仓颉的启示**：Node.js 的"捆绑"模式是用户体验最优的方案，但代价是安全更新滞后和体积增大。

#### Python：动态链接系统 OpenSSL

Python 的 `ssl` 模块和 `cryptography` 包依赖系统 OpenSSL：

- `ssl` 模块：编译时链接系统 OpenSSL，运行时依赖 `.so`
- `cryptography` 包：使用 Rust 编写绑定层，底层调用 OpenSSL
- 用户需安装系统 OpenSSL 开发包（`libssl-dev`）
- 部分场景提供 wheel 预编译包，内含 OpenSSL

**对仓颉的启示**：Python 的方案与仓颉当前默认变体类似，用户需自行安装 OpenSSL，体验较差。

#### Java：JCA 自研实现（零 OpenSSL 依赖）

Java 的 JCA（Java Cryptography Architecture）和 JCE（Java Cryptography Extension）使用纯 Java 实现：

- 默认不依赖 OpenSSL
- AES、RSA、ECDSA、SHA 等算法纯 Java 实现
- 可通过 BouncyCastle 等第三方库扩展
- 可通过 `OpenSSLProvider` 可选地使用 OpenSSL 加速

**对仓颉的启示**：Java 证明了大型语言生态可以完全不依赖 OpenSSL，但需要长期工程积累。

#### Swift / Apple 平台：系统原生 API

Swift 使用 Apple 平台的 `Security.framework` 和 `CryptoKit`：

- 完全不依赖 OpenSSL
- Apple 维护，跟随系统更新
- 硬件加速（Secure Enclave、AES-NI）
- 跨平台时需回退到其他方案

#### .NET：混合方案

- Windows：使用 CNG（Cryptography Next Generation），不依赖 OpenSSL
- Linux：`System.Security.Cryptography.Native.OpenSsl.so` 依赖系统 OpenSSL
- 自包含部署时可捆绑 OpenSSL 共享库

### 15.3 业界方案分类

| 类别 | 代表 | 用户感知 | 实现成本 | 安全性 |
|------|------|---------|---------|--------|
| **纯自研** | Go、Java | ★★★★★ 零感知 | ★ 极高 | ★★★★ 自主可控 |
| **捆绑 OpenSSL** | Node.js | ★★★★★ 零感知 | ★★ 中等 | ★★★ 依赖 OpenSSL 发版 |
| **多后端可选** | Rust | ★★★★ 需选择 | ★★★ 中高 | ★★★★ 灵活 |
| **动态链接系统库** | Python、.NET(Linux) | ★★ 需安装 | ★★★★★ 低 | ★★★★ 跟随系统更新 |
| **平台原生 API** | Swift、Kotlin | ★★★★★ 零感知 | ★★★ 中等 | ★★★★ 跟随平台更新 |
| **运行时动态加载** | Cangjie（当前） | ★★ 需安装 | ★★★★ 较低 | ★★★★ 可热更新 |

---

## 十六、仓颉自研加密/TLS 库的成本分析

### 16.1 实际使用的 OpenSSL 接口分析

dynamicLoader 中声明了 200+ 个 DYN_OPENSSL_* 包装函数，但**实际被业务代码调用的 OpenSSL 接口**需要精确统计。以下按功能域分类：

#### 16.1.1 实际调用的 OpenSSL 函数统计

| 功能域 | 实际调用函数数 | 核心函数举例 | 对应仓颉模块 |
|--------|-------------|-------------|------------|
| **SSL/TLS 核心** | 38 | SSL_CTX_new、SSL_new、SSL_read、SSL_write、SSL_do_handshake | net.tls |
| **SSL/TLS 扩展/ALPN/Session** | 22 | SSL_CTX_set_alpn_protos、SSL_SESSION_free、SSL_set_session | net.tls |
| **SSL/TLS 非标准包装** | 9 | SSL_CTX_set_min_proto_version、SSL_set_tlsext_host_name | net.tls |
| **SSL Session 回调** | 3 | SSL_CTX_sess_set_new_cb/get_cb | net.tls |
| **SSL Cipher** | 3 | SSL_CIPHER_get_name、SSL_get_current_cipher | net.tls |
| **EVP 摘要/哈希** | 13 | EVP_DigestInit_ex、EVP_sha256、EVP_md5 | crypto.digest |
| **EVP 对称加密** | 9 | EVP_DecryptInit_ex、EVP_aes_256_cbc、EVP_BytesToKey | crypto.crypto |
| **EVP PKEY 密钥管理** | 16 | EVP_PKEY_fromdata、EVP_PKEY_get_bn_param、EVP_PKEY2PKCS8 | crypto.keys |
| **BIO 核心** | 13 | BIO_new、BIO_read、BIO_write、BIO_free | net.tls + crypto |
| **BIO 非标准包装** | 4 | BIO_new_mem、BIO_set_retry_read | net.tls |
| **BIO 自定义方法** | 9 | BIO_meth_new、BIO_meth_set_read、BIO_get_new_index | net.tls |
| **X509 证书** | 24 | X509_new、X509_sign、X509_get_pubkey、X509_add_ext | crypto.x509 |
| **X509 验证/回调** | 7 | X509_verify_cert、X509_STORE_CTX_get0_cert | crypto.x509 |
| **X509 REQ (CSR)** | 7 | X509_REQ_new、X509_REQ_sign、X509_REQ_add_extensions | crypto.x509 |
| **X509 NAME/ALGOR/SIG** | 9 | X509_NAME_add_entry_by_txt、X509_ALGOR_get0 | crypto.x509 |
| **X509V3 扩展** | 2 | X509V3_EXT_i2d、a2i_GENERAL_NAME | crypto.x509 |
| **PEM** | 3 | PEM_read_bio_X509、PEM_write_bio_X509 | crypto.x509 |
| **ERR 错误处理** | 5 | ERR_get_error、ERR_reason_error_string | 全局 |
| **ASN1** | 9 | ASN1_INTEGER_new、ASN1_TIME_set_string、ASN1_STRING_get0_data | crypto.x509 |
| **DER 编解码** | 16 | i2d_X509、d2i_X509、d2i_PKCS8_bio、i2d_PKCS8PrivateKey_bio | crypto.x509 + crypto.keys |
| **BN 大数运算** | 12 | BN_new、BN_bin2bn、BN_mod_exp、BN_CTX_new | crypto.keys |
| **OSSL_PARAM** | 13 | OSSL_PARAM_locate、OSSL_PARAM_get_BN、OSSL_PARAM_construct_* | net.tls (Keyless) |
| **OSSL Provider** | 2 | OSSL_PROVIDER_add_builtin、OSSL_PROVIDER_load | net.tls (Keyless) |
| **PKCS8/PKCS5** | 3 | PKCS8_set0_pbe、PKCS5_pbe2_set_iv | crypto.keys |
| **CRYPTO 通用** | 4 | CRYPTO_malloc、CRYPTO_free、CRYPTO_get_ex_new_index | 全局 |
| **OPENSSL 工具/内存** | 17 | OPENSSL_sk_new_null、OPENSSL_cleanse、OPENSSL_zalloc | 全局 |
| **RAND** | 1 | RAND_bytes | crypto.crypto |
| **SHA256** | 3 | SHA256_Init、SHA256_Update、SHA256_Final | net.tls (Keyless) |
| **OBJ** | 1 | OBJ_obj2nid | crypto.x509 |
| **合计** | **241** | | |

#### 16.1.2 按仓颉模块聚合的实际使用量

| 仓颉模块 | 使用的 OpenSSL 函数数 | 底层 C FFI 文件数 | 核心功能 |
|---------|---------------------|-----------------|---------|
| **net.tls** | ~150 | 15 | TLS 客户端/服务端、Keyless TLS、Session 管理 |
| **crypto.x509** | ~60 | 3 | X.509 证书/CSR 解析/生成/验证 |
| **crypto.keys** | ~40 | 3 | RSA/ECDSA/SM2 密钥操作、PKCS 编解码 |
| **crypto.digest** | ~13 | 0（通过 EVP 接口） | SHA/MD5/SM3 摘要 |
| **crypto.crypto** | ~10 | 0（通过 EVP 接口） | SM4 对称加密、安全随机数 |

#### 16.1.3 OpenSSL 结构体类型使用分析

| 分类 | 类型 | 使用方式 |
|------|------|---------|
| **有成员直接访问（6 个）** | OSSL_PARAM（data_type/data/data_size）、ASN1_BIT_STRING（length/data）、GENERAL_NAME（type/d.dNSName/d.iPAddress）、BUF_MEM（data/length）、X509V3_CTX（db）、OSSL_DISPATCH（聚合初始化） | 需要结构体定义，无法用透明指针替代 |
| **仅透明指针（25+ 个）** | SSL_CTX*、SSL*、SSL_SESSION*、BIO*、BIO_METHOD*、EVP_PKEY*、EVP_PKEY_CTX*、EVP_CIPHER_CTX*、EVP_MD_CTX*、X509*、X509_STORE*、X509_STORE_CTX*、X509_REQ*、X509_NAME*、X509_EXTENSION*、X509_ALGOR*、X509_PUBKEY*、X509_SIG*、ASN1_INTEGER*、ASN1_TIME*、ASN1_STRING*、BIGNUM*、PKCS8_PRIV_KEY_INFO*、OSSL_PROVIDER*、SSL_CIPHER*、X509_VERIFY_PARAM* | 仅传递给 API 函数，自研时可直接替换为自有结构体 |

**关键发现**：25+ 个类型仅作透明指针使用，自研时只需定义等价的 opaque 结构体即可，无需复制 OpenSSL 的内部布局。仅 6 个类型有成员直接访问，集中在 Keyless TLS Provider 和 X509 证书解析模块。

### 16.2 基于实际使用量的精简工作量估算

上一版估算基于"200+ API"的粗略范围，现在基于实际 241 个函数调用和 25+ 透明指针类型的精确分析，结合仓颉实际只需要特定算法子集（不需要 OpenSSL 全部能力），重新评估：

#### 16.2.1 不需要实现的部分

| 排除项 | 原因 | 节省估算 |
|--------|------|---------|
| **OSSL Provider 框架** | 这是 OpenSSL 3.x 的算法注册机制，自研后不再需要。Keyless TLS 可用回调直接实现 | 3,000-5,000 行 |
| **OSSL_PARAM 参数构造** | Provider 框架的配套机制，自研后用自有结构体替代 | 2,000-3,000 行 |
| **BIO 抽象层** | 自研可用仓颉原生 Stream/Buffer 替代，无需 BIO 中间层 | 2,000-3,000 行 |
| **ERR 错误队列** | 自研可用仓颉异常体系替代，无需 OpenSSL 风格的错误队列 | 1,000-2,000 行 |
| **OPENSSL_sk_* 栈** | 自研可用仓颉原生集合类型替代 | 500-1,000 行 |
| **CRYPTO_malloc/free** | 自研用仓颉 GC 管理，无需 OpenSSL 内存管理 | 500-1,000 行 |
| **大量未使用的 EVP_PKEY_* 接口** | defineFunction.inc 中定义但未调用的密钥生成/签名/验签接口（EVP_PKEY_keygen、EVP_PKEY_sign 等） | 不需实现 |
| **未使用的摘要算法** | SHA1/SHA224/SHA384/SHA512 的 Init/Update/Final 三段式接口（已用 EVP_Digest* 统一替代）、MD5_Init/Update/Final | 不需实现 |
| **未使用的 HMAC 接口** | HMAC_CTX_new/HMAC_Init_ex/HMAC_Update/HMAC_Final/HMAC_CTX_free（仓颉层已用 EVP_Digest* 实现） | 不需实现 |
| **未使用的国密接口** | EVP_sm4_cbc/ecb/cfb/ofb/ctr、EVP_sm3（通过 EVP_get_cipherbyname/digestbyname 动态获取） | 不需实现 |
| **未使用的加密接口** | EVP_EncryptInit_ex/Update/Final（仅用 Decrypt 方向）、EVP_CIPHER_fetch/free | 不需实现 |

#### 16.2.2 修正后的模块工作量

| 模块 | 实际需要的 OpenSSL 接口 | 修正后代码量估算 | 说明 |
|------|----------------------|----------------|------|
| **摘要算法** | 13 个 EVP_Digest* + 5 个 EVP_sha*/md5 | 2,000-3,000 行 | 仅需 SHA-1/256/384/512、MD5、SM3，无需三段式接口 |
| **HMAC** | 0 个（仓颉层已基于 EVP_Digest 实现） | 800-1,200 行 | 简单的 HMAC 构造，基于摘要算法 |
| **对称加密** | 9 个 EVP_Decrypt* + 2 个 EVP_aes/sm4 | 2,500-4,000 行 | 仅 SM4-CBC/GCM/ECB/CFB/OFB/CTR + AES-256-CBC，无需 EVP_Encrypt* |
| **非对称加密** | 16 个 EVP_PKEY* + 12 个 BN_* | 5,000-8,000 行 | RSA-PKCS1/OAEP、ECDSA-P256/P384、SM2，密钥参数提取 |
| **X509 证书** | 49 个 X509_* + 9 个 ASN1_* + 16 个 DER + 3 个 PEM + 3 个 PKCS8/PKCS5 | 6,000-9,000 行 | 证书/CSR 解析生成验证，ASN.1/DER/PEM 编解码 |
| **TLS 1.2/1.3 协议** | 75 个 SSL_* + 3 个 SHA256_* | 15,000-22,000 行 | 最大模块，含 Keyless TLS（用回调替代 Provider） |
| **随机数** | 1 个 RAND_bytes | 300-500 行 | 系统熵源 + CSPRNG |
| **合计** | **241 个（含可排除项）** | **约 32,000-48,000 行** | 比原估算 60,000-93,000 行减少约 45% |

#### 16.2.3 修正后的人月估算

| 阶段 | 工作内容 | 修正人月 | 与原估算对比 | 说明 |
|------|---------|---------|------------|------|
| **算法实现** | SHA/MD5/SM3/SM4/AES/RSA/ECDSA/SM2 | 8-12 | 原 12-18 | 排除未使用算法，减少汇编优化范围 |
| **TLS 协议** | TLS 1.2 + 1.3 + Keyless | 12-18 | 原 15-24 | Keyless 用回调替代 Provider，减少框架代码 |
| **X509/PKCS** | 证书/CSR + ASN.1/DER/PEM | 4-7 | 原 6-10 | 仅实现实际使用的子集 |
| **BIO/IO** | 无需实现 | 0 | 原 2-3 | 用仓颉原生 Stream 替代 |
| **硬件加速** | AES-NI + SM3/SM4 指令 | 3-5 | 原 4-8 | 仅优化实际使用的算法 |
| **FFI 桥接** | 仓颉层 API 对齐 | 2-3 | 原 3-5 | API 已定义，仅替换底层实现 |
| **测试与审计** | 单元/集成测试 + 安全审计 | 6-9 | 原 8-12 | 测试范围缩小 |
| **文档与合规** | API 文档 + 合规认证 | 1-3 | 原 2-4 | 文档范围缩小 |
| **合计** | | **36-57 人月** | 原 52-84 | **减少约 30%** |

### 16.3 AI 辅助开发对工作量的影响

#### 16.3.1 AI 辅助效率的客观评估

**重要前提**：加密/TLS 库属于安全关键代码，AI 辅助效率不能简单套用通用软件开发的数据。以下评估基于 2023-2025 年的学术研究和行业实践：

| 数据来源 | 场景 | 生产力提升 | 可信度 |
|---------|------|-----------|-------|
| GitHub/Microsoft 随机对照实验（2023） | Web 服务器开发（Copilot） | 55.8% | ★★★★★ 金标准 |
| McKinsey 报告（2023） | 文档/代码生成 | 20-50% | ★★★★ |
| McKinsey 报告（2023） | 复杂架构设计 | 10-15% | ★★★★ |
| 学术研究（Perry et al., 2023） | 安全关键代码 | **可能为负值** | ★★★★ |
| 多所大学联合研究（2023-2024） | LLM 生成密码学代码 | GPT-4 约 60% 输出含安全缺陷 | ★★★★ |
| 行业共识 | 密码学核心实现 | **不推荐 AI 生成** | ★★★★★ |

**关键结论**：
- 通用场景 AI 辅助效率 20-55%，但**安全关键代码领域，当前证据表明风险远大于收益**
- 目前**没有任何主流密码学库**（OpenSSL、BoringSSL、libsodium、ring）的核心实现使用 AI 生成代码
- AI 生成的密码学代码系统性问题：错误使用加密模式、硬编码密钥/IV、缺少认证标签验证、非常量时间实现
- GPT-4 生成 AES 实现时约 60% 存在至少一个安全缺陷；生成 TLS 配置时约 70% 存在已知弱点

#### 16.3.2 按模块重新评估 AI 辅助效率

基于上述研究数据，对每个模块的 AI 辅助效率进行修正：

| 模块 | AI 辅助效率 | 修正说明 |
|------|-----------|---------|
| **ASN.1/DER/PEM 编解码** | ★★★★☆ | 格式规范明确（RFC 5280），非安全关键路径，AI 可高效生成，但仍需人工审查边界条件 |
| **X509 证书解析/生成** | ★★★★☆ | 结构化数据格式，AI 擅长，但证书验证逻辑涉及安全判断，需人工审查 |
| **单元测试** | ★★★★★ | NIST/国密测试向量驱动，AI 可批量生成，安全风险最低 |
| **FFI 桥接层** | ★★★★☆ | 仓颉 foreign 接口模式化，AI 可批量生成绑定代码 |
| **文档编写** | ★★★★☆ | API 文档、注释生成，AI 擅长 |
| **摘要算法实现** | ★★★☆☆ | 算法规范公开，但**常量时间实现**需人工保证，AI 生成的代码可能存在侧信道漏洞 |
| **HMAC 实现** | ★★★☆☆ | 逻辑简单但仍是安全关键代码，需人工审查 |
| **对称加密模式** | ★★★☆☆ | CBC/GCM/CTR 逻辑标准化，但 GCM 认证标签验证、填充预言防护等需人工保证 |
| **随机数生成** | ★★★☆☆ | 系统调用封装看似简单，但 CSPRNG 的安全性要求极高，AI 可能引入微妙缺陷 |
| **TLS 1.2/1.3 协议** | ★★☆☆☆ | 状态机复杂，安全极度敏感，AI 生成代码需逐行人工审查，实际效率提升有限 |
| **非对称加密** | ★★☆☆☆ | RSA/ECDSA/SM2 的侧信道防护（常量时间、盲化）AI 无法可靠实现，需密码学专家 |
| **硬件加速** | ★☆☆☆☆ | AES-NI/SM3/SM4 汇编指令选择和时序控制，AI 几乎无法正确生成 |
| **安全审计** | ★☆☆☆☆ | 安全漏洞检测仍需专家，AI 可辅助扫描但不可替代 |

#### 16.3.3 AI 辅助的正确使用方式

AI 在加密/TLS 库开发中应定位为**辅助工具**而非**生成工具**：

| 使用方式 | 效率提升 | 安全风险 | 推荐度 |
|---------|---------|---------|-------|
| **生成测试用例** | 50-60% | 低 | ★★★★★ |
| **生成样板代码/FFI 绑定** | 40-50% | 低 | ★★★★★ |
| **生成 ASN.1/DER 编解码** | 30-40% | 中 | ★★★★ |
| **辅助代码审查** | 15-25% | 低 | ★★★★ |
| **生成算法参考实现** | 20-30% | 高 | ★★★（需完全重写安全关键部分） |
| **直接生成密码学核心代码** | 0-10% | 极高 | ★（不推荐） |

#### 16.3.4 修正后的 AI 辅助工作量

| 阶段 | 传统开发 | AI 辅助开发 | 效率提升 | 修正说明 |
|------|---------|-----------|---------|---------|
| **算法实现** | 8-12 人月 | 6-10 人月 | ~20% | 摘要/对称算法 AI 可生成参考实现，但安全关键部分（常量时间、侧信道防护）必须人工重写 |
| **TLS 协议** | 12-18 人月 | 10-16 人月 | ~15% | AI 仅辅助框架代码和文档，状态机和握手逻辑必须人工编写 |
| **X509/PKCS** | 4-7 人月 | 3-5 人月 | ~30% | ASN.1/DER 编解码 AI 可高效生成，证书验证逻辑需人工 |
| **硬件加速** | 3-5 人月 | 2.5-4 人月 | ~15% | C 语言 intrinsics AI 可辅助参考，汇编仍需人工 |
| **FFI 桥接** | 2-3 人月 | 1-1.5 人月 | ~50% | 模式化绑定代码 AI 可批量生成 |
| **测试** | 6-9 人月 | 3-4.5 人月 | ~50% | 测试向量驱动，AI 可批量生成 |
| **文档与合规** | 1-3 人月 | 0.5-1.5 人月 | ~40% | 文档生成 AI 擅长，合规认证仍需人工 |
| **合计** | **36-57 人月** | **26-42 人月** | **~25%** | 约 3-5 人团队 7-11 个月 |

#### 16.3.5 为什么 AI 辅助效率没有想象中高

1. **安全关键代码的特殊性**：加密库不是普通业务软件，一行代码的缺陷可能导致全系统被攻破。AI 生成的代码"看起来正确"但可能包含微妙漏洞，审查 AI 代码的时间可能不亚于从头编写。

2. **常量时间编程**：密码学操作必须抵抗时序攻击，所有分支和内存访问必须是常量时间的。AI 完全不理解这个约束，生成的代码几乎必然包含非常量时间操作。

3. **侧信道防护**：RSA 盲化、ECDSA 随机 k 值生成、填充预言防护等，需要密码学专业知识，AI 无法可靠实现。

4. **GCM 认证加密**：GCM 模式的 nonce 管理和认证标签验证有严格的数学要求，AI 经常在边界条件上出错。

5. **TLS 状态机**：TLS 握手是一个复杂的状态机，涉及多种密码套件、扩展和版本协商，AI 生成的状态机几乎必然有遗漏的边界情况。

6. **"审查成本"被低估**：对于安全关键代码，审查 AI 生成代码的成本 ≈ 从头编写的 60-80%，因为审查者必须验证每一行的安全性，而不能仅看逻辑正确性。

### 16.4 参考项目规模

| 项目 | 语言 | 代码量 | 开发周期 | 说明 |
|------|------|--------|---------|------|
| **Go crypto/tls** | Go | ~80,000 行 | 2009-2014（5年迭代） | 纯 Go，含 TLS 1.0-1.3 |
| **Go crypto/* 全部** | Go | ~200,000 行 | 2009-至今 | 含所有加密算法 |
| **rustls** | Rust | ~30,000 行 | 2016-至今 | 仅 TLS 1.2/1.3，不含加密原语 |
| **ring** | Rust | ~60,000 行 | 2015-至今 | 加密原语，大量汇编优化 |
| **BoringSSL** | C | ~400,000 行 | 2014-至今 | OpenSSL 分支，Google 维护 |
| **mbedTLS** | C | ~100,000 行 | 2006-至今 | 轻量级，适合嵌入式 |
| **OpenSSL** | C | ~500,000 行 | 1998-至今 | 功能最全，历史包袱重 |

### 16.5 分阶段实施建议（修正版）

#### 第一阶段：基础算法库（3-5 人月，AI 辅助）

实现不依赖 OpenSSL 的基础加密算法，替代 `crypto.digest` 和 `crypto.crypto` 模块：

- SM3/SHA-256/SHA-384/SHA-512/MD5 摘要算法（AI 高效辅助）
- SM4 对称加密 CBC/GCM/ECB/CFB/OFB/CTR 模式（AI 高效辅助）
- AES-256-CBC 解密（用于 PKCS8 密钥解密）
- HMAC（AI 高效辅助）
- 安全随机数 CSPRNG（AI 高效辅助）

**实际需替代的 OpenSSL 接口**：13 个 EVP_Digest* + 9 个 EVP_Decrypt* + 1 个 RAND_bytes = 23 个

**效果**：`crypto.digest` 和 `crypto.crypto` 模块不再依赖 OpenSSL

#### 第二阶段：非对称加密与密钥（4-7 人月，AI 辅助）

实现 RSA/ECDSA/SM2 密钥操作，替代 `crypto.keys` 模块：

- RSA-PKCS1/OAEP 签名与加密
- ECDSA/P-256/P-384 签名
- SM2 签名与加密
- PKCS#1/#8 密钥格式编解码（AI 高效辅助）
- 大数运算 BN_* 子集（12 个函数）

**实际需替代的 OpenSSL 接口**：16 个 EVP_PKEY* + 12 个 BN_* + 3 个 PKCS8/PKCS5 + 16 个 DER 编解码 = 47 个

**效果**：`crypto.keys` 模块不再依赖 OpenSSL

#### 第三阶段：X509 证书（2-4 人月，AI 高效辅助）

实现证书解析/生成/验证，替代 `crypto.x509` 模块：

- X.509 v3 证书解析与生成（ASN.1/DER AI 可高效生成）
- CSR (X509_REQ) 解析与生成
- 证书链验证
- PEM 编解码（3 个函数）

**实际需替代的 OpenSSL 接口**：49 个 X509_* + 9 个 ASN1_* + 3 个 PEM = 61 个

**效果**：`crypto.x509` 模块不再依赖 OpenSSL

#### 第四阶段：TLS 协议（9-14 人月，AI 部分辅助）

实现 TLS 1.2/1.3 协议，替代 `net.tls` 模块：

- TLS 1.2 握手与记录层（AI 辅助框架，人工审查状态机）
- TLS 1.3 握手与 0-RTT
- 密码套件协商
- 会话恢复与票证
- ALPN/SNI 扩展
- Keyless TLS（用回调替代 OpenSSL Provider 框架，**节省 OSSL_PARAM + OSSL_DISPATCH + OSSL_PROVIDER 共 15 个接口**）

**实际需替代的 OpenSSL 接口**：75 个 SSL_* + 3 个 SHA256_* = 78 个（Keyless 部分用回调替代，不实现 Provider 框架）

**效果**：`net.tls` 和 `net.http` 模块不再依赖 OpenSSL，**彻底消除 OpenSSL 依赖**

### 16.6 自研 vs 继续使用 OpenSSL 的决策矩阵

| 维度 | 继续使用 OpenSSL | 自研加密/TLS 库（传统） | 自研加密/TLS 库（AI 辅助） |
|------|-----------------|---------------------|----------------------|
| **用户体验** | ★★ 需安装 OpenSSL | ★★★★★ 零依赖，开箱即用 | ★★★★★ 零依赖，开箱即用 |
| **实现成本** | ★★★★★ 已完成 | ★★ 约 36-57 人月 | ★★★ 约 26-42 人月 |
| **安全性** | ★★★★ 依赖 OpenSSL 发版 | ★★★★ 自主可控，但需安全审计 | ★★★☆ 同左，但 AI 生成部分需额外审查 |
| **维护成本** | ★★★★ 跟随 OpenSSL 更新 | ★★ 需持续维护算法和协议 | ★★☆ 同左，AI 可辅助维护非安全关键部分 |
| **兼容性** | ★★★★★ OpenSSL 生态最全 | ★★★ 需逐步补齐功能 | ★★★ 同左 |
| **国密支持** | ★★★★ OpenSSL 3.x 内置 | ★★★★★ 可原生支持 | ★★★★★ 同左 |
| **性能** | ★★★★★ OpenSSL 高度优化 | ★★★ 初期无汇编优化 | ★★★ 同左，AI 无法可靠生成汇编优化 |
| **FIPS/合规** | ★★★★ OpenSSL 已认证 | ★ 需自行认证 | ★ 同左 |
| **OHOS 适配** | ★★★★★ 系统内置 | ★★★ 需额外适配 | ★★★ 同左 |

### 16.7 折中方案：渐进式替换

参考 Rust 的多后端模式，在 dynamicLoader 层增加抽象，支持多种加密后端：

```
stdx.crypto.* / stdx.net.tls
       │
       ▼
  CryptoBackend（抽象层）
       │
       ├─ OpenSSLBackend    ← 当前实现，继续维护
       ├─ NativeBackend     ← 自研实现，逐步替换
       ├─ PlatformBackend   ← macOS Security.framework / Windows CNG
       └─ BoringSSLBackend  ← FIPS 合规场景
```

**优势**：
- 不破坏现有功能，渐进式替换
- 用户可按需选择后端
- 不同平台可使用最优后端
- 降低单次投入风险

**实施路径**：
1. 定义 `CryptoBackend` 抽象接口
2. 将现有 OpenSSL 调用封装为 `OpenSSLBackend`
3. 逐步实现 `NativeBackend`（从基础算法开始）
4. 在特定平台实现 `PlatformBackend`
5. 默认后端策略：优先 Native → Platform → OpenSSL

### 16.8 工作量汇总对比

| 估算版本 | 代码量 | 人月（传统） | 人月（AI 辅助） | 团队规模 | 周期 |
|---------|--------|------------|--------------|---------|------|
| **原估算（基于 200+ API）** | 60,000-93,000 行 | 52-84 人月 | — | 4-7 人 | 1-1.5 年 |
| **修正估算（基于实际 241 接口）** | 32,000-48,000 行 | 36-57 人月 | 26-42 人月 | 3-5 人 | 7-11 月 |
| **减少幅度** | **-45%** | **-30%** | — | — | — |

**核心缩减因素**：
1. 排除 Provider 框架（OSSL_PARAM/OSSL_DISPATCH/OSSL_PROVIDER 共 15 个接口），Keyless TLS 用回调替代
2. 排除 BIO 抽象层（26 个接口），用仓颉原生 Stream 替代
3. 排除 ERR 错误队列（5 个接口），用仓颉异常体系替代
4. 排除 OPENSSL_sk_*/CRYPTO_malloc 等工具函数（21 个接口），用仓颉原生类型替代
5. 25+ 个 OpenSSL 结构体类型仅作透明指针，自研时直接替换为自有结构体
6. AI 辅助对测试、FFI 桥接、文档等非安全关键模块效率提升 40-50%
7. AI 对安全关键模块（算法核心、TLS 协议、硬件加速）效率提升仅 15-20%，因为审查成本接近从头编写

## 十七、将 OpenSSL 静态库链接进 stdx 产物的可行性分析

### 17.1 当前链接现状

| 产物类型 | OpenSSL 链接方式 | 符号解析模式 | 运行时依赖 |
|---------|----------------|------------|-----------|
| **动态库 (.so)** | 不链接 OpenSSL，仅链接 `libcangjie-dynamicLoader-opensslFFI.so` | Normal 模式（dlopen/dlsym） | 需系统安装 libcrypto.so.3 + libssl.so.3 |
| **默认静态库 (.a)** | 不链接 OpenSSL，内嵌 Auto 模式 opensslFFI 对象 | Auto 模式（弱符号 + dlopen 回退） | 默认需系统 OpenSSL；若用户静态链接 OpenSSL 则无需 |
| **Strong 静态库 (.a)** | 不链接 OpenSSL，内嵌 Strong 模式 opensslFFI 对象 | Strong 模式（直接符号引用） | 用户必须显式提供 OpenSSL 静态库 |

**核心问题**：三种产物都**不包含 OpenSSL 代码本身**，仅在运行时（Normal/Auto）或链接时（Strong）引用外部 OpenSSL 符号。用户必须自行安装或提供 OpenSSL。

### 17.2 静态链接 OpenSSL 到 stdx 的方案

#### 方案 A：将 OpenSSL 静态库链接进 stdx 动态库 (.so)

```
libcangjieStdx.so / libstdx.net.tls.so
  ├─ stdx 自身代码
  ├─ opensslFFI 代码（Normal/Auto/Strong）
  └─ libcrypto.a + libssl.a（静态链接嵌入）  ← 新增
```

**技术步骤**：
1. 编译 OpenSSL 时启用 `-fPIC`（共享库要求位置无关代码）
2. 修改 `PrepareOpenSSL.cmake`，将 `CMAKE_FIND_LIBRARY_SUFFIXES` 改为 `.a`
3. 使用 `-Wl,--whole-archive` 链接 OpenSSL 静态库确保所有符号被拉入
4. 添加版本脚本（Version Script）隐藏 OpenSSL 符号

**可行性评估**：

| 维度 | 评估 | 说明 |
|------|------|------|
| **技术可行性** | ✅ 可行 | 需 PIC 编译的 OpenSSL 静态库 |
| **符号冲突风险** | ⚠️ 高 | 若用户程序也链接系统 OpenSSL，两份 OpenSSL 符号会冲突 |
| **产物体积** | ⚠️ 增加 | libcrypto.a 约 5-8 MB，libssl.a 约 1-2 MB |
| **安全更新** | ❌ 无法热更新 | OpenSSL CVE 修复需重新发布 stdx |
| **许可证** | ✅ 合规 | OpenSSL 3.x Apache 2.0 允许，需保留归属声明 |

#### 方案 B：将 OpenSSL 静态库链接进 stdx 静态库 (.a)

```
libstdx.net.tls.a
  ├─ stdx 自身代码 .o
  ├─ opensslFFI .o（Strong 模式）
  └─ libcrypto.a + libssl.a 的所有 .o  ← 新增
```

**技术步骤**：
1. 使用 `ar x` 解压 OpenSSL 静态库
2. 将解压的 `.o` 文件与 stdx 的 `.o` 合并为一个 `.a`
3. 或使用 `ar -M` 脚本合并归档

**可行性评估**：

| 维度 | 评估 | 说明 |
|------|------|------|
| **技术可行性** | ✅ 可行 | `.a` 是 `.o` 的归档，合并简单 |
| **符号冲突风险** | ⚠️ 中 | 静态库不直接导出符号，但最终链接时仍可能冲突 |
| **产物体积** | ⚠️ 增加 | 同方案 A |
| **安全更新** | ❌ 无法热更新 | 同方案 A |
| **许可证** | ✅ 合规 | 同方案 A |

#### 方案 C：提供独立的"捆绑 OpenSSL"变体（推荐）

不修改现有产物，新增一个**内置 OpenSSL 的变体**：

```
产物布局：
  dynamic/stdx/                    ← 现有动态库（不变）
  static/stdx/                     ← 现有默认静态库（不变）
  static-static-link-extern/stdx/  ← 现有 Strong 静态库（不变）
  bundled/stdx/                    ← 新增：内置 OpenSSL 的动态库
    ├─ libcangjieStdx.so           ← 内含 OpenSSL 代码
    ├─ libstdx.net.tls.so          ← 内含 OpenSSL 代码
    └─ ...
```

**优势**：
- 不影响现有三种产物的用户
- 用户可按需选择是否使用捆绑版本
- 捆绑版本零外部依赖，开箱即用

### 17.3 核心技术挑战：符号冲突

#### 17.3.1 冲突场景

```
用户应用
├── libstdx.net.tls.so（内含静态链接的 OpenSSL 3.x）
└── libcurl.so（动态链接系统 OpenSSL 3.x）
     └── libcrypto.so.3（系统 OpenSSL）
```

此时进程中有**两份 OpenSSL 代码**：
- stdx 内嵌的 OpenSSL（静态链接）
- 系统的 libcrypto.so.3（动态链接）

Linux 动态链接器使用**全局符号介入**（Global Symbol Interposition）：对同一符号的引用解析到最先加载的那个。这会导致：
- stdx 调用的 `SSL_read` 可能被解析到系统 OpenSSL 的实现
- 系统库调用的 `EVP_EncryptInit` 可能被解析到 stdx 内嵌的 OpenSSL
- **两份 OpenSSL 的全局状态（错误队列、线程局部存储等）互相干扰**

#### 17.3.2 解决方案：版本脚本隐藏符号

这是最实用的方案，使用链接器版本脚本控制符号导出：

```ld
/* stdx_bundled.version */
{
    global:
        CJ_*;              /* 仓颉公共 API 前缀 */
        cangjie_*;         /* 仓颉运行时 API */
        stdx_*;            /* stdx 公共 API */
    local:
        *;                 /* 隐藏所有其他符号，包括 OpenSSL 的 */
};
```

```bash
clang -shared -Wl,--version-script=stdx_bundled.version \
    -Wl,--whole-archive \
    /path/to/libssl.a /path/to/libcrypto.a \
    -Wl,--no-whole-archive \
    -o libstdx.net.tls.so ...
```

**效果**：`local: *` 隐藏所有未显式列出的符号，OpenSSL 符号不会泄漏到动态符号表中。

**验证方法**：
```bash
# 检查是否有 OpenSSL 符号泄漏
nm -D libstdx.net.tls.so | grep -iE "SSL_|EVP_|BIO_|X509_"
# 无输出则表示符号已成功隐藏
```

#### 17.3.3 辅助措施：-Bsymbolic-functions

```bash
clang -shared -Wl,-Bsymbolic-functions \
    -Wl,--version-script=stdx_bundled.version \
    ...
```

`-Bsymbolic-functions` 让共享库内部的函数调用在链接时解析（而非运行时），避免全局符号介入导致 stdx 内部调用被劫持到外部 OpenSSL。

#### 17.3.4 macOS 平台适配

macOS 不支持 `--version-script`，需使用 `exported_symbols_list`：

```
# stdx_bundled.exports
_CJ_.*
_cangjie_.*
_stdx_.*
```

```bash
clang -dynamiclib \
    -Wl,-exported_symbols_list,stdx_bundled.exports \
    -o libstdx.net.tls.dylib ...
```

### 17.4 安全性影响

| 场景 | 动态链接（当前） | 静态链接 OpenSSL |
|------|---------------|----------------|
| OpenSSL CVE 发布 | 用户 `apt upgrade` 即可修复 | **必须重新发布 stdx** |
| 用户更新 | 自动受益 | 必须等待 stdx 发版 |
| 版本追踪 | `openssl version` 即可 | 需查询 stdx 发布说明 |
| 合规审计 | 系统包管理器可查 | 需文档记录内嵌版本 |

**缓解措施**：
1. 建立 OpenSSL 安全公告监控机制
2. CVE 发布后 48 小时内发布 stdx 更新版本
3. 在 stdx 文档和发布说明中明确标注内嵌的 OpenSSL 版本
4. 提供 API 查询内嵌 OpenSSL 版本号

### 17.5 许可证合规

OpenSSL 3.x 采用 **Apache License 2.0**：

| 义务 | 说明 |
|------|------|
| 保留版权声明 | 分发时必须包含 OpenSSL 的 LICENSE 文件 |
| 保留 NOTICE | 必须包含 NOTICE 文件中的归属信息 |
| 声明修改 | 如果修改了 OpenSSL 代码，必须标注修改内容 |
| 专利授权 | Apache 2.0 包含专利授权条款，对使用者有利 |

**stdx 需要做的**：
1. 在 stdx 分发包中包含 OpenSSL 的 LICENSE 和 NOTICE 文件
2. 在文档中声明使用了 OpenSSL 及其版本
3. 如果修改了 OpenSSL 代码，标注修改内容

### 17.6 产物体积影响

| 产物 | 当前体积（估算） | 内嵌 OpenSSL 后（估算） | 增量 |
|------|---------------|---------------------|------|
| libcangjieStdx.so | ~2 MB | ~10 MB | +8 MB |
| libstdx.net.tls.so | ~1 MB | ~9 MB | +8 MB |
| libstdx.crypto.digest.so | ~0.5 MB | ~6 MB | +5.5 MB |
| libstdx.crypto.keys.so | ~0.5 MB | ~7 MB | +6.5 MB |
| libstdx.crypto.x509.so | ~0.5 MB | ~7 MB | +6.5 MB |

**注意**：如果多个 .so 都内嵌 OpenSSL，会有大量重复代码。可通过以下方式优化：
- 仅在 `libcangjieStdx.so` 中内嵌 OpenSSL，其他 .so 依赖它
- 或合并为一个单独的 .so（monolithic build）
- 使用 `-Wl,--gc-sections -ffunction-sections -fdata-sections` 裁剪未使用的 OpenSSL 代码

### 17.7 实施方案对比

| 方案 | 用户体验 | 技术复杂度 | 符号冲突风险 | 安全更新 | 推荐度 |
|------|---------|-----------|------------|---------|-------|
| **A: 链接到 .so** | ★★★★★ 零依赖 | ★★★ 中 | ⚠️ 需版本脚本 | ❌ 需重发 | ★★★ |
| **B: 链接到 .a** | ★★★☆ 需链接但无需 OpenSSL | ★★ 低 | ⚠️ 最终链接时可能冲突 | ❌ 需重发 | ★★★ |
| **C: 独立捆绑变体** | ★★★★★ 零依赖 | ★★★★ 较高 | ⚠️ 需版本脚本 | ❌ 需重发 | ★★★★ |
| **当前 Strong 模式** | ★★ 需用户提供 OpenSSL | ★ 最低 | ✅ 无冲突 | ✅ 用户自行更新 | ★★★ |
| **当前 Auto 模式** | ★★ 需系统安装 OpenSSL | ★ 最低 | ✅ 无冲突 | ✅ 系统更新 | ★★★ |

### 17.8 推荐实施路径

**推荐方案 C：独立捆绑变体**，具体实施步骤：

#### 第一步：构建基础设施（1-2 周）

1. 在 CMake 中新增 `CANGJIE_BUNDLE_OPENSSL` 选项
2. 修改 `PrepareOpenSSL.cmake`，当 `BUNDLE_OPENSSL=ON` 时查找静态库（`.a`）
3. 创建版本脚本文件 `stdx_bundled.version`（Linux）和导出列表 `stdx_bundled.exports`（macOS）
4. 确保 OpenSSL 静态库以 `-fPIC` 编译

#### 第二步：修改链接配置（1-2 周）

1. 修改 `MakeCJNATIVEStdSharedLib.cmake`，捆绑模式下添加：
   - `-Wl,--whole-archive` + OpenSSL 静态库路径 + `-Wl,--no-whole-archive`
   - `-Wl,--version-script=stdx_bundled.version`（Linux）
   - `-Wl,-exported_symbols_list,stdx_bundled.exports`（macOS）
   - `-Wl,-Bsymbolic-functions`
2. 使用 Strong 模式的 opensslFFI 对象（直接符号引用，无需 dlopen）
3. 添加 `-Wl,--gc-sections -ffunction-sections -fdata-sections` 裁剪未使用代码

#### 第三步：安装与发布（1 周）

1. 新增 `bundled/stdx/` 安装目录
2. 在发布包中包含 OpenSSL 的 LICENSE 和 NOTICE 文件
3. 文档标注内嵌的 OpenSSL 版本
4. 提供 API 查询内嵌版本号

#### 第四步：安全更新流程（持续）

1. 监控 OpenSSL 安全公告
2. CVE 发布后评估影响并更新内嵌版本
3. 发布 stdx 更新版本

**总工作量估算**：3-5 周（不含安全更新持续维护）

### 17.9 与现有 Strong 模式的关系

| 对比项 | Strong 模式 | 捆绑 OpenSSL 模式 |
|--------|-----------|-----------------|
| OpenSSL 提供方 | 用户自行提供 | stdx 内嵌 |
| 用户操作 | 需下载 OpenSSL 并配置链接 | 无需任何操作 |
| 符号解析 | Strong 模式（直接引用） | Strong 模式（直接引用） |
| 安全更新 | 用户自行更新 OpenSSL | stdx 发版更新 |
| 产物体积 | 无额外体积 | 增加 5-8 MB |
| 适用场景 | 企业用户、有 OpenSSL 管理能力 | 个人开发者、嵌入式、开箱即用 |

捆绑模式本质上是 **Strong 模式 + OpenSSL 静态库 + 版本脚本** 的组合，用户无需关心 OpenSSL 的安装和配置。
