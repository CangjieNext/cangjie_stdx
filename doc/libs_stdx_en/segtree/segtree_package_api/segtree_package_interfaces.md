# Interfaces

## interface Monoid

```cangjie
public interface Monoid<T> {
    func combine(a: T, b: T): T
    func identity(): T
}
```

Function: describes the merge operation and the identity element of the tree. As long as `combine`
is associative and `identity()` is neutral for it, `SegmentTree` works with that type.

Constraints:

- Associativity: `combine(combine(a, b), c) == combine(a, combine(b, c))`
- Identity: `combine(identity(), a) == a` and `combine(a, identity()) == a`

### func combine(T, T)

```cangjie
func combine(a: T, b: T): T
```

Function: merges two range results into one.

Parameters:

- a: T - left operand.
- b: T - right operand.

Returns: the merged result. During a query the left partial result is always passed as the first
argument, so non-commutative operations (matrix product, string concatenation) stay correct.

### func identity()

```cangjie
func identity(): T
```

Function: returns the identity element, which is also the result of an empty query (`l >= r`).

Returns: the identity element.

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

Function: extends `Monoid` with the semantics of lazy tags, used by `IterativeLazySegmentTree`.

Constraints:

- `combine` and `identity` follow the `Monoid` constraints;
- `apply(v, identityLazy()) == v`;
- applying `l1` then `l2` equals applying `mergeLazy(l1, l2)`.

### func apply(T, L)

```cangjie
func apply(value: T, lazy: L): T
```

Function: applies the tag `lazy` to the range result `value`.

Parameters:

- value: T - the range result to update.
- lazy: L - the tag to apply.

Returns: the updated range result.

### func mergeLazy(L, L)

```cangjie
func mergeLazy(a: L, b: L): L
```

Function: composes two tags. `b` is applied after `a`.

Parameters:

- a: L - the tag already stored on the node.
- b: L - the newly arrived tag.

Returns: the composed tag.

### func identityLazy()

```cangjie
func identityLazy(): L
```

Function: returns the neutral tag, used to initialise the `lazy` array and to clear a node.

Returns: the neutral tag.
