#include "flatbuffers/SemanticType_generated.h"

#include "cangjie/AST/Node.h"
#include "cangjie/Basic/Print.h"

using ASTNode = Ptr<const Cangjie::AST::Node>;
using AstTy = Ptr<const Cangjie::AST::Ty>;

const size_t INITIAL_FILE_SIZE = 65536;

using namespace Cangjie;
class TypeWrite {
public:
    TypeWrite(std::map<int, Ptr<const AST::Node>> declTypeMap, std::map<int, Ptr<const AST::Node>> exprTypeMap,
        std::map<int, int> refMap)
        : declTypeMap(declTypeMap), exprTypeMap(exprTypeMap), refMap(refMap), builder(INITIAL_FILE_SIZE)
        {}

    ~TypeWrite(){}

    uint8_t *ExportType();

private:
    std::vector<uint8_t> bufferData;
    std::map<int, Ptr<const AST::Node>> declTypeMap;
    std::map<int, Ptr<const AST::Node>> exprTypeMap;
    std::map<int, int> refMap;
    flatbuffers::Offset<SemanticType::ASTType> SerializeSemanticType(AstTy ty);
    flatbuffers::Offset<SemanticType::SemanticTypeMap> SerializeSemanticTypeMap(int id, AstTy ty);
    flatbuffers::Offset<SemanticType::NodeTypeMap> SerializeNodeTypeMap();
    flatbuffers::FlatBufferBuilder builder;
};