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

    func wait(timeout: Duration): Unit {
        let n = cnt.load()
        if (n == 0) {
            synchronized(mtx) {
                let startTime = DateTime.now()
                while (cnt.load() == 0) {
                    if (timeout - (DateTime.now() - startTime) <= Duration.Zero) {
                        return
                    }
                    cond.wait(timeout: timeout - (DateTime.now() - startTime))
                }
            }
        }
        cnt.fetchSub(1)
    }
}
