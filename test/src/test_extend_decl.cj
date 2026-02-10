/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_extend_decl
// (not Windows) EXEC: dos2unix package_extend_decl/decls.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*


@Test
class ExtendAnalyzeTest {
    var decls: Array<Decl> = []
    var semaRes: SemanticResult = SemanticResult.analyze(Package(false, "default", 
        [SourceFile([], "default", "/path/to/sourceFile.cj", None, 
            MainDecl(
                Block([ReturnExpr(None)]), 
                ParameterList([]), 
                AtomicType(UnitType))
        )]), importedPkgContexts: [])

    @BeforeAll
    func readDecls(): Unit {
        let parsingRes: ParsingResult<Package> = parsePackage("../sourceFile/package/package_extend_decl")
        
        let pkgAST: Package = parsingRes.node.getOrThrow()

        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let file = pkgAST.srcFile[0]

        decls = file.topLevelDecls
    }

    @TestCase
    func testclassA_Type() {
        let decl = decls[0]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @FailExpect("ExtendDecl should has no SemanticType")
            case None => ()
        }
    }

    @TestCase
    func testclassB_Type() {
        let decl = decls[1]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @FailExpect("ExtendDecl should has no SemanticType")
            case None => ()
        }
    }

    @TestCase
    func testclassC_Type() {
        let decl = decls[2]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @FailExpect("ExtendDecl should has no SemanticType")
            case None => ()
        }
    }

    @TestCase
    func testclassD_Type() {
        let decl = decls[3]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @FailExpect("ExtendDecl should has no SemanticType")
            case None => ()
        }
    }
   
    @TestCase
    func testclassTo_Type() {
        let decl = decls[4]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @FailExpect("ExtendDecl should has no SemanticType")
            case None => ()
        }
    }

    @TestCase
    func testinfFoo_Type() {
        let decl = decls[5]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @FailExpect("ExtendDecl should has no SemanticType")
            case None => ()
        }
    }

     @TestCase
    func testextendA_Type() {
        let decl = decls[6]
        var declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @FailExpect("ExtendDecl should has no SemanticType")
            case None => ()
        }
        
    }

    @TestCase
    func testextendB_Type() {
        let decl = decls[7]

        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @FailExpect("ExtendDecl should has no SemanticType")
            case None => ()
        }
       
    }

    @TestCase
    func testextendC_Type() {
        let decl = decls[8]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @FailExpect("ExtendDecl should has no SemanticType")
            case None => ()
        }
    }

    @TestCase
    func testextendD_Type() {
        let decl = decls[9]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @FailExpect("ExtendDecl should has no SemanticType")
            case None => ()
        }
    }



    
}