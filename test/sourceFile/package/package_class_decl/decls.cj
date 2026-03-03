package testPackage

class Class_00 {}

class Class_01 {
    public var x: Int64 = 10
    var y: String = "Hello" 
}


class Class_02 {
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

class Class_03 {
    public Class_03(let a: Int64,let b: Int32) {}
}

class Class_04 {
    public var a: Int64 = 1
    private var b: Int64 = 2
    
    static public var c: Int32 = 100
    static let d: Int32 = 200

    public static func staticFunc(): String {
        "Static"
    }
}


class Class_05 {
    var count: Int64 = 0

    public func getCount(): Int64 {
        return this.count
    }

    public func increment() {
        this.count = this.count + 1
    }

    private func internalHelper(): Unit {}
}


class Class_06<T> {
    var content: T
    
    init(val: T) {
        this.content = val
    }

    func getVal(): T{
        this.content
    }
}

open class Class_07<K, V> where K <: ToString {
    let key: K
    var val: V

    private let a_: Int32 = 1
    protected var b_: Float64 = 2.0

    init(k: K, v: V) {
        this.key = k
        this.val = v
    }

    public prop a: Int32{
        get() {
            this.a_
        }
    }
    public mut prop b: Float64{
        get() {
            this.b_
        }
        set(value) {
            this.b_ = value
        }
    }

    public open func openfunc(input: Int64): Int64 {
        input
    }
    public static func staticfunc(input: Float64): Float64 {
        input
    }
    public func unopenfunc(input: Bool): Bool {
        input
    }
}

// class Class_08<K, V> {}

class Class_08<K, V> <: Class_07<K, V> where K <: ToString {
    init(k: K, v: V) {
        super(k, v)
    }
    public var c: String = "hello"
    public func myfoo() {}
    public override func openfunc(input: Int64): Int64 {
        input
    }
    public redef static func staticfunc(input: Float64): Float64 {
        input
    }
}

abstract class Class_09 {
    public func foo(a: Int32): Bool
}

class Class_10 <: Class_09 {
    public override func foo(a: Int32): Bool {
        return a > 0
    }

}

class Class_11 <: IPrintable {
    public func printInfo(): Unit {
        println("class")
    }
}


class Class_12 {
    var x: Int64
    var y: Int64

    init(x: Int64, y: Int64) {
        this.x = x
        this.y = y
    }

    public operator func +(right: Class_12): Class_12 {
        return Class_12(this.x + right.x, this.y + right.y)
    }
}

interface IPrintable {
    func printInfo(): Unit
}