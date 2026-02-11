package stdx.semantic
internal import stdx.syntax.*
import std.collection.HashMap
import std.fs.*
import std.io.*
import std.time.*
// import std.ast.MACRO_OBJECT

public class SemanticResult {
    public let diags: Array<Diagnostic> = []
    private let impl: AnalyzerImpl
    
    public static func analyze(pkgAST: Package, importedPkgContexts!: Array<SemanticContext> = []): SemanticResult {
        let analyzeStart = MonoTime.now()
        let serialStart = MonoTime.now()
        let buf: Array<UInt8> = serializePkg(pkgAST)
        let serialEnd = MonoTime.now()
        var result = serialEnd - serialStart
        println("Stage 2. Serialize GreenTree time: ${result.toNanoseconds()}ns")

        let maps = unsafe{ analyzeImpl(buf) }
        
        let declMapStart = MonoTime.now()
        let declMap = getDeclTypeMap(pkgAST, maps)
        let declMapEnd = MonoTime.now()
        result = declMapEnd - declMapStart
        println("Stage 5. Build DeclTypeMap time: ${result.toNanoseconds()}ns")

        let refMapStart = MonoTime.now()
        let refMap = getRefMap(pkgAST, maps)
        let refMapEnd = MonoTime.now()
        result = refMapEnd - refMapStart
        println("Stage 5. Build RefMap time: ${result.toNanoseconds()}ns")
        
        let analyzeEnd = MonoTime.now()
        result = analyzeEnd - analyzeStart
        println("Total Analyze time: ${result.toNanoseconds()}ns")
        
        SemanticResult(declMap, refMap, AnalyzerImpl(pkgAST))
    }

    public static func analyze(pkgAST: Package, cjoPath: String) {
        let maps = unsafe{ analyzeImplWithPath(serializePkg(pkgAST), cjoPath) }
        let declMaps = getDeclTypeMap(pkgAST, maps)
        let refMap = getRefMap(pkgAST, maps)
        SemanticResult(declMaps, refMap, AnalyzerImpl(pkgAST))
        // TODO: 内部应该存一份对应 cjoPath 的 SemanticContext
    }

    public func getTypeInfo(decl: Decl): Option<SemanticType> {
        declTypeInfoMap.get(decl.getId())
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
        let declMap = HashMap<UInt64, SemanticType>()

        let tyPtrToSemanticType = HashMap<UInt64, SemanticType>()
        for (semanticTypeMapOption in maps.GetDeclMapList()) {
            if (let Some(semanticTypeMap) <- semanticTypeMapOption) {
                let id = semanticTypeMap.GetId()
                let ty = generateSemanticType(semanticTypeMap.GetType(), pkgAST)
                if (tyPtrToSemanticType.contains(ty.rawPointer)) {
                    declMap.add(id, tyPtrToSemanticType[ty.rawPointer])
                } else {
                    declMap.add(id, ty)
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
                // println("ref - decl: ${refId}, ${declId}")
                let nf = NodeFinder(pkgAST, declId)
                nf.walk(pkgAST)
                if (let Some(decl) <- nf.res) {
                    target.add(refId, decl)
                }
            }
        }
        target
    }

    private let declTypeInfoMap: HashMap<UInt64, SemanticType>
    // private let exprTypeInfoMap: HashMap<SyntaxTreeNode, SemanticType>
    private let target: HashMap<UInt64, SyntaxTreeNode>
    // private let target: HashMap<SyntaxTreeNode, SyntaxTreeNode>
    
    init(declTypeInfoMap: HashMap<UInt64, SemanticType>, target: HashMap<UInt64, SyntaxTreeNode>, impl: AnalyzerImpl){
        this.declTypeInfoMap = declTypeInfoMap
        this.target = target
        this.impl = impl
    }
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

class TopDeclFinder <: ASTVisitor {
    var res = Option<SyntaxTreeNode>.None
    var targetID: UInt64 = 0
    let pkg: SyntaxTreeNode

    public override func preAction(node: SyntaxTreeNode): PreActionMode {
        if (node.getId() == targetID) {
            res = node
            return PreActionMode.Stop
        }
        match (node) {
            case _: Package => return PreActionMode.Continue
            case _: SourceFile => return PreActionMode.Continue
            case _ => return PreActionMode.Skip
        }
        return PreActionMode.Skip
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
