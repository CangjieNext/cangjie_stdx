# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

add_subdirectory(dynamicLoader)
add_subdirectory(compress)
add_subdirectory(serialization)
add_subdirectory(encoding)
if(NOT CANGJIE_CJPM_BUILD_TYPE OR NOT WIN32)
    add_subdirectory(fuzz)
endif()
add_subdirectory(log)
add_subdirectory(logger)
add_subdirectory(crypto)
add_subdirectory(net)
add_subdirectory(unittest)
add_subdirectory(actors)
add_subdirectory(string_intern)

if(CANGJIE_CODEGEN_CJNATIVE_BACKEND AND "$ENV{NO_ASPECTCJ}" STREQUAL "" AND NOT CANGJIE_CJPM_BUILD_TYPE)
    if(CMAKE_CROSSCOMPILING)
        if ("$ENV{CANGJIE_LSP_PATH}" STREQUAL "")
            # Nothing to do
        else()
            add_subdirectory(aspectCJ)
        endif()
    else()
        add_subdirectory(aspectCJ)
    endif()
endif()

if(NOT CANGJIE_BUILD_WITHOUT_EFFECT_HANDLERS)
    add_subdirectory(effect)
endif()
