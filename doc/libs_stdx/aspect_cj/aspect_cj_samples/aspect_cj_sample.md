# AOP 开发示例

## InsertAtEntry 入口插桩示例

下面是使用 @InsertAtEntry 完成在指定函数入口插桩的示例代码：

<!-- compile -->

```cangjie
package AOP_demo1

import stdx.aspect_cj.*
import std.time.DateTime

@InsertAtEntry[packageName: "AOP_demo1", className: "", methodName: "printCurrentTime", isStatic: false,
    funcTypeStr: "()->Unit", recursive: false]
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
    funcTypeStr: "()->std.core:String", recursive: false]
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

## 通配符配置示例

下面是使用通配符配置来匹配多个函数的示例代码：

<!-- compile -->

```cangjie
package AOP_demo4

import stdx.aspect_cj.*
import std.time.DateTime

@InsertAtEntry[packageName: "*", className: "", methodName: "logTime", isStatic: false,
    funcTypeStr: "()->Unit", recursive: false]
public func logTimeImpl() {
    println("----- ${DateTime.now()} -----")
}

public func logTime() {
    println("logging time")
}

main() {
    logTime()
    0
}
```

使用通配符 `*` 作为 `packageName` 可以匹配任意包中的 `logTime` 方法。同样，`className` 和 `methodName` 也可以使用 `*` 来匹配任意值。

## 切点函数参数作为实参示例

下面是使用切点函数参数作为实参的示例代码：

<!-- compile -->

```cangjie
package AOP_demo5

import stdx.aspect_cj.*

@InsertAtEntry[packageName: "AOP_demo5", className: "", methodName: "processData", isStatic: false,
    funcTypeStr: "(Int64, String)->Unit", recursive: false]
public func logDataProcessing(x: Int64) {
    println("Processing data with Int64 value: ${x}")
}

public func processData(x: Int64, name: String) {
    println("Processing ${name} with value ${x}")
}

main() {
    processData(42, "test")
    0
}
```

在这个示例中，切面函数 `logDataProcessing` 只声明了一个 `Int64` 类型的参数 `x`，而目标函数 `processData` 有两个参数。编译器会自动根据类型匹配将 `processData` 的第一个参数（`Int64` 类型）传递给 `logDataProcessing`。