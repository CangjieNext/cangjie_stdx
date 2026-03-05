---
name: "stdx-debugger"
description: "Debugs and diagnoses issues in cangjie_stdx library. Invoke when user asks about stdx bugs, errors, or needs to locate code in stdx modules like http/tls/crypto/encoding etc."
---

# STDX 库问题定位技能

此技能帮助定位和诊断仓颉扩展库 (stdx) 中的问题。

## 项目概述

stdx 是仓颉编程语言的扩展库，位于 `/home/xdst/cangjie_stdx`，提供以下功能模块：

| 模块 | 路径 | 功能说明 |
|------|------|----------|
| actors | `src/stdx/actors/` | Actor 并发编程模型 |
| aspectCJ | `src/stdx/aspectCJ/` | 面向切面编程 (AOP) |
| compress | `src/stdx/compress/` | 压缩解压 (zlib, tar, gzip) |
| crypto | `src/stdx/crypto/` | 密码学工具 (摘要、密钥、证书) |
| dynamicLoader | `src/stdx/dynamicLoader/` | OpenSSL 动态加载 |
| effect | `src/stdx/effect/` | 非局部控制操作 (实验性) |
| encoding | `src/stdx/encoding/` | 编解码 (json, base64, hex, url) |
| fuzz | `src/stdx/fuzz/` | 模糊测试 |
| log | `src/stdx/log/` | 日志记录 |
| logger | `src/stdx/logger/` | 格式化日志 |
| net | `src/stdx/net/` | 网络通信 (http, tls, websocket) |
| serialization | `src/stdx/serialization/` | 序列化/反序列化 |
| string_intern | `src/stdx/string_intern/` | 字符串池化缓存 |
| syntax | `src/stdx/syntax/` | 仓颉语法解析 |
| unittest | `src/stdx/unittest/` | 单元测试扩展 |
| chir | `src/stdx/chir/` | 类型定义 |

## 问题定位流程

### 1. 确定问题模块

根据错误信息或功能关键词，确定涉及的模块：

- **HTTP 相关问题**: `src/stdx/net/http/`
- **TLS/SSL 问题**: `src/stdx/net/tls/`
- **加密/解密问题**: `src/stdx/crypto/`
- **JSON 处理问题**: `src/stdx/encoding/json/`
- **压缩解压问题**: `src/stdx/compress/`

### 2. 关键文件定位

#### HTTP 模块 (`src/stdx/net/http/`)
- `client.cj` / `server.cj` - HTTP 客户端/服务端核心
- `http_client1_1.cj` / `http_server1_1.cj` - HTTP/1.1 实现
- `http_client2_0.cj` / `http_server2_0.cj` - HTTP/2.0 实现
- `websocket.cj` / `websocket_conn.cj` - WebSocket 实现
- `cookie.cj` / `cookie_jar.cj` - Cookie 管理
- `hpack_*.cj` - HPACK 压缩实现

#### TLS 模块 (`src/stdx/net/tls/`)
- `tls_socket.cj` - TLS Socket 实现
- `certificate.cj` - 证书处理
- `cipher_suite.cj` - 加密套件
- `tls_common/` - TLS 通用接口

#### Crypto 模块 (`src/stdx/crypto/`)
- `crypto/crypto.cj` - 核心加密功能
- `crypto/secure_random.cj` - 安全随机数
- `digest/` - 摘要算法 (SHA, MD5, SM3, HMAC)
- `keys/` - 密钥处理 (RSA, ECDSA, SM2)
- `x509/` - X.509 证书处理
- `common/` - 通用工具 (PEM 解析, DER 编码)

#### Encoding 模块 (`src/stdx/encoding/`)
- `json/json_object.cj` - JSON 对象
- `json/json_value.cj` - JSON 值
- `json/stream/json_reader.cj` - JSON 流读取
- `json/stream/json_writer.cj` - JSON 流写入
- `base64/` - Base64 编解码
- `hex/` - 十六进制编解码
- `url/` - URL 编解码

#### Compress 模块 (`src/stdx/compress/`)
- `zlib/deflate.cj` - 压缩
- `zlib/inflate.cj` - 解压
- `zlib/zlib_stream.cj` - 流式处理
- `tar/tar_reader.cj` - TAR 读取
- `tar/tar_writer.cj` - TAR 写入

