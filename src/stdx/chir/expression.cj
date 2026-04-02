/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

import std.deriving.*

@Derive[Equatable]
@Derive[ToString]
internal enum ExprKind <: ToString {
    // terminator
    Goto | Branch | MultiBranch | Exit |
    TryApply | TryInvoke | TryIntrinsic |
    RaiseException | TrySpawn | TypeCastWithException |
    TryAllocate | TryRawArrayAllocate |

    // unary expr
    Neg | Not | BitNot |

    // binary expr
    Add | Sub | Mul | Div | Mod | Exp |
    LShift | RShift | BitAnd | BitOr | BitXor |
    Lt | Gt | Le | Ge | Equal | NotEqual |
    And | Or |

    // memory expr
    Allocate | Load | Store | GetElementByName | StoreElementByName | Field | FieldByName |

    // array
    RawArrayAllocate | RawArrayLiteralInit | RawArrayInitByValue |
    `VArrayExpr` | VArrayBuilder |

    // others
    Constant | Debug | Tuple | InstanceOf | TypeCast | GetException | Spawn | Lambda | GetInstantiateValue |
    Apply | Invoke | Intrinsic | GetRtti | GetRttiStatic

    internal func isTerminator(): Bool {
        match (this) {
            case Goto | Branch | MultiBranch | Exit |
            TryApply | TryInvoke | TryIntrinsic |
            RaiseException | TrySpawn | TypeCastWithException |
            TryAllocate | TryRawArrayAllocate => true
            case _ => false
        }
    }

    internal func isUnary(): Bool {
        match (this) {
            case Neg | Not | BitNot => true
            case _ => false
        }
    }

    internal func isBinary(): Bool {
        match (this) {
            case Add | Sub | Mul | Div | Mod | Exp |
            LShift | RShift | BitAnd | BitOr | BitXor |
            Lt | Gt | Le | Ge | Equal | NotEqual |
            And | Or => true
            case _ => false
        }
    }

    internal func isMathematicalOperator(): Bool {
        match (this) {
            case Add | Sub | Mul | Div | Mod | Exp => true
            case _ => false
        }
    }

    internal func isBitwiseOperator(): Bool {
        match (this) {
            case LShift | RShift | BitAnd | BitOr | BitXor => true
            case _ => false
        }
    }

    internal func isComparisonOperator(): Bool {
        match (this) {
            case Lt | Gt | Le | Ge | Equal | NotEqual => true
            case _ => false
        }
    }

    internal func isLogicalOperator(): Bool {
        match (this) {
            case And | Or => true
            case _ => false
        }
    }
}

@Derive[Equatable]
@Derive[ToString]
public enum OverflowStrategy {
    NA
    | Wrapping
    | Throwing
    | Saturating
}

