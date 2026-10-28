/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 *
 * @file
 *
 * Iterative segment tree implementations.
 * Inspired by AtCoder Library and segmenttree4cj.
 *
 * Three types are provided:
 *   1. SegmentTree<T>          - point update + range query
 *   2. IterativeSegmentTree<T> - alias kept for API parity
 *   3. IterativeLazySegmentTree<T, L> - range update + range query
 */

package stdx.segtree

/// Monoid: associative binary operation with identity.
public interface Monoid<T> {
    public func combine(left: T, right: T): T
    public func identity(): T
}

/// LazyMonoid: monoid with a lazy propagation operation.
public interface LazyMonoid<T, L> <: Monoid<T> {
    public func lazyApply(value: T, lazy: L): T
    public func lazyCompose(parent: L, child: L): L
    public func lazyIdentity(): L
}

public class SegmentTree<T> {
    private let n: Int64
    private let size: Int64
    private var data: Array<T>
    private let monoid: Monoid<T>

    public init(n: Int64, monoid: Monoid<T>, builder: (Int64) -> T) {
        self.monoid = monoid
        self.n = n
        size = computeSize(n)
        data = Array<T>(2 * size, { _ => monoid.identity() })
        var i: Int64 = 0
        while (i < n) {
            data[i + size] = builder(i)
            i = i + 1
        }
        var p = size - 1
        while (p >= 1) {
            data[p] = monoid.combine(left: data[2 * p], right: data[2 * p + 1])
            p = p - 1
        }
    }

    public init(array: Array<T>, monoid: Monoid<T>) {
        self.monoid = monoid
        self.n = Int64(array.size)
        size = computeSize(n)
        data = Array<T>(2 * size, { _ => monoid.identity() })
        var i: Int64 = 0
        while (i < n) {
            data[i + size] = array[i]
            i = i + 1
        }
        var p = size - 1
        while (p >= 1) {
            data[p] = monoid.combine(left: data[2 * p], right: data[2 * p + 1])
            p = p - 1
        }
    }

    private static func computeSize(n: Int64): Int64 {
        var s: Int64 = 1
        while (s < n) { s = s * 2 }
        return s
    }

    /// O(log n): point update.
    public func set(pos: Int64, value: T): Unit {
        var p = pos + size
        data[p] = value
        p = p >> 1
        while (p >= 1) {
            let newVal = monoid.combine(left: data[2 * p], right: data[2 * p + 1])
            if (data[p] == newVal) { break }
            data[p] = newVal
            p = p >> 1
        }
    }

    /// O(log n): point query.
    public func get(pos: Int64): T {
        return data[pos + size]
    }

    /// O(log n): range query [l, r).
    public func query(l: Int64, r: Int64): T {
        if (l >= r) { return monoid.identity() }
        var leftRes = monoid.identity()
        var rightRes = monoid.identity()
        var l2 = l + size
        var r2 = r + size
        while (l2 < r2) {
            if ((l2 & 1) == 1) {
                leftRes = monoid.combine(left: leftRes, right: data[l2])
                l2 = l2 + 1
            }
            if ((r2 & 1) == 1) {
                r2 = r2 - 1
                rightRes = monoid.combine(left: data[r2], right: rightRes)
            }
            l2 = l2 >> 1
            r2 = r2 >> 1
        }
        return monoid.combine(left: leftRes, right: rightRes)
    }
}

public class IterativeSegmentTree<T> <: SegmentTree<T> {
    public init(n: Int64, monoid: Monoid<T>, builder: (Int64) -> T) {
        super(n: n, monoid: monoid, builder: builder)
    }
    public init(array: Array<T>, monoid: Monoid<T>) {
        super(array: array, monoid: monoid)
    }
}

public class IterativeLazySegmentTree<T, L> {
    private let n: Int64
    private let size: Int64
    private let log: Int64
    private var data: Array<T>
    private var lazy: Array<L>
    private let op: LazyMonoid<T, L>

