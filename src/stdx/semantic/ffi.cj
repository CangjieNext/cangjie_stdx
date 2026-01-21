package stdx.semantic
import stdx.syntax.*

let BUFFER_HEADER_SIZE = 4

foreign func CJ_Analyze(jsonStr: CString): CPointer<UInt8>
foreign func CJ_GetSemanticResult(fptr: CPointer<Unit>): CPointer<UInt8>

unsafe func analyzeImpl(jsonStr: String) : SemanticType_NodeTypeMap {
    var typeListPtr : CPointer<UInt8> = CPointer<UInt8>()
    var semanticTypeMap = SemanticType_NodeTypeMap(Array<UInt8>(), 0)
    try(pCStr = LibC.mallocCString(jsonStr).asResource()) {
        typeListPtr = CJ_Analyze(pCStr.value)
        semanticTypeMap = genSemanticTypeMap(typeListPtr)
    } finally {
        LibC.free(typeListPtr)
    }
    return semanticTypeMap
}

unsafe func genSemanticTypeMap(typeListPtr: CPointer<UInt8>) {
    let bufferSize = Int64(getInt32FromUnsafePointer(typeListPtr))
    if (bufferSize <=0 ) {
        LibC.free(typeListPtr)
        throw Exception("zero length")
    }
    let flatBuf = Array<UInt8>(bufferSize, {x: Int64 => typeListPtr.read(x)})
    return SemanticType_NodeTypeMap(flatBuf[BUFFER_HEADER_SIZE..], 0)
}

func getInt32FromUnsafePointer(ptr: CPointer<UInt8>): Int32 {
    var buf = Array<UInt8>(BUFFER_HEADER_SIZE, {x: Int64 => unsafe {ptr.read(x)}})
    return getInt32(buf[0..4])
}