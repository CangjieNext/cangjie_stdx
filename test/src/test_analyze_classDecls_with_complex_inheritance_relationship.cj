/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_classDecls_with_inheritance
// (not Windows) EXEC: dos2unix package_classDecls_with_inheritance/tokenizer
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

internal import std.unittest.*
import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

@Test
class AnalyzeTestDeclWithComplexInheritanceRelationship {
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
        let parsingRes: ParsingResult<Package> = parsePackage("sourceFile/package/package_classDecls_with_inheritance")
        let pkgAST: Package = parsingRes.node.getOrThrow()

        semaRes = SemanticResult.analyze(pkgAST, "sourceFile/import")
        let file = pkgAST.srcFile[0]

        decls = file.topLevelDecls
    }

    @TestCase
    func testDecl00() {
        let decl = decls[0]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "TokenizerType")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl01() {
        let decl = decls[1]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Tokenizer")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl02() {
        let decl = decls[2]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "Tiktoken")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl03() {
        let decl = decls[3]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "HashPairString")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func testDecl04() {
        let decl = decls[4]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(extendTy: SemanticType) => @Expect(extendTy.toString(), "HashPairUInt32")
            case None => () // extendDecl's semantic type is None
        }
    }

    @TestCase
    func testDecl05() {
        let decl = decls[5]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "HashMap<HashPairString, UInt32>")
            case None => () // extendDecl's semantic type is None
        }
    }

    @TestCase
    func testDecl06() {
        let decl = decls[6]
        let declTyInfo: Option<SemanticType> = semaRes.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(declTy: SemanticType) => @Expect(declTy.toString(), "HashMap<HashPairUInt32, (UInt32, UInt32)>")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase [
        data in ["Tokenizer", "Tiktoken", "HashPairString", "HashPairUInt32"]
    ] // "TokenizerType" Enum类型找不到Decl
    func testGetDecl01(data: String) {
        let ty = CompositeType(data, [], [])
        @Expect(semaRes.getDecl(ty).isSome())
        if (let Some(decl) <- semaRes.getDecl(ty)) {
            println(decl)
        }
    }

    @TestCase [
        data in [("Tokenizer", 11), ("Tiktoken", 5), ("HashPairString", 6), ("HashPairUInt32", 7)]
    ]
    func testGetMembers(data: (ty: String, size: Int64)) {
        let ty = CompositeType(data[0], [], [])
        if (let Some(decl) <- semaRes.getDecl(ty)) {
            let mems = semaRes.getMembers(decl)
            println("members: ${mems.size}")
            @Expect(mems.size, data[1])
        }
    }

    @TestCase [
        data in [("Tokenizer", 0), ("Tiktoken", 1), ("HashPairString", 0), ("HashPairUInt32", 0)] //("HashPairString", 2), ("HashPairUInt32", 3)]
    ] // 当前只能统计本包内的继承关系，无法统计到外包的继承关系，待解决
    func testGetSuperTys(data: (ty: String, size: Int64)) {
        let ty = CompositeType(data[0], [], [])
        if (let Some(decl) <- semaRes.getDecl(ty)) {
            let supers = semaRes.getSuperTys(decl)
            println("supers: ${supers.size}")
            @Expect(supers.size, data[1])
        }
    }

    @TestCase [
        data in [("Tokenizer", 1), ("Tiktoken", 0), ("HashPairString", 0), ("HashPairUInt32", 0)]
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
