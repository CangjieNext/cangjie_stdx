/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_enum_decl
// (not Windows) EXEC: dos2unix package_enum_decl/decls.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*


@Test
class EnumAnalyzeTest {
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
        let parsingRes: ParsingResult<Package> = parsePackage("../sourceFile/package/package_enum_decl")
        
        let pkgAST: Package = parsingRes.node.getOrThrow()

        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let file = pkgAST.srcFile[0]

        decls = file.topLevelDecls
    }

    
    @TestCase
    func testEnumA_Type() {
        let decl = decls[0]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "A")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testEnumB_Type() {
        let decl = decls[1]

        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "B")
            case None => @FailExpect("no type info")
        }
       
    }

    @TestCase
    func testEnumC_Type() {
        let decl = decls[2]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "C")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testEnumD_Type() {
        let decl = decls[3]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "D")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testEnumE_Type() {
        let decl = decls[4]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "E<T>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testEnumF_Type() {
        let decl = decls[5]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "F")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testEnumG_Type() {
        let decl = decls[6]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "G")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testEnumH_Type() {
        let decl = decls[7]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "H")
            case None => @FailExpect("no type info")
        }
    }

    
}