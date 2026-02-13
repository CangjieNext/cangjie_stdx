package stdx.semantic

import std.time.*

const ENABLE_PROFILE: Bool = false 

func timerStart() {
    MonoTime.now()
}

func timerRecord(start: MonoTime, info: String) {
    if (ENABLE_PROFILE) {
        println("${info} time: ${Float64((MonoTime.now() - start).toNanoseconds()) / 1000000.0} ms")
    }
}

