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
 * Batch integer parsing (deserialization counterpart of the formatter above).
 *
 * The caller positions input[0..len) at an element boundary: either right
 * after the '[' of the array or right after the ',' that followed a
 * previously accepted element.  The parser accepts as many plain decimal
 * elements (optional '-' followed by digits, JSON whitespace allowed around
 * tokens) as fit into out, and always stops at a clean boundary so the
 * caller can resume element-wise decoding for anything it does not handle.
 *
 * Return value packs:
 *   bits 63..34 : accepted element count
 *   bits 33..2  : consumed byte count (up to and including the last ',' or
 *                 the terminating ']')
 *   bits  1..0  : stop reason
 * Reasons:
 *   DONE        ']' consumed; the array is complete.  A ']' directly after
 *               a ',' (trailing comma) is reported as COMPLEX because the
 *               element-wise reader rejects it with the same exception.
 *   COMPLEX     A token the fast path does not handle: floats, strings,
 *               0x/0b/0o/0d number-system prefixes, values beyond Int64,
 *               malformed signs, ...  Consumed stops BEFORE that element so
 *               the element-wise fallback reproduces the exact original
 *               behavior (same values or same exceptions).
 *   TRUNCATED   The buffer ends inside an element or before its terminator;
 *               consumed stops at the last boundary and the caller should
 *               refill the buffer and retry.
 *   CHUNK_FULL  out reached its capacity; consumed stops at the last
 *               boundary so the caller can retry with a fresh chunk.
 */
#define CJ_JSON_PARSE_DONE 0
#define CJ_JSON_PARSE_COMPLEX 1
#define CJ_JSON_PARSE_TRUNCATED 2
#define CJ_JSON_PARSE_CHUNK_FULL 3

static int CJ_JSON_ParseIsWs(uint8_t c)
{
    return c == ' ' || c == '\t' || c == '\n' || c == '\r';
}

static int CJ_JSON_ParseIsDigit(uint8_t c)
{
    return c >= '0' && c <= '9';
}

static int64_t CJ_JSON_ParsePack(int64_t elems, int64_t consumed, int64_t reason)
{
    return (elems << 34) | (consumed << 2) | reason;
}

int64_t CJ_JSON_ParseInt64Array(const uint8_t* input, int64_t len, int64_t* out, int64_t outCap)
{
    int64_t pos = 0;
    int64_t boundary = 0; /* 0 also means "still right after '['" */
    int64_t elems = 0;
    if (input == NULL || out == NULL || outCap <= 0) {
        return CJ_JSON_ParsePack(0, 0, CJ_JSON_PARSE_TRUNCATED);
    }
    while (1) {
        while (pos < len && CJ_JSON_ParseIsWs(input[pos])) {
            pos++;
        }
        if (pos >= len) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_TRUNCATED);
        }
        uint8_t c = input[pos];
        if (c == ']') {
            if (boundary == 0) {
                /* empty array (or whitespace only): ']' right after '[' */
                return CJ_JSON_ParsePack(elems, pos + 1, CJ_JSON_PARSE_DONE);
            }
            /* ']' right after a ',': trailing comma, rejected downstream */
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_COMPLEX);
        }
        if (elems == outCap) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_CHUNK_FULL);
        }
        int neg = 0;
        if (c == '-') {
            neg = 1;
            pos++;
            if (pos >= len) {
                return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_TRUNCATED);
            }
            c = input[pos];
        }
        if (!CJ_JSON_ParseIsDigit(c)) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_COMPLEX);
        }
        uint64_t mag = 0;
        int overflow = 0;
        while (pos < len && CJ_JSON_ParseIsDigit(input[pos])) {
            uint8_t d = (uint8_t)(input[pos] - '0');
            if (mag > (UINT64_MAX - d) / 10) {
                overflow = 1;
            } else {
                mag = mag * 10 + d;
            }
            pos++;
        }
        if (pos >= len) {
            /* element terminator not in buffer yet */
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_TRUNCATED);
        }
        while (pos < len && CJ_JSON_ParseIsWs(input[pos])) {
            pos++;
        }
        if (pos >= len) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_TRUNCATED);
        }
        c = input[pos];
        if (c != ',' && c != ']') {
            /* fraction/exponent, 0x-style prefix, stray letter, ... */
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_COMPLEX);
        }
        if (overflow || (!neg && mag > (uint64_t)INT64_MAX) ||
            (neg && mag > (uint64_t)INT64_MAX + 1)) {
            /* fallback re-reads the element and raises the same overflow error */
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_COMPLEX);
        }
        out[elems] = neg ? (int64_t)(0 - mag) : (int64_t)mag;
        elems++;
        if (c == ']') {
            return CJ_JSON_ParsePack(elems, pos + 1, CJ_JSON_PARSE_DONE);
        }
        pos++;
        boundary = pos;
    }
}

/*
 * Unsigned counterpart of CJ_JSON_ParseInt64Array.  The fast path accepts
 * only ordinary non-negative decimal JSON integers; '-' and every malformed
 * or cross-buffer token are intentionally reported as COMPLEX/TRUNCATED so
 * the Cangjie reader finishes through its established UInt64 scalar path.
 */
