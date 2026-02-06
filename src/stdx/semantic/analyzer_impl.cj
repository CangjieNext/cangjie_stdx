package stdx.semantic

import stdx.syntax.*
import std.collection.*

class AnalyzerImpl {
    let visitor: CollectVisitor

    init(pkg: Package) {
        visitor = CollectVisitor()
        visitor.walk(pkg)
        visitor.updateExtendInheritMap()

        println("Collect Result:")
        println("TypeMap: ${visitor.typeMap.size}")
        println("ExtendMap: ${visitor.extendMap.size}")
        println("InheritMap: ${visitor.inheritMap.size}")
    }

    func get(ty: TypeAnnotation): ?Decl {
        visitor.typeMap.get("${ty}")
    }

    private func getExtendMembers(decl: Decl): ArrayList<Decl> {
        let members = ArrayList<Decl>()
        let id = match (decl) {
            case cd: ClassDecl => cd.name 
            case sd: StructDecl => sd.name
            case _ => ""
        }
        if (let Some(eds) <- visitor.extendMap.get(id)) {
            for (ed in eds) {
               members.add(all: ed.body.memberDecls) 
            }
        }
        members
    }

    // get members of decl, including extend members
    func getMembers(decl: Decl): Array<Decl> {
        let members = ArrayList<Decl>()
        match (decl) {
            case cd: ClassDecl =>
                members.add(all: cd.body.memberDecls)
            case id: InterfaceDecl =>
                members.add(all: id.body.memberDecls)
            case _ => ()
        }
        members.add(all: getExtendMembers(decl))
        members.toArray()
    }

    private func getExtendSuperTys(decl: Decl): ArrayList<Decl> {
        let superTys = ArrayList<Decl>()
        let id = match (decl) {
            case cd: ClassDecl => cd.name 
            case sd: StructDecl => sd.name
            case _ => ""
        }
        if (let Some(eds) <- visitor.extendMap.get(id)) {
            for (ed in eds) {
                superTys.add(all: getTys(ed.superTyAnnotations))
            }
        }
        superTys
    }

    private func getTys(tys: Array<TypeAnnotation>): ArrayList<Decl> {
        let decls = ArrayList<Decl>()
        for (ty in tys) {
            if (let Some(decl) <- visitor.typeMap.get("${ty}")) {
                decls.add(decl)
            }
        }
        decls
    }

    // get super tys of decl, including extend implementation
    // TODO: imported decl?
    func getSuperTys(decl: Decl): Array<Decl> {
        let supers = ArrayList<Decl>()
        match (decl) {
            case cd: ClassDecl => 
                supers.add(all: getTys(cd.superTyAnnotations))
                supers.add(all: getExtendSuperTys(cd))
            case sd: StructDecl =>
                supers.add(all: getTys(sd.superTyAnnotations))
                supers.add(all: getExtendSuperTys(sd))
            case id: InterfaceDecl =>
                supers.add(all: getTys(id.superTyAnnotations))
            case _ => ()
        }
        // TODO: compute super closure
        supers.toArray()
    }

    // get sub tys of decl, including extend implementation
    func getSubTys(decl: Decl): Array<Decl> {
        let subs = ArrayList<Decl>()
        let id = match (decl) {
            case cd: ClassDecl => cd.name 
            case id: InterfaceDecl => id.name
            case _ => ""
        }
        if (let Some(subDecls) <- visitor.inheritMap.get(id)) {
            subs.add(all: subDecls)
        }
        // TODO: compute sub closure
        subs.toArray()
    }
}

class CollectVisitor <: ASTVisitor {
    // collect custom decls
    let typeMap = HashMap<String, Decl>()
    // collect extend decl
    let extendMap = HashMap<String, ArrayList<ExtendDecl>>()
    // collect sub types: I -> [A, C] extend A <: I or class C <: I
    let inheritMap = HashMap<String, ArrayList<Decl>>()

    CollectVisitor() {}

    func updateSymbolTable(decl: Decl) {
        match (decl) {
            case cd: ClassDecl =>
                typeMap[cd.name] = cd
            case id: InterfaceDecl =>
                typeMap[id.name] = id
            case _ => ()
        }
    }

    func addDecl<T>(map: HashMap<String, ArrayList<T>>, key: String, decl: T) where T <: Decl {
        if (!map.contains(key)) {
            map.add(key, ArrayList<T>())
        }
        map[key].add(decl)
    }

    func updateExtend(ed: ExtendDecl) {
        let ty = "${ed.extendedTyAnnotation}"
        addDecl<ExtendDecl>(this.extendMap, ty, ed)
    }

    private func updateInheritMap(decl: Decl, superTys: Array<TypeAnnotation>) {
        for (ty in superTys) {
            addDecl<Decl>(inheritMap, "${ty}", decl)
        }
    }

    func updateExtendInheritMap() {
        for (ed in (extendMap |> flatMap { kv => kv[1]})) {
            let ty = "${ed.extendedTyAnnotation}"
            if (let Some(decl) <- typeMap.get(ty)) {
                updateInheritMap(decl, ed.superTyAnnotations)
            }
        }
    }

    public override func preAction(node: SyntaxTreeNode): PreActionMode {
        if (let decl: Decl <- node) {
            match (decl) {
                case cd: ClassDecl =>
                    typeMap[cd.name] = cd
                    updateInheritMap(cd, cd.superTyAnnotations)
                case id: InterfaceDecl =>
                    typeMap[id.name] = id
                    updateInheritMap(id, id.superTyAnnotations)
                case sd: StructDecl =>
                    typeMap[sd.name] = sd
                    updateInheritMap(sd, sd.superTyAnnotations)
                case ed: ExtendDecl =>
                    updateExtend(ed)
                case _ => ()
            }
            PreActionMode.Skip
        } else {
            PreActionMode.Continue
        }
    }
}

