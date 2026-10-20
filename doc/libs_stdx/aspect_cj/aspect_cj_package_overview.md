# stdx.aspect_cj

> **说明：**
>
> 当前处于开发阶段，尚不具备完整功能。

## 功能介绍

`stdx.aspect_cj` 包提供了仓颉中面向切面编程（Aspect Oriented Programming, AOP）的相关注解。旧式注解配合 libstdx.collect_aspects 和 libstdx.weave_aspects 编译插件使用，可以对函数进行前后插桩以及替换实现；新式规则模式通过可复用切点及布尔表达式选择入口或正常出口的织入目标，使用独立的规则插件和构建驱动。

## API 列表

### 类

| 类名                                                         | 功能                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [InsertAtEntry](./aspect_cj_package_api/aspect_cj_package_classes.md#class-insertatentry) | 一个注解类，提供一种切面能力。在注解所指定方法的入口，织入对被注解标注的函数的调用。 |
| [InsertAtExit](./aspect_cj_package_api/aspect_cj_package_classes.md#class-insertatexit) | 一个注解类，提供一种切面能力。在注解所指定方法的退出点，织入对被注解标注的函数的调用。 |
| [ReplaceFuncBody](./aspect_cj_package_api/aspect_cj_package_classes.md#class-replacefuncbody) | 一个注解类，提供一种切面能力。将注解所指定方法的方法体，替换为对被注解标注的函数的调用。 |
| [PointcutRule](./aspect_cj_package_api/aspect_cj_package_classes.md#class-pointcutrule) | 定义可复用的原子切点；可按业务注解的解析后全名过滤目标。 |
| [PointcutExpression](./aspect_cj_package_api/aspect_cj_package_classes.md#class-pointcutexpression) | 以 AND、OR、NOT 组合当前切面包中的切点规则。 |
| [InsertAtEntryByRule](./aspect_cj_package_api/aspect_cj_package_classes.md#class-insertatentrybyrule) / [InsertAtExitByRule](./aspect_cj_package_api/aspect_cj_package_classes.md#class-insertatexitbyrule) | 用规则选择入口或正常出口的织入目标。 |

## 规格和使用

### 规格

#### 旧式注解模式

本节适用于 `InsertAtEntry`、`InsertAtExit` 和 `ReplaceFuncBody`，不适用于下文的新式规则注解。

**标注范围：**

- 切面函数不能是泛型函数，也不能属于泛型类型；
- 注解只允许标注在 public 函数上；
- 注解可以标注在全局函数上，支持：
    - 织入另一个全局函数，
    - 织入另一个实例成员函数，
    - 织入另一个静态成员函数；
- 注解可以标注在静态成员函数上，支持：
    - 织入另一个全局函数，
    - 织入另一个实例成员函数，
    - 织入另一个静态成员函数；
- 注解可以标注在实例成员函数上，支持：
    - 织入同类型的其它实例成员函数。

**形参约束：**

- 被标注 @InsertAtEntry/@InsertAtExit 的函数，其返回类型只能是 Unit；
- 被标注 @ReplaceFuncBody 的函数，其返回类型应和被织入的函数的返回类型相同；
- 被标注 @InsertAtEntry/@InsertAtExit 的全局或静态切面函数如果没有显式形参，织入时不传入目标函数的显式实参；实例成员切面采用下述类型化形参或 `Array<Any>` 模式，并使用隐式 `this` 接收者；
- 被标注 @InsertAtEntry/@InsertAtExit 的函数也可以通过类型化形参接收目标函数实参，形参列表应和目标函数的源码形参列表相同。对于实例目标，全局或静态切面还须在首位显式声明目标实例参数；同类型的实例成员切面使用隐式 `this`，不重复声明该参数；
- 被标注 @ReplaceFuncBody 的函数必须在最后一个显式形参中接收原始函数的闭包，不能省略。该闭包类型只包含目标函数的源码显式形参和返回类型，不包含实例接收者；织入时自动绑定目标实例。对于全局或静态目标，切面可以仅声明该闭包形参；若还需接收目标函数实参，则闭包之前的形参必须与目标函数参数相匹配。实例目标的接收者按上述 `this` 规则处理，其余形参必须逐一匹配目标的源码形参；
    - 对于类型 `T` 的 `func foo(x: Int64): Int64`，成员切面写作 `func aspect(x: Int64, original: (Int64) -> Int64): Int64`；
    - 全局或静态切面写作 `func aspect(self: T, x: Int64, original: (Int64) -> Int64): Int64`。`self` 的类型必须与配置的目标类型一致，形参名称不参与匹配；调用原始实现时写作 `original(x)`，不再传入 `self`；
- 对于 @InsertAtEntry/@InsertAtExit，切面函数也可以只声明一个 `Array<Any>` 显式形参。此时数组按源码显式形参顺序保存目标函数入口处的实参浅快照，不包含隐式 `this`，修改数组元素不会回写目标函数形参；
- `Array<Any>` 实参模式不适用于 @ReplaceFuncBody。

#### 新式规则模式

- `PointcutRule` 和 `PointcutExpression` 标注当前切面包内的顶层、非泛型普通类，用于声明切点规则，不标注切面函数；
- `InsertAtEntryByRule` 和 `InsertAtExitByRule` 只能标注 public 全局或静态切面函数，不支持实例成员切面。切面不能是泛型函数，也不能属于泛型类型，返回类型必须为 `Unit`；
- 规则切面只能声明零个显式形参或一个 `Array<Any>` 形参，不支持按目标参数逐个声明类型化形参。无参切面也可以引用包含通配符的 `PointcutRule`，不要求改为 `Array<Any>`；
- `Array<Any>` 保存目标函数入口处显式实参的浅快照，不包含隐式 `this`，修改数组元素不会回写目标形参；出口切面使用的仍是入口快照，不是返回值；
- 规则目标可以是具有可执行函数体的普通全局、静态或实例成员函数，包括泛型函数或泛型类型的具体实例化函数，但不包含泛型模板本身。`main`、构造/析构函数、属性访问器、注解工厂、lambda、编译器辅助函数及切面函数体不作为规则目标；
- `PointcutExpression` 支持括号以及 `NOT`、`AND`、`OR` 运算符，三个运算符的优先级依次递减。规则引用仅限当前切面包，各层规则保留自身包范围，范围外的目标不会因 `NOT` 而命中。

#### 两种模式的公共约束

**全局变量定义约束：**

- 定义了切面的包中，只允许定义基本类型（整型、浮点、Rune、Bool）字面值的全局变量，否则编译报错；若需要使用超规格的全局变量，需要将其定义在另外的包再导入使用，以避免在编译后可能产生的循环依赖。

**切点通配符：**

- `packageName`、`className` 和 `methodName` 中的 `*` 匹配同一名称段内零个或多个字符；
- `packageName` 中的完整 `**` 段匹配零个或多个包名段；
- `funcTypeStr` 中独立的 `*` 匹配一个类型，参数列表中独立的 `**` 匹配零个或多个参数，限定类型名中的 `*` 和 `**` 与上述规则相同；
- 参数列表中最多使用一个独立的 `**`。旧式 @InsertAtEntry/@InsertAtExit 的 `funcTypeStr` 包含通配符时，必须使用 `Array<Any>` 实参模式；此限制不适用于引用 `PointcutRule` 的无参规则切面；
- 旧式实例成员切面函数的 `this` 类型静态确定，因此其 `packageName` 和 `className` 必须精确配置；新式规则模式不支持实例成员切面。
- 配置字段使用直接书写的名称或类型模式，不支持反斜杠转义（包括字符串字面量中的 `\n`、`\r`、`\u{...}`）；控制字符或转义文本会在收集阶段报错，不会生成无法匹配的规则。

### 使用

使用旧式注解定义切面时，需要两个编译插件：

- libstdx.collect_aspects.so(.dll/.dylib)
- libstdx.weave_aspects.so(.dll/.dylib)

这两个编译插件以动态库的形式在 stdx.aspect_cj 中提供，不同平台提供不同版本。

应先使用 libstdx.collect_aspects，在编译时收集所有切面、连接点信息；再使用 libstdx.weave_aspects 进行二次编译，把之前收集的切面织入到连接点。

新式规则模式还需要 `libstdx.collect_rules`、`libstdx.weave_rules` 与匹配版本的编译器。当前支持 Linux/cjnative，由安装后的 `aspect-cj-driver` 协调来源收集、来源选择、预检、织入和最终发布。规则参数见[类文档](./aspect_cj_package_api/aspect_cj_package_classes.md#class-pointcutrule)，构建配置及命令见[驱动说明](../../../build/aspect_cj_driver/README.md)。旧的两个插件不自动升级到规则模式。
