/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/import
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

import stdx.syntax.*
import stdx.semantic.*
import std.unittest.testmacro.*
import std.unittest.*

@Test
class SemanticContextFromSemanticResultTest01 {
    var decls: Array<Decl> = []
    var semaRes: SemanticResult = SemanticResult.analyze(parsePackage("sourceFile/import").node.getOrThrow(),
        importedPkgContexts: [])
    var semaContext: SemanticContext = SemanticContext.createFromSemanticResult(semaRes)

    @TestCase
    func test01() {
        @Expect(semaContext.syntaxTree.toString(), """
// define.cj
package define

public class A {
    let a: Int64

    public init(a: Int64) {
        this.a = a
    }
}""")
    }


    @TestCase
    func test02() {
        let decl = (semaContext.syntaxTree as Package).getOrThrow().srcFile[0].topLevelDecls[0]
        @Expect(decl.toString(), """
public class A {
    let a: Int64

    public init(a: Int64) {
        this.a = a
    }
}""")
        let declTyInfo = semaContext.getTypeInfo(decl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "A")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func test03() {
        let topLevelDecls = (semaContext.syntaxTree as Package).getOrThrow().srcFile[0].topLevelDecls
        let classDecl = (topLevelDecls[0] as ClassDecl).getOrThrow()
        let varDecl = classDecl.body.memberDecls[0]
        @Expect(varDecl.toString(), "let a: Int64")
        let declTyInfo = semaContext.getTypeInfo(varDecl)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Int64")
            case None => @FailExpect("no type info")
        }
    }

    @TestCase
    func test04() {
        let topLevelDecls = (semaContext.syntaxTree as Package).getOrThrow().srcFile[0].topLevelDecls
        let classDecl = (topLevelDecls[0] as ClassDecl).getOrThrow()
        let initFunc = classDecl.body.memberDecls[1]
        @Expect(initFunc.toString(), """
public init(a: Int64) {
        this.a = a
    }"""
)
        let declTyInfo = semaContext.getTypeInfo(initFunc)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "(Int64) -> A")
            case None => @FailExpect("no type info")
        }
    }

    @Skip
    @TestCase
    func test05() {
        let topLevelDecls = (semaContext.syntaxTree as Package).getOrThrow().srcFile[0].topLevelDecls
        let classDecl = (topLevelDecls[0] as ClassDecl).getOrThrow()
        let initFunc = (classDecl.body.memberDecls[1] as FuncDecl).getOrThrow()
        let param = initFunc.params.params[0]
        @Expect(param.toString(), "a: Int64")
        let declTyInfo = semaContext.getTypeInfo(param)
        match (declTyInfo) {
            case Some(ty: SemanticType) => @Expect(ty.toString(), "Int64")
            case None => @FailExpect("no type info")
        }
    }
}