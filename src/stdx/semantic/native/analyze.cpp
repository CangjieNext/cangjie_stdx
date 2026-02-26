#include <chrono>
#include <fstream>
#include <iostream>
#include <memory>
#include <vector>
#include <mutex>
#include <filesystem>

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
using namespace std::filesystem;

void FixConstructorTypes(CompilerInstance& ci, const Ptr<AST::Package>& package)
{
    if (!package) {
        return;
    }

    auto visitor = [&ci](const Ptr<AST::Node>& node) -> Cangjie::AST::VisitAction {
        if (node->astKind != ASTKind::FUNC_DECL && node->astKind != ASTKind::PRIMARY_CTOR_DECL) {
            return Cangjie::AST::VisitAction::WALK_CHILDREN;
        }

        if (node->astKind == ASTKind::FUNC_DECL) {
            auto fd = Cangjie::AST::StaticAs<ASTKind::FUNC_DECL>(node);
            if (!fd->TestAttr(Cangjie::AST::Attribute::CONSTRUCTOR)) {
                return Cangjie::AST::VisitAction::WALK_CHILDREN;
            }

            if (!Cangjie::AST::Ty::IsInitialTy(fd->ty)) {
                return Cangjie::AST::VisitAction::SKIP_CHILDREN;
            }

            Ptr<Cangjie::AST::Ty> retTy = nullptr;
            if (fd->TestAttr(Cangjie::AST::Attribute::STATIC)) {
                retTy = TypeManager::GetPrimitiveTy(Cangjie::AST::TypeKind::TYPE_UNIT);
            } else {
                if (fd->funcBody && fd->funcBody->parentClassLike) {
                    retTy = fd->funcBody->parentClassLike->ty;
                } else if (fd->funcBody && fd->funcBody->parentStruct) {
                    retTy = fd->funcBody->parentStruct->ty;
                } else if (fd->outerDecl && fd->outerDecl->IsNominalDecl()) {
                    retTy = fd->outerDecl->ty;
                }
            }

            if (retTy && !Cangjie::AST::Ty::IsInitialTy(retTy) && fd->funcBody) {
                std::vector<Ptr<Cangjie::AST::Ty>> paramTys;
                if (!fd->funcBody->paramLists.empty()) {
                    for (auto& param : fd->funcBody->paramLists[0]->params) {
                        if (param->ty && !Cangjie::AST::Ty::IsInitialTy(param->ty)) {
                            paramTys.push_back(param->ty);
                        }
                    }
                }
                fd->ty = ci.typeManager->GetFunctionTy(paramTys, retTy);
            }
        } else if (node->astKind == ASTKind::PRIMARY_CTOR_DECL) {
            auto pcd = Cangjie::AST::StaticAs<ASTKind::PRIMARY_CTOR_DECL>(node);

            if (!Cangjie::AST::Ty::IsInitialTy(pcd->ty)) {
                return Cangjie::AST::VisitAction::SKIP_CHILDREN;
            }

            Ptr<Cangjie::AST::Ty> retTy = nullptr;
            if (pcd->outerDecl && pcd->outerDecl->IsNominalDecl()) {
                retTy = pcd->outerDecl->ty;
            }

            if (retTy && !Cangjie::AST::Ty::IsInitialTy(retTy)) {
                std::vector<Ptr<Cangjie::AST::Ty>> paramTys;
                
                if (pcd->funcBody && !pcd->funcBody->paramLists.empty()) {
                    for (auto& param : pcd->funcBody->paramLists[0]->params) {
                        if (param->ty && !Cangjie::AST::Ty::IsInitialTy(param->ty)) {
                            paramTys.push_back(param->ty);
                        }
                    }
                }
                
                if (paramTys.empty() && pcd->outerDecl) {
                    auto classDecl = DynamicCast<ClassDecl*>(pcd->outerDecl);
                    if (classDecl && classDecl->body) {
                        for (auto& member : classDecl->body->decls) {
                            if (member->astKind == ASTKind::VAR_DECL || 
                                member->astKind == ASTKind::VAR_WITH_PATTERN_DECL) {
                                if (member->ty && !Cangjie::AST::Ty::IsInitialTy(member->ty)) {
                                    paramTys.push_back(member->ty);
                                }
                            }
                        }
                    }
                }
                
                pcd->ty = ci.typeManager->GetFunctionTy(paramTys, retTy);
            }
        }

        return Cangjie::AST::VisitAction::SKIP_CHILDREN;
    };

    Cangjie::AST::Walker walker(package.get(), visitor);
    walker.Walk();
}

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
static const std::string CSV_FILE_PATH = "./timeSave.csv";
static const std::string CSV_HEADER = "info,time,timestamp";
static std::mutex csvMutex;

void TimerSave(const std::string& info, double time)
{
    std::lock_guard<std::mutex> lock(csvMutex);
    try {
        bool fileExists = exists(CSV_FILE_PATH);
        std::ofstream file(CSV_FILE_PATH, std::ios::app);
        
        if (!file.is_open()) {
            std::cerr << "Failed to open CSV file: " << CSV_FILE_PATH << std::endl;
            return;
        }
        
        if (!fileExists) {
            file << CSV_HEADER << "\n";
        }
        
        auto now = system_clock::now();
        auto timestamp = duration_cast<nanoseconds>(now.time_since_epoch()).count();
        file << info << "," << time << "," << timestamp << "\n";
        file.close();
    } catch (const std::exception& e) {
        std::cerr << "Failed to write to CSV file: " << e.what() << std::endl;
    }
}

void TimerRecord(steady_clock::time_point start, const std::string& info)
{
    if (enableProfile) {
        auto duration = duration_cast<nanoseconds>(steady_clock::now() - start);
        double elapsed = duration.count() / 1000000.0;
        std::cout << info << " time: " << elapsed << " ms" << std::endl;
        TimerSave(info, elapsed);
    }
}

extern "C" {
uint8_t* CJ_Analyze(const uint8_t* node, size_t length)
{
    steady_clock::time_point deserialStart = TimerStart();
    SyntaxNodePtr root = SyntaxNodeFlatBufferDeserializer::deserialize(node, length);
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

    steady_clock::time_point semaStart = TimerStart();
    ci.PerformSema();
    TimerRecord(semaStart, "Stage 2.5: Sema");

    steady_clock::time_point reCollectStart = TimerStart();
    tyCollector.collectMainDeclDesugar(root, ci.srcPkgs[0].get());
    FixConstructorTypes(ci, ci.srcPkgs[0]);
    TimerRecord(reCollectStart, "Stage 2.6: ReCollect Type");

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
    TimerRecord(serialStart, "Stage 2.7: Serial semantic result");

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

    tyCollector.collectMainDeclDesugar(root, ci.srcPkgs[0].get());
    FixConstructorTypes(ci, ci.srcPkgs[0]);

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
