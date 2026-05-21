# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

# Build a Cangjie package as a host-loadable dylib (CHIR plugins, plugin manager, etc.).
#
#   add_cangjie_dylib(<target>
#       OUTPUT_BASENAME <name>     # e.g. collect_aspects -> libcollect_aspects.so
#       SOURCE_DIR <dir>
#       [NO_SUB_PKG]
#       DEPENDS <targets...>
#       LINK_LIBS <cjc -l / -L flags...>)
#
function(add_cangjie_dylib target_name)
    set(options NO_SUB_PKG)
    set(one_value_args OUTPUT_BASENAME SOURCE_DIR)
    set(multi_value_args DEPENDS LINK_LIBS)
    cmake_parse_arguments(CJDYLIB "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

    if(NOT CJDYLIB_OUTPUT_BASENAME)
        message(FATAL_ERROR "add_cangjie_dylib(${target_name}): OUTPUT_BASENAME is required")
    endif()
    if(NOT CJDYLIB_SOURCE_DIR)
        message(FATAL_ERROR "add_cangjie_dylib(${target_name}): SOURCE_DIR is required")
    endif()

    set(cangjie_compiler_tool "cjc$<$<BOOL:${CMAKE_HOST_WIN32}>:.exe>")
    file(GLOB source_files CONFIGURE_DEPENDS ${CJDYLIB_SOURCE_DIR}/*.cj)

    string(TOLOWER "${TARGET_TRIPLE_DIRECTORY_PREFIX}" _cj_triple)
    set(_cj_modules_dir "${CMAKE_BINARY_DIR}/modules/${_cj_triple}_cjnative${SANITIZER_SUBPATH}")
    set(_stdx_lib_dir "${CMAKE_BINARY_DIR}/lib/${_cj_triple}_cjnative${SANITIZER_SUBPATH}")
    set(_cj_src_dir "${CMAKE_BINARY_DIR}/src")
    set(_cj_runtime_lib_dir "$ENV{CANGJIE_HOME}/runtime/lib/${_cj_triple}_cjnative${SANITIZER_SUBPATH}")
    set(output_file "${_stdx_lib_dir}/lib${CJDYLIB_OUTPUT_BASENAME}${CMAKE_SHARED_LIBRARY_SUFFIX}")

    set(cangjie_compile_flags)
    if(CMAKE_BUILD_TYPE MATCHES Debug OR CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
        list(APPEND cangjie_compile_flags "-g")
    endif()
    list(APPEND cangjie_compile_flags "--output-type=dylib" "-Woff=all")

    if(CJDYLIB_NO_SUB_PKG)
        list(APPEND cangjie_compile_flags "--no-sub-pkg")
    endif()

    if(CJDYLIB_LINK_LIBS)
        list(APPEND cangjie_compile_flags "-L" "${_stdx_lib_dir}")
        list(APPEND cangjie_compile_flags "-L" "${_cj_modules_dir}/stdx")
        list(APPEND cangjie_compile_flags ${CJDYLIB_LINK_LIBS})
    endif()
    list(APPEND cangjie_compile_flags "--import-path" "${_cj_src_dir}")

    set(COMPILE_CMD
        ${cangjie_compiler_tool}
        ${cangjie_compile_flags}
        ${source_files}
        -o ${output_file})
    if(CMAKE_CROSSCOMPILING)
        list(APPEND COMPILE_CMD "--target=${TRIPLE}")
        if(NOT ("${CANGJIE_TARGET_TOOLCHAIN}" STREQUAL ""))
            list(APPEND COMPILE_CMD "-B${CANGJIE_TARGET_TOOLCHAIN}")
        endif()
    endif()

    cj_resolve_depends(resolved_depends ${CJDYLIB_DEPENDS})

    add_custom_command(
        OUTPUT ${output_file}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${_stdx_lib_dir}
        COMMAND ${CMAKE_COMMAND} -E env
            "CANGJIE_PATH=${_cj_modules_dir}"
            "LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib"
            "LD_LIBRARY_PATH=${_stdx_lib_dir}:${_cj_runtime_lib_dir}:$ENV{LD_LIBRARY_PATH}"
            ${COMPILE_CMD}
        DEPENDS ${resolved_depends} ${source_files} ${CJDYLIB_SOURCE_DIR}
        COMMENT "Generating dylib ${target_name} (${CJDYLIB_OUTPUT_BASENAME})")

    add_custom_target(${target_name} ALL DEPENDS ${output_file})
    set_target_properties(${target_name} PROPERTIES CJ_OUTPUT_FILE ${output_file})

    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX}_${CJNATIVE_BACKEND} _cj_install_lib_dir)
        set(_cj_install_lib_dir ${_cj_install_lib_dir}${SANITIZER_SUBPATH})
        install(FILES ${output_file} DESTINATION ${_cj_install_lib_dir}/dynamic/stdx)
    endif()
endfunction()

# cjc link flag for libstdx.<name>.so in the stdx dylib directory.
function(cjc_link_stdx_dylib out_var name)
    if(DARWIN)
        set(${out_var} -lstdx.${name} PARENT_SCOPE)
    else()
        set(${out_var} -l:libstdx.${name}${CMAKE_SHARED_LIBRARY_SUFFIX} PARENT_SCOPE)
    endif()
endfunction()

# cjc link flag for lib-macro_stdx.<package> (macro packages under modules/<triple>/stdx/).
function(cjc_link_stdx_macro out_var package)
    if(DARWIN)
        set(${out_var} -l-macro_stdx.${package} PARENT_SCOPE)
    else()
        set(${out_var} -l:lib-macro_stdx.${package} PARENT_SCOPE)
    endif()
endfunction()

