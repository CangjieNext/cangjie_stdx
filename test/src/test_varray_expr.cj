/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_varray_expr
// (not Windows) EXEC: dos2unix package_varray_expr/exprs.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

@Test
class VArrayExprTest001 {
    var decls: Array<Decl> = []
    var semaRes: SemanticResult = SemanticResult.analyze(Package(false, "default", 
        [SourceFile([], "default", "/path/to/sourceFile.cj", None, 
            MainDecl(
                Block([ReturnExpr(None)]), 
                ParameterList([]), 
                AtomicType(UnitType))
        )]), importedPkgContexts: [])
    var nodes: Array<SyntaxTreeNode> = []

    @BeforeAll
    func readExprs(): Unit {
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_varray_expr")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let file = pkgAST.srcFile[0]
        let decl = (file.topLevelDecls[0] as FuncDecl).getOrThrow()

        nodes = decl.body.getOrThrow().nodes
    }

    @TestCase
    @Skip
    func testVArrayExpr00() {
        let expr = (nodes[0] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<Int64, $6>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr01() {
        let expr = (nodes[1] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<UInt32, $3>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr02() {
        let expr = (nodes[2] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<UInt16, $3>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr03() {
        let expr = (nodes[3] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<UInt8, $3>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr04() {
        let expr = (nodes[4] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<UInt64, $2>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr05() {
        let expr = (nodes[5] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<UInt32, $2>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr06() {
        let expr = (nodes[6] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<UInt16, $2>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr07() {
        let expr = (nodes[7] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<UInt8, $2>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr08() {
        let expr = (nodes[8] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<Float16, $4>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr09() {
        let expr = (nodes[9] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<Float32, $4>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr10() {
        let expr = (nodes[10] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<Float64, $4>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr11() {
        let expr = (nodes[11] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<Bool, $2>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr12() {
        let expr = (nodes[12] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<Rune, $3>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr13() {
        let expr = (nodes[13] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<(Int64, Bool), $2>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr14() {
        let expr = (nodes[14] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<(Float64, Rune), $2>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr15() {
        let expr = (nodes[15] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<VArray<Int64, $2>, $3>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr16() {
        let expr = (nodes[16] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<VArray<Bool, $3>, $2>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr17() {
        let expr = (nodes[17] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<(String, Int64), $2>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr18() {
        let expr = (nodes[18] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<Unit, $2>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testVArrayExpr19() {
        let expr = (nodes[19] as VArrayExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "VArray<(VArray<Int64, $2>, Bool), $2>")
            case None => @FailExpect("no type info")
        }
    }



}
