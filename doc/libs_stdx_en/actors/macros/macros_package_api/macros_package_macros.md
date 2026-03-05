# Macros

## @Actor macro

```cangjie
public macro Actor(input: Tokens): Tokens

public macro Actor(options: Tokens, input: Tokens): Tokens
```

Function: Transform a class into an actor.

> **Description:**
>
> The usage of the `@Actor` macro has the following limitations:
>
> - It can only be applied to classes.
> - The class being annotated cannot be `abstract`, `open`, or `sealed`.

Violating these limitations will result in a compilation error during macro expansion.

Options: The `@Actor` macro accepts a list of options in the form `opt1: value1, opt2: value2`. For example:

```cangjie
@Actor[option1: value1, option2: value2]
```

Currently, the only available option is `enableReceiverPriority: value` — this specifies whether to enable priority between receiver functions. The value provided must be a boolean literal, either `true` or `false`. If this option is not specified, it defaults to `false`.

Each option can only appear once; otherwise, an error will be thrown during macro expansion.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::actors.*
import cangjie_stdx::actors.macros.*

@Actor
public class Counter <: ToString {
    private var cnt: Int64 = 0

    public func toString(): String {
        "This is a counter."
    }
}

main() {
    let counter = Counter()
    println(counter)
}
```

Execution result：

```text
This is a counter.
```

## @Receiver macro

```cangjie
public macro Receiver(input: Tokens): Tokens

public macro Receiver(options: Tokens, input: Tokens): Tokens
```

Function: Transform a member function into a receiver function

> **Description:**
>
> The usage of the `@Receiver` macro has the following limitations:
>
> - It can only be used inside an `@Actor` macro;
> - The annotated method must not be `static`;
> - The annotated method must have an explicitly declared return type;
> - The annotated method cannot override an interface method, i.e., it cannot be marked as `override`;
> - If the annotated method does not explicitly use the `override` modifier but actually overrides an interface method, a compilation error will occur after macro expansion;
> - The annotated method cannot be `open`;
> - When used inside an `@Actor` macro with `enableReceiverPriority` set to `true`, the annotated method cannot have a parameter named `priority`.

Violating these restrictions will result in a compilation error during macro expansion.

Options: The `Receiver` macro accepts a list of options in the form of `opt1: value1, opt2: value2`. For example,

```cangjie
@Receiver[option1: value1, option2: value2]
```

The currently available option is only `priority: value` - specifies the default priority level for the receiving function. The provided value must be an integer literal between 1 and 10; otherwise, an error will be thrown during macro expansion. This option is only available when the outer [@Actor](./macros_package_macros.md#actor-macro) macro has the `enableReceiverPriority: true` option.

Each option can only appear once, otherwise, an error will be thrown during macro expansion.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::actors.*
import cangjie_stdx::actors.macros.*

@Actor
public class Counter <: ToString {
    private var cnt: Int64 = 0

    @Receiver
    public func inc(): Unit {
        cnt++
    }

    @Receiver
    public func getCnt(): Int64 {
        cnt
    }

    public func toString(): String {
        "This is a counter: cnt = ${getCnt().get()}."
    }
}

main() {
    let counter = Counter()
    counter.inc()
    counter.inc()
    println(counter)
}
```

Execution result:

```text
This is a counter: cnt = 2.
```