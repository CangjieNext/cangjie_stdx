/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.crypto.digest

import std.crypto.digest.Digest
import stdx.crypto.common.CryptoException

public class SHA384 <: Digest {
    var sha384Ctx: SHA384CTX
    var hasFinished: Bool

    public init() {
        sha384Ctx = SHA384CTX()
        this.hasFinished = false
    }

    public prop size: Int64 {
        get() {
            return SHA384_DIGEST_LENGTH
        }
    }

    public prop blockSize: Int64 {
        get() {
            return SHA384_BLOCK_SIZE
        }
    }

    public prop algorithm: String {
        get() {
            return SHA384_DIGEST_ALGORITHM_NAME
        }
    }

    public func write(buffer: Array<Byte>): Unit {
        if (this.hasFinished) {
            throw CryptoException("Digest calculation already completed.")
        }
        sha384Update(sha384Ctx, buffer)
    }

    public func finish(): Array<Byte> {
        var md = Array<Byte>(this.size, repeat: 0)
        finish(to: md)
        md
    }

    public func finish(to!: Array<Byte>): Unit {
        if (this.hasFinished) {
            throw CryptoException("Digest calculation already completed.")
        }
        if (to.size != size) {
            throw CryptoException("Output length '${to.size}' does not match digest length '${size}'.")
        }
        sha384Final(sha384Ctx, to)
        this.hasFinished = true
    }

    public func reset(): Unit {
        sha384Init(this.sha384Ctx.ptr)
        this.hasFinished = false
    }
}

func sha384Update(c: SHA384CTX, data: Array<Byte>): Unit {
    unsafe {
        let dynMsgPtr = generateDynMsg()
        let p: CPointerHandle<Byte> = acquireArrayRawData(data)
        let res = try {
            DYN_SHA384_Update(c.ptr, p.pointer, UIntNative(data.size), dynMsgPtr)
        } finally {
            releaseArrayRawData(p)
        }
        checkError(dynMsgPtr)
        if (res != 1) {
            throw CryptoException("SHA384 write operation failed.")
        }
    }
}

func sha384Final(c: SHA384CTX, md: Array<Byte>): Unit {
    unsafe {
        let dynMsgPtr = generateDynMsg()
        let p: CPointerHandle<Byte> = acquireArrayRawData(md)
        let res = try {
            DYN_SHA384_Final(p.pointer, c.ptr, dynMsgPtr)
        } finally {
            releaseArrayRawData(p)
        }
        checkError(dynMsgPtr)
        if (res != 1) {
            throw CryptoException("SHA384 finish operation failed.")
        }
    }
}
