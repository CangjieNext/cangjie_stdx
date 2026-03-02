/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_interface_decl
// (not Windows) EXEC: dos2unix package_interface_decl/decls.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

@Test
class AnalyzeTestInterfaceDecl001 {
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
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_interface_decl")
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
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Interface_00")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl01() {
        let decl = (decls[1] as InterfaceDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Interface_01")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> Unit")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Int64) -> String")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl02() {
        let decl = (decls[2] as InterfaceDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Interface_02")
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
    func testDecl03() {
        let decl = (decls[3] as InterfaceDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Interface_03")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> Int64")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> String")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl04() {
        let decl = (decls[4] as InterfaceDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Interface_04")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> Interface_04")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> Unit")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl05() {
        let decl = (decls[5] as InterfaceDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Interface_05")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Interface_05) -> Interface_05")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Int64) -> String")
                case (2, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Int64, String) -> Unit")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl06() {
        let decl = (decls[6] as InterfaceDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Interface_06")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> Int64")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl07() {
        let decl = (decls[7] as InterfaceDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Interface_07")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> Bool")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl08() {
        let decl = (decls[8] as InterfaceDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Interface_08<T>")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> T")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(T) -> Unit")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl09() {
        let decl = (decls[9] as InterfaceDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Interface_09<T>")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls

        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(T) -> String")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl10() {
        let decl = (decls[10] as InterfaceDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Interface_10")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(R) -> Int64")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl11() {
        let decl = (decls[11] as InterfaceDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Interface_11")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> Int64")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Int64) -> Unit")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl12() {
        let decl = (decls[12] as InterfaceDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Interface_12")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> (Int64, String)")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> Option<Int64>")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }
 
}
