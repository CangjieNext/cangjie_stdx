#include "semantic.h"

#include "cangjie/AST/Node.h"
#include "cangjie/AST/Symbol.h"
#include "cangjie/AST/Match.h"

using namespace Cangjie;
using namespace AST;

std::vector<Ptr<AST::Node>> TypeCollector::collectChild(const Ptr<AST::Node> &node)
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
            case ASTKind::REF_EXPR: {
                auto refExpr = StaticAs<ASTKind::REF_EXPR>(node);
                for (auto& typeArg : refExpr->typeArguments) {
                    collect.emplace_back(typeArg);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::ANNOTATION: {
                auto annotation = StaticAs<ASTKind::ANNOTATION>(node);
                for (auto& arg : annotation->args) {
                    collect.emplace_back(arg);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::FUNC_ARG: {
                auto funcArg = StaticAs<ASTKind::FUNC_ARG>(node);
                if (funcArg->expr.get()) {
                    collect.emplace_back(funcArg->expr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::ARRAY_LIT: {
                auto arrayLit = StaticAs<ASTKind::ARRAY_LIT>(node);
                for (auto& element : arrayLit->children) {
                    collect.emplace_back(element);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::ASSIGN_EXPR: {
                auto assignExpr = StaticAs<ASTKind::ASSIGN_EXPR>(node);
                if (assignExpr->leftValue.get()) {
                    collect.emplace_back(assignExpr->leftValue);
                }
                if (assignExpr->rightExpr.get()) {
                    collect.emplace_back(assignExpr->rightExpr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::BLOCK: {
                auto block = StaticAs<ASTKind::BLOCK>(node);
                for (auto& n : block->body) {
                    collect.emplace_back(n);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::CALL_EXPR: {
                auto callExpr = StaticAs<ASTKind::CALL_EXPR>(node);
                if (callExpr->baseFunc.get()) {
                    collect.emplace_back(callExpr->baseFunc);
                }
                for (auto& arg : callExpr->args) {
                    collect.emplace_back(arg);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::CLASS_DECL: {
                auto classDecl = StaticAs<ASTKind::CLASS_DECL>(node);
                if (classDecl->generic.get()) {
                    collect.emplace_back(classDecl->generic);
                }
                for (auto& inheritedType : classDecl->inheritedTypes) {
                    collect.emplace_back(inheritedType);
                }
                if (classDecl->body.get()) {
                    collect.emplace_back(classDecl->body);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::FUNC_DECL: {
                auto funcDecl = StaticAs<ASTKind::FUNC_DECL>(node);
                if (funcDecl->funcBody.get()) {
                    collect.emplace_back(funcDecl->funcBody);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::FUNC_BODY: {
                auto funcBody = StaticAs<ASTKind::FUNC_BODY>(node);
                if (funcBody->generic.get()) {
                    collect.emplace_back(funcBody->generic);
                }
                for (auto& paramList : funcBody->paramLists) {
                    collect.emplace_back(paramList);
                }
                if (funcBody->retType.get()) {
                    collect.emplace_back(funcBody->retType);
                }
                if (funcBody->body.get()) {
                    collect.emplace_back(funcBody->body);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::FUNC_PARAM_LIST: {
                auto funcParamList = StaticAs<ASTKind::FUNC_PARAM_LIST>(node);
                for (auto& param : funcParamList->params) {
                    collect.emplace_back(param);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::FUNC_PARAM: {
                auto funcParam = StaticAs<ASTKind::FUNC_PARAM>(node);
                if (funcParam->type.get()) {
                    collect.emplace_back(funcParam->type);
                }
                if (funcParam->assignment.get()) {
                    collect.emplace_back(funcParam->assignment);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::IF_EXPR: {
                auto ifExpr = StaticAs<ASTKind::IF_EXPR>(node);
                if (ifExpr->condExpr.get()) {
                    collect.emplace_back(ifExpr->condExpr);
                }
                if (ifExpr->thenBody.get()) {
                    collect.emplace_back(ifExpr->thenBody);
                }
                if (ifExpr->elseBody.get()) {
                    collect.emplace_back(ifExpr->elseBody);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::MATCH_EXPR: {
                auto matchExpr = StaticAs<ASTKind::MATCH_EXPR>(node);
                if (matchExpr->selector.get()) {
                    collect.emplace_back(matchExpr->selector);
                }
                for (auto& mCase : matchExpr->matchCases) {
                    collect.emplace_back(mCase);
                }
                for (auto& mCaseOther : matchExpr->matchCaseOthers) {
                    collect.emplace_back(mCaseOther);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::MEMBER_ACCESS: {
                auto memberAccess = StaticAs<ASTKind::MEMBER_ACCESS>(node);
                if (memberAccess->baseExpr.get()) {
                    collect.emplace_back(memberAccess->baseExpr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::RETURN_EXPR: {
                auto returnExpr = StaticAs<ASTKind::RETURN_EXPR>(node);
                if (returnExpr->expr.get()) {
                    collect.emplace_back(returnExpr->expr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::SUBSCRIPT_EXPR: {
                auto subscriptExpr = StaticAs<ASTKind::SUBSCRIPT_EXPR>(node);
                if (subscriptExpr->baseExpr.get()) {
                    collect.emplace_back(subscriptExpr->baseExpr);
                }
                for (auto& indexExpr : subscriptExpr->indexExprs) {
                    collect.emplace_back(indexExpr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::THROW_EXPR: {
                auto throwExpr = StaticAs<ASTKind::THROW_EXPR>(node);
                if (throwExpr->expr.get()) {
                    collect.emplace_back(throwExpr->expr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::TRY_EXPR: {
                auto tryExpr = StaticAs<ASTKind::TRY_EXPR>(node);
                for (auto& resourceSpec : tryExpr->resourceSpec) {
                    collect.emplace_back(resourceSpec);
                }
                if (tryExpr->tryBlock.get()) {
                    collect.emplace_back(tryExpr->tryBlock);
                }
                for (auto& catchPattern : tryExpr->catchPatterns) {
                    collect.emplace_back(catchPattern);
                }
                for (auto& catchBlock : tryExpr->catchBlocks) {
                    collect.emplace_back(catchBlock);
                }
                if (tryExpr->finallyBlock.get()) {
                    collect.emplace_back(tryExpr->finallyBlock);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::UNARY_EXPR: {
                auto unaryExpr = StaticAs<ASTKind::UNARY_EXPR>(node);
                if (unaryExpr->expr.get()) {
                    collect.emplace_back(unaryExpr->expr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::WHILE_EXPR: {
                auto whileExpr = StaticAs<ASTKind::WHILE_EXPR>(node);
                if (whileExpr->condExpr.get()) {
                    collect.emplace_back(whileExpr->condExpr);
                }
                if (whileExpr->body.get()) {
                    collect.emplace_back(whileExpr->body);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::DO_WHILE_EXPR: {
                auto doWhileExpr = StaticAs<ASTKind::DO_WHILE_EXPR>(node);
                if (doWhileExpr->body.get()) {
                    collect.emplace_back(doWhileExpr->body);
                }
                if (doWhileExpr->condExpr.get()) {
                    collect.emplace_back(doWhileExpr->condExpr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::FOR_IN_EXPR: {
                auto forInExpr = StaticAs<ASTKind::FOR_IN_EXPR>(node);
                if (forInExpr->pattern.get()) {
                    collect.emplace_back(forInExpr->pattern);
                }
                if (forInExpr->inExpression.get()) {
                    collect.emplace_back(forInExpr->inExpression);
                }
                if (forInExpr->patternGuard.get()) {
                    collect.emplace_back(forInExpr->patternGuard);
                }
                if (forInExpr->body.get()) {
                    collect.emplace_back(forInExpr->body);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::ENUM_DECL: {
                auto enumDecl = StaticAs<ASTKind::ENUM_DECL>(node);
                if (enumDecl->generic.get()) {
                    collect.emplace_back(enumDecl->generic);
                }
                for (auto& inheritedType : enumDecl->inheritedTypes) {
                    collect.emplace_back(inheritedType);
                }
                for (auto& constructor : enumDecl->constructors) {
                    collect.emplace_back(constructor);
                }
                for (auto& member : enumDecl->members) {
                    collect.emplace_back(member);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::INTERFACE_DECL: {
                auto interfaceDecl = StaticAs<ASTKind::INTERFACE_DECL>(node);
                if (interfaceDecl->generic.get()) {
                    collect.emplace_back(interfaceDecl->generic);
                }
                for (auto& inheritedType : interfaceDecl->inheritedTypes) {
                    collect.emplace_back(inheritedType);
                }
                if (interfaceDecl->body.get()) {
                    collect.emplace_back(interfaceDecl->body);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::STRUCT_DECL: {
                auto structDecl = StaticAs<ASTKind::STRUCT_DECL>(node);
                if (structDecl->generic.get()) {
                    collect.emplace_back(structDecl->generic);
                }
                for (auto& inheritedType : structDecl->inheritedTypes) {
                    collect.emplace_back(inheritedType);
                }
                if (structDecl->body.get()) {
                    collect.emplace_back(structDecl->body);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::EXTEND_DECL: {
                auto extendDecl = StaticAs<ASTKind::EXTEND_DECL>(node);
                if (extendDecl->extendedType.get()) {
                    collect.emplace_back(extendDecl->extendedType);
                }
                for (auto& inheritedType : extendDecl->inheritedTypes) {
                    collect.emplace_back(inheritedType);
                }
                if (extendDecl->generic.get()) {
                    collect.emplace_back(extendDecl->generic);
                }
                for (auto& member : extendDecl->members) {
                    collect.emplace_back(member);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::STRUCT_BODY: {
                auto structBody = StaticAs<ASTKind::STRUCT_BODY>(node);
                for (auto& decl : structBody->decls) {
                    collect.emplace_back(decl);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::CLASS_BODY: {
                auto classBody = StaticAs<ASTKind::CLASS_BODY>(node);
                for (auto& decl : classBody->decls) {
                    collect.emplace_back(decl);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::INTERFACE_BODY: {
                auto interfaceBody = StaticAs<ASTKind::INTERFACE_BODY>(node);
                for (auto& decl : interfaceBody->decls) {
                    collect.emplace_back(decl);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::LAMBDA_EXPR: {
                auto lambdaExpr = StaticAs<ASTKind::LAMBDA_EXPR>(node);
                if (lambdaExpr->funcBody.get()) {
                    collect.emplace_back(lambdaExpr->funcBody);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::TRAIL_CLOSURE_EXPR: {
                auto trailClosureExpr = StaticAs<ASTKind::TRAIL_CLOSURE_EXPR>(node);
                if (trailClosureExpr->expr.get()) {
                    collect.emplace_back(trailClosureExpr->expr);
                }
                if (trailClosureExpr->lambda.get()) {
                    collect.emplace_back(trailClosureExpr->lambda);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::RANGE_EXPR: {
                auto rangeExpr = StaticAs<ASTKind::RANGE_EXPR>(node);
                if (rangeExpr->startExpr.get()) {
                    collect.emplace_back(rangeExpr->startExpr);
                }
                if (rangeExpr->stopExpr.get()) {
                    collect.emplace_back(rangeExpr->stopExpr);
                }
                if (rangeExpr->stepExpr.get()) {
                    collect.emplace_back(rangeExpr->stepExpr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::STR_INTERPOLATION_EXPR: {
                auto strInterpolationExpr = StaticAs<ASTKind::STR_INTERPOLATION_EXPR>(node);
                for (auto& strPartExpr : strInterpolationExpr->strPartExprs) {
                    collect.emplace_back(strPartExpr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::INTERPOLATION_EXPR: {
                auto interpolationExpr = StaticAs<ASTKind::INTERPOLATION_EXPR>(node);
                if (interpolationExpr->block.get()) {
                    collect.emplace_back(interpolationExpr->block);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::TUPLE_LIT: {
                auto tupleLit = StaticAs<ASTKind::TUPLE_LIT>(node);
                for (auto& child : tupleLit->children) {
                    collect.emplace_back(child);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::TYPE_CONV_EXPR: {
                auto typeConvExpr = StaticAs<ASTKind::TYPE_CONV_EXPR>(node);
                if (typeConvExpr->type.get()) {
                    collect.emplace_back(typeConvExpr->type);
                }
                if (typeConvExpr->expr.get()) {
                    collect.emplace_back(typeConvExpr->expr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::LIT_CONST_EXPR: {
                auto litConstExpr = StaticAs<ASTKind::LIT_CONST_EXPR>(node);
                if (litConstExpr->ref.get()) {
                    collect.emplace_back(litConstExpr->ref);
                }
                if (litConstExpr->siExpr.get()) {
                    collect.emplace_back(litConstExpr->siExpr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::MACRO_DECL: {
                auto macroDecl = StaticAs<ASTKind::MACRO_DECL>(node);
                if (macroDecl->funcBody.get()) {
                    collect.emplace_back(macroDecl->funcBody);
                }
                if (macroDecl->desugarDecl.get()) {
                    collect.emplace_back(macroDecl->desugarDecl);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::MACRO_EXPAND_DECL: {
                auto macroExpandDecl = StaticAs<ASTKind::MACRO_EXPAND_DECL>(node);
                if (macroExpandDecl->invocation.decl.get()) {
                    collect.emplace_back(macroExpandDecl->invocation.decl);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::MACRO_EXPAND_EXPR: {
                auto macroExpandExpr = StaticAs<ASTKind::MACRO_EXPAND_EXPR>(node);
                if (macroExpandExpr->invocation.decl.get()) {
                    collect.emplace_back(macroExpandExpr->invocation.decl);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::MACRO_EXPAND_PARAM: {
                auto macroExpandParam = StaticAs<ASTKind::MACRO_EXPAND_PARAM>(node);
                if (macroExpandParam->invocation.decl.get()) {
                    collect.emplace_back(macroExpandParam->invocation.decl);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::MAIN_DECL: {
                auto mainDecl = StaticAs<ASTKind::MAIN_DECL>(node);
                if (mainDecl->funcBody.get()) {
                    collect.emplace_back(mainDecl->funcBody);
                }
                if (mainDecl->desugarDecl.get()) {
                    collect.emplace_back(mainDecl->desugarDecl);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::MATCH_CASE: {
                auto matchCase = StaticAs<ASTKind::MATCH_CASE>(node);
                for (auto& pattern : matchCase->patterns) {
                    collect.emplace_back(pattern);
                }
                if (matchCase->patternGuard.get()) {
                    collect.emplace_back(matchCase->patternGuard);
                }
                if (matchCase->exprOrDecls.get()) {
                    collect.emplace_back(matchCase->exprOrDecls);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::MODIFIER: {
                // Modifier 没有子节点
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::PAREN_EXPR: {
                auto parenExpr = StaticAs<ASTKind::PAREN_EXPR>(node);
                if (parenExpr->expr.get()) {
                    collect.emplace_back(parenExpr->expr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::PRIMARY_CTOR_DECL: {
                auto primaryCtorDecl = StaticAs<ASTKind::PRIMARY_CTOR_DECL>(node);
                if (primaryCtorDecl->funcBody.get()) {
                    collect.emplace_back(primaryCtorDecl->funcBody);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::PROP_DECL: {
                auto propDecl = StaticAs<ASTKind::PROP_DECL>(node);
                if (propDecl->type.get()) {
                    collect.emplace_back(propDecl->type);
                }
                for (auto& getter : propDecl->getters) {
                    collect.emplace_back(getter);
                }
                for (auto& setter : propDecl->setters) {
                    collect.emplace_back(setter);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::VAR_WITH_PATTERN_DECL: {
                auto varWithPatternDecl = StaticAs<ASTKind::VAR_WITH_PATTERN_DECL>(node);
                if (varWithPatternDecl->irrefutablePattern.get()) {
                    collect.emplace_back(varWithPatternDecl->irrefutablePattern);
                }
                if (varWithPatternDecl->type.get()) {
                    collect.emplace_back(varWithPatternDecl->type);
                }
                if (varWithPatternDecl->initializer.get()) {
                    collect.emplace_back(varWithPatternDecl->initializer);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::TYPE_ALIAS_DECL: {
                auto typeAliasDecl = StaticAs<ASTKind::TYPE_ALIAS_DECL>(node);
                if (typeAliasDecl->generic.get()) {
                    collect.emplace_back(typeAliasDecl->generic);
                }
                if (typeAliasDecl->type.get()) {
                    collect.emplace_back(typeAliasDecl->type);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::LET_PATTERN_DESTRUCTOR: {
                auto letPatternDestructor = StaticAs<ASTKind::LET_PATTERN_DESTRUCTOR>(node);
                for (auto& pattern : letPatternDestructor->patterns) {
                    collect.emplace_back(pattern);
                }
                if (letPatternDestructor->initializer.get()) {
                    collect.emplace_back(letPatternDestructor->initializer);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::MATCH_CASE_OTHER: {
                auto matchCaseOther = StaticAs<ASTKind::MATCH_CASE_OTHER>(node);
                if (matchCaseOther->matchExpr.get()) {
                    collect.emplace_back(matchCaseOther->matchExpr);
                }
                if (matchCaseOther->exprOrDecls.get()) {
                    collect.emplace_back(matchCaseOther->exprOrDecls);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::PERFORM_EXPR: {
                auto performExpr = StaticAs<ASTKind::PERFORM_EXPR>(node);
                if (performExpr->expr.get()) {
                    collect.emplace_back(performExpr->expr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::RESUME_EXPR: {
                auto resumeExpr = StaticAs<ASTKind::RESUME_EXPR>(node);
                if (resumeExpr->withExpr.get()) {
                    collect.emplace_back(resumeExpr->withExpr);
                }
                if (resumeExpr->throwingExpr.get()) {
                    collect.emplace_back(resumeExpr->throwingExpr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::INC_OR_DEC_EXPR: {
                auto incOrDecExpr = StaticAs<ASTKind::INC_OR_DEC_EXPR>(node);
                if (incOrDecExpr->expr.get()) {
                    collect.emplace_back(incOrDecExpr->expr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::POINTER_EXPR: {
                auto pointerExpr = StaticAs<ASTKind::POINTER_EXPR>(node);
                if (pointerExpr->type.get()) {
                    collect.emplace_back(pointerExpr->type);
                }
                if (pointerExpr->arg.get()) {
                    collect.emplace_back(pointerExpr->arg);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::TYPE_PATTERN: {
                auto typePattern = StaticAs<ASTKind::TYPE_PATTERN>(node);
                if (typePattern->type.get()) {
                    collect.emplace_back(typePattern->type);
                }
                if (typePattern->pattern.get()) {
                    collect.emplace_back(typePattern->pattern);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::ARRAY_EXPR: {
                auto arrayExpr = StaticAs<ASTKind::ARRAY_EXPR>(node);
                if (arrayExpr->type.get()) {
                    collect.emplace_back(arrayExpr->type);
                }
                for (auto& arg : arrayExpr->args) {
                    collect.emplace_back(arg);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::IF_AVAILABLE_EXPR: {
                auto ifAvailableExpr = StaticCast<IfAvailableExpr>(node);
                if (ifAvailableExpr->GetArg()) {
                    collect.emplace_back(ifAvailableExpr->GetArg());
                }
                if (ifAvailableExpr->GetLambda1()) {
                    collect.emplace_back(ifAvailableExpr->GetLambda1());
                }
                if (ifAvailableExpr->GetLambda2()) {
                    collect.emplace_back(ifAvailableExpr->GetLambda2());
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::REF_TYPE: {
                auto refType = StaticAs<ASTKind::REF_TYPE>(node);
                for (auto& typeArg : refType->typeArguments) {
                    collect.emplace_back(typeArg);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::QUALIFIED_TYPE: {
                auto qualifiedType = StaticAs<ASTKind::QUALIFIED_TYPE>(node);
                if (qualifiedType->baseType.get()) {
                    collect.emplace_back(qualifiedType->baseType);
                }
                for (auto& typeArg : qualifiedType->typeArguments) {
                    collect.emplace_back(typeArg);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::OPTION_TYPE: {
                auto optionType = StaticAs<ASTKind::OPTION_TYPE>(node);
                if (optionType->desugarType.get()) {
                    collect.emplace_back(optionType->desugarType);
                }
                if (optionType->componentType.get()) {
                    collect.emplace_back(optionType->componentType);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::CONSTANT_TYPE: {
                auto constantType = StaticAs<ASTKind::CONSTANT_TYPE>(node);
                if (constantType->constantExpr.get()) {
                    collect.emplace_back(constantType->constantExpr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::VARRAY_TYPE: {
                auto varrayType = StaticAs<ASTKind::VARRAY_TYPE>(node);
                if (varrayType->typeArgument.get()) {
                    collect.emplace_back(varrayType->typeArgument);
                }
                if (varrayType->constantType.get()) {
                    collect.emplace_back(varrayType->constantType);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::PAREN_TYPE: {
                auto parenType = StaticAs<ASTKind::PAREN_TYPE>(node);
                if (parenType->type.get()) {
                    collect.emplace_back(parenType->type);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::FUNC_TYPE: {
                auto funcType = StaticAs<ASTKind::FUNC_TYPE>(node);
                for (auto& paramType : funcType->paramTypes) {
                    collect.emplace_back(paramType);
                }
                if (funcType->retType.get()) {
                    collect.emplace_back(funcType->retType);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::TUPLE_TYPE: {
                auto tupleType = StaticAs<ASTKind::TUPLE_TYPE>(node);
                for (auto& fieldType : tupleType->fieldTypes) {
                    collect.emplace_back(fieldType);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::GENERIC_CONSTRAINT: {
                auto genericConstraint = StaticAs<ASTKind::GENERIC_CONSTRAINT>(node);
                if (genericConstraint->type.get()) {
                    collect.emplace_back(genericConstraint->type);
                }
                for (auto& upperBound : genericConstraint->upperBounds) {
                    collect.emplace_back(upperBound);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::CONST_PATTERN: {
                auto constPattern = StaticAs<ASTKind::CONST_PATTERN>(node);
                if (constPattern->literal.get()) {
                    collect.emplace_back(constPattern->literal);
                }
                if (constPattern->operatorCallExpr.get()) {
                    collect.emplace_back(constPattern->operatorCallExpr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::VAR_PATTERN: {
                auto varPattern = StaticAs<ASTKind::VAR_PATTERN>(node);
                if (varPattern->varDecl.get()) {
                    collect.emplace_back(varPattern->varDecl);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::TUPLE_PATTERN: {
                auto tuplePattern = StaticAs<ASTKind::TUPLE_PATTERN>(node);
                for (auto& pattern : tuplePattern->patterns) {
                    collect.emplace_back(pattern);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::ENUM_PATTERN: {
                auto enumPattern = StaticAs<ASTKind::ENUM_PATTERN>(node);
                if (enumPattern->constructor.get()) {
                    collect.emplace_back(enumPattern->constructor);
                }
                for (auto& pattern : enumPattern->patterns) {
                    collect.emplace_back(pattern);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::VAR_OR_ENUM_PATTERN: {
                auto varOrEnumPattern = StaticAs<ASTKind::VAR_OR_ENUM_PATTERN>(node);
                if (varOrEnumPattern->pattern.get()) {
                    collect.emplace_back(varOrEnumPattern->pattern);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::EXCEPT_TYPE_PATTERN: {
                auto& exceptTypePattern = *StaticCast<ExceptTypePattern*>(node);
                if (exceptTypePattern.pattern.get()) {
                    collect.emplace_back(exceptTypePattern.pattern);
                }
                for (auto& type : exceptTypePattern.types) {
                    collect.emplace_back(type);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::COMMAND_TYPE_PATTERN: {
                auto& commandTypePattern = *StaticCast<CommandTypePattern*>(node);
                if (commandTypePattern.pattern.get()) {
                    collect.emplace_back(commandTypePattern.pattern);
                }
                for (auto& type : commandTypePattern.types) {
                    collect.emplace_back(type);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::SPAWN_EXPR: {
                auto spawnExpr = StaticAs<ASTKind::SPAWN_EXPR>(node);
                if (spawnExpr->arg.get()) {
                    collect.emplace_back(spawnExpr->arg);
                }
                if (spawnExpr->task.get()) {
                    collect.emplace_back(spawnExpr->task);
                }
                if (spawnExpr->futureObj.get()) {
                    collect.emplace_back(spawnExpr->futureObj);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::SYNCHRONIZED_EXPR: {
                auto synchronizedExpr = StaticAs<ASTKind::SYNCHRONIZED_EXPR>(node);
                if (synchronizedExpr->mutex.get()) {
                    collect.emplace_back(synchronizedExpr->mutex);
                }
                if (!synchronizedExpr->desugarExpr && synchronizedExpr->body.get()) {
                    collect.emplace_back(synchronizedExpr->body);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::QUOTE_EXPR: {
                auto quoteExpr = StaticAs<ASTKind::QUOTE_EXPR>(node);
                for (auto& expr : quoteExpr->exprs) {
                    collect.emplace_back(expr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::IS_EXPR: {
                auto isExpr = StaticAs<ASTKind::IS_EXPR>(node);
                if (isExpr->leftExpr.get()) {
                    collect.emplace_back(isExpr->leftExpr);
                }
                if (isExpr->isType.get()) {
                    collect.emplace_back(isExpr->isType);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::AS_EXPR: {
                auto asExpr = StaticAs<ASTKind::AS_EXPR>(node);
                if (asExpr->leftExpr.get()) {
                    collect.emplace_back(asExpr->leftExpr);
                }
                if (asExpr->asType.get()) {
                    collect.emplace_back(asExpr->asType);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::BUILTIN_DECL: {
                auto builtinDecl = StaticAs<ASTKind::BUILTIN_DECL>(node);
                if (builtinDecl->generic.get()) {
                    collect.emplace_back(builtinDecl->generic);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::GENERIC: {
                auto generic = StaticAs<ASTKind::GENERIC>(node);
                for (auto& typeParam : generic->typeParameters) {
                    collect.emplace_back(typeParam);
                }
                for (auto& constraint : generic->genericConstraints) {
                    collect.emplace_back(constraint);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::OPTIONAL_CHAIN_EXPR: {
                auto optionalChainExpr = StaticAs<ASTKind::OPTIONAL_CHAIN_EXPR>(node);
                if (!optionalChainExpr->desugarExpr && optionalChainExpr->expr.get()) {
                    collect.emplace_back(optionalChainExpr->expr);
                }
                return VisitAction::SKIP_CHILDREN;
            }
            case ASTKind::OPTIONAL_EXPR: {
                auto optionalExpr = StaticAs<ASTKind::OPTIONAL_EXPR>(node);
                if (optionalExpr->baseExpr.get()) {
                    collect.emplace_back(optionalExpr->baseExpr);
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

void TypeCollector::collect(const SyntaxNodePtr &syntaxNode, const Ptr<AST::Node> &node){
    if (syntaxNode->getType() != NonTerminal::NodeType::NON_TERMINAL) {
        return;
    }
    if (syntaxNode->isDecl()) {
        declMap[node.get()] = syntaxNode->id;
    }
    if (syntaxNode->isSymbolRef() && node->astKind == ASTKind::REF_EXPR) {
        exprMap[node.get()] = syntaxNode->id;
        auto refExpr = StaticAs<ASTKind::REF_EXPR>(node);
        refTarget[syntaxNode->id] = refExpr;
    }
    if (syntaxNode->isMemberAccess() && node->astKind == ASTKind::MEMBER_ACCESS) {
        exprMap[node.get()] = syntaxNode->id;
        auto nonTerminal = std::static_pointer_cast<NonTerminal>(syntaxNode);
        auto symbolNode = nonTerminal->findFirstSymbolNode();
        auto memberAccess = StaticAs<ASTKind::MEMBER_ACCESS>(node);
        refTarget[symbolNode->id] = memberAccess;
        return;
    }

    auto nonTerminal = std::static_pointer_cast<NonTerminal>(syntaxNode);
    std::vector<Ptr<AST::Node>> collect = collectChild(node.get());
    
    size_t i = 0;
    size_t j = 0;
    
    while (i < nonTerminal->children.size() && j < collect.size()) {
        if (nonTerminal->children[i]->kind == "VarPattern" || nonTerminal->children[i]->kind == "ImportSpec"
        || nonTerminal->children[i]->kind == "PackageSpec") {
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