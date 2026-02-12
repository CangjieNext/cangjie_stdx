/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %output %f %cmp_utest_opt
// RUN-EXEC: %run_stdx %output --bench %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*


@Test
@Configure[baseline: "test_analyze_syntax"]
class Test_Analyze_Bench {
    @Bench
    func test_analyze_syntax(): Unit {
        let parsingRes: ParsingResult<Package> = parsePackage("../../src/stdx/syntax")
        let pkgAST: Package = parsingRes.node.getOrThrow()
        SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        return
    }
}
