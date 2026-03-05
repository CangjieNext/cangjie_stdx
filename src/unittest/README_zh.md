# cangjie_stdx::unittest

## 简介

`cangjie_stdx::unittest` 模块提供了在编写仓颉项目单元测试代码时输入序列化格式的测试数据的能力。它通过额外的测试数据管理功能扩展了标准单元测试能力。

## 特性

- **序列化测试数据**：支持以序列化格式提供测试数据
- **数据驱动测试**：支持使用多个测试用例的数据驱动测试
- **测试数据管理**：提供管理和组织测试数据的工具
- **集成性**：与仓颉的单元测试框架无缝集成

## 使用方法

要在项目中使用 unittest 模块，请在 `cjpm.toml` 中添加以下依赖：

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

然后导入 unittest 模块：

```cj
import cangjie_stdx::unittest
```

## 文档

详细的 API 文档请参阅 [stdx API 文档](../../doc/summary_cjnative.md)。

## 许可证

此模块是 Cangjie stdx 项目的一部分，遵循相同的许可条款。