@Derive[Equatable]
@Derive[ToString]
internal enum IntrinsicKind {
    NotIntrinsic |
    NotImplemented |
    ArrayInit |
    SizeOf |
    AlignOf |
    ArrayAcquireRawData |
    ArrayReleaseRawData |
    ArrayBuiltInCopyTo |
    ArrayGet |
    ArraySet |
    ArrayGetUnchecked |
    ArrayGetRefUnchecked |
    ArraySetUnchecked |
    ArraySize |
    ArrayClone |
    ArraySliceInit |
    ArraySlice |
    ArraySliceRawArray |
    ArraySliceStart |
    ArraySliceSize |
    ArraySliceGetElement |
    ArraySliceGetElementUnchecked |
    ArraySliceSetElement |
    ArraySliceSetElementUnchecked |
    FillInStackTrace |
    DecodeStackTrace |
    DumpCurrentThreadInfo |
    DumpAllThreadsInfo |
    Chr |
    Ord |
    CPointerGetPointerAddress |
    CPointerInit0 |
    CPointerInit1 |
    CPointerRead |
    CPointerWrite |
    CPointerAdd |
    CStringInit |
    CStringConvertCstrToPtr |
    InoutParam |
    RegisterWatchedObject |
    ObjectRefeq |
    RawArrayRefeq |
    FuncRefeq |
    ObjectZeroValue |
    InvokeGc |
    SetGcThreshold |
    DumpCjHeapData |
    GetGcCount |
    GetGcTimeUs |
    GetGcFreedSize |
    StartCjCpuProfiling |
    StopCjCpuProfiling |
    BlackBox |
    GetMaxHeapSize |
    GetAllocateHeapSize |
    GetRealHeapSize |
    GetThreadNumber |
    GetBlockingThreadNumber |
    GetNativeThreadNumber |
    VArraySet |
    VArrayGet |
    FutureInit |
    FutureIsComplete |
    FutureWait |
    FutureNotifyAll |
    IsThreadObjectInited |
    GetThreadObject |
    SetThreadObject |
    OverflowCheckedAdd |
    OverflowCheckedSub |
    OverflowCheckedMul |
    OverflowCheckedDiv |
    OverflowCheckedMod |
    OverflowCheckedPow |
    OverflowCheckedInc |
    OverflowCheckedDec |
    OverflowCheckedNeg |
    OverflowThrowingAdd |
    OverflowThrowingSub |
    OverflowThrowingMul |
    OverflowThrowingDiv |
    OverflowThrowingMod |
    OverflowThrowingPow |
    OverflowThrowingInc |
    OverflowThrowingDec |
    OverflowThrowingNeg |
    OverflowSaturatingAdd |
    OverflowSaturatingSub |
    OverflowSaturatingMul |
    OverflowSaturatingDiv |
    OverflowSaturatingMod |
    OverflowSaturatingPow |
    OverflowSaturatingInc |
    OverflowSaturatingDec |
    OverflowSaturatingNeg |
    OverflowWrappingAdd |
    OverflowWrappingSub |
    OverflowWrappingMul |
    OverflowWrappingDiv |
    OverflowWrappingMod |
    OverflowWrappingPow |
    OverflowWrappingInc |
    OverflowWrappingDec |
    OverflowWrappingNeg |
    VectorCompare32 |
    VectorIndexByte32 |
    CjCoreCanUseSimd |
    CjTlsDynSetSessionCallback |
    CjTlsDynSslInit |
    ReflectionIntrinsicStartFlag |
    IsInterface |
    IsClass |
    IsPrimitive |
    IsStruct |
    IsGeneric |
    GetOrCreateTypeInfoForReflect |
    GetTypeTemplate |
    CheckMethodActualArgs |
    MethodEntrypointIsNull |
    IsRelectUnsupportedType |
    GetTypeForAny |
    GetTypeByMangledName |
    GetTypeName |
    GetTypeByQualifiedName |
    GetTypeQualifiedNameLength |
    GetTypeQualifiedName |
    GetNumOfInterface |
    GetInterface |
    IsSubtype |
    GetTypeInfoModifier |
    GetTypeInfoAnnotations |
    GetObjClass |
    GetSuperTypeInfo |
    GetNumOfInstanceMethodInfos |
    GetInstanceMethodInfo |
    GetNumOfStaticMethodInfos |
    GetStaticMethodInfo |
    GetMethodName |
    GetMethodReturnType |
    GetMethodModifier |
    GetMethodAnnotations |
    ApplyCjMethod |
    ApplyCjStaticMethod |
    ApplyCjGenericMethod |
    ApplyCjGenericStaticMethod |
    GetNumOfActualParameters |
    GetNumOfGenericParameters |
    GetActualParameterInfo |
    GetGenericParameterInfo |
    GetNumOfInstanceFieldInfos |
    GetInstanceFieldInfo |
    GetNumOfStaticFieldInfos |
    GetStaticFieldInfo |
    GetStaticFieldName |
    GetStaticFieldType |
    GetStaticFieldAnnotations |
    GetFieldName |
    GetFieldType |
    GetFieldAnnotations |
    GetFieldModifier |
    GetStaticFieldModifier |
    GetFieldValue |
    SetFieldValue |
    GetStaticFieldValue |
    SetStaticFieldValue |
    GetFieldDeclaringType |
    GetParameterIndex |
    GetParameterName |
    GetParameterType |
    GetParameterAnnotations |
    GetRelatedPackageInf |
    GetPackageName |
    GetPackageNumOfTypeInfos |
    GetPackageTypeInfo |
    GetPackageNumOfGlobalMethods |
    GetPackageGlobalMethodInfo |
    GetPackageNumOfGlobalFieldInfos |
    GetPackageGlobalFieldInfo |
    LoadPackage |
    GetPackageByQualifiedName |
    GetPackageVersion |
    GetSubPackages |
    ReflectionIntrinsicEndFlag |
    Sleep |
    SourceFile |
    SourceLine |
    IdentityHashCode |
    IdentityHashCodeForArray |
    AtomicLoad |
    AtomicStore |
    AtomicSwap |
    AtomicCompareAndSwap |
    AtomicFetchAdd |
    AtomicFetchSub |
    AtomicFetchAnd |
    AtomicFetchOr |
    AtomicFetchXor |
    MutexInit |
    CjMutexLock |
    MutexTryLock |
    MutexCheckStatus |
    MutexUnlock |
    WaitQueueInit |
    MonitorInit |
    MoitiorWait |
    MoitiorNotify |
    MoitiorNotifyAll |
    MulticonditionWait |
    MulticonditionNotify |
    MulticonditionNotifyAll |
    CrossAccessBarrier |
    CreateExportHandle |
    GetExportedRef |
    RemoveExportedRef |
    FfiCjAstLex |
    FfiCjAstParseExpr |
    FfiCjAstParseDecl |
    FfiCjAstParsePropMemberDecl |
    FfiCjAstParsePriConstructor |
    FfiCjAstParsePattern |
    FfiCjAstParseType |
    FfiCjAstParseTopLevel |
    FfiCjAstDiagReport |
    FfiCjParentContext |
    FfiCjMacroItemInfo |
    FfiCjGetChildMessages |
    FfiCjCheckAddSpace |
    CgUnsafeBegin |
    CgUnsafeEnd |
    Strlen |
    MemcpyS |
    MemsetS |
    Free |
    Malloc |
    Strcmp |
    Memcmp |
    Strncmp |
    Strcasecmp |
    AtomicInt8Load |
    AtomicInt8Store |
    AtomicInt8Swap |
    AtomicInt8Cas |
    AtomicInt8FetchAdd |
    AtomicInt8FetchSub |
    AtomicInt8FetchAnd |
    AtomicInt8FetchOr |
    AtomicInt8FetchXor |
    AtomicInt16Load |
    AtomicInt16Store |
    AtomicInt16Swap |
    AtomicInt16Cas |
    AtomicInt16FetchAdd |
    AtomicInt16FetchSub |
    AtomicInt16FetchAnd |
    AtomicInt16FetchOr |
    AtomicInt16FetchXor |
    AtomicInt32Load |
    AtomicInt32Store |
    AtomicInt32Swap |
    AtomicInt32Cas |
    AtomicInt32FetchAdd |
    AtomicInt32FetchSub |
    AtomicInt32FetchAnd |
    AtomicInt32FetchOr |
    AtomicInt32FetchXor |
    AtomicInt64Load |
    AtomicInt64Store |
    AtomicInt64Swap |
    AtomicInt64Cas |
    AtomicInt64FetchAdd |
    AtomicInt64FetchSub |
    AtomicInt64FetchAnd |
    AtomicInt64FetchOr |
    AtomicInt64FetchXor |
    AtomicUint8Load |
    AtomicUint8Store |
    AtomicUint8Swap |
    AtomicUint8Cas |
    AtomicUint8FetchAdd |
    AtomicUint8FetchSub |
    AtomicUint8FetchAnd |
    AtomicUint8FetchOr |
    AtomicUint8FetchXor |
    AtomicUint16Load |
    AtomicUint16Store |
    AtomicUint16Swap |
    AtomicUint16Cas |
    AtomicUint16FetchAdd |
    AtomicUint16FetchSub |
    AtomicUint16FetchAnd |
    AtomicUint16FetchOr |
    AtomicUint16FetchXor |
    AtomicUint32Load |
    AtomicUint32Store |
    AtomicUint32Swap |
    AtomicUint32Cas |
    AtomicUint32FetchAdd |
    AtomicUint32FetchSub |
    AtomicUint32FetchAnd |
    AtomicUint32FetchOr |
    AtomicUint32FetchXor |
    AtomicUint64Load |
    AtomicUint64Store |
    AtomicUint64Swap |
    AtomicUint64Cas |
    AtomicUint64FetchAdd |
    AtomicUint64FetchSub |
    AtomicUint64FetchAnd |
    AtomicUint64FetchOr |
    AtomicUint64FetchXor |
    AtomicBoolLoad |
    AtomicBoolStore |
    AtomicBoolSwap |
    AtomicBoolCas |
    AtomicReferenceBaseLoad |
    AtomicReferenceBaseStore |
    AtomicReferenceBaseSwap |
    AtomicReferenceBaseCas |
    AtomicOptionReferenceLoad |
    AtomicOptionReferenceStore |
    AtomicOptionReferenceSwap |
    AtomicOptionReferenceCas |
    BeginCatch |
    Abs |
    Fabs |
    Floor |
    Ceil |
    Trunc |
    Sin |
    Cos |
    Exp |
    Exp2 |
    Log |
    Log2 |
    Log10 |
    Sqrt |
    Round |
    Pow |
    Powi |
    BitCast |
    Preinitialize |
    ObjectAs |
    IsNull |
    GetTypeForTypeParameter |
    IsSubtypeTypes
}

