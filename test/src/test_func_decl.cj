/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_func_decl
// (not Windows) EXEC: dos2unix package_func_decl/decls.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

@Test
class AnalyzeTestFuncDecl001 {
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
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_func_decl")
        let pkgAST: Package = parsingRes.node.getOrThrow()
        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let file = pkgAST.srcFile[0]

        decls = file.topLevelDecls
    }

    @TestCase
    func testDecl00() {
        let decl = decls[0]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "() -> Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl01() {
        let decl = decls[1]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "() -> Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl02() {
        let decl = decls[2]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(Int64) -> Int64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl03() {
        let decl = decls[3]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(Int64, Float64) -> Bool")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl04() {
        let decl = decls[4]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(String) -> Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl05() {
        let decl = decls[5]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(T) -> T")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl06() {
        let decl = decls[6]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(K, V) -> K")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl07() {
        let decl = decls[7]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(K, V) -> V")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl08() {
        let decl = decls[8]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(Int32) -> Int32")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl09() {
        let decl = decls[9]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "() -> (Int64, Bool)")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl10() {
        let decl = decls[10]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "() -> (Int64, Bool)")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl11() {
        let decl = decls[11]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "() -> () -> Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl12() {
        let decl = decls[12]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(Int16) -> (Int16) -> Int16")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl13() {
        let decl = decls[13]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(Int16) -> (Int16) -> Int16")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl14() {
        let decl = decls[14]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(Int64) -> Option<Int64>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl15() {
        let decl = decls[15]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(Array<String>) -> Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl16() {
        let decl = decls[16]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(T) -> Array<T>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl17() {
        let decl = decls[17]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(Int64, Int64) -> Int64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl18() {
        let decl = decls[18]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "((Int32) -> Int16) -> Int16")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl19() {
        let decl = decls[19]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "((Int32) -> Int16) -> (Int32) -> Int16")
            case None => @FailExpect("no type info")
        }
    }
}
