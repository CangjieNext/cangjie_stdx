/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 *
 * @file
 * Iterative 2-array segment tree implementations.
 * Inspired by AtCoder Library and segmenttree4cj.
 *
 * Three public types:
 *   1. SegmentTree<T>                              - point update + range query
 *   2. IterativeSegmentTree<T> <: SegmentTree<T>   - API alias
 *   3. IterativeLazySegmentTree<T, L>              - range update + range query (lazy)
 *
 * All indices 0-based [0, n). Range ops use semi-open [l, r).
 * Out-of-bounds throws Exception (Fail-Closed).
 */

package stdx.segtree

/// Monoid: associative binary operation with identity.
/// combine(combine(a, b), c) == combine(a, combine(b, c))  (associativity)
/// combine(identity(), a) == a                             (identity)
public interface Monoid<T> {
    func combine(a: T, b: T): T
    func identity(): T
}

/// LazyMonoid: Monoid extended with lazy propagation.
///   apply(apply(v, l1), l2) == apply(v, mergeLazy(l1, l2))
///   apply(v, identityLazy()) == v
public interface LazyMonoid<T, L> {
    func combine(a: T, b: T): T
    func identity(): T
    func apply(value: T, lazy: L): T
    func mergeLazy(a: L, b: L): L
    func identityLazy(): L
}

open public class SegmentTree<T> {
    let n: Int64
    let size: Int64
    var data: Array<T>
    let monoid: Monoid<T>

    public init(n: Int64, monoid: Monoid<T>, builder: (Int64) -> T) {
        if (n <= 0) { throw Exception("SegmentTree: n must be > 0, got ${n}") }
        this.monoid = monoid
        this.n = n
        size = computeSize(n)
        data = Array<T>(2 * size, { _ => monoid.identity() })
        var i: Int64 = 0
        while (i < n) {
            data[i + size] = builder(i)
            i = i + 1
        }
        var p = size - 1
        while (p >= 1) {
            data[p] = monoid.combine(data[2 * p], data[2 * p + 1])
            p = p - 1
        }
    }

    public init(array: Array<T>, monoid: Monoid<T>) {
        let cnt = Int64(array.size)
        if (cnt <= 0) { throw Exception("SegmentTree: array must be non-empty") }
        this.monoid = monoid
        this.n = cnt
        size = computeSize(n)
        data = Array<T>(2 * size, { _ => monoid.identity() })
        var i: Int64 = 0
        while (i < n) {
            data[i + size] = array[i]
            i = i + 1
        }
        var p = size - 1
        while (p >= 1) {
            data[p] = monoid.combine(data[2 * p], data[2 * p + 1])
            p = p - 1
        }
    }

    private static func computeSize(n: Int64): Int64 {
        if (n <= 0) { throw Exception("computeSize: n must be > 0") }
        if (n > 4611686018427387904) { throw Exception("computeSize: n too large") }
        var s: Int64 = 1
        while (s < n) { s = s * 2 }
        return s
    }

    /// O(log n) point update. pos in [0, n).
    public func set(pos: Int64, value: T) {
        if (pos < 0 || pos >= n) {
            throw Exception("SegmentTree.set: pos ${pos} out of [0, ${n})")
        }
        var p = pos + size
        data[p] = value
        p = p >> 1
        while (p >= 1) {
            data[p] = monoid.combine(data[2 * p], data[2 * p + 1])
            p = p >> 1
        }
    }

    /// O(log n) point query. pos in [0, n).
    public func get(pos: Int64): T {
        if (pos < 0 || pos >= n) {
            throw Exception("SegmentTree.get: pos ${pos} out of [0, ${n})")
        }
        return data[pos + size]
    }

    /// O(log n) range query [l, r). Returns monoid.identity() if l >= r.
    public func query(l: Int64, r: Int64): T {
        if (l < 0 || r > n || l > r) {
            throw Exception("SegmentTree.query: invalid [${l}, ${r}) for n=${n}")
        }
        if (l >= r) { return monoid.identity() }
        var leftRes = monoid.identity()
        var rightRes = monoid.identity()
        var l2 = l + size
        var r2 = r + size
        while (l2 < r2) {
            if ((l2 & 1) == 1) {
                leftRes = monoid.combine(leftRes, data[l2])
                l2 = l2 + 1
            }
            if ((r2 & 1) == 1) {
                r2 = r2 - 1
                rightRes = monoid.combine(data[r2], rightRes)
            }
            l2 = l2 >> 1
            r2 = r2 >> 1
        }
        return monoid.combine(leftRes, rightRes)
    }
}

public class IterativeSegmentTree<T> <: SegmentTree<T> {
    public init(n: Int64, monoid: Monoid<T>, builder: (Int64) -> T) {
        super(n, monoid, builder)
    }
    public init(array: Array<T>, monoid: Monoid<T>) {
        super(array, monoid)
    }
}

public class IterativeLazySegmentTree<T, L> {
    let n: Int64
    let size: Int64
    let log: Int64
    var data: Array<T>
    var lazy: Array<L>
    let op: LazyMonoid<T, L>

