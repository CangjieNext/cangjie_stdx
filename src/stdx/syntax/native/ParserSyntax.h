/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#ifndef CANGJIE_PARSER_SYNTAX_H
#define CANGJIE_PARSER_SYNTAX_H

#include "ParserSyntaxImpl.h"

using namespace Cangjie;
using namespace Cangjie::AST;

class ParserSyntax : public Parser {
public:
    /// Create Parser with string \ref input and the position of the first token. Only used in macro reparse.
    ParserSyntax(const std::string& input, DiagnosticEngine& diag, SourceManager& sm, const Position& pos = {0, 1, 1},
        bool attachComment = false);
    /// Create Parser with tokens \ref inputTokens returned by macro func. Only used in macro reparse.
    ParserSyntax(const std::vector<Token>& inputTokens, DiagnosticEngine& diag, SourceManager& sm, bool attachComment = false);
    ~ParserSyntax();

    // parser expr or decl from text or tokens
    OwnedPtr<AST::Node> ParseExprOrDecl(ScopeKind sk);

    void AttachComment(std::vector<OwnedPtr<AST::Node>>& nodes);
private:
    std::unique_ptr<class ParserSyntaxImpl> implSyntax;
};

#endif /* CANGJIE_PARSER_SYNTAX_H */