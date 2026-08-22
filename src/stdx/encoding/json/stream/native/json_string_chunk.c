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
 * x86_64 guarantees SSE2.  Keep the AVX2 body separately target-attributed:
 * the library is built for a generic x86_64 baseline and selects that body
 * only after checking the running CPU.
 */
#if defined(__x86_64__) || defined(_M_X64)
#define CJ_JSON_SCAN_SSE2 1
#include <emmintrin.h>
#if (defined(__GNUC__) || defined(__clang__)) && !defined(_MSC_VER)
#define CJ_JSON_SCAN_AVX2 1
#include <immintrin.h>
#define CJ_JSON_TARGET_AVX2 __attribute__((target("avx2")))
#endif
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

#if !defined(CJ_JSON_SCAN_NEON) && !defined(CJ_JSON_SCAN_SSE2)
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

#ifdef CJ_JSON_SCAN_SSE2
static bool CJ_JSON_SSE2NeedsEscape(const uint8_t* p)
{
    const __m128i v = _mm_loadu_si128((const __m128i*)p);
    /* Convert an unsigned byte comparison (v < 0x20) into a signed one. */
    const __m128i below = _mm_cmplt_epi8(_mm_xor_si128(v, _mm_set1_epi8((char)0x80)),
        _mm_set1_epi8((char)0xa0));
    const __m128i bad = _mm_or_si128(below,
        _mm_or_si128(_mm_cmpeq_epi8(v, _mm_set1_epi8(0x22)),
            _mm_or_si128(_mm_cmpeq_epi8(v, _mm_set1_epi8(0x5c)),
                _mm_cmpeq_epi8(v, _mm_set1_epi8(0x7f)))));
    return _mm_movemask_epi8(bad) != 0;
}
#endif

#ifdef CJ_JSON_SCAN_AVX2
static CJ_JSON_TARGET_AVX2 bool CJ_JSON_AVX2NeedsEscape(const uint8_t* p)
{
    const __m256i v = _mm256_loadu_si256((const __m256i*)p);
    const __m256i below = _mm256_cmpgt_epi8(_mm256_set1_epi8((char)0xa0),
        _mm256_xor_si256(v, _mm256_set1_epi8((char)0x80)));
    const __m256i bad = _mm256_or_si256(below,
        _mm256_or_si256(_mm256_cmpeq_epi8(v, _mm256_set1_epi8(0x22)),
            _mm256_or_si256(_mm256_cmpeq_epi8(v, _mm256_set1_epi8(0x5c)),
                _mm256_cmpeq_epi8(v, _mm256_set1_epi8(0x7f)))));
    return _mm256_movemask_epi8(bad) != 0;
}

static bool CJ_JSON_HasAVX2(void)
{
    return __builtin_cpu_supports("avx2");
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
#elif defined(CJ_JSON_SCAN_SSE2)
#ifdef CJ_JSON_SCAN_AVX2
    if (CJ_JSON_HasAVX2()) {
        while (i + 32 <= end) {
            if (CJ_JSON_AVX2NeedsEscape(input + i)) {
                break;
            }
            i += 32;
        }
    }
#endif
    while (i + 16 <= end) {
        if (CJ_JSON_SSE2NeedsEscape(input + i)) {
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
