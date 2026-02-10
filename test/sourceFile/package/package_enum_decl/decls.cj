package testPackage


enum A {
    | X | Y | Z
}

enum B {
    | P(UInt8) | Q(UInt8) | R(UInt8)
}

enum C {
    | M | M(UInt8) | N | N(UInt8)
}

enum D {
    | V(Int64) | A(D,D) | S(D,D) | M(D,D)
}

enum E<T> {
    | V(T) | E
}

enum F {
    | O(?Int64) | F((Int64)->Int64) | N(B)
}

public enum G {
    | W | B
    func i(): String { return "pub" }
}

enum H {
    | A
}

interface I<X, Y> { }

class J<Z> <: I<Z, Z> { }

public enum k<T, E> {

    Ok(T)

    | Err(E)

    public func unwrap(): T {
        match (this) {
            case Ok(v) => v
            case Err(e) => throw e
        }
    }

    public func isOk(): Bool {
        match (this) {
            case Ok(_) => true
            case Err(_) => false
        }
    }

    public func isErr(): Bool {
        match (this) {
            case Ok(_) => false
            case Err(_) => true
        }
    }
}
