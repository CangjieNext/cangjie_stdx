# 类

## class InsertAtEntry

```cangjie
public class InsertAtEntry {}
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
public class InsertAtExit {}
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
public class ReplaceFuncBody {}
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
public class PointcutRule {}
```

功能：标注当前切面包内的顶层普通类，定义一个可复用的原子切点。各条件同时满足时才匹配目标。名称和类型模式遵循[切点通配符规则](../aspect_cj_package_overview.md#规格和使用)。

### const init(String, String, String, String, String, Bool, String)

```cangjie
public const init(packageName!: String, className!: String, methodName!: String,
    funcTypeStr!: String, targetKind!: String, recursive!: Bool, annotationName!: String)
```

功能：创建 [PointcutRule](#class-pointcutrule) 对象。所有参数均为必填命名参数。

参数：

- packageName!: String - 目标函数所属包名模式。支持名称段内 `*` 和完整包名段 `**`。
- className!: String - 目标成员所属类型名模式，支持名称段内 `*`；全局函数的类型名为空字符串。当 `targetKind` 为 `global` 时必须为空字符串。
- methodName!: String - 目标函数名模式，支持名称段内 `*`。
- funcTypeStr!: String - 不含空格及隐式 `this` 的目标函数类型模式。独立 `*` 匹配一个类型，参数列表中独立 `**` 匹配零个或多个参数，例如 `(**)->*`。
- targetKind!: String - 目标种类。仅接受 `any`、`global`、`static`、`instance`，分别表示不限制种类、全局函数、静态成员函数、实例成员函数。
- recursive!: Bool - 是否将成员所属类型名的匹配扩展到其祖先类型；不表示业务注解继承。为 `true` 时，`className` 不得为空，且 `targetKind` 不得为 `global`。
- annotationName!: String - 目标函数源声明上直接标注的业务注解类的完整名称，例如 `example.annotations.Trace`。空字符串表示不限制业务注解；非空时按解析后的声明身份精确匹配，不按源码别名或同短名猜测，不支持通配符。

## class PointcutExpression

```cangjie
public class PointcutExpression {}
```

功能：标注当前切面包内的顶层普通类，以布尔表达式组合可复用的切点规则。

### const init(String, String)

```cangjie
public const init(packageScope!: String, expression!: String)
```

功能：创建 [PointcutExpression](#class-pointcutexpression) 对象。所有参数均为必填命名参数。

参数：

- packageScope!: String - 本层规则允许匹配的目标包名模式，支持名称段内 `*` 和完整包名段 `**`。每层规则保留自身范围，外层范围不会覆盖被引用规则的范围；范围外的目标不会因 `NOT` 而命中。
- expression!: String - 引用当前切面包内规则类源码名的表达式，例如 `ReadRule AND NOT InternalRule`。支持括号及大写运算符 `NOT`、`AND`、`OR`，优先级依次递减。未知引用、循环引用或非法表达式在收集阶段报错。

## class InsertAtEntryByRule

```cangjie
public class InsertAtEntryByRule {}
```

功能：标注 public 全局或静态切面函数，在规则匹配目标的入口织入调用。切面返回 `Unit`，显式参数只能为零个或单个 `Array<Any>`。数组按目标入口处的显式实参顺序保存浅快照，不包含隐式 `this`；修改数组元素不会回写目标形参。

### const init(String)

```cangjie
public const init(rule!: String)
```

功能：创建 [InsertAtEntryByRule](#class-insertatentrybyrule) 对象。

参数：

- rule!: String - 必填命名参数，指定当前切面包内规则类的完整规范 ID，即声明包全名加类名，例如 `example.aspect.TraceRule`。可引用 [PointcutRule](#class-pointcutrule) 或 [PointcutExpression](#class-pointcutexpression) 标注的规则类；不是表达式或通配模式，引用不存在时收集失败。

## class InsertAtExitByRule

```cangjie
public class InsertAtExitByRule {}
```

功能：标注 public 全局或静态切面函数，在规则匹配目标的正常返回点织入调用；目标未捕获异常时不执行该出口切面。切面签名和实参快照规则同 [InsertAtEntryByRule](#class-insertatentrybyrule)，快照仍取自目标入口，而非返回值。

### const init(String)

```cangjie
public const init(rule!: String)
```

功能：创建 [InsertAtExitByRule](#class-insertatexitbyrule) 对象。

参数：

- rule!: String - 必填命名参数，指定当前切面包内规则类的完整规范 ID，例如 `example.aspect.TraceRule`。可引用 [PointcutRule](#class-pointcutrule) 或 [PointcutExpression](#class-pointcutexpression) 标注的规则类；不是表达式或通配模式，引用不存在时收集失败。
