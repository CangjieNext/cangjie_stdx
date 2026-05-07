# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

set(CHIR_SRCS "*.cj" CACHE INTERNAL "")

# Generate cangjie flatbuffers files for chir
set(SCHEMA_SRC ${CMAKE_SOURCE_DIR}/../cangjie_compiler/schema/PackageFormat.fbs)
get_filename_component(FILENAME ${SCHEMA_SRC} NAME_WE)
set(FLATC_EXECUTABLE "${CMAKE_BINARY_DIR}/bin/flatc")
set(FLATBUFFER_DEPEND_CJ_DIR ${CMAKE_SOURCE_DIR}/third_party/flatbuffers/cangjie)

set(FLATC_CJ_OUTPUT "${CMAKE_BINARY_DIR}/${FILENAME}_generated.cj")

add_custom_command(
    OUTPUT ${FLATC_CJ_OUTPUT}
    COMMAND ${FLATC_EXECUTABLE} ARGS --no-warnings --cangjie -o "${CMAKE_BINARY_DIR}" ${SCHEMA_SRC}
    DEPENDS flatbuffers ${SCHEMA_SRC}
    COMMAND sed 's/std.ast/stdx.chir/g' ${FLATBUFFER_DEPEND_CJ_DIR}/flatbuffer_object.cj > ${CMAKE_BINARY_DIR}/chir_flatbuffer_object.cj
    COMMAND sed 's/std.ast/stdx.chir/g' ${FLATBUFFER_DEPEND_CJ_DIR}/decode.cj             > ${CMAKE_BINARY_DIR}/chir_decode.cj
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/patch_table.py ${CMAKE_BINARY_DIR}/patch_table.py
    COMMAND python3 ${CMAKE_BINARY_DIR}/patch_table.py ${FLATBUFFER_DEPEND_CJ_DIR}/table.cj ${CMAKE_BINARY_DIR}/chir_table.cj
    COMMAND sed 's/std.ast/stdx.chir/g' ${FLATBUFFER_DEPEND_CJ_DIR}/builder.cj            > ${CMAKE_BINARY_DIR}/chir_builder.cj
    COMMAND sed 's/std.ast/stdx.chir/g' ${FLATBUFFER_DEPEND_CJ_DIR}/constants.cj          > ${CMAKE_BINARY_DIR}/chir_constants.cj
    COMMAND sed 's/std.ast/stdx.chir/g' ${FLATBUFFER_DEPEND_CJ_DIR}/exception.cj          > ${CMAKE_BINARY_DIR}/chir_exception.cj
    COMMAND sed 's/std.ast/stdx.chir/g' ${FLATC_CJ_OUTPUT}                                > ${CMAKE_BINARY_DIR}/chir_${FILENAME}_generated.cj
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/chir_flatbuffer_object.cj      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffer_object.cj
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/chir_decode.cj                 ${CMAKE_CURRENT_SOURCE_DIR}/decode.cj
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/chir_table.cj                  ${CMAKE_CURRENT_SOURCE_DIR}/table.cj
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/chir_builder.cj                ${CMAKE_CURRENT_SOURCE_DIR}/builder.cj
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/chir_constants.cj              ${CMAKE_CURRENT_SOURCE_DIR}/constants.cj
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/chir_exception.cj              ${CMAKE_CURRENT_SOURCE_DIR}/exception.cj
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/chir_${FILENAME}_generated.cj  ${CMAKE_CURRENT_SOURCE_DIR}/${FILENAME}_generated.cj
    COMMENT "generate cangjie flatbuffers files for chir"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_custom_target(CHIR_FLATC_OUTPUTS ALL DEPENDS ${FLATC_CJ_OUTPUT})

add_subdirectory(to_string_macro)