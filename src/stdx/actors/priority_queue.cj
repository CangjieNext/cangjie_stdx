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
 * ConcurrentPriorityQueue for Actor mailbox — O(log P) priority lookup
 * via iterative 2-array max-segment tree replacing O(P) linear scan.
 * Issue #408. Inspired by segmenttree4cj IterativeSegmentTree.
 *
 * secbot vul-002 fixed: PriorityTracker protected by Monitor lock
 * (eliminates data races in multi-producer add); remove() uses
 * non-blocking tryRemove() with bounded retry loop (never hangs on
 * empty queue; bounded convergence under contention).
 *
 */

package stdx.actors

import std.collection.concurrent.ArrayBlockingQueue
import std.sync.Monitor

private const DEFAULT_NUM_OF_PRIORITIES = 10

// Thread-safe iterative max-segment-tree tracking queue size per priority.
// 2-array layout: d[1..2*size-1], d[leaf+size]=queue size, d[internal]=max(children).
// Monitor-protected: all update() and findHighestNonZero() run synchronized(lock).
private class PriorityTracker {
    let n: Int64
    let size: Int64
    var d: Array<Int64>
    private let lock: Monitor = Monitor()

    init(n: Int64) {
        this.n = n
        this.size = computeSize(n)
        this.d = Array<Int64>(2 * this.size, { _ => 0 })
    }

    private static func computeSize(n: Int64): Int64 {
        var s: Int64 = 1
        while (s < n) { s = s * 2 }
        return s
    }

    func update(pos: Int64, value: Int64): Unit {
        synchronized(lock) {
            if (pos < 0 || pos >= n) {
                throw Exception("PriorityTracker.update: pos $pos out of range [0, $n)")
            }
            var p = pos + size
            d[p] = value
            p = p >> 1
            while (p >= 1) {
                let left = d[2 * p]
                let right = d[2 * p + 1]
                let newVal = if (left >= right) { left } else { right }
                if (d[p] == newVal) { break }
                d[p] = newVal
                p = p >> 1
            }
        }
    }

    // Returns highest-index priority with non-zero queue size, or -1.
    func findHighestNonZero(): Int64 {
        synchronized(lock) {
            if (d[1] == 0) { return -1 }
            var p: Int64 = 1
            while (p < size) {
                if (d[2 * p + 1] > 0) { p = 2 * p + 1 } else { p = 2 * p }
            }
            let result = p - size
            return if (result < n) { result } else { -1 }
        }
    }
}

class ConcurrentPriorityQueue<T> {
    private let numOfPriorities: Int64
    private let queuePool: Array<ArrayBlockingQueue<T>>
    private let tracker: PriorityTracker
    private let semaphore = SingleConsumerSemaphore()

    init(capacity: Int64) {
        this(DEFAULT_NUM_OF_PRIORITIES, capacity)
    }

    init(numOfPriorities: Int64, capacity: Int64) {
        this.numOfPriorities = numOfPriorities
        this.queuePool = Array<ArrayBlockingQueue<T>>(numOfPriorities,
            { _ => ArrayBlockingQueue<T>(capacity) })
        this.tracker = PriorityTracker(numOfPriorities)
    }

    func add(item: T, priority: Int64): Unit {
        if (priority <= 0 || priority > numOfPriorities) {
            throw IllegalArgumentException(
                "Invalid argument 'priority': expected a value in [1..${numOfPriorities}], got '${priority}'.")
        }
        queuePool[priority - 1].add(item)
        let qsize = queuePool[priority - 1].size
        tracker.update(priority - 1, qsize)
        semaphore.signal()
    }

    func remove(timeout: Duration): Option<T> {
        if (!semaphore.wait(timeout)) {
            return None
        }

        // Bounded retry: tracker may be stale-high from concurrent add() race.
        // tryRemove() is non-blocking — never wait on empty queue.
        // On stale-high hit (tracker says non-zero but queue is empty), refresh
        // tracker with real size and retry. Converges within numOfPriorities+1.
        var attempts: Int64 = 0
        while (attempts < numOfPriorities + 1) {
            attempts = attempts + 1

            let priority: Int64 = tracker.findHighestNonZero()
            if (priority == -1) {
                // Tracker says all empty but semaphore was signaled — race consumed
                // our wakeup. Return None (timeout was semaphore-based; caller
                // will retry or fail up the stack).
                return None
            }

            // Non-blocking dequeue — ArrayBlockingQueue.tryRemove() returns Option<T>
            if (let Some(v) <- queuePool[priority].tryRemove()) {
                // Successful removal — refresh tracker with real post-removal size
                let newSize = queuePool[priority].size
                tracker.update(priority, newSize)
                return Some(v)
            }

            // tracker was stale-high: another consumer raced us for this queue's item.
            // Refresh tracker entry and retry — will pick next-highest on retry.
            tracker.update(priority, queuePool[priority].size)
        }

        // All retries exhausted under extreme contention. Return None.
        return None
    }
}