@Derive[Equatable]
@Derive[ToString]
internal enum SourceExpr {
    IfExpr
    | WhileExpr
    | DoWhileExpr
    | MatchExpr
    | IfLetOrWhileLet
    | Quest
    | Binary
    | ForInExpr
    | Other
}

sealed abstract class Expression <: Base & ToString & Hashable & Equatable<Expression> {
    internal let _kind: ExprKind
    internal var _operands: ArrayList<Value>
    internal var _blockGroups = ArrayList<BlockGroup>()
    internal var _owner: ?Block = None
    internal var _result: ?LocalVar = None

    public func hashCode(): Int64 {
        return _result.getOrThrow().hashCode()
    }

    public operator func==(other: Expression): Bool {
        return this._result.getOrThrow() == other._result.getOrThrow()
    }

    public prop operands: Array<Value> {
        get() {
            return _operands.toArray()
        }
    }

    public prop blockGroups: Array<BlockGroup> {
        get() {
            return _blockGroups.toArray()
        }
    }

    public prop owner: Block {
        get() {
            return _owner
        }
    }

    public func destroySelf(): Unit {
        for (op in _operands) {
            op._users.removeIf({ e => e == this })
        }
        _operands.clear()
        for (blockGroup in _blockGroups) {
            blockGroup.destroySelf()
        }
        _blockGroups.clear()
        _owner._exprs.removeIf({ e => e == this })
    }

    public prop result: LocalVar {
        get() {
            if (resultIsValid()) {
                return _result.getOrThrow()
            }
            throw Exception("Result is not valid")
        }
    }
    public prop successors: Array<Block> {
        get() {
            return _operands.filter({ op => op.isBlock() }).map({ op => (op as Block).getOrThrow() }).toArray()
        }
    }
    public func moveBefore(other: Expression): Unit {
        assert(!this.isTerminator(), "Terminator expression cannot be moved in front of another expression")
        if (this == other) {
            return
        }
        // 1. remove current expr from parent block
        this._owner._exprs.removeIf({ e => e == this })

        // 2. get offset
        var index = -1
        for (i in 0..other._owner._exprs.size) {
            if (other._owner._exprs[i] == this) {
                index = i
                break
            }
        }
        assert(index != -1, "target expression: ${other.toString()} Not found in block: ${other._owner.toString()}")
        
        // 3. insert current expr before `other`
        other._owner._exprs.add(this, at: index)

        // 4. update current expr's owner
        this._owner = other._owner
    }
    public func moveAfter(other: Expression): Unit {
        assert(!other.isTerminator(), "An expression cannot be moved behind terminator expression")
        if (this == other) {
            return
        }
        // 1. remove current expr from parent block
        this._owner._exprs.removeIf({ e => e == this })

        // 2. update successor's predecessors
        if (this.isTerminator()) {
            for (successor in this.successors) {
                successor._predecessors.removeIf({ bb => bb == this._owner })
            }
        }

        // 3. get offset
        var index = -1
        for (i in 0..other._owner._exprs.size) {
            if (other._owner._exprs[i] == this) {
                index = i
                break
            }
        }
        assert(index != -1, "target expression: ${other.toString()} Not found in block: ${other._owner.toString()}")

        // 4. insert current expr after `other`
        other._owner._exprs.add(this, at: index + 1)

        // 5. update current expr's owner
        this._owner = other._owner
    }

    public func hasExceptionBranch(): Bool {
        match (kind) {
            case TryApply => true
            case TryInvoke => true
            case TryIntrinsic => true
            case TrySpawn => true
            case TypeCastWithException => true
            case TryAllocate => true
            case TryRawArrayAllocate => true
            case _ => false
        }
    }
    public func dump(): Unit {
        println(toString())
    }
    internal func baseOpsToString(): String {
        return valueVecToString(_operands, hasExceptionBranch())
    }
    protected open func operandsToString(): String {
        return baseOpsToString()
    }
    protected open func getExtraCommentString(): String {
        return ""
    }
    internal func getCommentString(): String {
        var comments = ArrayList<String>()
        if (let c <- baseCommentToString() && !c.isEmpty()) {
            comments.add(c)
        }
        if (let c <- getExtraCommentString() && !c.isEmpty()) {
            comments.add(c)
        }
        if (comments.isEmpty()) {
            return ""
        }
        return " // " + String.join(comments.toArray(), delimiter: ", ")
    }
    protected open func kindToString(): String {
        return _kind.toString()
    }
    public open func toString(): String {
        var res = ""
        if (resultIsValid()) {
            if (result._isRetValue) {
                res += "[ret] "
            }
            res += result.identifier + ": " + result.ty.toString() + " = "
        }
        res += _kind.toString() + "(" + operandsToString() + ")"
        res += getCommentString()
        return res
    }
    public prop topLevelFunc: Function {
        get() {
            return _owner.topLevelFunc
        }
    }

