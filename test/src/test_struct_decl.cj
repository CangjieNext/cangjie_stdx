/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_struct_decl
// (not Windows) EXEC: dos2unix package_struct_decl/decls.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

@Test
class AnalyzeTestStructDecl001 {
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
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_struct_decl")
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
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Struct_00")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl01() {
        let decl = decls[1]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Struct_01")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl02() {
        let decl = (decls[2] as StructDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Struct_02")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Int64")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Float64")
                case (2, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Int64, Float64) -> Struct_02")
                case (3, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Int64) -> Struct_02")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl03() {
        let decl = (decls[3] as StructDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Struct_03")
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
    func testDecl04() {
        let decl = (decls[4] as StructDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Struct_04")
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
    func testDecl05() {
        let decl = (decls[5] as StructDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Struct_05<T>")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "T")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(T) -> Struct_05<T>")
                case (2, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "() -> T")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl06() {
        let decl = (decls[6] as StructDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Struct_06<K, V>")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "K")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "V")
                case (2, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(K, V) -> Struct_06<K, V>")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }

    @TestCase
    func testDecl07() {
        let decl = (decls[7] as StructDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Struct_07")
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
    func testDecl08() {
        let decl = (decls[8] as StructDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Struct_08")
            case None => @FailExpect("no type info")
        }

        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Int64")
                case (1, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "Int64")
                case (2, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Int64, Int64) -> Struct_08")
                case (3, Some(funcTy: SemanticType)) =>  @Expect(Some(funcTy.toString()), "(Struct_08) -> Struct_08")
                case (_, None) => @FailExpect("no type info")
                case (_, _) => println("extra node")
            }
        }
    }



}
