/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

/**
 * @file
 *
 * This file defines a semaphore without limit that is specialized for a single consumer.
 *
 */

package stdx.actors

import std.sync.AtomicUInt64
import std.sync.Mutex
import std.sync.Condition
import std.time.DateTime

class SingleConsumerSemaphore {
    private let cnt = AtomicUInt64(0)
    private let mtx = Mutex()
    private let cond: Condition

    init() {
        synchronized(mtx) {
            cond = mtx.condition()
        }
    }

    func signal(): Unit {
        let n = cnt.fetchAdd(1)
        if (n == 0) {
            synchronized(mtx) {
                cond.notifyAll()
            }
        }
    }
    // It might appear that the following sequence would result in a deadlock:
    // Pre: cnt == 0
    // Consumer wait():
    //   1) n = cnt.load()
    //   2) n == 0 (true)
    // Producer signal():
    //   3) n = cnt.fetchAdd(1)
    //   4) n == 0 (true)
    //   5) synchronized(mtx) {
    //   6)   cond.notifyAll()
    //   7) }
    // Consumer wait():
    //   8) let startTime = DateTime.now()
    //   9) synchronized(mtx) {
    //  10)   ... wait(...)
    // However, this is safe because the wait() has a timeout
    // which will eventually break out of the loop.
    func wait(timeout: Duration): Bool {
        let n = cnt.load()
        if (n == 0) {
            let startTime = DateTime.now()
            synchronized(mtx) {
                while (cnt.load() == 0) {
                    let timeElapsed = DateTime.now() - startTime
                    if (timeElapsed >= timeout) {
                        return false
                    }
                    cond.wait(timeout: timeout - timeElapsed)
                }
            }
        }
        cnt.fetchSub(1)
        true
    }
}
