# Classes

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

Function: iterative segment tree with point update and range query. The leaves are padded to a power
of two and the tree is stored in an array of `2 * size` elements; no operation recurses.

### init(Int64, Monoid\<T>, (Int64) -> T)

```cangjie
public init(n: Int64, monoid: Monoid<T>, builder: (Int64) -> T)
```

Function: builds a tree of length `n` whose `i`-th element is produced by `builder(i)`.

Parameters:

- n: Int64 - number of elements, must be greater than 0.
- monoid: Monoid\<T> - merge semantics.
- builder: (Int64) -> T - produces the initial element at a position.

Exceptions:

- Exception - thrown when `n <= 0` or `n` exceeds `2^62`.

### init(Array\<T>, Monoid\<T>)

```cangjie
public init(array: Array<T>, monoid: Monoid<T>)
```

Function: builds a tree from an existing array; indices match the array.

Parameters:

- array: Array\<T> - the initial elements, must not be empty.
- monoid: Monoid\<T> - merge semantics.

Exceptions:

- Exception - thrown when `array` is empty or longer than `2^62`.

### func set(Int64, T)

```cangjie
public func set(pos: Int64, value: T): Unit
```

Function: replaces the element at `pos` and rebuilds the affected nodes bottom-up. O(log n).

Parameters:

- pos: Int64 - index in `[0, n)`.
- value: T - the new element.

Exceptions:

- Exception - thrown when `pos` is out of range.

### func get(Int64)

```cangjie
public func get(pos: Int64): T
```

Function: reads the element at `pos`. O(1).

Parameters:

- pos: Int64 - index in `[0, n)`.

Returns: the element at that position.

Exceptions:

- Exception - thrown when `pos` is out of range.

### func query(Int64, Int64)

```cangjie
public func query(l: Int64, r: Int64): T
```

Function: returns the merge result of the half-open range `[l, r)`. O(log n). The two partial
results are merged as `combine(left, right)`, which keeps non-commutative operations correct.

Parameters:

- l: Int64 - inclusive left endpoint in `[0, n]`.
- r: Int64 - exclusive right endpoint in `[0, n]`.

Returns: the merged result, or `monoid.identity()` when `l >= r`.

Exceptions:

- Exception - thrown when `l < 0`, `r > n` or `l > r`.

## class IterativeSegmentTree

```cangjie
public class IterativeSegmentTree<T> <: SegmentTree<T> {
    public init(n: Int64, monoid: Monoid<T>, builder: (Int64) -> T)
    public init(array: Array<T>, monoid: Monoid<T>)
}
```

Function: alias of the iterative `SegmentTree` implementation. Behaviour, parameters and exceptions
are identical to `SegmentTree`.

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

Function: iterative segment tree with lazy propagation, supporting range update and range query.
A range update only stores a tag on the covered nodes; the tag is pushed down when the node is
visited later, so a single range update is O(log n).

### init(Int64, LazyMonoid\<T, L>, (Int64) -> T)

```cangjie
public init(n: Int64, op: LazyMonoid<T, L>, builder: (Int64) -> T)
```

Function: builds a lazy tree of length `n` whose `i`-th element is produced by `builder(i)`.

Parameters:

- n: Int64 - number of elements, must be greater than 0.
- op: LazyMonoid\<T, L> - merge and tag semantics.
- builder: (Int64) -> T - produces the initial element at a position.

Exceptions:

- Exception - thrown when `n <= 0` or `n` exceeds `2^62`.

### init(Array\<T>, LazyMonoid\<T, L>)

```cangjie
public init(array: Array<T>, op: LazyMonoid<T, L>)
```

Function: builds a lazy tree from an existing array.

Parameters:

- array: Array\<T> - the initial elements, must not be empty.
- op: LazyMonoid\<T, L> - merge and tag semantics.

Exceptions:

- Exception - thrown when `array` is empty or longer than `2^62`.

### func rangeUpdate(Int64, Int64, L)

```cangjie
public func rangeUpdate(l: Int64, r: Int64, value: L): Unit
```

Function: applies the tag `value` to the half-open range `[l, r)`. O(log n).

Parameters:

- l: Int64 - inclusive left endpoint.
- r: Int64 - exclusive right endpoint.
- value: L - the tag to apply.

Exceptions:

- Exception - thrown when `l < 0`, `r > n` or `l > r`.

### func query(Int64, Int64)

```cangjie
public func query(l: Int64, r: Int64): T
```

Function: returns the merge result of the half-open range `[l, r)`, pushing the pending tags on the
boundary paths first. O(log n).

Parameters:

- l: Int64 - inclusive left endpoint.
- r: Int64 - exclusive right endpoint.

Returns: the merged result, or `op.identity()` when `l >= r`.

Exceptions:

- Exception - thrown when `l < 0`, `r > n` or `l > r`.

### func set(Int64, T)

```cangjie
public func set(pos: Int64, value: T): Unit
```

Function: replaces the element at `pos` after pushing the tags on its path, then rebuilds the
ancestors. O(log n).

Parameters:

- pos: Int64 - index in `[0, n)`.
- value: T - the new element.

Exceptions:

- Exception - thrown when `pos` is out of range.

### func get(Int64)

```cangjie
public func get(pos: Int64): T
```

Function: reads the element at `pos`, pushing the tags on its path first.

Parameters:

- pos: Int64 - index in `[0, n)`.

Returns: the element at that position.

Exceptions:

- Exception - thrown when `pos` is out of range.
