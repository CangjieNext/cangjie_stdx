
#include "semantic.h"

#include "cangjie/AST/Identifier.h"
#include "cangjie/AST/Node.h"
#include "cangjie/AST/PrintNode.h"

#include <functional>
#include <string>
#include <vector>

using namespace Cangjie;
using namespace AST;

NonTerminal* AsNonTerminal(const SyntaxNodePtr& n)
{
    if (!n) {
        return nullptr;
    }
    if (n->getType() != SyntaxNode::NodeType::NON_TERMINAL) {
        return nullptr;
    }
    return static_cast<NonTerminal*>(n.get());
}

ValuedTerminal* AsValuedTerminal(const SyntaxNodePtr& n)
{
    if (!n) {
        return nullptr;
    }
    if (n->getType() != SyntaxNode::NodeType::VALUED_TERMINAL) {
        return nullptr;
    }
    return static_cast<ValuedTerminal*>(n.get());
}

// 一个简单的 C++ 版 LocalParser，方便遍历 NonTerminal.children。
class SyntaxLocalParser {
public:
    explicit SyntaxLocalParser(const std::vector<SyntaxNodePtr>& nodes) : nodes(nodes), cur(0), end(nodes.size()) {}

    bool isEnd() const
    {
        return cur >= end;
    }

    // 跳过空白后取一个节点，可能返回 nullptr。
    SyntaxNodePtr consume()
    {
        consumeWhitespace();
        if (isEnd()) {
            return nullptr;
        }
        return nodes[cur++];
    }

    // 不强制存在节点，直接取（同上，但更贴近原始实现语义）。
    SyntaxNodePtr tryConsume()
    {
        consumeWhitespace();
        if (isEnd()) {
            return nullptr;
        }
        return nodes[cur++];
    }

    // 期待特定 kind 的节点（string 版本），否则返回 nullptr。
    SyntaxNodePtr consume(const std::string& kind)
    {
        consumeWhitespace();
        if (isEnd()) {
            return nullptr;
        }
        if (nodes[cur]->kind == kind) {
            return nodes[cur++];
        }
        return nullptr;
    }

    // look(kind) / look(predicate) 与 CJ 版接口类似。
    bool look(const std::string& kind)
    {
        auto n = peek();
        return n && n->kind == kind;
    }

    bool look(const std::function<bool(const SyntaxNodePtr&)>& pred)
    {
        auto n = peek();
        return n && pred(n);
    }

    SyntaxNodePtr peek()
    {
        consumeWhitespace();
        if (isEnd()) {
            return nullptr;
        }
        return nodes[cur];
    }

    void consumeToEnd()
    {
        while (!isEnd()) {
            ++cur;
        }
    }

private:
    const std::vector<SyntaxNodePtr>& nodes;
    size_t cur;
    size_t end;

    void consumeWhitespace()
    {
        while (!isEnd()) {
            const auto& n = nodes[cur];
            // 和 syntaxNodeDeserializer 中的命名保持一致
            if (n->kind == "Space" || n->kind == "NewlineToken") {
                ++cur;
            } else if (n->kind == "CommentGroupList") {
                ++cur;
            } else {
                break;
            }
        }
    }
};

