# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

set(SEGTREE_CJ_SOURCES
    segment_tree.cj
)

cangjie_add_module(stdx_segtree STATIC SHARED
    SOURCES
        
)
