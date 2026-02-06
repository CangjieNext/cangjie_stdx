class A <: D {
    let a: Int64 = 0
}

struct B {
    let a: Int64 = 0
}

enum C { C0 | C1 }

interface D {
}

main() {
    let aA = A()
    let aB = B()
    let aC = C.C0
    let aD: D = A()
}