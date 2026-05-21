# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

include(${CMAKE_CURRENT_SOURCE_DIR}/../AddCangjieDylib.cmake)

if(NOT DEFINED BACKEND_TYPE)
    set(BACKEND_TYPE CJNATIVE)
endif()

cjc_link_stdx_dylib(_link_chir chir)
cjc_link_stdx_dylib(_link_aspect_cj aspect_cj)
cjc_link_stdx_dylib(_link_plugin_manager plugin.manager)
cjc_link_stdx_macro(_link_plugin_macro plugin)

add_cangjie_dylib(cangjie${BACKEND_TYPE}CollectAspects
    OUTPUT_BASENAME collect_aspects
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/collect_aspects
    NO_SUB_PKG
    DEPENDS
        cangjie${BACKEND_TYPE}Chir
        chir
        cangjie${BACKEND_TYPE}AspectCj
        aspect_cj
        cangjie${BACKEND_TYPE}PluginMacro
        cangjie${BACKEND_TYPE}PluginManager
        plugin.manager
    LINK_LIBS
        ${_link_chir}
        ${_link_aspect_cj}
        ${_link_plugin_manager}
        ${_link_plugin_macro})

add_cangjie_dylib(cangjie${BACKEND_TYPE}WaveAspects
    OUTPUT_BASENAME wave_aspects
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/wave_aspects
    NO_SUB_PKG
    DEPENDS
        cangjie${BACKEND_TYPE}Chir
        chir
        cangjie${BACKEND_TYPE}AspectCj
        aspect_cj
        cangjie${BACKEND_TYPE}PluginMacro
    LINK_LIBS
        ${_link_chir}
        ${_link_aspect_cj}
        ${_link_plugin_macro})
