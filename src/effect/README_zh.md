# cangjie_stdx::effect

## 简介

`cangjie_stdx::effect` 模块提供了一种强大的非局部控制操作机制。它提供了用于处理 Effect Handler 特性的用户级 API。这是一个实验性功能，需要使用支持该机制的 Cangjie 编译器。

## 特性

- **Effect 处理器**：提供以受控方式处理效果的机制
- **非局部控制流**：支持超出传统异常处理的非局部控制操作
- **可组合的效果**：支持多个效果的组合
- **类型安全**：确保类型安全的效果处理

## 实验状态

此模块目前处于实验阶段，未来版本可能会发生重大更改。它需要支持 Effect Handler 机制的 Cangjie 编译器。

## 使用方法

要在项目中使用 effect 模块，请在 `cjpm.toml` 中添加以下依赖：

```toml
[dependencies]
stdx = { path = "path/to/stdx" }
```

然后导入 effect 模块：

```cj
import cangjie_stdx::effect
```

## 文档

详细的 API 文档请参阅 [stdx API 文档](../../doc/summary_cjnative.md)。

## 许可证

此模块是 Cangjie stdx 项目的一部分，遵循相同的许可条款。
