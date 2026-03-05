# cangjie_stdx::net

## 简介

`cangjie_stdx::net` 模块提供了网络通信和安全传输功能。它包括对 HTTP 和 TLS 协议的支持，用于构建网络应用程序。

## 特性

- **HTTP 客户端/服务器**：提供 HTTP 客户端和服务器功能
- **TLS 支持**：通过 TLS/SSL 提供安全通信
- **网络工具**：包含常用的网络工具函数
- **安全传输**：支持通过网络进行加密数据传输

## 子模块

- **cangjie_stdx::net.http**：HTTP 客户端和服务器实现
- **cangjie_stdx::net.tls**：TLS/SSL 安全通信支持
- **cangjie_stdx::net.tls.common**：通用 TLS 工具和常量

## 使用方法

要在项目中使用 net 模块，请在 `cjpm.toml` 中添加以下依赖：

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

然后导入 net 模块：

```cj
import cangjie_stdx::net
```

## 文档

详细的 API 文档请参阅 [stdx API 文档](../../doc/summary_cjnative.md)。

## 许可证

此模块是 Cangjie stdx 项目的一部分，遵循相同的许可条款。
