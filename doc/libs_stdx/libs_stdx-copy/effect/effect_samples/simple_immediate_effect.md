# 即时效应处理器（Immediate Effect Handler）

本示例展示了如何使用简单的 effect handler：定义一个效应（Command），并在其未被处理时进行捕获。

```cangjie
import stdx.effect.{Command, UnhandledCommandException}

// 定义两个效应类型：生成随机数和发送消息
class Random <: Command<Int64> {}
class Send <: Command<Unit> {
    Send(let msg: String) {}
}

main() {
    try {
        // 触发 Random 效应
        let x = perform Random()
        println("Got random number ${x}, sending...")

        // 触发 Send 效应
        perform Send("Sending ${x}")
    } handle(_: Random) {
        // 处理 Random 效应，立即返回 42
        resume with 42
    } catch(_: UnhandledCommandException) {
        // 如果某个效应没有被处理（这里是 Send），会抛出该异常
        println("Attempting to perform an unhandled command")
    }
}
```

## 执行输出

```text
Got random number 42, sending...
Attempting to perform an unhandled command
```