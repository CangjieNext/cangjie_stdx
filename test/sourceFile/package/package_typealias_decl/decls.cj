package testPackage

type A = Int64
type B = Float64
type C = Bool
type D = String

var aVal: A = 42
var bVal: B = 3.14
var cVal: C = true
var dVal: D = "hello"

class LongClass {}
type LC = LongClass
var lc: LC = LC()

enum UnitEnum {
    X
    | Y
}
type UE = UnitEnum
var e1 = UE.X
var e2 = UE.Y

struct Box<T> {
    var value: T
    public init(v: T) {
        value = v
    }
}
type BX<T> = Box<T>
