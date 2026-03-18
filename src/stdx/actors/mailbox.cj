/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

/**
 * @file
 *
 * This file defines the abstraction and implementation of different mailbox.
 *
 */

package stdx.actors

import std.collection.concurrent.LinkedBlockingQueue

private type Item = (SequentialDispatcher, () -> Unit)

interface Mailbox {
    func add(item: Item, priority: Int64): Unit
    func remove(timeout!: Duration): Option<Item>
}

class UnboundedMailbox <: Mailbox {
    private let queue = LinkedBlockingQueue<Item>()

    public func add(item: Item, _: Int64): Unit {
        queue.add(item)
    }

    public func remove(timeout!: Duration = Duration.Zero): Option<Item> {
        queue.remove(timeout)
    }
}

class UnboundedPriorityMailbox <: Mailbox {
    private let queue = ConcurrentPriorityQueue<Item>()

    public func add(item: Item, priority: Int64): Unit {
        queue.add(item, priority)
    }

    public func remove(timeout!: Duration = Duration.Zero): Option<Item> {
        queue.remove(timeout)
    }
}
