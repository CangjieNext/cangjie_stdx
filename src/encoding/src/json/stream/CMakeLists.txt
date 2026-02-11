# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

add_subdirectory(native)
set(JSON_STREAM_SRCS
    json_convert.cj
    json_reader.cj
    json_deserializable.cj
    json_token.cj
    json_serializable.cj
    json_writer.cj
    string_serialize.cj
    numeric_serialize.cj
    datetime_serialize.cj
    CACHE INTERNAL "")
