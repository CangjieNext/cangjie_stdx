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
 * This file defines utility functions used by the actor macros.
 *
 */

macro package stdx.actors.macros

import std.ast.*

const PREFIX = "___actors__9723459842301294657___"
const ACTOR_MACRO_NAME = "Actor"
const RECEIVER_MARKER_NAME = PREFIX + "Receiver"
const ACTOR_INSTANCE_NAME = PREFIX + "actorInstance"
let receiverMarkerToken = Token(IDENTIFIER, RECEIVER_MARKER_NAME)
let actorInstanceToken = Token(IDENTIFIER, ACTOR_INSTANCE_NAME)

func actorFutureType(t: TypeNode): RefType {
    RefType(quote(
        ActorFuture<$t>
    ))
}
