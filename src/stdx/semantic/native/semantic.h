#include "flatbuffers/SemanticType_generated.h"
#include "flatbuffers/SyntaxNodeFormat_generated.h"

#include "cangjie/AST/Walker.h"
#include "cangjie/AST/Node.h"
#include "cangjie/Basic/Print.h"
#include "cangjie/Sema/TypeManager.h"

#include <cstdint>
#include <iostream>
#include <ostream>
#include <sstream>
#include <string>
#include <vector>
#include <stack>

using ASTNode = Ptr<const Cangjie::AST::Node>;
using AstTy = Ptr<const Cangjie::AST::Ty>;

const size_t INITIAL_FILE_SIZE = 65536;
class SyntaxNode;

using SyntaxNodePtr = std::shared_ptr<SyntaxNode>;
using namespace Cangjie;
using namespace AST;

class TypeWrite {
public:
    TypeWrite(std::map<Ptr<const AST::Node>, int> declTypeMap, std::map<Ptr<const AST::Node>, int> exprTypeMap,
        std::map<int, Ptr<const AST::Expr>> refMap)
        : declTypeMap(declTypeMap), exprTypeMap(exprTypeMap), refMap(refMap), builder(INITIAL_FILE_SIZE) {
    }

    ~TypeWrite() {
    }

    uint8_t* ExportType();

private:
    std::vector<uint8_t> bufferData;
    std::map<Ptr<const AST::Node>, int> declTypeMap;
    std::map<Ptr<const AST::Node>, int> exprTypeMap;
    // ref id -> decl ptr
    std::map<int, Ptr<const AST::Expr>> refMap;
    flatbuffers::Offset<SemanticType::ASTType> SerializeSemanticType(AstTy ty);
    flatbuffers::Offset<SemanticType::SemanticTypeMap> SerializeSemanticTypeMap(int id, AstTy ty);
    flatbuffers::Offset<SemanticType::SymbolRefMap> SerializeRefMap(int refId, int declId);
    flatbuffers::Offset<SemanticType::NodeTypeMap> SerializeNodeTypeMap();
    flatbuffers::FlatBufferBuilder builder;
};

class SyntaxNodeFlatBufferDeserializer {
public:
    static std::shared_ptr<SyntaxNode> deserialize(const uint8_t* buffer, size_t length);

private:
    static std::shared_ptr<SyntaxNode> deserializeNonTerminal(const SyntaxNodeFormat::NonTerminal* nonTerm);

    static std::shared_ptr<SyntaxNode> deserializeTerminal(const SyntaxNodeFormat::Terminal* term);

    static std::shared_ptr<SyntaxNode> deserializeValuedTerminal(const SyntaxNodeFormat::ValuedTerminal* valTerm);

    static std::shared_ptr<SyntaxNode> deserializeRepeatedTerminal(const SyntaxNodeFormat::RepeatedTerminal* repTerm);

    static std::shared_ptr<SyntaxNode> getChildNodeByType(const void* offset, SyntaxNodeFormat::SyntaxNodeImpl type);

    static std::string getNodeKindName(SyntaxNodeFormat::NodeImplKind kind);
};

struct ASTTypeInfo {
    uint16_t kind = 0;
    std::string name;
    uint64_t rawPointer = 0;
    uint64_t declId = 0;
    std::vector<ASTTypeInfo> typeArgs;

    void dump(std::ostream& os, int indent = 0) const
    {
        auto pad = [&]() {
            for (int i = 0; i < indent; ++i) os << ' ';
        };

        pad();
        os << "ASTTypeInfo{kind=" << kind;
        if (!name.empty()) os << ", name=\"" << name << "\"";
        os << ", rawPointer=" << rawPointer << ", declId=" << declId;

        if (typeArgs.empty()) {
            os << "}";
            return;
        }

        os << ", typeArgs=[\n";
        for (size_t i = 0; i < typeArgs.size(); ++i) {
            typeArgs[i].dump(os, indent + 2);
            os << (i + 1 == typeArgs.size() ? "\n" : ",\n");
        }
        pad();
        os << "]}";
    }

    std::string toString(int indent = 0) const
    {
        std::ostringstream ss;
        dump(ss, indent);
        return ss.str();
    }
};

