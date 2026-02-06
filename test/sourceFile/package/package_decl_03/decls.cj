package pkg3

public interface I {
    func foo(): Unit
}

public class A <: I {
    public func foo() {}
}

extend A {
    public func goo() {}
}

public class B {
    public init() {}
}

extend B <: I {
    public func foo() {}
}
