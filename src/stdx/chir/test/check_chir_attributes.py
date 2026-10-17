#!/usr/bin/env python3
# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

"""Check stdx CHIR Attribute against the compiler SDK.

The compiler installs include/cangjie/CHIR/IR/AttributeInfo.h into CANGJIE_HOME.
This script reads that installed header and the attribute.cj next to this test.
It does not look for a compiler source checkout.
"""

import os
import re
import sys
from pathlib import Path

STDX_ATTRIBUTE = Path(__file__).resolve().parent.parent / "attribute.cj"


def fail(message):
    print("check_chir_attributes: " + message, file=sys.stderr)
    return 1


def read_header():
    home = os.environ.get("CANGJIE_HOME", "")
    if not home:
        raise SystemExit(fail("CANGJIE_HOME is not set; cannot read the compiler SDK Attribute enum."))
    header = Path(home) / "include" / "cangjie" / "CHIR" / "IR" / "AttributeInfo.h"
    if not header.is_file():
        raise SystemExit(fail(
            "compiler SDK header not found: %s. Install the compiler SDK that matches this stdx." % header))
    return header.read_text(encoding="utf-8")


def compiler_attributes(header_text):
    body = header_text.split("enum class Attribute {", 1)[1].split("ATTR_END", 1)[0]
    names = []
    for line in body.splitlines():
        line = line.split("//", 1)[0].split("/*", 1)[0]
        match = re.match(r"\s*([A-Z][A-Z0-9_]*)\s*,", line)
        if match:
            names.append(match.group(1))
    texts = dict(re.findall(r'Attribute::([A-Z0-9_]+),\s*"([^"]+)"', header_text))
    missing = [name for name in names if name not in texts]
    extra = [name for name in texts if name not in names]
    if missing or extra or len(texts) != len(names):
        raise SystemExit(fail(
            "compiler SDK Attribute enum and ATTR_TO_STRING disagree. missing=%s extra=%s"
            % (missing, extra)))
    return [texts[name] for name in names]


def stdx_attributes(text):
    enum_body = text.split("enum Attribute", 1)[1].split("func toString", 1)[0]
    order = []
    for line in enum_body.splitlines():
        code = line.split("//", 1)[0]
        match = re.match(r"\s*([A-Za-z_][A-Za-z0-9_]*)\s*\|", code)
        if match:
            order.append(match.group(1))
        elif re.match(r"\s*AttrEnd\b", code):
            order.append("AttrEnd")
    order = [name for name in order if name not in ("AttrBegin", "AttrEnd")]

    to_string = text.split("func toString", 1)[1].split("func getNextAttribute", 1)[0]
    texts = {}
    for line in to_string.splitlines():
        if "|" in line:
            continue
        match = re.search(r'case\s+([A-Za-z0-9_]+)\s*=>\s*"([^"]+)"', line)
        if match:
            texts[match.group(1)] = match.group(2)

    bit_body = text.split("func toUInt64", 1)[1].split("struct AttributeInfo", 1)[0]
    bits = {}
    for line in bit_body.splitlines():
        match = re.search(r"case\s+([A-Za-z0-9_]+)\s*=>\s*(-?\d+)", line)
        if match and match.group(1) not in ("AttrBegin", "AttrEnd"):
            bits[match.group(1)] = int(match.group(2))

    next_body = text.split("func getNextAttribute", 1)[1].split("func toUInt64", 1)[0]
    nxt = {}
    for line in next_body.splitlines():
        match = re.search(r"case\s+([A-Za-z0-9_]+)\s*=>\s*([A-Za-z0-9_]+)", line)
        if match and match.group(1) not in ("AttrBegin", "AttrEnd"):
            nxt[match.group(1)] = match.group(2)
    return order, texts, bits, nxt


def main():
    if not STDX_ATTRIBUTE.is_file():
        return fail("stdx attribute source missing next to this script: %s" % STDX_ATTRIBUTE)
    compiler = compiler_attributes(read_header())
    order, texts, bits, nxt = stdx_attributes(STDX_ATTRIBUTE.read_text(encoding="utf-8"))
    if len(order) != len(compiler):
        return fail("attribute count differs: stdx %d, compiler SDK %d" % (len(order), len(compiler)))
    for index, (name, expected) in enumerate(zip(order, compiler)):
        if texts.get(name) != expected:
            return fail("attribute %d %s text is %r, compiler SDK is %r" % (index, name, texts.get(name), expected))
        if bits.get(name) != index:
            return fail("attribute %s bit is %s, compiler SDK ordinal is %d" % (name, bits.get(name), index))
        expected_next = order[index + 1] if index + 1 < len(order) else "AttrEnd"
        if nxt.get(name) != expected_next:
            return fail("attribute %s next is %s, expected %s" % (name, nxt.get(name), expected_next))
    print("check_chir_attributes: %d attributes match the compiler SDK" % len(compiler))
    return 0


if __name__ == "__main__":
    sys.exit(main())
