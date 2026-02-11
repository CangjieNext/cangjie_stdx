# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

if ("$ENV{CANGJIE_HOME}" STREQUAL "")
    message(FATAL_ERROR "\n##### Please confirm cjc is well configured in current environment. #####")
endif()

FILE(GLOB PLUGIN_SRC ./CollectAspects.cpp)
set(LIB_NAME collect-aspects)

add_library(${LIB_NAME} SHARED ${PLUGIN_SRC})
set_target_properties(${LIB_NAME} PROPERTIES COMPILE_FLAGS "-fPIC")

if ("$ENV{CANGJIE_LSP_PATH}" STREQUAL "")
    target_link_directories(${LIB_NAME} PRIVATE $ENV{CANGJIE_HOME}/tools/lib)
else()
    target_link_directories(${LIB_NAME} PRIVATE $ENV{CANGJIE_LSP_PATH})
endif()

if(DARWIN)
    target_link_options(${LIB_NAME} PRIVATE "-Wl,-flat_namespace")
endif()

target_link_libraries(${LIB_NAME} PRIVATE cangjie-lsp)

install_cangjie_library_ffi(${LIB_NAME})
install_cangjie_library_ffi_s(${LIB_NAME})