    public func isTerminator(): Bool {
        if (kind.isTerminator()) {
            return true
        }
        if (kind.isUnary() || kind.isBinary()) {
            if (operands.isEmpty()) {
                return false
            }
            return operands[operands.size - 1].isBlock()
        }
        return false
    }
    public func isLambda(): Bool {
        return kind == ExprKind.Lambda
    }
    public func isGetRTTIStatic(): Bool {
        return kind == ExprKind.GetRttiStatic
    }
    public func isGetRTTI(): Bool {
        return kind == ExprKind.GetRtti
    }
    public func isExit(): Bool {
        return kind == ExprKind.Exit
    }

    internal init(kind: ExprKind, operands: ArrayList<Value>) {
        this._kind = kind
        this._operands = operands
    }

    internal init(kind: ExprKind, owner: Block) {
        this._kind = kind
        this._operands = ArrayList<Value>()
    }

    internal func resultIsValid(): Bool {
        match (_kind) {
            case ExprKind.Goto | ExprKind.Exit | ExprKind.MultiBranch | ExprKind.Branch |
                 ExprKind.RaiseException => false
            case _ => true
        }
    }
}

public class UnaryExpression <: Expression {
    internal let _overflow: OverflowStrategy

    protected override func getExtraCommentString(): String {
        if (_overflow != OverflowStrategy.NA) {
            return "Overflow: " + _overflow.toString()
        }
        return ""
    }

    public init(kind: ExprKind, op: Value, overflow: OverflowStrategy, owner: Block) {
        super(kind, ArrayList<Value>([op]), owner)
        this._overflow = overflow
    }

    internal init(kind: ExprKind, op: Value, owner: Block) {
        super(kind, ArrayList<Value>([op]), owner)
        this._overflow = OverflowStrategy.NA
        if (kind == ExprKind.Neg) {
            throw Exception("unary Neg must have an overflow strategy")
        }
    }

    internal init(kind: ExprKind, op: Value, owner: Block, normal: Block, err: Block) {
        super(kind, ArrayList<Value>([op]), owner)
        this._overflow = OverflowStrategy.THROWING
        _operands.add(normal)
        _operands.add(err)
    }
}

public class BinaryExpression <: Expression {
    internal let _overflow: OverflowStrategy

    protected override func getExtraCommentString(): String {
        if (_overflow != OverflowStrategy.NA) {
            return "Overflow: " + _overflow.toString()
        }
        return ""
    }

    internal init(kind: ExprKind, leftOp: Value, rightOp: Value, overflow: OverflowStrategy, owner: Block) {
        super(kind, ArrayList<Value>([leftOp, rightOp]), owner)
        this._overflow = overflow
    }

    internal init(kind: ExprKind, leftOp: Value, rightOp: Value, owner: Block) {
        super(kind, ArrayList<Value>([leftOp, rightOp]), owner)
        this._overflow = OverflowStrategy.NA
        if (kind.isMathematicalOperator() || kind == ExprKind.LShift || kind == ExprKind.RShift) {
            throw Exception("binary " + kind.toString() + " must have an overflow strategy")
        }
    }

    internal init(kind: ExprKind, leftOp: Value, rightOp: Value, owner: Block, normal: Block, err: Block) {
        super(kind, ArrayList<Value>([leftOp, rightOp]), owner)
        this._overflow = OverflowStrategy.THROWING
        _operands.add(normal)
        _operands.add(err)
        if (kind == ExprKind.Div) {
            throw Exception("binary Div must have an overflow strategy, maybe you could div 0 in runtime.")
        }
    }
    internal init(kind: ExprKind, leftOp: Value, rightOp: Value, overflow: OverflowStrategy, owner: Block, normal: Block, err: Block) {
        super(kind, ArrayList<Value>([leftOp, rightOp]), owner)
        this._overflow = overflow
        _operands.add(normal)
        _operands.add(err)
        if (kind != ExprKind.Div && overflow != OverflowStrategy.THROWING) {
            throw Exception("binary " + kind.toString() + " must have a throwing overflow strategy, can't be " + overflow.toString() + " in try catch block.")
        }
    }
}

public class Constant <: Expression {
    internal init(val: LiteralValue, owner: Block) {
        super(ExprKind.Constant, ArrayList<Value>([val]), owner)
    }
}

public class Allocate <: Expression {
    internal let _allocatedType: Type

    public prop allocatedType: Type {
        get() {
            return _allocatedType
        }
    }

    internal prop normalBranch: Block {
        get() {
            if (kind == ExprKind.TryAllocate) {
                return (operands[operands.size - 2] as Block).getOrThrow()
            }
            throw Exception("Allocate: " + this.toString() + " has no normal target")
        }
    }

    internal prop errorBranch: Block {
        get() {
            if (kind == ExprKind.TryAllocate) {
                return (operands[operands.size - 1] as Block).getOrThrow()
            }
            throw Exception("Allocate: " + this.toString() + " has no error target")
        }
    }
    protected override func operandsToString(): String {
        var res = _allocatedType.toString()
        if (let temp <- baseOpsToString() && !temp.isEmpty()) {
            res += ", " + temp
        }
        return res
    }

    internal init(allocatedType: Type, owner: Block) {
        super(ExprKind.Allocate, owner)
        this._allocatedType = allocatedType
    }

    internal init(allocatedType: Type, owner: Block, normal: Block, err: Block) {
        super(ExprKind.TryAllocate, owner)
        _operands.add(normal)
        _operands.add(err)
        this._allocatedType = allocatedType
    }
}

public class Load <: Expression {
    internal init(location: Value, owner: Block) {
        super(ExprKind.Load, ArrayList<Value>([location]), owner)
    }
    public prop srcLocation: Value {
        get() {
            return operands[0]
        }
    }
}

public class Store <: Expression {
    internal init(val: Value, location: Value, owner: Block) {
        super(ExprKind.Store, ArrayList<Value>([val, location]), owner)
    }
    public prop srcValue: Value {
        get() {
            return operands[0]
        }
    }
    public prop dstLocation: Value {
        get() {
            return operands[1]
        }
    }
}

internal class GetElementByName <: Expression {
    internal let _fieldNames: ArrayList<String>

    public prop fieldNames: Array<String> {
        get() {
            return _fieldNames.toArray()
        }
    }

