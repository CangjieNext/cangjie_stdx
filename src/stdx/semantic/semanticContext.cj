package stdx.semantic

import std.collection.{ArrayList, HashMap}
import std.fs.{File, Path, OpenMode}
import std.io.{readToEnd}


public class SemanticContext {
    // cjo 
    public let pkgAST: Package
    private let declTypeInfoMap: HashMap<UInt64, SemanticType>
    public static func createFromCJOFile(cjoFilePath: String): SemanticContext {
        let cjoPath: Path = Path(cjoFilePath)
        let file: File = File(cjoPath, OpenMode.Read)
        let allBytes: Array<Byte> = readToEnd(file)
        let creator = SemanticContextCreator()
        creator.createPackageFromCJO(allBytes)
    }

    public static func createFromSemanticResult(semaRes: SemanticResult): SemanticContext {
        SemanticContext(semaRes.pkgAST, semaRes.declTypeInfoMap)
    }

    public func getTypeInfo(decl: Decl): Option<SemanticType> {
        declTypeInfoMap.get(decl.getId())
    }

    prop declMap: HashMap<UInt64, SemanticType> {
        get() {
            declTypeInfoMap
        }
    }

    init(syntaxTree: Package, declTypeInfoMap: HashMap<UInt64, SemanticType>) {
        this.declTypeInfoMap = declTypeInfoMap
        this.pkgAST = syntaxTree
    }
}

class SemanticContextCreator {
    SemanticContextCreator() {}
    private let declTypeInfoMap = HashMap<UInt64, SemanticType>()

    func createPackageFromCJO(bytes: Array<Byte>): SemanticContext {
        let cjoPackage = PackageFormat_Package(bytes, 0)
        
        let pkgName = cjoPackage.GetFullPkgName()
        let isMacroPkg = EnumPackageFormat_PackageKindValues(cjoPackage.GetKind()) == 1
        let topLevelDecls = createTopLevelDecls(cjoPackage)
        let file = SourceFile(Array<ImportList>(), pkgName + ".cj", pkgName + ".cj", 
        PackageHeader(Option<Modifier>.None, isMacroPkg, [pkgName]), topLevelDecls)
        let pkg = Package(isMacroPkg, cjoPackage.GetFullPkgName(), [file])
        SemanticContext(pkg, declTypeInfoMap)
    }

    private func createTopLevelDecls(cjoPackage: PackageFormat_Package): Array<Decl> {
        let decls = cjoPackage.GetAllDecls()
        let topLevelDecls = ArrayList<Decl>()
        for (decl in decls) {
            if (let Some(d) <- decl) {
                if (d.GetIsTopLevel()) {
                    topLevelDecls.add(createDecl(cjoPackage, d))
                }
            }
        }
        topLevelDecls.toArray()
    }
    
    private func createDecl(cjoPackage: PackageFormat_Package, declIndex: UInt32): Decl {
        // NOTE: valid index start from 1!
        let index = Int64(declIndex) - 1
        if (index < 0 || index >= cjoPackage.GetAllDecls().size) {
            throw Exception("The length of the all decls is ${cjoPackage.GetAllDecls().size}, but the index is ${index}.")
        }
        let declInfo = cjoPackage.GetAllDecls()[index]
        return if (let Some(decl) <- declInfo) { 
            createDecl(cjoPackage, decl)
        } else {
            throw Exception("Failed to createDecl")
        }
    }

    private func createDecl(cjoPackage: PackageFormat_Package, decl: PackageFormat_Decl): Decl {
        return match (decl.GetKind()) {
            case PackageFormat_DeclKind.DeclKind_CLASSDECL => createClassDecl(cjoPackage, decl)
            case PackageFormat_DeclKind.DeclKind_FUNCDECL => createFuncDecl(cjoPackage, decl)
            case PackageFormat_DeclKind.DeclKind_VARDECL => createVarDecl(cjoPackage, decl)
            case PackageFormat_DeclKind.DeclKind_FUNCPARAM => createFuncParam(cjoPackage, decl)
            case _ => throw Exception("Not implement this PackageFormat_DeclKind ${EnumPackageFormat_DeclKindValues(decl.GetKind())}")
        }
    }

