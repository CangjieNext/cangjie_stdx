#include "typeWrite.h"

#include "cangjie/AST/Node.h"
#include "cangjie/AST/Symbol.h"

using namespace Cangjie;
using namespace AST;

flatbuffers::Offset<SemanticType::ASTType> TypeWrite::SerializeSemanticType(AstTy ty) {
    if (ty == nullptr) {
        return flatbuffers::Offset<SemanticType::ASTType>();
    }

    auto kind = static_cast<uint16_t>(ty->kind);
    std::vector<flatbuffers::Offset<SemanticType::ASTType>> lateTypeVector;

    for (const auto item: ty->typeArgs) {
        lateTypeVector.push_back(SerializeSemanticType(item));
    }
    if (ty->kind == TypeKind::TYPE_GENERICS) {
        for (const auto item: (static_cast<const GenericsTy*>(ty.get()))->upperBounds) {
            lateTypeVector.push_back(SerializeSemanticType(item));
        }
    }
    auto args = builder.CreateVector(lateTypeVector);
    auto name = builder.CreateString(ty->name);
    auto rPointer = uint64_t(ty.get());
    return SemanticType::CreateASTType(builder, kind, name, args, rPointer);

}

flatbuffers::Offset<SemanticType::SemanticTypeMap> TypeWrite::SerializeSemanticTypeMap(int id, AstTy ty) {
    auto type = SerializeSemanticType(ty);
    return SemanticType::CreateSemanticTypeMap(builder, id, type);
}

flatbuffers::Offset<SemanticType::NodeTypeMap> TypeWrite::SerializeNodeTypeMap() {
    std::vector<flatbuffers::Offset<SemanticType::SemanticTypeMap>> declTypeVector;
    std::vector<flatbuffers::Offset<SemanticType::SemanticTypeMap>> exprTypeVector;
    std::vector<flatbuffers::Offset<SemanticType::SymbolRefMap>> refVector;

    for (const auto &pair: declTypeMap){
        declTypeVector.push_back(SerializeSemanticTypeMap(pair.first, pair.second.get()->ty));
    }
    auto declTypeFlatbufferVector = builder.CreateVector(declTypeVector);
    auto exprTypeFlatbufferVector = builder.CreateVector(exprTypeVector);
    auto refFlatbufferVector = builder.CreateVector(refVector);
    return SemanticType::CreateNodeTypeMap(builder, declTypeFlatbufferVector, exprTypeFlatbufferVector, refFlatbufferVector);
}

uint8_t* TypeWrite::ExportType()
{
    auto map = SerializeNodeTypeMap();
    builder.Finish(map);

    // Serialize data into buffer.
    // Flatbuffer maximum size is 2GB, for 32-bit signed offsets.
    uint32_t length = static_cast<uint32_t>(builder.GetSize());
    bufferData.resize(sizeof(uint32_t) + length); // Add length of buffer in front.
    uint8_t* buf = builder.GetBufferPointer();
    uint32_t bufferSize = length + static_cast<uint32_t>(sizeof(uint32_t));
    uint8_t* pBufferSize = reinterpret_cast<uint8_t*>(&bufferSize);
    (void)std::copy(pBufferSize, pBufferSize + sizeof(uint32_t), bufferData.begin());
    (void)std::copy(
        buf, buf + static_cast<size_t>(length), bufferData.begin() + static_cast<int32_t>(sizeof(uint32_t)));
    uint8_t* rawPtr = (uint8_t*)malloc(bufferData.size());
    if (rawPtr == nullptr) {
        Errorln("Memory Allocation Failed.");
        return rawPtr;
    }
    (void)std::copy_n(bufferData.begin(), bufferData.size(), rawPtr);
    return rawPtr;
}


// uint8_t* TypeWrite::ExportDeclAndType()
// {
//     auto map = SerializeNodeTypeMap();
//     builder.Finish(map);

//     // Serialize data into buffer.
//     // Flatbuffer maximum size is 2GB, for 32-bit signed offsets.
//     uint32_t length = static_cast<uint32_t>(builder.GetSize());
//     bufferData.resize(sizeof(uint32_t) + length); // Add length of buffer in front.
//     uint8_t* buf = builder.GetBufferPointer();
//     uint32_t bufferSize = length + static_cast<uint32_t>(sizeof(uint32_t));
//     uint8_t* pBufferSize = reinterpret_cast<uint8_t*>(&bufferSize);
//     (void)std::copy(pBufferSize, pBufferSize + sizeof(uint32_t), bufferData.begin());
//     (void)std::copy(
//         buf, buf + static_cast<size_t>(length), bufferData.begin() + static_cast<int32_t>(sizeof(uint32_t)));
//     uint8_t* rawPtr = (uint8_t*)malloc(bufferData.size());
//     if (rawPtr == nullptr) {
//         Errorln("Memory Allocation Failed.");
//         return rawPtr;
//     }
//     (void)std::copy_n(bufferData.begin(), bufferData.size(), rawPtr);
//     return rawPtr;
// }