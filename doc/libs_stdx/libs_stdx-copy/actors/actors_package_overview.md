# stdx.actors

## 功能介绍

### Actor 模型概述

Actor 模型是一种并发编程模型，旨在简化并发任务的处理。

在这个模型中，actor 是基本的并发单元，具备以下特征：

- 每个 actor 都拥有独立的仓颉线程。
- 每个 actor 都拥有自己的成员变量。
- 这些变量只能由该 actor 的线程进行访问和修改。
- Actor 包含一种特殊的成员函数，称为 "接收函数"。当接收函数被调用时，调用请求会被加入到一个队列中，并在该 actor 的线程上按顺序执行。
- 一旦没有任何引用指向该 actor，且所有的接收函数都已执行完毕，它就可以被系统回收。

> **注意：**
> Actor 模型的第三项特性还没有被语言强制实施，所以 actor 的成员变量还不具备完全的并发安全性。未来，类型系统可以解决这个问题，确保成员变量的并发安全。

Actor 的主要应用场景是在多线程环境下对同一个对象进行访问和修改。例如，一个银行账户的对象能会被多个线程同时访问，如执行存款或取款。在缺乏任何同步机制的情况下，可能会导致数据竞争：

```cangjie
public class Account {
    public Account(
        private let name: String,
        private var balance: Float64
    ) {}

    public func deposit(amount: Float64): Unit {
        balance += amount
    }

    public func withdraw(amount: Float64): Unit {
        if (balance < amount) {
            throw BalanceNotEnoughException(name)
        }
        balance -= amount
    }

    public func getBalance(): Float64 {
        balance
    }
}
```

在多线程环境下同时访问和修改该对象，可能会导致数据竞争：

```cangjie
let account = Account("Steven", 0.0)
spawn {
    account.deposit(1000.0)
}
spawn {
    account.withdraw(2000.0)
}
```

正确使用 Actor 模型可以使并发编程变得更加简洁和高效。

### Actor 的声明

引用上述银行账户的例子，为了避免线程安全问题，我们可以使用 Actor 模型来设计一个专门处理账户操作的 actor。

