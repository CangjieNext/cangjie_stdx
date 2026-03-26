/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx

import std.fs.*

foreign func CJ_OpenSSL_SetPath(cryptoPath: CString, sslPath: CString): Int32

public func setOpenSslPath(cryptoPath: Path, sslPath: Path): Unit {
    unsafe {
        try (
            cryptoPathCStr = LibC.mallocCString(canonicalize(cryptoPath).toString()).asResource(),
            sslPathCStr = LibC.mallocCString(canonicalize(sslPath).toString()).asResource()
        ) {
            if (CJ_OpenSSL_SetPath(cryptoPathCStr.value, sslPathCStr.value) != 1) {
                throw IllegalStateException("Failed to set OpenSSL paths. Call setOpenSslPath before the first OpenSSL usage.")
            }
        } catch(e: Exception) {
            throw IllegalStateException("Failed to set OpenSSL paths. ${e.message}")
        }
    }
}
