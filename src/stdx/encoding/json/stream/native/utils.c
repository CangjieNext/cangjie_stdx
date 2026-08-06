/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#include <stdint.h>
#include <math.h>
#include "securec.h"
#include "ryu/ryu.h"

#define RYU_DOUBLE_MAX_OUTPUT 32

extern int64_t CJ_ReadString(const uint8_t* str, int64_t left, int64_t right)
{
    int64_t i = left;
    while (i < right) {
        unsigned char c = str[i];
        if (c <= 0x7F) {
            // ASCII character
            if (str[i] == '\"' || str[i] == '\\') {
                return i;
            }
            i++;
            continue;
        }
        switch (c >> 4) { // 4 refer to leading four bits
            case 12:      // 1100 xxxx; 12 == 1100
            case 13:      // 1101 xxxx; 13 == 1101
                // 2-byte sequence
                if (i + 1 >= right) {
                    return i;
                }
                if ((c & 0x1e) == 0 || (str[i + 1] & 0xC0) != 0x80) {
                    return -1;
                }
                i += 2; // 2-byte sequence
                break;
            case 14: // 1110 xxxx; 14 == 1110
                // 3-byte sequence
                if (i + 2 >= right) { // i + 2 refer to 3rd char
                    return i;
                }
                if ((str[i + 1] & 0xC0) != 0x80 || (str[i + 2] & 0xC0) != 0x80 || // i + 2 refer to 3rd char
                    ((c & 0b1111) == 0 && (str[i + 1] & 0b00100000) == 0) ||
                    ((c & 0b1111) == 0b1101 && (str[i + 1] & 0b00100000) != 0)) {
                    return -1;
                }
                i += 3; // 3-byte sequence
                break;
            case 15: // 1111 xxxx; 15 == 1111
                // 4-byte sequence
                if (i + 3 >= right) { // check length 3
                    return i;
                }
                if ((str[i + 1] & 0xC0) != 0x80 || (str[i + 2] & 0xC0) != 0x80 || // i + 2 refer to 3rd char
                    (str[i + 3] & 0xC0) != 0x80 ||                                // i + 3 refer to 4th char
                    (c > 0xF4) || ((c & 0b111) == 0 && (str[i + 1] & 0b00110000) == 0) ||
                    ((c & 0b111) == 0b100 && (str[i + 1] & 0b00110000) != 0)) {
                    return -1;
                }
                i += 4; // 4-byte sequence
                break;
            default:
                return -1;
        }
    }
    return i;
}

static int RyuExponentLength(int exponent)
{
    int length = exponent < 0 ? 1 : 0;
    int value = exponent < 0 ? -exponent : exponent;
    do {
        length++;
        value /= 10;
    } while (value != 0);
    return length;
}

static int RyuToJsonNumber(const char* input, int inputLength, char* output)
{
    int inputIndex = 0;
    int outputIndex = 0;
    const int negative = input[0] == '-';
    if (negative) {
        output[outputIndex++] = input[inputIndex++];
    }

    char digits[17];
    int digitCount = 0;
    while (inputIndex < inputLength && input[inputIndex] != 'E') {
        if (input[inputIndex] != '.') {
            digits[digitCount++] = input[inputIndex];
        }
        inputIndex++;
    }
    if (inputIndex == inputLength) {
        return -1;
    }

    inputIndex++;
    int exponentSign = 1;
    if (input[inputIndex] == '-') {
        exponentSign = -1;
        inputIndex++;
    }
    int exponent = 0;
    while (inputIndex < inputLength) {
        exponent = exponent * 10 + (input[inputIndex++] - '0');
    }
    exponent *= exponentSign;

    const int scientificLength = negative + digitCount + (digitCount > 1) + 1 + RyuExponentLength(exponent);
    // Ryu's exponent applies to the first significant digit: for example,
    // 1.25E-1 has its decimal point after one digit (0.125).
    const int decimalPoint = 1 + exponent;
    const int fixedLength = negative + (decimalPoint <= 0 ? 2 - decimalPoint + digitCount :
        (decimalPoint < digitCount ? digitCount + 1 : decimalPoint));
    if (fixedLength > scientificLength) {
        inputIndex = 0;
        while (inputIndex < inputLength) {
            output[inputIndex] = input[inputIndex] == 'E' ? 'e' : input[inputIndex];
            inputIndex++;
        }
        return inputLength;
    }

    if (decimalPoint <= 0) {
        output[outputIndex++] = '0';
        output[outputIndex++] = '.';
        for (int i = 0; i < -decimalPoint; i++) {
            output[outputIndex++] = '0';
        }
        for (int i = 0; i < digitCount; i++) {
            output[outputIndex++] = digits[i];
        }
        return outputIndex;
    }

    for (int i = 0; i < digitCount; i++) {
        if (i == decimalPoint) {
            output[outputIndex++] = '.';
        }
        output[outputIndex++] = digits[i];
    }
    for (int i = digitCount; i < decimalPoint; i++) {
        output[outputIndex++] = '0';
    }
    return outputIndex;
}

extern int64_t CJ_JSON_FloatPrint(const double num, uint8_t* dest, const int64_t destSize)
{
    if (dest == NULL || destSize < RYU_DOUBLE_MAX_OUTPUT || !isfinite(num)) {
        return -1;
    }
    char ryuOutput[RYU_DOUBLE_MAX_OUTPUT];
    char jsonOutput[RYU_DOUBLE_MAX_OUTPUT];
    const int ryuLength = d2s_buffered_n(num, ryuOutput);
    const int jsonLength = RyuToJsonNumber(ryuOutput, ryuLength, jsonOutput);
    if (jsonLength <= 0 || jsonLength > destSize) {
        return -1;
    }
    for (int i = 0; i < jsonLength; i++) {
        dest[i] = (uint8_t)jsonOutput[i];
    }
    return jsonLength;
}