    protected override func operandsToString(): String {
        let fieldStr = "[" + String.join(_fieldNames.toArray(), delimiter: ", ") + "]"
        return baseOpsToString() + ", field: " + fieldStr
    }

    internal init(location: Value, fieldNames: ArrayList<String>, owner: Block) {
        super(ExprKind.GetElementByName, ArrayList<Value>([location]), owner)
        this._fieldNames = fieldNames
    }
}

internal class StoreElementByName <: Expression {
    private let _fieldNames: ArrayList<String>

    public prop fieldNames: Array<String> {
        get() {
            return _fieldNames.toArray()
        }
    }

    protected override func operandsToString(): String {
        let fieldStr = "[" + String.join(_fieldNames.toArray(), delimiter: ", ") + "]"
        return baseOpsToString() + ", field: " + fieldStr
    }

    internal init(val: Value, location: Value, fieldNames: ArrayList<String>, owner: Block) {
        super(ExprKind.StoreElementByName, ArrayList<Value>([val, location]), owner)
        this._fieldNames = fieldNames
    }
}

public class FuncCallContext {
    internal let _args: ArrayList<Value>
    internal let _instTypeArgs: ArrayList<Type>
    internal let _thisType: Type
    public init(
        args!: Array<Value> = Array<Value>(),
        instTypeArgs!: Array<Type> = Array<Type>(),
        thisType!: Type = InvalidType.get()) {
        this._args = ArrayList<Value>.of(args)
        this._instTypeArgs = ArrayList<Type>.of(instTypeArgs)
        this._thisType = thisType
    }
    public prop args: Array<Value> {
        get() {
            return _args.toArray()
        }
    }
    public prop instTypeArgs: Array<Type> {
        get() {
            return _instTypeArgs.toArray()
        }
    }
    public prop thisType: Type {
        get() {
            if (_thisType == InvalidType.get()) {
                throw Exception("FuncCallContext: thisType is invalid")
            }
            return _thisType
        }
    }
    public func thisTypeIsValid(): Bool {
        return _thisType != InvalidType.get()
    }
}

internal struct VirMethodContext {
    public VirMethodContext(let srcCodeIdentifier: String, let originalFuncType: FuncType, let genericTypeParams: Array<GenericType>) {

    }
}

internal struct InvokeCallContext {
    public InvokeCallContext(let caller: Value, let funcCallCtx: FuncCallContext, let virMethodCtx: VirMethodContext) {

    }
}

sealed abstract class FuncCall <: Expression {
    internal let _instantiatedTypeArgs: ArrayList<Type>
    internal let _thisType: Type

    public prop instantiatedTypeArgs: Array<Type> {
        get() {
            return _instantiatedTypeArgs.toArray()
        }
    }

    public prop thisType: Type {
        get() {
            if (_thisType == InvalidType.get()) {
                throw Exception("FuncCall: thisType is invalid")
            }
            return _thisType
        }
    }

    public func getArgs(): Array<Value>

    public func thisTypeIsValid(): Bool {
        return _thisType != InvalidType.get()
    }

    internal init(kind: ExprKind, funcCallCtx: FuncCallContext, owner: Block) {
        super(kind, funcCallCtx._args, owner)
        this._instantiatedTypeArgs = funcCallCtx._instTypeArgs
        if (funcCallCtx.thisTypeIsValid()) {
            this._thisType = funcCallCtx.thisType
        } else {
            this._thisType = InvalidType.get()
        }
    }
}

public class Apply <: FuncCall {
    internal var _isSuperCall: Bool = false

    internal mut prop isSuperCall: Bool {
        get() {
            return _isSuperCall
        }
        set(v) {
            _isSuperCall = v
        }
    }
    public prop callee: Value {
        get() {
            return operands[0]
        }
    }
    public override func getArgs(): Array<Value> {
        if (isTerminator()) {
            return operands[1..operands.size - 2]
        }
        return operands[1..operands.size].toArray()
    }
    internal prop normalBranch: Block {
        get() {
            if (kind == ExprKind.TryApply) {
                return (operands[operands.size - 2] as Block).getOrThrow()
            }
            throw Exception("Apply: " + this.toString() + " has no normal target")
        }
    }

    internal prop errorBranch: Block {
        get() {
            if (kind == ExprKind.TryApply) {
                return (operands[operands.size - 1] as Block).getOrThrow()
            }
            throw Exception("Apply: " + this.toString() + " has no error target")
        }
    }

    protected override func operandsToString(): String {
        var opStr = ""
        if (thisTypeIsValid()) {
            opStr += thisType.toString() + "::"
        }
        opStr += callee.identifier
        opStr += typeVecToString("<", instantiatedTypeArgs, ">")
        if (let temp <- baseOpsToString() && !temp.isEmpty()) {
            opStr += ", " + temp
        }
        return opStr
    }
    protected override func getExtraCommentString(): String {
        if (isSuperCall) {
            return "isSuperCall"
        }
        return ""
    }

    internal init(callee: Value, funcCallCtx: FuncCallContext, owner: Block) {
        super(ExprKind.Apply, funcCallCtx, owner)
        _operands.add(callee, at: 0)
    }

    internal init(callee: Value, funcCallCtx: FuncCallContext, owner: Block, normal: Block, err: Block) {
        super(ExprKind.TryApply, funcCallCtx, owner)
        _operands.add(callee, at: 0)
        _operands.add(normal)
        _operands.add(err)
    }
}

internal class Intrinsic <: FuncCall {
    internal let _calleeKind: IntrinsicKind

    internal prop calleeKind: IntrinsicKind {
        get() {
            return _calleeKind
        }
    }
    protected override func kindToString(): String {
        return "Intrinsic/" + _calleeKind.toString()
    }
    public override func getArgs(): Array<Value> {
        if (isTerminator()) {
            return operands[0..operands.size - 2].toArray()
        }
        return operands.toArray()
    }

    internal init(calleeKind: IntrinsicKind, funcCallCtx: FuncCallContext, owner: Block) {
        super(ExprKind.Intrinsic, funcCallCtx, owner)
        this._calleeKind = calleeKind
    }

