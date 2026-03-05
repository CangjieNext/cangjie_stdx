# Immediate Effect Handler

This example demonstrates how to use a simple effect handler: define an effect (`Command`) and handle it, while also catching the case where an effect is not handled.

```cangjie
import cangjie_stdx::effect.{Command, UnhandledCommandException}

// Define two effect types: generating a random number and sending a message
class Random <: Command<Int64> {}
class Send <: Command<Unit> {
    Send(let msg: String) {}
}

main() {
    try {
        // Perform the Random effect
        let x = perform Random()
        println("Got random number ${x}, sending...")

        // Perform the Send effect
        perform Send("Sending ${x}")
    } handle(_: Random) {
        // Handle the Random effect, immediately returning 42
        resume with 42
    } catch(_: UnhandledCommandException) {
        // If an effect is not handled (in this case, Send), this exception is thrown
        println("Attempting to perform an unhandled command")
    }
}
```

## Output

```text
Got random number 42, sending...
Attempting to perform an unhandled command
```