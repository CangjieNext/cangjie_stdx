// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package stdx.aspect_cj.plugins.semantic_test

import stdx.aspect_cj.*
import stdx.chir.*
import stdx.plugin.*

// In-process test adapter for the public rule engine. Production builds use
// collect_rules and weave_rules through the staged driver instead.
@CHIRPlugin
class SemanticTestPlugin {
    public override func run(pkg: Package): Bool {
        let hash = String.join(Array<String>(64, repeat: "a"), delimiter: "")
        let session = String.join(Array<String>(32, repeat: "b"), delimiter: "")
        let sources = [collectRuleWirePackage(pkg, session, hash, hash)]
        let plans = preflightRuleWeave(pkg, sources)
        println("semantic planned=${plans.size}")
        applyRuleWeave(pkg, sources, plans)
        var rejected = false
        try {
            preflightRuleWeave(pkg, sources)
        } catch (error: IllegalArgumentException) {
            rejected = error.message.contains("already-woven")
        }
        if (!rejected) { throw IllegalArgumentException("repeat weaving was accepted") }
        println("semantic reentry=rejected")
        return true
    }
}
