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
 * This file defines the Actor class and provide method to submit a closure to it.
 *
 */

package stdx.actors

import std.collection.concurrent.ConcurrentLinkedQueue

public class SequentialDispatcher {
    let mailbox: Mailbox
    let numMsg: SingleConsumerSemaphore
    let threadHandle: Future<Unit>

    public init(enableReceiverPriority!: Bool = false) {
        this.mailbox = if (enableReceiverPriority) {
            UnboundedPriorityMailbox()
        } else {
            UnboundedMailbox()
        }
        this.numMsg = SingleConsumerSemaphore()
        this.threadHandle = startActorLoop(mailbox, numMsg)
    }

    static func startActorLoop(mailbox: Mailbox, numMsg: SingleConsumerSemaphore): Future<Unit> {
        spawn {
            while (true) {
                numMsg.wait()

                if (Thread.currentThread.hasPendingCancellation) {
                    return
                }

                match (mailbox.remove()) {
                    case Some((_, f)) => f()
                    case None => ()
                }
            }
        }
    }

    public func post<T>(f: () -> T, priority!: Int64 = 5): ActorFuture<T> {
        let fut = ActorFuture<T>(f)
        mailbox.add((this, fut.execute), priority)
        numMsg.signal()
        return fut
    }

    ~init() {
        while (!threadHandle.thread.hasPendingCancellation) {
            threadHandle.cancel()
        }
        numMsg.signal()
    }
}
