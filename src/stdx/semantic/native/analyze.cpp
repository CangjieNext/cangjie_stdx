#include <iostream>
#include <vector>
#include <memory>
#include <chrono>


#include "cangjie/Basic/DiagnosticEmitter.h"
#include "cangjie/Basic/SourceManager.h"
#include "cangjie/Frontend/CompilerInstance.h"
#include "cangjie/Parse/Parser.h"

#include "cangjie/Sema/TypeChecker.h"
#include "cangjie/Sema/Desugar.h"
#include "cangjie/Macro/MacroCommon.h"

#include "semantic.h"
#include "flatbuffers/SyntaxNodeFormat_generated.h"

using namespace Cangjie;
using namespace std::chrono;

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

extern "C"{
uint8_t* CJ_Analyze(const uint8_t* node, size_t length)
{
    steady_clock::time_point deserialStart = steady_clock::now();
    SyntaxNodePtr root = SyntaxNodeFlatBufferDeserializer::deserialize(node, length);
    steady_clock::time_point deserialEnd = steady_clock::now();
    auto duration = duration_cast<nanoseconds>(deserialEnd - deserialStart);
    std::cout << "Stage 2. Deserialize GreenTree time: " << duration.count() << " ns" << std::endl;

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

    steady_clock::time_point parseStart = steady_clock::now();
    if (root->getType() == SyntaxNode::NodeType::NON_TERMINAL) {
        auto nonTerminal = std::static_pointer_cast<NonTerminal>(root);
        for (const auto& child : nonTerminal->children) {
            std::string code = child->toString();
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
        }
    }
    ci.srcPkgs.push_back(std::move(package));
    steady_clock::time_point parseEnd = steady_clock::now();
    duration = duration_cast<nanoseconds>(parseEnd - parseStart);
    std::cout << "Stage 3. Parser time: " << duration.count() << " ns" << std::endl;


    TypeCollector tyCollector;
    tyCollector.collect(root, ci.srcPkgs[0].get());
    // std::cout << "----------before sema---------" << std::endl;
    // for (const auto &pair : tyCollector.declMap) {
    //     std::cout << "key: " << pair.second << ", value: " << pair.first.get()
    //         << ", ty: " << pair.first.get()->ty->String() << std::endl;
    // }

    ci.PerformImportPackage();
    ci.PerformSema();

    // std::cout << "----------after sema---------" << std::endl;
    // for (const auto &pair : tyCollector.declMap) {
    //     std::cout << "key: " << pair.second << ", value: " << pair.first.get()
    //         << ", ty: " << pair.first.get()->ty->String() << std::endl;
    // }

    // serialize type
    steady_clock::time_point typeStart = steady_clock::now();
    TypeWrite typeWriter(tyCollector.declMap, tyCollector.exprMap, tyCollector.refTarget);
    steady_clock::time_point typeEnd = steady_clock::now();
    duration = duration_cast<nanoseconds>(typeEnd - typeStart);
    std::cout << "Stage 4. Serialize SemanticTypeMap time: " << duration.count() << " ns" << std::endl;
    
    return typeWriter.ExportType();
}

uint8_t* CJ_Analyze_With_Path(const uint8_t* node, size_t length, const char* cjoPath)
{
    SyntaxNodePtr root = SyntaxNodeFlatBufferDeserializer::deserialize(node, length);

    DiagnosticEngine diag;
    CompilerInvocation compilerInvocation;
    CompilerInstance ci(compilerInvocation, diag);
    
    const char* path = getenv("CANGJIE_HOME");
    std::string cangjieHome(path);
    ci.invocation.globalOptions.cangjieHome = cangjieHome;
    ci.invocation.globalOptions.outputMode = FrontendOptions::OutputMode::STATIC_LIB;
    ci.cangjieHome = cangjieHome;
    ci.invocation.globalOptions.environment.cangjieHome = cangjieHome;
    std::string cjo(cjoPath);
    ci.invocation.globalOptions.importPaths.emplace_back(cjo);
    // PARSER
    auto package = MakeOwned<AST::Package>();
    if (root->getType() == SyntaxNode::NodeType::NON_TERMINAL) {
        auto nonTerminal = std::static_pointer_cast<NonTerminal>(root);
        for (const auto& child : nonTerminal->children) {
            std::string code = child->toString();
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
        }
    }
    ci.srcPkgs.push_back(std::move(package));


    TypeCollector tyCollector;
    tyCollector.collect(root, ci.srcPkgs[0].get());
    // std::cout << "----------before sema---------" << std::endl;
    // for (const auto &pair : tyCollector.declMap) {
    //     std::cout << "key: " << pair.second << ", value: " << pair.first.get()
    //         << ", ty: " << pair.first.get()->ty->String() << std::endl;
    // }

    ci.PerformImportPackage();
    ci.PerformSema();

    // std::cout << "----------after sema---------" << std::endl;
    // for (const auto &pair : tyCollector.declMap) {
    //     std::cout << "key: " << pair.second << ", value: " << pair.first.get()
    //         << ", ty: " << pair.first.get()->ty->String() << std::endl;
    // }

    // serialize
    TypeWrite typeWriter(tyCollector.declMap, tyCollector.exprMap, tyCollector.refTarget);
    
    return typeWriter.ExportType();
}

void CJ_GetSemanticResult(void* fptr) {
}

}