首先，我们可以使用 [@Actor](./macros/macros_package_api/macros_package_macros.md#actor-宏) 注解将 `Account` 类标记为一个 actor。然后，使用 [@Receiver](./macros/macros_package_api/macros_package_macros.md#receiver-宏) 注解来标记 deposit ， withdraw 和 getBalance 函数：

```cangjie
@Actor
public class Account {
    public Account(
        private let name: String,
        private var balance: Float64
    ) {}

    @Receiver
    public func deposit(amount: Float64): Unit {
        balance += amount
    }

    @Receiver
    public func withdraw(amount: Float64): Unit {
        if (balance < amount) {
            throw BalanceNotEnoughException(name)
        }
        balance -= amount
    }

    @Receiver
    public func getBalance(): Float64 {
        balance
    }
}
```

对于 [@Actor](./macros/macros_package_api/macros_package_macros.md#actor-宏) 和 [@Receiver](./macros/macros_package_api/macros_package_macros.md#receiver-宏) 的使用规则跟限制，请参考对应的文档。

我们可以通过调用该类的构造函数来创建一个 Account 实例，例如：

```cangjie
let stevenAccount: Account = Account("Steven", 0.0)
```

在创建 Account 实例的同时，系统会自动创建一个与该实例关联的仓颉线程。

### 调用接收函数

与普通函数不同，接收函数的调用是异步的，并返回一个 [ActorFuture\<T>](./actors_package_api/actors_package_classes.md#class-actorfuture) 对象。通过该对象，可以等待接收函数执行完成并获取结果，其中 `T` 是该接收函数的返回类型。例如，调用 getBalance 时，将返回一个 [ActorFuture\<Float64>](./actors_package_api/actors_package_classes.md#class-actorfuture) 的对象：

```cangjie
let fut: ActorFuture<Float64> = stevenAccount.getBalance()
```

当接收函数被调用时，调用请求会被加入到一个队列中，并在该 actor 的附属线程上按顺序执行。

随后，我们可以通过调用 [ActorFuture\<T>](./actors_package_api/actors_package_classes.md#class-actorfuture) 的 get 函数来阻塞当前线程，直到 steven.getBalance() 函数执行完成，并返回一个 `T` 类型的值。

```cangjie
let stevenBalance: Float64 = fut.get()
```

stevenBalance 的值将取决于 steven.getBalance() 执行时成员变量 balance 的值。

在多线程环境下，虽然接收函数可能同时被调用，但由于同一个 actor 实例的接收函数是顺序执行的，不会发生交叉执行。因此，我们可以将它们视为原子操作（atomic function），从而避免数据竞争。

```cangjie
let account = Account("Steven", 0.0)
spawn {
    account.deposit(1000.0)
}
spawn {
    account.withdraw(2000.0)
}
```

> **注意：**
> 目前 actor 的成员变量还不具备完全的并发安全性。例如在以下的例子当中，public 的成员变量还是可以被直接在外部访问与修改：
>
> ```cangjie
> @Actor
> public class MyActor {
>     public var x: Int64 = 0
> }
>
> let myActor = MyActor()
> spawn {
>     myActor.x = 2
> }
> spawn {
>     myActor.x = 3
> }
> ```
>
> 未来，一个新的类型系统可以解决这个问题，确保成员变量的并发安全。

### 接收函数的执行顺序

在同一线程对同一个 actor 调用接收函数时，这些函数将按调用的顺序执行。例如：

```cangjie
func foo() {
    let account = Account("Federico", 0.0)
    account.deposit(1000.0)
    account.withdraw(500.0)
    let fut = account.getBalance()
    println(fut.get())
}
```

在没有其他线程的情况下，这段代码必然会输出以下内容，并不会出现 account.withdraw(500.0) 先于 account.deposit(1000.0) 执行的情况：

```text
500.0
```

不同线程对同一 actor 的调用将不保证执行顺序，比如：

```cangjie
let account = Account("Steven", 0.0)
spawn {
    account.deposit(1000.0)
}
spawn {
    account.withdraw(500.0)
}
```

以下都是可能出现的执行顺序：

```text
account.deposit(1000.0)
account.withdraw(500.0)
```

```text
account.withdraw(500.0)
account.deposit(1000.0)
```

### 接收函数抛出的异常

接收函数抛出的任何未捕获的异常或错误都将传播到对应的 [ActorFuture\<T>](./actors_package_api/actors_package_classes.md#class-actorfuture) 对象，类似于 `spawn` 的处理。

继续应用 Account 的例子，在 withdraw(amount) 函数里面，如果户口里面的 balance 不够会抛出 BalanceNotEnoughException 异常：

```cangjie
@Receiver
public func withdraw(amount: Float64): Unit {
    if (balance < amount) {
        throw BalanceNotEnoughException(name)
    }
    balance -= amount
}
```

抛出的异常会被传递到对应的 [ActorFuture](./actors_package_api/actors_package_classes.md#class-actorfuture) 对象，调用它的 get 函数时会抛出同一个异常：

```cangjie
let account = Account("Hamid", 0.0)
let fut: ActorFuture<Unit> = account.withdraw(500.0)
try {
    let res = fut.get()
} catch (e: BalanceNotEnoughException) {
    println("fut.get() throws BalanceNotEnoughException")
    println()
    e.printStackTrace()
}
```

由于 account.withdraw(500.0) 抛出了 BalanceNotEnoughException，因此 fut.get() 也会抛出相同的异常。以下是输出内容：

```text
fut.get() throws BalanceNotEnoughException

An exception has occurred:
Exception: Balance for account Hamid is not enough.
         at default.BalanceNotEnoughException::init(std.core::String)(/home/.../main.cj:6)
         at default.Account::withdraw::lambda.0()(/home/.../main.cj:25)
         at stdx.actors.ActorFuture<...>::execute()(stdx/actors/actor_future.cj:90)
         at stdx.actors.SequentialDispatcher::startActorLoop::lambda.0()(stdx/actors/actors.cj:46)
```

当一个接收函数抛出异常后， 该 actor 的附属线程会继续执行下一个在队列里面的接收函数调用：

```cangjie
let account = Account("Hamid", 0.0)
let fut: ActorFuture<Unit> = account.withdraw(500.0)
let fut2: ActorFuture<Float64> = account.getBalance()
try {
    let res = fut.get()
} catch (e: BalanceNotEnoughException) {
    println("fut.get() throws BalanceNotEnoughException")
    println()
    e.printStackTrace()
    println()
}
let res = fut2.get()
println("Balance = ${res}")
```

在该 actor 的线程里面， account.withdraw(500.0) 执行并抛出异常后，线程会继续执行 account.getBalance()。以下是输出内容：

```text
fut.get() throws BalanceNotEnoughException

An exception has occurred:
Exception: Balance for account Hamid is not enough.
         at default.BalanceNotEnoughException::init(std.core::String)(/home/.../main.cj:6)
         at default.Account::withdraw::lambda.0()(/home/.../main.cj:25)
         at stdx.actors.ActorFuture<...>::execute()(stdx/actors/actor_future.cj:90)
         at stdx.actors.SequentialDispatcher::startActorLoop::lambda.0()(stdx/actors/actors.cj:46)

Balance = 0.0
```

### Actor 的生命周期

当没有任何引用指向该 actor，并且没有待执行的接收函数调用时，该 actor 就可以被运行时回收：

```cangjie
func test(): Unit {
    let account = Account("Ziming", 0.0)
    let fut = account.deposit(5.0)
    println(fut.get())
}

func bar() {
    test()
    // account 有可能被回收
}
```

在 test() 返回后，由于已经没有对 account 的引用，且没有待执行的接收函数调用（因为我们在 test() 内部已经等待了 account.deposit(5.0) 的结果），因此 account 所指向的 actor 及其附属仓颉线程将会被系统回收。

### 接收函数的优先值

用户可以为接收函数指定优先级，从而使高优先级的接收函数有可能在低优先级的接收函数之前执行。

首先，用户需要通过在 [@Actor](./macros/macros_package_api/macros_package_macros.md#actor-宏) 宏上加上 `enableReceiverPriority: true` 选项，用于启用 actor 接收函数之间的优先级。例如：

```cangjie
@Actor[enableReceiverPriority: true]
public class Account {
    public Account(
        private let name: String,
        private var balance: Float64
    ) {}
}
```

如果 `enableReceiverPriority` 设置为 `false` 或者 `@Actor` 宏没有这个选项，那么意味着接收函数的优先级未启用。

接下来我们可以为每个接收函数指定默认的优先级级别，目前我们提供了 10 个优先级级别，用 1 到 10 的整数表示；数字越大，优先级越高，如果未设置 `priority` 选项，则默认值为 5：

```cangjie
@Actor[enableReceiverPriority: true]
public class Account {
    ...

    @Receiver[priority: 10]
    public func deposit(amount: Float64): Unit {
        balance += amount
    }

    @Receiver[priority: 1]
    public func withdraw(amount: Float64): Unit {
        if (balance < amount) {
            throw BalanceNotEnoughException(name)
        }
        balance -= amount
    }

    @Receiver
    public func getBalance(): Float64 {
        balance
    }
}
```

通过提高 deposit 的优先级并降低 withdraw 的优先级，当同时有大量 deposit 和 withdraw 调用时，deposit 将优先执行，从而减少 withdraw 抛出 BalanceNotEnoughException 的机会。

此外，在调用接收函数时，可以通过在参数列表末尾传递一个额外的命名参数 *priority* 来重载该函数的优先级：

```cangjie
func foo(account: Account) {
    account.getBalance()
    account.withdraw(100.0, priority: 10)
}
```

account.withdraw(100.0, priority: 10) 的调用将有可能被优先执行。

### 死锁

最后请注意，在 actor 的接收函数中调用 `fut.get()` 可能会导致死锁，例如：

```cangjie
@Actor
class MyActor {
    @Receiver
    func foo(): Int64 {
        let fut = this.bar()
        // this will deadlock
        fut.get()
    }

    @Receiver
    func bar(): Int64 {
        42
    }
}
```

调用 `this.bar()` 会将该接收函数添加到队列末尾。然而在一个接收函数里面阻塞会导致 actor 的线程阻塞，所以 `bar()` 永远不会被执行。所以在 `foo()` 里面执行 `fut.get()` 会永远阻塞。

### 完整例子

<!-- compile -->

```cangjie
package actorDemo

import std.collection.ArrayList

import stdx.actors.*
import stdx.actors.macros.*

@Actor[enableReceiverPriority: true]
public class Account {
    public Account(
        private let name: String,
        private var balance: Float64
    ) {}

    @Receiver[priority: 10]
    public func deposit(amount: Float64): Unit {
        balance += amount
    }

    @Receiver[priority: 1]
    public func withdraw(amount: Float64): Unit {
        if (balance < amount) {
            throw BalanceNotEnoughException(name)
        }
        balance -= amount
    }

    @Receiver
    public func getBalance(): Float64 {
        balance
    }
}

public class BalanceNotEnoughException <: Exception {
    public init(name: String) {
        super("Balance for account ${name} is not enough.")
    }
}

main() {
    let account = Account("Steven", 0.0)
    let futs = ArrayList<Future<Unit>>()
    for (_ in 0..100) {
        let fut1 = spawn {
            for (_ in 0..10) {
                account.deposit(1000.0)
            }
        }
        let fut2 = spawn {
            for (_ in 0..10) {
                account.withdraw(1000.0)
            }
        }
        futs.add(fut1)
        futs.add(fut2)
    }
    for (f in futs) {
        f.get()
    }
    println("Balance: ${account.getBalance().get()}")
}
```

## API 列表

### 类

|                 类名              |                功能                 |
| --------------------------------- | ---------------------------------- |
| [ActorFuture\<T>](./actors_package_api/actors_package_classes.md#class-actorfuture) | 调用接收函数获得，可用于获取其结果。                        |
| [SequentialDispatcher](./actors_package_api/actors_package_classes.md#class-sequentialdispatcher) | 提供把多个闭包在同一个线程排队执行的功能，通常用户不需要自己使用这个类型。       |