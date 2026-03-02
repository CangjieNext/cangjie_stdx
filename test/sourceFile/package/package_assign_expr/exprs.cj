func test(): Unit {
    var a = 1
    var b = 2
    var c = -1 
    var d = true
    var e = false
    a = b
    a += b
    a = a + b
    a *= 2
    a **= 3
    a /= b
    a %= b
    a <<= b 
    a >>= b
    a -= b
    a = if (a + c < b) {
        a + c
    } else {
        b
    }
    d ||= e
    a &= b
    e &&= d
    a |= b
    a ^= b
}