# 宏

## @Actor 宏

```cangjie
public macro Actor(input: Tokens): Tokens

public macro Actor(options: Tokens, input: Tokens): Tokens
```

功能：把一个 class 类变成一个 actor。

> **说明：**
>
> @Actor 宏的使用有以下限制：
>
> - 它只能用于类；
> - 被标注的类不能是 abstract/open/sealed。

违反这些限制会导致宏展开时出现编译错误。

选项：Actor 宏接受以 `opt1: value1, opt2: value2` 形式的选项列表。例如，

```cangjie
@Actor[option1: value1, option2: value2]
```

目前可用的选项只有 enableReceiverPriority: value - 指定是否启用接收函数之间的优先级。提供的值必须是 boolean 的字面量，即 true 或 false。如果没有指定此选项，默认为 false。

所有选项只能出现一次，否则在宏展开期间将抛出错误。

示例：

<!-- verify -->
```cangjie
import stdx.actors.*
import stdx.actors.macros.*

@Actor
public class Counter <: ToString {
    private var cnt: Int64 = 0

    public func toString(): String {
        "This is a counter."
    }
}

main() {
    let counter: Counter = Counter()
    println(counter)
}
```

运行结果：

```text
This is a counter.
```

## @Receiver 宏

```cangjie
public macro Receiver(input: Tokens): Tokens

public macro Receiver(options: Tokens, input: Tokens): Tokens
```

功能：把一个成员函数变成接收函数。

> **说明：**
>
> @Receiver 宏的使用有以下限制：
>
> - 只能在 [@Actor](./macros_package_macros.md#actor-宏) 宏内部使用；
> - 被注解的方法必须是非 `static` 的；
> - 被注解的方法必须具有明确声明的返回类型；
> - 被注解的方法不能覆盖接口方法，即不能被 override 修饰；
> - 如果被注解方法没有显式的 `override` 修饰符但实际上覆盖了接口方法，则会在宏展开后会导致编译错误；
> - 被注解的方法不能是 `open` 的；
> - 当在 [@Actor](./macros_package_macros.md#actor-宏) 宏内部使用且 `enableReceiverPriority` 设置为 `true` 时，被注解的方法不能具有名为 `priority` 的参数。

违反这些限制会导致宏展开时出现编译错误。

选项：Receiver 宏接受以 `opt1: value1, opt2: value2` 形式的选项列表。例如，

```cangjie
@Receiver[option1: value1, option2: value2]
```

目前可用的选项只有 priority: value - 指定接收函数的默认优先级级别。提供的值必须是介于 1 到 10 之间的整数字面量；否则，在宏展开期间将抛出错误。此选项仅在外层 [@Actor](./macros_package_macros.md#actor-宏) 宏具有 `enableReceiverPriority: true` 选项时才可用。

所有选项只能出现一次，否则在宏展开期间将抛出错误。

示例：

<!-- verify -->
```cangjie
import stdx.actors.*
import stdx.actors.macros.*

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
    let counter: Counter = Counter()
    counter.inc()
    counter.inc()
    println(counter)
}
```

运行结果：

```text
This is a counter: cnt = 2.
```
