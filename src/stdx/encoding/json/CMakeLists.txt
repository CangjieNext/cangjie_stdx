# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

add_subdirectory(stream)
add_subdirectory(native)
set(JSON_SRCS
    json_object.cj
    json_value.cj
    native.cj
    to_json.cj
    json_exception.cj
    write_buffer.cj
    CACHE INTERNAL "")
