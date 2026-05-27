# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# Copy the macro dylib produced by `cjc --compile-macro` to the modules tree.
# cjc may emit the file with or without a platform suffix, and not always in SRC_DIR.

if(NOT DEFINED SRC_DIR OR NOT DEFINED macro_basename OR NOT DEFINED DEST)
    message(FATAL_ERROR "CopyCangjieMacroOutput.cmake requires SRC_DIR, macro_basename and DEST")
endif()

set(_suffixes "")
if(DEFINED macro_suffix AND NOT "${macro_suffix}" STREQUAL "")
    list(APPEND _suffixes "${macro_suffix}")
endif()
list(APPEND _suffixes ".so" ".dll" ".dylib" "")

set(_dirs "${SRC_DIR}")
if(DEFINED SRC_DIR2 AND NOT "${SRC_DIR2}" STREQUAL "")
    list(APPEND _dirs "${SRC_DIR2}")
endif()

foreach(_dir IN LISTS _dirs)
    foreach(_suffix IN LISTS _suffixes)
        set(_candidate "${_dir}/${macro_basename}${_suffix}")
        if(EXISTS "${_candidate}")
            execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different "${_candidate}" "${DEST}")
            return()
        endif()
    endforeach()
endforeach()

message(FATAL_ERROR "Macro library '${macro_basename}' not found under ${SRC_DIR}")