    private func createClassDecl(cjoPackage: PackageFormat_Package, decl: PackageFormat_Decl): ClassDecl {
        let classInfo = decl.GetInfoAsClassInfo().getOrThrow()
        let memberDeclsIndex = classInfo.GetBody()
        let memberDecls = ArrayList<Decl>()
        for (i in memberDeclsIndex) {
            memberDecls.add(createDecl(cjoPackage, i))
        }
        let body = Body(memberDecls.toArray())
        let genericConstraints = Option<GenericConstraints>.None // TODO: decl.GetGeneric()
        let genericParams = Array<GenericParam>()
        let name = decl.GetIdentifier()
        let superTyAnnotations = Array<TypeAnnotation>() // TODO: classInfo.GetInheritedTypes
        

        let classDecl = ClassDecl(body, genericConstraints, genericParams, name, superTyAnnotations,
        annotations : [], modifiers : [], comments : [])
        declTypeInfoMap.add(classDecl.getId(), createSemanticType(cjoPackage, decl.GetType()))
        return classDecl
    }

    private func createFuncDecl(cjoPackage: PackageFormat_Package, decl: PackageFormat_Decl): FuncDecl {
        let funcInfo = decl.GetInfoAsFuncInfo().getOrThrow()

        let genericConstraints = Option<GenericConstraints>.None // TODO: decl.GetGeneric()
        let genericParams = Array<GenericParam>()
        let name = decl.GetIdentifier()
        let funcBody = funcInfo.GetFuncBody().getOrThrow()
        funcBody.GetBody()
        let body = Option<Block>.None // TODO: get func body
        
        let params = createFuncParamList(cjoPackage, funcBody.GetParamLists()[0])
        var retTyAnnotation:Option<TypeAnnotation> = None// TODO: fix bug Some(createTyAnnotation(cjoPackage, funcBody.GetRetType()))
        // TODO: func kind
        let kind = if (EnumPackageFormat_OperatorKindValues(funcInfo.GetOp()) != 0) {
            FuncKind.Operator
        } else if (name == "init") {
            retTyAnnotation = Option<TypeAnnotation>.None
            FuncKind.Constructor
        } else {
            FuncKind.Normal
        }
        let funcDecl = FuncDecl(body, genericConstraints, genericParams, kind, name, params, retTyAnnotation,
        annotations : [], modifiers : [], comments : [])
        declTypeInfoMap.add(funcDecl.getId(), createSemanticType(cjoPackage, decl.GetType()))
        return funcDecl
    }

    private func createFuncParamList(cjoPackage: PackageFormat_Package, funcParamList: Option<PackageFormat_FuncParamList>): ParameterList {
        let parameters = ArrayList<Parameter>()
        if (let Some(fpList) <- funcParamList) {
            for (i in fpList.GetParams()) {
                let param = (createDecl(cjoPackage, i) as Parameter)
                if (let Some(p) <- param) {
                    parameters.add(p)
                } else {
                    throw Exception("Failed to createFuncParamList")
                }
            }
        } else {
            throw Exception("Failed to createFuncParamList")
        }
        ParameterList(parameters.toArray())
    }

    private func createVarDecl(cjoPackage: PackageFormat_Package, decl: PackageFormat_Decl): VarDecl {
        let varInfo  = decl.GetInfoAsVarInfo().getOrThrow()
        let initializer = Option<Expr>.None // TODO: varInfo.GetInitializer()
        let kind = if (varInfo.GetIsVar()) {
            VarKind.Var
        } else if (varInfo.GetIsConst()) {
            VarKind.Const
        } else {
            VarKind.Let
        }
        let name = decl.GetIdentifier()
        let pattern = VarPattern(name)

        let tyAnnotation = createTyAnnotation(cjoPackage, decl.GetType())
        let varDecl = VarDecl(initializer, kind, name, pattern, tyAnnotation,
        annotations : [], modifiers : [], comments : [])
        declTypeInfoMap.add(varDecl.getId(), createSemanticType(cjoPackage, decl.GetType()))
        return varDecl
    }

