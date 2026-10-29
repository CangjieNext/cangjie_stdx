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

private const DEFAULT_NUM_OF_PRIORITIES = 10

// Lightweight iterative segment tree for tracking max queue size per priority.
// 2-array iterative layout, O(log P) update + O(log P) find-non-zero.
// Inspired by segmenttree4cj IterativeSegmentTree.
private class PriorityTracker {
    let n: Int64
    let size: Int64       // next power of two >= n
    var d: Array<Int64>  // d[1..2*size-1], max child per node

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
        assert(pos >= 0 && pos < n, "PriorityTracker.update: pos $pos out of [0, $n)")
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

    // O(log P): find highest-index priority with non-zero queue size
    func findHighestNonZero(): Int64 {
        if (d[1] == 0) { return -1 }
        var p: Int64 = 1
        while (p < size) {
            if (d[2 * p + 1] > 0) { p = 2 * p + 1 } else { p = 2 * p }
        }
        let result = p - size
        return if (result < n) { result } else { -1 }
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
        // Update tracker in O(log P)
        let qsize = queuePool[priority - 1].size
        tracker.update(pos: priority - 1, value: qsize)
        semaphore.signal()
    }

    func remove(timeout: Duration): Option<T> {
        if (!semaphore.wait(timeout)) {
            return None
        }

        // O(log P) find highest-priority non-empty queue (replaces O(P) for loop)
        let priority: Int64 = tracker.findHighestNonZero()
        if (priority == -1) {
            return None
        }

        let result = queuePool[priority].remove()
        // Update tracker after removal
        let newSize = queuePool[priority].size
        tracker.update(pos: priority, value: newSize)
        return result
    }
}