Ptr<AST::Ty> SyntaxToAstBuilder::BuildType(Decl& decl, uint64_t nodeId)
{
    auto type = declIDToTyMap.find(nodeId);
    if (type == declIDToTyMap.end()) {
        return nullptr;
    }
    Ptr<AST::Ty> ty = TypeManager::GetInvalidTy();
    auto typeArgs = std::vector<Ptr<AST::Ty>>();
    if (type->second.kind == static_cast<uint16_t>(TypeKind::TYPE_INT64)) {
        ty = TypeManager::GetPrimitiveTy(TypeKind::TYPE_INT64);
    } else if (type->second.kind == static_cast<uint16_t>(TypeKind::TYPE_INT32)) {
        ty = TypeManager::GetPrimitiveTy(TypeKind::TYPE_INT32);
    } else if (type->second.kind == static_cast<uint16_t>(TypeKind::TYPE_INT16)) {
        ty = TypeManager::GetPrimitiveTy(TypeKind::TYPE_INT16);
    } else if (type->second.kind == static_cast<uint16_t>(TypeKind::TYPE_INT8)) {
        ty = TypeManager::GetPrimitiveTy(TypeKind::TYPE_INT8);
    } else if (type->second.kind == static_cast<uint16_t>(TypeKind::TYPE_FUNC)) {
        for (const auto& typeArg : type->second.typeArgs) {
            typeArgs.emplace_back(BuildType(decl, typeArg.declId));
        }
        ty = typeManager.GetFunctionTy(typeArgs, typeArgs.back());
    } else if (type->second.kind == static_cast<uint16_t>(TypeKind::TYPE_CLASS)) {
        for (const auto& typeArg : type->second.typeArgs) {
            typeArgs.emplace_back(BuildType(decl, typeArg.declId));
        }
        if (auto* classDecl = dynamic_cast<ClassDecl*>(&decl)) {
            ty = typeManager.GetClassTy(*classDecl, typeArgs);
        }
    }
    return ty;
}

OwnedPtr<ClassDecl> SyntaxToAstBuilder::BuildClassDecl(NonTerminal* classNode, File* file, Package* pkg)
{
    auto decl = MakeOwned<ClassDecl>();
    // BNF: annotationList? (classModifierList)? CLASS IdentToken TypeArguments? (<: superTypes)? GenericConstraints? Body
    SyntaxLocalParser lp(classNode->children);
    std::string name;

    if (lp.look("AnnotationList")) {
        lp.consume();
    }
    if (lp.look("ModifierList")) {
        lp.consume();
    }
    if (lp.look("class")) {
        lp.consume();
    }
    if (lp.look("IdentToken")) {
        auto n = lp.consume();
        if (auto* vt = AsValuedTerminal(n)) {
            name = vt->value;
        }
    }
    if (lp.look("TypeArguments")) {
        lp.consume();
    }
    if (lp.look("<:")) {
        lp.consume();
        while (!lp.isEnd() && !lp.look("GenericConstraints") && !lp.look("Body")) {
            lp.consume();
        }
    }
    if (lp.look("GenericConstraints")) {
        lp.consume();
    }

    NonTerminal* bodyNode = nullptr;
    if (lp.look("Body")) {
        auto n = lp.consume();
        bodyNode = AsNonTerminal(n);
    }
    lp.consumeToEnd();

    if (!name.empty()) {
        decl->identifier = SrcIdentifier(name);
        decl->identifierForLsp = name;
        decl->fullPackageName = pkg ? pkg->fullPackageName : std::string{};
        decl->moduleName = pkg ? pkg->fullPackageName : std::string{};
    }
    std::cout << "BuildClassDecl: " << decl->identifier << std::endl;
    auto body = MakeOwned<ClassBody>();
    if (bodyNode) {
        for (const auto& child : bodyNode->children) {
            auto* nt = AsNonTerminal(child);
            if (!nt) {
                continue;
            }
            OwnedPtr<Decl> member = BuildDeclFromSyntaxNode(nt, file, pkg, decl.get());
            if (member) {
                body->decls.emplace_back(std::move(member));
            }
        }
    }
    decl->body = std::move(body);
    decl->curFile = file;
    decl->outerDecl = nullptr;
    decl->ty = BuildType(*decl, classNode->id);
    return decl;
}

// 从 VarBindingPattern (kind "VarPattern") 子节点中取第一个 IdentToken 的 value。
static std::string getIdentFromVarBindingPattern(NonTerminal* vb)
{
    if (!vb) {
        return {};
    }
    for (const auto& c : vb->children) {
        if (auto* vt = AsValuedTerminal(c)) {
            if (vt->kind == "IdentToken") {
                return vt->value;
            }
        }
    }
    return {};
}

