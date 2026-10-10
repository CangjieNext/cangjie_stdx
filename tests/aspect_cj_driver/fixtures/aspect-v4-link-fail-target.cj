// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_target

// The archive produced during preflight may contain an unresolved external.
// The executable link in apply must fail without publishing COMPLETE.
foreign func AspectV4MissingExternalSymbol(): Unit

main() {
    unsafe { AspectV4MissingExternalSymbol() }
}
