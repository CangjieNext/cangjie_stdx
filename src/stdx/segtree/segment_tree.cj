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
 *
 * All public methods use semi-open intervals:
 *   - Indices are in [0, n)
 *   - Range query/update use [l, r) where 0 <= l <= r <= n
 *   - Invalid inputs (out-of-bounds pos, l > r, etc.) throw at runtime.
 */

package stdx.segtree

/// Monoid: associative binary operation with identity.
///
/// Required laws:
///   combine(a, combine(b, c)) == combine(combine(a, b), c)  (associativity)
///   combine(identity(), a) == combine(a, identity()) == a   (identity)
public interface Monoid<T> {
    /// Associative binary operation.
    public func combine(left: T, right: T): T
    /// Identity element satisfying combine(identity(), a) == a.
    public func identity(): T
}

/// LazyMonoid: monoid extended with lazy propagation for range updates.
///
/// Additional laws beyond Monoid:
///   lazyApply(lazyApply(v, l1), l2) == lazyApply(v, lazyCompose(l1, l2))
///   lazyApply(v, lazyIdentity()) == v
public interface LazyMonoid<T, L> <: Monoid<T> {
    /// Apply a lazy marker to a value.
    public func lazyApply(value: T, lazy: L): T
    /// Compose two lazy markers (parent outer, child inner).
    public func lazyCompose(parent: L, child: L): L
    /// Identity lazy marker: lazyApply(v, lazyIdentity()) == v.
    public func lazyIdentity(): L
}

/// Iterative segment tree supporting point update and range query.
///
/// All indices use 0-based [0, n) convention.
/// Range query uses semi-open [l, r), i.e., elements at positions l, l+1, ..., r-1.
///
/// Complexity: O(log n) for both set/get/query.
/// Memory: O(n) (2 * nextPowerOfTwo(n) nodes).
public class SegmentTree<T> {
    private let n: Int64
    private let size: Int64
    private var data: Array<T>
    private let monoid: Monoid<T>

