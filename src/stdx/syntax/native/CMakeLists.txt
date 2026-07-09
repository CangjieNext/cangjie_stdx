# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

include(CangjieFlatbuffers)

# flatc, SyntaxFormat.fbs and flatbuffers cangjie runtime come from the compiler SDK
# (SyntaxFormat.fbs is owned by stdx under schema/).
set(SCHEMA_SRC ${CMAKE_SOURCE_DIR}/schema/SyntaxFormat.fbs)
get_filename_component(FILENAME ${SCHEMA_SRC} NAME_WE)

if(NOT EXISTS ${SCHEMA_SRC})
    message(FATAL_ERROR "SyntaxFormat.fbs not found: ${SCHEMA_SRC}")
endif()

if(IOS)
    get_directory_property(SRC_COMPILE_OPTIONS COMPILE_OPTIONS)
    list(REMOVE_ITEM SRC_COMPILE_OPTIONS "--target=${TRIPLE}")
    set_directory_properties(PROPERTIES COMPILE_OPTIONS "${SRC_COMPILE_OPTIONS}")
    add_compile_options(--target=${CXX_COMPATIABLE_TRIPLE})
endif()

# Generate cpp code for syntax using flatc with cpp backend.
set(FLATC_CPP_OUTPUT "${CMAKE_BINARY_DIR}/include/flatbuffers/${FILENAME}_generated.h")
add_custom_command(
    OUTPUT ${FLATC_CPP_OUTPUT}
    COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/include/flatbuffers"
    COMMAND ${CANGJIE_FLATBUFFERS_FLATC} ARGS --no-warnings -c -o "${CMAKE_BINARY_DIR}/include/flatbuffers" ${SCHEMA_SRC}
    DEPENDS ${SCHEMA_SRC} ${CANGJIE_FLATBUFFERS_FLATC}
    COMMENT "generate cpp file using flatc"
    WORKING_DIRECTORY ${CANGJIE_FLATBUFFERS_DIR})

# Generate cangjie code for syntax using flatc with cangjie backend.
# Only *_generated.cj is produced; runtime lives in package flatbuffers (same as std.ast).
set(FLATC_CJ_OUTPUT "${CMAKE_BINARY_DIR}/${FILENAME}_generated.cj")
set(SYNTAX_GENERATED_CJ "${CMAKE_SOURCE_DIR}/src/stdx/syntax/${FILENAME}_generated.cj")
add_custom_command(
    OUTPUT ${FLATC_CJ_OUTPUT} ${SYNTAX_GENERATED_CJ}
    COMMAND ${CANGJIE_FLATBUFFERS_FLATC} ARGS --no-warnings --cangjie -o "${CMAKE_BINARY_DIR}" ${SCHEMA_SRC}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${FLATC_CJ_OUTPUT} ${SYNTAX_GENERATED_CJ}
    DEPENDS ${SCHEMA_SRC} ${CANGJIE_FLATBUFFERS_FLATC}
    COMMENT "generate and install SyntaxFormat_generated.cj"
    WORKING_DIRECTORY ${CANGJIE_FLATBUFFERS_DIR})

add_custom_target(FLATC_OUTPUTS ALL DEPENDS ${FLATC_CJ_OUTPUT} ${FLATC_CPP_OUTPUT} ${SYNTAX_GENERATED_CJ})

# build syntax ffi lib using object library
file(GLOB synatx_ffi_src
    AstApi.cpp
    NodeWriter.cpp
    ExprWriter.cpp
    TokenWriter.cpp
    ParserSyntax.cpp
    ParserSyntaxImpl.cpp)
set(libname stdx.syntaxFFI)

# Create object library
add_library(${libname}-objs OBJECT ${synatx_ffi_src})
set_target_properties(${libname}-objs PROPERTIES COMPILE_FLAGS "-fPIC")
add_dependencies(${libname}-objs FLATC_OUTPUTS)

# Build static library
add_library(${libname} STATIC $<TARGET_OBJECTS:${libname}-objs>)
add_dependencies(${libname} FLATC_OUTPUTS)

set(CANGJIE_INC_DIR)
set(AST_SUPPORT_LIB_DIR)
set(LSP_LIB_DIR)
if ("$ENV{CANGJIE_LSP_PATH}" STREQUAL "")
    set(LSP_LIB_DIR ${CANGJIE_HOME}/tools/lib)
else()
    set(LSP_LIB_DIR $ENV{CANGJIE_LSP_PATH})
endif()
string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX}_${CJNATIVE_BACKEND} output_cj_lib_dir)
set(AST_SUPPORT_LIB_DIR ${CANGJIE_HOME}/lib/${output_cj_lib_dir})
set(CANGJIE_INC_DIR ${CANGJIE_HOME}/include)
if(NOT EXISTS "${CANGJIE_INC_DIR}/cangjie")
    message(FATAL_ERROR "Cangjie headers not found: ${CANGJIE_INC_DIR}/cangjie")
endif()

target_compile_options(${libname}-objs PRIVATE ${CMAKE_C_COVERAGE_FLAGS})
target_include_directories(${libname}-objs PRIVATE
    ${CANGJIE_INC_DIR}
    ${CANGJIE_FLATBUFFERS_CPP_INCLUDE}
    ${CMAKE_BINARY_DIR}/include)
if(CANGJIE_BUILD_STDLIB_WITH_COVERAGE)
    target_compile_options(${libname}-objs PUBLIC "-fno-exceptions")
    target_compile_definitions(${libname}-objs PRIVATE CANGJIE_ENABLE_GCOV)
endif()

if(DARWIN)
    if (IOS)
        string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX}_${CJNATIVE_BACKEND} output_cj_lib_dir)
        set(AST_LIB_DIR ${CANGJIE_HOME}/runtime/lib/${output_cj_lib_dir})

        add_library(cangjie-link-ast SHARED IMPORTED)
        set_target_properties(cangjie-link-ast PROPERTIES IMPORTED_LOCATION ${AST_LIB_DIR}/libcangjie-std-ast.dylib)
        target_link_libraries(${libname} PUBLIC cangjie-link-ast)
    else()

        add_library(cangjie-lsp SHARED IMPORTED)
        set_target_properties(cangjie-lsp PROPERTIES IMPORTED_LOCATION ${LSP_LIB_DIR}/libcangjie-lsp.dylib)
        target_link_libraries(${libname} PUBLIC cangjie-lsp)
    endif()
else()
    if (MINGW)
        add_library(cangjie-lsp SHARED IMPORTED)
        set_target_properties(cangjie-lsp PROPERTIES IMPORTED_IMPLIB ${LSP_LIB_DIR}/libcangjie-lsp.dll.a)
        target_link_libraries(${libname} PUBLIC cangjie-lsp)
    endif()
endif()

# install for dynamic and static lib
install_cangjie_library_ffi(${libname})
install_cangjie_library_ffi_s(${libname})
