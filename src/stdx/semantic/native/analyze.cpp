#include <iostream>
#include <vector>
#include <memory>

#include "json.hpp"
#include "cangjie/Basic/DiagnosticEmitter.h"
#include "cangjie/Basic/SourceManager.h"
#include "cangjie/Frontend/CompilerInstance.h"
#include "cangjie/Parse/Parser.h"

#include "cangjie/AST/Walker.h"

#include "cangjie/Sema/TypeChecker.h"
#include "cangjie/Sema/Desugar.h"
#include "cangjie/Macro/MacroCommon.h"

#include "typeWrite.h"

using json = nlohmann::json;

class SyntaxNode;
using SyntaxNodePtr = std::shared_ptr<SyntaxNode>;
using namespace Cangjie;

class SyntaxNode {
public:
    std::string kind;
    uint64_t id;

    enum class NodeType {
        NON_TERMINAL,
        TERMINAL,
        VALUED_TERMINAL,
        REPEAT_TERMINAL
    };
    
    virtual ~SyntaxNode() = default;
    virtual NodeType getType() const = 0;
    virtual std::string toString() const = 0;
    bool isDecl() {
        if (kind == "VarDecl" || kind == "FuncDecl") {
            return true;
        }
        return false;
    }
    bool isExpr() {
        if (kind == "BinaryExpr") {
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
        std::stack<SyntaxNodePtr, std::vector<SyntaxNodePtr>> stack(children);
        std::stringstream ss;

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
        } else if (this->kind == "NL") {
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

// JSON反序列化函数
class SyntaxTreeDeserializer {
public:
    // 主要的反序列化方法
    static SyntaxNodePtr deserialize(const std::string& jsonString) {
        try {
            json j = json::parse(jsonString);
            return deserializeNode(j);
        } catch (const std::exception& e) {
            // 处理解析错误
            throw std::runtime_error("Failed to parse JSON: " + std::string(e.what()));
        }
    }
    
private:
    // 递归反序列化节点
    static SyntaxNodePtr deserializeNode(const json& j) {
        if (!j.contains("type")) {
            throw std::runtime_error("Missing 'type' field in JSON");
        }
        
        std::string type = j["type"];
        
        if (type == "NonTerminal") {
            return deserializeNonTerminal(j);
        } else if (type == "ValuedTerminal") {
            return deserializeValuedTerminal(j);
        } else if (type == "RepeatedTerminal") {
            return deserializeRepeatedTerminal(j);
        } else if (type == "Terminal") {
            return deserializeTerminal(j);
        } else {
            throw std::runtime_error("Unknown node type: " + type);
        }
    }
    
    // 反序列化非终结符节点
    static SyntaxNodePtr deserializeNonTerminal(const json& j) {
        auto node = std::make_shared<NonTerminal>();
        
        if (j.contains("kind")) {
            node->kind = j["kind"];
        }
        if (j.contains("id")) {
            node->id = j["id"];
        }
        if (j.contains("children") && j["children"].is_array()) {
            for (const auto& childJson : j["children"]) {
                node->children.push_back(deserializeNode(childJson));
            }
        }
        
        return node;
    }
    
    // 反序列化带值的终结符节点
    static SyntaxNodePtr deserializeValuedTerminal(const json& j) {
        auto node = std::make_shared<ValuedTerminal>();
        
        if (j.contains("kind")) {
            node->kind = j["kind"];
        }
        if (j.contains("id")) {
            node->id = j["id"];
        }
        if (j.contains("value")) {
            node->value = j["value"];
        }
        
        return node;
    }
    
    // 反序列化重复终结符节点
    static SyntaxNodePtr deserializeRepeatedTerminal(const json& j) {
        auto node = std::make_shared<RepeatedTerminal>();
        
        if (j.contains("kind")) {
            node->kind = j["kind"];
        }
        if (j.contains("id")) {
            node->id = j["id"];
        }
        if (j.contains("repeat")) {
            node->repeat = j["repeat"];
        }
        
        return node;
    }

    static SyntaxNodePtr deserializeTerminal(const json& j) {
        auto node = std::make_shared<Terminal>();
        
        if (j.contains("kind")) {
            node->kind = j["kind"];
        }
        if (j.contains("id")) {
            node->id = j["id"];
        }

        return node;
    }
};

void printSyntaxNode(const SyntaxNodePtr& node, int depth = 0) {
    if (!node) {
        std::cout << "null" << std::endl;
        return;
    }
    
    // Print indentation based on depth
    for (int i = 0; i < depth; ++i) {
        std::cout << "  ";
    }
    
    // Print node information based on type
    switch (node->getType()) {
        case SyntaxNode::NodeType::NON_TERMINAL:
        {
            auto nonTerminal = std::static_pointer_cast<NonTerminal>(node);
            std::cout << "NonTerminal: " << nonTerminal->kind << std::endl;
            // Print children
            for (const auto& child : nonTerminal->children) {
                printSyntaxNode(child, depth + 1);
            }
            break;
        }
            
        case SyntaxNode::NodeType::VALUED_TERMINAL:
        {
            auto valuedTerminal = std::static_pointer_cast<ValuedTerminal>(node);
            std::cout << "ValuedTerminal: " << valuedTerminal->kind 
                      << " = \"" << valuedTerminal->value << "\"" << std::endl;
            break;
        }
            
        case SyntaxNode::NodeType::REPEAT_TERMINAL:
        {
            auto repeatedTerminal = std::static_pointer_cast<RepeatedTerminal>(node);
            std::cout << "RepeatedTerminal: " << repeatedTerminal->kind 
                      << " (repeat=" << repeatedTerminal->repeat << ")" << std::endl;
            break;
        }

        case SyntaxNode::NodeType::TERMINAL:
        {
            auto repeatedTerminal = std::static_pointer_cast<Terminal>(node);
            std::cout << "Terminal: " << repeatedTerminal->kind << std::endl;
            break;
        }
    }
}

class TypeCollector {
public:
    std::map<int, Ptr<const AST::Node>> declMap;
    std::map<int, Ptr<const AST::Node>> exprMap;
    std::map<int, int> refTarget;

    std::vector<Ptr<AST::Node>> collectChild(const Ptr<AST::Node> &node)
    {
        std::vector<Ptr<AST::Node>> collect;
        auto visitor = [&collect](const Ptr<AST::Node> &node) {
            switch (node->astKind) {
                case ASTKind::PACKAGE: {
                    auto package = StaticAs<ASTKind::PACKAGE>(node);
                    for (auto& file : package->files) {
                        collect.emplace_back(file);
                    }
                    return VisitAction::SKIP_CHILDREN;
                }
                case ASTKind::FILE: {
                    auto file = StaticAs<ASTKind::FILE>(node);
                    for (auto& decl : file->decls) {
                        collect.emplace_back(decl);
                    }
                    return VisitAction::SKIP_CHILDREN;
                }
                case ASTKind::VAR_DECL: {
                    auto vd = StaticAs<ASTKind::VAR_DECL>(node);
                    if (vd->type.get()) {
                        collect.emplace_back(vd->type);
                    }
                    if(vd->initializer.get()) {
                        collect.emplace_back(vd->initializer);
                    }
                    return VisitAction::SKIP_CHILDREN;
                }
                case ASTKind::BINARY_EXPR: {
                    auto be = StaticAs<ASTKind::BINARY_EXPR>(node);
                    if (be->leftExpr.get()) {
                        collect.emplace_back(be->leftExpr);
                    }
                    if (be->rightExpr.get()) {
                        collect.emplace_back(be->rightExpr);
                    }
                    return VisitAction::SKIP_CHILDREN;
                }
                default:
                    return VisitAction::SKIP_CHILDREN;
            }
        };
        Walker collector = Walker(node, visitor);
        collector.Walk();
        return collect;
    }

    void collect(const SyntaxNodePtr &syntaxNode, const Ptr<AST::Node> &node){
        if (syntaxNode->getType() != NonTerminal::NodeType::NON_TERMINAL) {
            return;
        }
        if (syntaxNode->isDecl() || syntaxNode->isExpr()) {
            declMap[syntaxNode->id] = node.get();
        }
        if (syntaxNode->isSymbolRef() && node->astKind == ASTKind::REF_EXPR) {
            exprMap[syntaxNode->id] = node.get();
            auto refExpr = StaticAs<ASTKind::REF_EXPR>(node);
            refTarget[syntaxNode->id] = refExpr->ref.target;
        }
        auto nonTerminal = std::static_pointer_cast<NonTerminal>(syntaxNode);
        std::vector<Ptr<AST::Node>> collect = collectChild(node.get());
        std::cout << nonTerminal->kind << "----" << collect.size() << std::endl;
        // 修改判断
        size_t i = 0;
        size_t j = 0;
        while (i < nonTerminal->children.size() && j < collect.size()) {
            if (nonTerminal->children[i]->kind == "VarPattern") {
                i++;
                continue;
            }
            if (nonTerminal->children[i]->getType() != NonTerminal::NodeType::NON_TERMINAL) {
                i++;
                continue;
            }
            this->collect(nonTerminal->children[i], collect[j]);
            i++;
            j++;
        }
    }
};

extern "C"{
uint8_t* CJ_Analyze(const char* jsonStr)
{
    std::string jsonString = R"({"type":"NonTerminal","kind":"Package","id":25,"children":[{"type":"NonTerminal","kind":"File","id":22,"children":[{"type":"NonTerminal","kind":"VarDecl","id":10,"children":[{"type":"Terminal","kind":"let","id":1},{"type":"RepeatedTerminal","kind":"Space","id":2,"repeat":1},{"type":"NonTerminal","kind":"VarPattern","id":4,"children":[{"type":"ValuedTerminal","kind":"IdentToken","id":3,"value":"a"}]},{"type":"RepeatedTerminal","kind":"Space","id":5,"repeat":1},{"type":"Terminal","kind":"=","id":6},{"type":"RepeatedTerminal","kind":"Space","id":7,"repeat":1},{"type":"ValuedTerminal","kind":"IntegerLiteralToken","id":9,"value":"1"}]},{"type":"RepeatedTerminal","kind":"NL","id":11,"repeat":1},{"type":"NonTerminal","kind":"VarDecl","id":21,"children":[{"type":"Terminal","kind":"let","id":12},{"type":"RepeatedTerminal","kind":"Space","id":13,"repeat":1},{"type":"NonTerminal","kind":"VarPattern","id":15,"children":[{"type":"ValuedTerminal","kind":"IdentToken","id":14,"value":"b"}]},{"type":"RepeatedTerminal","kind":"Space","id":16,"repeat":1},{"type":"Terminal","kind":"=","id":17},{"type":"RepeatedTerminal","kind":"Space","id":18,"repeat":1},{"type":"NonTerminal","kind":"VarPattern","id":20,"children":[{"type":"ValuedTerminal","kind":"IdentToken","id":19,"value":"a"}]}]}]}]})";
    SyntaxNodePtr root = SyntaxTreeDeserializer::deserialize(jsonString);


    std::string code = root->toString();
    printSyntaxNode(root);
    std::cout << "code: " << code << std::endl;
    DiagnosticEngine diag;
    CompilerInvocation compilerInvocation;
    CompilerInstance ci(compilerInvocation, diag);
    
    const char* path = getenv("CANGJIE_HOME");
    std::string cangjieHome(path);
    ci.invocation.globalOptions.cangjieHome = cangjieHome;
    ci.invocation.globalOptions.outputMode = FrontendOptions::OutputMode::STATIC_LIB;
    ci.cangjieHome = cangjieHome;
    ci.invocation.globalOptions.environment.cangjieHome = cangjieHome;

    // PARSER
    auto package = MakeOwned<AST::Package>();
    auto fileID = ci.GetSourceManager().AddSource("", code);
    Parser parser(fileID, code, diag, ci.GetSourceManager(), ci.invocation.globalOptions.enableAddCommentToAst,
        ci.invocation.globalOptions.compileCjd);
    parser.SetCompileOptions(ci.invocation.globalOptions);
    auto file = parser.ParseTopLevel();
    ci.GetSourceManager().AddComments(parser.GetCommentsMap());
    if (!file->package) {
        package->fullPackageName = DEFAULT_PACKAGE_NAME;
    } else {
        package->fullPackageName = file->package->packageName;
    }
    file->curPackage = package.get();
    package->files.push_back(std::move(file));
    ci.srcPkgs.push_back(std::move(package));

    // SEMA
    TypeCollector tyCollector;
    tyCollector.collect(root, ci.srcPkgs[0].get());
    std::cout << "----------before sema---------" << std::endl;
    for (const auto &pair : tyCollector.declMap) {
        std::cout << "key: " << pair.first << ", value: " << pair.second.get()
            << ", ty: " << pair.second.get()->ty->String() << std::endl;
    }
    ci.PerformImportPackage();
    ci.PerformSema();
    std::cout << "----------after sema---------" << std::endl;
    for (const auto &pair : tyCollector.declMap) {
        std::cout << "key: " << pair.first << ", value: " << pair.second.get()
            << ", ty: " << pair.second.get()->ty->String() << std::endl;
    }

    // serialize
    TypeWrite typeWriter(tyCollector.declMap, tyCollector.exprMap, tyCollector.refTarget);
    return typeWriter.ExportType();
}

void CJ_GetSemanticResult(void* fptr) {
    auto macCall = reinterpret_cast<MacroCall*>(fptr);
    std::cout << macCall->GetFullName() << std::endl;
    // auto curFile = macCall->getNode()->curFile;
    // auto pkg = curFile->curPackage;
}

}
