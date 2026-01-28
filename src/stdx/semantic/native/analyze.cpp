#include <iostream>
#include <vector>
#include <memory>

#include "cangjie/Basic/DiagnosticEmitter.h"
#include "cangjie/Basic/SourceManager.h"
#include "cangjie/Frontend/CompilerInstance.h"
#include "cangjie/Parse/Parser.h"

#include "cangjie/AST/Walker.h"

#include "cangjie/Sema/TypeChecker.h"
#include "cangjie/Sema/Desugar.h"
#include "cangjie/Macro/MacroCommon.h"

#include "semantic.h"
#include "flatbuffers/SyntaxNodeFormat_generated.h"

using namespace Cangjie;

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
uint8_t* CJ_Analyze(const uint8_t* node, size_t length)
{
    SyntaxNodePtr root = SyntaxNodeFlatBufferDeserializer::deserialize(node, length);

    std::string code = root->toString();
    // printSyntaxNode(root);
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
}

}
