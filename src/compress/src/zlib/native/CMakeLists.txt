# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

include(ExtractArchive)
set(libname compress.zlibFFI)

include_directories(${CMAKE_BINARY_DIR}/third_party/zlib/include)

message(STATUS "---CMAKE_BINARY_DIR: ${CMAKE_BINARY_DIR} ")

set(ZLIB_OBJS_DIR ${CMAKE_CURRENT_BINARY_DIR}/temp)
file(MAKE_DIRECTORY ${ZLIB_OBJS_DIR})

if(WIN32)
    extract_archive(
    FROM ${CMAKE_BINARY_DIR}/third_party/zlib/lib/libzlibstatic.a
    TO ${ZLIB_OBJS_DIR})
else()
    extract_archive(
    FROM ${CMAKE_BINARY_DIR}/third_party/zlib/lib/libz.a
    TO ${ZLIB_OBJS_DIR})
endif()

file(GLOB ZLIB_OBJS ${ZLIB_OBJS_DIR}/*.o ${ZLIB_OBJS_DIR}/*.obj)
set(ZLIB_OBJS ${ZLIB_OBJS} PARENT_SCOPE)
add_library(${libname}-objs OBJECT ./zlib.c)
target_compile_options(${libname}-objs PRIVATE ${CMAKE_C_COVERAGE_FLAGS})

if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
    add_library(${libname} STATIC $<TARGET_OBJECTS:${libname}-objs> ${ZLIB_OBJS})
endif()
install_cangjie_library_ffi(${libname})

if (CANGJIE_CJPM_BUILD_SELF)
    string(TOLOWER ${CMAKE_BUILD_TYPE} type)
    install(TARGETS ${libname} DESTINATION ${type}/compress@cangjie_stdx)
endif()