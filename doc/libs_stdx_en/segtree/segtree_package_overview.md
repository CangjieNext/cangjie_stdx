# stdx.segtree

## Feature Description

The segtree package provides iterative (non-recursive) segment trees that answer range queries and
perform range updates in O(log n).

The tree does not assume anything about the element type: the merge semantics are supplied by the
caller through `Monoid` (point update + range query) or `LazyMonoid` (range update + range query),
so the same structure covers range sum, range minimum/maximum, maximum subarray, matrix products
and any other associative operation.

Two implementations are provided:

1. `SegmentTree<T>` — point update and range query. The leaves are padded to a power of two and the
   whole tree lives in one array of `2 * size` elements (`data[0]` is unused). Both update and query
   walk the array with shifts instead of recursion, which keeps the constant small and avoids
   stack-overflow on deep recursions.

2. `IterativeLazySegmentTree<T, L>` — range update and range query. A second `lazy` array stores the
   pending tags on the nodes that fully cover the updated range; the tags are pushed down only when
   the node is visited later.

All indices are 0-based and all ranges are half-open `[l, r)`. Out-of-range arguments throw an
`Exception` instead of being silently clamped, so mistakes surface at the call site.

## API List

### Interfaces

| Interface | Description |
| --- | --- |
| [Monoid](./segtree_package_api/segtree_package_interfaces.md#interface-monoid) | Merge operation and identity element of the tree. |
| [LazyMonoid](./segtree_package_api/segtree_package_interfaces.md#interface-lazymonoid) | Monoid extended with lazy tag application and composition. |

### Classes

| Class | Description |
| --- | --- |
| [SegmentTree](./segtree_package_api/segtree_package_classes.md#class-segmenttree) | Iterative segment tree with point update and range query. |
| [IterativeSegmentTree](./segtree_package_api/segtree_package_classes.md#class-iterativesegmenttree) | Alias of the iterative SegmentTree implementation. |
| [IterativeLazySegmentTree](./segtree_package_api/segtree_package_classes.md#class-iterativelazysegmenttree) | Iterative segment tree with lazy propagation. |

## Complexity

| Operation | Time | Space |
| --- | --- | --- |
| Construction | O(n) | O(n) |
| `set` / `get` | O(log n) | O(1) |
| `query` | O(log n) | O(1) |
| `rangeUpdate` (lazy) | O(log n) | O(1) |

## Example

```cangjie
package demo

import stdx.segtree.*

class SumInt <: Monoid<Int64> {
    public func combine(a: Int64, b: Int64): Int64 { a + b }
    public func identity(): Int64 { 0 }
}

main() {
    let tree = SegmentTree<Int64>([1, 2, 3, 4, 5], SumInt())
    println(tree.query(1, 4)) // 9
    tree.set(2, 10)
    println(tree.query(0, 5)) // 22
}
```

See the [sample](./segtree_samples/segtree_sample.md) for more usage.
