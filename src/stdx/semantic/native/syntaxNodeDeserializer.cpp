#include "semantic.h"

std::shared_ptr<SyntaxNode> SyntaxNodeFlatBufferDeserializer::deserialize(
    const uint8_t* buffer, size_t length) {
    auto root = SyntaxNodeFormat::GetNonTerminal(buffer);
    return deserializeNonTerminal(root);
}

std::shared_ptr<SyntaxNode> SyntaxNodeFlatBufferDeserializer::deserializeNonTerminal(
    const SyntaxNodeFormat::NonTerminal* nonTerm) {

    if (!nonTerm) {
        return nullptr;
    }

    auto node = std::make_shared<NonTerminal>();
    node->id = nonTerm->id();

    node->kind = getNodeKindName(nonTerm->kind());

    // deserialize children
    if (nonTerm->children() && nonTerm->children_type()) {
        auto children = nonTerm->children();
        auto childrenType = nonTerm->children_type();
        for (size_t i = 0; i < children->size(); ++i) {

            auto childTypeValue = childrenType->Get(i);
            auto childType = SyntaxNodeFormat::EnumValuesSyntaxNodeImpl()[static_cast<uint8_t>(childTypeValue)];

            auto childNode = getChildNodeByType(children->Get(i), childType);
            if (childNode) {
                node->children.push_back(childNode);
            }
        }
    }

    return node;
}

std::shared_ptr<SyntaxNode> SyntaxNodeFlatBufferDeserializer::deserializeTerminal(
    const SyntaxNodeFormat::Terminal* term) {

    if (!term) {
        return nullptr;
    }

    auto node = std::make_shared<Terminal>();
    node->id = term->id();
    node->kind = getNodeKindName(term->kind());

    return node;
}

std::shared_ptr<SyntaxNode> SyntaxNodeFlatBufferDeserializer::deserializeValuedTerminal(
    const SyntaxNodeFormat::ValuedTerminal* valTerm) {

    if (!valTerm) {
        return nullptr;
    }

    auto node = std::make_shared<ValuedTerminal>();
    node->id = valTerm->id();
    node->kind = getNodeKindName(valTerm->kind());

    if (valTerm->value()) {
        node->value = valTerm->value()->str();
    }

    return node;
}

std::shared_ptr<SyntaxNode> SyntaxNodeFlatBufferDeserializer::deserializeRepeatedTerminal(
    const SyntaxNodeFormat::RepeatedTerminal* repTerm) {

    if (!repTerm) {
        return nullptr;
    }

    auto node = std::make_shared<RepeatedTerminal>();
    node->id = repTerm->id();
    node->kind = getNodeKindName(repTerm->kind());
    node->repeat = repTerm->repeat();

    return node;
}

std::shared_ptr<SyntaxNode> SyntaxNodeFlatBufferDeserializer::getChildNodeByType(
    const void* offset, SyntaxNodeFormat::SyntaxNodeImpl type) {

    switch (type) {
        case SyntaxNodeFormat::SyntaxNodeImpl_NonTerminal:
            return deserializeNonTerminal(reinterpret_cast<const SyntaxNodeFormat::NonTerminal*>(offset));
        case SyntaxNodeFormat::SyntaxNodeImpl_Terminal:
            return deserializeTerminal(reinterpret_cast<const SyntaxNodeFormat::Terminal*>(offset));
        case SyntaxNodeFormat::SyntaxNodeImpl_ValuedTerminal:
            return deserializeValuedTerminal(reinterpret_cast<const SyntaxNodeFormat::ValuedTerminal*>(offset));
        case SyntaxNodeFormat::SyntaxNodeImpl_RepeatedTerminal:
            return deserializeRepeatedTerminal(reinterpret_cast<const SyntaxNodeFormat::RepeatedTerminal*>(offset));
        default:
            return nullptr;
    }
}

