# stdx.segtree

## 功能介绍

segtree 包提供迭代式（非递归）线段树实现，用于在 O(log n) 时间内完成区间查询与区间更新。

线段树本身不假设元素类型，元素的合并语义由调用方通过 `Monoid`（区间查询）或 `LazyMonoid`
（区间更新 + 区间查询）接口给出，因此同一个数据结构可以用于求和、求最值、求最大子段和、
矩阵连乘等任意满足结合律的问题。

本包提供两个实现：

1. `SegmentTree<T>`：点更新 + 区间查询。叶子数量补齐到 2 的幂后，用一棵大小为 `2 * size`
   的数组存放整棵树，`data[0]` 不使用。点更新与区间查询都不需要递归，只需要顺着下标做移位，
   常数小于递归实现，也不会因为递归深度导致栈溢出。

2. `IterativeLazySegmentTree<T, L>`：区间更新 + 区间查询。在 `SegmentTree` 的基础上增加一个
   `lazy` 数组，区间更新时把「待下推的标记」暂存在节点上，访问到该节点时再下推给子节点。

所有下标从 0 开始，区间使用左闭右开 `[l, r)`。参数越界时抛出 `Exception`，不做静默截断，
避免错误被掩盖到后续计算中。

## API 列表

### 接口

| 接口名 | 功能 |
| --- | --- |
| [Monoid](./segtree_package_api/segtree_package_interfaces.md#interface-monoid) | 定义线段树元素的合并操作与单位元。 |
| [LazyMonoid](./segtree_package_api/segtree_package_interfaces.md#interface-lazymonoid) | 在 Monoid 基础上增加惰性标记的下推与合并操作。 |

### 类

| 类名 | 功能 |
| --- | --- |
| [SegmentTree](./segtree_package_api/segtree_package_classes.md#class-segmenttree) | 迭代式线段树，支持点更新与区间查询。 |
| [IterativeSegmentTree](./segtree_package_api/segtree_package_classes.md#class-iterativesegmenttree) | SegmentTree 的迭代实现别名。 |
| [IterativeLazySegmentTree](./segtree_package_api/segtree_package_classes.md#class-iterativelazysegmenttree) | 带惰性标记的迭代式线段树，支持区间更新与区间查询。 |

## 复杂度

| 操作 | 时间复杂度 | 空间复杂度 |
| --- | --- | --- |
| 构造 | O(n) | O(n) |
| `set` / `get` | O(log n) | O(1) |
| `query` | O(log n) | O(1) |
| `rangeUpdate`（惰性） | O(log n) | O(1) |

## 示例

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

更多用法见[示例教程](./segtree_samples/segtree_sample.md)。
