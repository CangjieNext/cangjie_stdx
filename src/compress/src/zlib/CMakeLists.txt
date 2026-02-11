# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

add_subdirectory(native)

set(ZLIB_SRCS
    deflate.cj
    inflate.cj
    native.cj
    zlib_exception.cj
    zlib_stream.cj
    zutil.cj
    CACHE INTERNAL "")
