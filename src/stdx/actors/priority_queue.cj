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

import std.collection.concurrent.LinkedBlockingQueue

private const DEFAULT_NUM_OF_PRIORITIES = 10

class ConcurrentPriorityQueue<T> {
    private let numOfPriorities: Int64
    private let queuePool: Array<LinkedBlockingQueue<T>>
    private let semaphore = SingleConsumerSemaphore()

    init() {
        this(DEFAULT_NUM_OF_PRIORITIES)
    }

    init(numOfPriorities: Int64) {
        this.numOfPriorities = numOfPriorities
        this.queuePool = Array<LinkedBlockingQueue<T>>(numOfPriorities, { _ => LinkedBlockingQueue<T>() })
    }

    func add(item: T, priority: Int64): Unit {
        if (priority <= 0 || priority > numOfPriorities) {
            throw IllegalArgumentException("Priority must be in the range [1..${numOfPriorities}].")
        }
        queuePool[priority - 1].add(item)
        semaphore.signal()
    }

    func remove(timeout: Duration): Option<T> {
        semaphore.wait(timeout)

        var index: Int64 = -1
        for (i in 0..numOfPriorities) {
            if (queuePool[i].size > 0) {
                index = i
            }
        }
        if (index != -1) {
            return queuePool[index].remove()
        }

        return None
    }
}
