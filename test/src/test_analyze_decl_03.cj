/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_decl_02 sourceFile/import
// (not Windows) EXEC: dos2unix package_decl_02/decls.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

func showDiag(diag: DiagnosticInfo) {
    match (diag) {
        case DiagnosticInfo.Error(info, hint) =>
            println("ERROR: ${info}, HINT: ${hint}")
        case DiagnosticInfo.Warning(info, hint) =>
            println("WARNING: ${info}, HINT: ${hint}")
        case _ => 
            println("UNKNOWN diag info")
        
    }
}

func parse(path: String): Package {
    try {
        let res = parsePackage(path)
        if (let Some(node) <- res.node) {
            node
        } else {
            for (diag in res.diags) {
                showDiag(diag.diagInfo)
            }
            throw Exception("parse get error")
        }
    } catch (e: Exception) {
        throw e
    }
}

@Test
class SemanticResultTest003 {
    var semaRes: ?SemanticResult = None
    var path: String = "sourceFile/package/package_decl_03"

    @BeforeAll
    func readDecls(): Unit {
        try {
            let pkgAST: Package =  parse(this.path)
            semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        } catch (e: Exception) {
            println("FAIL: parse ${this.path} error: ${e.message}")
        }
    }

    @TestCase [
        data in ["A", "B", "I"]
    ]
    func testGetDecl01(data: String) {
        let ty = CompositeType(data, [], [])
        if (let Some(res) <- semaRes) {
            if (let Some(decl) <- res.getDecl(ty)) {
                println(decl)
            }
        }
        @Expect(true)
    }

    @TestCase [
        data in [("A", 2), ("B", 2), ("I", 1)]
    ]
    func testGetMembers(data: (ty: String, size: Int64)) {
        let ty = CompositeType(data[0], [], [])
        if (let Some(res) <- semaRes) {
            if (let Some(decl) <- res.getDecl(ty)) {
                let mems = res.getMembers(decl)
                println("members: ${mems.size}")
                @Expect(mems.size, data[1])
            }
        }
    }

    @TestCase [
        data in [("A", 1), ("B", 1), ("I", 0)]
    ]
    func testGetSuperTys(data: (ty: String, size: Int64)) {
        let ty = CompositeType(data[0], [], [])
        if (let Some(res) <- semaRes) {
            if (let Some(decl) <- res.getDecl(ty)) {
                let supers = res.getSuperTys(decl)
                println("supers: ${supers.size}")
                @Expect(supers.size, data[1])
            }
        }
    }

    @TestCase [
        data in [("A", 0), ("B", 0), ("I", 2)]
    ]
    func testGetSubTys(data: (ty: String, size: Int64)) {
        let ty = CompositeType(data[0], [], [])
        if (let Some(res) <- semaRes) {
            if (let Some(decl) <- res.getDecl(ty)) {
                let subs = res.getSubTys(decl)
                println("subs: ${subs.size}")
                @Expect(subs.size, data[1])
            }
        }
    }
}

