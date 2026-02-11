# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../third_party/boundscheck-v1.1.16/include)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../build/libs/")

message(STATUS "CANGJIE_CJPM_BUILD_SELF ${CANGJIE_CJPM_BUILD_SELF}")
if (CANGJIE_NATIVE_LIB STREQUAL "compress")
    add_subdirectory(compress/zlib/native)
    add_subdirectory(compress/tar/native)
    return()
endif()
if (CANGJIE_NATIVE_LIB STREQUAL "crypto")
    add_subdirectory(dynamicLoader)
    add_subdirectory(crypto/keys/native)
    add_subdirectory(crypto/x509/native)
    return()
endif()
if (CANGJIE_NATIVE_LIB STREQUAL "encoding")
    add_subdirectory(encoding/json/native)
    add_subdirectory(encoding/json/stream/native)
    return()
endif()
if (CANGJIE_NATIVE_LIB STREQUAL "net")
    add_subdirectory(dynamicLoader)
    add_subdirectory(net/tls/native)
    return()
endif()
if (CANGJIE_NATIVE_LIB STREQUAL "fuzz" AND NOT WIN32)
    add_subdirectory(fuzz/fuzz/native)
    return()
endif()
if (CANGJIE_NATIVE_LIB STREQUAL "syntax")
    add_subdirectory(syntax/native)
    return()
endif()

if(CMAKE_BUILD_STAGE STREQUAL "preBuild" OR CANGJIE_NATIVE_ONLY)
    add_subdirectory(compress/src/zlib/native)
    add_subdirectory(compress/src/tar/native)
    add_subdirectory(crypto/src/keys/native)
    add_subdirectory(crypto/src/x509/native)
    add_subdirectory(dynamicLoader)
    add_subdirectory(encoding/src/json/native)
    add_subdirectory(encoding/src/json/stream/native)
    if(NOT WIN32)
        add_subdirectory(fuzz/src/fuzz/native)
    endif()
    add_subdirectory(net/src/tls/native)
    return()
endif()

add_subdirectory(dynamicLoader)
add_subdirectory(compress)
add_subdirectory(serialization)
add_subdirectory(encoding)
if(NOT CANGJIE_CJPM_BUILD_TYPE OR NOT WIN32)
    add_subdirectory(fuzz)
endif()
add_subdirectory(log)
add_subdirectory(logger)
add_subdirectory(crypto)
add_subdirectory(net)
add_subdirectory(unittest)
add_subdirectory(actors)
add_subdirectory(string_intern)

message(STATUS "CMAKE_BUILD_STAGE ${CMAKE_BUILD_STAGE}")
if(NOT CANGJIE_CJPM_BUILD_TYPE AND NOT TRIPLE STREQUAL "arm-linux-ohos")
    add_subdirectory(syntax)
endif()

if(CANGJIE_CODEGEN_CJNATIVE_BACKEND AND "$ENV{NO_ASPECTCJ}" STREQUAL "" AND NOT CANGJIE_CJPM_BUILD_TYPE)
    if(CMAKE_CROSSCOMPILING)
        if ("$ENV{CANGJIE_LSP_PATH}" STREQUAL "")
            # Nothing to do
        else()
            add_subdirectory(aspectCJ)
        endif()
    else()
        add_subdirectory(aspectCJ)
    endif()
endif()

if(NOT CANGJIE_BUILD_WITHOUT_EFFECT_HANDLERS)
    add_subdirectory(effect)
endif()

if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
    include(MakeCJNATIVEStdSharedLib)
    if(TRIPLE STREQUAL "arm-linux-ohos")
        include(AddCJNATIVELibraryArm32)
    else()
        include(AddCJNATIVELibrary)
    endif()
endif()

execute_process(
    COMMAND cjc --version 
    RESULT_VARIABLE cjc_result
    OUTPUT_VARIABLE cjc_output
    ERROR_VARIABLE cjc_error
)

set(BACKEND)
set(version_number)
if(cjc_result EQUAL 0)
    string(REGEX MATCH "Cangjie Compiler: (([0-9]+\\.[0-9]+\\.[0-9]+)(-[a-z]+\\.[0-9]+)?) \\(cjnative\\)" first_match_cjnative "${cjc_output}")
    if(first_match_cjnative)
        set(version_number "${CMAKE_MATCH_1}")
        set(BACKEND "cjnative")
    endif()
else()
    message(WARNING "cjc --version error:")
    message(WARNING "${cjc_error}")
endif() 
 
message("cjc version is " ${version_number})
 
 
set(json_file_path "${CMAKE_SOURCE_DIR}/package.json")
 
file(READ "${json_file_path}" file_content)
string(REGEX MATCH "\"version\": \"([^\"]+)\"" match_stdx_version_result "${file_content}")
if(match_stdx_version_result)
    set(stdx_version_number "${CMAKE_MATCH_1}")
else()
    message(STATUS "not find stdx version")
endif()
 
message("stdx version is "  ${stdx_version_number})
 
set(json_content "{
    \"cjc_version\": \"${version_number}\",
    \"version\": \"${version_number}.${stdx_version_number}\",
    \"description\": \"\"
}")
set(json_file "${CMAKE_BINARY_DIR}/package.json")
file(WRITE "${json_file}" "${json_content}")
install(FILES "${json_file}" DESTINATION "${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND}")