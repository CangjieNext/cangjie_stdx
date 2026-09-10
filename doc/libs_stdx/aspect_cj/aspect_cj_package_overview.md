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
- 被标注 @InsertAtEntry/@InsertAtExit/@ReplaceFuncBody 的函数如果没有形参，那么其织入后总是被无参调用 ；
- 被标注 @InsertAtEntry/@InsertAtExit/@ReplaceFuncBody 的函数如果有形参，其形参列表应和被织入函数的源码形参列表相同，此外：
    - 特别地，如果被织入的函数是实例成员函数，那么需要将 this 参数显式地写在形参中；
    - 对于被标注 @ReplaceFuncBody 的函数，需要额外添加一个形参，形参的类型和被织入的函数相同，该形参表示被织入函数原始版本的闭包。

**通配符配置：**

- 注解的 `packageName`、`className`、`methodName` 参数支持使用通配符 `*` 来匹配任意值；
- 当 `packageName` 为 `*` 时，匹配任意包名；
- 当 `className` 为 `*` 时，匹配任意类名（仅对成员函数有效）；
- 当 `methodName` 为 `*` 时，匹配任意方法名；
- 通配符可以组合使用，例如 `packageName: "*"` 和 `methodName: "*"` 可以匹配所有包中的所有同名方法。

**切点函数参数作为实参：**

- 被标注 @InsertAtEntry/@InsertAtExit/@ReplaceFuncBody 的函数可以声明比被织入函数更少的形参；
- 编译器会自动根据类型匹配将切点函数的参数传递给切面函数；
- 这使得切面函数可以只声明它需要的参数，而不必声明所有参数。

### 使用

要实现 AOP 的完整功能，除了使用上述的注解类来定义切面，还需要两个编译插件：

- libstdx.collect_aspects.so(.dll/.dylib)
- libstdx.weave_aspects.so(.dll/.dylib)

这两个编译插件以动态库的形式在 stdx.aspect_cj 中提供，不同平台提供不同版本。

应先使用 libstdx.collect_aspects，在编译时收集所有切面、连接点信息；再使用 libstdx.weave_aspects 进行二次编译，把之前收集的切面织入到连接点。