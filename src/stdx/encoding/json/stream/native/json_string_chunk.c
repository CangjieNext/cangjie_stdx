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
#include <string.h>

#if defined(__aarch64__) || defined(_M_ARM64)
#define CJ_JSON_SCAN_NEON 1
#include <arm_neon.h>
#endif

/*
 * Escape classification shared with the stream writer's compact mode:
 * '"' and '\' take the two-byte short escapes, the C0 controls use
 * \u00XX, DEL (127) uses \u007f, and every other byte (including UTF-8
 * continuation bytes >= 0x80) is copied verbatim.
 */
#define CJ_JSON_STRING_MAX_ESCAPE_BYTES 6

static const char g_stringHexDigits[16] = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
};

static bool CJ_JSON_StringByteNeedsEscape(uint8_t byte)
{
    return byte < 32 || byte == '"' || byte == '\\' || byte == 127;
}

static int CJ_JSON_WriteEscapedByte(uint8_t* output, uint8_t byte)
{
    switch (byte) {
        case '\b':
            output[0] = '\\';
            output[1] = 'b';
            return 2;
        case '\t':
            output[0] = '\\';
            output[1] = 't';
            return 2;
        case '\n':
            output[0] = '\\';
            output[1] = 'n';
            return 2;
        case '\f':
            output[0] = '\\';
            output[1] = 'f';
            return 2;
        case '\r':
            output[0] = '\\';
            output[1] = 'r';
            return 2;
        case '"':
            output[0] = '\\';
            output[1] = '"';
            return 2;
        case '\\':
            output[0] = '\\';
            output[1] = '\\';
            return 2;
        default:
            if (byte < 32 || byte == 127) {
                output[0] = '\\';
                output[1] = 'u';
                output[2] = '0';
                output[3] = '0';
                output[4] = (uint8_t)g_stringHexDigits[byte >> 4];
                output[5] = (uint8_t)g_stringHexDigits[byte & 0xF];
                return 6;
            }
            output[0] = byte;
            return 1;
    }
}

#ifndef CJ_JSON_SCAN_NEON
/*
 * SWAR escape test for one 64-bit word: true when any byte is < 0x20 or
 * equals '"', '\' or 0x7f.  Bytes >= 0x80 (UTF-8 continuation) never match.
 * The classic hasless/hasvalue identities may report a false positive on
 * the byte following a real hit (borrow propagation), which is safe here:
 * callers only use the word test to skip whole runs and confirm the exact
 * position bytewise afterwards.
 */
static bool CJ_JSON_WordHasZero(uint64_t v)
{
    return ((v - UINT64_C(0x0101010101010101)) & ~v & UINT64_C(0x8080808080808080)) != 0;
}

static bool CJ_JSON_WordNeedsEscape(uint64_t word)
{
    /* hasless(word, 0x20): any byte below 0x20. */
    if (((word - UINT64_C(0x2020202020202020)) & ~word & UINT64_C(0x8080808080808080)) != 0) {
        return true;
    }
    if (CJ_JSON_WordHasZero(word ^ UINT64_C(0x2222222222222222))) { /* '"' */
        return true;
    }
    if (CJ_JSON_WordHasZero(word ^ UINT64_C(0x5c5c5c5c5c5c5c5c))) { /* '\' */
        return true;
    }
    if (CJ_JSON_WordHasZero(word ^ UINT64_C(0x7f7f7f7f7f7f7f7f))) { /* DEL */
        return true;
    }
    return false;
}
#endif

#ifdef CJ_JSON_SCAN_NEON
/*
 * NEON test for 16 bytes at once: four lane compares reduced into one
 * predicate.  vld1q_u8 tolerates arbitrary alignment, so no tail handling
 * is needed before the scalar confirmation loop.
 */
static bool CJ_JSON_VectorNeedsEscape(const uint8_t* p)
{
    const uint8x16_t v = vld1q_u8(p);
    const uint8x16_t bad = vorrq_u8(
        vcltq_u8(v, vdupq_n_u8(0x20)),
        vorrq_u8(vceqq_u8(v, vdupq_n_u8(0x22)),
                 vorrq_u8(vceqq_u8(v, vdupq_n_u8(0x5c)),
                          vceqq_u8(v, vdupq_n_u8(0x7f)))));
    return vmaxvq_u8(bad) != 0;
}
#endif

/*
 * Locate the first byte in [from, end) that requires escaping, or end when
 * the whole range is plain text.  The bulk of the scan advances 16 bytes
 * (NEON) or 8 bytes (SWAR) per iteration; a vector hit or a sub-vector
 * tail is resolved bytewise.  False positives from the word test only
 * cost a few scalar steps, never correctness.
 */
static int64_t CJ_JSON_FindNextEscape(const uint8_t* input, int64_t from, int64_t end)
{
    int64_t i = from;
#ifdef CJ_JSON_SCAN_NEON
    while (i + 16 <= end) {
        if (CJ_JSON_VectorNeedsEscape(input + i)) {
            break;
        }
        i += 16;
    }
#else
    while (i + 8 <= end) {
        uint64_t word;
        (void)memcpy(&word, input + i, sizeof(word));
        if (CJ_JSON_WordNeedsEscape(word)) {
            break;
        }
        i += 8;
    }
#endif
    while (i < end && !CJ_JSON_StringByteNeedsEscape(input[i])) {
        i++;
    }
    return i;
}

/*
 * Vectorized scan exported for the stream writer: returns the index of the
 * first byte in [from, end) that requires escaping, or end when the whole
 * range is plain text.  The stream writer uses it to route long plain runs
 * straight to the output stream, bypassing the staging buffer.
 */
extern int64_t CJ_JSON_StringFindFirstEscape(const uint8_t* input, int64_t from, int64_t end)
{
    if (input == NULL || from < 0 || end < from) {
        return end;
    }
    return CJ_JSON_FindNextEscape(input, from, end);
}

/*
 * Escape input[0, inputLen) into output and stop once the remaining capacity
 * can no longer hold the worst-case expansion of one byte.  Plain runs are
 * located with the vectorized scanner and copied with memcpy so long
 * unescaped strings complete in one pass.  The return value packs the
 * consumed input bytes into the high 32 bits and the written output bytes
 * into the low 32 bits, mirroring the integer array chunk formatter
 * contract.
 */
int64_t CJ_JSON_EscapeStringChunk(const uint8_t* input, int64_t inputLen,
    uint8_t* output, int64_t outputCapacity)
{
    int64_t consumed = 0;
    int64_t written = 0;
    if (input == NULL || output == NULL || inputLen <= 0 || outputCapacity <= 0) {
        return 0;
    }
    while (consumed < inputLen) {
        if (outputCapacity - written < CJ_JSON_STRING_MAX_ESCAPE_BYTES) {
            break;
        }
        if (!CJ_JSON_StringByteNeedsEscape(input[consumed])) {
            int64_t runEnd = CJ_JSON_FindNextEscape(input, consumed, inputLen);
            int64_t runLength = runEnd - consumed;
            int64_t available = outputCapacity - written;
            if (runLength > available) {
                runLength = available;
            }
            if (runLength > 0) {
                (void)memcpy(output + written, input + consumed, (size_t)runLength);
                written += runLength;
                consumed += runLength;
            }
            continue;
        }
        written += CJ_JSON_WriteEscapedByte(output + written, input[consumed]);
        consumed++;
    }
    return (consumed << 32) | written;
}
