import std.sync.*
import std.time.*
func test(a:Int64): Unit {
    let mtx = Monitor()
    synchronized (mtx) {
        while (true) {
            println(a)
        }
    }
}