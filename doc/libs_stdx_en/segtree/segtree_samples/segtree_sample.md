# Sample

## Range sum with point update

`SegmentTree` only needs three things: the length, the merge semantics (`Monoid`) and the initial
values. The example below merges with sum.

```cangjie
package segtree_sample

import stdx.segtree.*

class SumInt <: Monoid<Int64> {
    public func combine(a: Int64, b: Int64): Int64 { a + b }
    public func identity(): Int64 { 0 }
}

main() {
    let tree = SegmentTree<Int64>([1, 2, 3, 4, 5], SumInt())
    println(tree.query(1, 4)) // 2 + 3 + 4 = 9
    tree.set(2, 10)
    println(tree.query(0, 5)) // 1 + 2 + 10 + 4 + 5 = 22
    println(tree.get(2))      // 10
}
```

Ranges are half-open: `query(1, 4)` covers indices 1, 2 and 3.

## Range maximum

Replacing `combine` with "take the larger one" and `identity` with `Int64.Min` turns the same tree
into a range-maximum query.

```cangjie
class MaxInt <: Monoid<Int64> {
    public func combine(a: Int64, b: Int64): Int64 { if (a >= b) { a } else { b } }
    public func identity(): Int64 { Int64.Min }
}

main() {
    let tree = SegmentTree<Int64>([3, 1, 4, 1, 5], MaxInt())
    println(tree.query(0, 3)) // 4
    println(tree.query(3, 5)) // 5
}
```

`identity` must really be neutral for `combine`. `Int64.Min` is the identity of "max"; reusing the
`0` of the sum example would make an empty query return 0 instead of "no maximum".

## Range add with range maximum (lazy)

`IterativeLazySegmentTree` uses `LazyMonoid` to describe how a tag applies and how tags compose.
The example adds a constant to a range and queries the maximum of a range.

```cangjie
class AddMax <: LazyMonoid<Int64, Int64> {
    public func combine(a: Int64, b: Int64): Int64 { if (a >= b) { a } else { b } }
    public func identity(): Int64 { Int64.Min }
    public func apply(value: Int64, lazy: Int64): Int64 { value + lazy }
    public func mergeLazy(a: Int64, b: Int64): Int64 { a + b }
    public func identityLazy(): Int64 { 0 }
}

main() {
    let tree = IterativeLazySegmentTree<Int64, Int64>([1, 2, 3, 4, 5], AddMax())
    tree.rangeUpdate(1, 4, 10)   // add 10 to indices 1..3
    println(tree.query(1, 4))    // 14
    println(tree.query(0, 5))    // 14
    tree.set(0, 100)
    println(tree.query(0, 2))    // 100
}
```

## Note: the tag interface does not carry the segment length

`apply(value, lazy)` only receives the range result and the tag; it does not know how many elements
the node covers. Semantics whose effect depends on the length — for example range add with range
sum, where a node value must grow by `lazy * length` — therefore need the length to be carried
inside the aggregate itself, or a plain `SegmentTree` with point updates.