class DeclTypeMapFlatBufferDeserializer {
public:
    static std::map<uint64_t, ASTTypeInfo> deserialize(const uint8_t* buffer, size_t length) {

        if (buffer == nullptr || length == 0) {
            mutableDeclTypeInfoMap().clear();
            return mutableDeclTypeInfoMap();
        }

        // buffer comes from Cangjie `Builder.finishedBytes()` (no size prefix).
        flatbuffers::Verifier verifier(buffer, length);
        if (!SemanticType::VerifyNodeTypeMapBuffer(verifier)) {
            std::cerr << "DeclTypeMapFlatBufferDeserializer: invalid NodeTypeMap flatbuffer" << std::endl;
            mutableDeclTypeInfoMap().clear();
            return mutableDeclTypeInfoMap();
        }

        const auto* root = SemanticType::GetNodeTypeMap(buffer);
        auto& map = mutableDeclTypeInfoMap();
        map.clear();

        const auto* declList = root ? root->declMapList() : nullptr;
        if (!declList) {
            return mutableDeclTypeInfoMap();
        }

        for (const auto* e : *declList) {
            if (!e) continue;
            const uint64_t id = e->id();
            map[id] = deserializeASTType(e->type());
            
            std::cout << "DeclTypeMapFlatBufferDeserializer: " << id << " " << map[id].toString() << std::endl;
        }
        return mutableDeclTypeInfoMap();
    }

    static const std::map<uint64_t, ASTTypeInfo>& declTypeInfoMap()
    {
        return mutableDeclTypeInfoMap();
    }

private:
    static ASTTypeInfo deserializeASTType(const SemanticType::ASTType* t)
    {
        ASTTypeInfo out;
        if (!t) return out;

        out.kind = t->kind();
        out.rawPointer = t->rawPointer();
        out.declId = t->declId();
        if (t->name()) {
            out.name = t->name()->str();
        }
        if (const auto* args = t->typeArgs()) {
            out.typeArgs.reserve(args->size());
            for (const auto* a : *args) {
                out.typeArgs.push_back(deserializeASTType(a));
            }
        }
        return out;
    }

    static std::map<uint64_t, ASTTypeInfo>& mutableDeclTypeInfoMap()
    {
        // Header-only storage: one instance per translation unit.
        static std::map<uint64_t, ASTTypeInfo> s_map;
        return s_map;
    }
};


class SyntaxNode {
public:
    std::string kind;
    uint64_t id;

    enum class NodeType { NON_TERMINAL, TERMINAL, VALUED_TERMINAL, REPEAT_TERMINAL };

    virtual ~SyntaxNode() = default;
    virtual NodeType getType() const = 0;
    virtual std::string toString() const = 0;
    bool isDecl() {
        if (kind == "VarDecl" || kind == "FuncDecl" || kind == "MainDecl" || kind == "TypeAlias" || 
            kind == "ClassDecl" || kind == "StructDecl" || kind == "InterfaceDecl" || kind == "ExtendDecl" || 
            kind == "EnumDecl" || kind == "MacroDecl" || kind == "MacroExpandDecl" || kind == "PropDecl" || 
            kind == "StaticInit" || kind == "EnumConstructor" || kind == "GenericParam") {
            return true;
        }
        return false;
    }
    bool isExpr() {
        if (kind == "BinaryExpr" || kind == "SymbolRef" || kind == "ValuedLiteral" || kind == "UnitLiteral" || 
            kind == "RuneLiteral" || kind == "LineStringLiteral" || kind == "MultiLineStringLiteral" || 
            kind == "MultiLineRawStringLiteral" || kind == "ArrayLiteral" || kind == "TupleLiteral" || 
            kind == "AssignExpr" || kind == "VArrayExpr" || kind == "MemberAccess" || kind == "UnaryExpr" || 
            kind == "CallExpr" || kind == "IsExpr" || kind == "AsExpr" || kind == "ParenExpr" || 
            kind == "ReturnExpr" || kind == "IncOrDecExpr" || kind == "RangeExpr" || kind == "TypeConvExpr" || 
            kind == "OptionalExpr" || kind == "BreakExpr" || kind == "ContinueExpr" || kind == "SubscriptExpr" || 
            kind == "Lambda" || kind == "MatchExpr" || kind == "TryCatch" || kind == "ThrowExpr" || 
            kind == "SynchronizedExpr" || kind == "SpawnExpr" || kind == "IfExpr" || kind == "WhileExpr" || 
            kind == "DoWhileExpr" || kind == "ForInExpr" || kind == "JumpExpr" || kind == "LambdaExpr" || 
            kind == "TryExpr" || kind == "InterpolationExpr" || kind == "QuoteTokenExpr" || kind == "QuoteExpr" || 
            kind == "QuoteInterpolationExpr" || kind == "TrailingClosureExpr" || kind == "UnsafeExpr" || 
            kind == "MacroExpandExpr") {
            return true;
        }
        return false;
    }
    bool isSymbolRef() {
        if (kind == "SymbolRef") {
            return true;
        }
        return false;
    }

    bool isMemberAccess() {
        if (kind == "MemberAccess") {
            return true;
        }
        return false;
    }
};

class Terminal : public SyntaxNode {
public:
    NodeType getType() const override {
        return NodeType::TERMINAL;
    }

    virtual std::string toString() const override {
        return this->kind;
    }
};

class NonTerminal : public SyntaxNode {
public:
    std::vector<SyntaxNodePtr> children;

