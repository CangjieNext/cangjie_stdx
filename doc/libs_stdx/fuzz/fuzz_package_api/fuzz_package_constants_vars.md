# 常量&变量

## let FUZZ_VERSION

```cangjie
public let FUZZ_VERSION: String = "1.0.0"
```

功能：Fuzz 版本。

> **注意：**
>
> 不支持平台：Windows。

类型：String

示例：

<!-- verify -->
```cangjie
import stdx.fuzz.fuzz.*

main() {
    println("Fuzz 版本: ${FUZZ_VERSION}")
    return 0
}
```

运行结果：

```text
Fuzz 版本: 1.0.0
```
