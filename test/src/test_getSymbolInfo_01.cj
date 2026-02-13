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

class SymbolRefFinder <: ASTVisitor {
    var res = Option<SymbolRef>.None
    var refName: String
    let pkg: SyntaxTreeNode

    public override func preAction(node: SyntaxTreeNode): PreActionMode {
        match (node) {
            case ref: SymbolRef => if (ref.name == refName) {
                res = ref
                return PreActionMode.Stop
            }
            case _ => return PreActionMode.Continue
        }
        return PreActionMode.Continue
    }

    init (pkgAST: Package, refName: String) {
        this.refName = refName
        this.pkg = pkgAST
    }

    func clear() {
        res = Option<SymbolRef>.None
        refName = ""
    }

}

@Test
class SymbolRefTest {
    var pkgAST: Package = Package(false, "default", 
        [SourceFile([], "default", "/path/to/sourceFile.cj", None, 
            MainDecl(
                Block([ReturnExpr(None)]), 
                ParameterList([]), 
                AtomicType(UnitType))
        )])
    var semaRes: SemanticResult = SemanticResult.analyze(pkgAST, "./sourceFile/package/import")

    @BeforeAll
    func readDecls(): Unit {
        let parsingRes: ParsingResult<Package> = parsePackage("./sourceFile/package/package_symbol_01")
        pkgAST = parsingRes.node.getOrThrow()
        semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])
    }

    @Skip
    @TestCase
    func testSymbol01() {
        let myVisitor = SymbolRefFinder(pkgAST, "a")
        myVisitor.walk(pkgAST)
        let ref = myVisitor.res.getOrThrow()
        let decl: Option<SyntaxTreeNode> = semaRes.getSymbolRef(ref)
        match (decl) {
            case Some(decl: SyntaxTreeNode) => @Expect(decl.toString(), "let a = 1")
            case None => @FailExpect("no decl")
        }
    }

    @Skip
    @TestCase
    func testSymbol02() {
        let myVisitor = SymbolRefFinder(pkgAST, "c")
        myVisitor.walk(pkgAST)
        let ref = myVisitor.res.getOrThrow()
        let decl: Option<SyntaxTreeNode> = semaRes.getSymbolRef(ref)
        match (decl) {
            case Some(decl: SyntaxTreeNode) => @Expect(decl.toString(), "let c = [1, 2, 3, 4]")
            case None => @FailExpect("no decl")
        }
    }

    @Skip
    @TestCase
    func testSymbol03() {
        let myVisitor = SymbolRefFinder(pkgAST, "rec")
        myVisitor.walk(pkgAST)
        let ref = myVisitor.res.getOrThrow()
        let decl: Option<SyntaxTreeNode> = semaRes.getSymbolRef(ref)
        match (decl) {
            case Some(decl: SyntaxTreeNode) => @Expect(decl.toString(), "let rec = Rectangle(20)")
            case None => @FailExpect("no decl")
        }
    }
}
