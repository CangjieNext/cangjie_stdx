/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_tupleliteral_expr
// (not Windows) EXEC: dos2unix package_tupleliteral_expr/exprs.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

@Test
class TupleLiteralTest001 {
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
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_tupleliteral_expr")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let file = pkgAST.srcFile[0]
        let decl = (file.topLevelDecls[0] as FuncDecl).getOrThrow()

        nodes = decl.body.getOrThrow().nodes
    }

    @TestCase
    func testTupleLiteral00() {
        let expr = (nodes[0] as TupleLiteral).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "(Int64, Int64, Int64)")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testTupleLiteral01() {
        let expr = (nodes[1] as TupleLiteral).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "(Bool, Bool)")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testTupleLiteral02() {
        let expr = (nodes[2] as TupleLiteral).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "(Float64, Float64)")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testTupleLiteral03() {
        let expr = (nodes[3] as TupleLiteral).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "(Rune, Rune, Rune)")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testTupleLiteral04() {
        let expr = (nodes[4] as TupleLiteral).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "(String, String)")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testTupleLiteral05() {
        let expr = (nodes[5] as TupleLiteral).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "(Array<Int64>, Array<Int64>)")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testTupleLiteral06() {
        let expr = (nodes[6] as TupleLiteral).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "((Int64, Int64), (Int64, Int64, Int64))")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testTupleLiteral07() {
        let expr = (nodes[7] as TupleLiteral).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "((Int64, String), (Int64, String))")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testTupleLiteral08() {
        let expr = (nodes[8] as TupleLiteral).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "(Option<Int64>, Option<Int64>)")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testTupleLiteral09() {
        let expr = (nodes[9] as TupleLiteral).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "((Int64) -> Int64, () -> String)")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testTupleLiteral10() {
        let expr = (nodes[10] as TupleLiteral).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "(Int64, String, Bool, Array<Int64>, (Int64, Int64))")
            case None => @FailExpect("no type info")
        }
    }


}
