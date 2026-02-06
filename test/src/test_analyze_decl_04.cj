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

@Test
class AnalyzeTest003 {
    var semaRes: SemanticResult = SemanticResult.analyze(Package(false, "default", 
        [SourceFile([], "default", "/path/to/sourceFile.cj", None, 
            MainDecl(
                Block([ReturnExpr(None)]), 
                ParameterList([]), 
                AtomicType(UnitType))
        )]), importedPkgContexts: [])
    var files = Array<SourceFile>()

    @BeforeAll
    func readDecls(): Unit {
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_decl_04")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        files = pkgAST.srcFile
    }

    @TestCase
    func testDecl00() {
        let decl = files[0].topLevelDecls[0]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(String) -> String")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl01() {
        let decl = files[1].topLevelDecls[0]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(Int64) -> Int64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl02() {
        let decl = files[1].topLevelDecls[1]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Array<Int64>")
            case None => @FailExpect("no type info")
        }
    }
}