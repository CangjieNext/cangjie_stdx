# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

file(
    GLOB
    openssl_ffi_src
    opensslSymbols.c
)
set(libname cangjie-dynamicLoader-opensslFFI)
add_library(${libname}-objs OBJECT ${openssl_ffi_src})
add_library(${libname}-auto-objs OBJECT ${openssl_ffi_src})
target_compile_definitions(${libname}-auto-objs PRIVATE CANGJIE_OPENSSL_RESOLVE_AUTO=1)
target_compile_options(${libname}-auto-objs PRIVATE -Wno-deprecated-declarations)


if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
    add_library(${libname} STATIC $<TARGET_OBJECTS:${CANGJIE_OPENSSL_FFI_OBJECTS_TARGET}>)
endif()

target_include_directories(${libname}-objs PRIVATE ${OPENSSL_INCLUDE_DIR})
target_include_directories(${libname}-auto-objs PRIVATE ${OPENSSL_INCLUDE_DIR})

install_cangjie_library_ffi(${libname})


if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
    add_library(${libname}-shared SHARED $<TARGET_OBJECTS:${libname}-objs>)
    set_target_properties(${libname}-shared PROPERTIES OUTPUT_NAME ${libname})
    if(MINGW)
        target_link_options(${libname}-shared PRIVATE -pthread -Wl,--export-all-symbols)
    endif()
    install_cangjie_library_ffi_s(${libname}-shared)
endif()