int64_t CJ_JSON_ParseUInt64Array(const uint8_t* input, int64_t len, uint64_t* out, int64_t outCap)
{
    int64_t pos = 0;
    int64_t boundary = 0;
    int64_t elems = 0;
    if (input == NULL || out == NULL || outCap <= 0) {
        return CJ_JSON_ParsePack(0, 0, CJ_JSON_PARSE_TRUNCATED);
    }
    while (1) {
        while (pos < len && CJ_JSON_ParseIsWs(input[pos])) {
            pos++;
        }
        if (pos >= len) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_TRUNCATED);
        }
        uint8_t c = input[pos];
        if (c == ']') {
            if (boundary == 0) {
                return CJ_JSON_ParsePack(elems, pos + 1, CJ_JSON_PARSE_DONE);
            }
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_COMPLEX);
        }
        if (elems == outCap) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_CHUNK_FULL);
        }
        if (!CJ_JSON_ParseIsDigit(c)) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_COMPLEX);
        }
        uint64_t value = 0;
        int overflow = 0;
        while (pos < len && CJ_JSON_ParseIsDigit(input[pos])) {
            uint8_t d = (uint8_t)(input[pos] - '0');
            if (value > (UINT64_MAX - d) / 10) {
                overflow = 1;
            } else {
                value = value * 10 + d;
            }
            pos++;
        }
        if (pos >= len) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_TRUNCATED);
        }
        while (pos < len && CJ_JSON_ParseIsWs(input[pos])) {
            pos++;
        }
        if (pos >= len) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_TRUNCATED);
        }
        c = input[pos];
        if (c != ',' && c != ']') {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_COMPLEX);
        }
        if (overflow) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_COMPLEX);
        }
        out[elems] = value;
        elems++;
        if (c == ']') {
            return CJ_JSON_ParsePack(elems, pos + 1, CJ_JSON_PARSE_DONE);
        }
        pos++;
        boundary = pos;
    }
}

/*
 * Batch parse ordinary object members of the form "key":<Int64>.
 *
 * The input begins immediately after '{' or a previously consumed comma.
 * Accepted keys are unescaped and wholly contained in this input span.  The
 * caller materializes the reported key spans before it refills the stream.
 * Unlike the array parsers, DONE deliberately stops *before* the closing
 * '}', allowing JsonReader.endObject() to retain ownership of object state.
 */
int64_t CJ_JSON_ParseStringInt64Members(const uint8_t* input, int64_t len,
    int64_t* keyStarts, int64_t* keyLens, int64_t* values, int64_t outCap)
{
    int64_t pos = 0;
    int64_t boundary = 0;
    int64_t elems = 0;
    if (input == NULL || keyStarts == NULL || keyLens == NULL || values == NULL || outCap <= 0) {
        return CJ_JSON_ParsePack(0, 0, CJ_JSON_PARSE_TRUNCATED);
    }
    while (1) {
        while (pos < len && CJ_JSON_ParseIsWs(input[pos])) {
            pos++;
        }
        if (pos >= len) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_TRUNCATED);
        }
        if (input[pos] == '}') {
            return CJ_JSON_ParsePack(elems, pos, CJ_JSON_PARSE_DONE);
        }
        if (elems == outCap) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_CHUNK_FULL);
        }
        if (input[pos] != '"') {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_COMPLEX);
        }
        int64_t keyStart = ++pos;
        while (pos < len && input[pos] != '"') {
            if (input[pos] == '\\') {
                return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_COMPLEX);
            }
            pos++;
        }
        if (pos >= len) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_TRUNCATED);
        }
        int64_t keyLen = pos - keyStart;
        pos++;
        if (pos >= len) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_TRUNCATED);
        }
        if (input[pos] != ':') {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_COMPLEX);
        }
        pos++;
        if (pos >= len) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_TRUNCATED);
        }
        int neg = 0;
        uint8_t c = input[pos];
        if (c == '-') {
            neg = 1;
            pos++;
            if (pos >= len) {
                return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_TRUNCATED);
            }
            c = input[pos];
        }
        if (!CJ_JSON_ParseIsDigit(c)) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_COMPLEX);
        }
        uint64_t mag = 0;
        int overflow = 0;
        while (pos < len && CJ_JSON_ParseIsDigit(input[pos])) {
            uint8_t d = (uint8_t)(input[pos] - '0');
            if (mag > (UINT64_MAX - d) / 10) {
                overflow = 1;
            } else {
                mag = mag * 10 + d;
            }
            pos++;
        }
        if (pos >= len) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_TRUNCATED);
        }
        while (pos < len && CJ_JSON_ParseIsWs(input[pos])) {
            pos++;
        }
        if (pos >= len) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_TRUNCATED);
        }
        c = input[pos];
        if (c != ',' && c != '}') {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_COMPLEX);
        }
        if (overflow || (!neg && mag > (uint64_t)INT64_MAX) ||
            (neg && mag > (uint64_t)INT64_MAX + 1)) {
            return CJ_JSON_ParsePack(elems, boundary, CJ_JSON_PARSE_COMPLEX);
        }
        keyStarts[elems] = keyStart;
        keyLens[elems] = keyLen;
        values[elems] = neg ? (int64_t)(0 - mag) : (int64_t)mag;
        elems++;
        if (c == '}') {
            return CJ_JSON_ParsePack(elems, pos, CJ_JSON_PARSE_DONE);
        }
        pos++;
        boundary = pos;
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
