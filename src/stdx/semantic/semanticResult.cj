package stdx.semantic
import stdx.syntax.*
import std.collection.HashMap
// import std.ast.MACRO_OBJECT

public class SemanticResult {
    public let diags: Array<Diagnostic> = []
    
    public static func analyze(pkgAST: Package, importedPkgContexts!: Array<SemanticContext> = []): SemanticResult {
        let maps = unsafe{ analyzeImpl("") }
        println("analyzeImpl finish")
        let declMaps = getDeclTypeMap(pkgAST, maps)
        println("getDeclTypeMap finish")
        SemanticResult(declMaps)
    }

    public func getTypeInfo(decl: Decl): Option<SemanticType> {
        declTypeInfoMap.get(decl)
    }

    private static func getDeclTypeMap(pkgAST: Package, maps: SemanticType_NodeTypeMap) {
        let declMap = HashMap<SyntaxTreeNode, SemanticType>()

        let tyPtrToSemanticType = HashMap<UInt64, SemanticType>()
        for (semanticTypeMapOption in maps.GetDeclMapList()) {
            if (let Some(semanticTypeMap) <- semanticTypeMapOption) {
                let id = semanticTypeMap.GetId()
                // println("id: ${id}")
                let nf = NodeFinder(pkgAST, id)
                nf.walk(pkgAST)
                let decl = nf.res.getOrThrow()
                let ty = generateSemanticType(semanticTypeMap.GetType())
                println("${id}, ${ty}")
                if (tyPtrToSemanticType.contains(ty.rawPointer)) {
                    declMap.add(decl, tyPtrToSemanticType[ty.rawPointer])
                } else {
                    declMap.add(decl, ty)
                    tyPtrToSemanticType.add(ty.rawPointer, ty)
                }
            }
        }
        declMap
    }

    private let declTypeInfoMap: HashMap<SyntaxTreeNode, SemanticType>
    // private let exprTypeInfoMap: HashMap<SyntaxTreeNode, SemanticType>
    // private let target: HashMap<SyntaxTreeNode, SyntaxTreeNode>

    init(declTypeInfoMap: HashMap<SyntaxTreeNode, SemanticType>){
        this.declTypeInfoMap = declTypeInfoMap
    }
}

public class SemanticContext {
    // cjo 
    // private let declTypeInfoMap: HashMap<SyntaxTreeNode, SemanticType>
}
  
class NodeFinder <: ASTVisitor {
    var res = Option<SyntaxTreeNode>.None
    var targetID: UInt64 = 0
    let pkg: SyntaxTreeNode

    public override func preAction(node: SyntaxTreeNode): PreActionMode {
        if (node.getId() == targetID) {
            res = node
            println("targetID: ${targetID}, node.getId(): ${node.getId()}")
            PreActionMode.Stop
        }
        return PreActionMode.Continue
    }

    init (pkgAST: Package, id: UInt64) {
        this.targetID = id
        this.pkg = pkgAST
    }

    func clear() {
        res = Option<SyntaxTreeNode>.None
        targetID = 0
    }

}

// // need std.ast.MACRO_OBJECT
// public func getSemanticResult(input: SyntaxTreeNode): SemanticResult {
//     let maps = unsafe { getSemanticResultImpl(input.getId()) }

//     let declMap = getDeclTypeMap(maps)
//     SemanticResult(declMap)
// }
