/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_vardecl_01
// (not Windows) EXEC: dos2unix package_vardecl_01/vardecl.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

@Test
class AnalyzeTestVarDecl001 {
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
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_vardecl_01")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
        let file = pkgAST.srcFile[0]

        decls = file.topLevelDecls
    }

    @TestCase
    func testDecl00() {
        let decl = decls[0] // let int_a = 1
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Int64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl01() {
        let decl = decls[1] // var int_b: Int64 = 2
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Int64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl02() {
        let decl = decls[2] // const int_c : Int32 = 3
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Int32")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl03() {
        let decl = decls[3] // var int_d : Int16 = 4
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Int16")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl04() {
        let decl = decls[4] // let int_e : Int8 = 5
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Int8")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl05() {
        let decl = decls[5] // let int_f: ?Int64 = 6
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Option<Int64>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl06() {
        let decl = decls[6] // let int_g: (Int64) = 7
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Int64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl07() {
        let decl = decls[7] // let uint_a : UInt64 = 1
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "UInt64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl08() {
        let decl = decls[8] // var uint_b : UInt32 = 2
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "UInt32")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl09() {
        let decl = decls[9] // const uint_c : UInt16 = 3
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "UInt16")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl10() {
        let decl = decls[10] // let uint_d : UInt8 = 4
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "UInt8")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl11() {
        let decl = decls[11] // const float_a = 1.0
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Float64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl12() {
        let decl = decls[12] // let float_b: Float64 = 2.1
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Float64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl13() {
        let decl = decls[13] // var float_c: Float32 = 3.4
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Float32")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl14() {
        let decl = decls[14] // var float_d: Float16 = 3.4
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Float16")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl15() {
        let decl = decls[15] // var bool_a = true
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Bool")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl16() {
        let decl = decls[16] // let bool_b: Bool = false
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Bool")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl17() {
        let decl = decls[17] // const rune_a = r'a'
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Rune")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl18() {
        let decl = decls[18] // let rune_b: Rune = r'b'
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Rune")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl19() {
        let decl = decls[19] // let string_a = "Hello"
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "String")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl20() {
        let decl = decls[20] // let string_b: String = "World"
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "String")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl21() {
        let decl = decls[21] // var string_c = "Hello"
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "String")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl22() {
        let decl = decls[22] // var string_d: String = "World"
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "String")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl23() {
        let decl = decls[23] // let unit_a = ()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl24() {
        let decl = decls[24] // let unit_b: Unit = ()
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Unit")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl25() {
        let decl = decls[25] // let tuple_a = (1, "a", true)
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(Int64, String, Bool)")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl26() {
        let decl = decls[26] // let tuple_b: (Int64, String, Bool) = (1, "a", true)
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(Int64, String, Bool)")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl27() {
        let decl = decls[27] // var array_a = [1, 2, 3]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Array<Int64>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl28() {
        let decl = decls[28] // var array_b: Array<Int64> = [1, 2, 3]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Array<Int64>")
            case None => @FailExpect("no type info")
        }
    }

    @Skip
    @TestCase
    func testDecl29() {
        let decl = decls[29] // var varray_b: VArray<Int64, $3> = [1, 2, 3]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "VArray<Int64, $3>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl30() {
        let decl = decls[30] // let range_a = 1..10
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Range<Int64>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl31() {
        let decl = decls[31] // let range_b: Range<Int64> = 1..100
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "Range<Int64>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl32() {
        let decl = decls[32] // let lambda_a = { x: Int64 => x + 1 }
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(Int64) -> Int64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl33() {
        let decl = decls[33] // let lambda_b: (Int64) -> Int64 = { x => x * 2 }
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "(Int64) -> Int64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl34() {
        let decl = decls[34] // let lambda_no_arg_a = { => 0 }
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "() -> Int64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl35() {
        let decl = decls[35] // let lambda_no_arg_b: () -> Int64 = { => 1 }
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "() -> Int64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl36() {
        let decl = decls[36] // let annotation_a = AnnotationKind.Init
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(funcTy: SemanticType) => @Expect(funcTy.toString(), "AnnotationKind")
            case None => @FailExpect("no type info")
        }
    }
}
