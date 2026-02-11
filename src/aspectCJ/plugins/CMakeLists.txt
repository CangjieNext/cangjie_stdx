# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

if(EXISTS "$ENV{CANGJIE_HOME}/include/cangjie")
    include_directories($ENV{CANGJIE_HOME}/include)
    add_subdirectory(CollectAspects)
    add_subdirectory(WaveAspects)
else()
    message(FATAL_ERROR "cannot find Cangjie include directory in {CANGJIE_HOME}")
endif()