OwnedPtr<VarDecl> SyntaxToAstBuilder::BuildVarDecl(NonTerminal* varNode, File* file, Package* pkg)
{
    auto decl = MakeOwned<VarDecl>();
    decl->ty = BuildType(*decl, varNode->id);
    // AnnotationList? ModifierList? (let|var|const)? pattern ( : type )? ( = init )?
    SyntaxLocalParser lp(varNode->children);
    std::string name;

    if (lp.look("AnnotationList")) {
        lp.consume();
    }
    if (lp.look("ModifierList")) {
        lp.consume();
    }
    if (lp.look("let") || lp.look("var") || lp.look("const")) {
        auto n = lp.consume();
        if (n) {
            decl->isVar = (n->kind == "var");
            decl->isConst = (n->kind == "const" || n->kind == "let");
        }
    }
    if (lp.look("VarPattern")) {
        auto n = lp.consume();
        if (n) {
            name = getIdentFromVarBindingPattern(AsNonTerminal(n));
        }
    } else if (lp.look("WildcardPattern") || lp.look("TuplePattern")) {
        lp.consume();
    }
    if (lp.look(":")) {
        lp.consume();
        lp.consume(); // skip type annotation node
    }
    if (lp.look("=")) {
        lp.consume();
        lp.consume(); // skip initializer node
    }

    if (!name.empty()) {
        decl->identifier = SrcIdentifier(name);
        decl->identifierForLsp = name;
        decl->fullPackageName = pkg ? pkg->fullPackageName : std::string{};
        decl->moduleName = pkg ? pkg->fullPackageName : std::string{};
    }
    std::cout << "BuildVarDecl: " << decl->identifier << std::endl;
    decl->curFile = file;
    decl->outerDecl = nullptr;
    return decl;
}

OwnedPtr<FuncParam> SyntaxToAstBuilder::BuildFuncParam(NonTerminal* paramNode, File* file, Package* pkg)
{
    auto param = MakeOwned<FuncParam>();
    if (!paramNode) {
        return param;
    }
    param->ty = BuildType(*param, paramNode->id);
    for (const auto& c : paramNode->children) {
        if (auto* vt = AsValuedTerminal(c)) {
            if (vt->kind == "IdentToken") {
                param->identifier = SrcIdentifier(vt->value);
                param->identifierForLsp = vt->value;
                break;
            }
        }
    }
    param->curFile = file;
    param->fullPackageName = pkg ? pkg->fullPackageName : std::string{};
    param->moduleName = pkg ? pkg->fullPackageName : std::string{};
    std::cout << "BuildFuncParam: " << param->identifier << std::endl;
    return param;
}

OwnedPtr<FuncParamList> SyntaxToAstBuilder::BuildFuncParamList(NonTerminal* paramListNode, File* file, Package* pkg)
{
    auto paramList = MakeOwned<FuncParamList>();
    if (!paramListNode) {
        return paramList;
    }
    for (const auto& child : paramListNode->children) {
        auto* nt = AsNonTerminal(child);
        if (!nt || nt->kind != "FuncParam") {
            continue;
        }
        paramList->params.emplace_back(BuildFuncParam(nt, file, pkg));
    }
    return paramList;
}

OwnedPtr<FuncBody> SyntaxToAstBuilder::BuildFuncBody(OwnedPtr<FuncParamList> paramList)
{
    auto body = MakeOwned<FuncBody>();
    if (paramList) {
        body->paramLists.push_back(std::move(paramList));
    }
    return body;
}