    internal init(calleeKind: IntrinsicKind, funcCallCtx: FuncCallContext, owner: Block, normal: Block, err: Block) {
        super(ExprKind.TryIntrinsic, funcCallCtx, owner)
        this._calleeKind = calleeKind
        _operands.add(normal)
        _operands.add(err)
    }

    internal prop normalBranch: Block {
        get() {
            if (kind == ExprKind.TryIntrinsic) {
                return (operands[operands.size - 2] as Block).getOrThrow()
            }
            throw Exception("Intrinsic: " + this.toString() + " has no normal target")
        }
    }

    internal prop errorBranch: Block {
        get() {
            if (kind == ExprKind.TryIntrinsic) {
                return (operands[operands.size - 1] as Block).getOrThrow()
            }
            throw Exception("Intrinsic: " + this.toString() + " has no error target")
        }
    }
}

internal class Invoke <: FuncCall {
    internal let _virMethodCtx: VirMethodContext

    public override func getArgs(): Array<Value> {
        if (isTerminator()) {
            return operands[1..operands.size - 2].toArray()
        }
        return operands[1..operands.size].toArray()
    }
    public prop methodName: String {
        get() {
            return _virMethodCtx.srcCodeIdentifier
        }
    }

    public prop methodType: FuncType {
        get() {
            return _virMethodCtx.originalFuncType
        }
    }

    public prop methodGenericTypeParams: Array<GenericType> {
        get() {
            return _virMethodCtx.genericTypeParams.toArray()
        }
    }

    internal func calleeIsStatic(): Bool {
        let caller = operands[0]
        if (!caller.isLocalVar()) {
            return false
        }
        let callerLocalVar = (caller as LocalVar).getOrThrow()
        return callerLocalVar.expr.isGetRTTIStatic() || callerLocalVar.expr.isGetRTTI()
    }
    protected override func operandsToString(): String {
        var opStr = thisType.toString() + "::"
        opStr += methodName
        opStr += typeVecToString("<", instantiatedTypeArgs, ">")
        opStr += ": " + methodType.toString()
        if (let temp <- baseOpsToString() && !temp.isEmpty()) {
            opStr += ", " + temp
        }
        return opStr
    }

    internal init(callContext: InvokeCallContext, owner: Block) {
        super(ExprKind.Invoke, callContext.funcCallCtx, owner)
        _operands.add(callContext.caller, at: 0)
        _virMethodCtx = callContext.virMethodCtx
    }

    internal init(callContext: InvokeCallContext, owner: Block, normal: Block, err: Block) {
        super(ExprKind.TryInvoke, callContext.funcCallCtx, owner)
        _operands.add(callContext.caller, at: 0)
        _operands.add(normal)
        _operands.add(err)
        _virMethodCtx = callContext.virMethodCtx
    }

    public prop normalBranch: Block {
        get() {
            if (kind == ExprKind.TryInvoke) {
                return (operands[operands.size - 2] as Block).getOrThrow()
            }
            throw Exception("Invoke: " + this.toString() + " has no normal target")
        }
    }

    public prop errorBranch: Block {
        get() {
            if (kind == ExprKind.TryInvoke) {
                return (operands[operands.size - 1] as Block).getOrThrow()
            }
            throw Exception("Invoke: " + this.toString() + " has no error target")
        }
    }
}

internal class GetRTTI <: Expression {
    internal init(val: Value, owner: Block) {
        super(ExprKind.GetRtti, ArrayList<Value>([val]), owner)
    }
}

internal class GetRTTIStatic <: Expression {
    private let _ty: Type

    public prop ty: Type {
        get() {
            return _ty
        }
    }
    protected override func operandsToString(): String {
        return ty.toString()
    }

    internal init(ty: Type, owner: Block) {
        super(ExprKind.GetRttiStatic, owner)
        this._ty = ty
    }
}

internal class TypeCast <: Expression {
    internal let _overflow: OverflowStrategy

    protected override func getExtraCommentString(): String {
        if (overflow != OverflowStrategy.NA) {
            return "Overflow: " + overflow.toString()
        }
        return ""
    }
    public prop sourceType: Type {
        get() {
            return operands[0].ty
        }
    }
    public prop targetType: Type {
        get() {
            return result.ty
        }
    }

    public prop overflow: OverflowStrategy {
        get() {
            return _overflow
        }
    }

    internal init(srcVal: Value, owner: Block) {
        super(ExprKind.TypeCast, ArrayList<Value>([srcVal]), owner)
        this._overflow = OverflowStrategy.NA
    }
    internal init(srcVal: Value, overflow: OverflowStrategy, owner: Block) {
        super(ExprKind.TypeCast, ArrayList<Value>([srcVal]), owner)
        this._overflow = overflow
    }
    internal init(srcVal: Value, owner: Block, normal: Block, err: Block) {
        super(ExprKind.TypeCastWithException, ArrayList<Value>([srcVal]), owner)
        _operands.add(normal)
        _operands.add(err)
        this._overflow = OverflowStrategy.THROWING
    }

    public prop normalBranch: Block {
        get() {
            if (kind == ExprKind.TypeCastWithException) {
                return (operands[operands.size - 2] as Block).getOrThrow()
            }
            throw Exception("TypeCast: " + this.toString() + " has no normal target")
        }
    }

    public prop errorBranch: Block {
        get() {
            if (kind == ExprKind.TypeCastWithException) {
                return (operands[operands.size - 1] as Block).getOrThrow()
            }
            throw Exception("TypeCast: " + this.toString() + " has no error target")
        }
    }
}

internal class InstanceOf <: Expression {
    private let _targetType: Type

    public prop targetType: Type {
        get() {
            return _targetType
        }
    }
    protected override func operandsToString(): String {
        return baseOpsToString() + ", " + _targetType.toString()
    }

    internal init(srcVal: Value, targetTy: Type, owner: Block) {
        super(ExprKind.InstanceOf, ArrayList<Value>([srcVal]), owner)
        this._targetType = targetTy
    }
}

internal class Tuple <: Expression {
    internal init(elements: ArrayList<Value>, owner: Block) {
        super(ExprKind.Tuple, elements, owner)
    }
    public prop elements: Array<Value> {
        get() {
            return operands.toArray()
        }
    }
}

