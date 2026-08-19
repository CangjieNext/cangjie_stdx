# Exceptions

## class DoubleResumeException

```cangjie
public class DoubleResumeException <: Exception {
    public init()
}
```

**Description:** This exception is thrown when attempting to `resume` a `Resumption` that has already been resumed. The semantics of Effect Handlers require that each `Resumption` can be resumed at most once, in order to prevent inconsistent program state or unpredictable behavior.

**Parent Type:**

- Exception

### init()

```cangjie
public init()
```

**Description:** Constructor for `DoubleResumeException`. Initializes the exception with the default message `"Resumption resumed multiple times"`.

## class UnhandledCommandException

```cangjie
public class UnhandledCommandException <: Exception {
    public init()
}
```

**Description:** This exception is thrown when a [Command](./effect_package_classes.md#class-commandres) (i.e., an effect) is performed but not handled by any handler. It serves as a runtime safety mechanism, indicating that the developer must provide explicit handling logic for the effect.

**Parent Type:**

- Exception

### init()

```cangjie
public init()
```

**Description:** Constructor for `UnhandledCommandException`. Initializes the exception with the default message `"Unhandled command"`.
