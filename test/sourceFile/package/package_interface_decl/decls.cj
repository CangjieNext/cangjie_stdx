package testPackage

interface Interface_00 {}

interface Interface_01 {
    func foo(): Unit
    func bar(a: Int64): String
}

interface Interface_02 {
    prop size: Int64

    prop name: String
}

interface Interface_03 {
    func requiredFunc(): Int64

    func defaultFunc(): String {
        return "Default Implementation"
    }
}

interface Interface_04 {
    static func create(): Interface_04

    static func logInfo(): Unit {
        println("static func")
    }
}


interface Interface_05 {
    operator func +(rhs: Interface_05): Interface_05
    
    operator func [](index: Int64): String
    
    operator func [](index: Int64, value: String): Unit
}

interface Interface_06 <: Interface_01 {
    func extra(): Int64
}


interface Interface_07 <: Interface_01 & Interface_02 {
    func compositeFunc(): Bool
}

interface Interface_08<T> {
    func get(): T
    func set(item: T): Unit
}


interface Interface_09<T> where T <: Interface_02 {
    func format(item: T): String
}

interface Interface_10 {
    func convert<R>(input: R): Int64
}

interface Interface_11 {
    func readonlyOp(): Int64

    mut func mutatingOp(delta: Int64): Unit
}

interface Interface_12 {
    func tupleFunc(): (Int64, String)
    
    func optionFunc(): ?Int64
}