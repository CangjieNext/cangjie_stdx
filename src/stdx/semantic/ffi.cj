package stdx.semantic
import stdx.syntax.*

let BUFFER_HEADER_SIZE = 4

foreign func CJ_Analyze(fptr: CPointer<UInt8>, length: UIntNative): CPointer<UInt8>
foreign func CJ_Analyze_With_Path(fptr: CPointer<UInt8>, length: UIntNative, path: CString): CPointer<UInt8>
foreign func CJ_GetSemanticResult(fptr: CPointer<Unit>): CPointer<UInt8>

foreign func CJ_CreateFromCJO(path: CString): CPointer<UInt8>

unsafe func analyzeImpl(arr: Array<UInt8>) : SemanticType_NodeTypeMap {
    var typeListPtr : CPointer<UInt8> = CPointer<UInt8>()
    var semanticTypeMap = SemanticType_NodeTypeMap(Array<UInt8>(), 0)
    
    let arrSize: Int64 = arr.size
    if (arrSize <= 0) {
        return semanticTypeMap
    }
    var ptr: CPointer<UInt8> = unsafe { LibC.malloc<UInt8>(count: arrSize) }
    if (ptr.isNull()) {
        throw IllegalMemoryException("unsafePointerCastFromUint8Array malloc failed!")
    }
    for (i in 0..arrSize) {
        unsafe { ptr.write(i, arr[i]) }
    }
    try{
        let length = UIntNative(arrSize)
        typeListPtr = CJ_Analyze(ptr, length)
        semanticTypeMap = genSemanticTypeMap(typeListPtr)
    } finally {
        LibC.free(typeListPtr)
        LibC.free(ptr)
    }
    return semanticTypeMap
}

unsafe func analyzeImplWithPath(arr: Array<UInt8>, cjoPath: String) : SemanticType_NodeTypeMap {
    var typeListPtr : CPointer<UInt8> = CPointer<UInt8>()
    var semanticTypeMap = SemanticType_NodeTypeMap(Array<UInt8>(), 0)
    
    let arrSize: Int64 = arr.size
    if (arrSize <= 0) {
        return semanticTypeMap
    }
    var ptr: CPointer<UInt8> = unsafe { LibC.malloc<UInt8>(count: arrSize) }
    if (ptr.isNull()) {
        throw IllegalMemoryException("unsafePointerCastFromUint8Array malloc failed!")
    }
    for (i in 0..arrSize) {
        unsafe { ptr.write(i, arr[i]) }
    }
    try (cjoPathPtr = LibC.mallocCString(cjoPath).asResource()) {
        let length = UIntNative(arrSize)
        typeListPtr = CJ_Analyze_With_Path(ptr, length, cjoPathPtr.value)
        semanticTypeMap = genSemanticTypeMap(typeListPtr)
    } finally {
        LibC.free(typeListPtr)
        LibC.free(ptr)
    }
    return semanticTypeMap
}

unsafe func createFromCJOImpl(cjoPath: String) {
    // try (cjoPathPtr = LibC.mallocCString(cjoPath).asResource()) {
    //     CJ_Analyze_With_Path(cjoPathPtr.value)
    //     // semanticTypeMap = genSemanticTypeMap(typeListPtr)
    // } finally {
    //     // LibC.free(typeListPtr)
    // }
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