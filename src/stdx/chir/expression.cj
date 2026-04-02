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
public enum OverflowStrategy {
    NA
    | Wrapping
    | Throwing
    | Saturating
}

@Derive[Equatable]
@Derive[ToString]
public enum ExprKind {
    // terminator
    Goto | Branch | MultiBranch | Exit |
    TryApply | TryInvoke | TryIntrinsic |
    RaiseException | TrySpawn | TryNumericCast |
    TryAllocate | TryRawArrayAllocate |

    // unary expr
    Neg | Not | BitNot |

    // binary expr
    Add | Sub | Mul | Div | Mod | Exp |
    LShift | RShift | BitAnd | BitOr | BitXor |
    Lt | Gt | Le | Ge | Equal | NotEqual |
    And | Or |

    // type cast
    StaticCast | Box | UnboxToValue | UnboxToRef | NumericCast |

    // memory expr
    Allocate | Load | Store | GetElementByName | StoreElementByName | Field | FieldByName |

    // array
    RawArrayAllocate | RawArrayLiteralInit | RawArrayInitByValue |
    VArrayExpr | VArrayBuilder |

    // others
    Constant | Debug | Tuple | InstanceOf | GetException | Spawn | Lambda | GetInstantiateValue |
    Apply | Invoke | Intrinsic | GetRtti | GetRttiStatic

    internal func isTerminator(): Bool {
        match (this) {
            case Goto | Branch | MultiBranch | Exit |
            TryApply | TryInvoke | TryIntrinsic |
            RaiseException | TrySpawn | TryNumericCast |
            TryAllocate | TryRawArrayAllocate => true
            case _ => false
        }
    }

    public func isUnary(): Bool {
        match (this) {
            case Neg | Not | BitNot => true
            case _ => false
        }
    }

    public func isBinary(): Bool {
        match (this) {
            case Add | Sub | Mul | Div | Mod | Exp |
            LShift | RShift | BitAnd | BitOr | BitXor |
            Lt | Gt | Le | Ge | Equal | NotEqual |
            And | Or => true
            case _ => false
        }
    }

    public func isMathematicalOperator(): Bool {
        match (this) {
            case Add | Sub | Mul | Div | Mod | Exp => true
            case _ => false
        }
    }

    public func isBitwiseOperator(): Bool {
        match (this) {
            case LShift | RShift | BitAnd | BitOr | BitXor => true
            case _ => false
        }
    }

    public func isComparisonOperator(): Bool {
        match (this) {
            case Lt | Gt | Le | Ge | Equal | NotEqual => true
            case _ => false
        }
    }

    public func isLogicalOperator(): Bool {
        match (this) {
            case And | Or => true
            case _ => false
        }
    }
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
    internal var _owner: Block = Block.invalidValue
    internal var _result: ?LocalVar = None

    public prop kind: ExprKind {
        get() {
            return _kind
        }
    }
    public func hashCode(): Int64 {
        return _result.getOrThrow().hashCode()
    }