    private func createTyAnnotation(cjoPackage: PackageFormat_Package, tyIndex: UInt32): TypeAnnotation {
        // NOTE: valid index start from 1!
        let index = Int64(tyIndex) - 1
        if (index < 0 || index >= cjoPackage.GetAllTypes().size) {
            throw Exception("The length of the all types is ${cjoPackage.GetAllTypes().size}, but the index is ${index}.")
        }
        let typeInfo = cjoPackage.GetAllTypes()[index]
        return if (let Some(ty) <- typeInfo) {
            match (ty.GetKind()) {
                case PackageFormat_TypeKind.TypeKind_UNIT => AtomicType(AtomicTypeKind.UnitType)
                case PackageFormat_TypeKind.TypeKind_INT64 => AtomicType(AtomicTypeKind.Int64Type)
                // case PackageFormat_TypeKind.TypeKind_CLASS => CompositeType("", [], [])
                case _ => throw Exception("Not implement this PackageFormat_TypeKind ${EnumPackageFormat_TypeKindValues(ty.GetKind())}")
            }
        } else {
            throw Exception("Failed to create TyAnnotation")
        }
    }

    private func createFuncParam(cjoPackage: PackageFormat_Package, decl: PackageFormat_Decl): FuncParam {
        let paramInfo  = decl.GetInfoAsParamInfo().getOrThrow()
        let defaultValue = Option<Expr>.None // TODO: create Expr for FuncParam
        let kind =  Option<VarKind>.None // TODO: var kind

        let typeAnnotation = createTyAnnotation(cjoPackage, decl.GetType())
        
        let param = FuncParam(defaultValue, kind, decl.GetIdentifier(), typeAnnotation,
        isNamed: paramInfo.GetIsNamedParam(), annotations: [], modifiers: [], comments: [])
        declTypeInfoMap.add(param.getId(), createSemanticType(cjoPackage, decl.GetType()))
        return param
    }

    // private func createExpr(cjoPackage: PackageFormat_Package, exprIndex: UInt32): Expr {
    //     // NOTE: valid index start from 1!
    //     let index = Int64(exprIndex) - 1
    //     if (index < 0 || index >= cjoPackage.GetAllExprs().size) {
    //         throw Exception("createDecl.GetAllExprs.size: ${index}, ${cjoPackage.GetAllExprs().size}")
    //     }
    //     let exprInfo = cjoPackage.GetAllExprs()[index]
    //     return if (let Some(expr) <- exprInfo) { 
    //         match (expr.GetKind()) {
    //             case PackageFormat_ExprKind.ExprKind_BLOCK => // block is not Expr in Syntax
    //             case _ => throw Exception("Not implement this PackageFormat_ExprKind ${EnumPackageFormat_ExprKindValues(expr.GetKind())}")
    //     }
    //     } else {
    //         throw Exception("Failed to createDecl")
    //     }
    // }
    
    // TODO  
    // private func createBlock(cjoPackage: PackageFormat_Package, expr: PackageFormat_Expr): Block {
    //     Block([])
    // }

