# String Intern Example

<!-- verify -->

```cangjie
import cangjie_stdx::string_intern.Internable

main(): Unit {
    String.configInternPool(capacity: 10000, strMaxLength: 1000)
    let intern1 = String.intern("hello, cangjie")
    println(intern1)
    let intern2 = String.intern(unsafe { "hello, cangjie".rawData() })
    println(intern2)
}
```

Execution results:

```text
"hello, cangjie"
"hello, cangjie"
```
