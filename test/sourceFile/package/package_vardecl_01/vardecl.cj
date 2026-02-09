package testPackage

let int_a = 1
var int_b: Int64 = 2
const int_c : Int32 = 3
var int_d : Int16 = 4
let int_e : Int8 = 5
let int_f: ?Int64 = 6
let int_g: (Int64) = 7

let uint_a : UInt64 = 1
var uint_b : UInt32 = 2
const uint_c : UInt16 = 3
let uint_d : UInt8 = 4

const float_a = 1.0
let float_b: Float64 = 2.1
var float_c: Float32 = 3.4
var float_d: Float16 = 3.4

var bool_a = true
let bool_b: Bool = false

const rune_a = r'a'
let rune_b: Rune = r'b'

let string_a = "Hello"
let string_b: String = "World"
var string_c = "Hello"
var string_d: String = "World"

let unit_a = ()
let unit_b: Unit = ()

let tuple_a = (1, "a", true)
let tuple_b: (Int64, String, Bool) = (1, "a", true)

var array_a = [1, 2, 3]
var array_b: Array<Int64> = [1, 2, 3]

var varray_a: VArray<Int64, $3> = [1, 2, 3]

let range_a = 1..10
let range_b: Range<Int64> = 1..100

let lambda_a = { x: Int64 => x + 1 }
let lambda_b: (Int64) -> Int64 = { x => x * 2 }

let lambda_no_arg_a = { => 0 }
let lambda_no_arg_b: () -> Int64 = { => 1 }

let annotation_a = AnnotationKind.Init