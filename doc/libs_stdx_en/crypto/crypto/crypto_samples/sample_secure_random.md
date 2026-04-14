# SecureRandom Usage

SecureRandom creates random number objects.

Example:

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

Execution Result:

> **Note**
>
> Possible execution results are as follows (the selection of true/false is random).

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