    public operator func==(other: Expression): Bool {
        return refEq(this, other)
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

    public prop result: ?LocalVar {
        get() {
            if (resultIsValid()) {
                return _result
            } else {
                return None
            }
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
            case TryNumericCast => true
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
    internal func kindToString(): String {
        if (_kind == ExprKind.Intrinsic || _kind == ExprKind.TryIntrinsic) {
            let calleeKind = (this as IntrinsicBase).getOrThrow()._calleeKind
            return "Intrinsic/" + calleeKind.toString()
        }
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

    internal init(kind: ExprKind, operands: ArrayList<Value>) {
        this._kind = kind
        this._operands = operands
    }

    internal init(kind: ExprKind) {
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

sealed abstract class UnaryExpressionBase <: Expression & Equatable<UnaryExpressionBase> {
    internal let _overflow: OverflowStrategy

    protected override func getExtraCommentString(): String {
        if (_overflow != OverflowStrategy.NA) {
            return "Overflow: " + _overflow.toString()
        }
        return ""
    }

    public mut prop overflow: OverflowStrategy {
        get() {
            return _overflow
        }
        set(v) {
            _overflow = v
        }
    }
    public operator func==(other: UnaryExpressionBase): Bool {
        return refEq(this, other)
    }
    internal init(kind: ExprKind, op: Value, overflow: OverflowStrategy) {
        super(kind, ArrayList<Value>([op]))
        this._overflow = overflow
    }

    internal init(kind: ExprKind, op: Value) {
        super(kind, ArrayList<Value>([op]))
        this._overflow = OverflowStrategy.NA
    }
}

public class UnaryExpression <: UnaryExpressionBase & Equatable<UnaryExpression> {
    public operator func==(other: UnaryExpression): Bool {
        return refEq(this, other)
    }
    public init(kind: ExprKind, op: Value, overflow: OverflowStrategy) {
        super(kind, op, overflow)
    }
    public init(kind: ExprKind, op: Value) {
        super(kind, op)
    }
}

public class TryUnaryExpression <: UnaryExpressionBase & Equatable<TryUnaryExpression> {
    public operator func==(other: TryUnaryExpression): Bool {
        return refEq(this, other)
    }
    public init(kind: ExprKind, op: Value, normal: Block, err: Block) {
        super(kind, op)
        _operands.add(normal)
        _operands.add(err)
        this._overflow = OverflowStrategy.THROWING
    }
}

sealed abstract class BinaryExpressionBase <: Expression & Equatable<BinaryExpressionBase> {
    internal let _overflow: OverflowStrategy

    protected override func getExtraCommentString(): String {
        if (_overflow != OverflowStrategy.NA) {
            return "Overflow: " + _overflow.toString()
        }
        return ""
    }

    public mut prop overflow: OverflowStrategy {
        get() {
            return _overflow
        }
        set(v) {
            _overflow = v
        }
    }
    public operator func==(other: BinaryExpressionBase): Bool {
        return refEq(this, other)
    }
    internal init(kind: ExprKind, leftOp: Value, rightOp: Value, overflow: OverflowStrategy) {
        super(kind, ArrayList<Value>([leftOp, rightOp]))
        this._overflow = overflow
    }

    internal init(kind: ExprKind, leftOp: Value, rightOp: Value) {
        super(kind, ArrayList<Value>([leftOp, rightOp]))
        this._overflow = OverflowStrategy.NA
    }
}

public class BinaryExpression <: BinaryExpressionBase & Equatable<BinaryExpression> {
    public operator func==(other: BinaryExpression): Bool {
        return refEq(this, other)
    }
    public init(kind: ExprKind, leftOp: Value, rightOp: Value, overflow: OverflowStrategy) {
        super(kind, leftOp, rightOp, overflow)
    }

    public init(kind: ExprKind, leftOp: Value, rightOp: Value) {
        super(kind, leftOp, rightOp)
    }
}

public class TryBinaryExpression <: BinaryExpressionBase & Equatable<TryBinaryExpression> {
    public operator func==(other: TryBinaryExpression): Bool {
        return refEq(this, other)
    }
    public init(kind: ExprKind, leftOp: Value, rightOp: Value, normal: Block, err: Block) {
        super(kind, leftOp, rightOp)
        _operands.add(normal)
        _operands.add(err)
        this._overflow = OverflowStrategy.THROWING
    }
    public init(kind: ExprKind, leftOp: Value, rightOp: Value, overflow: OverflowStrategy, normal: Block, err: Block) {
        super(kind, leftOp, rightOp, overflow)
        _operands.add(normal)
        _operands.add(err)
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }
}

public class Constant <: Expression & Equatable<Constant> {
    public operator func==(other: Constant): Bool {
        return refEq(this, other)
    }
    public init(val: LiteralValue) {
        super(ExprKind.Constant, ArrayList<Value>([val]))
    }
}

sealed abstract class AllocateBase <: Expression & Equatable<AllocateBase> {
    public operator func==(other: AllocateBase): Bool {
        return refEq(this, other)
    }
    internal let _allocatedType: Type

    public prop allocatedType: Type {
        get() {
            return _allocatedType
        }
    }

    protected override func operandsToString(): String {
        var res = _allocatedType.toString()
        if (let temp <- baseOpsToString() && !temp.isEmpty()) {
            res += ", " + temp
        }
        return res
    }

    internal init(kind: ExprKind, allocatedType: Type) {
        super(kind)
        this._allocatedType = allocatedType
    }

    internal init(kind: ExprKind, allocatedType: Type, normal: Block, err: Block) {
        super(kind)
        this._allocatedType = allocatedType
        _operands.add(normal)
        _operands.add(err)
    }
}

public class Allocate <: AllocateBase & Equatable<Allocate> {
    public operator func==(other: Allocate): Bool {
        return refEq(this, other)
    }
    public init(allocatedType: Type) {
        super(ExprKind.Allocate, allocatedType)
    }
}

public class TryAllocate <: AllocateBase & Equatable<TryAllocate> {
    public operator func==(other: TryAllocate): Bool {
        return refEq(this, other)
    }
    public init(allocatedType: Type, normal: Block, err: Block) {
        super(ExprKind.TryAllocate, allocatedType, normal, err)
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }
}

public class Load <: Expression & Equatable<Load> {
    public operator func==(other: Load): Bool {
        return refEq(this, other)
    }
    public init(location: Value) {
        super(ExprKind.Load, ArrayList<Value>([location]))
    }
    public prop srcAddress: Value {
        get() {
            return operands[0]
        }
    }
}

public class Store <: Expression & Equatable<Store> {
    public operator func==(other: Store): Bool {
        return refEq(this, other)
    }
    public init(val: Value, location: Value) {
        super(ExprKind.Store, ArrayList<Value>([val, location]))
    }
    public prop srcValue: Value {
        get() {
            return operands[0]
        }
    }
    public prop dstAddress: Value {
        get() {
            return operands[1]
        }
    }
}

public class GetElementByName <: Expression & Equatable<GetElementByName> {
    public operator func==(other: GetElementByName): Bool {
        return refEq(this, other)
    }
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

    public init(location: Value, fieldNames: ArrayList<String>) {
        super(ExprKind.GetElementByName, ArrayList<Value>([location]))
        this._fieldNames = fieldNames
    }
}

public class StoreElementByName <: Expression & Equatable<StoreElementByName> {
    public operator func==(other: StoreElementByName): Bool {
        return refEq(this, other)
    }
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

    public init(val: Value, location: Value, fieldNames: ArrayList<String>) {
        super(ExprKind.StoreElementByName, ArrayList<Value>([val, location]))
        this._fieldNames = fieldNames
    }
}

public class FuncCallContext {
    internal let _args: ArrayList<Value>
    internal let _instTypeArgs: ArrayList<Type>
    internal let _thisType: ?Type
    public init(args: Array<Value>, instTypeArgs: Array<Type>, thisType: ?Type) {
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
    public prop thisType: ?Type {
        get() {
            return _thisType
        }
    }
}

public struct VirMethodContext {
    public VirMethodContext(let srcCodeName: String, let originalFuncType: FuncType, let genericTypeParams: Array<GenericType>) {

    }
}

public struct InvokeCallContext {
    public InvokeCallContext(let caller: Value, let funcCallCtx: FuncCallContext, let virMethodCtx: VirMethodContext) {

    }
}

sealed abstract class FuncCall <: Expression & Equatable<FuncCall> {
    public operator func==(other: FuncCall): Bool {
        return refEq(this, other)
    }
    internal let _instantiatedTypeArgs: ArrayList<Type>
    internal let _thisType: ?Type

    public prop instantiatedTypeArgs: Array<Type> {
        get() {
            return _instantiatedTypeArgs.toArray()
        }
    }

    public prop thisType: ?Type {
        get() {
            return _thisType
        }
    }

    public func getArgs(): Array<Value>

    internal init(kind: ExprKind, funcCallCtx: FuncCallContext) {
        super(kind, funcCallCtx._args)
        this._instantiatedTypeArgs = funcCallCtx._instTypeArgs
        this._thisType = funcCallCtx.thisType
    }
}

sealed abstract class ApplyBase <: FuncCall & Equatable<ApplyBase> {
    public operator func==(other: ApplyBase): Bool {
        return refEq(this, other)
    }
    internal var _isSuperCall: Bool = false

    public prop callee: Value {
        get() {
            return operands[0]
        }
    }
    protected override func operandsToString(): String {
        var opStr = ""
        if (let Some(ty) <- _thisType) {
            opStr += ty.toString() + "::"
        }
        opStr += callee.identifier
        opStr += typeVecToString("<", instantiatedTypeArgs, ">")
        if (let temp <- baseOpsToString() && !temp.isEmpty()) {
            opStr += ", " + temp
        }
        return opStr
    }
    protected override func getExtraCommentString(): String {
        if (_isSuperCall) {
            return "isSuperCall"
        }
        return ""
    }

    internal init(kind: ExprKind, callee: Value, funcCallCtx: FuncCallContext) {
        super(kind, funcCallCtx)
        _operands.add(callee, at: 0)
    }
}

public class Apply <: ApplyBase & Equatable<Apply> {
    public operator func==(other: Apply): Bool {
        return refEq(this, other)
    }
    public override func getArgs(): Array<Value> {
        return operands[1..operands.size].toArray()
    }

    public init(callee: Value, funcCallCtx: FuncCallContext) {
        super(ExprKind.Apply, callee, funcCallCtx)
    }
}

public class TryApply <: ApplyBase & Equatable<TryApply> {
    public operator func==(other: TryApply): Bool {
        return refEq(this, other)
    }
    public override func getArgs(): Array<Value> {
        return operands[1..operands.size - 2]
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }

    public init(callee: Value, funcCallCtx: FuncCallContext, normal: Block, err: Block) {
        super(ExprKind.TryApply, callee, funcCallCtx)
        _operands.add(normal)
        _operands.add(err)
    }
}

sealed abstract class IntrinsicBase <: FuncCall & Equatable<IntrinsicBase> {
    public operator func==(other: IntrinsicBase): Bool {
        return refEq(this, other)
    }
    internal let _calleeKind: IntrinsicKind

    internal init(kind: ExprKind, calleeKind: IntrinsicKind, funcCallCtx: FuncCallContext) {
        super(kind, funcCallCtx)
        this._calleeKind = calleeKind
    }

}

public class Intrinsic <: IntrinsicBase & Equatable<Intrinsic> {
    public operator func==(other: Intrinsic): Bool {
        return refEq(this, other)
    }
    public override func getArgs(): Array<Value> {
        return operands.toArray()
    }

    public init(calleeKind: IntrinsicKind, funcCallCtx: FuncCallContext) {
        super(ExprKind.Intrinsic, calleeKind, funcCallCtx)
    }
}

public class TryIntrinsic <: IntrinsicBase & Equatable<TryIntrinsic> {
    public operator func==(other: TryIntrinsic): Bool {
        return refEq(this, other)
    }
    public override func getArgs(): Array<Value> {
        return operands[0..operands.size - 2].toArray()
    }

    public init(calleeKind: IntrinsicKind, funcCallCtx: FuncCallContext) {
        super(ExprKind.TryIntrinsic, calleeKind, funcCallCtx)
        _operands.add(normal)
        _operands.add(err)
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }
}

sealed abstract class InvokeBase <: FuncCall & Equatable<InvokeBase> {
    public operator func==(other: InvokeBase): Bool {
        return refEq(this, other)
    }
    internal let _virMethodCtx: VirMethodContext

    public prop methodName: String {
        get() {
            return _virMethodCtx.srcCodeName
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

    internal init(kind: ExprKind, callContext: InvokeCallContext) {
        super(kind, callContext.funcCallCtx)
        _operands.add(callContext.caller, at: 0)
        _virMethodCtx = callContext.virMethodCtx
    }
}

public class Invoke <: InvokeBase & Equatable<Invoke> {
    public operator func==(other: Invoke): Bool {
        return refEq(this, other)
    }
    public override func getArgs(): Array<Value> {
        return operands[1..operands.size].toArray()
    }

    public init(callContext: InvokeCallContext) {
        super(ExprKind.Invoke, callContext)
    }
}

public class TryInvoke <: InvokeBase & Equatable<TryInvoke> {
    public operator func==(other: TryInvoke): Bool {
        return refEq(this, other)
    }
    public override func getArgs(): Array<Value> {
        return operands[1..operands.size - 2].toArray()
    }

    public init(callContext: InvokeCallContext) {
        super(ExprKind.TryInvoke, callContext)
        _operands.add(normal)
        _operands.add(err)
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }
}

public class GetRTTI <: Expression & Equatable<GetRTTI> {
    public operator func==(other: GetRTTI): Bool {
        return refEq(this, other)
    }
    public init(val: Value) {
        super(ExprKind.GetRtti, ArrayList<Value>([val]))
    }
}

public class GetRTTIStatic <: Expression & Equatable<GetRTTIStatic> {
    public operator func==(other: GetRTTIStatic): Bool {
        return refEq(this, other)
    }
    internal let _ty: Type

    public prop ty: Type {
        get() {
            return _ty
        }
    }
    protected override func operandsToString(): String {
        return ty.toString()
    }

    public init(ty: Type) {
        super(ExprKind.GetRttiStatic)
        this._ty = ty
    }
}
sealed abstract class TypeCast <: Expression & Equatable<TypeCast> {
    public operator func==(other: TypeCast): Bool {
        return refEq(this, other)
    }
    internal init(kind: ExprKind, srcVal: Value) {
        super(kind, ArrayList<Value>([srcVal]))
    }
    public prop srcValue: Value {
        get() {
            return operands[0]
        }
    }
    public prop sourceType: Type {
        get() {
            return operands[0].ty
        }
    }
    public prop targetType: Type {
        get() {
            return result.getOrThrow().ty
        }
    }
}

sealed abstract class NumericCastBase <: Expression & Equatable<NumericCastBase> {
    public operator func==(other: NumericCastBase): Bool {
        return refEq(this, other)
    }
    internal let _overflow: OverflowStrategy

    protected override func getExtraCommentString(): String {
        if (overflow != OverflowStrategy.NA) {
            return "Overflow: " + overflow.toString()
        }
        return ""
    }

    public prop overflow: OverflowStrategy {
        get() {
            return _overflow
        }
    }

    internal init(kind: ExprKind, srcVal: Value) {
        super(kind, ArrayList<Value>([srcVal]))
    }
}

public class NumericCast <: NumericCastBase & Equatable<NumericCast> {
    public operator func==(other: NumericCast): Bool {
        return refEq(this, other)
    }
    public init(srcVal: Value, overflow: OverflowStrategy) {
        super(ExprKind.NumericCast, srcVal)
        this._overflow = overflow
    }
}

public class TryNumericCast <: NumericCastBase & Equatable<TryNumericCast> {
    public operator func==(other: TryNumericCast): Bool {
        return refEq(this, other)
    }
    public init(srcVal: Value, normal: Block, err: Block) {
        super(ExprKind.TryNumericCast, srcVal)
        _operands.add(normal)
        _operands.add(err)
        this._overflow = OverflowStrategy.THROWING
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }
}

public class StaticCast <: TypeCast & Equatable<StaticCast> {
    public operator func==(other: StaticCast): Bool {
        return refEq(this, other)
    }
    public init(srcVal: Value, targetType: Type) {
        super(ExprKind.StaticCast, srcVal)
    }
}

public class Box <: TypeCast & Equatable<Box> {
    public operator func==(other: Box): Bool {
        return refEq(this, other)
    }
    public init(srcVal: Value) {
        super(ExprKind.Box, srcVal)
    }
}

public class UnboxToValue <: TypeCast & Equatable<UnboxToValue> {
    public operator func==(other: UnboxToValue): Bool {
        return refEq(this, other)
    }
    public init(srcVal: Value) {
        super(ExprKind.UnboxToValue, srcVal)
    }
}

public class UnboxToRef <: TypeCast & Equatable<UnboxToRef> {
    public operator func==(other: UnboxToRef): Bool {
        return refEq(this, other)
    }
    public init(srcVal: Value) {
        super(ExprKind.UnboxToRef, srcVal)
    }
}

public class InstanceOf <: Expression & Equatable<InstanceOf> {
    public operator func==(other: InstanceOf): Bool {
        return refEq(this, other)
    }
    private let _targetType: Type

    public prop targetType: Type {
        get() {
            return _targetType
        }
    }
    protected override func operandsToString(): String {
        return baseOpsToString() + ", " + _targetType.toString()
    }

    public init(srcVal: Value, targetTy: Type) {
        super(ExprKind.InstanceOf, ArrayList<Value>([srcVal]))
        this._targetType = targetTy
    }
}

public class Tuple <: Expression & Equatable<Tuple> {
    public operator func==(other: Tuple): Bool {
        return refEq(this, other)
    }
    public init(elements: ArrayList<Value>) {
        super(ExprKind.Tuple, elements)
    }
    public prop elements: Array<Value> {
        get() {
            return operands.toArray()
        }
    }
}

public class FieldByName <: Expression & Equatable<FieldByName> {
    public operator func==(other: FieldByName): Bool {
        return refEq(this, other)
    }
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

    public init(location: Value, fieldNames: ArrayList<String>) {
        super(ExprKind.FieldByName, ArrayList<Value>([location]))
        this._fieldNames = fieldNames
    }
}

public class Field <: Expression & Equatable<Field> {
    public operator func==(other: Field): Bool {
        return refEq(this, other)
    }
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

    public init(location: Value, path: ArrayList<UInt64>) {
        super(ExprKind.Field, ArrayList<Value>([location]))
        this._path = path
    }
}

sealed abstract class RawArrayAllocateBase <: Expression & Equatable<RawArrayAllocateBase> {
    public operator func==(other: RawArrayAllocateBase): Bool {
        return refEq(this, other)
    }
    private let _elementType: Type

    public prop elementType: Type {
        get() {
            return _elementType
        }
    }

    protected override func operandsToString(): String {
        return _elementType.toString() + ", " + baseOpsToString()
    }

    internal init(kind: ExprKind, elementType: Type, size: Value) {
        super(kind, ArrayList<Value>([size]))
        this._elementType = elementType
    }
}

public class RawArrayAllocate <: RawArrayAllocateBase & Equatable<RawArrayAllocate> {
    public operator func==(other: RawArrayAllocate): Bool {
        return refEq(this, other)
    }
    public init(elementType: Type, size: Value) {
        super(ExprKind.RawArrayAllocate, elementType, size)
    }
}

public class TryRawArrayAllocate <: RawArrayAllocateBase & Equatable<TryRawArrayAllocate> {
    public operator func==(other: TryRawArrayAllocate): Bool {
        return refEq(this, other)
    }
    public init(elementType: Type, size: Value, normal: Block, err: Block) {
        super(ExprKind.TryRawArrayAllocate, elementType, size)
        _operands.add(normal)
        _operands.add(err)
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }
}

public class RawArrayLiteralInit <: Expression & Equatable<RawArrayLiteralInit> {
    public operator func==(other: RawArrayLiteralInit): Bool {
        return refEq(this, other)
    }
    public init(memory: Value, elements: ArrayList<Value>) {
        super(ExprKind.RawArrayLiteralInit, elements)
        _operands.add(memory, at: 0)
    }
}

public class RawArrayInitByValue <: Expression & Equatable<RawArrayInitByValue> {
    public operator func==(other: RawArrayInitByValue): Bool {
        return refEq(this, other)
    }
    public init(memory: Value, size: Value, initVal: Value) {
        super(ExprKind.RawArrayInitByValue, ArrayList<Value>([memory, size, initVal]))
    }
}

public class VArrayExpr <: Expression & Equatable<VArrayExpr> {
    public operator func==(other: VArrayExpr): Bool {
        return refEq(this, other)
    }
    public init(elements: ArrayList<Value>) {
        super(ExprKind.VArrayExpr, elements)
    }
}

public class VArrayBuilder <: Expression & Equatable<VArrayBuilder> {
    public operator func==(other: VArrayBuilder): Bool {
        return refEq(this, other)
    }
    public init(size: Value, initVal: Value, initFunc: Value) {
        super(ExprKind.VArrayBuilder, ArrayList<Value>([size, initVal, initFunc]))
    }
}

public class GetException <: Expression & Equatable<GetException> {
    public operator func==(other: GetException): Bool {
        return refEq(this, other)
    }
    public init() {
        super(ExprKind.GetException)
    }
}

public class Lambda <: Expression & Equatable<Lambda> {
    public operator func==(other: Lambda): Bool {
        return refEq(this, other)
    }
    internal let _identifier: String
    internal let _srcCodeName: String
    internal let _funcType: FuncType
    internal var _parameters = ArrayList<Parameter>()
    internal var _isLocalFunc: Bool = false
    internal var _genericTypeParams = ArrayList<GenericType>()
    internal var _paramDftValHostFunc: ?Lambda = None
    internal var _returnValue: ?LocalVar = None
    internal var _isCompileTimeValue: Bool = false

    protected override func getExtraCommentString(): String {
        var comments = ArrayList<String>()
        if (!_srcCodeName.isEmpty()) {
            comments.add("srcCodeName: " + _srcCodeName)
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

    public prop srcCodeName: String {
        get() {
            return _srcCodeName
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
    public func initParametersAndBody(): Unit {
        // 1. init parameters
        if (!_parameters.isEmpty()) {
            throw Exception("Lambda parameters already set")
        }
        for (paramTy in _funcType.paramTypes) {
            appendParameter(paramTy)
        }

        // 2. init body
        if (_blockGroups.size != 0) {
            throw Exception("Lambda body already set")
        }
        let identifier = topLevelFunc.generateBlockGroupId().toString()
        let body = BlockGroup(identifier, _result.getOrThrow())
        _blockGroups.add(body)
        let bb = body.appendBlock()
        body.setEntryBlock(bb)
    }
    public prop body: BlockGroup {
        get() {
            return _blockGroups[0]
        }
    }

    internal func appendParameter(ty: Type): Unit {
        let identifier = LOCAL_VAR_PREFIX + topLevelFunc.generateLocalId().toString()
        let result = Parameter(ty, identifier, this)
        _parameters.add(result)
    }

    public func toString(): String {
        return lambdaToString(this, 0)
    }

    public init(ty: FuncType, identifier: String, srcName: String, genericTypeParams: ArrayList<GenericType>) {
        super(ExprKind.Lambda)
        this._identifier = identifier
        this._srcCodeName = srcName
        this._funcType = ty
        this._isLocalFunc = false
        this._genericTypeParams = genericTypeParams
    }
}

public class Debug <: Expression & Equatable<Debug> {
    public operator func==(other: Debug): Bool {
        return refEq(this, other)
    }
    private let _srcCodeName: String

    public prop srcCodeName: String {
        get() {
            return _srcCodeName
        }
    }
    protected override func operandsToString(): String {
        return baseOpsToString() + ", " + _srcCodeName
    }

    public init(location: Value, srcName: String) {
        super(ExprKind.Debug, ArrayList<Value>([location]))
        this._srcCodeName = srcName
    }
}

internal sealed abstract class SpawnBase <: Expression & Equatable<SpawnBase> {
    public operator func==(other: SpawnBase): Bool {
        return refEq(this, other)
    }
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

    internal init(kind: ExprKind, operands: ArrayList<Value>) {
        super(kind, operands)
    }
}

public class Spawn <: SpawnBase & Equatable<Spawn> {
    public operator func==(other: Spawn): Bool {
        return refEq(this, other)
    }
    public init(lambda: Value) {
        super(ExprKind.Spawn, ArrayList<Value>([lambda]))
    }

    public init(lambda: Value, arg: Value) {
        super(ExprKind.Spawn, ArrayList<Value>([lambda, arg]))
    }
}

public class TrySpawn <: SpawnBase & Equatable<TrySpawn> {
    public operator func==(other: TrySpawn): Bool {
        return refEq(this, other)
    }
    public init(lambda: Value, normal: Block, err: Block) {
        super(ExprKind.TrySpawn, ArrayList<Value>([lambda]))
        _operands.add(normal)
        _operands.add(err)
    }

    public init(lambda: Value, arg: Value, normal: Block, err: Block) {
        super(ExprKind.TrySpawn, ArrayList<Value>([lambda, arg]))
        _operands.add(normal)
        _operands.add(err)
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }
}

public class GetInstantiateValue <: Expression & Equatable<GetInstantiateValue> {
    public operator func==(other: GetInstantiateValue): Bool {
        return refEq(this, other)
    }
    internal let _instantiateTypes: ArrayList<Type>

    public prop instantiateTypes: Array<Type> {
        get() {
            return _instantiateTypes.toArray()
        }
    }

    public init(val: Value, instantiateTypes: ArrayList<Type>) {
        super(ExprKind.GetInstantiateValue, ArrayList<Value>([val]))
        this._instantiateTypes = instantiateTypes
    }
}

public class GoTo <: Expression & Equatable<GoTo> {
    public operator func==(other: GoTo): Bool {
        return refEq(this, other)
    }
    public init(target: Block) {
        super(ExprKind.Goto)
        _operands.add(target)
    }
}

public class Branch <: Expression & Equatable<Branch> {
    public operator func==(other: Branch): Bool {
        return refEq(this, other)
    }
    internal var _sourceExpr: SourceExpr = SourceExpr.Other

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
    public init(condition: Value, trueTarget: Block, falseTarget: Block) {
        super(ExprKind.Branch, ArrayList<Value>([condition]))
        _operands.add(trueTarget)
        _operands.add(falseTarget)
    }
}

public class MultiBranch <: Expression & Equatable<MultiBranch> {
    public operator func==(other: MultiBranch): Bool {
        return refEq(this, other)
    }
    internal let _caseValues: ArrayList<UInt64>

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
    public init(condition: Value, default: Block, targets: ArrayList<Block>, caseValues: ArrayList<UInt64>) {
        super(ExprKind.MultiBranch, ArrayList<Value>([condition]))
        _operands.add(default)
        _operands.add(all: ArrayList<Value>(targets.size, { i => targets[i] }))
        _caseValues = caseValues
    }
}

public class Exit <: Expression & Equatable<Exit> {
    public operator func==(other: Exit): Bool {
        return refEq(this, other)
    }
    public init() {
        super(ExprKind.Exit)
    }
}

public class RaiseException <: Expression & Equatable<RaiseException> {
    public operator func==(other: RaiseException): Bool {
        return refEq(this, other)
    }
    public init(value: Value, successor: Block) {
        super(ExprKind.RaiseException, ArrayList<Value>([value]))
        _operands.add(successor)
    }
    public init(value: Value) {
        super(ExprKind.RaiseException, ArrayList<Value>([value]))
    }
}
