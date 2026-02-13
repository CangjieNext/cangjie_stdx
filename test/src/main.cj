package semantictest

import stdx.syntax.*
import stdx.semantic.*

class SemaTestVisitor <: ASTVisitor {
    SemaTestVisitor(let semaRes: SemanticResult) {}

    func printSema(decl: Decl) {
        if (let Some(tyInfo) <- semaRes.getTypeInfo(decl)) {
            println("${decl} -> ${tyInfo}")
        }
    }

    func printSema(expr: Expr) {
        /*
        if (let Some(tyInfo) <- semaRes.getTypeInfo(expr)) {
            println("${expr} -> ${tyInfo}")
        }
        */
        match (expr) {
            case ref: SymbolRef =>
                if (let Some(decl) <- semaRes.getSymbolRef(ref)) {
                    println("${ref} target -> ${decl}")
                } else {
                    println("${ref} target not found")
                }
            case _ => ()
        }
    }

    public override func preAction(node: SyntaxTreeNode): PreActionMode {
        match (node) {
            case decl: Decl => 
                printSema(decl)
            case expr: Expr =>
                printSema(expr)
            case _ => ()
        }
        return PreActionMode.Continue
    }
}


func semaTest() {
    let parsingRes: ParsingResult<Package> = parsePackage("/home/tiny/work/code/blue2/samples/bench/syntax")
	let pkgAST: Package = parsingRes.node.getOrThrow()

    println("parse success: ${pkgAST.name}")
	
	let semaRes = SemanticResult.analyze(pkgAST, importedPkgContexts: [])

    println("analyze success: ${pkgAST.name}")
    
    // SemaTestVisitor(semaRes).walk(pkgAST)
}

main(): Int64 {
    semaTest()
    return 0
}
