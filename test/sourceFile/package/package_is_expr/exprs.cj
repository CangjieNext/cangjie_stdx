enum Tree<T> {
    | Leaf(T)
    | Node(Tree<T>, Tree<T>)
}

func test(a:Int64,b:Int64): Unit {
    b is Int64
    a is String
    a is Tree<Int64>
    (a as String).getOrThrow() is String
}