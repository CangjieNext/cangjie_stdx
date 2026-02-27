/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_return_expr
// (not Windows) EXEC: dos2unix package_return_expr/exprs.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

@Test
class AnalyzeExprTest001 {
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
        let parsingRes: ParsingResult<Package> = parsePackage("../sourceFile/package/package_return_expr")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let file = pkgAST.srcFile[0]
        decls = file.topLevelDecls
    }

    @TestCase
    func testExpr00() {
        let funcDecl = (decls[0] as FuncDecl).getOrThrow()
        let body = funcDecl.body.getOrThrow()
        let expr = (body.nodes[0] as ReturnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Nothing")
            case None => @FailExpect("no type info")
        }
    }
    @TestCase
    func testExpr01() {
        let funcDecl = (decls[1] as FuncDecl).getOrThrow()
        let body = funcDecl.body.getOrThrow()
        let expr = (body.nodes[0] as ReturnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Nothing")
            case None => @FailExpect("no type info")
        }
    }
    @TestCase
    func testExpr02() {
        let funcDecl = (decls[2] as FuncDecl).getOrThrow()
        let body = funcDecl.body.getOrThrow()
        let expr = (body.nodes[0] as ReturnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Nothing")
            case None => @FailExpect("no type info")
        }
    }
    @TestCase
    func testExpr03() {
        let funcDecl = (decls[3] as FuncDecl).getOrThrow()
        let body = funcDecl.body.getOrThrow()
        let expr = (body.nodes[0] as ReturnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Nothing")
            case None => @FailExpect("no type info")
        }
    }
    @TestCase
    func testExpr04() {
        let funcDecl = (decls[4] as FuncDecl).getOrThrow()
        let body = funcDecl.body.getOrThrow()
        let expr = (body.nodes[0] as ReturnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Nothing")
            case None => @FailExpect("no type info")
        }
    }
    @TestCase
    func testExpr05() {
        let funcDecl = (decls[5] as FuncDecl).getOrThrow()
        let body = funcDecl.body.getOrThrow()
        let expr = (body.nodes[0] as ReturnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Nothing")
            case None => @FailExpect("no type info")
        }
    }
    @TestCase
    func testExpr06() {
        let funcDecl = (decls[6] as FuncDecl).getOrThrow()
        let body = funcDecl.body.getOrThrow()
        let expr = (body.nodes[0] as ReturnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Nothing")
            case None => @FailExpect("no type info")
        }
    }
    @TestCase
    func testExpr07() {
        let funcDecl = (decls[7] as FuncDecl).getOrThrow()
        let body = funcDecl.body.getOrThrow()
        let expr = (body.nodes[0] as ReturnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Nothing")
            case None => @FailExpect("no type info")
        }
    }
    @TestCase
    func testExpr08() {
        let funcDecl = (decls[8] as FuncDecl).getOrThrow()
        let body = funcDecl.body.getOrThrow()
        let expr = (body.nodes[0] as ReturnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Nothing")
            case None => @FailExpect("no type info")
        }
    }
    @TestCase
    func testExpr09() {
        let funcDecl = (decls[9] as FuncDecl).getOrThrow()
        let body = funcDecl.body.getOrThrow()
        let expr = (body.nodes[0] as ReturnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Nothing")
            case None => @FailExpect("no type info")
        }
    }
    @TestCase
    func testExpr10() {
        let funcDecl = (decls[10] as FuncDecl).getOrThrow()
        let body = funcDecl.body.getOrThrow()
        let expr = (body.nodes[0] as ReturnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Nothing")
            case None => @FailExpect("no type info")
        }
    }
}
