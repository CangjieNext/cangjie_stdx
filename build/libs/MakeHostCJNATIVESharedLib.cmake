# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

# Host-arch shared libraries for macros loaded by host cjc while producing target packages.
# Needed when host OS != target OS (e.g. Linux -> Windows): target DLLs cannot be loaded by host cjc.

set(STDX_HOST_STDX_LIB_DIR "")
set(STDX_HOST_RUNTIME_LIB_DIR "")
set(STDX_HOST_SHLIB_SUFFIX "")

if(NOT CMAKE_SYSTEM_NAME STREQUAL "${CMAKE_HOST_SYSTEM_NAME}")
    if(CMAKE_HOST_WIN32)
        set(STDX_HOST_SHLIB_SUFFIX ".dll")
    elseif(CMAKE_HOST_APPLE)
        set(STDX_HOST_SHLIB_SUFFIX ".dylib")
    else()
        set(STDX_HOST_SHLIB_SUFFIX ".so")
    endif()

    set(_stdx_host_proc "${CMAKE_HOST_SYSTEM_PROCESSOR}")
    if(_stdx_host_proc STREQUAL "AMD64")
        set(_stdx_host_proc "x86_64")
    elseif(_stdx_host_proc STREQUAL "arm64")
        set(_stdx_host_proc "aarch64")
    endif()
    string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}_${_stdx_host_proc}" _stdx_host_triple_dir)
    set(STDX_HOST_CJ_LIB_DIR "${_stdx_host_triple_dir}_cjnative")
    set(STDX_HOST_STDX_LIB_DIR "${CMAKE_BINARY_DIR}/lib/${STDX_HOST_CJ_LIB_DIR}")
    set(STDX_HOST_STDX_MOD_DIR "${CMAKE_BINARY_DIR}/modules/${STDX_HOST_CJ_LIB_DIR}/stdx")
    # Host macros dlopen host libcangjie-*.so; always point at host runtime, not target.
    set(STDX_HOST_RUNTIME_LIB_DIR "$ENV{CANGJIE_HOME}/runtime/lib/${STDX_HOST_CJ_LIB_DIR}")

    find_program(STDX_HOST_C_COMPILER NAMES clang gcc cc REQUIRED)

    # Compile a stdx package for the host (no --target) and link a host shared library.
    # make_host_cangjie_shared_lib(<name> SOURCE_DIR <dir> [STDX_DEP ...] [STD_LINK ...] DEPENDS ...)
    function(make_host_cangjie_shared_lib lib_name)
        set(one_value_args SOURCE_DIR)
        set(multi_value_args DEPENDS STDX_DEP STD_LINK)
        cmake_parse_arguments(HOSTLIB "" "${one_value_args}" "${multi_value_args}" ${ARGN})

        set(_host_a "${STDX_HOST_STDX_MOD_DIR}/stdx.${lib_name}.a")
        set(_host_o "${STDX_HOST_STDX_MOD_DIR}/${lib_name}.o")
        set(_host_so "${STDX_HOST_STDX_LIB_DIR}/libstdx.${lib_name}${STDX_HOST_SHLIB_SUFFIX}")
        set(_host_target "host_stdx_${lib_name}")
        string(REPLACE "." "_" _host_target "${_host_target}")

        if(CMAKE_BUILD_TYPE MATCHES "^(Debug|RelWithDebInfo)$")
            set(_host_opt_flags -g)
            set(_host_strip_flags)
        else()
            set(_host_opt_flags -O2)
            set(_host_strip_flags -s)
        endif()

        set(_link_libs_str "")
        foreach(_dep IN LISTS HOSTLIB_STDX_DEP)
            if(CMAKE_HOST_APPLE)
                string(APPEND _link_libs_str " -lstdx.${_dep}")
            else()
                string(APPEND _link_libs_str " -l:libstdx.${_dep}${STDX_HOST_SHLIB_SUFFIX}")
            endif()
        endforeach()
        foreach(_std IN LISTS HOSTLIB_STD_LINK)
            if(CMAKE_HOST_APPLE)
                string(APPEND _link_libs_str " -lcangjie-${_std}")
            else()
                string(APPEND _link_libs_str " -l:libcangjie-${_std}${STDX_HOST_SHLIB_SUFFIX}")
            endif()
        endforeach()
        if(CMAKE_HOST_APPLE)
            string(APPEND _link_libs_str " -lcangjie-runtime -lboundscheck")
            set(_host_link_common "-dynamiclib -install_name @rpath/libstdx.${lib_name}${STDX_HOST_SHLIB_SUFFIX} -rpath @loader_path")
        else()
            string(APPEND _link_libs_str " -l:libcangjie-runtime${STDX_HOST_SHLIB_SUFFIX} -l:libboundscheck${STDX_HOST_SHLIB_SUFFIX} -lm")
            # $CANGJIE_HOME and $ORIGIN are expanded by the shell at build time.
            set(_host_link_common "-shared -Wl,-z,relro,-z,now,-z,noexecstack -Wl,-T,\$CANGJIE_HOME/lib/${STDX_HOST_CJ_LIB_DIR}/cjld.shared.lds \$CANGJIE_HOME/lib/${STDX_HOST_CJ_LIB_DIR}/cjstart.o -Wl,--hash-style=both -Wl,--no-undefined -Wl,--disable-new-dtags -Wl,-rpath=\$ORIGIN ${_host_strip_flags}")
        endif()

        string(TOLOWER "${TARGET_TRIPLE_DIRECTORY_PREFIX}_cjnative" _target_cj_lib_dir)
        set(_target_cangjie_path "${CMAKE_BINARY_DIR}/modules/${_target_cj_lib_dir}")

        set(_build_script "${CMAKE_CURRENT_BINARY_DIR}/build_${_host_target}.sh")
        file(WRITE "${_build_script}" "#!/bin/sh
set -e
if [ -z \"\$CANGJIE_HOME\" ]; then
  echo \"CANGJIE_HOME is not set\" >&2
  exit 1
fi
mkdir -p \"${STDX_HOST_STDX_MOD_DIR}\" \"${STDX_HOST_STDX_LIB_DIR}\"
export CANGJIE_PATH=\"${_target_cangjie_path}\"
export LIBRARY_PATH=\"${CMAKE_BINARY_DIR}/lib\${LIBRARY_PATH:+:\$LIBRARY_PATH}\"
cjc --no-sub-pkg --trimpath \"${CMAKE_SOURCE_DIR}/src/\" --output-type=staticlib -Woff=all ${_host_opt_flags} \\
  -p \"${HOSTLIB_SOURCE_DIR}\" --output \"${_host_a}\"
extract_dir=\"${STDX_HOST_STDX_MOD_DIR}/.extract_${_host_target}\"
rm -rf \"\$extract_dir\"
mkdir -p \"\$extract_dir\"
( cd \"\$extract_dir\" && ar x \"${_host_a}\" && mv *.o \"${_host_o}\" )
rm -rf \"\$extract_dir\"
${STDX_HOST_C_COMPILER} ${_host_link_common} -o \"${_host_so}\" \"${_host_o}\" \\
  -L\"${STDX_HOST_STDX_LIB_DIR}\" \\
  -L\"\$CANGJIE_HOME/runtime/lib/${STDX_HOST_CJ_LIB_DIR}\" \\
  -L\"\$CANGJIE_HOME/lib/${STDX_HOST_CJ_LIB_DIR}\" \\
  ${_link_libs_str}
")

        add_custom_command(
            OUTPUT ${_host_so}
            COMMAND chmod +x ${_build_script}
            COMMAND ${_build_script}
            DEPENDS ${HOSTLIB_DEPENDS} ${_build_script}
            COMMENT "Generating host libstdx.${lib_name}${STDX_HOST_SHLIB_SUFFIX}"
            VERBATIM)

        add_custom_target(${_host_target} ALL DEPENDS ${_host_so})
        set_target_properties(${_host_target} PROPERTIES CJ_LIB_OUTPUT_FILE ${_host_so})
    endfunction()
endif()
