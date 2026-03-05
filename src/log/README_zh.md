# cangjie_stdx::log

## 简介

`cangjie_stdx::log` 模块为仓颉应用程序提供了一个单一的日志 API。它为整个应用程序的日志操作提供了统一的接口。

## 特性

- **统一 API**：提供单一、一致的日志接口
- **多种日志级别**：支持各种日志级别（debug、info、warning、error、fatal）
- **灵活配置**：允许自定义日志行为
- **高性能**：优化以最小化性能影响

## 使用方法

要在项目中使用 log 模块，请在 `cjpm.toml` 中添加以下依赖：

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

然后导入 log 模块：

```cj
import cangjie_stdx::log
```

## 文档

详细的 API 文档请参阅 [stdx API 文档](../../doc/summary_cjnative.md)。

## 许可证

此模块是 Cangjie stdx 项目的一部分，遵循相同的许可条款。