internal class FieldByName <: Expression {
    internal let _fieldNames: ArrayList<String>

    public prop fieldNames: Array<String> {
        get() {
            return _fieldNames.toArray()
        }
    }

    protected override func operandsToString(): String {
        let fieldStr = "[" + String.join(_fieldNames.toArray(), delimiter: ", ") + "]"
        return baseOpsToString() + ", path: " + fieldStr
    }

    internal init(location: Value, fieldNames: ArrayList<String>, owner: Block) {
        super(ExprKind.FieldByName, ArrayList<Value>([location]), owner)
        this._fieldNames = fieldNames
    }
}

internal class Field <: Expression {
    internal let _path: ArrayList<UInt64>

    public prop path: Array<UInt64> {
        get() {
            return _path.toArray()
        }
    }

    protected override func operandsToString(): String {
        let strArray = ArrayList<String>(_path.size, { i => _path[i].toString() })
        let pathStr = "[" + String.join(strArray.toArray(), delimiter: ", ") + "]"
        return baseOpsToString() + ", path: " + pathStr
    }

    internal init(location: Value, path: ArrayList<UInt64>, owner: Block) {
        super(ExprKind.Field, ArrayList<Value>([location]), owner)
        this._path = path
    }
}

internal class RawArrayAllocate <: Expression {
    private let _elementType: Type

    public prop elementType: Type {
        get() {
            return _elementType
        }
    }

    protected override func operandsToString(): String {
        return _elementType.toString() + ", " + baseOpsToString()
    }

    internal init(elementType: Type, size: Value, owner: Block) {
        super(ExprKind.RawArrayAllocate, ArrayList<Value>([size]), owner)
        this._elementType = elementType
    }

    internal init(elementType: Type, size: Value, owner: Block, normal: Block, err: Block) {
        super(ExprKind.TryRawArrayAllocate, ArrayList<Value>([size]), owner)
        _operands.add(normal)
        _operands.add(err)
        this._elementType = elementType
    }

    public prop normalBranch: Block {
        get() {
            if (kind == ExprKind.TryRawArrayAllocate) {
                return (operands[operands.size - 2] as Block).getOrThrow()
            }
            throw Exception("RawArrayAllocate: " + this.toString() + " has no normal target")
        }
    }

    public prop errorBranch: Block {
        get() {
            if (kind == ExprKind.TryRawArrayAllocate) {
                return (operands[operands.size - 1] as Block).getOrThrow()
            }
            throw Exception("RawArrayAllocate: " + this.toString() + " has no error target")
        }
    }
}

internal class RawArrayLiteralInit <: Expression {
    internal init(memory: Value, elements: ArrayList<Value>, owner: Block) {
        super(ExprKind.RawArrayLiteralInit, elements, owner)
        _operands.add(memory, at: 0)
    }
}

internal class RawArrayInitByValue <: Expression {
    internal init(memory: Value, size: Value, initVal: Value, owner: Block) {
        super(ExprKind.RawArrayInitByValue, ArrayList<Value>([memory, size, initVal]), owner)
    }
}

internal class VArrayExpr <: Expression {
    internal init(elements: ArrayList<Value>, owner: Block) {
        super(ExprKind.`VArrayExpr`, elements, owner)
    }
}

internal class VArrayBuilder <: Expression {
    internal init(size: Value, initVal: Value, initFunc: Value, owner: Block) {
        super(ExprKind.VArrayBuilder, ArrayList<Value>([size, initVal, initFunc]), owner)
    }
}

internal class GetException <: Expression {
    internal init(owner: Block) {
        super(ExprKind.GetException, owner)
    }
}

internal class Lambda <: Expression {
    private let _identifier: String
    private let _srcCodeIdentifier: String
    private let _funcType: FuncType
    protected var _parameters = ArrayList<Parameter>()
    private var _isLocalFunc: Bool = false
    internal var _genericTypeParams = ArrayList<GenericType>()
    private var _paramDftValHostFunc: ?Lambda = None
    protected var _returnValue: ?LocalVar = None
    private var _isCompileTimeValue: Bool = false

    protected override func getExtraCommentString(): String {
        var comments = ArrayList<String>()
        if (!_srcCodeIdentifier.isEmpty()) {
            comments.add("srcCodeIdentifier: " + _srcCodeIdentifier)
        }
        if (_paramDftValHostFunc.isSome()) {
            comments.add("paramDftValHostFunc: " + _paramDftValHostFunc.getOrThrow().identifier)
        }
        if (comments.isEmpty()) {
            return ""
        }
        return String.join(comments.toArray(), delimiter: ", ")
    }
    public prop identifier: String {
        get() {
            return _identifier
        }
    }

    public prop srcCodeIdentifier: String {
        get() {
            return _srcCodeIdentifier
        }
    }

    public prop funcType: FuncType {
        get() {
            return _funcType
        }
    }

    public prop parameters: Array<Parameter> {
        get() {
            return _parameters.toArray()
        }
    }

    public prop genericTypeParams: Array<GenericType> {
        get() {
            return _genericTypeParams.toArray()
        }
    }

    protected mut prop paramDftValHostFunc: Lambda {
        get() {
            return _paramDftValHostFunc.getOrThrow()
        }
        set(v) {
            _paramDftValHostFunc = v
        }
    }

    public mut prop isLocalFunc: Bool {
        get() {
            return _isLocalFunc
        }
        set(v) {
            _isLocalFunc = v
        }
    }

    public prop returnValue: LocalVar {
        get() {
            return _returnValue.getOrThrow()
        }
    }

    public mut prop isCompileTimeValue: Bool {
        get() {
            return _isCompileTimeValue
        }
        set(v) {
            _isCompileTimeValue = v
        }
    }
    internal func addBody(): BlockGroup {
        if (_blockGroups.size != 0) {
            throw Exception("Lambda body already set")
        }
        let identifier = topLevelFunc.generateBlockGroupId().toString()
        let body = BlockGroup(identifier, _result.getOrThrow())
        _blockGroups.add(body)
        return body
    }
    public prop body: BlockGroup {
        get() {
            return _blockGroups[0]
        }
    }

