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
 * This file defines a ConcurrentPriorityQueue class for a given capacity (Default 10).
 *
 */

package stdx.actors

import std.collection.concurrent.ConcurrentLinkedQueue

const DEFAULT_CAPACITY = 10

class ConcurrentPriorityQueue<T> {
    private let capacity: Int64
    private let queuePool: Array<ConcurrentLinkedQueue<T>>

    init() {
        this(DEFAULT_CAPACITY)
    }

    init(capacity: Int64) {
        this.capacity = capacity
        this.queuePool = Array<ConcurrentLinkedQueue<T>>(capacity, {_ => ConcurrentLinkedQueue<T>()})
    }

    func add(value: T, priority: Int64): Unit {
        if (priority <= 0 || priority > capacity) {
            throw IllegalArgumentException("Priority must be in the range [1..${capacity}].")
        }
        // Note: ConcurrentLinkedQueue.add() will never return false
        queuePool[priority - 1].add(value)
    }

    func remove(): Option<T> {
        var index: Int64 = -1
        for (i in 0..queuePool.size) {
            if (!queuePool[i].isEmpty()) {
                index = i
            }
        }
        if (index != -1) {
            return queuePool[index].remove()
        }
        return None
    }
}
