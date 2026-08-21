/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#include <stdbool.h>
#include <stdint.h>
#include <math.h>
#include <string.h>
#include "securec.h"
#include "ryu/ryu.h"

#if defined(__aarch64__) || defined(_M_ARM64)
#define CJ_JSON_READ_SCAN_NEON 1
#include <arm_neon.h>
#endif

#define RYU_DOUBLE_MAX_OUTPUT 32

/*
 * Return the first byte that needs the scalar JSON-string decoder.  The
 * common case is a long ASCII run: it contains neither a quote/backslash nor
 * a UTF-8 lead/continuation byte, so scan 16 bytes at once on arm64 (or 8
 * bytes with a portable word scan) before falling back to the existing UTF-8
 * validator.  Control ASCII bytes remain part of the fast run because the
 * pre-existing decoder accepts them and this change must not alter its input
 * semantics.
 */
#ifdef CJ_JSON_READ_SCAN_NEON
static bool CJ_ReadStringVectorNeedsScalar(const uint8_t* input)
{
    const uint8x16_t value = vld1q_u8(input);
    const uint8x16_t high = vandq_u8(value, vdupq_n_u8(0x80));
    const uint8x16_t special = vorrq_u8(vceqq_u8(value, vdupq_n_u8('"')),
        vceqq_u8(value, vdupq_n_u8('\\')));
    return vmaxvq_u8(vorrq_u8(high, special)) != 0;
}
#else
static bool CJ_ReadStringWordHasZero(uint64_t value)
{
    return ((value - UINT64_C(0x0101010101010101)) & ~value &
        UINT64_C(0x8080808080808080)) != 0;
}

static bool CJ_ReadStringWordNeedsScalar(uint64_t value)
{
    if ((value & UINT64_C(0x8080808080808080)) != 0) {
        return true;
    }
    return CJ_ReadStringWordHasZero(value ^ UINT64_C(0x2222222222222222)) ||
        CJ_ReadStringWordHasZero(value ^ UINT64_C(0x5c5c5c5c5c5c5c5c));
}
#endif

static int64_t CJ_ReadStringAsciiRun(const uint8_t* input, int64_t from, int64_t end)
{
    int64_t index = from;
#ifdef CJ_JSON_READ_SCAN_NEON
    while (index + 16 <= end) {
        if (CJ_ReadStringVectorNeedsScalar(input + index)) {
            break;
        }
        index += 16;
    }
#else
    while (index + 8 <= end) {
        uint64_t word;
        (void)memcpy(&word, input + index, sizeof(word));
        if (CJ_ReadStringWordNeedsScalar(word)) {
            break;
        }
        index += 8;
    }
#endif
    while (index < end && input[index] <= 0x7F && input[index] != '"' && input[index] != '\\') {
        index++;
    }
    return index;
}

extern int64_t CJ_ReadString(const uint8_t* str, int64_t left, int64_t right)
{
    int64_t i = left;
    while (i < right) {
        i = CJ_ReadStringAsciiRun(str, i, right);
        if (i >= right) {
            return i;
        }
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

/*
 * Format the doubles input[startIndex, startIndex + count) into output and
 * stop before the remaining capacity drops below the worst-case element
 * size.  firstElement tells whether startIndex is the first element of the
 * whole array, keeping comma placement correct across chunk boundaries.
 * The return value packs the consumed element count into the high 32 bits
 * and the written byte count into the low 32 bits; -1 marks a non-finite
 * value, which the caller reports as a serialization error.
 */
extern int64_t CJ_JSON_FormatFloat64Array(const void* input, int64_t startIndex, int64_t count,
    uint8_t* output, int64_t outputCapacity, bool firstElement)
{
    const double* values = (const double*)input;
    int64_t index = 0;
    int64_t written = 0;
    if (input == NULL || output == NULL || count <= 0) {
        return 0;
    }
    while (index < count) {
        if (outputCapacity - written < RYU_DOUBLE_MAX_OUTPUT + 1) {
            break;
        }
        const double num = values[startIndex + index];
        if (!isfinite(num)) {
            return -1;
        }
        if (index > 0 || !firstElement) {
            output[written++] = ',';
        }
        char ryuOutput[RYU_DOUBLE_MAX_OUTPUT];
        char jsonOutput[RYU_DOUBLE_MAX_OUTPUT];
        const int ryuLength = d2s_buffered_n(num, ryuOutput);
        const int jsonLength = RyuToJsonNumber(ryuOutput, ryuLength, jsonOutput);
        if (jsonLength <= 0) {
            return -1;
        }
        for (int i = 0; i < jsonLength; i++) {
            output[written++] = (uint8_t)jsonOutput[i];
        }
        index++;
    }
    return (index << 32) | written;
}

/*
 * Same chunk contract as CJ_JSON_FormatFloat64Array, reading 4-byte float
 * elements.  Each element is widened to double before the Ryu round trip so
 * the digits match the element-wise Float64(value) path byte for byte.
 */
extern int64_t CJ_JSON_FormatFloat32Array(const void* input, int64_t startIndex, int64_t count,
    uint8_t* output, int64_t outputCapacity, bool firstElement)
{
    const float* values = (const float*)input;
    int64_t index = 0;
    int64_t written = 0;
    if (input == NULL || output == NULL || count <= 0) {
        return 0;
    }
    while (index < count) {
        if (outputCapacity - written < RYU_DOUBLE_MAX_OUTPUT + 1) {
            break;
        }
        const double num = (double)values[startIndex + index];
        if (!isfinite(num)) {
            return -1;
        }
        if (index > 0 || !firstElement) {
            output[written++] = ',';
        }
        char ryuOutput[RYU_DOUBLE_MAX_OUTPUT];
        char jsonOutput[RYU_DOUBLE_MAX_OUTPUT];
        const int ryuLength = d2s_buffered_n(num, ryuOutput);
        const int jsonLength = RyuToJsonNumber(ryuOutput, ryuLength, jsonOutput);
        if (jsonLength <= 0) {
            return -1;
        }
        for (int i = 0; i < jsonLength; i++) {
            output[written++] = (uint8_t)jsonOutput[i];
        }
        index++;
    }
    return (index << 32) | written;
}
