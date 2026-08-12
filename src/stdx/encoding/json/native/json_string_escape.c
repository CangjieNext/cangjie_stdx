/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#include <math.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include "ryu/ryu_parse.h"

#include "json_string_escape.h"
#include "securec.h"

bool CJ_JSON_ValidateUtf8AndCopy(const uint8_t* input, uint8_t* output, int64_t size)
{
    const uint64_t asciiMask = UINT64_C(0x8080808080808080);
    int64_t offset = 0;

    if (size < 0) {
        return false;
    }

    // Fast path for the ASCII-heavy JSON payloads.  The stack temporary keeps
    // the load/store well-defined for unaligned Cangjie array storage.
    while (size - offset >= (int64_t)sizeof(uint64_t)) {
        uint64_t bytes;
        (void)memcpy(&bytes, input + offset, sizeof(bytes));
        (void)memcpy(output + offset, &bytes, sizeof(bytes));
        if ((bytes & asciiMask) != 0) {
            break;
        }
        offset += (int64_t)sizeof(bytes);
    }

    while (offset < size) {
        const uint8_t byte1 = input[offset];
        output[offset] = byte1;
        if (byte1 < 0x80) {
            offset++;
            continue;
        }
        if (byte1 < 0xc0) {
            return false;
        }
        if (byte1 < 0xe0) {
            if (size - offset < 2) {
                return false;
            }
            const uint8_t byte2 = input[offset + 1];
            output[offset + 1] = byte2;
            if ((byte1 & 0x1e) == 0 || (byte2 & 0xc0) != 0x80) {
                return false;
            }
            offset += 2;
            continue;
        }
        if (byte1 < 0xf0) {
            if (size - offset < 3) {
                return false;
            }
            const uint8_t byte2 = input[offset + 1];
            const uint8_t byte3 = input[offset + 2];
            output[offset + 1] = byte2;
            output[offset + 2] = byte3;
            if ((byte2 & 0xc0) != 0x80 || (byte3 & 0xc0) != 0x80 ||
                ((byte1 & 0x0f) == 0 && (byte2 & 0x20) == 0) ||
                ((byte1 & 0x0f) == 0x0d && (byte2 & 0x20) != 0)) {
                return false;
            }
            offset += 3;
            continue;
        }
        if (byte1 < 0xf8) {
            if (size - offset < 4) {
                return false;
            }
            const uint8_t byte2 = input[offset + 1];
            const uint8_t byte3 = input[offset + 2];
            const uint8_t byte4 = input[offset + 3];
            output[offset + 1] = byte2;
            output[offset + 2] = byte3;
            output[offset + 3] = byte4;
            if ((byte2 & 0xc0) != 0x80 || (byte3 & 0xc0) != 0x80 || (byte4 & 0xc0) != 0x80 ||
                (byte1 & 0x07) > 0x04 ||
                ((byte1 & 0x07) == 0 && (byte2 & 0x30) == 0) ||
                ((byte1 & 0x07) == 0x04 && (byte2 & 0x30) != 0)) {
                return false;
            }
            offset += 4;
            continue;
        }
        return false;
    }
    return true;
}

int64_t CJ_JSON_ReplaceEscapeChar(const uint8_t* input, int64_t inputlen, uint8_t* buffer, bool htmlSafe)
{
    uint8_t* pointer = buffer;
    const uint8_t* inputPointer = input;
    int64_t remainlen = inputlen;
    int64_t len = 0;
    static uint8_t hex[] = "0123456789abcdef";
    for (; remainlen > 0; inputPointer++, pointer++, remainlen--) {
        uint8_t b = *inputPointer;
        if (b == 0X7f) {
            *pointer++ = '\\';
            *pointer++ = 'u';
            *pointer++ = '0';
            *pointer++ = '0';
            *pointer++ = '7';
            *pointer = 'f';
            len += 6; // 6 is the sizeof("\u007f")
            continue;
        }

        if ((b >= 32) && (b != '\"') && (b != '\\') && ((!htmlSafe && b == '&') || (b != '&'))) { // ASCII code over 32 don't need escape
            *pointer = *inputPointer;
            len++;
            continue;
        }

        switch (b) {
            case '\b':
                *pointer++ = '\\';
                *pointer = 'b';
                len += 2; // add 2 bytes
                break;
            case '\f':
                *pointer++ = '\\';
                *pointer = 'f';
                len += 2; // add 2 bytes
                break;
            case '\n':
                *pointer++ = '\\';
                *pointer = 'n';
                len += 2; // add 2 bytes
                break;
            case '\r':
                *pointer++ = '\\';
                *pointer = 'r';
                len += 2; // add 2 bytes
                break;
            case '\t':
                *pointer++ = '\\';
                *pointer = 't';
                len += 2; // add 2 bytes
                break;
            case '\\':
                *pointer++ = '\\';
                *pointer = '\\';
                len += 2; // add 2 bytes
                break;
            case '\"':
                *pointer++ = '\\';
                *pointer = '\"';
                len += 2; // add 2 bytes
                break;
            default:
                *pointer++ = '\\';
                *pointer++ = 'u';
                *pointer++ = '0';
                *pointer++ = '0';
                *pointer++ = hex[b >> 4]; // num of high 4 bits
                *pointer = hex[b & 0xF];  // num of low 4 bits
                len += 6;                 // add 6 bytes
                break;
        }
    }
    return len;
}

int64_t CJ_JSON_WriteBufferAppendInt(uint8_t* buffer, const int64_t num)
{
    if (num < 0) {
        uint64_t unum = (uint64_t)(-(num + 1)) + 1;
        buffer[0] = '-';
        buffer++;
        return CJ_JSON_WriteBufferAppendUint(buffer, unum) + 1;
    } else {
        return CJ_JSON_WriteBufferAppendUint(buffer, (uint64_t)num);
    }
}

