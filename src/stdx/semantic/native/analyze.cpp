#include <chrono>
#include <fstream>
#include <iostream>
#include <memory>
#include <vector>

#include "cangjie/Basic/DiagnosticEmitter.h"
#include "cangjie/Basic/SourceManager.h"
#include "cangjie/Frontend/CompilerInstance.h"
#include "cangjie/Parse/Parser.h"

#include "cangjie/Macro/MacroCommon.h"
#include "cangjie/Sema/Desugar.h"
#include "cangjie/Sema/TypeChecker.h"

#include "flatbuffers/SyntaxNodeFormat_generated.h"
#include "semantic.h"

using namespace Cangjie;
using namespace std::chrono;

void printSyntaxNode(const SyntaxNodePtr& node, int depth = 0)
{
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
        case SyntaxNode::NodeType::NON_TERMINAL: {
            auto nonTerminal = std::static_pointer_cast<NonTerminal>(node);
            std::cout << "NonTerminal: " << nonTerminal->kind << std::endl;
            // Print children
            for (const auto& child : nonTerminal->children) {
                printSyntaxNode(child, depth + 1);
            }
            break;
        }

        case SyntaxNode::NodeType::VALUED_TERMINAL: {
            auto valuedTerminal = std::static_pointer_cast<ValuedTerminal>(node);
            std::cout << "ValuedTerminal: " << valuedTerminal->kind << " = \"" << valuedTerminal->value << "\""
                      << std::endl;
            break;
        }

        case SyntaxNode::NodeType::REPEAT_TERMINAL: {
            auto repeatedTerminal = std::static_pointer_cast<RepeatedTerminal>(node);
            std::cout << "RepeatedTerminal: " << repeatedTerminal->kind << " (repeat=" << repeatedTerminal->repeat
                      << ")" << std::endl;
            break;
        }

        case SyntaxNode::NodeType::TERMINAL: {
            auto repeatedTerminal = std::static_pointer_cast<Terminal>(node);
            std::cout << "Terminal: " << repeatedTerminal->kind << std::endl;
            break;
        }
    }
}

steady_clock::time_point TimerStart()
{
    return steady_clock::now();
}

static bool enableProfile = false;
void TimerRecord(steady_clock::time_point start, const std::string& info)
{
    if (enableProfile) {
        auto duration = duration_cast<nanoseconds>(steady_clock::now() - start);
        std::cout << info << " time: " << duration.count() / 1000000.0 << " ms" << std::endl;
    }
}

extern "C" {
struct ImportedPackage {
    uint8_t* buffer;
    size_t size;
};

struct DeclTypeMap {
    uint8_t* buffer;
    size_t size;
};

struct ImportedPackageArray {
    struct ImportedPackage* importedPackageBuffer;
    struct DeclTypeMap* declTypeMapBuffer;
    size_t size;
};

uint8_t* CJ_Analyze(const uint8_t* node, size_t length, const ImportedPackageArray* importContexts)
{
    steady_clock::time_point deserialStart = TimerStart();
    SyntaxNodePtr root = SyntaxNodeFlatBufferDeserializer::deserialize(node, length);
    if (importContexts == nullptr) {
        std::cerr << "importContexts is nullptr" << std::endl;
    } else {
        for (size_t i = 0; i < importContexts->size; ++i) {
            const ImportedPackage& pkg = importContexts->importedPackageBuffer[i];
            SyntaxNodePtr context = SyntaxNodeFlatBufferDeserializer::deserialize(pkg.buffer, pkg.size);
            const DeclTypeMap& map = importContexts->declTypeMapBuffer[i];
            DeclTypeMapFlatBufferDeserializer::deserialize(map.buffer, map.size);
            
            printSyntaxNode(context);
            std::cout << context->toString() << std::endl;
        }
    }
    TimerRecord(deserialStart, "Stage 2.1: Deserial GreenTree");

    DiagnosticEngine diag;
    CompilerInvocation compilerInvocation;
    CompilerInstance ci(compilerInvocation, diag);

    const char* path = getenv("CANGJIE_HOME");
    std::string cangjieHome(path);
    ci.invocation.globalOptions.cangjieHome = cangjieHome;
    ci.invocation.globalOptions.outputMode = FrontendOptions::OutputMode::STATIC_LIB;
    ci.cangjieHome = cangjieHome;
    ci.invocation.globalOptions.environment.cangjieHome = cangjieHome;
    // off all warning
    WarningOptionMgr::UpdateFlags(std::vector<bool>(static_cast<size_t>(WarnGroup::NONE), true));

    // PARSER
    auto package = MakeOwned<AST::Package>();

    steady_clock::time_point parseStart = TimerStart();
    int counter = 1;
    if (root->getType() == SyntaxNode::NodeType::NON_TERMINAL) {
        auto nonTerminal = std::static_pointer_cast<NonTerminal>(root);
        for (const auto& child : nonTerminal->children) {
            std::string code = child->toString();
            // TODO: replace counter by the file name
            auto fileID = ci.GetSourceManager().AddSource(std::to_string(counter), code);
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
            counter++;
        }
    }
    ci.srcPkgs.push_back(std::move(package));
    TimerRecord(parseStart, "Stage 2.2: Parse");

    auto tyCollectStart = TimerStart();
    TypeCollector tyCollector;
    tyCollector.collect(root, ci.srcPkgs[0].get());
    // std::cout << "----------before sema---------" << std::endl;
    // for (const auto &pair : tyCollector.declMap) {
    //     std::cout << "key: " << pair.second << ", value: " << pair.first.get()
    //         << ", ty: " << pair.first.get()->ty->String() << std::endl;
    // }
    // for (const auto &pair : tyCollector.exprMap) {
    //     std::cout << "key: " << pair.second << ", value: " << pair.first.get()
    //         << ", ty: " << pair.first.get()->ty->String() << std::endl;
    // }
    TimerRecord(tyCollectStart, "Stage 2.3: TypeCollector");

    steady_clock::time_point importStart = TimerStart();
    ci.PerformImportPackage();
    TimerRecord(importStart, "Stage 2.4: Import");

    // buildIndex // 重排依赖信息

    steady_clock::time_point semaStart = TimerStart();
    ci.PerformSema();
    TimerRecord(semaStart, "Stage 2.5: Sema");

    // std::cout << "----------after sema---------" << std::endl;
    // for (const auto &pair : tyCollector.declMap) {
    //     std::cout << "key: " << pair.second << ", value: " << pair.first.get()
    //         << ", ty: " << pair.first.get()->ty->String() << std::endl;
    // }
    // for (const auto &pair : tyCollector.exprMap) {
    //     std::cout << "key: " << pair.second << ", value: " << pair.first.get()
    //         << ", ty: " << pair.first.get()->ty->String() << std::endl;
    // }

    // serialize type
    steady_clock::time_point serialStart = steady_clock::now();
    TypeWrite typeWriter(tyCollector.declMap, tyCollector.exprMap, tyCollector.refTarget);
    auto result = typeWriter.ExportType();
    TimerRecord(serialStart, "Stage 2.6: Serial semantic result");

    TimerRecord(deserialStart, "Stage 2: Total native");
    return result;
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

void CJ_GetSemanticResult(void* fptr)
{
}
}
