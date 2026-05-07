#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

import sys

src, dst = sys.argv[1], sys.argv[2]
patch = '        if (offsetVal == 0) {\n            return 0\n        }\n        '
lines = open(src).read().replace('std.ast', 'stdx.chir').splitlines(True)
out = []
in_target = False
for line in lines:
    if 'func getVectorLenBySlot' in line or 'func getVectorStartBySlot' in line:
        in_target = True
    if in_target and 'let lenPos' in line:
        out.append(patch + line.lstrip())
        in_target = False
    else:
        out.append(line)
open(dst, 'w').write(''.join(out))
