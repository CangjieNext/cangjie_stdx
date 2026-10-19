# AOP Development Example

## InsertAtEntry Entry Instrumentation Example

The following is an example code demonstrating function entry point instrumentation using `@InsertAtEntry`:

<!-- compile -->

```cangjie
package AOP_demo1

import stdx.aspect_cj.*
import std.time.DateTime

@InsertAtEntry[packageName: "AOP_demo1", className: "", methodName: "printCurrentTime", isStatic: false, recursive: false, funcTypeStr: "()->Unit"]
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

Linux platform compilation commands:

```shell
cjc aop_demo1.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.collect_aspects.so -o main # First compilation: aspect collection
cjc aop_demo1.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.weave_aspects.so -o main # Second compilation: aspect weaving
```

Possible execution output:

```text
----- 2025-06-03T00:00:18.994507-07:00 -----
hi
bye
```

## InsertAtExit Exit Instrumentation Example

The following is an example code demonstrating function exit point instrumentation using `@InsertAtExit`:

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

Linux platform compilation commands:

```shell
cjc aop_demo2.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.collect_aspects.so -o main # First compilation: aspect collection
cjc aop_demo2.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.weave_aspects.so -o main # Second compilation: aspect weaving
```

Possible execution output:

```text
hi
bye
----- 2025-06-03T00:04:59.996469-07:00 -----
done
```

## Wildcard Pointcut and Argument Snapshot Example

The following aspect uses wildcard configuration to match two functions with different signatures and receives all explicit target arguments through `Array<Any>`:

<!-- compile -->

```cangjie
package AOP_demo4

import stdx.aspect_cj.*

// AOP_* matches this example's package; handle* matches both business function names.
// A global function has an empty type name, which className's * also matches.
// (**)->* accepts any parameter list and return type; advice receives Array<Any>.
@InsertAtEntry[packageName: "AOP_*", className: "*", methodName: "handle*", isStatic: false,
    recursive: false, funcTypeStr: "(**)->*"]
public func traceArguments(args: Array<Any>) {
    // Arguments retain parameter order: one for handleOne, two for handleTwo.
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
    // traceArguments runs before each business function call.
    handleOne(1)
    println(handleTwo(2, "Cangjie"))
    0
}
```

Compilation commands on Linux:

```shell
# Collect first, then weave using the generated metadata in the same working directory.
cjc aop_demo4.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.collect_aspects.so -o main
cjc aop_demo4.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.weave_aspects.so -o main
```

The output is:

```text
arguments=1
handleOne
arguments=2
handleTwo
done
```

`Array<Any>` excludes the implicit `this` of an instance method. It is a shallow snapshot of arguments at target-function entry, and changing an array element does not write back to the target parameter.

## ReplaceFuncBody Function Body Replacement Example

The following is an example code demonstrating function body replacement using `@ReplaceFuncBody`:

<!-- compile -->

```cangjie
package AOP_demo3

import stdx.aspect_cj.*
import std.time.DateTime

@ReplaceFuncBody[packageName: "AOP_demo3", className: "", methodName: "printCurrentTime", isStatic: false,
    recursive: false]
public func printCurrentTimeImpl(original: (String)->String) {
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

Linux platform compilation commands:

```shell
cjc aop_demo3.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.collect_aspects.so -o main # First compilation: aspect collection
cjc aop_demo3.cj -L $CANGJIE_STDX_PATH --import-path $CANGJIE_STDX_PATH -lstdx.aspect_cj --plugin=$CANGJIE_STDX_PATH/libstdx.weave_aspects.so -o main # Second compilation: aspect weaving
```

Possible execution output:

```text
----- 2025-06-03T00:04:59.996469-07:00 -----
abc
456
----- end -----
def
```
