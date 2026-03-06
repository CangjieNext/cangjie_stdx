# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

if(WIN32)
    file(GLOB TAR_FFI_SRC ./tar_native_win.c)
else()
    file(GLOB TAR_FFI_SRC ./tar_native_unix.c)
endif()

set(libname compress.tarFFI)

add_library(${libname}-objs OBJECT ${TAR_FFI_SRC})
target_compile_options(${libname}-objs PRIVATE ${CMAKE_C_COVERAGE_FLAGS})
add_library(${libname} STATIC $<TARGET_OBJECTS:${libname}-objs>)
install_cangjie_library_ffi(${libname})

if (CANGJIE_CJPM_BUILD_SELF)
    string(TOLOWER ${CMAKE_BUILD_TYPE} type)
    install(TARGETS ${libname} DESTINATION ${type}/compress@cangjie_stdx)
endif()
