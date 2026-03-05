# cangjie_stdx::logger

## 简介

`cangjie_stdx::logger` 模块提供了文本格式和 JSON 格式的日志打印功能。它支持多种输出格式的灵活日志记录能力。

## 特性

- **多种格式**：支持文本和 JSON 日志格式
- **结构化日志**：支持结构化日志输出，便于解析和分析
- **可配置输出**：允许自定义日志输出目标
- **丰富的元数据**：在日志条目中包含时间戳、日志级别和其他元数据

## 使用方法

要在项目中使用 logger 模块，请在 `cjpm.toml` 中添加以下依赖：

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

然后导入 logger 模块：

```cj
import cangjie_stdx::logger
```

## 文档

详细的 API 文档请参阅 [stdx API 文档](../../doc/summary_cjnative.md)。

## 许可证

此模块是 Cangjie stdx 项目的一部分，遵循相同的许可条款。
