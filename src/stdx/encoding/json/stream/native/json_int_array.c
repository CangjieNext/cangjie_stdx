/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* Element kinds accepted by CJ_JSON_FormatIntegerArray. */
#define CJ_JSON_INT_ARRAY_KIND_I8 0
#define CJ_JSON_INT_ARRAY_KIND_I16 1
#define CJ_JSON_INT_ARRAY_KIND_I32 2
#define CJ_JSON_INT_ARRAY_KIND_I64 3
#define CJ_JSON_INT_ARRAY_KIND_U8 4
#define CJ_JSON_INT_ARRAY_KIND_U16 5
#define CJ_JSON_INT_ARRAY_KIND_U32 6
#define CJ_JSON_INT_ARRAY_KIND_U64 7

/* Worst case per element: 1 comma + 1 minus sign + 20 digits. */
#define CJ_JSON_INT_ARRAY_MAX_BYTES_PER_ELEMENT 21

/* Two-digit decimal table mirroring digits100 in json_convert.cj so batch
 * formatting stays byte-identical with the per-element writer. */
static const char g_digits100[200] = {
    '0','0','0','1','0','2','0','3','0','4','0','5','0','6','0','7','0','8','0','9',
    '1','0','1','1','1','2','1','3','1','4','1','5','1','6','1','7','1','8','1','9',
    '2','0','2','1','2','2','2','3','2','4','2','5','2','6','2','7','2','8','2','9',
    '3','0','3','1','3','2','3','3','3','4','3','5','3','6','3','7','3','8','3','9',
    '4','0','4','1','4','2','4','3','4','4','4','5','4','6','4','7','4','8','4','9',
    '5','0','5','1','5','2','5','3','5','4','5','5','5','6','5','7','5','8','5','9',
    '6','0','6','1','6','2','6','3','6','4','6','5','6','6','6','7','6','8','6','9',
    '7','0','7','1','7','2','7','3','7','4','7','5','7','6','7','7','7','8','7','9',
    '8','0','8','1','8','2','8','3','8','4','8','5','8','6','8','7','8','8','8','9',
    '9','0','9','1','9','2','9','3','9','4','9','5','9','6','9','7','9','8','9','9'
};

static int CJ_JSON_Uint64Len(uint64_t value)
{
    uint64_t product = 10;
    for (int i = 1; i < 19; i++) {
        if (value < product) {
            return i;
        }
        product *= 10;
    }
    if (value >= UINT64_C(10000000000000000000)) {
        return 20;
    }
    return 19;
}

static int CJ_JSON_FormatUint64(uint8_t* output, uint64_t value)
{
    if (value < 10) {
        output[0] = (uint8_t)('0' + value);
        return 1;
    }
    if (value < 100) {
        int index = (int)(value * 2);
        output[0] = (uint8_t)g_digits100[index];
        output[1] = (uint8_t)g_digits100[index + 1];
        return 2;
    }
    if (value < 10000) {
        uint64_t high = value / 100;
        uint64_t low = value - high * 100;
        if (high < 10) {
            output[0] = (uint8_t)('0' + high);
            output[1] = (uint8_t)g_digits100[low * 2];
            output[2] = (uint8_t)g_digits100[low * 2 + 1];
            return 3;
        }
        int highIndex = (int)(high * 2);
        int lowIndex = (int)(low * 2);
        output[0] = (uint8_t)g_digits100[highIndex];
        output[1] = (uint8_t)g_digits100[highIndex + 1];
        output[2] = (uint8_t)g_digits100[lowIndex];
        output[3] = (uint8_t)g_digits100[lowIndex + 1];
        return 4;
    }
    int digitNum = CJ_JSON_Uint64Len(value);
    uint64_t remaining = value;
    uint8_t* next = output + digitNum;
    while (remaining >= 100) {
        uint64_t high = remaining / 100;
        uint64_t low = remaining - high * 100;
        next -= 2;
        int index = (int)(low * 2);
        next[0] = (uint8_t)g_digits100[index];
        next[1] = (uint8_t)g_digits100[index + 1];
        remaining = high;
    }
    if (remaining < 10) {
        output[0] = (uint8_t)('0' + remaining);
    } else {
        int index = (int)(remaining * 2);
        output[0] = (uint8_t)g_digits100[index];
        output[1] = (uint8_t)g_digits100[index + 1];
    }
    return digitNum;
}

static void CJ_JSON_LoadIntegerElement(const void* input, int64_t kind, int64_t index,
    uint64_t* magnitude, int* negative)
{
    int64_t signedValue = 0;
    switch (kind) {
        case CJ_JSON_INT_ARRAY_KIND_I8:
            signedValue = (int64_t)(((const int8_t*)input)[index]);
            break;
        case CJ_JSON_INT_ARRAY_KIND_I16:
            signedValue = (int64_t)(((const int16_t*)input)[index]);
            break;
        case CJ_JSON_INT_ARRAY_KIND_I32:
            signedValue = (int64_t)(((const int32_t*)input)[index]);
            break;
        case CJ_JSON_INT_ARRAY_KIND_I64:
            signedValue = ((const int64_t*)input)[index];
            break;
        case CJ_JSON_INT_ARRAY_KIND_U8:
            *magnitude = (uint64_t)(((const uint8_t*)input)[index]);
            return;
        case CJ_JSON_INT_ARRAY_KIND_U16:
            *magnitude = (uint64_t)(((const uint16_t*)input)[index]);
            return;
        case CJ_JSON_INT_ARRAY_KIND_U32:
            *magnitude = (uint64_t)(((const uint32_t*)input)[index]);
            return;
        case CJ_JSON_INT_ARRAY_KIND_U64:
            *magnitude = ((const uint64_t*)input)[index];
            return;
        default:
            return;
    }
    if (signedValue < 0) {
        *negative = 1;
        *magnitude = (uint64_t)(-(signedValue + 1)) + 1;
    } else {
        *magnitude = (uint64_t)signedValue;
    }
}

/*
 * Format the elements input[startIndex, startIndex + count) into output and
 * stop before the remaining capacity drops below the worst-case element
 * size.  firstElement tells whether startIndex is the first element of the
 * whole array, keeping comma placement correct across chunk boundaries.
 * The return value packs the consumed element count into the high 32 bits
 * and the written byte count into the low 32 bits; a negative value marks
 * an invalid kind.
 */
int64_t CJ_JSON_FormatIntegerArray(const void* input, int64_t kind, int64_t startIndex, int64_t count,
    uint8_t* output, int64_t outputCapacity, bool firstElement)
{
    int64_t index = 0;
    int64_t written = 0;
    if (input == NULL || output == NULL || count <= 0) {
        return 0;
    }
    if (kind < CJ_JSON_INT_ARRAY_KIND_I8 || kind > CJ_JSON_INT_ARRAY_KIND_U64) {
        return -1;
    }
    while (index < count) {
        if (outputCapacity - written < CJ_JSON_INT_ARRAY_MAX_BYTES_PER_ELEMENT) {
            break;
        }
        if (index > 0 || !firstElement) {
            output[written++] = ',';
        }
        uint64_t magnitude = 0;
        int negative = 0;
        CJ_JSON_LoadIntegerElement(input, kind, startIndex + index, &magnitude, &negative);
        if (negative != 0) {
            output[written++] = '-';
        }
        written += CJ_JSON_FormatUint64(output + written, magnitude);
        index++;
    }
    return (index << 32) | written;
}
