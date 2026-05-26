# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

set(CANGJIE_LIB_DIR "modules")
string(TOLOWER "${CMAKE_BUILD_TYPE}" lowercase_build_type)
function(add_cangjie_library target_name
)
    set(options
        IS_PACKAGE
        IS_STDXLIB
        IS_CJNATIVE_BACKEND
        NO_SUB_PKG)
    set(one_value_args
        OUTPUT_NAME
        OUTPUT_DIR
        PACKAGE_NAME
        MODULE_NAME
        SOURCE_DIR)
    set(multi_value_args SOURCES DEPENDS FFI)
    cmake_parse_arguments(
        CANGJIELIB
        "${options}"
        "${one_value_args}"
        "${multi_value_args}"
        ${ARGN})

    # The pre-process source files
    set(source_files)
    foreach(file ${CANGJIELIB_SOURCES})
        get_filename_component(file_path ${file} PATH)
        if(IS_ABSOLUTE "${file_path}")
            list(APPEND source_files "${file}")
        else()
            list(APPEND source_files "${CANGJIELIB_SOURCE_DIR}/${file}")
        endif()
    endforeach()

    set(BACKEND)
    if(CANGJIELIB_IS_CJNATIVE_BACKEND)
        set(BACKEND "cjnative")
    endif()
    # Set output directory
    set(output_dir)
    set(output_bc_dir)
    if(CANGJIELIB_IS_STDXLIB)
        if(NOT ("${CANGJIELIB_MODULE_NAME}" STREQUAL ""))
            set(output_dir "${CANGJIE_LIB_DIR}/${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND}/${CANGJIELIB_MODULE_NAME}")
            set(output_bc_dir "${CANGJIE_LIB_DIR}/${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND}_bc/${CANGJIELIB_MODULE_NAME}")
        else()
            set(output_dir "${CANGJIE_LIB_DIR}/${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND}")
            set(output_bc_dir "${CANGJIE_LIB_DIR}/${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND}_bc")
        endif()
        if(NOT ("${CANGJIELIB_OUTPUT_DIR}" STREQUAL ""))
            set(output_dir "${output_dir}/${CANGJIELIB_OUTPUT_DIR}")
            set(output_bc_dir "${output_bc_dir}/${CANGJIELIB_OUTPUT_DIR}")
        endif()
    endif()

    set(cangjie_compile_flags)
    if(CMAKE_BUILD_TYPE MATCHES Debug)
        list(APPEND cangjie_compile_flags "-g")
    elseif(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
        list(APPEND cangjie_compile_flags "-g")
        if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
            # The -g will enable aggressive-parallel-compile, so we need limit --apc to 1 to disable it forcibly.
            list(APPEND cangjie_compile_flags "--apc=1")
        endif()
    else()
       if(NOT CANGJIE_BUILD_STDLIB_WITH_COVERAGE)
            list(APPEND cangjie_compile_flags "--trimpath")
            list(APPEND cangjie_compile_flags "${CMAKE_SOURCE_DIR}/src/")
        endif()
    endif()

    if(NOT ("${CANGJIELIB_MODULE_NAME}" STREQUAL ""))
        set(output_full_name "${CMAKE_BINARY_DIR}/${output_dir}/${CANGJIELIB_MODULE_NAME}.${CANGJIELIB_PACKAGE_NAME}")
    else()
        set(output_full_name "${CMAKE_BINARY_DIR}/${output_dir}/${CANGJIELIB_PACKAGE_NAME}")
    endif()

    set(output_full_name_prefix "${CMAKE_BINARY_DIR}/${output_dir}/${CANGJIELIB_PACKAGE_NAME}")
    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        set(output_full_name "${output_full_name}.a") # Set output path and output name
        if(NOT ("${CANGJIELIB_MODULE_NAME}" STREQUAL ""))
            set(output_lto_bc_full_name "${CMAKE_BINARY_DIR}/${output_bc_dir}/lib${CANGJIELIB_MODULE_NAME}.${CANGJIELIB_PACKAGE_NAME}")
        else()
            set(output_lto_bc_full_name "${CMAKE_BINARY_DIR}/${output_bc_dir}/lib${CANGJIELIB_PACKAGE_NAME}")
        endif()
        set(output_lto_bc_full_name "${output_lto_bc_full_name}.bc") # Set output path and output name
    endif()

    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        list(APPEND cangjie_compile_flags "--output-type=staticlib")
    endif()

    if(TRIPLE STREQUAL "arm-linux-ohos")
        list(APPEND cangjie_compile_flags "--disable-reflection")
    endif()

    # Set compiler path
    if(CMAKE_CROSSCOMPILING)
        set(CANGJIE_NATIVE_CANGJIE_TOOLS_PATH ${CMAKE_BINARY_DIR}/../build/bin)
    endif()
    # Do not use ${CMAKE_EXECUTABLE_SUFFIX} here, because its value is determined by the target platform, not the host.
    # Determine the suffix according to the host instead.
    set(cangjie_compiler_tool "cjc$<$<BOOL:${CMAKE_HOST_WIN32}>:.exe>")

    # Set no-sub-pkg
    if(CANGJIELIB_NO_SUB_PKG)
        set(no_sub_pkg "--no-sub-pkg")
    endif()

    set(output_argument "--output") # Output argument to specify the output file dir and name
    set(module_name_argument) # Module name argument to specify which module the project belongs to
    set(CJNATIVE_PATH)
    # Use the installed llvm tools,
    # in case the backend is compiled from source in previous native-building step
    set(CJNATIVE_PATH $ENV{CANGJIE_HOME}/third_party/llvm/bin)
    set(COMPILE_CMD)
    if(CANGJIELIB_IS_PACKAGE)
        set(COMPILE_CMD
            ${cangjie_compiler_tool}
            ${no_prelude}
            ${no_sub_pkg}
            ${cangjie_compile_flags}
            -p
            ${CANGJIELIB_SOURCE_DIR}
            ${module_name_argument})
    else()
        set(COMPILE_CMD
            ${cangjie_compiler_tool}
            ${no_prelude}
            ${cangjie_compile_flags}
            ${source_files}
            ${module_name_argument})
    endif()
    if(CMAKE_CROSSCOMPILING)
        set(COMPILE_CMD ${COMPILE_CMD} "--target=${TRIPLE}")
        if(NOT ("${CANGJIE_TARGET_TOOLCHAIN}" STREQUAL ""))
            set(COMPILE_CMD ${COMPILE_CMD} "-B${CANGJIE_TARGET_TOOLCHAIN}")
        endif()
    endif()

    list(APPEND COMPILE_CMD "-Woff=all")

    foreach(build_args ${CANGJIE_BUILD_ARGS})
        list(APPEND COMPILE_CMD "${build_args}")
    endforeach()

    set(COMPILE_BC_CMD
        ${COMPILE_CMD}
        --lto=full
        ${output_argument}
        ${output_lto_bc_full_name})
    set(COMPILE_CMD ${COMPILE_CMD} ${output_argument} ${output_full_name})
    
    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        if(TRIPLE STREQUAL "arm-linux-ohos")
            list(APPEND COMPILE_CMD "$<IF:$<CONFIG:MinSizeRel>,-Os,-O0>")
            # .bc files is for LTO mode and LTO mode does not support -Os and -Oz.
            list(APPEND COMPILE_BC_CMD "-O0")
        else()
            list(APPEND COMPILE_CMD "$<IF:$<CONFIG:MinSizeRel>,-Os,-O2>")
            # The .bc files is for LTO mode and LTO mode does not support -Os and -Oz.
            list(APPEND COMPILE_BC_CMD "-O2")
        endif()
    endif()
    
    if(CANGJIE_BUILD_STDLIB_WITH_COVERAGE)
        list(APPEND COMPILE_CMD "--coverage")
    endif()

    set(ENV{LD_LIBRARY_PATH} $ENV{LD_LIBRARY_PATH}:${CMAKE_BINARY_DIR}/lib)
    string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND} output_cj_lib_dir)
    if(NOT CMAKE_BUILD_STAGE STREQUAL "postBuild")
        add_custom_target(
            ${target_name} ALL
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/${output_dir}
            COMMAND ${CMAKE_COMMAND} -E env "CANGJIE_PATH=${CMAKE_BINARY_DIR}/modules/${output_cj_lib_dir}"  "LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib"
                    ${COMPILE_CMD}
            BYPRODUCTS ${output_full_name}
            DEPENDS ${CANGJIELIB_DEPENDS} ${CANGJIELIB_SOURCE_DIR}
            COMMENT "Generating ${target_name}")
    endif()
    if(CMAKE_BUILD_STAGE STREQUAL "postBuild")
        set(bc_depends ${CANGJIELIB_DEPENDS} ${CANGJIELIB_SOURCE_DIR})
        if(CMAKE_CROSSCOMPILING)
            set(bc_cangjie_path ${CMAKE_SOURCE_DIR}/${target_dir}/${TRIPLE}/${lowercase_build_type}/stdx)
        else()
            set(bc_cangjie_path ${CMAKE_SOURCE_DIR}/${target_dir}/${lowercase_build_type}/stdx)
        endif()
    else()
        set(bc_depends ${CANGJIELIB_DEPENDS} ${CANGJIELIB_SOURCE_DIR} ${target_name})
        set(bc_cangjie_path ${CMAKE_BINARY_DIR}/modules/${output_cj_lib_dir})
    endif()
    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND
       AND NOT WIN32
       AND NOT DARWIN)
        add_custom_target(
            ${target_name}_bc ALL
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/${output_bc_dir}
            COMMAND ${CMAKE_COMMAND} -E env "CANGJIE_PATH=${bc_cangjie_path}" "LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib"
                     ${COMPILE_BC_CMD}
            BYPRODUCTS ${output_lto_bc_full_name}
            # The ${target_name}_bc depends on ${target_name} so they will not run simultaneously. <target> and <target>_bc
            # compile the same package, which means they may write the same bc cache file. Running simultaneously
            # may cause IO error on windows in some cases.
            DEPENDS ${bc_depends}
            COMMENT "Generating ${target_name}_bc")
    endif()

    if(NOT CMAKE_BUILD_STAGE STREQUAL "postBuild")
        if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
            set(TARGET_AR ar)
            if(CMAKE_CROSSCOMPILING)
                if(IOS)
                    set(TARGET_AR ${CANGJIE_TARGET_TOOLCHAIN}/ar)
                elseif(CMAKE_C_COMPILER_ID STREQUAL "Clang")
                    set(TARGET_AR ${CANGJIE_TARGET_TOOLCHAIN}/llvm-ar)
                else()
                    set(TARGET_AR ${CANGJIE_TARGET_TOOLCHAIN}/${TRIPLE}-ar)
                endif()
            endif()
            if(CMAKE_HOST_UNIX)
                set(MOVE_CMD mv)
            elseif(CMAKE_HOST_WIN32)
                set(MOVE_CMD move)
            endif()
            add_custom_command(
                TARGET ${target_name}
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E make_directory ${target_name} && cd ${target_name}
                COMMAND ${CMAKE_COMMAND} -E remove_directory tmp
                COMMAND ${CMAKE_COMMAND} -E make_directory tmp && cd tmp
                COMMAND ${TARGET_AR} x ${output_full_name}
                COMMAND ${MOVE_CMD} *.o ${output_full_name_prefix}.o
                COMMAND cd ..
                COMMAND ${CMAKE_COMMAND} -E remove_directory tmp
                BYPRODUCTS ${output_full_name_prefix}.o)
        endif()
    endif()

    # Install
    if(NOT ("${CANGJIELIB_MODULE_NAME}" STREQUAL ""))
        set(file_name "${CANGJIELIB_MODULE_NAME}.${CANGJIELIB_PACKAGE_NAME}")
    else()
        set(file_name "${CANGJIELIB_PACKAGE_NAME}")
    endif()
    if(CMAKE_BUILD_STAGE STREQUAL "postBuild")
        if(CMAKE_CROSSCOMPILING)
            if(${CANGJIELIB_PACKAGE_NAME} STREQUAL "actors.macros")
                set(install_files "${CANGJIE_CJPM_DIR}/${target_dir}/${lowercase_build_type}/stdx/${file_name}.cjo")
            else()
                set(install_files "${CANGJIE_CJPM_DIR}/${target_dir}/${TRIPLE}/${lowercase_build_type}/stdx/${file_name}.cjo")
            endif()
        else()
            set(install_files "${CANGJIE_CJPM_DIR}/${target_dir}/${lowercase_build_type}/stdx/${file_name}.cjo")
        endif()
    else()
        set(install_files "${CMAKE_BINARY_DIR}/${output_dir}/${file_name}.cjo")
    endif()
    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
    else()
        list(APPEND install_files "${CMAKE_BINARY_DIR}/${output_dir}/${file_name}.bchir")
        list(APPEND install_files "${CMAKE_BINARY_DIR}/${output_dir}/${file_name}.pdba")
    endif()

    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND
       AND NOT WIN32
       AND NOT DARWIN)
        list(APPEND install_files ${output_lto_bc_full_name})
    endif()
    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        install(FILES ${install_files} DESTINATION "${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND}/static/stdx")
        install(FILES ${install_files} DESTINATION "${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND}/dynamic/stdx")
    endif()
