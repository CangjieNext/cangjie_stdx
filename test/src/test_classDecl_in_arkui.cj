/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_classDecl_in_arkui
// (not Windows) EXEC: dos2unix package_classDecl_in_arkui/decls.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

@Test
class AnalyzeTestClassDeclInArkUI {
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
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_classDecl_in_arkui")
        let pkgAST: Package = parsingRes.node.getOrThrow()
        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        for (i in 0..3) {
            let file = pkgAST.srcFile[i]
             println("file_${i}: ${file.name}")
        }
        let file = pkgAST.srcFile[0]

        decls = file.topLevelDecls
    }

    @TestCase
    func testDecl00() {
        let decl = decls[0]
        var declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(classTy: SemanticType) => @Expect(classTy.toString(), "CallbackResource")
            case None => @FailExpect("no type info")
        }
        let decls00 = (decl as ClassDecl).getOrThrow().body.memberDecls
        @Expect(decls00.size, 4)
        declTyInfo = semaRes.getTypeInfo(decls00[0])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Int32")
            case None => @FailExpect("no type info")
        }
        declTyInfo = semaRes.getTypeInfo(decls00[1])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "pointer")
            case None => @FailExpect("no type info")
        }
        declTyInfo = semaRes.getTypeInfo(decls00[2])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "pointer")
            case None => @FailExpect("no type info")
        }
        declTyInfo = semaRes.getTypeInfo(decls00[3])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "(Int32, pointer, pointer) -> CallbackResource")
            case None => @FailExpect("no type info")
        }
    }

    @Skip
    @TestCase
    func testDecl01() {
        let decl = decls[1]
        var declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(classTy: SemanticType) => @Expect(classTy.toString(), "DeserializerBase")
            case None => @FailExpect("no type info")
        }
        let decls01 = (decl as ClassDecl).getOrThrow().body.memberDecls
        @Expect(decls01.size, 25)
        declTyInfo = semaRes.getTypeInfo(decls01[0])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Int32")
            case None => @FailExpect("no type info 0")
        }
        declTyInfo = semaRes.getTypeInfo(decls01[1])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Int32")
            case None => @FailExpect("no type info 1")
        }
        declTyInfo = semaRes.getTypeInfo(decls01[2])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "UInt64")
            case None => @FailExpect("no type info 2")
        }
        declTyInfo = semaRes.getTypeInfo(decls01[3])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "(UInt64, Int32) -> DeserializerBase")
            case None => @FailExpect("no type info 3")
        }
        declTyInfo = semaRes.getTypeInfo(decls01[4])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "(Array<UInt8>, Int32) -> DeserializerBase")
            case None => @FailExpect("no type info 4")
        }
        declTyInfo = semaRes.getTypeInfo(decls01[5])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "(pointer, Int32, Int32, UInt8) -> Unit")
            case None => @FailExpect("no type info 5")
        }
        declTyInfo = semaRes.getTypeInfo(decls01[6])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "(pointer, Int32, Int32) -> Int32")
            case None => @FailExpect("no type info 6")
        }
        declTyInfo = semaRes.getTypeInfo(decls01[7])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> UInt64")
            case None => @FailExpect("no type info 7")
        }
        declTyInfo = semaRes.getTypeInfo(decls01[8])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> Int32")
            case None => @FailExpect("no type info 8")
        }
        declTyInfo = semaRes.getTypeInfo(decls01[9])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> Unit")
            case None => @FailExpect("no type info 9")
        }
        declTyInfo = semaRes.getTypeInfo(decls01[10])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "(Int32) -> Unit")
            case None => @FailExpect("no type info 10")
        }

        declTyInfo = semaRes.getTypeInfo(decls01[11])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> Int8")
            case None => @FailExpect("no type info 11")
        }
        var varDecl = (decls01[11] as FuncDecl).getOrThrow().body.getOrThrow().nodes[1] as VarDecl
        var varDeclTyInfo = semaRes.getTypeInfo(varDecl.getOrThrow())
        match (varDeclTyInfo) {
            case Some(varDeclTy: SemanticType) => @Expect(varDeclTy.toString(), "Int32")
            case None => @FailExpect("no varDecl type info 11")
        }

        declTyInfo = semaRes.getTypeInfo(decls01[12])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> Int32")
            case None => @FailExpect("no type info 12")
        }
        varDecl = (decls01[12] as FuncDecl).getOrThrow().body.getOrThrow().nodes[1] as VarDecl
        varDeclTyInfo = semaRes.getTypeInfo(varDecl.getOrThrow())
        match (varDeclTyInfo) {
            case Some(varDeclTy: SemanticType) => @Expect(varDeclTy.toString(), "Array<UInt8>")
            case None => @FailExpect("no varDecl type info 12")
        }

        declTyInfo = semaRes.getTypeInfo(decls01[13])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> Int64")
            case None => @FailExpect("no type info 13")
        }
        varDecl = (decls01[13] as FuncDecl).getOrThrow().body.getOrThrow().nodes[1] as VarDecl
        varDeclTyInfo = semaRes.getTypeInfo(varDecl.getOrThrow())
        match (varDeclTyInfo) {
            case Some(varDeclTy: SemanticType) => @Expect(varDeclTy.toString(), "Array<UInt8>")
            case None => @FailExpect("no varDecl type info 13")
        }

        declTyInfo = semaRes.getTypeInfo(decls01[14])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> UInt64")
            case None => @FailExpect("no type info 14")
        }
        varDecl = (decls01[14] as FuncDecl).getOrThrow().body.getOrThrow().nodes[1] as VarDecl
        varDeclTyInfo = semaRes.getTypeInfo(varDecl.getOrThrow())
        match (varDeclTyInfo) {
            case Some(varDeclTy: SemanticType) => @Expect(varDeclTy.toString(), "Array<UInt8>")
            case None => @FailExpect("no varDecl type info 14")
        }

        declTyInfo = semaRes.getTypeInfo(decls01[15])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> Float32")
            case None => @FailExpect("no type info 15")
        }
        varDecl = (decls01[15] as FuncDecl).getOrThrow().body.getOrThrow().nodes[1] as VarDecl
        varDeclTyInfo = semaRes.getTypeInfo(varDecl.getOrThrow())
        match (varDeclTyInfo) {
            case Some(varDeclTy: SemanticType) => @Expect(varDeclTy.toString(), "Array<UInt8>")
            case None => @FailExpect("no varDecl type info 15")
        }

        declTyInfo = semaRes.getTypeInfo(decls01[16])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> Float64")
            case None => @FailExpect("no type info 16")
        }
        varDecl = (decls01[16] as FuncDecl).getOrThrow().body.getOrThrow().nodes[1] as VarDecl
        varDeclTyInfo = semaRes.getTypeInfo(varDecl.getOrThrow())
        match (varDeclTyInfo) {
            case Some(varDeclTy: SemanticType) => @Expect(varDeclTy.toString(), "Array<UInt8>")
            case None => @FailExpect("no varDecl type info 16")
        }

        declTyInfo = semaRes.getTypeInfo(decls01[17])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> Bool")
            case None => @FailExpect("no type info 17")
        }
        varDecl = (decls01[17] as FuncDecl).getOrThrow().body.getOrThrow().nodes[0] as VarDecl
        varDeclTyInfo = semaRes.getTypeInfo(varDecl.getOrThrow())
        match (varDeclTyInfo) {
            case Some(varDeclTy: SemanticType) => @Expect(varDeclTy.toString(), "Int32")
            case None => @FailExpect("no varDecl type info 17")
        }

        declTyInfo = semaRes.getTypeInfo(decls01[18])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> String")
            case None => @FailExpect("no type info 18")
        }
        varDecl = (decls01[18] as FuncDecl).getOrThrow().body.getOrThrow().nodes[0] as VarDecl
        varDeclTyInfo = semaRes.getTypeInfo(varDecl.getOrThrow())
        match (varDeclTyInfo) {
            case Some(varDeclTy: SemanticType) => @Expect(varDeclTy.toString(), "Int32")
            case None => @FailExpect("no varDecl type info 18_0")
        }
        varDecl = (decls01[18] as FuncDecl).getOrThrow().body.getOrThrow().nodes[2] as VarDecl
        varDeclTyInfo = semaRes.getTypeInfo(varDecl.getOrThrow())
        match (varDeclTyInfo) {
            case Some(varDeclTy: SemanticType) => @Expect(varDeclTy.toString(), "String")
            case None => @FailExpect("no varDecl type info 18_1")
        }

        declTyInfo = semaRes.getTypeInfo(decls01[19])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "(String) -> Object")
            case None => @FailExpect("no type info 19")
        }

        declTyInfo = semaRes.getTypeInfo(decls01[20])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> Any")
            case None => @FailExpect("no type info 20")
        }
        varDecl = (decls01[20] as FuncDecl).getOrThrow().body.getOrThrow().nodes[0] as VarDecl
        varDeclTyInfo = semaRes.getTypeInfo(varDecl.getOrThrow())
        match (varDeclTyInfo) {
            case Some(varDeclTy: SemanticType) => @Expect(varDeclTy.toString(), "CallbackResource")
            case None => @FailExpect("no varDecl type info 20")
        }

        declTyInfo = semaRes.getTypeInfo(decls01[21])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> Array<UInt8>")
            case None => @FailExpect("no type info 21")
        }
        declTyInfo = semaRes.getTypeInfo(decls01[22])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> Any")
            case None => @FailExpect("no type info 22")
        }

        declTyInfo = semaRes.getTypeInfo(decls01[23])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> Float64")
            case None => @FailExpect("no type info 23")
        }
        varDecl = (decls01[23] as FuncDecl).getOrThrow().body.getOrThrow().nodes[0] as VarDecl
        varDeclTyInfo = semaRes.getTypeInfo(varDecl.getOrThrow())
        match (varDeclTyInfo) {
            case Some(varDeclTy: SemanticType) => @Expect(varDeclTy.toString(), "Int8")
            case None => @FailExpect("no varDecl type info 23")
        }

        declTyInfo = semaRes.getTypeInfo(decls01[24])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> CallbackResource")
            case None => @FailExpect("no type info 24")
        }
    }

    @TestCase
    func testDecl02() {
        let decl = (decls[2] as ClassDecl).getOrThrow()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "pointer")
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
    func testDecl04() {
        let decl = (decls[4] as FuncDecl).getOrThrow()
        var declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "() -> Unit")
            case None => @FailExpect("no type info")
        }
 
        let varDecl = (decl.body.getOrThrow().nodes[0] as VarDecl).getOrThrow()

        declTyInfo = semaRes.getTypeInfo(varDecl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Int64")
            case None => @FailExpect("no type info")
        }
    }
}
