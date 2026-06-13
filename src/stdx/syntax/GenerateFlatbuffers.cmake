# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.
#
# Shared FlatBuffers generation for syntax. Invoked via:
#   cmake -DSYNTAX_SOURCE_DIR=... -DSYNTAX_BUILD_DIR=... -DSYNTAX_REPO_DIR=... -DSYNTAX_SCHEMA_SRC=... -P GenerateFlatbuffers.cmake

if(NOT SYNTAX_SOURCE_DIR OR NOT SYNTAX_BUILD_DIR OR NOT SYNTAX_REPO_DIR OR NOT SYNTAX_SCHEMA_SRC)
    message(FATAL_ERROR "GenerateFlatbuffers.cmake: missing required -D arguments")
endif()

get_filename_component(_filename ${SYNTAX_SCHEMA_SRC} NAME_WE)
set(_flatc "${SYNTAX_BUILD_DIR}/bin/flatc")
set(_fb_cj "${SYNTAX_REPO_DIR}/third_party/flatbuffers/cangjie")
set(_flatc_out "${SYNTAX_BUILD_DIR}/${_filename}_generated.cj")

if(NOT EXISTS "${_flatc}")
    message(FATAL_ERROR "flatc not found: ${_flatc}")
endif()

execute_process(
    COMMAND "${_flatc}" --no-warnings --cangjie -o "${SYNTAX_BUILD_DIR}" "${SYNTAX_SCHEMA_SRC}"
    RESULT_VARIABLE _flatc_result)
if(NOT _flatc_result EQUAL 0)
    message(FATAL_ERROR "flatc failed with code ${_flatc_result}")
endif()

function(_syntax_sed_replace in_file out_file)
    execute_process(
        COMMAND sed "s/std.ast/stdx.syntax/g" "${in_file}"
        OUTPUT_FILE "${out_file}"
        RESULT_VARIABLE _sed_result)
    if(NOT _sed_result EQUAL 0)
        message(FATAL_ERROR "sed failed for ${in_file}")
    endif()
endfunction()

_syntax_sed_replace("${_fb_cj}/flatbuffer_object.cj" "${SYNTAX_SOURCE_DIR}/flatbuffer_object.cj")
_syntax_sed_replace("${_fb_cj}/decode.cj" "${SYNTAX_SOURCE_DIR}/decode.cj")
_syntax_sed_replace("${_fb_cj}/table.cj" "${SYNTAX_SOURCE_DIR}/table.cj")
_syntax_sed_replace("${_fb_cj}/builder.cj" "${SYNTAX_SOURCE_DIR}/builder.cj")
_syntax_sed_replace("${_fb_cj}/constants.cj" "${SYNTAX_SOURCE_DIR}/constants.cj")
_syntax_sed_replace("${_fb_cj}/exception.cj" "${SYNTAX_SOURCE_DIR}/exception.cj")
_syntax_sed_replace("${_flatc_out}" "${SYNTAX_SOURCE_DIR}/${_filename}_generated.cj")
