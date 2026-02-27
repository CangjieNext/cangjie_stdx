
func test(): Int64 {
    return 1
}

func test_null() {
    return
}

func test1(a: Int64, b: Int64) {
    return a + b
}

func test2() {
    return [1, 2, 3]
}

func test3(b: Int64) {
    return match(b) {
        case v: Int64 => v
        case _ => 1
    }
}

func test4() {
    return test_null() 
}

func test5(a: Int64, v: Int64, b: Int64) {
    return if (a + v < b) {
        a + v
    } else {
        b
    }
}

func test6()  {
    return VArray<Int64, $3>(repeat: 10)
}

func test7(firstName: String, lastName: String): String {
    return "${firstName} ${lastName}"
}

func test8(width: Float64, height: Float64): Float64 {
    return width * height
}


func test9(number: Int64): Bool {
    return number % 2 == 0
}

