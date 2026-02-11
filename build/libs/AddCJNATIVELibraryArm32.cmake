# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

include(AddAndCombineStaticLib)
include(ExtractArchive)

set(BACKEND_TYPE CJNATIVE)

##  make shared/static library
# if we support cross-compiling, we need to change here for target type
string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND_TYPE} output_cj_object_dir)
string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX} output_triple_name)
set(CJNATIVE_BACKEND "cjnative")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})
set(output_cj_object_dir ${CMAKE_BINARY_DIR}/modules/${output_cj_object_dir})

make_cangjie_lib(
    chir IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Chir
    CANGJIE_STD_LIB_LINK
        std-core
        std-collection
    OBJECTS ${output_cj_object_dir}/stdx/chir.o)
add_library(stdx.chir STATIC ${output_cj_object_dir}/stdx/chir.o)
set_target_properties(stdx.chir PROPERTIES LINKER_LANGUAGE C OUTPUT_NAME "chir@cangjie_stdx")
install(TARGETS stdx.chir DESTINATION ${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH}/static/stdx)

make_cangjie_lib(
    encoding IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Encoding
    CANGJIE_STD_LIB_LINK std-core
    OBJECTS ${output_cj_object_dir}/stdx/encoding.o)

add_library(stdx.encoding STATIC ${output_cj_object_dir}/stdx/encoding.o)
set_target_properties(stdx.encoding PROPERTIES LINKER_LANGUAGE C OUTPUT_NAME "encoding@cangjie_stdx")
install(TARGETS stdx.encoding DESTINATION ${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH}/static/stdx)

make_cangjie_lib(
    serialization IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}StdxSerialization
    CANGJIE_STD_LIB_LINK std-core
    OBJECTS ${output_cj_object_dir}/stdx/serialization.o)

add_library(stdx.serialization STATIC ${output_cj_object_dir}/stdx/serialization.o)
set_target_properties(stdx.serialization PROPERTIES LINKER_LANGUAGE C OUTPUT_NAME "serialization@cangjie_stdx")
install(TARGETS stdx.serialization DESTINATION ${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH}/static/stdx)

make_cangjie_lib(
    serialization.serialization IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Serialization
    CANGJIE_STD_LIB_LINK
        std-core
        std-collection
        std-sort
        std-math
    OBJECTS ${output_cj_object_dir}/stdx/serialization.serialization.o)

add_library(stdx.serialization.serialization STATIC ${output_cj_object_dir}/stdx/serialization.serialization.o)
set_target_properties(stdx.serialization.serialization PROPERTIES LINKER_LANGUAGE C OUTPUT_NAME "serialization.serialization@cangjie_stdx")
install(TARGETS stdx.serialization.serialization
        DESTINATION ${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH}/static/stdx)

make_cangjie_lib(
    encoding.json IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Json encoding.jsonFFI
    CANGJIE_STDX_LIB_DEPENDS  serialization.serialization
    CANGJIE_STD_LIB_LINK
        std-core
        std-collection
        std-convert
        std-sort
        std-math
    OBJECTS ${output_cj_object_dir}/stdx/encoding.json.o
    FLAGS -lencoding.jsonFFI)
get_target_property(JSONFFI_OBJS encoding.jsonFFI SOURCES)

add_library(stdx.encoding.json STATIC ${JSONFFI_OBJS} ${output_cj_object_dir}/stdx/encoding.json.o)
set_target_properties(stdx.encoding.json PROPERTIES LINKER_LANGUAGE C OUTPUT_NAME "encoding.json@cangjie_stdx")
install(TARGETS stdx.encoding.json DESTINATION ${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH}/static/stdx)

make_cangjie_lib(
    encoding.json.stream IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}JsonStream
        encoding.json.streamFFI
        encoding.jsonFFI
    CANGJIE_STD_LIB_LINK
        std-core
        std-collection
        std-collection.concurrent
        std-io
        std-math.numeric
        std-math
        std-time
        std-sort
        std-convert
    OBJECTS ${output_cj_object_dir}/stdx/encoding.json.stream.o
    FLAGS
        -lencoding.json.streamFFI
        -lencoding.jsonFFI)
get_target_property(JSONFFI_OBJS encoding.jsonFFI SOURCES)

add_library(
    stdx.encoding.json.stream STATIC
    $<TARGET_OBJECTS:encoding.json.streamFFI-objs>
    ${JSONFFI_OBJS}
    ${output_cj_object_dir}/stdx/encoding.json.stream.o)
install(TARGETS stdx.encoding.json.stream DESTINATION ${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH}/static/stdx)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Defined all xxx_DEPENDENCIES, which are for all backends.
include(LibraryDependencies)

add_cangjie_library(
    cangjie${BACKEND_TYPE}Encoding
    NO_SUB_PKG
    IS_STDXLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    OUTPUT_NAME "cangjieEncoding"
    PACKAGE_NAME "encoding"
    MODULE_NAME "stdx"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/encoding
    DEPENDS ${ENCODING_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}StdxSerialization
    NO_SUB_PKG
    IS_STDXLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "serialization"
    MODULE_NAME "stdx"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/serialization
    DEPENDS ${SERIALIZATIONBASE_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Serialization
    NO_SUB_PKG
    IS_STDXLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "serialization.serialization"
    MODULE_NAME "stdx"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/serialization/serialization
    DEPENDS ${SERIALIZATION_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Json
    IS_STDXLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "encoding.json"
    MODULE_NAME "stdx"
    SOURCES ${JSON_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/encoding/json
    DEPENDS ${ENCODING_JSON_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}JsonStream
    NO_SUB_PKG
    IS_STDXLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    OUTPUT_NAME "cangjieJson"
    PACKAGE_NAME "encoding.json.stream"
    MODULE_NAME "stdx"
    SOURCES ${JSON_STREAM_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/encoding/json/stream
    DEPENDS ${ENCODING_JSON_STREAM_DEPENDENCIES})