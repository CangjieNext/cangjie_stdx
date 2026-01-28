#include "flatbuffers/SyntaxNodeFormat_generated.h"
#include <flatbuffers/flatbuffers.h>
#include <flatbuffers/util.h>


class SyntaxNodeFlatBufferDeserializer {
public:
    static std::shared_ptr<SyntaxNode> deserialize(
        const uint8_t* buffer, 
        size_t length) {
        
        // // 验证FlatBuffer数据
        // flatbuffers::Verifier verifier(buffer, length);
        // if (!SyntaxNodeFormat::VerifyBuffer(verifier)) {
        //     throw std::runtime_error("Invalid FlatBuffer data");
        // }
        
        // 获取根节点
        auto root = SyntaxNodeFormat::GetNonTerminal(buffer);
        return deserializeNonTerminal(root);
    }
    
private:
    
    static std::shared_ptr<SyntaxNode> deserializeNonTerminal(
        const SyntaxNodeFormat::NonTerminal* nonTerm) {
        
        if (!nonTerm) {return nullptr;}
        
        auto node = std::make_shared<NonTerminal>();
        node->id = nonTerm->id();

        node->kind = getNodeKindName(nonTerm->kind());
        
        // 反序列化子节点
        if (nonTerm->children() && nonTerm->children_type()) {
            auto children = nonTerm->children();
            auto childrenTypes = nonTerm->children_type();
            
            for (size_t i = 0; i < children->size(); ++i) {
                // 获取子节点类型
                auto childType = static_cast<SyntaxNodeFormat::NodeImplKind>(
                    childrenTypes->Get(i));
                
                // 根据类型获取对应的数据
                auto childNode = getChildNodeByType(children->Get(i), childType);
                if (childNode) {
                    node->children.push_back(childNode);
                }
            }
        }
        
        return node;
    }
    
    static std::shared_ptr<SyntaxNode> deserializeTerminal(
        const SyntaxNodeFormat::Terminal* term) {
        
        if (!term) { return nullptr;} 
        
        auto node = std::make_shared<Terminal>();
        node->id = term->id();
        node->kind = getNodeKindName(term->kind());
        
        return node;
    }

    static std::shared_ptr<SyntaxNode> deserializeValuedTerminal(
        const SyntaxNodeFormat::ValuedTerminal* valTerm) {
        
        if (!valTerm) { return nullptr;} 
        
        auto node = std::make_shared<ValuedTerminal>();
        node->id = valTerm->id();
        node->kind = getNodeKindName(valTerm->kind());
        
        if (valTerm->value()) {
            node->value = valTerm->value()->str();
        }
        
        return node;
    }
    
    static std::shared_ptr<SyntaxNode> deserializeRepeatedTerminal(
        const SyntaxNodeFormat::RepeatedTerminal* repTerm) {
        
        if (!repTerm) { return nullptr; }
        
        auto node = std::make_shared<RepeatedTerminal>();
        node->id = repTerm->id();
        node->kind = getNodeKindName(repTerm->kind());
        node->repeat = repTerm->repeat();
        
        return node;
    }
    
    static std::shared_ptr<SyntaxNode> getChildNodeByType(
        const flatbuffers::Offset<void>& offset,
        SyntaxNodeFormat::NodeImplKind type) {
        
        // TODO: may not need this
        const uint8_t* ptr = reinterpret_cast<const uint8_t*>(offset.o);
        
        switch (type) {
            case SyntaxNodeFormat::NodeImplKind_NonTerminal:
                return deserializeNonTerminal(
                    reinterpret_cast<const SyntaxNodeFormat::NonTerminal*>(ptr));
            case SyntaxNodeFormat::NodeImplKind_Terminal:
                return deserializeTerminal(
                    reinterpret_cast<const SyntaxNodeFormat::Terminal*>(ptr));
            case SyntaxNodeFormat::NodeImplKind_ValuedTerminal:
                return deserializeValuedTerminal(
                    reinterpret_cast<const SyntaxNodeFormat::ValuedTerminal*>(ptr));
            case SyntaxNodeFormat::NodeImplKind_RepeatedTerminal:
                return deserializeRepeatedTerminal(
                    reinterpret_cast<const SyntaxNodeFormat::RepeatedTerminal*>(ptr));
            default:
                return nullptr;
        }
    }
    
    static std::string getNodeKindName(SyntaxNodeFormat::NodeImplKind kind) {
        switch (kind) {
            case SyntaxNodeFormat::NodeImplKind_Package: return "Package";
            case SyntaxNodeFormat::NodeImplKind_File: return "File";
            case SyntaxNodeFormat::NodeImplKind_VarDecl: return "VarDecl";
            case SyntaxNodeFormat::NodeImplKind_FuncDecl: return "FuncDecl";
            case SyntaxNodeFormat::NodeImplKind_BinaryExpr: return "BinaryExpr";
            case SyntaxNodeFormat::NodeImplKind_SymbolRef: return "SymbolRef";
            case SyntaxNodeFormat::NodeImplKind_VarPattern: return "VarPattern";
            case SyntaxNodeFormat::NodeImplKind_IdentToken: return "IdentToken";
            case SyntaxNodeFormat::NodeImplKind_IntegerLiteralToken: return "IntegerLiteralToken";
            case SyntaxNodeFormat::NodeImplKind_Space: return "Space";
            case SyntaxNodeFormat::NodeImplKind_NL: return "NL";
            case SyntaxNodeFormat::NodeImplKind_let: return "let";
            case SyntaxNodeFormat::NodeImplKind_EqualToken: return "=";
            case SyntaxNodeFormat::NodeImplKind_AddToken: return "+";
            case SyntaxNodeFormat::NodeImplKind_IdentToken: return "IdentToken";
            default:
                return "UnknownKind_" + std::to_string(static_cast<int>(kind));
        }
    }
};
