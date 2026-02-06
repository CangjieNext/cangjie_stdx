package stdx.semantic
import stdx.syntax.*
import std.collection.HashMap
// import std.ast.MACRO_OBJECT

public class SemanticResult {
    public let diags: Array<Diagnostic> = []
    private let impl: AnalyzerImpl
    
    public static func analyze(pkgAST: Package, importedPkgContexts!: Array<SemanticContext> = []): SemanticResult {
        let maps = unsafe{ analyzeImpl(serializePkg(pkgAST)) }
        let declMap = getDeclTypeMap(pkgAST, maps)
        let refMap = getRefMap(pkgAST, maps)
        let declMaps = getDeclTypeMap(pkgAST, maps)
        SemanticResult(declMaps, refMap, AnalyzerImpl(pkgAST))
    }

    public static func analyze(pkgAST: Package, cjoPath: String) {
        let maps = unsafe{ analyzeImplWithPath(serializePkg(pkgAST), cjoPath) }
        let declMaps = getDeclTypeMap(pkgAST, maps)
        let refMap = getRefMap(pkgAST, maps)
        SemanticResult(declMaps, refMap, AnalyzerImpl(pkgAST))
        // TODO: 内部应该存一份对应 cjoPath 的 SemanticContext
    }

    public func getTypeInfo(decl: Decl): Option<SemanticType> {
        declTypeInfoMap.get(decl)
    }

    public func getSymbolRef(symbol: SymbolRef): Option<SyntaxTreeNode> {
        target.get(symbol.getId())
    }

    // get decl by TypeAnnotation
    public func getDecl(ty: TypeAnnotation): Option<Decl> {
        impl.get(ty)
    }

    // get members of decl, including extend members
    public func getMembers(decl: Decl): Array<Decl> {
        impl.getMembers(decl)
    }

    // get super tys of decl, including extend implementation
    public func getSuperTys(decl: Decl): Array<Decl> {
        impl.getSuperTys(decl)
    }

    // get sub tys of decl, including extend implementation
    public func getSubTys(decl: Decl): Array<Decl> {
        impl.getSubTys(decl)
    }

    private static func getDeclTypeMap(pkgAST: Package, maps: SemanticType_NodeTypeMap) {
        let declMap = HashMap<SyntaxTreeNode, SemanticType>()

        let tyPtrToSemanticType = HashMap<UInt64, SemanticType>()
        for (semanticTypeMapOption in maps.GetDeclMapList()) {
            if (let Some(semanticTypeMap) <- semanticTypeMapOption) {
                let id = semanticTypeMap.GetId()
                let nf = NodeFinder(pkgAST, id)
                nf.walk(pkgAST)
                let decl = nf.res.getOrThrow()
                let ty = generateSemanticType(semanticTypeMap.GetType())
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

    private static func getRefMap(pkgAST: Package, maps: SemanticType_NodeTypeMap) {
        let target = HashMap<UInt64, SyntaxTreeNode>()

        let refIdToDeclId = HashMap<UInt64, UInt64>()
        for (refMapOption in maps.GetRefMapList()) {
            if (let Some(refMap) <- refMapOption) {
                let refId = refMap.GetId()
                let declId = refMap.GetDecl()
                println("ref - decl: ${refId}, ${declId}")
                let nf = NodeFinder(pkgAST, declId)
                nf.walk(pkgAST)
                if (let Some(decl) <- nf.res) {
                    target.add(refId, decl)
                }
            }
        }
        target
    }

    private let declTypeInfoMap: HashMap<SyntaxTreeNode, SemanticType>
    // private let exprTypeInfoMap: HashMap<SyntaxTreeNode, SemanticType>
    private let target: HashMap<UInt64, SyntaxTreeNode>
    // private let target: HashMap<SyntaxTreeNode, SyntaxTreeNode>
    
    init(declTypeInfoMap: HashMap<SyntaxTreeNode, SemanticType>, target: HashMap<UInt64, SyntaxTreeNode>, impl: AnalyzerImpl){
        this.declTypeInfoMap = declTypeInfoMap
        this.target = target
        this.impl = impl
    }
}

public class SemanticContext {
    // cjo 
    // private let declTypeInfoMap: HashMap<Decl, SemanticType>
    // public static func createFromCJOFile(cjoFilePath: String): SemanticContext {
    //     let maps = unsafe{ createFromCJOImpl(cjoFilePath) }
    //     // let declMaps = getDeclTypeMap(pkgAST, maps)
    //     SemanticContext(maps)
    // }
}
  
class NodeFinder <: ASTVisitor {
    var res = Option<SyntaxTreeNode>.None
    var targetID: UInt64 = 0
    let pkg: SyntaxTreeNode

    public override func preAction(node: SyntaxTreeNode): PreActionMode {
        if (node.getId() == targetID) {
            res = node
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
