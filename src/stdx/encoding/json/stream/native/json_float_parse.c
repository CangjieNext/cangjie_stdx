/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 */

#include <stdbool.h>
#include <math.h>
#include <stddef.h>
#include <stdint.h>

#include "ryu/ryu_parse.h"

/*
 * Parse only the compact decimal subset that Ryu accepts without a temporary
 * string.  The Cangjie stream reader keeps the existing parser as its fallback
 * for malformed, long, or buffer-spanning tokens, so returning false here must
 * not consume reader input.
 */
double CJ_JSON_TryParseFloat64(const uint8_t* data, int64_t start, int64_t end)
{
    if (data == NULL || start >= end || end - start > 1024) {
        return NAN;
    }

    int64_t mantissaDigits = 0;
    int64_t exponentDigits = 0;
    bool inExponent = false;
    for (int64_t i = start; i < end; i++) {
        const uint8_t c = data[i];
        if (c == 'e' || c == 'E') {
            if (inExponent) {
                return NAN;
            }
            inExponent = true;
            continue;
        }
        if (c == '.' || c == '-' || c == '+') {
            continue;
        }
        if (c < '0' || c > '9') {
            return NAN;
        }
        if (inExponent) {
            exponentDigits++;
        } else {
            mantissaDigits++;
        }
    }
    if (mantissaDigits == 0 || mantissaDigits > 17 || exponentDigits > 3) {
        return NAN;
    }

    double value = 0.0;
    if (s2d_n((const char*)(data + start), (int)(end - start), &value) != SUCCESS) {
        return NAN;
    }
    return value;
}
