# SecureRandom 使用

Random 创建随机数对象。

示例：

<!-- run -->
```cangjie
import stdx.crypto.crypto.*

main() {
    let r = SecureRandom()
    for (_ in 0..10) {
        let flip = r.nextBool()
        println(flip)
    }
    return 0
}
```

可能的运行结果：

```text
false
true
false
false
false
true
true
false
false
true
```
