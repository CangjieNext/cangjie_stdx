# cangjie_stdx::compress

## 简介

`cangjie_stdx::compress` 模块提供了各种压缩算法的压缩和解压缩功能。它通过减少数据大小来实现高效的数据存储和传输。

## 特性

- **多种压缩格式**：支持多种压缩算法，包括 zlib、tar 和 gzip
- **流式处理**：提供流式和内存中的压缩/解压缩
- **高性能**：通过原生实现优化性能
- **易于集成**：简单的 API，可无缝集成到应用程序中

## 支持的格式

- **zlib**：DEFLATE 压缩算法
- **tar**：多文件存档格式
- **gzip**：GNU zip 压缩格式

## 使用方法

要在项目中使用 compress 模块，请在 `cjpm.toml` 中添加以下依赖：

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

然后导入 compress 模块：

```cj
import cangjie_stdx::compress
```

## 文档

详细的 API 文档请参阅 [stdx API 文档](../../doc/summary_cjnative.md)。

## 许可证

此模块是 Cangjie stdx 项目的一部分，遵循相同的许可条款。
