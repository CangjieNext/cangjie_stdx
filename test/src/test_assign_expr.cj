/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_assign_expr
// (not Windows) EXEC: dos2unix package_assign_expr/exprs.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

@Test
class AssignExprTest001 {
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
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_assign_expr")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let file = pkgAST.srcFile[0]
        let decl = (file.topLevelDecls[0] as FuncDecl).getOrThrow()

        nodes = decl.body.getOrThrow().nodes
    }

    @TestCase
    func testAssignExpr00() {
        let expr = (nodes[5] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAssignExpr01() {
        let expr = (nodes[6] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAssignExpr02() {
        let expr = (nodes[7] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAssignExpr03() {
        let expr = (nodes[8] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAssignExpr04() {
        let expr = (nodes[9] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAssignExpr05() {
        let expr = (nodes[10] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }
    
    @TestCase
    func testAssignExpr06() {
        let expr = (nodes[11] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAssignExpr07() {
        let expr = (nodes[12] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAssignExpr08() {
        let expr = (nodes[13] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAssignExpr09() {
        let expr = (nodes[14] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAssignExpr10() {
        let expr = (nodes[15] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAssignExpr11() {
        let expr = (nodes[16] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAssignExpr12() {
        let expr = (nodes[17] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }
    
    @TestCase
    func testAssignExpr13() {
        let expr = (nodes[18] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAssignExpr14() {
        let expr = (nodes[19] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAssignExpr15() {
        let expr = (nodes[20] as AssignExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }


}
