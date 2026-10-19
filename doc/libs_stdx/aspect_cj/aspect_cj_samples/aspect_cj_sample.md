# AOP 开发示例

## InsertAtEntry 入口插桩示例

下面是使用 @InsertAtEntry 完成在指定函数入口插桩的示例代码：

<!-- compile -->

```cangjie
package AOP_demo1

import stdx.aspect_cj.*
import std.time.DateTime

@InsertAtEntry[packageName: "AOP_demo1", className: "", methodName: "printCurrentTime", isStatic: false,
    recursive: false, funcTypeStr: "()->Unit"]
public func printCurrentTimeImpl() {
    println("----- ${DateTime.now()} -----")
}

public func printCurrentTime() {
    println("hi")
    println("bye")
}

main() {
    printCurrentTime()
    0
}
```

linux 平台编译命令：

```shell
cjc aop_demo1.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.collect_aspects.so -o main # 第一次编译，收集切面
cjc aop_demo1.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.weave_aspects.so -o main # 第二次编译，织入切面
```

运行结果可能如下：

```text
----- 2025-06-03T00:00:18.994507-07:00 -----
hi
bye
```

## InsertAtExit 退出插桩示例

下面是使用 @InsertAtExit 完成在指定函数退出前插桩的示例代码：

<!-- compile -->

```cangjie
package AOP_demo2

import stdx.aspect_cj.*
import std.time.DateTime

@InsertAtExit[packageName: "AOP_demo2", className: "", methodName: "printCurrentTime", isStatic: false,
    recursive: false, funcTypeStr: "()->std.core.String"]
public func printCurrentTimeImpl() {
    println("----- ${DateTime.now()} -----")
}

public func printCurrentTime() {
    println("hi")
    println("bye")
    "done"
}

main() {
    println(printCurrentTime())
    0
}
```

linux 平台编译命令：

```shell
cjc aop_demo2.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.collect_aspects.so -o main # 第一次编译，收集切面
cjc aop_demo2.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.weave_aspects.so -o main # 第二次编译，织入切面
```

运行结果可能如下：

```text
hi
bye
----- 2025-06-03T00:04:59.996469-07:00 -----
done
```

## 通配切点和实参快照示例

下面的切面使用通配配置匹配两个不同签名的函数，并通过 `Array<Any>` 接收目标函数的全部显式实参：

<!-- compile -->

```cangjie
package AOP_demo4

import stdx.aspect_cj.*

// AOP_* 匹配本示例包，handle* 匹配两个业务函数名。
// 全局函数的类型名为空，className 中的 * 也能匹配空字符串。
// (**)->* 表示任意参数列表和返回类型，切面用 Array<Any> 接收实参。
@InsertAtEntry[packageName: "AOP_*", className: "*", methodName: "handle*", isStatic: false,
    recursive: false, funcTypeStr: "(**)->*"]
public func traceArguments(args: Array<Any>) {
    // 实参按目标函数参数顺序排列：handleOne 为 1 项，handleTwo 为 2 项。
    println("arguments=${args.size}")
}

public func handleOne(id: Int64): Unit {
    println("handleOne")
}

public func handleTwo(id: Int64, name: String): String {
    println("handleTwo")
    "done"
}

main() {
    // 每次业务调用之前都会先执行 traceArguments。
    handleOne(1)
    println(handleTwo(2, "Cangjie"))
    0
}
```

linux 平台编译命令：

```shell
# 在同一工作目录先收集切面，再利用生成的元数据织入并重新生成 main。
cjc aop_demo4.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.collect_aspects.so -o main
cjc aop_demo4.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.weave_aspects.so -o main
```

运行结果如下：

```text
arguments=1
handleOne
arguments=2
handleTwo
done
```

`Array<Any>` 不包含实例方法的隐式 `this`。它是目标函数入口处实参的浅快照，修改数组元素不会回写目标函数形参。

## ReplaceFuncBody 替换函数体示例

下面是使用 @ReplaceFuncBody 完成替换指定函数函数体的示例代码：

<!-- compile -->

```cangjie
package AOP_demo3

import stdx.aspect_cj.*
import std.time.DateTime

@ReplaceFuncBody[packageName: "AOP_demo3", className: "", methodName: "printCurrentTime", isStatic: false,
    recursive: false]
public func printCurrentTimeImpl(original: (String) -> String) {
    println("----- ${DateTime.now()} -----")
    println(original("abc"))
    println("----- end -----")
    "def"
}

public func printCurrentTime(x: String): String {
    println(x)
    "456"
}

main() {
    println(printCurrentTime("123"))
    0
}
```

linux 平台编译命令：

```shell
cjc aop_demo3.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.collect_aspects.so -o main # 第一次编译，收集切面
cjc aop_demo3.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.weave_aspects.so -o main # 第二次编译，织入切面
```

运行结果可能如下：

```text
----- 2025-06-03T00:04:59.996469-07:00 -----
abc
456
----- end -----
def
```
