#include "flatbuffers/SemanticType_generated.h"
#include "flatbuffers/SyntaxNodeFormat_generated.h"

#include "cangjie/AST/Walker.h"
#include "cangjie/AST/Node.h"
#include "cangjie/Basic/Print.h"

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

class DeclTypeMapFlatBufferDeserializer {
public:
    static void deserialize(const uint8_t* buffer, size_t length) {
        const auto* root = SemanticType::GetNodeTypeMap(buffer);

        auto dumpList = [](const flatbuffers::Vector<flatbuffers::Offset<SemanticType::SemanticTypeMap>>* list) {
            if (!list) return;
            for (const auto* e : *list) {
                uint64_t id = e->id();
                const auto* t = e->type(); // SemanticType::ASTType*
                uint16_t kind = t ? t->kind() : 0;
                const char* name = (t && t->name()) ? t->name()->c_str() : "";
                // 需要的话还可以读：t->typeArgs(), t->rawPointer(), t->declId()
                (void)id; (void)kind; (void)name;
            }
        };

        dumpList(root->declMapList());
    }

private:
    // static std::shared_ptr<SyntaxNode> deserializeNonTerminal(const SyntaxNodeFormat::NonTerminal* nonTerm);
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
            kind == "StaticInit" || kind == "EnumConstructor") {
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
};