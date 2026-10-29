/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.net.http

import std.sync.*

/*
    A multilevel concurrent queue designed for Single Producer Multiple Consumer scenario.
    In the initializer you can set number of priorities P. The priorities for messages
    range between [0, P-1]. This class creates multiple linked queues, each queue for each priority.
    send() is O(log P), receive() is O(log P) via iterative max-segment tree.
    Previously receive() was O(P) - the segment tree optimization (inspired by segmenttree4cj)
    removes the "priorities should be small" constraint.

    Optimization: An iterative segment tree tracks the max queue size across all priorities
    in O(log P). receive() no longer scans all P priorities.
 */

// Lightweight iterative segment tree for tracking max queue size per priority.
// Inspired by segmenttree4cj's IterativeSegmentTree - 2-array iterative layout,
// O(log n) point update + O(log n) find-first-non-zero.
private class PriorityMaxTracker {
    let n: Int64         // number of priorities
    let size: Int64      // next power of two >= n
    var d: Array<Int64>  // segment tree: d[1..2*size-1], d[i] = max child

    init(n: Int64) {
        self.n = n
        size = computeSize(n)
        d = Array<Int64>(2 * size, { _ => 0 })
    }

    private static func computeSize(n: Int64): Int64 {
        var s: Int64 = 1
        while (s < n) { s *= 2 }
        return s
    }

    // O(log P): set queue size at priority pos
    func update(pos: Int64, value: Int64) {
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
    func findNonZeroHighestPriority(): Int64 {
        if (d[1] == 0) { return -1 }
        var p: Int64 = 1
        while (p < size) {
            if (d[2 * p + 1] > 0) { p = 2 * p + 1 } else { p = 2 * p }
        }
        let result = p - size
        return if (result < n) { result } else { -1 }
    }

    // O(log P): find lowest-index priority with non-zero queue size
    func findNonZeroLowestPriority(): Int64 {
        if (d[1] == 0) { return -1 }
        var p: Int64 = 1
        while (p < size) {
            if (d[2 * p] > 0) { p = 2 * p } else { p = 2 * p + 1 }
        }
        let result = p - size
        return if (result < n) { result } else { -1 }
    }

    func isEmpty(): Bool { return d[1] == 0 }
}

class SPMCLevelQueue<T> {
    let levels: Int64
    let reverse: Bool
    let size: AtomicInt64 = AtomicInt64(0)
    let closed: AtomicBool = AtomicBool(false)
    let queues: Array<ClosableNonBlockingQueue<T>>
    let sendqSizes: Array<AtomicInt64>
    let tracker: PriorityMaxTracker
    let lock: Monitor = Monitor()

    let recvMon: Monitor = Monitor()
    let recvqSize: AtomicInt64 = AtomicInt64(0)

    init(levels: Int64, reverse!: Bool = false) {
        this.levels = levels
        this.sendqSizes = Array<AtomicInt64>(levels, {_ => AtomicInt64(0)})
        this.reverse = reverse
        this.tracker = PriorityMaxTracker(n: levels)
        this.queues = Array<ClosableNonBlockingQueue<T>>(levels, {
            _ => ClosableNonBlockingQueue<T>()
        })
    }

    func send(elem: T, priority: Int64): Bool {
        if (priority >= levels || priority < 0) {
            throw IllegalArgumentException("Invalid argument 'priority': expected value in range [0, ${levels - 1}], got ${priority}.")
        }

        if (queues[priority].enqueue(elem)) {
            size.fetchAdd(1)
            let newCount = sendqSizes[priority].fetchAdd(1) + 1
            synchronized(lock) {
                tracker.update(pos: priority, value: newCount)
            }
            if (recvqSize.load() == 0) {
                return true
            }
            synchronized(recvMon) {
                if (recvqSize.load() != 0) {
                    recvMon.notify()
                }
            }
            return true
        }
        return false
    }

    func receive(): Option<T> {
        while (true) {
            if (let Some(v) <- tryReceive()) {
                return v
            }

            synchronized (recvMon) {
                if (isClosed()) {
                    return None
                }
                recvqSize.fetchAdd(1)
                if (bufferEmpty()) {
                    recvMon.wait(timeout: Duration.second)
                }
                recvqSize.fetchAdd(-1)
            }
        }

        return Option<T>.None
    }

    func receive(timeout!: Duration): Option<T> {
        if (let Some(v) <- tryReceive()) {
            return v
        }

        synchronized (recvMon) {
            recvqSize.fetchAdd(1)
            if (bufferEmpty()) {
                recvMon.wait(timeout: timeout)
            }
            recvqSize.fetchAdd(-1)
        }
        tryReceive()
    }

    // Optimized: O(log P) using segment tree instead of O(P) linear scan
    func tryReceive(): ?T {
        let priority: Int64 = synchronized(lock) {
            if (reverse) {
                tracker.findNonZeroLowestPriority()
            } else {
                tracker.findNonZeroHighestPriority()
            }
        }

        if (priority < 0) {
            return None
        }

        if (let Some(v) <- queues[priority].dequeue()) {
            let newCount = sendqSizes[priority].fetchSub(1) - 1
            synchronized(lock) {
                tracker.update(pos: priority, value: newCount)
            }
            size.fetchSub(1)
            return v
        }
        return None
    }

    func close(): Unit {
        synchronized (recvMon) {
            for (priority in 0..levels) {
                queues[priority].close()
                sendqSizes[priority].store(0)
            }
            synchronized(lock) {
                for (p in 0..levels) {
                    tracker.update(pos: p, value: 0)
                }
            }
            size.store(0)
            closed.store(true)

            recvMon.notifyAll()
        }
    }

    func isClosed(): Bool {
        return closed.load()
    }

    func bufferEmpty(): Bool {
        return size.load() == 0
    }
}

