/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj.plugins.weave_rules

import stdx.aspect_cj.*
import stdx.chir.*
import stdx.plugin.*

@CHIRPlugin
class WeaveRules {
    public override func run(pkg: Package): Bool {
        try {
            let context = readRuleActionContextAny(pkg.name)
            if (context.action != "preselect" && context.action != "preflight" && context.action != "apply") {
                throw IllegalArgumentException("build-phase-invalid: Weaver action")
            }
            let wires = readRuleSourceInputs(context)
            if (context.action == "preselect") {
                let selected = preselectRuleSources(pkg, wires)
                let names = if (selected.isEmpty()) { "" } else { String.join(selected, delimiter: "\n") + "\n" }
                let report = "#aspect_cj_selected_sources_v1\n" + names
                writeRuleCandidate(context, report)
                return true
            }
            let plan = preflightRuleWeave(pkg, wires)
            let digest = ruleBuildPlanDigest(plan, context)
            if (context.action == "preflight") {
                var report = digest + "\n"
                for (source in rulePlanSourcePackages(plan, pkg.name)) { report += source + "\n" }
                writeRuleCandidate(context, report)
            } else {
                if (digest != context.expectedPlanDigest) {
                    throw IllegalArgumentException("build-input-mismatch: target plan digest")
                }
                applyRuleWeave(pkg, wires, plan)
            }
            return true
        } catch (error: Exception) {
            println("aspect_cj ${pkg.name} rule weave failed: ${error.message}")
            return false
        }
    }
}
