# 类

## class SegmentTree

```cangjie
open public class SegmentTree<T> {
    public init(n: Int64, monoid: Monoid<T>, builder: (Int64) -> T)
    public init(array: Array<T>, monoid: Monoid<T>)
    public func set(pos: Int64, value: T): Unit
    public func get(pos: Int64): T
    public func query(l: Int64, r: Int64): T
}
```

功能：迭代式线段树，支持点更新与区间查询。内部把叶子数量补齐到 2 的整数次幂，
用大小为 `2 * size` 的数组存放整棵树，所有操作都不递归。

### init(Int64, Monoid\<T>, (Int64) -> T)

```cangjie
public init(n: Int64, monoid: Monoid<T>, builder: (Int64) -> T)
```

功能：构造一棵长度为 `n` 的线段树，第 `i` 个位置的初始值由 `builder(i)` 给出。

参数：

- n: Int64 - 元素个数，必须大于 0。
- monoid: Monoid\<T> - 合并语义。
- builder: (Int64) -> T - 按位置生成初始元素。

异常：

- Exception - 当 `n <= 0` 或 `n` 超过 `2^62` 时抛出。

### init(Array\<T>, Monoid\<T>)

```cangjie
public init(array: Array<T>, monoid: Monoid<T>)
```

功能：用已有数组构造线段树，下标与原数组一致。

参数：

- array: Array\<T> - 初始元素，不能为空。
- monoid: Monoid\<T> - 合并语义。

异常：

- Exception - 当 `array` 为空或长度超过 `2^62` 时抛出。

### func set(Int64, T)

```cangjie
public func set(pos: Int64, value: T): Unit
```

功能：把下标 `pos` 处的元素改为 `value`，并自底向上更新受影响的节点。时间复杂度 O(log n)。

参数：

- pos: Int64 - 下标，范围 `[0, n)`。
- value: T - 新的元素值。

异常：

- Exception - 当 `pos` 越界时抛出。

### func get(Int64)

```cangjie
public func get(pos: Int64): T
```

功能：读取下标 `pos` 处的元素。时间复杂度 O(1)。

参数：

- pos: Int64 - 下标，范围 `[0, n)`。

返回值：该位置的元素。

异常：

- Exception - 当 `pos` 越界时抛出。

### func query(Int64, Int64)

```cangjie
public func query(l: Int64, r: Int64): T
```

功能：查询左闭右开区间 `[l, r)` 的合并结果。时间复杂度 O(log n)，两端的部分区间分别
从下往上合并，最后按「左结果在下、右结果在下」的顺序合并，保证非交换操作也正确。

参数：

- l: Int64 - 区间左端点（含），范围 `[0, n]`。
- r: Int64 - 区间右端点（不含），范围 `[0, n]`。

返回值：区间合并结果；当 `l >= r` 时返回 `monoid.identity()`。

异常：

- Exception - 当 `l < 0`、`r > n` 或 `l > r` 时抛出。

## class IterativeSegmentTree

```cangjie
public class IterativeSegmentTree<T> <: SegmentTree<T> {
    public init(n: Int64, monoid: Monoid<T>, builder: (Int64) -> T)
    public init(array: Array<T>, monoid: Monoid<T>)
}
```

功能：`SegmentTree` 的迭代实现别名，行为与 `SegmentTree` 完全一致，仅用于在代码中显式
表达「这里是迭代式线段树」。参数与异常同 `SegmentTree`。

## class IterativeLazySegmentTree

```cangjie
public class IterativeLazySegmentTree<T, L> {
    public init(n: Int64, op: LazyMonoid<T, L>, builder: (Int64) -> T)
    public init(array: Array<T>, op: LazyMonoid<T, L>)
    public func rangeUpdate(l: Int64, r: Int64, value: L): Unit
    public func query(l: Int64, r: Int64): T
    public func set(pos: Int64, value: T): Unit
    public func get(pos: Int64): T
}
```

功能：带惰性标记的迭代式线段树，支持区间更新与区间查询。区间更新时只在覆盖到的节点上
记录标记，真正下推发生在后续访问到该节点时，因此单次区间更新也是 O(log n)。

### init(Int64, LazyMonoid\<T, L>, (Int64) -> T)

```cangjie
public init(n: Int64, op: LazyMonoid<T, L>, builder: (Int64) -> T)
```

功能：构造长度为 `n` 的惰性线段树，第 `i` 个位置的初始值由 `builder(i)` 给出。

参数：

- n: Int64 - 元素个数，必须大于 0。
- op: LazyMonoid\<T, L> - 合并与标记语义。
- builder: (Int64) -> T - 按位置生成初始元素。

异常：

- Exception - 当 `n <= 0` 或 `n` 超过 `2^62` 时抛出。

### init(Array\<T>, LazyMonoid\<T, L>)

```cangjie
public init(array: Array<T>, op: LazyMonoid<T, L>)
```

功能：用已有数组构造惰性线段树。

参数：

- array: Array\<T> - 初始元素，不能为空。
- op: LazyMonoid\<T, L> - 合并与标记语义。

异常：

- Exception - 当 `array` 为空或长度超过 `2^62` 时抛出。

### func rangeUpdate(Int64, Int64, L)

```cangjie
public func rangeUpdate(l: Int64, r: Int64, value: L): Unit
```

功能：把标记 `value` 作用到左闭右开区间 `[l, r)` 上。时间复杂度 O(log n)。

参数：

- l: Int64 - 区间左端点（含）。
- r: Int64 - 区间右端点（不含）。
- value: L - 待作用的标记。

异常：

- Exception - 当 `l < 0`、`r > n` 或 `l > r` 时抛出。

### func query(Int64, Int64)

```cangjie
public func query(l: Int64, r: Int64): T
```

功能：查询左闭右开区间 `[l, r)` 的合并结果，查询前会先把路径上的标记下推。时间复杂度 O(log n)。

参数：

- l: Int64 - 区间左端点（含）。
- r: Int64 - 区间右端点（不含）。

返回值：区间合并结果；当 `l >= r` 时返回 `op.identity()`。

异常：

- Exception - 当 `l < 0`、`r > n` 或 `l > r` 时抛出。

### func set(Int64, T)

```cangjie
public func set(pos: Int64, value: T): Unit
```

功能：把下标 `pos` 处的元素改为 `value`，先把该位置路径上的标记下推，再自底向上更新。
时间复杂度 O(log n)。

参数：

- pos: Int64 - 下标，范围 `[0, n)`。
- value: T - 新的元素值。

异常：

- Exception - 当 `pos` 越界时抛出。

### func get(Int64)

```cangjie
public func get(pos: Int64): T
```

功能：读取下标 `pos` 处的元素，读取前先下推该位置路径上的标记。

参数：

- pos: Int64 - 下标，范围 `[0, n)`。

返回值：该位置的元素。

异常：

- Exception - 当 `pos` 越界时抛出。
