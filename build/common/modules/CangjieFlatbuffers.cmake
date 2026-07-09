# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.
#
# Resolve flatbuffers toolchain and schemas from the compiler SDK (CANGJIE_HOME).
# Layout matches cangjie_compiler output:
#   third_party/flatbuffers/bin/flatc
#   third_party/flatbuffers/include/
#   third_party/flatbuffers/cangjie/   (package flatbuffers)
#   schema/CHIRFormat.fbs
#   schema/ASTFormat.fbs

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
set(CANGJIE_FLATBUFFERS_FLATC "${CANGJIE_FLATBUFFERS_DIR}/bin/flatc")
if(CMAKE_HOST_WIN32)
    set(CANGJIE_FLATBUFFERS_FLATC "${CANGJIE_FLATBUFFERS_DIR}/bin/flatc.exe")
endif()
set(CANGJIE_FLATBUFFERS_CJ_DIR "${CANGJIE_FLATBUFFERS_DIR}/cangjie")
set(CANGJIE_FLATBUFFERS_CPP_INCLUDE "${CANGJIE_FLATBUFFERS_DIR}/include")
set(CANGJIE_FLATBUFFERS_CHIR_SCHEMA "${CANGJIE_HOME}/schema/CHIRFormat.fbs")

if(NOT EXISTS "${CANGJIE_FLATBUFFERS_FLATC}")
    message(FATAL_ERROR
        "flatc not found: ${CANGJIE_FLATBUFFERS_FLATC}. Build cangjie_compiler and source envsetup.sh first.")
endif()
if(NOT EXISTS "${CANGJIE_FLATBUFFERS_CPP_INCLUDE}/flatbuffers/flatbuffers.h")
    message(FATAL_ERROR
        "flatbuffers C++ headers not found: ${CANGJIE_FLATBUFFERS_CPP_INCLUDE}/flatbuffers/flatbuffers.h")
endif()
if(NOT EXISTS "${CANGJIE_FLATBUFFERS_CJ_DIR}/table.cj")
    message(FATAL_ERROR
        "flatbuffers cangjie runtime not found: ${CANGJIE_FLATBUFFERS_CJ_DIR}. Build cangjie_compiler and source envsetup.sh first.")
endif()

message(STATUS "Cangjie flatbuffers dir: ${CANGJIE_FLATBUFFERS_DIR}")
message(STATUS "Cangjie flatbuffers flatc: ${CANGJIE_FLATBUFFERS_FLATC}")

# Generate FlatBuffers Cangjie code into output_dir (only *_generated.cj).
# flatc emits `package <mapped>` and `import flatbuffers.*` directly.
function(cangjie_add_flatbuffers_cj_outputs target_name schema_src output_dir out_var)
    if(NOT EXISTS "${schema_src}")
        message(FATAL_ERROR "FlatBuffers schema not found: ${schema_src}")
    endif()

    get_filename_component(_filename ${schema_src} NAME_WE)
    set(_gen_dir "${CMAKE_BINARY_DIR}/${target_name}_flatc_gen")
    set(_generated_cj "${output_dir}/${_filename}_generated.cj")
    set(_tmp_generated "${_gen_dir}/${_filename}_generated.cj")

    add_custom_command(
        OUTPUT ${_generated_cj}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${_gen_dir}
        COMMAND ${CANGJIE_FLATBUFFERS_FLATC} --no-warnings --cangjie -o ${_gen_dir} ${schema_src}
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${_tmp_generated} ${_generated_cj}
        DEPENDS ${schema_src} ${CANGJIE_FLATBUFFERS_FLATC}
        COMMENT "generate ${_filename}_generated.cj for ${target_name}"
        WORKING_DIRECTORY ${CANGJIE_FLATBUFFERS_DIR})

    add_custom_target(${target_name} ALL DEPENDS ${_generated_cj})
    set(${out_var} ${_generated_cj} PARENT_SCOPE)
endfunction()
