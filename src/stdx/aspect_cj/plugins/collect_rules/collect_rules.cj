/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj.plugins.collect_rules

import stdx.aspect_cj.*
import stdx.chir.*
import stdx.plugin.*

@CHIRPlugin
class CollectRules {
    public override func run(pkg: Package): Bool {
        try {
            let context = readRuleActionContext("collect", pkg.name)
            writeRuleDeclarationAbi(context, pkg)
            let wire = collectRuleWirePackage(pkg, context.sessionId,
                context.sourceActionKey, context.toolchainAbiKey)
            writeRuleCandidate(context, encodeRuleWire(wire))
            return true
        } catch (error: Exception) {
            println("aspect_cj collect failed: ${error.message}")
            return false
        }
    }
}
