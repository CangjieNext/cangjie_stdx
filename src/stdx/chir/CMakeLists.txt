# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

set(_chir_flatbuffer_sources)

# Attribute bits are shared with the compiler. Compare this package with the header
# installed at $CANGJIE_HOME/include, not with a compiler source checkout.
find_program(_chir_attr_python NAMES python3 python)
if(NOT _chir_attr_python)
    message(FATAL_ERROR "python3 is required to check CHIR Attribute against the compiler SDK")
endif()
execute_process(
    COMMAND "${_chir_attr_python}" "${CMAKE_CURRENT_SOURCE_DIR}/test/check_chir_attributes.py"
    RESULT_VARIABLE _chir_attr_sync_result)
if(NOT _chir_attr_sync_result EQUAL 0)
    message(FATAL_ERROR "stdx CHIR Attribute does not match the compiler SDK")
endif()

# Generate StdxChirFormat_generated.cj from the compiler SDK schema (flatc from CANGJIE_HOME).
if(NOT CANGJIE_CJPM_BUILD_TYPE)
    include(CangjieFlatbuffers)

    cangjie_add_flatbuffers_cj_outputs(
        TARGET CHIR_FLATC_OUTPUTS
        SCHEMA "${CANGJIE_CHIR_FORMAT_FBS}"
        OUTPUT_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
        OUTPUT_VAR _chir_generated_cj)

    set(_chir_flatbuffer_sources StdxChirFormat_generated.cj)
    set(CHIR_FLATC_SOURCE_FILES "${_chir_generated_cj}" PARENT_SCOPE)
endif()

# CHIR_SRCS: generated FlatBuffers code (explicit) + hand-written sources from GLOB.
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
