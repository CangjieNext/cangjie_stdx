/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_class_decl
// (not Windows) EXEC: dos2unix package_class_decl/decls.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

@Test
class AnalyzeTestClassDecl001 {
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
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_class_decl")
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
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Class_00")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl01() {
        let decl = (decls[1] as ClassDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Class_01")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Int64")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "String")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl02() {
        let decl = (decls[2] as ClassDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Class_02")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Int64")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Float64")
                case (2, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Int64, Float64) -> Class_02")
                case (3, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Int64) -> Class_02")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }
    
    @Skip
    @TestCase
    func testDecl03() {
        let decl = (decls[3] as ClassDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Class_03")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Int64, Int32) -> Class_03")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl04() {
        let decl = (decls[4] as ClassDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Class_04")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Int64")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Int64")
                case (2, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Int32")
                case (3, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Int32")
                case (4, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> String")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl05() {
        let decl = (decls[5] as ClassDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Class_05")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Int64")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> Int64")
                case (2, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> Unit")
                case (3, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> Unit")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl06() {
        let decl = (decls[6] as ClassDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Class_06<T>")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "T")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(T) -> Class_06<T>")
                case (2, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> T")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl07() {
        let decl = (decls[7] as ClassDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Class_07<K, V>")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "K")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "V")
                case (2, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Int32")
                case (3, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Float64")
                case (4, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(K, V) -> Class_07<K, V>")
                case (5, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Int32")
                case (6, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Float64")
                case (7, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Int64) -> Int64")
                case (8, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Float64) -> Float64")
                case (9, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Bool) -> Bool")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @Skip
    @TestCase
    func testDecl08() {
        let decl = (decls[8] as ClassDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Class_08")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @Skip
    @TestCase
    func testDecl09() {
        let decl = (decls[9] as ClassDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Class_09")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls

        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Int32) -> Bool")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl10() {
        let decl = (decls[10] as ClassDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Class_10")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Int32) -> Bool")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl11() {
        let decl = (decls[11] as ClassDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Class_11")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> Unit")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl12() {
        let decl = (decls[12] as ClassDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Class_12")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Int64")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Int64")
                case (2, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Int64, Int64) -> Class_12")
                case (3, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Class_12) -> Class_12")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }
 
}