    public init(n: Int64, op: LazyMonoid<T, L>, builder: (Int64) -> T) {
        if (n <= 0) { throw Exception("IterativeLazySegmentTree: n must be > 0, got ${n}") }
        this.op = op
        this.n = n
        let (sz, lg) = computeSizeLog(n)
        size = sz
        log = lg
        data = Array<T>(2 * size, { _ => op.identity() })
        lazy = Array<L>(size, { _ => op.identityLazy() })
        var i: Int64 = 0
        while (i < n) {
            data[i + size] = builder(i)
            i = i + 1
        }
        var p = size - 1
        while (p >= 1) {
            data[p] = op.combine(data[2 * p], data[2 * p + 1])
            p = p - 1
        }
    }

    public init(array: Array<T>, op: LazyMonoid<T, L>) {
        let cnt = Int64(array.size)
        if (cnt <= 0) { throw Exception("IterativeLazySegmentTree: array must be non-empty") }
        this.op = op
        this.n = cnt
        let (sz, lg) = computeSizeLog(n)
        size = sz
        log = lg
        data = Array<T>(2 * size, { _ => op.identity() })
        lazy = Array<L>(size, { _ => op.identityLazy() })
        var i: Int64 = 0
        while (i < n) {
            data[i + size] = array[i]
            i = i + 1
        }
        var p = size - 1
        while (p >= 1) {
            data[p] = op.combine(data[2 * p], data[2 * p + 1])
            p = p - 1
        }
    }

    private static func computeSizeLog(n: Int64): (Int64, Int64) {
        if (n <= 0) { throw Exception("computeSizeLog: n must be > 0") }
        if (n > 4611686018427387904) { throw Exception("computeSizeLog: n too large") }
        var s: Int64 = 1
        var l: Int64 = 0
        while (s < n) { s = s * 2; l = l + 1 }
        return (s, l)
    }

    private func push(k: Int64) {
        data[2 * k] = op.apply(data[2 * k], lazy[k])
        if (2 * k < size) {
            lazy[2 * k] = op.mergeLazy(lazy[2 * k], lazy[k])
        }
        data[2 * k + 1] = op.apply(data[2 * k + 1], lazy[k])
        if (2 * k + 1 < size) {
            lazy[2 * k + 1] = op.mergeLazy(lazy[2 * k + 1], lazy[k])
        }
        lazy[k] = op.identityLazy()
    }

    private func pushFrom(node: Int64) {
        var depth = log
        while (depth >= 1) {
            let k = node >> depth
            if (k >= 1 && k < size) {
                push(k)
            }
            depth = depth - 1
        }
    }

    private func updateAncestors(node: Int64) {
        var p = node >> 1
        while (p >= 1) {
            data[p] = op.combine(data[2 * p], data[2 * p + 1])
            p = p >> 1
        }
    }

    /// O(log n) range update [l, r).
    public func rangeUpdate(l: Int64, r: Int64, value: L) {
        if (l < 0 || r > n || l > r) {
            throw Exception("rangeUpdate: invalid [${l}, ${r}) for n=${n}")
        }
        if (l >= r) { return }
        pushFrom(l + size)
        pushFrom(r + size)
        var l2 = l + size
        var r2 = r + size
        while (l2 < r2) {
            if ((l2 & 1) == 1) {
                data[l2] = op.apply(data[l2], value)
                if (l2 < size) {
                    lazy[l2] = op.mergeLazy(lazy[l2], value)
                }
                l2 = l2 + 1
            }
            if ((r2 & 1) == 1) {
                r2 = r2 - 1
                data[r2] = op.apply(data[r2], value)
                if (r2 < size) {
                    lazy[r2] = op.mergeLazy(lazy[r2], value)
                }
            }
            l2 = l2 >> 1
            r2 = r2 >> 1
        }
        updateAncestors(l + size)
        updateAncestors(r + size - 1)
    }

    /// O(log n) range query [l, r).
    public func query(l: Int64, r: Int64): T {
        if (l < 0 || r > n || l > r) {
            throw Exception("query: invalid [${l}, ${r}) for n=${n}")
        }
        if (l >= r) { return op.identity() }
        pushFrom(l + size)
        pushFrom(r + size)
        var l2 = l + size
        var r2 = r + size
        var leftRes = op.identity()
        var rightRes = op.identity()
        while (l2 < r2) {
            if ((l2 & 1) == 1) {
                leftRes = op.combine(leftRes, data[l2])
                l2 = l2 + 1
            }
            if ((r2 & 1) == 1) {
                r2 = r2 - 1
                rightRes = op.combine(data[r2], rightRes)
            }
            l2 = l2 >> 1
            r2 = r2 >> 1
        }
        return op.combine(leftRes, rightRes)
    }

    /// O(log n) point update.
    public func set(pos: Int64, value: T) {
        if (pos < 0 || pos >= n) {
            throw Exception("IterativeLazySegmentTree.set: pos ${pos} out of [0, ${n})")
        }
        let node = pos + size
        pushFrom(node)
        data[node] = value
        updateAncestors(node)
    }

    /// O(log n) point query.
    public func get(pos: Int64): T {
        if (pos < 0 || pos >= n) {
            throw Exception("IterativeLazySegmentTree.get: pos ${pos} out of [0, ${n})")
        }
        let node = pos + size
        pushFrom(node)
        return data[node]
    }
}