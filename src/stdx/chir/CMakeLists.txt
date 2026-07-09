# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

set(_chir_flatbuffer_sources)

# Generate cangjie flatbuffers files for chir using compiler SDK schema.
# flatbuffers runtime is a separate package (package flatbuffers), same as std.ast.
if(NOT CANGJIE_CJPM_BUILD_TYPE)
    include(CangjieFlatbuffers)

    set(CHIR_SCHEMA_SRC ${CANGJIE_FLATBUFFERS_CHIR_SCHEMA})
    if(NOT EXISTS ${CHIR_SCHEMA_SRC})
        message(FATAL_ERROR "CHIRFormat.fbs not found: ${CHIR_SCHEMA_SRC}")
    endif()

    get_filename_component(FILENAME ${CHIR_SCHEMA_SRC} NAME_WE)
    set(_chir_flatbuffer_sources ${FILENAME}_generated.cj)

    cangjie_add_flatbuffers_cj_outputs(
        CHIR_FLATC_OUTPUTS
        ${CHIR_SCHEMA_SRC}
        ${CMAKE_CURRENT_SOURCE_DIR}
        CHIR_FLATC_SOURCE_FILES)

    set(CHIR_FLATC_SOURCE_FILES ${CHIR_FLATC_SOURCE_FILES} PARENT_SCOPE)
endif()

# CHIR_SRCS: FlatBuffers outputs (listed explicitly) + hand-written sources from GLOB.
set(_chir_srcs ${_chir_flatbuffer_sources})
file(GLOB _chir_glob CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/*.cj")
foreach(_chir_file ${_chir_glob})
    get_filename_component(_chir_basename ${_chir_file} NAME)
    if(NOT _chir_basename IN_LIST _chir_flatbuffer_sources)
        list(APPEND _chir_srcs ${_chir_basename})
    endif()
endforeach()
set(CHIR_SRCS ${_chir_srcs} CACHE INTERNAL "")

add_subdirectory(to_string_macro)
