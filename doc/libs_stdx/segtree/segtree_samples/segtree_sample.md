# 示例教程

## 区间求和与点更新

`SegmentTree` 只需要三个信息：长度、合并语义（`Monoid`）、初始值。下面用求和作为合并语义。

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

区间是左闭右开的：`query(1, 4)` 覆盖下标 1、2、3。

## 区间最大值

把 `combine` 换成取较大值、`identity` 换成 `Int64.Min`，同一棵树就变成区间最大值查询。

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

`identity` 必须真的与 `combine` 相容：`Int64.Min` 与取最大值搭配才是单位元，
把求和用的 `0` 拿来当最大值的单位元，会让空区间返回 0 而不是「无最大值」。

## 区间加 + 区间最大值（惰性标记）

`IterativeLazySegmentTree` 用 `LazyMonoid` 描述标记如何作用、如何叠加。下面实现
「给一段区间整体加一个数，查询一段区间的最大值」。

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
    tree.rangeUpdate(1, 4, 10)   // 下标 1..3 各加 10
    println(tree.query(1, 4))    // 14
    println(tree.query(0, 5))    // 14
    tree.set(0, 100)
    println(tree.query(0, 2))    // 100
}
```

## 注意：标记接口不携带区间长度

`apply(value, lazy)` 只拿到「区间结果」和「标记」，拿不到该节点覆盖了多少个元素。
因此凡是标记的效果与区间长度相关的语义（例如「区间加 + 区间求和」，节点值需要加上
`lazy * 区间长度`），不能直接用本包的 `LazyMonoid`，需要在合并语义里自行携带长度信息，
或改用不带惰性标记的 `SegmentTree` 配合点更新实现。