    /// Build from a size + builder closure.
    ///
    /// - Parameter n: number of elements (must be >= 1, <= 2^62).
    /// - Parameter monoid: the monoid operations.
    /// - Parameter builder: called for each index in [0, n) to produce initial values.
    public init(n: Int64, monoid: Monoid<T>, builder: (Int64) -> T) {
        assert(n > 0, "stdx.segtree.SegmentTree: n must be > 0, got \(n)")
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

    /// Build from an existing array.
    ///
    /// - Parameter array: initial values; length must be >= 1.
    /// - Parameter monoid: the monoid operations.
    public init(array: Array<T>, monoid: Monoid<T>) {
        let count = Int64(array.size)
        assert(count > 0, "stdx.segtree.SegmentTree: array must be non-empty")
        self.monoid = monoid
        self.n = count
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

    /// Compute smallest power of two >= n, with overflow guard for n near Int64 max.
    private static func computeSize(n: Int64): Int64 {
        assert(n > 0, "computeSize: n must be > 0")
        assert(n <= 4611686018427387904, "computeSize: n too large, would overflow") // 2^62
        var s: Int64 = 1
        while (s < n) { s = s * 2 }
        return s
    }

    /// O(log n): point update.
    ///
    /// - Parameter pos: index in [0, n).
    /// - Parameter value: new value.
    public func set(pos: Int64, value: T): Unit {
        assert(pos >= 0 && pos < n, "SegmentTree.set: pos \(pos) out of range [0, \(n))")
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
    ///
    /// - Parameter pos: index in [0, n).
    /// - Returns: value at pos.
    public func get(pos: Int64): T {
        assert(pos >= 0 && pos < n, "SegmentTree.get: pos \(pos) out of range [0, \(n))")
        return data[pos + size]
    }

    /// O(log n): range query on semi-open interval [l, r).
    ///
    /// - Parameters:
    ///   - l: left bound (inclusive), in [0, n].
    ///   - r: right bound (exclusive), in [l, n].
    /// - Returns: combined result. Returns monoid.identity() if l >= r.
    public func query(l: Int64, r: Int64): T {
        assert(l >= 0 && r <= n, "SegmentTree.query: bounds out of range [0, \(n)]")
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

/// Alias for SegmentTree<T> kept for AtCoder Library API parity.
public class IterativeSegmentTree<T> <: SegmentTree<T> {
    public init(n: Int64, monoid: Monoid<T>, builder: (Int64) -> T) {
        super(n: n, monoid: monoid, builder: builder)
    }
    public init(array: Array<T>, monoid: Monoid<T>) {
        super(array: array, monoid: monoid)
    }
}

/// Iterative lazy segment tree supporting range update and range query.
///
/// Uses lazy propagation: updates are deferred to O(log n) by carrying markers
/// on tree nodes and pushing them down on demand.
///
/// All indices use 0-based [0, n) convention.
/// Range operations use semi-open [l, r).
///
/// Complexity: O(log n) for rangeUpdate / query / set / get.
public class IterativeLazySegmentTree<T, L> {
    private let n: Int64
    private let size: Int64
    private let log: Int64
    private var data: Array<T>
    private var lazy: Array<L>
    private let op: LazyMonoid<T, L>

    /// Build from size + builder closure.
    ///
    /// - Parameter n: number of elements (must be >= 1, <= 2^62).
    /// - Parameter op: lazy monoid operations.
    /// - Parameter builder: called for each index in [0, n) to produce initial values.
    public init(n: Int64, op: LazyMonoid<T, L>, builder: (Int64) -> T) {
        assert(n > 0, "IterativeLazySegmentTree: n must be > 0, got \(n)")
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

    /// Build from an existing array.
    ///
    /// - Parameter array: initial values; length must be >= 1.
    /// - Parameter op: lazy monoid operations.
    public init(array: Array<T>, op: LazyMonoid<T, L>) {
        let count = Int64(array.size)
        assert(count > 0, "IterativeLazySegmentTree: array must be non-empty")
        self.op = op
        self.n = count
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

    /// Compute (size, log2(size)) pair with overflow guard.
    private static func computeSizeLog(n: Int64): (Int64, Int64) {
        assert(n > 0, "computeSizeLog: n must be > 0")
        assert(n <= 4611686018427387904, "computeSizeLog: n too large, would overflow") // 2^62
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

    private func pushFrom(node: Int64): Unit {
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

    /// O(log n): range update on semi-open interval [l, r).
    ///
    /// - Parameters:
    ///   - l: left bound (inclusive), in [0, n].
    ///   - r: right bound (exclusive), in [l, n].
    ///   - value: lazy marker to apply.
    public func rangeUpdate(l: Int64, r: Int64, value: L): Unit {
        assert(l >= 0 && r <= n && l <= r, "rangeUpdate: invalid bounds [\(l), \(r)) for n=\(n)")
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

    /// O(log n): range query on semi-open interval [l, r).
    ///
    /// - Parameters:
    ///   - l: left bound (inclusive), in [0, n].
    ///   - r: right bound (exclusive), in [l, n].
    /// - Returns: combined result. Returns op.identity() if l >= r.
    public func query(l: Int64, r: Int64): T {
        assert(l >= 0 && r <= n, "query: invalid bounds [\(l), \(r)) for n=\(n)")
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

    /// O(log n): point update.
    ///
    /// - Parameter pos: index in [0, n).
    /// - Parameter value: new value.
    public func set(pos: Int64, value: T): Unit {
        assert(pos >= 0 && pos < n, "IterativeLazySegmentTree.set: pos \(pos) out of range [0, \(n))")
        let node = pos + size
        pushFrom(node)
        data[node] = value
        updateAncestors(node)
    }

    /// O(log n): point query.
    ///
    /// - Parameter pos: index in [0, n).
    /// - Returns: value at pos.
    public func get(pos: Int64): T {
        assert(pos >= 0 && pos < n, "IterativeLazySegmentTree.get: pos \(pos) out of range [0, \(n))")
        let node = pos + size
        pushFrom(node)
        return data[node]
    }
}