### 3. 依赖关系分析

模块依赖关系（用于链接顺序）：

```
stdx.net.http → stdx.net.tls → stdx.crypto.x509 → stdx.crypto.crypto → stdx.crypto.digest → stdx.crypto.common → stdx.encoding.base64
                                    ↓
                            stdx.encoding.hex
```

完整依赖链参见 `doc/libs_stdx/libs_overview.md`。

### 4. 构建相关问题

#### 构建脚本位置
- `build.py` - Python 构建脚本
- `cjpm_build.py` - CJPM 构建脚本
- `build.cj` - 仓颉构建脚本
- `CMakeLists.txt` - CMake 构建配置

#### 构建工具链
- `build/common/linux_toolchain.cmake` - Linux 工具链
- `build/common/darwin_toolchain.cmake` - macOS 工具链
- `build/common/mingw_x86_64_toolchain.cmake` - Windows 工具链

#### OpenSSL 依赖
- 动态加载: `src/stdx/dynamicLoader/opensslSymbols.h`
- 静态链接: 需要额外配置 `-lssl -lcrypto`

### 5. 常见问题排查

#### 问题：找不到符号/链接错误
1. 检查 `cjpm.toml` 中的 `bin-dependencies` 配置
2. 确认库链接顺序符合依赖关系
3. Linux 需添加 `-ldl`，Windows 需添加 `-lcrypt32`

#### 问题：OpenSSL 相关错误
1. 检查 OpenSSL 库路径配置
2. 查看 `src/stdx/dynamicLoader/` 中的符号加载
3. 确认 OpenSSL 版本兼容性

#### 问题：HTTP/TLS 连接问题
1. 检查证书配置 (`src/stdx/crypto/x509/`)
2. 查看加密套件支持 (`src/stdx/net/tls/cipher_suite.cj`)
3. 检查协议版本配置

#### 问题：JSON 解析错误
1. 查看 `src/stdx/encoding/json/json_exception.cj`
2. 检查 `json_value.cj` 中的类型处理
3. 流式处理问题查看 `json/stream/`

### 6. 文档参考

- API 文档: `doc/libs_stdx/` (中文) / `doc/libs_stdx_en/` (英文)
- 包概述: `doc/libs_stdx/libs_overview.md`
- 源码依赖: `doc/libs_stdx/source_code_dependency.md`
- 构建说明: `README_zh.md`

## 搜索策略

### 按功能搜索
```
# HTTP 相关
SearchCodebase: "HTTP client implementation" in /home/xdst/cangjie_stdx/src/stdx/net/http/

# TLS 相关  
SearchCodebase: "TLS handshake" in /home/xdst/cangjie_stdx/src/stdx/net/tls/

# 加密相关
SearchCodebase: "AES encryption" in /home/xdst/cangjie_stdx/src/stdx/crypto/
```

### 按错误类型搜索
```
# 异常定义
Grep: "class.*Exception" in /home/xdst/cangjie_stdx/src/stdx/

# 错误处理
Grep: "throw.*Exception" in /home/xdst/cangjie_stdx/src/stdx/
```

### 按类/接口搜索
```
# 查找类定义
Grep: "public class|public interface" in specific module directory

# 查找函数定义
Grep: "public func|public open func" in specific module directory
```

## 平台支持

| 操作系统 | CPU 架构 | 特殊要求 |
|---------|---------|---------|
| Linux | x86_64, aarch64 | glibc 2.22+, libstdc++ 6.0.24+ |
| Windows | x86_64 | Windows 10+ |
| macOS | x86_64, aarch64 | macOS 12.0+ |
| OpenHarmony | aarch64, arm32 | OpenHarmony 5.1+ |

## 注意事项

1. stdx 不承诺跨版本 API/ABI 兼容性
2. 使用动态库时 OpenSSL 通过运行时加载
3. 静态链接 OpenSSL 需注意链接顺序
4. aspectCJ 和 syntax 不包含在 cjpm 构建产物中
5. Windows 平台无 fuzz 包