OwnedPtr<FuncDecl> SyntaxToAstBuilder::BuildFuncDecl(NonTerminal* funcNode, File* file, Package* pkg)
{
    auto decl = MakeOwned<FuncDecl>();

    // BNF: anno? modifier? (FUNC? IDENT | INIT | ~INIT) typeParams? ParameterList (COLON type)? genericConstraints? block?
    SyntaxLocalParser lp(funcNode->children);
    std::string name;

    if (lp.look("AnnotationList")) {
        lp.consume();
    }
    if (lp.look("ModifierList")) {
        lp.consume();
    }
    if (lp.look("IdentToken")) {
        auto n = lp.consume();
        if (auto* vt = AsValuedTerminal(n)) {
            name = vt->value;
        }
    } else if (lp.look("func")) {
        lp.consume();
        if (lp.look("IdentToken")) {
            auto n = lp.consume();
            if (auto* vt = AsValuedTerminal(n)) {
                name = vt->value;
            }
        }
    } else if (lp.look("~")) {
        lp.consume();
        name = "~init";
        if (lp.look("init")) {
            lp.consume();
        }
    } else if (lp.look("init")) {
        lp.consume();
        name = "init";
    }

    if (lp.look("TypeArguments")) {
        lp.consume();
    }

    OwnedPtr<FuncParamList> paramList;
    if (lp.look("ParameterList")) {
        auto n = lp.consume();
        NonTerminal* paramsNode = AsNonTerminal(n);
        paramList = BuildFuncParamList(paramsNode, file, pkg);
    }
    decl->funcBody = BuildFuncBody(std::move(paramList));
    if (decl->funcBody) {
        decl->funcBody->funcDecl = decl.get();
    }

    if (lp.look(":")) {
        lp.consume();
        lp.consume(); // skip return type node
    }
    if (lp.look("GenericConstraints")) {
        lp.consume();
    }
    if (lp.look("Block")) {
        lp.consume(); // skip function body block
    }
    lp.consumeToEnd();

    if (!name.empty()) {
        decl->identifier = SrcIdentifier(name);
        decl->identifierForLsp = name;
        decl->fullPackageName = pkg ? pkg->fullPackageName : std::string{};
        decl->moduleName = pkg ? pkg->fullPackageName : std::string{};
    }
    std::cout << "BuildFuncDecl: " << decl->identifier << std::endl;
    decl->curFile = file;
    decl->outerDecl = nullptr;
    decl->ty = BuildType(*decl, funcNode->id);
    return decl;
}

OwnedPtr<Decl> SyntaxToAstBuilder::BuildDeclFromSyntaxNode(NonTerminal* nt, File* file, Package* pkg, Decl* outerDecl)
{
    if (!nt || !file || !pkg) {
        return nullptr;
    }
    OwnedPtr<Decl> decl;
    if (nt->kind == "ClassDecl") {
        decl = BuildClassDecl(nt, file, pkg);
    } else if (nt->kind == "VarDecl") {
        decl = BuildVarDecl(nt, file, pkg);
    } else if (nt->kind == "FuncDecl") {
        decl = BuildFuncDecl(nt, file, pkg);
    }
    if (decl && outerDecl) {
        decl->outerDecl = outerDecl;
    }
    return decl;
}

OwnedPtr<File> SyntaxToAstBuilder::BuildFile(NonTerminal* fileNode, Package* pkg, size_t index)
{
    auto file = MakeOwned<File>();

    file->curPackage = pkg;
    file->curFile = file.get();

    file->fileName = "synthetic_" + std::to_string(index) + ".cj";
    file->filePath = file->fileName;
    std::cout << "BuildFile: " << file->filePath << std::endl;
    
    for (const auto& child : fileNode->children) {
        auto* nt = AsNonTerminal(child);
        if (!nt) {
            continue;
        }
        OwnedPtr<Decl> decl = BuildDeclFromSyntaxNode(nt, file.get(), pkg, nullptr);
        if (decl) {
            file->decls.emplace_back(std::move(decl));
        }
    }

    return file;
}

// 从 SyntaxNode 根节点构建一个 Package AST。
// 仅处理 Package / File / ClassDecl / VarDecl / FuncDecl。
OwnedPtr<Package> SyntaxToAstBuilder::BuildPackageFromSyntaxNode(const SyntaxNodePtr& root)
{
    auto pkg = MakeOwned<Package>();
    // TODO: translate the package name from the root node
    pkg->fullPackageName = "define";
    auto* nt = AsNonTerminal(root);
    if (!nt) {
        return pkg;
    }

    size_t fileIndex = 0;
    if (nt->kind == "Package") {
        for (const auto& child : nt->children) {
            auto* fileNode = AsNonTerminal(child);
            if (!fileNode || fileNode->kind != "File") {
                continue;
            }
            pkg->files.emplace_back(BuildFile(fileNode, pkg.get(), fileIndex++));
        }
    } else if (nt->kind == "File") {
        pkg->files.emplace_back(BuildFile(nt, pkg.get(), fileIndex++));
    }
    PrintNode(pkg.get());
    return pkg;
}

