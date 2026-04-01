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

    func wait(timeout: Duration): Bool {
        let n = cnt.load()
        if (n == 0) {
            // From the look of it, this might have a problem with signal() when
            // n == 0 and cnt.fetchAdd(1) is called and goes into the synchronized block
            // after we got here but before we got into the synchronized block.
            // However, it is still safe because wait() always has a timeout which will
            // eventually break out of the loop.
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
