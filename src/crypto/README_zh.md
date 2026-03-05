# cangjie_stdx::crypto

## 简介

`cangjie_stdx::crypto` 模块提供了密码学操作的综合工具库。它包括安全加密能力、消息摘要算法、非对称加解密和签名算法、数字证书处理功能。

## 特性

- **对称加密**：支持多种对称加密算法
- **非对称密码学**：提供公钥密码学操作
- **消息摘要**：实现用于数据完整性验证的哈希算法
- **数字签名**：支持数字签名的签名和验证
- **证书处理**：处理用于安全通信的数字证书
- **密钥管理**：提供加密密钥生成和管理的工具

## 子模块

- **cangjie_stdx::crypto.common**：通用密码学工具和常量
- **cangjie_stdx::crypto.crypto**：核心密码学操作
- **cangjie_stdx::crypto.digest**：消息摘要和哈希算法
- **cangjie_stdx::crypto.keys**：加密密钥管理
- **cangjie_stdx::crypto.kit**：额外的密码学工具包

## 使用方法

要在项目中使用 crypto 模块，请在 `cjpm.toml` 中添加以下依赖：

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

然后导入 crypto 模块：

```cj
import cangjie_stdx::crypto
```

## 文档

详细的 API 文档请参阅 [stdx API 文档](../../doc/summary_cjnative.md)。

## 安全提示

此模块使用 OpenSSL 进行密码学操作。请确保使用安全且最新版本的 OpenSSL。

## 许可证

此模块是 Cangjie stdx 项目的一部分，遵循相同的许可条款。
