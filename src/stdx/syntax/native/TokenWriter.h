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
 * This file declares the NodeWriter, which serializes AST for Syntax.
 */

#ifndef CANGJIE_TOKEN_WRITER_H
#define CANGJIE_TOKEN_WRITER_H

#include <fstream>
#include <set>
#include <vector>

#include "cangjie/Lex/Token.h"

using namespace Cangjie;

namespace TokenWriter {
inline size_t GetTokenLength(size_t originalSize, TokenKind kind, unsigned delimiterNum);

std::string GetStringFromBytes(const uint8_t* pBuffer, uint32_t strLen);
}

inline size_t TokenWriter::GetTokenLength(size_t originalSize, TokenKind kind, unsigned delimiterNum)
{
    constexpr auto doubleQuotesSize = 2;
    constexpr auto multiQuotesSize = 6;
    switch (kind) {
        // both windows and linux trait NL as 1 size
        case TokenKind::NL:
            return 1;
        case TokenKind::STRING_LITERAL:
            return originalSize + doubleQuotesSize;
        case TokenKind::RUNE_LITERAL:
        case TokenKind::JSTRING_LITERAL:
            return originalSize + doubleQuotesSize + 1;
        case TokenKind::MULTILINE_STRING:
            return originalSize + multiQuotesSize;
        // For ##"abc"##, the offset of the length and value is 3 * 2.
        case TokenKind::MULTILINE_RAW_STRING:
            return originalSize + ((delimiterNum + 1) << 1);
        default:
            return originalSize;
    }
}

#endif /* CANGJIE_TOKEN_SERIALIZATION_H */
