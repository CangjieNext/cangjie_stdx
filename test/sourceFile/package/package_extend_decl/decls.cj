package testPackage

class A {}
class B {}
class C {}
class D<X, Y> {}
class ToStringImpl { public func toString(): String { return "impl" } }
interface Foo { func printValue(a: Int64): Unit }

extend A {
    public func newHello(): Unit {
        println("A extended")
    }
}

extend B {
    public prop doubleB: Int64 {
        get() { 100 }
    }
    public operator func +(other: B): Int64 {
        return this.doubleB + other.doubleB
    }
}

extend C <: Foo {
    public func printValue(a: Int64) {
        println("C value: ${a}")
    }
}

extend D<Int64, ToStringImpl> {
    public func foo(): String {
        return this.second.toString()
    }
}
