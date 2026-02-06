/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
// DEPENDENCE: sourceFile/package/package_symbol_01 sourceFile/import
// (not Windows) EXEC: dos2unix package_symbol_01/decls.cj
// EXEC: %compiler %import-cangjie-stdx %cmp_opt -o %n.%suffix %f %cmp_utest_opt
// RUN-EXEC: %set_stdx_path %run %run_opt %n.%suffix %run_utest_opt %run_args
package semantictest

import std.unittest.testmacro.*
import stdx.syntax.*
import stdx.semantic.*

class DeclFinder <: ASTVisitor {
    var res = Option<Decl>.None
    var dstName: String
    let pkg: SyntaxTreeNode

    public override func preAction(node: SyntaxTreeNode): PreActionMode {
        match (node) {
            case decl: ClassDecl => if (decl.name == dstName) {
                res = decl
                return PreActionMode.Stop
            }
            case decl: EnumDecl => if (decl.name == dstName) {
                res = decl
                return PreActionMode.Stop
            }
            case decl: StructDecl => if (decl.name == dstName) {
                res = decl
                return PreActionMode.Stop
            }
            case decl: InterfaceDecl => if (decl.name == dstName) {
                res = decl
                return PreActionMode.Stop
            }
            case decl: VarDecl => if (decl.name == dstName) {
                res = decl
                return PreActionMode.Stop
            }
            case _ => return PreActionMode.Continue
        }
        return PreActionMode.Continue
    }

    init (pkgAST: Package, dstName: String) {
        this.dstName = dstName
        this.pkg = pkgAST
    }

    func clear() {
        res = Option<Decl>.None
        dstName = ""
    }
}

@Test
class GetDeclTest {
    var pkgAST: Package = Package(false, "default", 
        [SourceFile([], "default", "/path/to/sourceFile.cj", None, 
            MainDecl(
                Block([ReturnExpr(None)]), 
                ParameterList([]), 
                AtomicType(UnitType))
        )])
    var semaRes: SemanticResult = SemanticResult.analyze(pkgAST, "")

    @BeforeAll
    func readDecls(): Unit {
        let parsingRes: ParsingResult<Package> = parsePackage("./sourceFile/package/package_getDecl_01")
        pkgAST = parsingRes.node.getOrThrow()
        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
    }

    @TestCase
    func testGetType01() {
        var myVisitor = DeclFinder(pkgAST, "A")
        myVisitor.walk(pkgAST)
        let declIn = myVisitor.res.getOrThrow()
        let declTy = semaRes.getTypeInfo(declIn).getOrThrow()
        let realTy = (declTy as ClassSType).getOrThrow()
        match (realTy.getDecl()) {
            case Some(declOut: ClassDecl) => @Expect(declIn == declOut, true)
            case None => @FailExpect("can not find decl of type")
        }
        /* myVisitor = DeclFinder(pkgAST, "aA")
        myVisitor.walk(pkgAST)
        let varDecl = myVisitor.res.getOrThrow()
        let varTy = semaRes.getTypeInfo(varDecl).getOrThrow()
        let varRealDecl = (varTy as ClassSType).getOrThrow()
        match (varRealDecl.getDecl()) {
            case Some(realDecl: ClassDecl) => @Expect(declIn == realDecl, true)
            case None => @FailExpect("can not find decl of type")
        } */
    }

    @TestCase
    func testGetType02() {
        let myVisitor = DeclFinder(pkgAST, "B")
        myVisitor.walk(pkgAST)
        let declIn = myVisitor.res.getOrThrow()
        let declTy = semaRes.getTypeInfo(declIn).getOrThrow()
        let realTy = (declTy as StructSType).getOrThrow()
        match (realTy.getDecl()) {
            case Some(declOut: StructDecl) => @Expect(declIn == declOut, true)
            case None => @FailExpect("can not find decl of type")
        }

    }

    @TestCase
    func testGetType03() {
        let myVisitor = DeclFinder(pkgAST, "C")
        myVisitor.walk(pkgAST)
        let declIn = myVisitor.res.getOrThrow()
        let declTy = semaRes.getTypeInfo(declIn).getOrThrow()
        let realTy = (declTy as EnumSType).getOrThrow()
        match (realTy.getDecl()) {
            case Some(declOut: EnumDecl) => @Expect(declIn == declOut, true)
            case None => @FailExpect("can not find decl of type")
        }
    }

    @TestCase
    func testGetType04() {
        let myVisitor = DeclFinder(pkgAST, "D")
        myVisitor.walk(pkgAST)
        let declIn = myVisitor.res.getOrThrow()
        let declTy = semaRes.getTypeInfo(declIn).getOrThrow()
        let realTy = (declTy as InterfaceSType).getOrThrow()
        match (realTy.getDecl()) {
            case Some(declOut: InterfaceDecl) => @Expect(declIn == declOut, true)
            case None => @FailExpect("can not find decl of type")
        }
    }
}
