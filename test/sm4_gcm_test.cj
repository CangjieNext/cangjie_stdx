/*
 * Copyright (c) 2026. All rights reserved.
 * SM4-GCM roundtrip regression test.
 *
 * Verifies that SM4-GCM encrypt/decrypt works end-to-end and that the
 * tag is correctly produced and verified (regression test for the
 * EVP_CTRL_AEAD_GET_TAG / EVP_CTRL_AEAD_SET_TAG constant fix).
 */

import stdx.crypto.crypto.*
import stdx.crypto.common.CryptoException

func assertTrue(cond: Bool, msg: String): Unit {
    if (!cond) {
        throw Exception("assert failed: ${msg}")
    }
}

func assertEq(actual: Array<Byte>, expected: Array<Byte>, msg: String): Unit {
    if (actual.size != expected.size) {
        throw Exception("${msg}: size mismatch ${actual.size} != ${expected.size}")
    }
    for (i in 0..actual.size) {
        if (actual[i] != expected[i]) {
            throw Exception("${msg}: byte mismatch at ${i}: ${actual[i]} != ${expected[i]}")
        }
    }
}

func roundtrip(key: Array<Byte>, iv: Array<Byte>, plain: Array<Byte>, aad: Array<Byte>,
    tagSize: Int64, expectTagSize: Int64): Unit {
    let enc = SM4(OperationMode.GCM, key, iv: iv, paddingMode: PaddingMode.NoPadding,
        aad: aad, tagSize: tagSize)
    let ciphertext = enc.encrypt(plain)
    // GCM output layout: ciphertext || tag
    assertTrue(ciphertext.size == plain.size + expectTagSize,
        "ciphertext length ${ciphertext.size} != ${plain.size + expectTagSize}")

    let dec = SM4(OperationMode.GCM, key, iv: iv, paddingMode: PaddingMode.NoPadding,
        aad: aad, tagSize: tagSize)
    let decrypted = dec.decrypt(ciphertext)
    assertEq(decrypted, plain, "roundtrip(tagSize=${tagSize})")

    // Tamper with the last tag byte: decryption must fail.
    var tampered = ciphertext.clone()
    if (tampered[tampered.size - 1] == 0) {
        tampered[tampered.size - 1] = 1
    } else {
        tampered[tampered.size - 1] = 0
    }
    var rejected = false
    try {
        dec.decrypt(tampered)
    } catch (e: CryptoException) {
        rejected = true
    }
    assertTrue(rejected, "tampered tag was not rejected (tagSize=${tagSize})")

    // Wrong AAD must fail tag verification. For the empty-AAD case the
    // wrong AAD must be non-empty so that it differs from the correct one.
    var wrongAad: Array<Byte> = Array<Byte>(aad.size, repeat: 0)
    if (wrongAad.size == 0) {
        wrongAad = Array<Byte>(1, repeat: 0)
    }
    let decWrongAad = SM4(OperationMode.GCM, key, iv: iv, paddingMode: PaddingMode.NoPadding,
        aad: wrongAad, tagSize: tagSize)
    var aadRejected = false
    try {
        decWrongAad.decrypt(ciphertext)
    } catch (e: CryptoException) {
        aadRejected = true
    }
    assertTrue(aadRejected, "wrong aad was not rejected (tagSize=${tagSize})")
}

main() {
    // 16-byte SM4 key and IV
    let key = "0123456789abcdef".toArray()
    let iv = "abcdef0123456789".toArray()

    // 1. short payload with AAD
    roundtrip(key, iv, "SM4-GCM roundtrip".toArray(), "aad-data".toArray(), 16, 16)
    // 2. payload without AAD
    roundtrip(key, iv, "payload without aad".toArray(), Array<Byte>(), 16, 16)
    // 3. empty payload
    roundtrip(key, iv, Array<Byte>(), "aad-only".toArray(), 16, 16)
    // 4. non-default tag size (12 bytes)
    roundtrip(key, iv, "short tag test".toArray(), "aad-data".toArray(), 12, 12)
    // 5. large payload crossing the internal 1024-byte buffer
    var large = Array<Byte>(3000, repeat: 0)
    for (i in 0..3000) {
        if (i % 256 == 0) {
            large[i] = 1
        }
    }
    roundtrip(key, iv, large, "aad-data".toArray(), 16, 16)

    println("SM4-GCM roundtrip test passed")
}
