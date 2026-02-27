/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_decl_with_different_visibility
// (not Windows) EXEC: dos2unix package_decl_with_different_visibility/cube.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

/*
该用例主要测试 cjut 自动生成测试用例的场景，当public函数入参类型为自定义类型时，
需要提供相应的语义信息给大模型来生成该类型的输入。
public class {func xxx} 的情况怎么识别成public func?
测试路径  找到public funcDecl （节点可见性要单独考虑下） -> 入参为自定义类型 CompositeType -> getDecl 得到对应Decl -> getSubTys 得到所有子类的Decl
（入参类型为接口或抽象类的情况，或用于提升生成测试用例覆盖率） -> 对于得到的Decl，尝试获取其构造函数。
*/
@Test
class AnalyzeTestDeclWithDifferentVisiblity {
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
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_decl_with_different_visibility")
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
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Cube")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl01() {
        let decl = decls[1]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Array<(Rotation, Int64)>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl02() {
        let decl = decls[2]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Array<Array<(Rotation, Int64)>>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl03() {
        let decl = decls[3]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Index")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl04() {
        let decl = decls[4]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(extendTy: SemanticType) => @Expect(extendTy.toString(), "Array<Array<(Rotation, Int64)>>")
            case None => () // extendDecl's semantic type is None
        }
    }

    @TestCase
    func testDecl05() {
        let decl = decls[5]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Int64")
            case None => () // extendDecl's semantic type is None
        }
    }

    @TestCase
    func testDecl06() {
        let decl = decls[6]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Array<(Rotation, Index)>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl07() {
        let decl = decls[7]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Array<(Rotation, Index)>")
            case None => () // extendDecl's semantic type is None
        }
    }

    @TestCase
    func testDecl08() {
        let decl = decls[8]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Rotation")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl09() {
        let decl = decls[9]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Rotation")
            case None => @FailExpect("no type info")
        }
    }

    @Skip
    @TestCase [
        data in ["Rotation", "Face", "Index", "Vector", "I"]
    ] // Enum类型找不到Decl，全是EnumDecl或TypeAlias，当前找不到
    func testGetDecl01(data: String) {
        let ty = CompositeType(data, [], [])
        @Expect(semaRes.getDecl(ty).isSome())
        if (let Some(decl) <- semaRes.getDecl(ty)) {
            println(decl)
        }
    }

    @Skip
    @TestCase [
        data in [("Rotation", 0), ("Face", 0), ("Index", 0), ("Vector", 0), ("I", 2)]
    ]
    func testGetMembers(data: (ty: String, size: Int64)) {
        let ty = CompositeType(data[0], [], [])
        if (let Some(decl) <- semaRes.getDecl(ty)) {
            let mems = semaRes.getMembers(decl)
            println("members: ${mems.size}")
            @Expect(mems.size, data[1])
            for (mem in mems) {
                // 找到构造函数则收集起来 FuncDecl (name == Init 或 data[0]), StaticInit 或 EnumConstructor 
            }
        }
    }

    @Skip
    @TestCase [
        data in [("Rotation", 0), ("Face", 0), ("Index", 0), ("Vector", 0), ("I", 2)]
    ]
    func testGetSubTys(data: (ty: String, size: Int64)) {
        let ty = CompositeType(data[0], [], [])
        if (let Some(decl) <- semaRes.getDecl(ty)) {
            let subs = semaRes.getSubTys(decl)
            println("subs: ${subs.size}")
            @Expect(subs.size, data[1])
        }
    }
}
