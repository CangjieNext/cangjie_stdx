# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

set(json_stream_ffi_src
    utils.c
    json_int_array.c
    json_string_chunk.c
    ryu/d2s.c
)
set(libname stdx.encoding.json.streamFFI)

add_library(${libname}-objs OBJECT ${json_stream_ffi_src})
target_compile_options(${libname}-objs PRIVATE ${CMAKE_C_COVERAGE_FLAGS})
target_include_directories(${libname}-objs PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})


if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
    add_library(${libname} STATIC $<TARGET_OBJECTS:${libname}-objs>)
endif()

install_cangjie_library_ffi(${libname})