    private func createSemanticType(cjoPackage: PackageFormat_Package, tyIndex: UInt32): SemanticType {
        let index = Int64(tyIndex) - 1
        if (index < 0 || index >= cjoPackage.GetAllTypes().size) {
            throw Exception("The length of the all types is ${cjoPackage.GetAllTypes().size}, but the index is ${index}.")
        }
        let typeInfo = cjoPackage.GetAllTypes()[index]
        if (let Some(ty) <- typeInfo) {
            return match (ty.GetKind()) {
                case PackageFormat_TypeKind.TypeKind_UNIT => UnitSType(0)
                case PackageFormat_TypeKind.TypeKind_INT64 => Int64SType(0)
                case PackageFormat_TypeKind.TypeKind_FUNC => createSemanticFuncType(cjoPackage, tyIndex)
                case PackageFormat_TypeKind.TypeKind_CLASS => createSemanticClassType(cjoPackage, tyIndex)
                case _ => throw Exception("Not implement this PackageFormat_TypeKind ${EnumPackageFormat_TypeKindValues(ty.GetKind())}")
            }
        } else {
            throw Exception("Failed to create SemanticType")
        }
    }

    private func createSemanticFuncType(cjoPackage: PackageFormat_Package, tyIndex: UInt32): SemanticType {
        let index = Int64(tyIndex) - 1
        if (index < 0 || index >= cjoPackage.GetAllTypes().size) {
            throw Exception("The length of the all types is ${cjoPackage.GetAllTypes().size}, but the index is ${index}.")
        }
        let typeInfo = cjoPackage.GetAllTypes()[index]
        return if (let Some(ty) <- typeInfo) {
            let funcTyInfo = ty.GetInfoAsFuncTyInfo().getOrThrow()
            let returnType = createSemanticType(cjoPackage, funcTyInfo.GetRetType())
            let paramTypes = ArrayList<SemanticType>()
            for (i in ty.GetTypeArgs()) {
                paramTypes.add(createSemanticType(cjoPackage, i))
            }
            let f = FuncSType(paramTypes.toArray(), returnType)
            return f
        } else { 
            throw Exception("Failed to create SemanticFuncType")
        }
    }

    private func createSemanticClassType(cjoPackage: PackageFormat_Package, tyIndex: UInt32): SemanticType {
        let index = Int64(tyIndex) - 1
        if (index < 0 || index >= cjoPackage.GetAllTypes().size) {
            throw Exception("The length of the all types is ${cjoPackage.GetAllTypes().size}, but the index is ${index}.")
        }
        let typeInfo = cjoPackage.GetAllTypes()[index]
        let res = if (let Some(ty) <- typeInfo) {
            let compositeTyInfo = ty.GetInfoAsCompositeTyInfo().getOrThrow()
            if (compositeTyInfo.GetIsThisTy()) {
                return ThisSType(0) 
            }
            let fullDeclId = compositeTyInfo.GetDeclPtr()
            let className = if (let Some(fullId) <- fullDeclId) {
                // println("fullId.GetDecl(): ${fullId.GetDecl()}") 读取字符串有bug，flatbuffer接口问题？
                GetDeclInfoFromIndex(cjoPackage, fullId)
            } else {
                ""
            }
            return ClassSType(className, [], Option<ClassDecl>.None, 0)
        } else { 
            throw Exception("Failed to create SemanticFuncType")
        }
        return res
    }


    static const INVALID_PACKAGE_INDEX: Int32 = -1
    static const CURRENT_PKG_INDEX: Int32 = -2
    static const PKG_REFERENCE_INDEX: Int32 = -3

    // get name TODO: get args
    private func GetDeclInfoFromIndex(cjoPackage: PackageFormat_Package, fullId: PackageFormat_FullId): String {
        return if (fullId.GetPkgId() == CURRENT_PKG_INDEX) {
            let index = Int64(fullId.GetIndex()) - 1
            if (index < 0 || index >= cjoPackage.GetAllDecls().size) {
                throw Exception("The length of the all decls is ${cjoPackage.GetAllDecls().size}, but the index is ${index}.")
            }
            let declInfo = cjoPackage.GetAllDecls()[index]
            
            if (let Some(decl) <- declInfo) { 
                decl.GetIdentifier()
            } else {
                throw Exception("Failed to get decl infos")
            }
        } else {
            ""
        }
    }
}
