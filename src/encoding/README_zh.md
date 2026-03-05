# cangjie_stdx::encoding

## 简介

`cangjie_stdx::encoding` 模块提供了数据编码和解码的基础工具库。它包括对多种编码格式的支持，包括 base64、hex、JSON 和 URL 编码。

## 特性

- **Base64 编码**：提供 Base64 编码和解码功能
- **Hex 编码**：支持十六进制编码和解码
- **JSON 编码**：提供 JSON 序列化和反序列化
- **URL 编码**：为 Web 应用程序提供 URL 编码和解码
- **流式处理**：支持大数据的流式操作

## 子模块

- **cangjie_stdx::encoding.base64**：Base64 编码和解码
- **cangjie_stdx::encoding.hex**：十六进制编码和解码
- **cangjie_stdx::encoding.json**：JSON 序列化和反序列化
- **cangjie_stdx::encoding.json.stream**：流式 JSON 处理
- **cangjie_stdx::encoding.url**：URL 编码和解码

## 使用方法

要在项目中使用 encoding 模块，请在 `cjpm.toml` 中添加以下依赖：

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

然后导入 encoding 模块：

```cj
import cangjie_stdx::encoding
```

## 文档

详细的 API 文档请参阅 [stdx API 文档](../../doc/summary_cjnative.md)。

## 许可证

此模块是 Cangjie stdx 项目的一部分，遵循相同的许可条款。
