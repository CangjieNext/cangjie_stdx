package stdx.semantic
import stdx.syntax.*

let BUFFER_HEADER_SIZE = 4

foreign func CJ_Analyze(fptr: CPointer<UInt8>, length: UIntNative, importedPkg: CPointer<ImportedPackageArray>): CPointer<UInt8>
foreign func CJ_Analyze_With_Path(fptr: CPointer<UInt8>, length: UIntNative, path: CString): CPointer<UInt8>
foreign func CJ_GetSemanticResult(fptr: CPointer<Unit>): CPointer<UInt8>

foreign func CJ_CreateFromCJO(path: CString): CPointer<UInt8>

@C
struct ImportedPackage {
    var buffer: CPointer<UInt8> = CPointer()
    var size: UIntNative = 0

    init(importedPkgBuffer: Array<UInt8>) {
        this.size = UIntNative(importedPkgBuffer.size)
        this.buffer = LibC.malloc<UInt8>(count: importedPkgBuffer.size)
        if (this.buffer.isNull()) {
            throw IllegalMemoryException("Malloc failed.")
        }
        for (i in 0..importedPkgBuffer.size) {
            unsafe { this.buffer.write(i, importedPkgBuffer[i])}
        }
    }
}

@C
struct DeclTypeMap {
    var buffer: CPointer<UInt8> = CPointer()
    var size: UIntNative = 0

    init(declMap: Array<UInt8>) {
        this.size = UIntNative(declMap.size)
        this.buffer = LibC.malloc<UInt8>(count: declMap.size)
        if (this.buffer.isNull()) {
            throw IllegalMemoryException("Malloc failed.")
        }
        for (i in 0..declMap.size) {
            unsafe { this.buffer.write(i, declMap[i])}
        }
    }
}

@C
struct ImportedPackageArray {
    var importedPackageBuffer: CPointer<ImportedPackage> = CPointer()
    var declTypeMapBuffer: CPointer<DeclTypeMap> = CPointer()
    var size: UIntNative = 0

    init(importedPkgListBuffer: Array<Array<UInt8>>, declMapListBuffer: Array<Array<UInt8>>) {
        // size should eq
        this.size = UIntNative(importedPkgListBuffer.size)

        this.importedPackageBuffer = LibC.malloc<ImportedPackage>(count: importedPkgListBuffer.size)
        this.declTypeMapBuffer = LibC.malloc<DeclTypeMap>(count: declMapListBuffer.size)
        if (this.importedPackageBuffer.isNull()) {
            throw IllegalMemoryException("Malloc failed.")
        }
        for (i in 0..importedPkgListBuffer.size) {
            // let p = LibC.malloc<ImportedPackage>(count: 1)
            // if (p.isNull()) {
            //     throw IllegalMemoryException("Malloc failed.")
            // }
            // p.write(ImportedPackage(importedPkgListBuffer[i]))
            unsafe { 
                this.importedPackageBuffer.write(i, ImportedPackage(importedPkgListBuffer[i]))
                this.declTypeMapBuffer.write(i, DeclTypeMap(declMapListBuffer[i]))
            }
        }
    }
}

unsafe func analyzeImpl(arr: Array<UInt8>, importedPkgBuf: Array<Array<UInt8>>, declMap: Array<Array<UInt8>>) : SemanticType_NodeTypeMap {
    let prepareStart = timerStart()
    var typeListPtr : CPointer<UInt8> = CPointer<UInt8>()
    var semanticTypeMap = SemanticType_NodeTypeMap(Array<UInt8>(), 0)
    
    let arrSize: Int64 = arr.size
    if (arrSize <= 0) {
        return semanticTypeMap
    }
    var ptr: CPointer<UInt8> = LibC.malloc<UInt8>(count: arrSize)
    var importedPkgPtr: CPointer<ImportedPackageArray> = LibC.malloc<ImportedPackageArray>(count: 1)

    if (ptr.isNull() || importedPkgPtr.isNull()) {
        throw IllegalMemoryException("unsafePointerCastFromUint8Array malloc failed!")
    }
    for (i in 0..arrSize) {
        ptr.write(i, arr[i])
    }
    importedPkgPtr.write(ImportedPackageArray(importedPkgBuf, declMap))
    timerRecord(prepareStart, "Stage 1.2: CFFI memory copy data")
    try{
        let cffiStart = timerStart()
        let length = UIntNative(arrSize)
        typeListPtr = CJ_Analyze(ptr, length, importedPkgPtr)
        timerRecord(cffiStart, "Stage 2: CFFI")
        
        let deserialStart = timerStart()
        semanticTypeMap = genSemanticTypeMap(typeListPtr)
        timerRecord(deserialStart, "Stage 3.1: Deserial semantic result")
    } finally {
        LibC.free(importedPkgPtr)
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