    public init(n: Int64, op: LazyMonoid<T, L>, builder: (Int64) -> T) {
        self.op = op
        self.n = n
        let (sz, lg) = computeSizeLog(n)
        size = sz
        log = lg
        data = Array<T>(2 * size, { _ => op.identity() })
        lazy = Array<L>(size, { _ => op.lazyIdentity() })
        var i: Int64 = 0
        while (i < n) {
            data[i + size] = builder(i)
            i = i + 1
        }
        var p = size - 1
        while (p >= 1) {
            data[p] = op.combine(left: data[2 * p], right: data[2 * p + 1])
            p = p - 1
        }
    }

    public init(array: Array<T>, op: LazyMonoid<T, L>) {
        self.op = op
        self.n = Int64(array.size)
        let (sz, lg) = computeSizeLog(n)
        size = sz
        log = lg
        data = Array<T>(2 * size, { _ => op.identity() })
        lazy = Array<L>(size, { _ => op.lazyIdentity() })
        var i: Int64 = 0
        while (i < n) {
            data[i + size] = array[i]
            i = i + 1
        }
        var p = size - 1
        while (p >= 1) {
            data[p] = op.combine(left: data[2 * p], right: data[2 * p + 1])
            p = p - 1
        }
    }

    private static func computeSizeLog(n: Int64): (Int64, Int64) {
        var s: Int64 = 1
        var l: Int64 = 0
        while (s < n) { s = s * 2; l = l + 1 }
        return (s, l)
    }

    private func push(k: Int64): Unit {
        if (lazy[k] != op.lazyIdentity()) {
            data[2 * k] = op.lazyApply(value: data[2 * k], lazy: lazy[k])
            if (2 * k < size) { lazy[2 * k] = op.lazyCompose(parent: lazy[2 * k], child: lazy[k]) }
            data[2 * k + 1] = op.lazyApply(value: data[2 * k + 1], lazy: lazy[k])
            if (2 * k + 1 < size) { lazy[2 * k + 1] = op.lazyCompose(parent: lazy[2 * k + 1], child: lazy[k]) }
            lazy[k] = op.lazyIdentity()
        }
    }

    private func pushFrom(node: Int64) -> Unit {
        var k = node >> log
        var l: Int64 = log
        while (l >= 1) { push(k >> l); l = l - 1 }
    }

    private func updateAncestors(node: Int64) -> Unit {
        var p = node >> 1
        while (p >= 1) {
            data[p] = op.combine(left: data[2 * p], right: data[2 * p + 1])
            p = p >> 1
        }
    }

    /// O(log n): range update [l, r).
    public func rangeUpdate(l: Int64, r: Int64, value: L): Unit {
        if (l >= r) { return }
        pushFrom(l + size)
        pushFrom(r + size)
        var l2 = l + size
        var r2 = r + size
        while (l2 < r2) {
            if ((l2 & 1) == 1) {
                data[l2] = op.lazyApply(value: data[l2], lazy: value)
                if (l2 < size) { lazy[l2] = op.lazyCompose(parent: lazy[l2], child: value) }
                l2 = l2 + 1
            }
            if ((r2 & 1) == 1) {
                r2 = r2 - 1
                data[r2] = op.lazyApply(value: data[r2], lazy: value)
                if (r2 < size) { lazy[r2] = op.lazyCompose(parent: lazy[r2], child: value) }
            }
            l2 = l2 >> 1
            r2 = r2 >> 1
        }
        updateAncestors(l + size)
        updateAncestors(r + size - 1)
    }

    /// O(log n): range query [l, r).
    public func query(l: Int64, r: Int64): T {
        if (l >= r) { return op.identity() }
        pushFrom(l + size)
        pushFrom(r + size)
        var l2 = l + size
        var r2 = r + size
        var leftRes = op.identity()
        var rightRes = op.identity()
        while (l2 < r2) {
            if ((l2 & 1) == 1) {
                leftRes = op.combine(left: leftRes, right: data[l2])
                l2 = l2 + 1
            }
            if ((r2 & 1) == 1) {
                r2 = r2 - 1
                rightRes = op.combine(left: data[r2], right: rightRes)
            }
            l2 = l2 >> 1
            r2 = r2 >> 1
        }
        return op.combine(left: leftRes, right: rightRes)
    }

    public func set(pos: Int64, value: T): Unit {
        let node = pos + size
        pushFrom(node)
        data[node] = value
        updateAncestors(node)
    }

    public func get(pos: Int64): T {
        let node = pos + size
        pushFrom(node)
        return data[node]
    }
}