int64_t CJ_JSON_WriteBufferAppendUint(uint8_t* buffer, const uint64_t num)
{
    int64_t index = 0, numStartPos = 0;
    uint64_t unum = num;
    do {
        buffer[index++] = unum % 10 + '0'; // mod 10
        unum /= 10;                        // mod 10
    } while (unum > 0);

    uint8_t temp;
    int64_t i = 0, iOpposite;
    int64_t mid = (index - 1) / 2;
    for (i = numStartPos; i <= mid; i++) {
        iOpposite = (index + numStartPos - i) - 1;
        temp = buffer[i];
        buffer[i] = buffer[iOpposite];
        buffer[iOpposite] = temp;
    }
    return index;
}

int64_t CJ_JSON_StringEscapeCharNumGet(const uint8_t* input, int64_t strlen, bool htmlSafe)
{
    const uint8_t* inputPointer;
    int64_t len = strlen;
    uint32_t escapeCharacters = 0;

    for (inputPointer = input; len > 0; inputPointer++, len--) {
        if (*inputPointer == 127) { // ASCII 127 is DEL
            escapeCharacters += 5;  // 5 is the size need to add
            continue;
        }

        // ASCII code over 32 don't need escape
        if ((*inputPointer >= 32) && (*inputPointer != '\"') && (*inputPointer != '\\') && ((!htmlSafe && *inputPointer == '&') || *inputPointer != '&')) {
            continue;
        }

        switch (*inputPointer) {
            case '\r':
            case '\f':
            case '\t':
            case '\b':
            case '\n':
            case '\"':
            case '\\':
                escapeCharacters++;
                break;
            default:
                escapeCharacters += 5; // 5 is the size need to add
                break;
        }
    }
    return escapeCharacters;
}

int64_t CJ_JSON_ParseInt64(const uint8_t* data, int64_t start, int64_t end)
{
    if (start >= end) {
        return 0;
    }

    int64_t result = 0;
    int64_t sign = 1;
    int64_t i = start;
    if (data[i] == '-') {
        sign = -1;
        i++;
    } else if (data[i] == '+') {
        i++;
    }

    if (i < end && data[i] == '0' && i + 1 < end) {
        uint8_t prefix = data[i + 1];
        int64_t base = 0;
        if (prefix == 'b' || prefix == 'B') {
            base = 2;
        } else if (prefix == 'o' || prefix == 'O') {
            base = 8;
        } else if (prefix == 'x' || prefix == 'X') {
            base = 16;
        }
        if (base != 0) {
            i += 2;
            for (; i < end; i++) {
                uint8_t c = data[i];
                int64_t digit = -1;
                if (c >= '0' && c <= '9') {
                    digit = c - '0';
                } else if (c >= 'a' && c <= 'f') {
                    digit = c - 'a' + 10;
                } else if (c >= 'A' && c <= 'F') {
                    digit = c - 'A' + 10;
                }
                if (digit >= 0 && digit < base) {
                    result = result * base + digit;
                }
            }
            return sign * result;
        }
    }

    for (; i < end; i++) {
        uint8_t c = data[i];
        if (c >= '0' && c <= '9') {
            result = result * 10 + (c - '0');
        }
    }
    return sign * result;
}

static bool CJ_JSON_CanUseRyu(const uint8_t* data, int64_t start, int64_t end)
{
    // s2d_n keeps the significant mantissa in uint64_t and the exponent in
    // int32_t.  Restrict the zero-copy fast path to the range those fields can
    // represent; longer/less common forms continue through strtod below.
    int64_t mantissaDigits = 0;
    int64_t exponentDigits = 0;
    bool inExponent = false;
    for (int64_t i = start; i < end; i++) {
        uint8_t c = data[i];
        if (c == 'e' || c == 'E') {
            if (inExponent) {
                return false;
            }
            inExponent = true;
            continue;
        }
        if (c == '.' || c == '-' || c == '+') {
            continue;
        }
        if (c < '0' || c > '9') {
            return false;
        }
        if (inExponent) {
            exponentDigits++;
        } else {
            mantissaDigits++;
        }
    }
    return mantissaDigits <= 17 && exponentDigits <= 3;
}

double CJ_JSON_ParseFloat64(const uint8_t* data, int64_t start, int64_t end)
{
    if (start >= end) {
        return 0.0;
    }

    int64_t len = end - start;
    if (len <= INT_MAX && CJ_JSON_CanUseRyu(data, start, end)) {
        double result = 0.0;
        if (s2d_n((const char*)(data + start), (int)len, &result) == SUCCESS) {
            return result;
        }
    }

    // Ryu s2d intentionally declines long inputs and uncommon formats. Keep
    // strtod as the exact compatibility fallback for those tokens.
    char stack_temp[512];
    char* temp = stack_temp;
    if (len >= (int64_t)sizeof(stack_temp)) {
        if ((uint64_t)len >= SIZE_MAX) {
            return HUGE_VAL;
        }
        temp = (char*)malloc((size_t)len + 1);
        if (temp == NULL) {
            return HUGE_VAL;
        }
    }

    if (memcpy_s(temp, (size_t)len + 1, data + start, (size_t)len) != EOK) {
        if (temp != stack_temp) {
            free(temp);
        }
        return HUGE_VAL;
    }
    temp[len] = '\0';
    double result = strtod(temp, NULL);
    if (temp != stack_temp) {
        free(temp);
    }
    return result;
}
