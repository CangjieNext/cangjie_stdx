/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_mian_decl
// (not Windows) EXEC: dos2unix package_main_decl/main1.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*


@Test
class MainAnalyzeTest {
    @TestCase
    func testMain1_Type() {
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_main_decl/package_main_decl_01")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        let semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let files=pkgAST.srcFile
        let decl = files[0].topLevelDecls[0]
        var declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "() -> Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testMain2_Type() {
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_main_decl/package_main_decl_02")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        let semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let files=pkgAST.srcFile
        let decl = files[0].topLevelDecls[0]

        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "() -> Int64")
            case None => @FailExpect("no type info")
        }
       
    }

    @TestCase
    func testMain3_Type() {
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_main_decl/package_main_decl_03")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        let semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let files=pkgAST.srcFile
        let decl = files[0].topLevelDecls[0]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "() -> Int32")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testMain4_Type() {
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_main_decl/package_main_decl_04")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        let semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let files=pkgAST.srcFile
        let decl = files[0].topLevelDecls[0]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "(Array<String>) -> Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testMain5_Type() {
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_main_decl/package_main_decl_05")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        let semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let files=pkgAST.srcFile
        let decl = files[0].topLevelDecls[0]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "(Array<String>) -> Int64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testMain6Type() {
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_main_decl/package_main_decl_06")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        let semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let files=pkgAST.srcFile
        let decl = files[0].topLevelDecls[0]
        let declTyInfo = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "(Array<String>) -> Int8")
            case None => @FailExpect("no type info")
        }
    }

    
}