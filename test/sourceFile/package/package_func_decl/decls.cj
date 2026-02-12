package testPackage

func func_00() {}

func func_01(): Unit {}

func func_02(a: Int64): Int64 { a }

func func_03(a: Int64, b: Float64): Bool { true }

func func_04(s: String) {}

func func_05<T>(a: T): T { a }

func func_06<K, V>(key: K, value: V): K { key }

func func_07<K, V>(key: K, value: V) { value }

func func_08(x!: Int32 = 10): Int32 { x }

func func_09(): (Int64, Bool) { (1, true) }

func func_10() { (1, true) }

func func_11(): () -> Unit { { => } }

func func_12(x : Int16) : (Int16) -> Int16 { { y : Int16 => x + y } }

func func_13(x : Int16){ { y: Int16 => x + y } }

func func_14(x: Int64): ?Int64 { Some(x) }

func func_15(args: Array<String>): Unit {}

func func_16<T>(x: T): Array<T> { [x] }

open func func_17(a: Int64, b: Int64): Int64 { a + b }

abstract func func_18(a!: (Int32) -> Int16){
    let b = a(1)
    b
}

public func func_19(a!: (Int32) -> Int16) { a }