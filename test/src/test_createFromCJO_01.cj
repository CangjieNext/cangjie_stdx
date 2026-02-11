/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/import
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

import stdx.syntax.*
import stdx.semantic.*
import std.unittest.testmacro.*
import std.unittest.*
@Test
class SemanticContextTest01 {
    var semaContext: SemanticContext = SemanticContext.createFromCJOFile("sourceFile/import/define.cjo")

    @TestCase
    func test01() {
        @Expect(semaContext.syntaxTree.toString(), """
// define.cj
package define
class A {
    let a: Int64
    init(a: Int64)
}
""")
    }
}