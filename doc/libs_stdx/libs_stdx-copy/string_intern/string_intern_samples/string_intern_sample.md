# 字符串池化缓存示例

代码如下：

<!-- verify -->

```cangjie
import stdx.string_intern.Internable

main(): Unit {
    String.configInternPool(capacity: 10000, strMaxLength: 1000)
    let intern1 = String.intern("hello, 仓颉")
    println(intern1)
    let intern2 = String.intern(unsafe { "hello, 仓颉".rawData() })
    println(intern2)
}
```

运行结果如下：

```text
"hello, 仓颉"
"hello, 仓颉"
```
