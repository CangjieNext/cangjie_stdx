/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#ifndef CJ_SANCOV_STANDARD_CJ_SANCOV_STANDARD_H
#define CJ_SANCOV_STANDARD_CJ_SANCOV_STANDARD_H

#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

uint8_t* __cj_sancov_8bit_counters_ctor(uint64_t edgeCount);

uint32_t* __cj_sancov_pc_guard_ctor(uint64_t edgeCount);

uint64_t __cj_sancov_func_count_table(uint64_t n, const int8_t** funcNameTable, uint64_t* funcBBCountTable);

void __cj_sancov_pcs_init(const int8_t* packageName, uint64_t n, const int8_t** funcNameTable,
    const int8_t** fileNameTable, const uint64_t* lineNumberTable);

void __cj_sanitizer_weak_hook_memcmp(const void* s1, const void* s2, size_t n);

void __cj_sanitizer_weak_hook_strcasecmp(const char* s1, const char* s2);

void __cj_sanitizer_weak_hook_strncmp(const char* s1, const char* s2, size_t n);

void __cj_sanitizer_weak_hook_strcmp(const char* s1, const char* s2);

#ifdef __cplusplus
}
#endif

#endif // CJ_SANCOV_STANDARD_CJ_SANCOV_STANDARD_H
