/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_spawn_expr
// (not Windows) EXEC: dos2unix package_spawn_expr/exprs.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

@Test
class SpawnExprTest001 {
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
        let parsingRes: ParsingResult<Package> = parsePackage("../sourceFile/package/package_spawn_expr")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let file = pkgAST.srcFile[0]
        let decl = (file.topLevelDecls[0] as FuncDecl).getOrThrow()

        nodes = decl.body.getOrThrow().nodes
    }

    @TestCase
    func testSpawnExpr00() {
        let expr = (nodes[0] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<Unit>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr01() {
        let expr = (nodes[1] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<Int64>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr02() {
        let expr = (nodes[2] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<Int8>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr03() {
        let expr = (nodes[3] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<Int16>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr04() {
        let expr = (nodes[4] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<Int32>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr05() {
        let expr = (nodes[5] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<Float64>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr06() {
        let expr = (nodes[6] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<Float32>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr07() {
        let expr = (nodes[7] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<Float16>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr08() {
        let expr = (nodes[8] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<UInt8>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr09() {
        let expr = (nodes[9] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<UInt16>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr10() {
        let expr = (nodes[10] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<UInt32>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr11() {
        let expr = (nodes[11] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<UInt64>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr12() {
        let expr = (nodes[12] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<Bool>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr13() {
        let expr = (nodes[13] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<Rune>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr14() {
        let expr = (nodes[14] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<String>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr15() {
        let expr = (nodes[15] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<((Int64, String), (Bool, Float64, Rune))>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr16() {
        let expr = (nodes[16] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<Array<Int64>>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testSpawnExpr17() {
        let expr = (nodes[17] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<VArray<Int64, $6>>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testSpawnExpr18() {
        let expr = (nodes[18] as SpawnExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Future<Option<Int64>>")
            case None => @FailExpect("no type info")
        }
    }



}
