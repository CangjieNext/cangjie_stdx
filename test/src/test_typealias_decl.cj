/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_typealias_decl
// (not Windows) EXEC: dos2unix package_typealias_decl/decls.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*


@Test
class TypealiasAnalyzeTest {
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
        let parsingRes: ParsingResult<Package> = parsePackage("../sourceFile/package/package_typealias_decl")
        
        let pkgAST: Package = parsingRes.node.getOrThrow()

        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let file = pkgAST.srcFile[0]

        decls = file.topLevelDecls
    }

    @TestCase
    func testtypeA_Type() {
        let decl = decls[0]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Int64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testtypeB_Type() {
        let decl = decls[1]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Float64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testtypeC_Type() {
        let decl = decls[2]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Bool")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testtypeD_Type() {
        let decl = decls[3]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "String")
            case None => @FailExpect("no type info")
        }
    }
   
    @TestCase
    func testvarA_Type() {
        let decl = decls[4]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Int64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testvarB_Type() {
        let decl = decls[5]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Float64")
            case None => @FailExpect("no type info")
        }
    }

     @TestCase
    func testvarC_Type() {
        let decl = decls[6]
        var declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Bool")
            case None => @FailExpect("no type info")
        }
        
    }

    @TestCase
    func testvarD_Type() {
        let decl = decls[7]

        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "String")
            case None => @FailExpect("no type info")
        }
       
    }

    @TestCase
    func testclassL_Type() {
        let decl = decls[8]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "LongClass")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testtypeLC_Type() {
        let decl = decls[9]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "LongClass")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testvarlc_Type() {
        let decl = decls[10]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "LongClass")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testenumU_Type() {
        let decl = decls[11]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "UnitEnum")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testtypeUE_Type() {
        let decl = decls[12]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "UnitEnum")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testvare1_Type() {
        let decl = decls[13]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "UnitEnum")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testvare2_Type() {
        let decl = decls[14]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "UnitEnum")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func teststructB_Type() {
        let decl = decls[15]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Box<T>")
            case None => @FailExpect("no type info")
        }
    }
   
    @TestCase
    func testtypeBX_Type() {
        let decl = decls[16]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Box<T>")
            case None => @FailExpect("no type info")
        }
    }



    
}