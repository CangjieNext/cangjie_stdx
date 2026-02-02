# 类

## class Command\<Res>

```cangjie
public abstract class Command<Res> {
    public open func defaultImpl(): Res
}
```

功能：该抽象类表示一种可以被触发和处理的**效应（effect）**。

参数：

- Res：当该效应被执行后，预期返回的结果类型。

### func defaultImpl()

```cangjie
public open func defaultImpl(): Res
```

功能：这是该效应的默认处理。当某个效应没有被任何 handler 明确处理时，此方法会抛出 [UnhandledCommandException](./effect_package_exceptions.md#class-unhandledcommandexception) 异常。你可以在具体的 `Command` 子类中重写此方法，为该效应提供默认的逻辑实现。

返回值：

- Res：效应执行后的结果（如果你提供了默认实现的话）。

异常：

- [UnhandledCommandException](./effect_package_exceptions.md#class-unhandledcommandexception) - 该异常在此函数未被重写时抛出。
