/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

/*
 * @file
 *
 * This file implements the NodeWriter.
 */
#include "TokenWriter.h"

using namespace Cangjie;

namespace TokenWriter {
std::string GetStringFromBytes(const uint8_t* pBuffer, uint32_t strLen)
{
    if (pBuffer == nullptr) {
        return "";
    }
    std::string value;
    for (uint32_t i = 0; i < strLen; i++) {
        if (*pBuffer == '\0') {
            value += "\\0";
            pBuffer += 1;
            continue;
        }
        value.push_back(static_cast<char>(*pBuffer));
        pBuffer += 1;
    }
    return value;
}

} // namespace

