package stdx.semantic
internal import stdx.syntax.*
import std.collection.HashMap
import std.fs.*
import std.io.*


public class SemanticResult {
    public let diags: Array<Diagnostic> = []
    private let impl: AnalyzerImpl
    let pkgAST: SyntaxTreeNode

    public static func analyze(pkgAST: Package, importedPkgContexts!: Array<SemanticContext> = []): SemanticResult {
        let serialStart = timerStart() 
        let buf: Array<UInt8> = serializePkg(pkgAST)
        timerRecord(serialStart, "Stage 1.1: Serial GreenTree")

        let maps = unsafe{ analyzeImpl(buf) }

        let tyMapStart = timerStart()
        let declMap = getDeclTypeMap(pkgAST, maps)
        let exprMap = getExprTypeMap(pkgAST, maps)
        timerRecord(tyMapStart, "Stage 3.2: Deserial Result of TypeMap")

        let refMapStart = timerStart()
        let refMap = getRefMap(pkgAST, maps)
        timerRecord(refMapStart, "Stage 3.3: Deserial Result of RefMap")

        let implStart = timerStart()
        let impl = AnalyzerImpl(pkgAST)
        timerRecord(implStart, "Stage 4: Analye impl in cangjie")
        timerRecord(serialStart, "Total Analye")
        SemanticResult(pkgAST, declMap, exprMap, refMap, impl)
    }

    public static func analyze(pkgAST: Package, cjoPath: String) {
        let maps = unsafe{ analyzeImplWithPath(serializePkg(pkgAST), cjoPath) }
        let declMaps = getDeclTypeMap(pkgAST, maps)
        let refMap = getRefMap(pkgAST, maps)
        let exprMap = getExprTypeMap(pkgAST, maps)
        SemanticResult(pkgAST, declMaps, exprMap, refMap, AnalyzerImpl(pkgAST))
        // TODO: 内部应该存一份对应 cjoPath 的 SemanticContext
    }

    public func getTypeInfo(decl: Decl): Option<SemanticType> {
        declTypeInfoMap.get(decl.getId())
    }

    public func getTypeInfo(expr: Expr): Option<SemanticType> {
        exprTypeInfoMap.get(expr.getId())
    }

    public func getSymbolInfo(symbol: SymbolRef): Option<Decl> {
        let declId = refMap.get(symbol.getId())
        if (let Some(id) <- declId && let Some(pkg) <- (pkgAST as Package)) {
            let nf = NodeFinder(pkg, id)
            nf.walk(pkgAST)
            if (let Some(decl) <- nf.res) {
                return decl as Decl
            }
        }
        None
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

    private static func getExprTypeMap(pkgAST: Package, maps: SemanticType_NodeTypeMap) {
        let exprMap = HashMap<UInt64, SemanticType>()

        let tyPtrToSemanticType = HashMap<UInt64, SemanticType>()
        for (semanticTypeMapOption in maps.GetExprMapList()) {
            if (let Some(semanticTypeMap) <- semanticTypeMapOption) {
                let id = semanticTypeMap.GetId()
                let ty = generateSemanticType(semanticTypeMap.GetType(), pkgAST)
                if (tyPtrToSemanticType.contains(ty.rawPointer)) {
                    exprMap.add(id, tyPtrToSemanticType[ty.rawPointer])
                } else {
                    exprMap.add(id, ty)
                    tyPtrToSemanticType.add(ty.rawPointer, ty)
                }
            }
        }
        exprMap
    }

    private static func getRefMap(pkgAST: Package, maps: SemanticType_NodeTypeMap) {
        let target = HashMap<UInt64, UInt64>()

        for (refMapOption in maps.GetRefMapList()) {
            if (let Some(refMap) <- refMapOption) {
                let refId = refMap.GetId()
                let declId = refMap.GetDecl()
                target.add(refId, declId)
            }
        }
        target
    }

    let declTypeInfoMap: HashMap<UInt64, SemanticType>
    private let exprTypeInfoMap: HashMap<UInt64, SemanticType>
    private let refMap: HashMap<UInt64, UInt64>
    
    init(pkgAST: SyntaxTreeNode, declTypeInfoMap: HashMap<UInt64, SemanticType>, exprTypeInfoMap: HashMap<UInt64, SemanticType>, refMap: HashMap<UInt64, UInt64>, impl: AnalyzerImpl){
        this.declTypeInfoMap = declTypeInfoMap
        this.exprTypeInfoMap = exprTypeInfoMap
        this.refMap = refMap
        this.impl = impl
        this.pkgAST = pkgAST
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