    public func appendParameter(ty: Type): Parameter {
        let identifier = LOCAL_VAR_PREFIX + topLevelFunc.generateLocalId().toString()
        let result = Parameter(ty, identifier, this)
        _parameters.add(result)
        return result
    }

    public func toString(): String {
        return lambdaToString(this, 0)
    }

    protected init(ty: FuncType, identifier: String, srcName: String, genericTypeParams: ArrayList<GenericType>, owner: Block) {
        super(ExprKind.Lambda, owner)
        this._identifier = identifier
        this._srcCodeIdentifier = srcName
        this._funcType = ty
        this._isLocalFunc = false
        this._genericTypeParams = genericTypeParams
    }
}

internal class Debug <: Expression {
    private let _srcCodeIdentifier: String

    public prop srcCodeIdentifier: String {
        get() {
            return _srcCodeIdentifier
        }
    }
    protected override func operandsToString(): String {
        return baseOpsToString() + ", " + _srcCodeIdentifier
    }

    protected init(location: Value, srcName: String, owner: Block) {
        super(ExprKind.Debug, ArrayList<Value>([location]), owner)
        this._srcCodeIdentifier = srcName
    }
}

internal class Spawn <: Expression {
    private var _executeClosure: ?Function = None

    // serializer may query executeClosure; keep it settable
    public mut prop executeClosure: Function {
        get() {
            return _executeClosure.getOrThrow()
        }
        set(v) {
            _executeClosure = v
        }
    }
    public func needExecuteClosure(): Bool {
        return _executeClosure.isSome()
    }
    protected override func getExtraCommentString(): String {
        if (needExecuteClosure()) {
            return "executeClosure: " + executeClosure.identifier
        }
        return ""
    }

    protected init(lambda: Value, owner: Block) {
        super(ExprKind.Spawn, ArrayList<Value>([lambda]), owner)
    }

    protected init(lambda: Value, arg: Value, owner: Block) {
        super(ExprKind.Spawn, ArrayList<Value>([lambda, arg]), owner)
    }

    protected init(lambda: Value, owner: Block, normal: Block, err: Block) {
        super(ExprKind.TrySpawn, ArrayList<Value>([lambda]), owner)
        _operands.add(normal)
        _operands.add(err)
    }

    protected init(lambda: Value, arg: Value, owner: Block, normal: Block, err: Block) {
        super(ExprKind.TrySpawn, ArrayList<Value>([lambda, arg]), owner)
        _operands.add(normal)
        _operands.add(err)
    }

    public prop normalBranch: Block {
        get() {
            if (kind == ExprKind.TrySpawn) {
                return (operands[operands.size - 2] as Block).getOrThrow()
            }
            throw Exception("Spawn: " + this.toString() + " has no normal target")
        }
    }

    public prop errorBranch: Block {
        get() {
            if (kind == ExprKind.TrySpawn) {
                return (operands[operands.size - 1] as Block).getOrThrow()
            }
            throw Exception("Spawn: " + this.toString() + " has no error target")
        }
    }
}

internal class GetInstantiateValue <: Expression {
    internal let _instantiateTypes: ArrayList<Type>

    public prop instantiateTypes: Array<Type> {
        get() {
            return _instantiateTypes.toArray()
        }
    }

    protected init(val: Value, instantiateTypes: ArrayList<Type>, owner: Block) {
        super(ExprKind.GetInstantiateValue, ArrayList<Value>([val]), owner)
        this._instantiateTypes = instantiateTypes
    }
}

public class GoTo <: Expression {
    internal init(target: Block, owner: Block) {
        super(ExprKind.Goto, owner)
        _operands.add(target)
    }
}

public class Branch <: Expression {
    private var _sourceExpr: SourceExpr = SourceExpr.Other

    internal mut prop sourceExpr: SourceExpr {
        get() {
            return _sourceExpr
        }
        set(v) {
            _sourceExpr = v
        }
    }
    public prop trueTarget: Block {
        get() {
            return (operands[1] as Block).getOrThrow()
        }
    }
    public prop falseTarget: Block {
        get() {
            return (operands[2] as Block).getOrThrow()
        }
    }
    protected override func getExtraCommentString(): String {
        return "sourceExpr: " + _sourceExpr.toString()
    }
    internal init(condition: Value, trueTarget: Block, falseTarget: Block, owner: Block) {
        super(ExprKind.Branch, ArrayList<Value>([condition]), owner)
        _operands.add(trueTarget)
        _operands.add(falseTarget)
    }
}

internal class MultiBranch <: Expression {
    private let _caseValues: ArrayList<UInt64>

    public prop caseValues: Array<UInt64> {
        get() {
            return _caseValues.toArray()
        }
    }
    public prop condition: Value {
        get() {
            return operands[0]
        }
    }
    public prop defaultTarget: Block {
        get() {
            return (operands[1] as Block).getOrThrow()
        }
    }
    public prop targetsWithoutDefault: Array<Block> {
        get() {
            return operands[2..operands.size].map({ i => (i as Block).getOrThrow() }).toArray()
        }
    }
    protected override func operandsToString(): String {
        var res = ArrayList<String>()
        res.add(condition.identifier)
        res.add(defaultTarget.identifier)
        for (i in 0..targetsWithoutDefault.size) {
            res.add("[" + caseValues[i].toString() + ", " + targetsWithoutDefault[i].identifier + "]")
        }
        return String.join(res.toArray(), delimiter: ", ")
    }
    protected init(condition: Value, default: Block, targets: ArrayList<Block>, caseValues: ArrayList<UInt64>, owner: Block) {
        super(ExprKind.MultiBranch, ArrayList<Value>([condition]), owner)
        _operands.add(default)
        _operands.add(all: ArrayList<Value>(targets.size, { i => targets[i] }))
        _caseValues = caseValues
    }
}

public class Exit <: Expression {
    protected init(owner: Block) {
        super(ExprKind.Exit, owner)
    }
}

internal class RaiseException <: Expression {
    protected init(value: Value, successor: Block, owner: Block) {
        super(ExprKind.RaiseException, ArrayList<Value>([value]), owner)
        _operands.add(successor)
    }
    protected init(value: Value, owner: Block) {
        super(ExprKind.RaiseException, ArrayList<Value>([value]), owner)
    }
}
