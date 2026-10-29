# 接口

## interface Monoid

```cangjie
public interface Monoid<T> {
    func combine(a: T, b: T): T
    func identity(): T
}
```

功能：定义线段树元素的合并操作与单位元。只要 `combine` 满足结合律、`identity()` 是单位元，
`SegmentTree` 就能用任意这样的类型做区间查询。

约束条件：

- 结合律：`combine(combine(a, b), c) == combine(a, combine(b, c))`
- 单位元：`combine(identity(), a) == a` 且 `combine(a, identity()) == a`

### func combine(T, T)

```cangjie
func combine(a: T, b: T): T
```

功能：把两个区间结果合并成一个。

参数：

- a: T - 左操作数。
- b: T - 右操作数。

返回值：合并后的结果。区间查询时，`combine` 的调用顺序保证左结果在左、右结果在右，
因此非交换的操作（如矩阵乘法、字符串拼接）同样正确。

### func identity()

```cangjie
func identity(): T
```

功能：返回区间查询的单位元。查询空区间 `query(l, r)`（`l >= r`）时返回该值。

返回值：单位元。

## interface LazyMonoid

```cangjie
public interface LazyMonoid<T, L> {
    func combine(a: T, b: T): T
    func identity(): T
    func apply(value: T, lazy: L): T
    func mergeLazy(a: L, b: L): L
    func identityLazy(): L
}
```

功能：在 `Monoid` 基础上增加惰性标记（lazy tag）的下推与合并语义，供
`IterativeLazySegmentTree` 使用。

约束条件：

- `combine`、`identity` 的约束同 `Monoid`；
- `apply(v, identityLazy()) == v`；
- 标记可合并：先作用 `l1` 再作用 `l2`，等价于作用 `mergeLazy(l1, l2)`。

### func apply(T, L)

```cangjie
func apply(value: T, lazy: L): T
```

功能：把标记 `lazy` 作用到区间结果 `value` 上，返回作用后的区间结果。

参数：

- value: T - 被作用的区间结果。
- lazy: L - 待下推的标记。

返回值：作用标记后的区间结果。

### func mergeLazy(L, L)

```cangjie
func mergeLazy(a: L, b: L): L
```

功能：把两个标记合并成一个。合并顺序为「先 `a` 后 `b`」，即新标记叠加在已有标记之上。

参数：

- a: L - 已有标记。
- b: L - 新到来的标记。

返回值：合并后的标记。

### func identityLazy()

```cangjie
func identityLazy(): L
```

功能：返回不产生任何影响的标记，用于初始化 `lazy` 数组和清空节点的标记。

返回值：单位标记。
