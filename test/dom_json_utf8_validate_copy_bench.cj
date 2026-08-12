import std.time.*

@FastNative
foreign func CJ_JSON_ValidateUtf8AndCopy(
    input: CPointer<UInt8>, output: CPointer<UInt8>, size: Int64
): Bool

let InputSize = 100 * 1024
let Iterations = 4000

func baseline(input: Array<UInt8>): (Int64, Int64) {
    var checksum: Int64 = 0
    let begin = MonoTime.now()
    for (_ in 0..Iterations) {
        if (!String.checkUtf8Encoding(input)) {
            throw Exception("baseline rejected valid UTF-8")
        }
        let copy = input.clone()
        checksum += Int64(copy[0])
    }
    return ((MonoTime.now() - begin).toMicroseconds(), checksum)
}

func fused(input: Array<UInt8>): (Int64, Int64) {
    var checksum: Int64 = 0
    let begin = MonoTime.now()
    for (_ in 0..Iterations) {
        let copy = Array<UInt8>(input.size, repeat: 0)
        let valid = unsafe {
            let inputHandle = acquireArrayRawData(input)
            let outputHandle = acquireArrayRawData(copy)
            let result = CJ_JSON_ValidateUtf8AndCopy(inputHandle.pointer, outputHandle.pointer, input.size)
            releaseArrayRawData(outputHandle)
            releaseArrayRawData(inputHandle)
            result
        }
        if (!valid) {
            throw Exception("fused path rejected valid UTF-8")
        }
        checksum += Int64(copy[0])
    }
    return ((MonoTime.now() - begin).toMicroseconds(), checksum)
}

main() {
    let input = Array<UInt8>(InputSize, repeat: b'a')
    let (baselineUs, baselineChecksum) = baseline(input)
    let (fusedUs, fusedChecksum) = fused(input)
    if (baselineChecksum != fusedChecksum) {
        throw Exception("benchmark checksums differ")
    }
    println("baseline_us=${baselineUs} fused_us=${fusedUs} speedup=${Float64(baselineUs) / Float64(fusedUs)}")
}