std::string SyntaxNodeFlatBufferDeserializer::getNodeKindName(SyntaxNodeFormat::NodeImplKind kind) {
    switch (kind) {
        case SyntaxNodeFormat::NodeImplKind_Package:
            return "Package";
        case SyntaxNodeFormat::NodeImplKind_File:
            return "File";
        case SyntaxNodeFormat::NodeImplKind_VarDecl:
            return "VarDecl";
        case SyntaxNodeFormat::NodeImplKind_FuncDecl:
            return "FuncDecl";
        case SyntaxNodeFormat::NodeImplKind_BinaryExpr:
            return "BinaryExpr";
        case SyntaxNodeFormat::NodeImplKind_RefExpr:
            return "SymbolRef";
        case SyntaxNodeFormat::NodeImplKind_VarBindingPattern:
            return "VarPattern";
        case SyntaxNodeFormat::NodeImplKind_IdentToken:
            return "IdentToken";
        case SyntaxNodeFormat::NodeImplKind_IntegerLiteralToken:
            return "IntegerLiteralToken";
        case SyntaxNodeFormat::NodeImplKind_SpaceToken:
            return "Space";
        case SyntaxNodeFormat::NodeImplKind_NewlineToken:
            return "NewlineToken";
        case SyntaxNodeFormat::NodeImplKind_LetToken:
            return "let";
        case SyntaxNodeFormat::NodeImplKind_AssignToken:
            return "=";
        case SyntaxNodeFormat::NodeImplKind_AddToken:
            return "+";
        case SyntaxNodeFormat::NodeImplKind_FeaturesDirective:
            return "FeaturesDirective";
        case SyntaxNodeFormat::NodeImplKind_FeaturesSet:
            return "FeaturesSet";
        case SyntaxNodeFormat::NodeImplKind_FeatureId:
            return "FeatureId";
        case SyntaxNodeFormat::NodeImplKind_PackageSpec:
            return "PackageSpec";
        case SyntaxNodeFormat::NodeImplKind_PackagePrefixes:
            return "PackagePrefixes";
        case SyntaxNodeFormat::NodeImplKind_CatchPattern:
            return "CatchPattern";
        case SyntaxNodeFormat::NodeImplKind_Argument:
            return "Argument";
        case SyntaxNodeFormat::NodeImplKind_Annotation:
            return "Annotation";
        case SyntaxNodeFormat::NodeImplKind_AnnotationList:
            return "AnnotationList";
        case SyntaxNodeFormat::NodeImplKind_TypeArguments:
            return "TypeArguments";
        case SyntaxNodeFormat::NodeImplKind_ModifierList:
            return "ModifierList";
        case SyntaxNodeFormat::NodeImplKind_ParameterList:
            return "ParameterList";
        case SyntaxNodeFormat::NodeImplKind_GenericConstraints:
            return "GenericConstraints";
        case SyntaxNodeFormat::NodeImplKind_GenericConstraint:
            return "GenericConstraint";
        case SyntaxNodeFormat::NodeImplKind_MatchCase:
            return "MatchCase";
        case SyntaxNodeFormat::NodeImplKind_MatchCaseBody:
            return "MatchCaseBody";
        case SyntaxNodeFormat::NodeImplKind_Pattern:
            return "Pattern";
        case SyntaxNodeFormat::NodeImplKind_Body:
            return "Body";
        case SyntaxNodeFormat::NodeImplKind_DisjunctionCondition:
            return "DisjunctionCondition";
        case SyntaxNodeFormat::NodeImplKind_ConjunctionCondition:
            return "ConjunctionCondition";
        case SyntaxNodeFormat::NodeImplKind_ParenCondition:
            return "ParenCondition";
        case SyntaxNodeFormat::NodeImplKind_LetPattern:
            return "LetPattern";
        case SyntaxNodeFormat::NodeImplKind_AtomicCondition:
            return "AtomicCondition";
        case SyntaxNodeFormat::NodeImplKind_TokenList:
            return "TokenList";
        case SyntaxNodeFormat::NodeImplKind_Comment:
            return "Comment";
        case SyntaxNodeFormat::NodeImplKind_CommentGroup:
            return "CommentGroup";
        case SyntaxNodeFormat::NodeImplKind_CommentGroupList:
            return "CommentGroupList";
        case SyntaxNodeFormat::NodeImplKind_Modifier:
            return "Modifier";
        case SyntaxNodeFormat::NodeImplKind_GenericParam:
            return "GenericParam";
        case SyntaxNodeFormat::NodeImplKind_ImportSpec:
            return "ImportSpec";
        case SyntaxNodeFormat::NodeImplKind_ImportAlias:
            return "ImportAlias";
        case SyntaxNodeFormat::NodeImplKind_ImportAll:
            return "ImportAll";
        case SyntaxNodeFormat::NodeImplKind_ImportMulti:
            return "ImportMulti";
        case SyntaxNodeFormat::NodeImplKind_ImportSingle:
            return "ImportSingle";
        case SyntaxNodeFormat::NodeImplKind_PrimitiveType:
            return "PrimitiveType";
        case SyntaxNodeFormat::NodeImplKind_RefType:
            return "RefType";
        case SyntaxNodeFormat::NodeImplKind_FuncType:
            return "FuncType";
        case SyntaxNodeFormat::NodeImplKind_ThisType:
            return "ThisType";
        case SyntaxNodeFormat::NodeImplKind_ParenType:
            return "ParenType";
        case SyntaxNodeFormat::NodeImplKind_QualifiedType:
            return "QualifiedType";
        case SyntaxNodeFormat::NodeImplKind_OptionType:
            return "OptionType";
        case SyntaxNodeFormat::NodeImplKind_OptionalType:
            return "OptionalType";
        case SyntaxNodeFormat::NodeImplKind_VArrayType:
            return "VArrayType";
        case SyntaxNodeFormat::NodeImplKind_TupleType:
            return "TupleType";
        case SyntaxNodeFormat::NodeImplKind_CompositeType:
            return "CompositeType";
        case SyntaxNodeFormat::NodeImplKind_MainDecl:
            return "main";
        case SyntaxNodeFormat::NodeImplKind_FuncParam:
            return "FuncParam";
        case SyntaxNodeFormat::NodeImplKind_LambdaParam:
            return "LambdaParam";
        case SyntaxNodeFormat::NodeImplKind_Block:
            return "Block";
        case SyntaxNodeFormat::NodeImplKind_TypeAlias:
            return "TypeAlias";
        case SyntaxNodeFormat::NodeImplKind_ClassDecl:
            return "ClassDecl";
        case SyntaxNodeFormat::NodeImplKind_PropGetterOrSetter:
            return "PropGetterOrSetter";
        case SyntaxNodeFormat::NodeImplKind_PropDecl:
            return "PropDecl";
        case SyntaxNodeFormat::NodeImplKind_StaticInit:
            return "StaticInit";
        case SyntaxNodeFormat::NodeImplKind_StructDecl:
            return "StructDecl";
        case SyntaxNodeFormat::NodeImplKind_InterfaceDecl:
            return "InterfaceDecl";
        case SyntaxNodeFormat::NodeImplKind_ExtendDecl:
            return "ExtendDecl";
        case SyntaxNodeFormat::NodeImplKind_EnumDecl:
            return "EnumDecl";
        case SyntaxNodeFormat::NodeImplKind_EnumConstructor:
            return "EnumConstructor";
        case SyntaxNodeFormat::NodeImplKind_MacroDecl:
            return "MacroDecl";
        case SyntaxNodeFormat::NodeImplKind_MacroExpandDecl:
            return "MacroExpandDecl";
        case SyntaxNodeFormat::NodeImplKind_MacroExpandParam:
            return "MacroExpandParam";
        case SyntaxNodeFormat::NodeImplKind_ValuedLiteral:
            return "ValuedLiteral";
        case SyntaxNodeFormat::NodeImplKind_UnitLiteral:
            return "UnitLiteral";
        case SyntaxNodeFormat::NodeImplKind_RuneLiteral:
            return "RuneLiteral";
        case SyntaxNodeFormat::NodeImplKind_LineStringLiteral:
            return "LineStringLiteral";
        case SyntaxNodeFormat::NodeImplKind_MultiLineStringLiteral:
            return "MultiLineStringLiteral";
        case SyntaxNodeFormat::NodeImplKind_MultiLineRawStringLiteral:
            return "MultiLineRawStringLiteral";
        case SyntaxNodeFormat::NodeImplKind_ArrayLiteral:
            return "ArrayLiteral";
        case SyntaxNodeFormat::NodeImplKind_TupleLiteral:
            return "TupleLiteral";
        case SyntaxNodeFormat::NodeImplKind_AssignExpr:
            return "AssignExpr";
        case SyntaxNodeFormat::NodeImplKind_VArrayExpr:
            return "VArrayExpr";
        case SyntaxNodeFormat::NodeImplKind_MemberAccess:
            return "MemberAccess";
        case SyntaxNodeFormat::NodeImplKind_UnaryExpr:
            return "UnaryExpr";
        case SyntaxNodeFormat::NodeImplKind_CallExpr:
            return "CallExpr";
        case SyntaxNodeFormat::NodeImplKind_IsExpr:
            return "IsExpr";
        case SyntaxNodeFormat::NodeImplKind_AsExpr:
            return "AsExpr";
        case SyntaxNodeFormat::NodeImplKind_ParenExpr:
            return "ParenExpr";
        case SyntaxNodeFormat::NodeImplKind_ReturnExpr:
            return "ReturnExpr";
        case SyntaxNodeFormat::NodeImplKind_IncOrDecExpr:
            return "IncOrDecExpr";
        case SyntaxNodeFormat::NodeImplKind_RangeExpr:
            return "RangeExpr";
        case SyntaxNodeFormat::NodeImplKind_TypeConvExpr:
            return "TypeConvExpr";
        case SyntaxNodeFormat::NodeImplKind_OptionalExpr:
            return "OptionalExpr";
        case SyntaxNodeFormat::NodeImplKind_BreakExpr:
            return "BreakExpr";
        case SyntaxNodeFormat::NodeImplKind_ContinueExpr:
            return "ContinueExpr";
        case SyntaxNodeFormat::NodeImplKind_SubscriptExpr:
            return "SubscriptExpr";
        case SyntaxNodeFormat::NodeImplKind_Lambda:
            return "Lambda";
        case SyntaxNodeFormat::NodeImplKind_MatchExpr:
            return "MatchExpr";
        case SyntaxNodeFormat::NodeImplKind_TryCatch:
            return "TryCatch";
        case SyntaxNodeFormat::NodeImplKind_ThrowExpr:
            return "ThrowExpr";
        case SyntaxNodeFormat::NodeImplKind_SynchronizedExpr:
            return "SynchronizedExpr";
        case SyntaxNodeFormat::NodeImplKind_SpawnExpr:
            return "SpawnExpr";
        case SyntaxNodeFormat::NodeImplKind_IfExpr:
            return "IfExpr";
        case SyntaxNodeFormat::NodeImplKind_WhileExpr:
            return "WhileExpr";
        case SyntaxNodeFormat::NodeImplKind_DoWhileExpr:
            return "DoWhileExpr";
        case SyntaxNodeFormat::NodeImplKind_ForInExpr:
            return "ForInExpr";
        case SyntaxNodeFormat::NodeImplKind_JumpExpr:
            return "JumpExpr";
        case SyntaxNodeFormat::NodeImplKind_LambdaExpr:
            return "LambdaExpr";
        case SyntaxNodeFormat::NodeImplKind_TryExpr:
            return "TryExpr";
        case SyntaxNodeFormat::NodeImplKind_InterpolationExpr:
            return "InterpolationExpr";
        case SyntaxNodeFormat::NodeImplKind_QuoteTokenExpr:
            return "QuoteTokenExpr";
        case SyntaxNodeFormat::NodeImplKind_QuoteExpr:
            return "QuoteExpr";
        case SyntaxNodeFormat::NodeImplKind_QuoteInterpolationExpr:
            return "QuoteInterpolationExpr";
        case SyntaxNodeFormat::NodeImplKind_TrailingClosureExpr:
            return "TrailingClosureExpr";
        case SyntaxNodeFormat::NodeImplKind_UnsafeExpr:
            return "UnsafeExpr";
        case SyntaxNodeFormat::NodeImplKind_MacroExpandExpr:
            return "MacroExpandExpr";
        case SyntaxNodeFormat::NodeImplKind_ExceptTypePattern:
            return "ExceptTypePattern";
        case SyntaxNodeFormat::NodeImplKind_WildcardPattern:
            return "WildcardPattern";
        case SyntaxNodeFormat::NodeImplKind_ConstPattern:
            return "ConstPattern";
        case SyntaxNodeFormat::NodeImplKind_VarOrEnumPattern:
            return "VarOrEnumPattern";
        case SyntaxNodeFormat::NodeImplKind_TuplePattern:
            return "TuplePattern";
        case SyntaxNodeFormat::NodeImplKind_TypePattern:
            return "TypePattern";
        case SyntaxNodeFormat::NodeImplKind_EnumPattern:
            return "EnumPattern";
        case SyntaxNodeFormat::NodeImplKind_Terminal:
            return "Terminal";
        case SyntaxNodeFormat::NodeImplKind_Token:
            return "Token";
        case SyntaxNodeFormat::NodeImplKind_DotToken:
            return ".";
        case SyntaxNodeFormat::NodeImplKind_CommaToken:
            return ",";
        case SyntaxNodeFormat::NodeImplKind_LParenToken:
            return "(";
        case SyntaxNodeFormat::NodeImplKind_RParenToken:
            return ")";
        case SyntaxNodeFormat::NodeImplKind_LSquareToken:
            return "[";
        case SyntaxNodeFormat::NodeImplKind_RSquareToken:
            return "]";
        case SyntaxNodeFormat::NodeImplKind_LCurlToken:
            return "{";
        case SyntaxNodeFormat::NodeImplKind_RCurlToken:
            return "}";
        case SyntaxNodeFormat::NodeImplKind_ExpToken:
            return "**";
        case SyntaxNodeFormat::NodeImplKind_MulToken:
            return "*";
        case SyntaxNodeFormat::NodeImplKind_ModToken:
            return "%";
        case SyntaxNodeFormat::NodeImplKind_DivToken:
            return "/";
        case SyntaxNodeFormat::NodeImplKind_SubToken:
            return "-";
        case SyntaxNodeFormat::NodeImplKind_IncrToken:
            return "++";
        case SyntaxNodeFormat::NodeImplKind_DecrToken:
            return "--";
        case SyntaxNodeFormat::NodeImplKind_AndToken:
            return "&&";
        case SyntaxNodeFormat::NodeImplKind_OrToken:
            return "||";
        case SyntaxNodeFormat::NodeImplKind_CoalescingToken:
            return "??";
        case SyntaxNodeFormat::NodeImplKind_PipelineToken:
            return "|>";
        case SyntaxNodeFormat::NodeImplKind_CompositionToken:
            return "~>";
        case SyntaxNodeFormat::NodeImplKind_NotToken:
            return "!";
        case SyntaxNodeFormat::NodeImplKind_BitAndToken:
            return "&";
        case SyntaxNodeFormat::NodeImplKind_BitOrToken:
            return "|";
        case SyntaxNodeFormat::NodeImplKind_BitXorToken:
            return "^";
        case SyntaxNodeFormat::NodeImplKind_BitNotToken:
            return "~";
        case SyntaxNodeFormat::NodeImplKind_LShiftToken:
            return "<<";
        case SyntaxNodeFormat::NodeImplKind_RShiftToken:
            return ">>";
        case SyntaxNodeFormat::NodeImplKind_ColonToken:
            return ":";
        case SyntaxNodeFormat::NodeImplKind_SemiToken:
            return ";";
        case SyntaxNodeFormat::NodeImplKind_AddAssignToken:
            return "+=";
        case SyntaxNodeFormat::NodeImplKind_SubAssignToken:
            return "-=";
        case SyntaxNodeFormat::NodeImplKind_MulAssignToken:
            return "*=";
        case SyntaxNodeFormat::NodeImplKind_ExpAssignToken:
            return "**=";
        case SyntaxNodeFormat::NodeImplKind_DivAssignToken:
            return "/=";
        case SyntaxNodeFormat::NodeImplKind_ModAssignToken:
            return "%=";
        case SyntaxNodeFormat::NodeImplKind_AndAssignToken:
            return "&&=";
        case SyntaxNodeFormat::NodeImplKind_OrAssignToken:
            return "||=";
        case SyntaxNodeFormat::NodeImplKind_BitAndAssignToken:
            return "&=";
        case SyntaxNodeFormat::NodeImplKind_BitOrAssignToken:
            return "|=";
        case SyntaxNodeFormat::NodeImplKind_BitXorAssignToken:
            return "^=";
        case SyntaxNodeFormat::NodeImplKind_LShiftAssignToken:
            return "<<=";
        case SyntaxNodeFormat::NodeImplKind_RShiftAssignToken:
            return ">>=";
        case SyntaxNodeFormat::NodeImplKind_ArrowToken:
            return "->";
        case SyntaxNodeFormat::NodeImplKind_BackArrowToken:
            return "<-";
        case SyntaxNodeFormat::NodeImplKind_DoubleArrowToken:
            return "=>";
        case SyntaxNodeFormat::NodeImplKind_RangeOpToken:
            return "..";
        case SyntaxNodeFormat::NodeImplKind_ClosedRangeOpToken:
            return "..=";
        case SyntaxNodeFormat::NodeImplKind_EllipsisToken:
            return "...";
        case SyntaxNodeFormat::NodeImplKind_HashToken:
            return "#";
        case SyntaxNodeFormat::NodeImplKind_AtToken:
            return "@";
        case SyntaxNodeFormat::NodeImplKind_QuestToken:
            return "?";
        case SyntaxNodeFormat::NodeImplKind_LtToken:
            return "<";
        case SyntaxNodeFormat::NodeImplKind_GtToken:
            return ">";
        case SyntaxNodeFormat::NodeImplKind_LeToken:
            return "<=";
        case SyntaxNodeFormat::NodeImplKind_GeToken:
            return ">=";
        case SyntaxNodeFormat::NodeImplKind_IsToken:
            return "is";
        case SyntaxNodeFormat::NodeImplKind_AsToken:
            return "as";
        case SyntaxNodeFormat::NodeImplKind_NotEqToken:
            return "!=";
        case SyntaxNodeFormat::NodeImplKind_EqualToken:
            return "==";
        case SyntaxNodeFormat::NodeImplKind_WildcardToken:
            return "_";
        case SyntaxNodeFormat::NodeImplKind_Int8Token:
            return "Int8";
        case SyntaxNodeFormat::NodeImplKind_Int16Token:
            return "Int16";
        case SyntaxNodeFormat::NodeImplKind_Int32Token:
            return "Int32";
        case SyntaxNodeFormat::NodeImplKind_Int64Token:
            return "Int64";
        case SyntaxNodeFormat::NodeImplKind_IntNativeToken:
            return "IntNative";
        case SyntaxNodeFormat::NodeImplKind_UInt8Token:
            return "UInt8";
        case SyntaxNodeFormat::NodeImplKind_UInt16Token:
            return "UInt16";
        case SyntaxNodeFormat::NodeImplKind_UInt32Token:
            return "UInt32";
        case SyntaxNodeFormat::NodeImplKind_UInt64Token:
            return "UInt64";
        case SyntaxNodeFormat::NodeImplKind_UIntNativeToken:
            return "UIntNative";
        case SyntaxNodeFormat::NodeImplKind_Float16Token:
            return "Float16";
        case SyntaxNodeFormat::NodeImplKind_Float32Token:
            return "Float32";
        case SyntaxNodeFormat::NodeImplKind_Float64Token:
            return "Float64";
        case SyntaxNodeFormat::NodeImplKind_RuneToken:
            return "Rune";
        case SyntaxNodeFormat::NodeImplKind_BooleanToken:
            return "Bool";
        case SyntaxNodeFormat::NodeImplKind_NothingToken:
            return "Nothing";
        case SyntaxNodeFormat::NodeImplKind_UnitToken:
            return "Unit";
        case SyntaxNodeFormat::NodeImplKind_StructToken:
            return "struct";
        case SyntaxNodeFormat::NodeImplKind_EnumToken:
            return "enum";
        case SyntaxNodeFormat::NodeImplKind_VArrayToken:
            return "VArray";
        case SyntaxNodeFormat::NodeImplKind_ThisTypeToken:
            return "This";
        case SyntaxNodeFormat::NodeImplKind_FeaturesToken:
            return "features";
        case SyntaxNodeFormat::NodeImplKind_PackageToken:
            return "package";
        case SyntaxNodeFormat::NodeImplKind_ImportToken:
            return "import";
        case SyntaxNodeFormat::NodeImplKind_ClassToken:
            return "class";
        case SyntaxNodeFormat::NodeImplKind_InterfaceToken:
            return "interface";
        case SyntaxNodeFormat::NodeImplKind_FuncToken:
            return "func";
        case SyntaxNodeFormat::NodeImplKind_MacroToken:
            return "macro";
        case SyntaxNodeFormat::NodeImplKind_QuoteToken:
            return "quote";
        case SyntaxNodeFormat::NodeImplKind_DollarToken:
            return "$";
        case SyntaxNodeFormat::NodeImplKind_VarToken:
            return "var";
        case SyntaxNodeFormat::NodeImplKind_ConstToken:
            return "const";
        case SyntaxNodeFormat::NodeImplKind_TypeToken:
            return "type";
        case SyntaxNodeFormat::NodeImplKind_InitToken:
            return "init";
        case SyntaxNodeFormat::NodeImplKind_ThisToken:
            return "this";
        case SyntaxNodeFormat::NodeImplKind_SuperToken:
            return "super";
        case SyntaxNodeFormat::NodeImplKind_IfToken:
            return "if";
        case SyntaxNodeFormat::NodeImplKind_ElseToken:
            return "else";
        case SyntaxNodeFormat::NodeImplKind_CaseToken:
            return "case";
        case SyntaxNodeFormat::NodeImplKind_TryToken:
            return "try";
        case SyntaxNodeFormat::NodeImplKind_CatchToken:
            return "catch";
        case SyntaxNodeFormat::NodeImplKind_FinallyToken:
            return "finally";
        case SyntaxNodeFormat::NodeImplKind_ForToken:
            return "for";
        case SyntaxNodeFormat::NodeImplKind_DoToken:
            return "do";
        case SyntaxNodeFormat::NodeImplKind_WhileToken:
            return "while";
        case SyntaxNodeFormat::NodeImplKind_ThrowToken:
            return "throw";
        case SyntaxNodeFormat::NodeImplKind_ReturnToken:
            return "return";
        case SyntaxNodeFormat::NodeImplKind_ContinueToken:
            return "continue";
        case SyntaxNodeFormat::NodeImplKind_BreakToken:
            return "break";
        case SyntaxNodeFormat::NodeImplKind_InToken:
            return "in";
        case SyntaxNodeFormat::NodeImplKind_NotInToken:
            return "!in";
        case SyntaxNodeFormat::NodeImplKind_MatchToken:
            return "match";
        case SyntaxNodeFormat::NodeImplKind_WhereToken:
            return "where";
        case SyntaxNodeFormat::NodeImplKind_ExtendToken:
            return "extend";
        case SyntaxNodeFormat::NodeImplKind_WithToken:
            return "with";
        case SyntaxNodeFormat::NodeImplKind_PropToken:
            return "prop";
        case SyntaxNodeFormat::NodeImplKind_GetToken:
            return "get";
        case SyntaxNodeFormat::NodeImplKind_SetToken:
            return "set";
        case SyntaxNodeFormat::NodeImplKind_StaticToken:
            return "static";
        case SyntaxNodeFormat::NodeImplKind_PublicToken:
            return "public";
        case SyntaxNodeFormat::NodeImplKind_PrivateToken:
            return "private";
        case SyntaxNodeFormat::NodeImplKind_InternalToken:
            return "internal";
        case SyntaxNodeFormat::NodeImplKind_ProtectedToken:
            return "protected";
        case SyntaxNodeFormat::NodeImplKind_OverrideToken:
            return "override";
        case SyntaxNodeFormat::NodeImplKind_RedefToken:
            return "redef";
        case SyntaxNodeFormat::NodeImplKind_AbstractToken:
            return "abstract";
        case SyntaxNodeFormat::NodeImplKind_SealedToken:
            return "sealed";
        case SyntaxNodeFormat::NodeImplKind_OpenToken:
            return "open";
        case SyntaxNodeFormat::NodeImplKind_ForeignToken:
            return "foreign";
        case SyntaxNodeFormat::NodeImplKind_InoutToken:
            return "inout";
        case SyntaxNodeFormat::NodeImplKind_MutToken:
            return "mut";
        case SyntaxNodeFormat::NodeImplKind_UnsafeToken:
            return "unsafe";
        case SyntaxNodeFormat::NodeImplKind_OperatorToken:
            return "operator";
        case SyntaxNodeFormat::NodeImplKind_SpawnToken:
            return "spawn";
        case SyntaxNodeFormat::NodeImplKind_SynchronizedToken:
            return "synchronized";
        case SyntaxNodeFormat::NodeImplKind_UpperBoundToken:
            return "<:";
        case SyntaxNodeFormat::NodeImplKind_MainToken:
            return "main";
        case SyntaxNodeFormat::NodeImplKind_PackageIdentifierToken:
            return "PackageIdentifierToken";
        case SyntaxNodeFormat::NodeImplKind_FloatLiteralToken:
            return "FloatLiteralToken";
        case SyntaxNodeFormat::NodeImplKind_CommentToken:
            return "CommentToken";
        case SyntaxNodeFormat::NodeImplKind_EndToken:
            return "EndToken";
        case SyntaxNodeFormat::NodeImplKind_SentinelToken:
            return "SentinelToken";
        case SyntaxNodeFormat::NodeImplKind_RunePrefixToken:
            return "r";
        case SyntaxNodeFormat::NodeImplKind_DoubleQuoteToken:
            return "\"";
        case SyntaxNodeFormat::NodeImplKind_SingleQuoteToken:
            return "'";
        case SyntaxNodeFormat::NodeImplKind_JStringLiteralToken:
            return "JStringLiteralToken";
        case SyntaxNodeFormat::NodeImplKind_MultilineStringToken:
            return "MultilineStringToken";
        case SyntaxNodeFormat::NodeImplKind_MultilineRawStringToken:
            return "MultilineRawStringToken";
        case SyntaxNodeFormat::NodeImplKind_BooleanLiteralToken:
            return "BooleanLiteralToken";
        case SyntaxNodeFormat::NodeImplKind_DollarIdentifierToken:
            return "DollarIdentifierToken";
        case SyntaxNodeFormat::NodeImplKind_AnnotationToken:
            return "AnnotationToken";
        case SyntaxNodeFormat::NodeImplKind_AtExclToken:
            return "@!";
        case SyntaxNodeFormat::NodeImplKind_CommonToken:
            return "common";
        case SyntaxNodeFormat::NodeImplKind_PlatformToken:
            return "specific";
        case SyntaxNodeFormat::NodeImplKind_HandleToken:
            return "handle";
        case SyntaxNodeFormat::NodeImplKind_PerformToken:
            return "perform";
        case SyntaxNodeFormat::NodeImplKind_ResumeToken:
            return "resume";
        case SyntaxNodeFormat::NodeImplKind_ThrowingToken:
            return "throwing";
        case SyntaxNodeFormat::NodeImplKind_TripleSingleQuoteToken:
            return "'''";
        case SyntaxNodeFormat::NodeImplKind_TripleDoubleQuoteToken:
            return "\"\"\"";
        case SyntaxNodeFormat::NodeImplKind_StringLiteralToken:
            return "StringLiteralToken";
        case SyntaxNodeFormat::NodeImplKind_Invalid:
            return "Invalid";
        default:
            std::cout << "UnknownKind_" + std::to_string(static_cast<int>(kind)) << std::endl;
            return "";
    }
}