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

/*
src code form https://gitcode.com/openharmony/arkui_ace_engine/blob/master/frameworks/bridge/arkts_frontend/
koala_projects/interop/src/cangjie repository. This use case is used to maintain real scenarios where 
interactions exist between multiple classes.
*/
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
        declTyInfo = semaRes.getTypeInfo(decls01[10])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "(Int32) -> Unit")
            case None => @FailExpect("no type info 10")
        }

        // private func readInt8(): Int8
        declTyInfo = semaRes.getTypeInfo(decls01[11])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> Int8")
            case None => @FailExpect("no type info 11")
        }
        var varDecl = (decls01[11] as FuncDecl).getOrThrow().body.getOrThrow().nodes[1] as VarDecl
        var varDeclTyInfo = semaRes.getTypeInfo(varDecl.getOrThrow())
        match (varDeclTyInfo) {
            case Some(varDeclTy11: SemanticType) => @Expect(varDeclTy11.toString(), "Int32")
            case None => @FailExpect("no varDecl type info 11")
        }

        // public func readInt32(): Int32
        declTyInfo = semaRes.getTypeInfo(decls01[12])
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "() -> Int32")
            case None => @FailExpect("no type info 12")
        }
        varDecl = (decls01[12] as FuncDecl).getOrThrow().body.getOrThrow().nodes[1] as VarDecl
        varDeclTyInfo = semaRes.getTypeInfo(varDecl.getOrThrow())
        match (varDeclTyInfo) {
            case Some(varDeclTy12: SemanticType) => @Expect(varDeclTy12.toString(), "Array<UInt8>")
            case None => @FailExpect("no varDecl type info 12")
        }

        // public func readString(): String
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
            case Some(varDeclTy18: SemanticType) => @Expect(varDeclTy18.toString(), "String")
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
            case Some(varDeclTy20: SemanticType) => @Expect(varDeclTy20.toString(), "CallbackResource")
            case None => @FailExpect("no varDecl type info 20")
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
            case Some(classTy: SemanticType) => @Expect(classTy.toString(), "pointer")
            case None => @FailExpect("no type info")
        }
 
        let nodes = decl.body.memberDecls
        for (i in 0..nodes.size){
            let menberdecl = nodes[i]
            let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(menberdecl)
            match((i, declTyInfo)) {
                case (0, Some(declTy: SemanticType)) =>  @Expect(Some(declTy.toString()), "Int64")
                case (1, Some(declTy: SemanticType)) =>  @Expect(Some(declTy.toString()), "String")
                case (2, Some(declTy: SemanticType)) =>  @Expect(Some(declTy.toString()), "() -> pointer")
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

    @TestCase
    func testDecl05() {
        let decl = decls[5]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Array<Int64>")
            case None => @FailExpect("no type info")
        }
    }

    @Skip
    @TestCase
    func testDecl06() {
        let decl = decls[6]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Int32")
            case None => @FailExpect("no type info")
        }
    }
}
