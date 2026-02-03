# stdx.effect

## 功能介绍

Effect Handlers 是一种强大的非局部控制操作，最初在函数式编程语言中引入，旨在表达副作用，但随后也被证明在面向对象和过程式语言中同样具有实用价值。

与异常机制类似，异常可以被抛出（throw）和捕获（catch），而效应则通过执行（`perform`）与处理（`handle`）来控制。但二者存在一个重要差异，当异常被捕获时，触发异常的计算过程已经中止，无法恢复；而在处理一个效应时，Effect Handlers 可以选择恢复触发该效应的计算过程，将控制权返回至 `perform` 执行点。

### 核心结构

Effect Handlers 在语法上扩展了传统的 `try-catch` 结构，增加了用于处理 effect 的 `handle` 子句。一个 `try` 表达式除了可以包含 `catch` 块来处理异常外，还可以包含一个或多个 `handle` 块来处理通过 `perform` 触发的 effect。Effect Handlers 有以下核心结构：

- **`Command<T>` 接口：**

    所有 effect 都必须继承 `Command<T>`，`T` 是该 effect 恢复执行时返回的类型。可以通过重写 `defaultImpl` 方法提供默认行为（未被任何 handler 捕获时调用）。

- **`perform` 表达式：**

    `perform expr` 会触发一个 effect，其中 `expr` 必须是 `Command<T>` 的实例。如果被 handler 恢复，`perform` 表达式的值类型为 `T`。

- **`handle` 子句：**

    handle 子句用于定义 effect 被触发时的处理逻辑。运行时会匹配最近的 handle 子句并进入处理代码块。在 handle 中，需要调用 resume 表达式来恢复执行。

    语法：

    ```cangjie
    try{
        ...  
    } handle (cmd: Command<T>) {
        // 处理逻辑
        resume with value
    }
    ```

    其中：

    - `cmd` 绑定到触发的 effect 对象
    - `with value` 的 `value` 类型必须与 `T` 相同

- **`resume` 表达式：**

    `resume with value` 会将执行流程恢复到 `perform` 处，并返回 `value` 作为该 `perform` 表达式的结果，也可以用 `resume throwing exn` 抛出异常。

### 基本语法

```cangjie
class MyEffect <: Command<String> {}

try {
    let result = perform MyEffect()
    println(result)
} handle (e: MyEffect) {
    resume with "Hello"
}
```

运行流程：

1. 进入 `try` 块，执行到 `perform MyEffect()` 时触发 effect
2. 匹配到 `handle (e: MyEffect)`，进入 handler
3. 执行 `resume with "Hello"`
4. 回到 `perform` 处，该表达式结果为 `"Hello"`
5. 继续往下执行 `println`

### 类型规则

- `perform expr` 的类型为 `Command<T>` 的 `T`
- `handle` 捕获的类型必须是 `Command` 的子类
- `resume with value` 中 `value` 的类型必须是 `T`
- `resume throwing exn` 中 `exn` 必须是 `Exception` 或 `Error` 的子类型

### 示例

#### 示例 1：基础用法

```cangjie
import stdx.effect.Command

class Eff <: Command<Int64> {}

main() {
    try {
        let x = perform Eff()
        println(x)
    } handle (e: Eff) {
        resume with 42
    }
}
```

输出：

```text
42
```

#### 示例 2：抛出异常

```cangjie
import stdx.effect.Command

class Eff <: Command<Unit> {}

main() {
    try {
        perform Eff()
    } handle (e: Eff) {
        resume throwing Exception("Error from effect")
    } catch (exn: Exception) {
        println(exn.message)
    }
}
```

输出：

```text
Error from effect
```

#### 示例 3：默认实现

```cangjie
import stdx.effect.Command

class Print <: Command<Unit> {
    Print (let msg: String) {}
    override func defaultImpl(): Unit {
        println(msg)
    }
}

main() {
    perform Print("No handler here") // 调用默认实现
}
```

输出：

```text
No handler here
```

> **说明：**
> Effect Handler 是一项实验性功能，需要配合支持该机制的 Cangjie 编译器使用。
> 编译带有 Effect Handlers 的代码时需要启用编译选项 `--experimental` 和 `--enable-eh`。
> 并且因为 Effect Handlers 还是一项实验性特性，所以对工具的支持工作还在进行中，具体情况如下：

| 工具              | 支持情况                            |
| --------------- | ------------------------------- |
| **Cjdb**        |  已可正常使用                        |
| **LSP**         |  暂不识别与 Effect Handlers 相关的关键字 |
| **Formatter**   |  尚未支持                          |
| **Coverage** |  尚未支持                          |
| **Cjlint**      |  尚未支持                          |

## API 列表

### 类

| 类名                   | 功能                                                     |
| ---------------------- | ------------------------------------------------------------ |
| [Command\<Res>](./effect_package_api/effect_package_classes.md#class-commandres)         | 一个抽象类，表示一种**效应（effect）**，该效应预期会返回类型为 `Res` 的结果。该类提供了一个可以被重写的默认处理本类效应的方法 [defaultImpl](./effect_package_api/effect_package_classes.md#func-defaultimpl)，该默认处理方法在效应没有被处理的时候调用，默认实现会抛出 [UnhandledCommandException](./effect_package_api/effect_package_exceptions.md#class-unhandledcommandexception) 异常。 |

### 异常类

| 异常类名                    | 功能                                                     |
| --------------------------- | ------------------------------------------------------------ |
| [DoubleResumeException](./effect_package_api/effect_package_exceptions.md#class-doubleresumeexception)     | 当对同一个效应尝试进行多次 resume（恢复）操作时抛出的异常。每个效应最多只能恢复一次。 |
| [UnhandledCommandException](./effect_package_api/effect_package_exceptions.md#class-unhandledcommandexception) | 当某个效应没有被任何 handler 捕获和处理时抛出的异常。        |
