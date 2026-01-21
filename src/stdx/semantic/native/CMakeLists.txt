# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

# Generate cpp code for semantic using flatc with cpp backend.
set(SCHEMA_SRC SemanticType.fbs)
get_filename_component(FILENAME ${SCHEMA_SRC} NAME_WE)
set(FLATC_EXECUTABLE "${CMAKE_BINARY_DIR}/bin/flatc")
set(FLATBUFFER_SRC ${CMAKE_CURRENT_SOURCE_DIR}/../../../../third_party/flatbuffers)

if(IOS)
    get_directory_property(SRC_COMPILE_OPTIONS COMPILE_OPTIONS)
    list(REMOVE_ITEM SRC_COMPILE_OPTIONS "--target=${TRIPLE}")
    set_directory_properties(PROPERTIES COMPILE_OPTIONS "${SRC_COMPILE_OPTIONS}")
    add_compile_options(--target=${CXX_COMPATIABLE_TRIPLE})
endif()

set(FLATC_CPP_OUTPUT_SEMA "${CMAKE_BINARY_DIR}/include/flatbuffers/${FILENAME}_generated.h")
add_custom_command(
    OUTPUT ${FLATC_CPP_OUTPUT_SEMA}
    COMMAND ${FLATC_EXECUTABLE} ARGS --no-warnings -c -o "${CMAKE_BINARY_DIR}/include/flatbuffers" ${SCHEMA_SRC}
    DEPENDS flatbuffers ${SCHEMA_SRC} # flatc defined in flatbuffers project: add_executable(flatc..)
    COMMENT "generate cpp file using flatc"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

# Generate cangjie code for semantic using flatc with cangjie backend.
set(FLATC_CJ_OUTPUT_SEMA "${CMAKE_BINARY_DIR}/${FILENAME}_generated.cj")
set(FLATBUFFER_DEPEND_CJ_DIR ${FLATBUFFER_SRC}/cangjie)
add_custom_command(
    OUTPUT ${FLATC_CJ_OUTPUT_SEMA}
    COMMAND ${FLATC_EXECUTABLE} ARGS --no-warnings --cangjie -o "${CMAKE_BINARY_DIR}" ${SCHEMA_SRC}
    DEPENDS flatbuffers ${SCHEMA_SRC} # flatc defined in flatbuffers project: add_executable(flatc..)

    COMMAND sed 's/std.ast/stdx.semantic/g' ${FLATBUFFER_DEPEND_CJ_DIR}/flatbuffer_object.cj > ${CMAKE_BINARY_DIR}/flatbuffer_object_semantic.cj
    COMMAND sed 's/std.ast/stdx.semantic/g' ${FLATBUFFER_DEPEND_CJ_DIR}/decode.cj > ${CMAKE_BINARY_DIR}/decode_semantic.cj
    COMMAND sed 's/std.ast/stdx.semantic/g' ${FLATBUFFER_DEPEND_CJ_DIR}/table.cj > ${CMAKE_BINARY_DIR}/table_semantic.cj
    COMMAND sed 's/std.ast/stdx.semantic/g' ${FLATBUFFER_DEPEND_CJ_DIR}/builder.cj > ${CMAKE_BINARY_DIR}/builder_semantic.cj
    COMMAND sed 's/std.ast/stdx.semantic/g' ${FLATBUFFER_DEPEND_CJ_DIR}/constants.cj > ${CMAKE_BINARY_DIR}/constants_semantic.cj
    COMMAND sed 's/std.ast/stdx.semantic/g' ${FLATBUFFER_DEPEND_CJ_DIR}/exception.cj > ${CMAKE_BINARY_DIR}/exception_semantic.cj
    COMMAND sed 's/std.ast/stdx.semantic/g' ${CMAKE_BINARY_DIR}/${FILENAME}_generated.cj > ${CMAKE_BINARY_DIR}/${FILENAME}_generated_semantic.cj
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/flatbuffer_object_semantic.cj
            ${CMAKE_SOURCE_DIR}/src/stdx/semantic/
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/decode_semantic.cj
            ${CMAKE_SOURCE_DIR}/src/stdx/semantic/
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/table_semantic.cj
            ${CMAKE_SOURCE_DIR}/src/stdx/semantic/
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/builder_semantic.cj
            ${CMAKE_SOURCE_DIR}/src/stdx/semantic/
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/constants_semantic.cj
            ${CMAKE_SOURCE_DIR}/src/stdx/semantic/
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/exception_semantic.cj
            ${CMAKE_SOURCE_DIR}/src/stdx/semantic/
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/${FILENAME}_generated_semantic.cj
            ${CMAKE_SOURCE_DIR}/src/stdx/semantic/${FILENAME}_generated.cj
    COMMENT "generate cangjie file using flatc"

    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_custom_target(FLATC_OUTPUTS_SEMA ALL DEPENDS ${FLATC_CJ_OUTPUT_SEMA} ${FLATC_CPP_OUTPUT_SEMA})


# build semantic ffi lib shared
file(GLOB semantic_ffi_src
    analyze.cpp
    typeWrite.cpp)
set(libname stdx.semanticFFI)
add_library(${libname} SHARED ${semantic_ffi_src})
set_target_properties(${libname} PROPERTIES COMPILE_FLAGS "-fPIC")
add_dependencies(${libname} FLATC_OUTPUTS_SEMA)

set(CANGJIE_INC_DIR)
set(AST_SUPPORT_LIB_DIR)
set(LSP_LIB_DIR)
# using CANGJIE_HOME or cangjie source directory
if(DEFINED ENV{CANGJIE_HOME})
    if ("$ENV{CANGJIE_LSP_PATH}" STREQUAL "")
        set(LSP_LIB_DIR $ENV{CANGJIE_HOME}/tools/lib)
    else()
        set(LSP_LIB_DIR $ENV{CANGJIE_LSP_PATH})
    endif()
    string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX}_${CJNATIVE_BACKEND} output_cj_lib_dir)
    set(AST_SUPPORT_LIB_DIR $ENV{CANGJIE_HOME}/lib/${output_cj_lib_dir})
    set(CANGJIE_INC_DIR $ENV{CANGJIE_HOME}/include)
    if(NOT EXISTS "${CANGJIE_INC_DIR}/cangjie")
        # using local cangjie source
        set(CANGJIE_INC_DIR ~/dev/cangjie/cangjie/include)
        if(NOT EXISTS "${CANGJIE_INC_DIR}/cangjie")
            message(FATAL_ERROR "NOT FOUND CANGJIE HEADERS")
        endif()
    endif()
else()
    message(FATAL_ERROR "NOT FOUND CJC")
endif()

target_compile_options(${libname} PRIVATE ${CMAKE_C_COVERAGE_FLAGS})
target_include_directories(${libname} PRIVATE ${CANGJIE_INC_DIR} ${CMAKE_BINARY_DIR}/include )
if(CANGJIE_BUILD_STDLIB_WITH_COVERAGE)
    target_compile_options(${libname} PUBLIC "-fno-exceptions")
    target_compile_definitions(${libname} PRIVATE CANGJIE_ENABLE_GCOV)
endif()

target_link_directories(${libname} PRIVATE ${LSP_LIB_DIR})
target_link_libraries(${libname} PRIVATE cangjie-lsp)

# install for dynamic and static lib
install_cangjie_library_ffi(${libname})
install_cangjie_library_ffi_s(${libname})