/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.compress.zlib

class ZlibStreamState {
    var inBuf: Array<UInt8> = Array<UInt8>()
    var inBufOffset: Int64 = 0
    var availIn: Int64 = 0
    var finished: Bool = false

    func addInputBytes(inBuf: Array<UInt8>, availIn: Int64): Unit {
        this.inBuf = inBuf
        this.inBufOffset = 0
        this.availIn = availIn
    }

    func updateAfterProcess(zlibStream: ZlibStream, ret: Int32, outBufSize: Int64): Int64 {
        let nextAvailIn: Int64 = Int64(zlibStream.availIn)
        inBufOffset += availIn - nextAvailIn
        availIn = nextAvailIn
        finished = ret == ZLIB_STREAM_END
        return outBufSize - Int64(zlibStream.availOut)
    }

    func needsInput(): Bool {
        return !finished && availIn == 0
    }

    func isFinished(): Bool {
        return finished
    }
}

class DecompressionRatioGuard {
    private var totalInputBytes: Int64 = 0
    private var totalOutputBytes: Int64 = 0

    func addInputBytes(bytes: Int64): Unit {
        totalInputBytes += bytes
    }

    func addOutputBytes(bytes: Int64): Unit {
        if (bytes <= 0) {
            return
        }
        totalOutputBytes += bytes
        if (totalOutputBytes < MIN_OUTPUT_BYTES_FOR_RATIO_CHECK || totalInputBytes <= 0) {
            return
        }
        if (totalOutputBytes / totalInputBytes > MAX_DECOMPRESSION_RATIO) {
            throw ZlibException("Decompressed output exceeds safety compression ratio ${MAX_DECOMPRESSION_RATIO}:1.")
        }
    }
}
