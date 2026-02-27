package testPackage

struct Box<T> {
    var v: T

    public init(v: T) {
        this.v = v
    }
}

main(): Int64 {
    let b = Box<Int64>(1)
    return 0
}