endfunction()

set(CJNATIVE_BACKEND "cjnative")
# Install cangjie library FFI
function(install_cangjie_library_ffi lib_name)
    # Set install dir
    string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX} output_lib_dir)
    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        if(DEFINED CANGJIE_CJPM_BUILD_SELF)
            if(CANGJIE_CJPM_BUILD_SELF)
                install(TARGETS ${lib_name} DESTINATION ${output_lib_dir}_${CJNATIVE_BACKEND}/static/stdx)
            else()
                install(TARGETS ${lib_name} DESTINATION "stdx")
            endif()
        else()
            install(TARGETS ${lib_name} DESTINATION ${output_lib_dir}_${CJNATIVE_BACKEND}/static/stdx)
        endif()
    endif()
endfunction()

function(install_cangjie_library_ffi_s lib_name)
    # Set install dir
    string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX} output_lib_dir)
    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        if(DEFINED CANGJIE_CJPM_BUILD_SELF)
            if(CANGJIE_CJPM_BUILD_SELF)
                install(TARGETS ${lib_name} DESTINATION ${output_lib_dir}_${CJNATIVE_BACKEND}/static/stdx)
            else()
                install(TARGETS ${lib_name} DESTINATION "stdx")
            endif()
        else()
            install(TARGETS ${lib_name} DESTINATION ${output_lib_dir}_${CJNATIVE_BACKEND}/dynamic/stdx)
        endif()
    endif()
endfunction()
