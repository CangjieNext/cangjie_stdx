# 类

## class InsertAtEntry

```cangjie
public class InsertAtEntry {
    public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool, funcTypeStr!: String)
}
```

功能：在注解所指定方法的入口，织入对被注解标注的函数的调用。注解所指定的方法和被注解标注的函数，需满足[规格限制](../aspect_cj_package_overview.md#规格和使用)。

示例：

参考[InsertAtEntry 示例教程](../aspect_cj_samples/aspect_cj_sample.md#insertatentry-入口插桩示例)了解具体调用流程。

### const init(String, String, String, Bool, Bool, String)

```cangjie
public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool, funcTypeStr!: String)
```

功能：创建 [InsertAtEntry](aspect_cj_package_classes.md#class-insertatentry) 对象。

示例：

参考[InsertAtEntry 示例教程](../aspect_cj_samples/aspect_cj_sample.md#insertatentry-入口插桩示例)了解具体调用流程。

参数：

- packageName!: String - 被织入的函数的所属包名，如 "default", "std.core"。支持名称段内 `*` 和完整包名段 `**` 通配符；
- className!: String - 如果被织入的函数是成员函数，则为函数所属类名；如果被织入的函数是全局函数，则为空。支持名称段内 `*` 通配符；
- methodName!: String - 被织入的函数名称，如 "foo"。支持名称段内 `*` 通配符；
- isStatic!: Bool - 被织入的函数是否为静态成员函数；
- recursive!: Bool - 当被织入的函数是成员函数时，表示是否对子类里的函数 override 版本也做织入；否则该字段应填 false。

- funcTypeStr!: String - 被织入的函数的类型字符串，不包括空格。对于自定义类型，类型定义所在的包名不可省略，且和类型名之间使用 `.` 分隔。不需要包括隐式的 this 形参的类型。如 "(Int64,std.core.Object)->Unit"。独立 `*` 匹配一个类型，参数列表中独立 `**` 匹配零个或多个参数，限定类型名支持名称段内 `*` 和完整段 `**`。通配函数类型必须与切面函数的单个 `Array<Any>` 显式形参组合使用；

## class InsertAtExit

```cangjie
public class InsertAtExit {
    public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool, funcTypeStr!: String)
}
```

功能：在注解所指定方法的退出点，织入对被注解标注的函数的调用。注解所指定的方法和被注解标注的函数，需满足[规格限制](../aspect_cj_package_overview.md#规格和使用)。

示例：

参考[InsertAtExit 示例教程](../aspect_cj_samples/aspect_cj_sample.md#insertatexit-退出插桩示例)了解具体调用流程。

### const init(String, String, String, Bool, Bool, String)

```cangjie
public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool, funcTypeStr!: String)
```

功能：创建 [InsertAtExit](aspect_cj_package_classes.md#class-insertatexit) 对象。

示例：

参考[InsertAtExit 示例教程](../aspect_cj_samples/aspect_cj_sample.md#insertatexit-退出插桩示例)了解具体调用流程。

参数：

- packageName!: String - 被织入的函数的所属包名，如 "default", "std.core"。支持名称段内 `*` 和完整包名段 `**` 通配符；
- className!: String - 如果被织入的函数是成员函数，则为函数所属类名；如果被织入的函数是全局函数，则为空。支持名称段内 `*` 通配符；
- methodName!: String - 被织入的函数名称，如 "foo"。支持名称段内 `*` 通配符；
- isStatic!: Bool - 被织入的函数是否为静态成员函数；
- recursive!: Bool - 当被织入的函数是成员函数时，表示是否对子类里的函数 override 版本也做织入；否则该字段应填 false。
- funcTypeStr!: String - 被织入的函数的类型字符串，不包括空格。对于自定义类型，类型定义所在的包名不可省略，且和类型名之间使用 `.` 分隔。不需要包括隐式的 this 形参的类型。如 "(Int64,std.core.Object)->Unit"。独立 `*` 匹配一个类型，参数列表中独立 `**` 匹配零个或多个参数，限定类型名支持名称段内 `*` 和完整段 `**`。通配函数类型必须与切面函数的单个 `Array<Any>` 显式形参组合使用；

## class ReplaceFuncBody

```cangjie
public class ReplaceFuncBody {
    public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool)
}
```

功能：将注解所指定方法的方法体，替换为对被注解标注的函数的调用。注解所指定的方法和被注解标注的函数，需满足[规格限制](../aspect_cj_package_overview.md#规格和使用)。

示例：

参考[ReplaceFuncBody 示例教程](../aspect_cj_samples/aspect_cj_sample.md#replacefuncbody-替换函数体示例)了解具体调用流程。

### const init(String, String, String, Bool, Bool)

```cangjie
public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool)
```

功能：创建 [ReplaceFuncBody](aspect_cj_package_classes.md#class-replacefuncbody) 对象。

示例：

参考[ReplaceFuncBody 示例教程](../aspect_cj_samples/aspect_cj_sample.md#replacefuncbody-替换函数体示例)了解具体调用流程。

参数：

- packageName!: String - 被织入的函数的所属包名，如 "default", "std.core"；
- className!: String - 如果被织入的函数是成员函数，则为函数所属类名；如果被织入的函数是全局函数，则为空；
- methodName!: String - 被织入的函数名称，如 "foo"；
- isStatic!: Bool - 被织入的函数是否为静态成员函数；
- recursive!: Bool - 当被织入的函数是成员函数时，表示是否对子类里的函数 override 版本也做织入；否则该字段应填 false。

## class PointcutRule

```cangjie
public class PointcutRule {
    public const init(packageName!: String, className!: String, methodName!: String,
        funcTypeStr!: String, targetKind!: String, recursive!: Bool, annotationName!: String)
}
```

功能：标注当前切面包内的顶层普通类，定义一个可复用的原子切点。`packageName`、`className`、`methodName`、`funcTypeStr` 沿用已有通配符规则；`targetKind` 可为 `any`、`global`、`static` 或 `instance`。`annotationName` 为空时不限制业务注解，非空时按解析后注解类完整名称精确匹配，不采用别名文字或同短名推测。`recursive` 仅扩展成员类型的祖先匹配，不代表注解继承。参数均为必填命名参数。详见[规则模式设计](../aspect_cj_rule_design.md)。

## class PointcutExpression

```cangjie
public class PointcutExpression {
    public const init(packageScope!: String, expression!: String)
}
```

功能：标注规则类，以 `AND`、`OR`、`NOT` 和括号组合当前切面包的规则类名。`packageScope` 限制本层规则可评估的目标包；优先级为 `NOT` 高于 `AND` 高于 `OR`。两个参数均为必填命名参数。

## class InsertAtEntryByRule

```cangjie
public class InsertAtEntryByRule {
    public const init(rule!: String)
}
```

功能：标注 public 全局或静态切面函数，在规则匹配目标的入口织入调用。`rule` 为规则类的完整规范 ID。切面返回 `Unit`，显式参数只能为零个或单个 `Array<Any>`。数组不包含目标的隐式 `this`，也不回写目标形参。

## class InsertAtExitByRule

```cangjie
public class InsertAtExitByRule {
    public const init(rule!: String)
}
```

功能：参数限制和规则引用方式同 `InsertAtEntryByRule`，但仅在目标正常返回点织入；目标未捕获异常时不执行该出口切面。
