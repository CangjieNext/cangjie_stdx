package stdx.semantic

import std.time.*
import std.fs.*
import std.io.*
import std.sync.*

const ENABLE_PROFILE: Bool = false
const CSV_FILE_PATH: String = "./timeSave.csv"
const CSV_HEADER: String = "info,time,timestamp"

var csvMutex = Mutex()

func timerStart() {
    MonoTime.now()
}

func timerSave(info: String, time: Float64) {
    csvMutex.lock()
    try {
        let filePath = Path(CSV_FILE_PATH)
        let fileExists = exists(filePath)
        
        var file = File(filePath, Append)
        
        if (!fileExists) {
            let headerBytes = CSV_HEADER.toArray()
            file.write(headerBytes)
            file.write("\n".toArray())
        }
        
        let timestamp = Int64(DateTime.nowUTC().toUnixTimeStamp().toNanoseconds())
        let line = "${info},${time},${timestamp}\n"
        file.write(line.toArray())
        file.close()
    } catch (e: IOException) {
        println("Failed to write to CSV file: ${e.message}")
    }
    csvMutex.unlock()
}

func timerRecord(start: MonoTime, info: String) {
    if (ENABLE_PROFILE) {
        let elapsed = Float64((MonoTime.now() - start).toNanoseconds()) / 1000000.0
        println("${info} time: ${elapsed} ms")
        timerSave(info, elapsed)
    }
}

