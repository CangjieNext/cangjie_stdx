# 类

## class Command\<Res>

```cangjie
public abstract class Command<Res> {
    public open func defaultImpl(): Res
}
```

功能：该抽象类表示一种可以被触发和处理的**效应（effect）**。

### func defaultImpl()

```cangjie
public open func defaultImpl(): Res
```

功能：这是该效应的默认处理。当某个效应没有被任何 handler 明确处理时，此方法会抛出 [UnhandledCommandException](./effect_package_exceptions.md#class-unhandledcommandexception) 异常。你可以在具体的 `Command` 子类中重写此方法，为该效应提供默认的逻辑实现。

返回值：

- Res - 效应执行后的结果（如果你提供了默认实现的话）。

异常：

- [UnhandledCommandException](./effect_package_exceptions.md#class-unhandledcommandexception) - 该异常在此函数未被重写时抛出。

示例：
以下程序连续使用了多个 effect handler 操作，以展示：每调用一次 `deeper` 函数，所影响（增加）的调用层数。
`GetDepth` 的默认 handler 由 `GetDepth.defaultImpl` 提供，定义了在没有显式 handler 的情况下，调用层数为 0。
而 `deeper` 函数使用的每个 handler 程序都会重新执行 `GetDepth` 函数，并将计算的调用层数增加 1，即比该调用 `deeper` 之前更深一层。

<!-- verify -->
```cangjie
import stdx.effect.*

public class GetDepth <: Command<Int64> {
    public func defaultImpl(): Int64 {
        0
    }
}

func deeper<T>(f: () -> T): Unit {
    try {
        f()
    } handle(e: GetDepth) {
        resume with ((perform e) + 1)
    }
}

main() {
    println("Depth: ${perform GetDepth()}")
    deeper {
        println("Depth: ${perform GetDepth()}")
        deeper {
            println("Depth: ${perform GetDepth()}")
        }
        println("Depth: ${perform GetDepth()}")
    }
    println("Depth: ${perform GetDepth()}")
}
```

运行结果如下：

```text
Depth: 0
Depth: 1
Depth: 2
Depth: 1
Depth: 0
```

这段代码里首先对 `defaultImpl` 进行了重载，其始终返回一个值，便意味着该程序永远不会抛出 `UnhandledCommandException` 异常。
这个程序的行为与将 `main` 函数的主体包裹在 handler 程序 `try {... } handle(_: GetDepth) { resume with 0 }` 中的效果等价。
