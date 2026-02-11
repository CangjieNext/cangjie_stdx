/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#ifndef CJ_API_H
#define CJ_API_H

#include <stdbool.h>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include "opensslSymbols.h"

#define CJ_EOF 0
#define CJ_FAIL (-1)
#define CJ_NEED_READ (-2)
#define CJ_NEED_WRITE (-3)
#define CJ_OK 1

struct StringArrayResult {
    char** buffer;
    size_t size;
};

struct ByteResult {
    uint8_t* buffer;
    size_t size;
};

struct ByteArrayResult {
    struct ByteResult* buffer;
    size_t size;
};

struct UInt16Result {
    uint16_t* buffer;
    size_t size;
};

#define X509_RESULT_SIZE sizeof(struct StringArrayResult)

typedef struct ExceptionDataS ExceptionData;

typedef struct CipherSuite {
    const char* name;
} CipherSuite;

// this should be syncronized with foreign struct in Cangjie code
typedef struct EncryptedKeyParams {
    char* password;
    const unsigned char* iv;
    size_t ivLength;
    const char* cipherName;
} EncryptedKeyParams;

#endif
