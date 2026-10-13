# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

add_subdirectory(plugins)

set(ASPECT_CJ_SRCS
    aspect_cj.cj
    replace_body.cj
    rule_annotations.cj
    rule_expression.cj
    rule_graph.cj
    rule_match.cj
    rule_control.cj
    rule_wire.cj
    rule_plan.cj
    rule_collect.cj
    rule_apply.cj
    rule_context.cj
    CACHE INTERNAL "")
