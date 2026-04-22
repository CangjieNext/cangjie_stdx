# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

# The fuzzing engine depends on fuzz.
# fuzz compiled with -fsanitize-coverage may cause incorrectly coverage feedback.

string(REGEX REPLACE "-fsanitize-coverage=[^ ]+" "" CMAKE_C_FLAGS_NO_COVERAGE "${CMAKE_C_FLAGS}" )
string(REGEX REPLACE "-fsanitize-coverage=[^ ]+" "" CMAKE_CXX_FLAGS_NO_COVERAGE "${CMAKE_CXX_FLAGS}" )
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS_NO_COVERAGE}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_NO_COVERAGE}")
FILE(GLOB fuzz_ffi_src 
    ./cj_sancov_standard.c
    ./cj_sancov_standard.h
    ./fake_stacktrace_printer.c
    ./fake_stacktrace_printer.h
    ./utf8_fix.c
    ./utf8_fix.h
    ./cjnative_sanitizer_coverage.h)
set(libname stdx.fuzzFFI)

add_library(${libname}-objs OBJECT ${fuzz_ffi_src})

if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
    add_library(${libname} STATIC $<TARGET_OBJECTS:${libname}-objs>)
endif()
install_cangjie_library_ffi(${libname})
