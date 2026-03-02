/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_is_expr
// (not Windows) EXEC: dos2unix package_is_expr/exprs.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

@Test
class IsExprTest001 {
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
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_is_expr")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let file = pkgAST.srcFile[0]
        let decl = (file.topLevelDecls[1] as FuncDecl).getOrThrow()

        nodes = decl.body.getOrThrow().nodes
    }

    @TestCase
    func testIsExpr00() {
        let expr = (nodes[0] as IsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Bool")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testIsExpr01() {
        let expr = (nodes[1] as IsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Bool")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testIsExpr02() {
        let expr = (nodes[2] as IsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Bool")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testIsExpr03() {
        let expr = (nodes[3] as IsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Bool")
            case None => @FailExpect("no type info")
        }
    }
}
