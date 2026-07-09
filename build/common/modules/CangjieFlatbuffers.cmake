# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.
#
# Resolve flatbuffers toolchain and runtime from CANGJIE_HOME/third_party/flatbuffers.

if(NOT DEFINED ENV{CANGJIE_HOME} OR "$ENV{CANGJIE_HOME}" STREQUAL "")
    message(FATAL_ERROR
        "CANGJIE_HOME is not set. Source envsetup.sh or export CANGJIE_HOME before building stdx.")
endif()

get_filename_component(CANGJIE_HOME "$ENV{CANGJIE_HOME}" ABSOLUTE)
if(NOT IS_DIRECTORY "${CANGJIE_HOME}")
    message(FATAL_ERROR "CANGJIE_HOME does not exist: ${CANGJIE_HOME}")
endif()

message(STATUS "CANGJIE_HOME: ${CANGJIE_HOME}")

set(CANGJIE_FLATBUFFERS_DIR "${CANGJIE_HOME}/third_party/flatbuffers")
set(CANGJIE_FLATBUFFERS_FLATC "${CANGJIE_FLATBUFFERS_DIR}/flatc")
if(CMAKE_HOST_WIN32)
    set(CANGJIE_FLATBUFFERS_FLATC "${CANGJIE_FLATBUFFERS_DIR}/flatc.exe")
endif()
set(CANGJIE_FLATBUFFERS_CJ_DIR "${CANGJIE_FLATBUFFERS_DIR}/cangjie")
set(CANGJIE_FLATBUFFERS_PACKAGE_SCHEMA "${CANGJIE_FLATBUFFERS_DIR}/PackageFormat.fbs")
set(CANGJIE_FLATBUFFERS_CPP_INCLUDE "${CANGJIE_FLATBUFFERS_DIR}/include")

if(NOT EXISTS "${CANGJIE_FLATBUFFERS_FLATC}")
    message(FATAL_ERROR "flatc not found: ${CANGJIE_FLATBUFFERS_FLATC}")
endif()
if(NOT EXISTS "${CANGJIE_FLATBUFFERS_CPP_INCLUDE}/flatbuffers/flatbuffers.h")
    message(FATAL_ERROR
        "flatbuffers C++ headers not found: ${CANGJIE_FLATBUFFERS_CPP_INCLUDE}/flatbuffers/flatbuffers.h")
endif()
if(NOT EXISTS "${CANGJIE_FLATBUFFERS_CJ_DIR}/table.cj")
    message(FATAL_ERROR "flatbuffers cangjie runtime not found: ${CANGJIE_FLATBUFFERS_CJ_DIR}")
endif()

message(STATUS "Cangjie flatbuffers dir: ${CANGJIE_FLATBUFFERS_DIR}")
message(STATUS "Cangjie flatbuffers flatc: ${CANGJIE_FLATBUFFERS_FLATC}")

# Generate FlatBuffers Cangjie support sources into output_dir using compiler flatc.
function(cangjie_add_flatbuffers_cj_outputs target_name schema_src output_dir package_name out_var)
    get_filename_component(_filename ${schema_src} NAME_WE)
    set(_gen_dir "${CMAKE_BINARY_DIR}/${target_name}_flatc_gen")
    set(_runtime_files
        flatbuffer_object.cj
        decode.cj
        table.cj
        builder.cj
        constants.cj
        exception.cj)
    set(_output_files)
    foreach(_file ${_runtime_files})
        list(APPEND _output_files "${output_dir}/${_file}")
    endforeach()
    list(APPEND _output_files "${output_dir}/${_filename}_generated.cj")

    set(_deps ${schema_src} ${CANGJIE_FLATBUFFERS_FLATC})
    foreach(_file ${_runtime_files})
        list(APPEND _deps "${CANGJIE_FLATBUFFERS_CJ_DIR}/${_file}")
    endforeach()

    set(_commands
        COMMAND ${CMAKE_COMMAND} -E make_directory ${_gen_dir}
        COMMAND ${CANGJIE_FLATBUFFERS_FLATC} --no-warnings --cangjie -o ${_gen_dir} ${schema_src})
    foreach(_file ${_runtime_files})
        list(APPEND _commands
            COMMAND sed "s/std.ast/${package_name}/g"
                ${CANGJIE_FLATBUFFERS_CJ_DIR}/${_file} > ${output_dir}/${_file})
    endforeach()
    list(APPEND _commands
        COMMAND sed "s/std.ast/${package_name}/g"
            ${_gen_dir}/${_filename}_generated.cj > ${output_dir}/${_filename}_generated.cj)

    get_filename_component(_schema_dir ${schema_src} DIRECTORY)

    add_custom_command(
        OUTPUT ${_output_files}
        ${_commands}
        DEPENDS ${_deps}
        COMMENT "generate cangjie flatbuffers files for ${target_name}"
        WORKING_DIRECTORY ${_schema_dir})

    add_custom_target(${target_name} ALL DEPENDS ${_output_files})
    set(${out_var} ${_output_files} PARENT_SCOPE)
endfunction()
