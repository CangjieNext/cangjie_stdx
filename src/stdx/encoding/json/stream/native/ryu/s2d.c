// Copyright 2019 Ulf Adams
//
// The contents of this file may be used under the terms of the Apache License,
// Version 2.0.
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Alternatively, the contents of this file may be used under the terms of
// the Boost Software License, Version 1.0.
//
//    https://www.boost.org/LICENSE_1_0.txt
//
// Unless required by applicable law or agreed to in writing, this software
// is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.

#include "ryu/ryu_parse.h"

#include <assert.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>

#include "ryu/common.h"
#include "ryu/d2s_intrinsics.h"
#include "ryu/d2s_full_table.h"

#define DOUBLE_MANTISSA_BITS 52
#define DOUBLE_EXPONENT_BITS 11
#define DOUBLE_EXPONENT_BIAS 1023

static inline uint32_t floor_log2(const uint64_t value) {
  return 63 - __builtin_clzll(value);
}

static inline int32_t max32(int32_t a, int32_t b) {
  return a < b ? b : a;
}

static inline double int64Bits2Double(uint64_t bits) {
  double f;
  memcpy(&f, &bits, sizeof(double));
  return f;
}

enum Status s2d_n(const char * buffer, const int len, double * result) {
  if (len == 0) {
    return INPUT_TOO_SHORT;
  }
  int m10digits = 0;
  int e10digits = 0;
  int dotIndex = len;
  int eIndex = len;
  uint64_t m10 = 0;
  int32_t e10 = 0;
  bool signedM = false;
  bool signedE = false;
  int i = 0;
  if (buffer[i] == '-') {
    signedM = true;
    i++;
  }
  for (; i < len; i++) {
    char c = buffer[i];
    if (c == '.') {
      if (dotIndex != len) {
        return MALFORMED_INPUT;
      }
      dotIndex = i;
      continue;
    }
    if ((c < '0') || (c > '9')) {
      break;
    }
    if (m10digits >= 17) {
      return INPUT_TOO_LONG;
    }
    m10 = 10 * m10 + (c - '0');
    if (m10 != 0) {
      m10digits++;
    }
  }
  if (i < len && ((buffer[i] == 'e') || (buffer[i] == 'E'))) {
    eIndex = i;
    i++;
    if (i < len && ((buffer[i] == '-') || (buffer[i] == '+'))) {
      signedE = buffer[i] == '-';
      i++;
    }
    for (; i < len; i++) {
      char c = buffer[i];
      if ((c < '0') || (c > '9')) {
        return MALFORMED_INPUT;
      }
      if (e10digits >= 3) {
        return INPUT_TOO_LONG;
      }
      e10 = 10 * e10 + (c - '0');
      if (e10 != 0) {
        e10digits++;
      }
    }
  }
  if (i < len) {
    return MALFORMED_INPUT;
  }
  if (signedE) {
    e10 = -e10;
  }
  e10 -= dotIndex < eIndex ? eIndex - dotIndex - 1 : 0;
  if (m10 == 0) {
    *result = signedM ? -0.0 : 0.0;
    return SUCCESS;
  }

  if ((m10digits + e10 <= -324) || (m10 == 0)) {
    uint64_t ieee = ((uint64_t)signedM) << (DOUBLE_EXPONENT_BITS + DOUBLE_MANTISSA_BITS);
    *result = int64Bits2Double(ieee);
    return SUCCESS;
  }
  if (m10digits + e10 >= 310) {
    uint64_t ieee = (((uint64_t)signedM) << (DOUBLE_EXPONENT_BITS + DOUBLE_MANTISSA_BITS)) |
      (0x7ffull << DOUBLE_MANTISSA_BITS);
    *result = int64Bits2Double(ieee);
    return SUCCESS;
  }

  int32_t e2;
  uint64_t m2;
  bool trailingZeros;
  if (e10 >= 0) {
    e2 = floor_log2(m10) + e10 + log2pow5(e10) - (DOUBLE_MANTISSA_BITS + 1);
    int j = e2 - e10 - ceil_log2pow5(e10) + DOUBLE_POW5_BITCOUNT;
    assert(j >= 0);
    assert(e10 < DOUBLE_POW5_TABLE_SIZE);
    m2 = mulShift64(m10, DOUBLE_POW5_SPLIT[e10], j);
    trailingZeros = e2 < e10 || (e2 - e10 < 64 && multipleOfPowerOf2(m10, e2 - e10));
  } else {
    e2 = floor_log2(m10) + e10 - ceil_log2pow5(-e10) - (DOUBLE_MANTISSA_BITS + 1);
    int j = e2 - e10 + ceil_log2pow5(-e10) - 1 + DOUBLE_POW5_INV_BITCOUNT;
    assert(-e10 < DOUBLE_POW5_INV_TABLE_SIZE);
    m2 = mulShift64(m10, DOUBLE_POW5_INV_SPLIT[-e10], j);
    trailingZeros = multipleOfPowerOf5(m10, -e10);
  }

  uint32_t ieee_e2 = (uint32_t)max32(0, e2 + DOUBLE_EXPONENT_BIAS + floor_log2(m2));
  if (ieee_e2 > 0x7fe) {
    uint64_t ieee = (((uint64_t)signedM) << (DOUBLE_EXPONENT_BITS + DOUBLE_MANTISSA_BITS)) |
      (0x7ffull << DOUBLE_MANTISSA_BITS);
    *result = int64Bits2Double(ieee);
    return SUCCESS;
  }

  int32_t shift = (ieee_e2 == 0 ? 1 : ieee_e2) - e2 - DOUBLE_EXPONENT_BIAS - DOUBLE_MANTISSA_BITS;
  assert(shift >= 0);
  trailingZeros &= (m2 & ((1ull << (shift - 1)) - 1)) == 0;
  uint64_t lastRemovedBit = (m2 >> (shift - 1)) & 1;
  bool roundUp = (lastRemovedBit != 0) && (!trailingZeros || (((m2 >> shift) & 1) != 0));
  uint64_t ieee_m2 = (m2 >> shift) + roundUp;
  assert(ieee_m2 <= (1ull << (DOUBLE_MANTISSA_BITS + 1)));
  ieee_m2 &= (1ull << DOUBLE_MANTISSA_BITS) - 1;
  if (ieee_m2 == 0 && roundUp) {
    ieee_e2++;
  }
  uint64_t ieee = (((((uint64_t)signedM) << DOUBLE_EXPONENT_BITS) | (uint64_t)ieee_e2) <<
    DOUBLE_MANTISSA_BITS) | ieee_m2;
  *result = int64Bits2Double(ieee);
  return SUCCESS;
}
