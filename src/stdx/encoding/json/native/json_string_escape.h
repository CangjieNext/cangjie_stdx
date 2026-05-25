/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#ifndef JSON_STRING_ESCAPE_H
#define JSON_STRING_ESCAPE_H

#include <stdint.h>
#include <stdbool.h>

int64_t CJ_JSON_ReplaceEscapeChar(const uint8_t* input, int64_t inputlen, uint8_t* buffer, bool htmlSafe);

int64_t CJ_JSON_WriteBufferAppendInt(uint8_t* buffer, const int64_t num);

int64_t CJ_JSON_StringEscapeCharNumGet(const uint8_t* input, int64_t strlen, bool htmlSafe);

int64_t CJ_JSON_WriteBufferAppendUint(uint8_t* buffer, const uint64_t num);

// Optimized: Single-pass escape with capacity check
int64_t CJ_JSON_AppendEscapedString(const uint8_t* input, int64_t inputLen, uint8_t* buffer,
                                     int64_t bufferOffset, int64_t bufferCapacity, bool htmlSafe);

// Optimized: Parse Int64 directly from byte array without creating temporary string
int64_t CJ_JSON_ParseInt64(const uint8_t* data, int64_t start, int64_t end);

// Optimized: Parse Float64 directly from byte array without creating temporary string
double CJ_JSON_ParseFloat64(const uint8_t* data, int64_t start, int64_t end);

#endif