# 异常类

## class DoubleResumeException

```cangjie
public class DoubleResumeException <: Exception {
    public init()
}
```

功能：当尝试对一个已经 resume（恢复）过的 `Resumption` 再次进行恢复时，将抛出此异常。Effect Handler 的语义要求每个 `Resumption` 只能被恢复一次，以防止程序状态不一致或不可预期的行为。

父类型：

- Exception

### init()

```cangjie
public init()
```

功能： 这是 `DoubleResumeException` 的构造函数。它会用默认信息 `"Resumption resumed multiple times"` 初始化该异常。

## class UnhandledCommandException

```cangjie
public class UnhandledCommandException <: Exception {
    public init()
}
```

功能：当某个 [Command](./effect_package_classes.md#class-commandres)（即某个效应）被 perform（触发）但没有任何 handler 对其进行处理时，会抛出此异常。这是一个运行时安全机制，提示开发者需要为该效应提供明确的处理逻辑。

父类型：

- Exception

### init()

```cangjie
public init()
```

功能： 这是 `UnhandledCommandException` 的构造函数。它使用默认信息 `"Unhandled command"` 来初始化异常对象。