    NodeType getType() const override {
        return NodeType::NON_TERMINAL;
    }
    std::string toString() const override {
        std::stack<SyntaxNodePtr, std::vector<SyntaxNodePtr>> stack;
        std::stringstream ss;

        // Push children in reverse order to maintain correct sequence
        for (int i = static_cast<int>(children.size()) - 1; i >= 0; i--) {
            stack.push(children[i]);
        }

        while (!stack.empty()) {
            auto node = stack.top();
            stack.pop();

            if (auto nt = std::dynamic_pointer_cast<NonTerminal>(node)) {
                for (int i = static_cast<int>(nt->children.size()) - 1; i >= 0; i--) {
                    stack.push(nt->children[i]);
                }
            } else if (auto t = std::dynamic_pointer_cast<Terminal>(node)) {
                ss << t->toString();
            } else {
                ss << "Unknown";
            }
        }
        return ss.str();
    }

    SyntaxNodePtr findFirstSymbolNode() const {
        return findSymbolNodeRecursive(children);
    }

private:
    SyntaxNodePtr findSymbolNodeRecursive(const std::vector<SyntaxNodePtr>& nodeList) const {
        for (const auto& node : nodeList) {
            if (!node) {
                continue; 
            }
            if (node->kind == "SymbolRef") {
                return node; 
            }
            if (auto nt = std::dynamic_pointer_cast<NonTerminal>(node)) {
                auto foundNode = findSymbolNodeRecursive(nt->children);
                if (foundNode) {
                    return foundNode;
                }
            }
        }
        return nullptr;
    }
};

class ValuedTerminal : public Terminal {
public:
    std::string value;

    NodeType getType() const override {
        return NodeType::VALUED_TERMINAL;
    }
    std::string toString() const override {
        return value;
    }
};

#ifdef _WIN32
const std::string NEWLINE = "\r\n";
#else
const std::string NEWLINE = "\n";
#endif

class RepeatedTerminal : public Terminal {
public:
    int repeat;
    NodeType getType() const override {
        return NodeType::REPEAT_TERMINAL;
    }

    std::string toString() const override {
        if (this->kind == "Space") {
            return std::string(repeat, ' ');
        } else if (this->kind == "NewlineToken") {
            std::string result;
            for (int64_t i = 0; i < repeat; i++) {
                result += NEWLINE;
            }
            return result;
        } else {
            return this->kind;
        }
        return "";
    }
};

class TypeCollector {
public:
    // Nonterminal id -> ast ptr
    std::map<Ptr<const AST::Node>, int> declMap;
    std::map<Ptr<const AST::Node>, int> exprMap;
    // Nonterminal id -> refExpr/MemberAccess 
    // refExpr->ref.target is null when collecting type before sema
    std::map<int, Ptr<const AST::Expr>> refTarget;

    std::vector<Ptr<AST::Node>> collectChild(const Ptr<AST::Node> &node);

    void collect(const SyntaxNodePtr &syntaxNode, const Ptr<AST::Node> &node);
    
    void collectMainDeclDesugar(const SyntaxNodePtr &syntaxNode, const Ptr<AST::Node> &node);
};

class SyntaxToAstBuilder {
public:
    SyntaxToAstBuilder(const std::map<uint64_t, ASTTypeInfo>& declIDToTyMap, TypeManager& typeManager)
        : declIDToTyMap(declIDToTyMap), typeManager(typeManager) {
    }

    ~SyntaxToAstBuilder() {
    }
    const std::map<uint64_t, ASTTypeInfo>& declIDToTyMap;
    TypeManager& typeManager;
    OwnedPtr<Package> BuildPackageFromSyntaxNode(const SyntaxNodePtr& root);
    
private:
    OwnedPtr<File> BuildFile(NonTerminal* fileNode, Package* pkg, size_t index);
    OwnedPtr<Decl> BuildDeclFromSyntaxNode(NonTerminal* nt, File* file, Package* pkg, Decl* outerDecl);
    OwnedPtr<ClassDecl> BuildClassDecl(NonTerminal* classNode, File* file, Package* pkg);
    OwnedPtr<VarDecl> BuildVarDecl(NonTerminal* varNode, File* file, Package* pkg);
    OwnedPtr<FuncDecl> BuildFuncDecl(NonTerminal* funcNode, File* file, Package* pkg);
    OwnedPtr<FuncBody> BuildFuncBody(OwnedPtr<FuncParamList> paramList);
    OwnedPtr<FuncParamList> BuildFuncParamList(NonTerminal* paramListNode, File* file, Package* pkg);
    OwnedPtr<FuncParam> BuildFuncParam(NonTerminal* paramNode, File* file, Package* pkg);

    Ptr<AST::Ty> BuildType(Decl& decl, uint64_t nodeId);
};
