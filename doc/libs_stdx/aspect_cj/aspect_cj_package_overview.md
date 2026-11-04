# stdx.aspect_cj

> **说明：**
>
> 当前处于开发阶段，尚不具备完整功能。

## 功能介绍

`stdx.aspect_cj` 包提供了仓颉中面向切面编程（Aspect Oriented Programming, AOP）的相关注解，配合 libstdx.collect_aspects 和 libstdx.weave_aspects 两个编译插件使用，可以对函数进行前后插桩以及替换实现。

## API 列表

### 类

| 类名                                                         | 功能                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [InsertAtEntry](./aspect_cj_package_api/aspect_cj_package_classes.md#class-insertatentry) | 一个注解类，提供一种切面能力。在注解所指定方法的入口，织入对被注解标注的函数的调用。 |
| [InsertAtExit](./aspect_cj_package_api/aspect_cj_package_classes.md#class-insertatexit) | 一个注解类，提供一种切面能力。在注解所指定方法的退出点，织入对被注解标注的函数的调用。 |
| [ReplaceFuncBody](./aspect_cj_package_api/aspect_cj_package_classes.md#class-replacefuncbody) | 一个注解类，提供一种切面能力。将注解所指定方法的方法体，替换为对被注解标注的函数的调用。 |

## 规格和使用

### 规格

**标注范围：**

- 注解暂不支持标注在泛型函数上，也不支持织入泛型函数；
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

**全局变量定义约束：**

- 定义了切面的包中，只允许定义基本类型（整型、浮点、Rune、Bool）字面值的全局变量，否则编译报错；若需要使用超规格的全局变量，需要将其定义在另外的包再导入使用，以避免在编译后可能产生的循环依赖；

**形参约束：**

- 被标注 @InsertAtEntry/@InsertAtExit 的函数，其返回类型只能是 Unit；
- 被标注 @ReplaceFuncBody 的函数，其返回类型应和被织入的函数的返回类型相同；
- 被标注 @InsertAtEntry/@InsertAtExit/@ReplaceFuncBody 的函数如果没有形参，那么其织入后总是被无参调用；
- 被标注 @InsertAtEntry/@InsertAtExit/@ReplaceFuncBody 的函数如果有形参，收集阶段先按切面形态去掉 receiver，再比较其余形参和被织入函数的源码形参：
    - 切面本身是被织入类型的实例成员时，receiver 就是该切面的隐式 `this`，源码形参里不再声明。收集阶段去掉这个隐式 `this` 之后，其余形参和被织入函数的源码形参相同。这种切面只能织入同一类型的实例成员；
    - 切面是全局函数或静态成员，并且被织入的函数是实例成员时，源码第一个形参显式写成该实例类型，例如 `self: T`。校验的是类型，必须等于注解中的 `packageName.className`；形参名不参与校验。去掉这个形参之后，其余形参和被织入函数的源码形参相同；
    - 被织入的函数是全局函数或静态成员时，切面不能是实例成员，形参列表直接和被织入函数的源码形参相同。
- 被标注 @ReplaceFuncBody 的函数在上面的形参之后，最后再增加一个形参，表示被织入函数的原始实现。该形参是函数类型，只包含被织入函数的源码形参和返回类型，receiver 不在其中。切面的返回类型必须与被织入函数以及该形参的返回类型相同。被织入 `func foo(x: Int64): Int64` 时：
    - 成员切面写作 `func aspect(x: Int64, original: (Int64) -> Int64): Int64`；
    - 全局或静态切面写作 `func aspect(self: T, x: Int64, original: (Int64) -> Int64): Int64`。

### 使用

要实现 AOP 的完整功能，除了使用上述的注解类来定义切面，还需要两个编译插件：

- libstdx.collect_aspects.so(.dll/.dylib)
- libstdx.weave_aspects.so(.dll/.dylib)

这两个编译插件以动态库的形式在 stdx.aspect_cj 中提供，不同平台提供不同版本。

应先使用 libstdx.collect_aspects，在编译时收集所有切面、连接点信息；再使用 libstdx.weave_aspects 进行二次编译，把之前收集的切面织入到连接点。
