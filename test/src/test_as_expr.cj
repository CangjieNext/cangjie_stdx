/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_as_expr
// (not Windows) EXEC: dos2unix package_as_expr/exprs.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

@Test
class AsExprTest001 {
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
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_as_expr")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let file = pkgAST.srcFile[0]
        let decl = (file.topLevelDecls[0] as FuncDecl).getOrThrow()

        nodes = decl.body.getOrThrow().nodes
    }

    @TestCase
    func testAsExpr00() {
        let expr = (nodes[0] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Int64>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr01() {
        let expr = (nodes[1] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Int32>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr02() {
        let expr = (nodes[2] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Int16>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr03() {
        let expr = (nodes[3] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Int8>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr04() {
        let expr = (nodes[4] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Float64>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr05() {
        let expr = (nodes[5] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Float32>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr06() {
        let expr = (nodes[6] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Float16>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr07() {
        let expr = (nodes[7] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<UInt64>")
            case None => @FailExpect("no type info")
        }
    }
    
    @TestCase
    func testAsExpr08() {
        let expr = (nodes[8] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<UInt32>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr09() {
        let expr = (nodes[9] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<UInt16>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr10() {
        let expr = (nodes[10] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<UInt8>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr11() {
        let expr = (nodes[11] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<String>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr12() {
        let expr = (nodes[12] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Int16>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr13() {
        let expr = (nodes[13] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Rune>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr14() {
        let expr = (nodes[14] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Bool>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr15() {
        let expr = (nodes[15] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Unit>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr16() {
        let expr = (nodes[16] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Nothing>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr17() {
        let expr = (nodes[17] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Range<Int64>>")
            case None => @FailExpect("no type info")
        }
    }
    
    @TestCase
    func testAsExpr18() {
        let expr = (nodes[18] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Range<Rune>>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr19() {
        let expr = (nodes[19] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Range<UInt64>>")
            case None => @FailExpect("no type info")
        }
    }
@TestCase
    func testAsExpr20() {
        let expr = (nodes[20] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Array<Int64>>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr21() {
        let expr = (nodes[21] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<Array<String>>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testAsExpr22() {
        let expr = (nodes[22] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<VArray<Int64, $3>>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testAsExpr23() {
        let expr = (nodes[23] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<VArray<Rune, $3>>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testAsExpr24() {
        let expr = (nodes[24] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<VArray<Float64, $3>>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testAsExpr25() {
        let expr = (nodes[25] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<VArray<Bool, $3>>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    @Skip
    func testAsExpr26() {
        let expr = (nodes[26] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<VArray<VArray<Bool, $3>, $2>>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr27() {
        let expr = (nodes[27] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<(Int64, Float64)>")
            case None => @FailExpect("no type info")
        }
    }
    
    @TestCase
    func testAsExpr28() {
        let expr = (nodes[28] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<(Int64, Float64, String)>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr29() {
        let expr = (nodes[29] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<(Int64, Float64, String, Bool)>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testAsExpr30() {
        let expr = (nodes[30] as AsExpr).getOrThrow()
        println(expr)
        let exprTyInfo: Option<SemanticType> = semaRes.getTypeInfo(expr)
        match (exprTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Option<(Unit, Nothing, Rune, UInt64)>")
            case None => @FailExpect("no type info")
        }
    }




}
