# stdx.effect

## Overview

Effect Handlers are a powerful form of non-local control operation. They were first introduced in functional programming languages to represent side effects, but have since proven equally useful in object-oriented and procedural languages.

They are similar to exception handling: exceptions can be **thrown** (`throw`) and **caught** (`catch`), while effects are **performed** (`perform`) and **handled** (`handle`). The key difference is that when an exception is caught, the computation that raised it has already been aborted and cannot be resumed. In contrast, when handling an effect, Effect Handlers can choose to resume the computation at the point where the effect was performed, returning control to the `perform` expression.

### Core Structure

Effect Handlers extend the traditional `try-catch` structure by adding a `handle` clause for processing effects. A `try` expression can contain `catch` blocks for handling exceptions as well as one or more `handle` blocks for handling effects triggered via `perform`. The core components of Effect Handlers are as follows:

* **`Command<T>` Interface:**

    All effects must inherit from `Command<T>`, where `T` is the type returned when the effect is resumed. The `defaultImpl` method can be overridden to provide default behavior when the effect is not caught by any handler.

* **`perform` Expression:**

    `perform expr` triggers an effect, where `expr` must be an instance of `Command<T>`. If the effect is handled and resumed, the `perform` expression has type `T`.

* **`handle` Clause:**

    A `handle` clause defines the logic to process an effect when it is triggered. At runtime, the nearest matching `handle` clause is selected, and the handler code block is executed. Within a `handle` block, you must use a `resume` expression to continue execution.

    Syntax:

    ```cangjie
    try {
        ...  
    } handle (cmd: Command<T>) {
        // handler logic
        resume with value
    }
    ```

    Where:

    * `cmd` is bound to the triggered effect object
    * In `resume with value`, the type of `value` must match `T`

* **`resume` Expression:**

    `resume with value` resumes execution at the `perform` site and returns `value` as the result of the `perform` expression. `resume throwing exn` throws an exception back to the `perform` site.

### Basic Syntax

```cangjie
class MyEffect <: Command<String> {}

try {
    let result = perform MyEffect()
    println(result)
} handle (e: MyEffect) {
    resume with "Hello"
}
```

Execution flow:

1. Enter the `try` block and execute until `perform MyEffect()` triggers the effect
2. Match it with `handle (e: MyEffect)` and enter the handler
3. Execute `resume with "Hello"`
4. Control returns to the `perform` site, and the expression evaluates to `"Hello"`
5. Continue execution of `println`

### Type Rules

* The type of `perform expr` is the `T` from `Command<T>`
* The type captured by `handle` must be a subclass of `Command`
* In `resume with value`, the type of `value` must match `T`
* In `resume throwing exn`, `exn` must be an instance of `Exception` or `Error` (or their subclasses)

### Examples

#### Example 1: Basic Usage

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

Output:

```text
42
```

#### Example 2: Throwing an Exception

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

Output:

```text
Error from effect
```

#### Example 3: Default Implementation

```cangjie
import stdx.effect.Command

class Print <: Command<Unit> {
    Print (let msg: String) {}
    override func defaultImpl(): Unit {
        println(msg)
    }
}

main() {
    perform Print("No handler here") // Calls the default implementation
}
```

Output:

```text
No handler here
```

> **Note:**
> Effect Handlers are an experimental feature and require a Cangjie compiler with support for this mechanism.
> Compiling code that uses Effect Handlers requires the options `--experimental` and `--enable-eh`.
> Since this feature is experimental, tooling support is still in progress, as shown below:

| Tool          | Support Status                                             |
| ------------- | ------------------------------- |
| **Cjdb**      | Fully supported            |
| **LSP**       | Does not yet recognize keywords related to Effect Handlers |
| **Formatter** | Not yet supported                                          |
| **Coverage**  | Not yet supported                                          |
| **Cjlint**    | Not yet supported                                          |

## API Reference

### Classes

| Class Name                                                                       | Description                         |
| ----------------------- | ----------------------------------------------------------- |
| [Command\<Res>](./effect_package_api/effect_package_classes.md#class-commandres) | An abstract class representing an **effect** that is expected to return a result of type `Res`. This class provides a default handler method [defaultImpl](./effect_package_api/effect_package_classes.md#func-defaultimpl), which can be overridden. If an effect is not handled, this default method is called; its default implementation throws an [UnhandledCommandException](./effect_package_api/effect_package_exceptions.md#class-unhandledcommandexception). |

### Exceptions

| Exception Name                                                                                                 | Description                                                                                              |
| --------------------------- | ----------------------------------------------------------- |
| [DoubleResumeException](./effect_package_api/effect_package_exceptions.md#class-doubleresumeexception)         | Thrown when attempting to `resume` the same effect more than once. Each effect can only be resumed once. |
| [UnhandledCommandException](./effect_package_api/effect_package_exceptions.md#class-unhandledcommandexception) | Thrown when an effect is not caught and handled by any handler.                                          |
