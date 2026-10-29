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
 * Optimized: find-non-empty-priority is O(log P) via iterative max-segment tree,
 * replacing the previous O(P) linear scan (Issue #408).
 * Inspired by segmenttree4cj's IterativeSegmentTree.
 *
 */

package stdx.actors

import std.collection.concurrent.ArrayBlockingQueue
import std.sync.Monitor

private const DEFAULT_NUM_OF_PRIORITIES = 10

// Thread-safe iterative segment tree for tracking max queue size per priority.
// 2-array iterative layout, O(log P) update + O(log P) find-non-zero.
// All reads/writes protected by Monitor to prevent data races in multi-producer scenarios.
private class PriorityTracker {
    let n: Int64
    let size: Int64       // next power of two >= n
    var d: Array<Int64>  // d[1..2*size-1], max child per node
    private let lock: Monitor = Monitor()

    init(n: Int64) {
        self.n = n
        size = computeSize(n)
        d = Array<Int64>(2 * size, { _ => 0 })
    }

    private static func computeSize(n: Int64): Int64 {
        var s: Int64 = 1
        while (s < n) { s = s * 2 }
        return s
    }

    func update(pos: Int64, value: Int64): Unit {
        synchronized(lock) {
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

    // O(log P): find highest-index priority with non-zero queue size.
    // Returns -1 when all priorities are zero.
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
        this.queuePool = Array<ArrayBlockingQueue<T>>(numOfPriorities, { _ => ArrayBlockingQueue<T>(capacity) })
        this.tracker = PriorityTracker(n: numOfPriorities)
    }

    func add(item: T, priority: Int64): Unit {
        if (priority <= 0 || priority > numOfPriorities) {
            throw IllegalArgumentException("Invalid argument 'priority': expected a value in [1..${numOfPriorities}], got '${priority}'.")
        }
        queuePool[priority - 1].add(item)
        // Update tracker in O(log P) — tracker.update is internally synchronized
        let qsize = queuePool[priority - 1].size
        tracker.update(pos: priority - 1, value: qsize)
        semaphore.signal()
    }

    func remove(timeout: Duration): Option<T> {
        if (!semaphore.wait(timeout)) {
            return None
        }

        // Retry loop to handle tracker/queue divergence (stale-high / stale-low).
        // poll() is non-blocking — we never wait on a possibly-empty queue.
        var attempts: Int64 = 0
        while (attempts < numOfPriorities + 1) {
            attempts = attempts + 1

            // O(log P) find highest-priority non-empty queue
            let priority: Int64 = tracker.findHighestNonZero()
            if (priority == -1) {
                // Tracker says all empty but semaphore was signaled — retry once
                continue
            }

            // poll() never blocks; returns null immediately if queue is empty
            let result = queuePool[priority].poll()
            if (result != null) {
                // Successful removal — refresh tracker with real queue size
                let newSize = queuePool[priority].size
                tracker.update(pos: priority, value: newSize)
                return Option<T>(result as T)
            }

            // poll() returned null — tracker was stale-high (another consumer raced us).
            // Refresh this priority's tracker entry and retry.
            tracker.update(pos: priority, value: queuePool[priority].size)
        }

        // All retries exhausted — semaphore was burned by race. Return None.
        return None
    }
}
