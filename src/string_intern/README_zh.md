# cangjie_stdx::string_intern

## 简介

`cangjie_stdx::string_intern` 模块提供了字符串对象的池化缓存能力。它通过维护唯一字符串实例的池来实现高效的字符串存储和比较。

## 特性

- **字符串池化**：维护唯一字符串实例的池
- **内存效率**：通过共享相同字符串减少内存使用
- **快速比较**：通过引用相等实现快速字符串比较
- **去重**：自动去重相同的字符串

## 使用方法

要在项目中使用 string_intern 模块，请在 `cjpm.toml` 中添加以下依赖：

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

然后导入 string_intern 模块：

```cj
import cangjie_stdx::string_intern
```

## 文档

详细的 API 文档请参阅参阅 [stdx API 文档](../../doc/summary_cjnative.md)。

## 许可证

此模块是 Cangjie stdx 项目的一部分，遵循相同的许可条款。
