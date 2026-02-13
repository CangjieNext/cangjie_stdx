package testPackage

struct Struct_00 {}

struct Struct_01 {
    public var x: Int64 = 10
    var y: String = "Hello" 
}


struct Struct_02 {
    let a: Int64
    var b: Float64

    public init(a: Int64, b: Float64) {
        this.a = a
        this.b = b
    }

    init(a: Int64) {
        this.a = a
        this.b = 0.0
    }
}


struct Struct_03 {
    public var a: Int64 = 1
    private var b: Int64 = 2
    
    static public var c: Int32 = 100
    static let d: Int32 = 200

    public static func staticFunc(): String {
        "Static"
    }
}


struct Struct_04 {
    var count: Int64 = 0

    public func getCount(): Int64 {
        return this.count
    }

    public mut func increment() {
        this.count = this.count + 1
    }

    private func internalHelper(): Unit {}
}


struct Struct_05<T> {
    var content: T
    
    init(val: T) {
        this.content = val
    }

    func getVal(): T{
        content
    }
}


struct Struct_06<K, V> where K <: Hashable {
    let key: K
    var val: V
    
    init(k: K, v: V) {
        this.key = k
        this.val = v
    }
}


struct Struct_07 <: IPrintable {
    public func printInfo(): Unit {
        println("Struct")
    }
}


struct Struct_08 {
    var x: Int64
    var y: Int64

    init(x: Int64, y: Int64) {
        this.x = x
        this.y = y
    }

    public operator func +(right: Struct_08): Struct_08 {
        return Struct_08(this.x + right.x, this.y + right.y)
    }
}

interface IPrintable {
    func printInfo(): Unit
}