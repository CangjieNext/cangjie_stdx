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
import std.collection.ArrayList

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

func findDeclUnderMacro<D>(headDecl: Decl): Option<D> where D <: Decl {
    var decl = headDecl
    while (true) {
        if (let Some(d) <- (decl as D)) {
            return Some(d)
        }
        if (let Some(mc) <- (decl as MacroExpandDecl)) {
            decl = mc.macroInputDecl
        } else {
            return None
        }
    }
    return None
}

func checkModifiers(mods: ArrayList<Modifier>, notAllowed: Array<TokenKind>): Bool {
    for (mod in mods) {
        for (kind in notAllowed) {
            if (mod.keyword.kind == kind) {
                return false
            }
        }
    }
    return true
}

func processReceivers(
    decls: ArrayList<Decl>,
    nonReceiverAction: (Decl) -> Unit,
    receiverAction: (MacroExpandDecl) -> Unit
): Unit {
    for (decl in decls) {
        match (decl) {
            case mDecl: MacroExpandDecl =>
                if (mDecl.identifier.value != receiverMarkerToken.value) {
                    nonReceiverAction(decl)
                    continue
                }
                receiverAction(mDecl)
            case _ =>
                nonReceiverAction(decl)
        }
    }
}
