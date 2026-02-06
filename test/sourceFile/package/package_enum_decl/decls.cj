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