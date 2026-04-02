/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
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
internal enum ExprKind {
    Invalid |

    // terminator
    Goto | Branch | MultiBranch | Exit |
    TryApply | TryInvoke | TryIntrinsic |
    RaiseException | TrySpawn | TryNumericCast |
    TryAllocate | TryRawArrayAllocate |
    TryNeg | TryAdd | TrySub | TryMul | TryDiv | TryMod | TryExp | TryLShift | TryRShift |

    // unary expr
    Neg | Not | BitNot |

    // binary expr
    Add | Sub | Mul | Div | Mod | Exp |
    LShift | RShift | BitAnd | BitOr | BitXor |
    LT | GT | LE | GE | Equal | NotEqual |
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

    internal func isBinary(): Bool {
        match (this) {
            case Add | Sub | Mul | Div | Mod | Exp |
            LShift | RShift | BitAnd | BitOr | BitXor |
            LT | GT | LE | GE | Equal | NotEqual |
            And | Or => true
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
            case LT | GT | LE | GE | Equal | NotEqual => true
            case _ => false
        }
    }

    internal func isLogicalOperator(): Bool {
        match (this) {
            case And | Or => true
            case _ => false
        }
    }

    internal func isMathematicalOperator(): Bool {
        match (this) {
            case Add | Sub | Mul | Div | Mod | Exp => true
            case _ => false
        }
    }

    internal func isUnary(): Bool {
        match (this) {
            case Neg | Not | BitNot => true
            case _ => false
        }
    }

    internal func isTerminator(): Bool {
        match (this) {
            case Goto
                | Branch
                | MultiBranch
                | Exit
                | TryApply
                | TryInvoke
                | TryIntrinsic
                | RaiseException
                | TrySpawn
                | TryNumericCast
                | TryAllocate
                | TryRawArrayAllocate
                | TryNeg
                | TryAdd
                | TrySub
                | TryMul
                | TryDiv
                | TryMod
                | TryExp
                | TryLShift
                | TryRShift => true
            case _ => false
        }
    }
}

@Derive[Equatable]
@Derive[ToString]
public enum UnaryExprKind {
    Neg | Not | BitNot

    internal func toExprKind(isTry: Bool): ExprKind {
        match (this) {
            case Neg => if (isTry) {ExprKind.TryNeg} else {ExprKind.Neg}
            case Not => ExprKind.Not
            case BitNot => ExprKind.BitNot
        }
    }
}

@Derive[Equatable]
@Derive[ToString]
public enum BinaryExprKind {
    // mathematical operators
    Add | Sub | Mul | Div | Mod | Exp |
    // bitwise operators
    LShift | RShift | BitAnd | BitOr | BitXor |
    // comparison operators
    LT | GT | LE | GE | Equal | NotEqual |
    // logical operators
    And | Or

    internal func toExprKind(isTry: Bool): ExprKind {
        match (this) {
            case Add => if (isTry) {ExprKind.TryAdd} else {ExprKind.Add}
            case Sub => if (isTry) {ExprKind.TrySub} else {ExprKind.Sub}
            case Mul => if (isTry) {ExprKind.TryMul} else {ExprKind.Mul}
            case Div => if (isTry) {ExprKind.TryDiv} else {ExprKind.Div}
            case Mod => if (isTry) {ExprKind.TryMod} else {ExprKind.Mod}
            case Exp => if (isTry) {ExprKind.TryExp} else {ExprKind.Exp}
            case LShift => if (isTry) {ExprKind.TryLShift} else {ExprKind.LShift}
            case RShift => if (isTry) {ExprKind.TryRShift} else {ExprKind.RShift}
            case BitAnd => ExprKind.BitAnd
            case BitOr => ExprKind.BitOr
            case BitXor => ExprKind.BitXor
            case LT => ExprKind.LT
            case GT => ExprKind.GT
            case LE => ExprKind.LE
            case GE => ExprKind.GE
            case Equal => ExprKind.Equal
            case NotEqual => ExprKind.NotEqual
            case And => ExprKind.And
            case Or => ExprKind.Or
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
    internal var _blockGroups = ArrayList<BlockGroup>()
    internal var _kind: ExprKind
    internal var _operands: ArrayList<Value>
    internal var _owner: ?Block = None
    internal var _result: LocalVar = LocalVar(InvalidType.get())

    public prop blockGroups: Array<BlockGroup> {
        get() {
            return _blockGroups.toArray()
        }
    }

    public prop operands: Array<Value> {
        get() {
            return _operands.toArray()
        }
    }

    public prop owner: Block {
        get() {
            if (let Some(b) <- _owner) {
                return b
            } else {
                throw Exception("Owner is not set")
            }
        }
    }

    public prop result: LocalVar {
        get() {
            return _result
        }
    }

    public prop successors: Array<Block> {
        get() {
            let blocks = ArrayList<Block>()
            for (op in _operands) {
                if (let Some(b) <- (op as Block)) {
                    blocks.add(b)
                }
            }
            return blocks.toArray()
        }
    }

    public prop topLevelFunc: Function {
        get() {
            return owner.topLevelFunc
        }
    }

    internal init(kind: ExprKind) {
        this._kind = kind
        this._operands = ArrayList<Value>()
    }

    internal init(kind: ExprKind, operands: ArrayList<Value>) {
        this._kind = kind
        this._operands = operands
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
        owner._exprs.removeIf({ e => e == this })
        _kind = ExprKind.Invalid
    }

    public func dump(): Unit {
        println(toString())
    }

    public func hasExceptionBranch(): Bool {
        match (_kind) {
            case TryApply
                | TryInvoke
                | TryIntrinsic
                | TrySpawn
                | TryNumericCast
                | TryAllocate
                | TryRawArrayAllocate
                | TryNeg
                | TryAdd
                | TrySub
                | TryMul
                | TryDiv
                | TryMod
                | TryExp
                | TryLShift
                | TryRShift => true
            case _ => false
        }
    }

    public func hashCode(): Int64 {
        return _result.hashCode()
    }

    public func isTerminator(): Bool {
        return _kind.isTerminator()
    }

    public func moveAfter(other: Expression): Unit {
        assert(!other.isTerminator(), "An expression cannot be moved behind terminator expression")
        if (this == other) {
            return
        }
        // 1. remove current expr from parent block
        this.owner._exprs.removeIf({ e => e == this })

        // 2. update successor's predecessors
        if (this.isTerminator()) {
            for (successor in this.successors) {
                successor._predecessors.removeIf({ bb => bb == this.owner })
            }
        }

        // 3. get offset
        var index = -1
        for (i in 0..other.owner._exprs.size) {
            if (other.owner._exprs[i] == this) {
                index = i
                break
            }
        }
        assert(index != -1, "target expression: ${other.toString()} Not found in block: ${other.owner.toString()}")

        // 4. insert current expr after `other`
        other.owner._exprs.add(this, at: index + 1)

        // 5. update current expr's owner
        this._owner = other.owner

        // 6. update current expr's result identifier
        updateLocalVarIdAndHashCode(_result)
    }

    public func moveBefore(other: Expression): Unit {
        assert(!this.isTerminator(), "Terminator expression cannot be moved in front of another expression")
        if (this == other) {
            return
        }
        // 1. remove current expr from parent block
        this.owner._exprs.removeIf({ e => e == this })

        // 2. get offset
        var index = -1
        for (i in 0..other.owner._exprs.size) {
            if (other.owner._exprs[i] == this) {
                index = i
                break
            }
        }
        assert(index != -1, "target expression: ${other.toString()} Not found in block: ${other.owner.toString()}")

        // 3. insert current expr before `other`
        other.owner._exprs.add(this, at: index)

        // 4. update current expr's owner
        this._owner = other.owner

        // 5. update current expr's result identifier
        updateLocalVarIdAndHashCode(_result)
    }

    public open func toString(): String {
        let res = StringBuilder()
        if (result._isRetValue) {
            res.append("[ret] ")
        }
        res.append(result.identifier + ": " + result.ty.toString() + " = ")
        res.append(_kind.toString() + "(" + operandsToString() + ")")
        res.append(getCommentString())
        return res.toString()
    }

    protected open func getExtraCommentString(): String {
        return ""
    }

    protected open func operandsToString(): String {
        return baseOpsToString()
    }

    internal func baseOpsToString(): String {
        return valueVecToString(_operands, hasExceptionBranch())
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
        if (let Some(intrinsic) <- (this as IntrinsicBase)) {
            return "Intrinsic/" + intrinsic._calleeKind.toString()
        }
        return this._kind.toString()
    }

    public operator func==(other: Expression): Bool {
        return refEq(this, other)
    }
}

sealed abstract class UnaryExpressionBase <: Expression & Equatable<UnaryExpressionBase> {
    internal var _overflow: OverflowStrategy

    public mut prop overflow: OverflowStrategy {
        get() {
            return _overflow
        }
        set(v) {
            _overflow = v
        }
    }

    internal init(kind: ExprKind, op: Value) {
        super(kind, ArrayList<Value>([op]))
        this._overflow = OverflowStrategy.NA
    }

    protected override func getExtraCommentString(): String {
        if (_overflow != OverflowStrategy.NA) {
            return "Overflow: " + _overflow.toString()
        }
        return ""
    }

    public operator func==(other: UnaryExpressionBase): Bool {
        return refEq(this, other)
    }
}

public class UnaryExpression <: UnaryExpressionBase & Equatable<UnaryExpression> {
    private init(kind: ExprKind, op: Value) {
        super(kind, op)
    }

    public static func create(kind: UnaryExprKind, op: Value): UnaryExpression {
        let expr = UnaryExpression(kind.toExprKind(false), op)
        let retType = match (kind) {
            case Neg | BitNot => op.ty
            case Not => BoolType.get()
            case _ => throw Exception("Invalid kind for UnaryExpression: ${kind.toString()}")
        }
        expr._result._type = retType
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: UnaryExpression): Bool {
        return refEq(this, other)
    }
}

public class TryUnaryExpression <: UnaryExpressionBase & Equatable<TryUnaryExpression> {
    private init(kind: ExprKind, op: Value, normal: Block, err: Block) {
        super(kind, op)
        _operands.add(normal)
        _operands.add(err)
        this._overflow = OverflowStrategy.Throwing
    }

    public static func create(op: Value, normal: Block, err: Block): TryUnaryExpression {
        let expr = TryUnaryExpression(TryNeg, op, normal, err)
        expr._result._type = op.ty
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: TryUnaryExpression): Bool {
        return refEq(this, other)
    }
}

sealed abstract class BinaryExpressionBase <: Expression & Equatable<BinaryExpressionBase> {
    internal var _overflow: OverflowStrategy

    public mut prop overflow: OverflowStrategy {
        get() {
            return _overflow
        }
        set(v) {
            _overflow = v
        }
    }

    internal init(kind: ExprKind, leftOp: Value, rightOp: Value) {
        super(kind, ArrayList<Value>([leftOp, rightOp]))
        this._overflow = OverflowStrategy.NA
    }

    protected override func getExtraCommentString(): String {
        if (_overflow != OverflowStrategy.NA) {
            return "Overflow: " + _overflow.toString()
        }
        return ""
    }

    public operator func==(other: BinaryExpressionBase): Bool {
        return refEq(this, other)
    }
}

public class BinaryExpression <: BinaryExpressionBase & Equatable<BinaryExpression> {
    private init(kind: ExprKind, leftOp: Value, rightOp: Value) {
        super(kind, leftOp, rightOp)
    }

    public static func create(kind: BinaryExprKind, leftOp: Value, rightOp: Value): BinaryExpression {
        let expr = BinaryExpression(kind.toExprKind(false), leftOp, rightOp)
        let retType = match (kind) {
            case Add | Sub | Mul | Div | Mod | Exp | LShift | RShift | BitAnd | BitOr | BitXor => leftOp.ty
            case LT | GT | LE | GE | Equal | NotEqual | And | Or => BoolType.get()
        }
        expr._result._type = retType
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: BinaryExpression): Bool {
        return refEq(this, other)
    }
}

public class TryBinaryExpression <: BinaryExpressionBase & Equatable<TryBinaryExpression> {
    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    private init(kind: ExprKind, leftOp: Value, rightOp: Value, normal: Block, err: Block) {
        super(kind, leftOp, rightOp)
        _operands.add(normal)
        _operands.add(err)
        this._overflow = OverflowStrategy.Throwing
    }

    public static func create(kind: BinaryExprKind, leftOp: Value, rightOp: Value, normal: Block, err: Block): TryBinaryExpression {
        let expr = TryBinaryExpression(kind.toExprKind(true), leftOp, rightOp, normal, err)
        expr._result._type = leftOp.ty
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: TryBinaryExpression): Bool {
        return refEq(this, other)
    }
}

public class Constant <: Expression & Equatable<Constant> {
    private init(val: LiteralValue) {
        super(ExprKind.Constant, ArrayList<Value>([val]))
    }

    public static func create(val: LiteralValue): Constant {
        let expr = Constant(val)
        expr._result._type = val.ty
        return expr
    }

    public operator func==(other: Constant): Bool {
        return refEq(this, other)
    }
}

sealed abstract class AllocateBase <: Expression & Equatable<AllocateBase> {
    internal let _allocatedType: Type

    public prop allocatedType: Type {
        get() {
            return _allocatedType
        }
    }

    internal init(kind: ExprKind, allocatedType: Type) {
        super(kind)
        this._allocatedType = allocatedType
    }

    protected override func operandsToString(): String {
        var res = _allocatedType.toString()
        if (let temp <- baseOpsToString() && !temp.isEmpty()) {
            res += ", " + temp
        }
        return res
    }

    public operator func==(other: AllocateBase): Bool {
        return refEq(this, other)
    }
}

public class Allocate <: AllocateBase & Equatable<Allocate> {
    private init(allocatedType: Type) {
        super(ExprKind.Allocate, allocatedType)
    }

    public static func create(allocatedType: Type): Allocate {
        let expr = Allocate(allocatedType)
        expr._result._type = RefType.get(allocatedType)
        return expr
    }

    public operator func==(other: Allocate): Bool {
        return refEq(this, other)
    }
}

public class TryAllocate <: AllocateBase & Equatable<TryAllocate> {
    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    private init(allocatedType: Type, normal: Block, err: Block) {
        super(ExprKind.TryAllocate, allocatedType)
        _operands.add(normal)
        _operands.add(err)
    }

    public static func create(allocatedType: Type, normal: Block, err: Block): TryAllocate {
        let expr = TryAllocate(allocatedType, normal, err)
        expr._result._type = RefType.get(allocatedType)
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: TryAllocate): Bool {
        return refEq(this, other)
    }
}

public class Load <: Expression & Equatable<Load> {
    public prop srcAddress: Value {
        get() {
            return operands[0]
        }
    }

    private init(location: Value) {
        super(ExprKind.Load, ArrayList<Value>([location]))
    }

    public static func create(location: Value): Load {
        let expr = Load(location)
        expr._result._type = location._type._typeArgs[0]
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: Load): Bool {
        return refEq(this, other)
    }
}

public class Store <: Expression & Equatable<Store> {
    public prop dstAddress: Value {
        get() {
            return operands[1]
        }
    }

    public prop srcValue: Value {
        get() {
            return operands[0]
        }
    }

    private init(val: Value, location: Value) {
        super(ExprKind.Store, ArrayList<Value>([val, location]))
    }

    public static func create(val: Value, location: Value): Store {
        let expr = Store(val, location)
        expr._result._type = UnitType.get()
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: Store): Bool {
        return refEq(this, other)
    }
}

public class GetElementByName <: Expression & Equatable<GetElementByName> {
    internal let _fieldNames: ArrayList<String>

    public prop fieldNames: Array<String> {
        get() {
            return _fieldNames.toArray()
        }
    }

    private init(location: Value, fieldNames: ArrayList<String>) {
        super(ExprKind.GetElementByName, ArrayList<Value>([location]))
        this._fieldNames = fieldNames
    }

    public static func create(location: Value, fieldNames: ArrayList<String>): GetElementByName {
        let expr = GetElementByName(location, fieldNames)
        let retTy = getFieldOfType(location.ty, fieldNames)
        expr._result._type = RefType.get(retTy)
        expr._result._expr = expr
        return expr
    }

    protected override func operandsToString(): String {
        let fieldStr = "[" + String.join(_fieldNames.toArray(), delimiter: ", ") + "]"
        return baseOpsToString() + ", field: " + fieldStr
    }

    public operator func==(other: GetElementByName): Bool {
        return refEq(this, other)
    }
}

public class StoreElementByName <: Expression & Equatable<StoreElementByName> {
    private let _fieldNames: ArrayList<String>

    public prop fieldNames: Array<String> {
        get() {
            return _fieldNames.toArray()
        }
    }

    private init(val: Value, location: Value, fieldNames: ArrayList<String>) {
        super(ExprKind.StoreElementByName, ArrayList<Value>([val, location]))
        this._fieldNames = fieldNames
    }

    public static func create(val: Value, location: Value, fieldNames: ArrayList<String>): StoreElementByName {
        let expr = StoreElementByName(val, location, fieldNames)
        expr._result._type = UnitType.get()
        expr._result._expr = expr
        return expr
    }

    protected override func operandsToString(): String {
        let fieldStr = "[" + String.join(_fieldNames.toArray(), delimiter: ", ") + "]"
        return baseOpsToString() + ", field: " + fieldStr
    }

    public operator func==(other: StoreElementByName): Bool {
        return refEq(this, other)
    }
}

public class FuncCallContext {
    internal let _args: ArrayList<Value>
    internal let _instTypeArgs: ArrayList<Type>
    internal let _objType: ?Type

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

    public prop objType: ?Type {
        get() {
            return _objType
        }
    }

    public init(args: Array<Value>, instTypeArgs: Array<Type>, objType: ?Type) {
        this._args = ArrayList<Value>.of(args)
        this._instTypeArgs = ArrayList<Type>.of(instTypeArgs)
        this._objType = objType
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
    internal let _instantiatedTypeArgs: ArrayList<Type>
    internal let _objType: ?Type

    public prop instantiatedTypeArgs: Array<Type> {
        get() {
            return _instantiatedTypeArgs.toArray()
        }
    }

    public prop objType: ?Type {
        get() {
            return _objType
        }
    }

    internal init(kind: ExprKind, funcCallCtx: FuncCallContext) {
        super(kind, funcCallCtx._args)
        this._instantiatedTypeArgs = funcCallCtx._instTypeArgs
        this._objType = funcCallCtx.objType
    }

    public func getArgs(): Array<Value>

    public operator func==(other: FuncCall): Bool {
        return refEq(this, other)
    }
}

sealed abstract class ApplyBase <: FuncCall & Equatable<ApplyBase> {
    internal var _isSuperCall: Bool = false

    public prop callee: Value {
        get() {
            return operands[0]
        }
    }

    internal init(kind: ExprKind, callee: Value, funcCallCtx: FuncCallContext) {
        super(kind, funcCallCtx)
        _operands.add(callee, at: 0)
    }

    protected override func getExtraCommentString(): String {
        if (_isSuperCall) {
            return "isSuperCall"
        }
        return ""
    }

    protected override func operandsToString(): String {
        let opStr = StringBuilder()
        if (let Some(ty) <- _objType) {
            opStr.append(ty.toString() + "::")
        }
        opStr.append(callee.identifier)
        opStr.append(typeVecToString("<", instantiatedTypeArgs, ">"))
        if (let temp <- baseOpsToString() && !temp.isEmpty()) {
            opStr.append(", " + temp)
        }
        return opStr.toString()
    }

    public operator func==(other: ApplyBase): Bool {
        return refEq(this, other)
    }
}

public class Apply <: ApplyBase & Equatable<Apply> {
    private init(callee: Value, funcCallCtx: FuncCallContext) {
        super(ExprKind.Apply, callee, funcCallCtx)
    }

    public static func create(callee: Value, funcCallCtx: FuncCallContext): Apply {
        let expr = Apply(callee, funcCallCtx)
        let genericRetType = (callee.ty as FuncType).getOrThrow().returnType
        let retTy = getInstType(genericRetType, callee, funcCallCtx)
        expr._result._type = retTy
        return expr
    }

    public override func getArgs(): Array<Value> {
        return operands[1..operands.size].toArray()
    }

    public operator func==(other: Apply): Bool {
        return refEq(this, other)
    }
}

public class TryApply <: ApplyBase & Equatable<TryApply> {
    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    private init(callee: Value, funcCallCtx: FuncCallContext, normal: Block, err: Block) {
        super(ExprKind.TryApply, callee, funcCallCtx)
        _operands.add(normal)
        _operands.add(err)
    }

    public static func create(callee: Value, funcCallCtx: FuncCallContext, normal: Block, err: Block): TryApply {
        let expr = TryApply(callee, funcCallCtx, normal, err)
        let genericRetType = (callee.ty as FuncType).getOrThrow().returnType
        let retTy = getInstType(genericRetType, callee, funcCallCtx)
        expr._result._type = retTy
        return expr
    }

    public override func getArgs(): Array<Value> {
        return operands[1..operands.size - 2]
    }

    public operator func==(other: TryApply): Bool {
        return refEq(this, other)
    }
}

sealed abstract class IntrinsicBase <: FuncCall & Equatable<IntrinsicBase> {
    internal let _calleeKind: IntrinsicKind

    internal init(kind: ExprKind, calleeKind: IntrinsicKind, funcCallCtx: FuncCallContext) {
        super(kind, funcCallCtx)
        this._calleeKind = calleeKind
    }

    public operator func==(other: IntrinsicBase): Bool {
        return refEq(this, other)
    }
}

public class Intrinsic <: IntrinsicBase & Equatable<Intrinsic> {
    private init(calleeKind: IntrinsicKind, funcCallCtx: FuncCallContext) {
        super(ExprKind.Intrinsic, calleeKind, funcCallCtx)
    }

    internal static func create(retTy: Type, calleeKind: IntrinsicKind, funcCallCtx: FuncCallContext): Intrinsic {
        let expr = Intrinsic(calleeKind, funcCallCtx)
        expr._result._type = retTy
        return expr
    }

    public override func getArgs(): Array<Value> {
        return operands.toArray()
    }

    public operator func==(other: Intrinsic): Bool {
        return refEq(this, other)
    }
}

public class TryIntrinsic <: IntrinsicBase & Equatable<TryIntrinsic> {
    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    private init(calleeKind: IntrinsicKind, funcCallCtx: FuncCallContext, normal: Block, err: Block) {
        super(ExprKind.TryIntrinsic, calleeKind, funcCallCtx)
        _operands.add(normal)
        _operands.add(err)
    }

    internal static func create(retTy: Type, calleeKind: IntrinsicKind, funcCallCtx: FuncCallContext, normal: Block, err: Block): TryIntrinsic {
        let expr = TryIntrinsic(calleeKind, funcCallCtx, normal, err)
        expr._result._type = retTy
        return expr
    }

    public override func getArgs(): Array<Value> {
        return operands[0..operands.size - 2].toArray()
    }

    public operator func==(other: TryIntrinsic): Bool {
        return refEq(this, other)
    }
}

sealed abstract class InvokeBase <: FuncCall & Equatable<InvokeBase> {
    internal let _virMethodCtx: VirMethodContext

    public prop methodGenericTypeParams: Array<GenericType> {
        get() {
            return _virMethodCtx.genericTypeParams.toArray()
        }
    }

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

    internal init(kind: ExprKind, callContext: InvokeCallContext) {
        super(kind, callContext.funcCallCtx)
        _operands.add(callContext.caller, at: 0)
        _virMethodCtx = callContext.virMethodCtx
    }

    protected override func operandsToString(): String {
        let opStr = StringBuilder()
        if (let Some(ty) <- objType) {
            opStr.append(ty.toString() + "::")
        }
        opStr.append(methodName)
        opStr.append(typeVecToString("<", instantiatedTypeArgs, ">"))
        opStr.append(": " + methodType.toString())
        if (let temp <- baseOpsToString() && !temp.isEmpty()) {
            opStr.append(", " + temp)
        }
        return opStr.toString()
    }

    internal func calleeIsStatic(): Bool {
        let caller = operands[0]
        if (!caller.isLocalVar()) {
            return false
        }
        let callerLocalVar = (caller as LocalVar).getOrThrow()
        return callerLocalVar.expr._kind == ExprKind.GetRttiStatic || callerLocalVar.expr._kind == ExprKind.GetRtti
    }

    public operator func==(other: InvokeBase): Bool {
        return refEq(this, other)
    }
}

public class Invoke <: InvokeBase & Equatable<Invoke> {
    private init(callContext: InvokeCallContext) {
        super(ExprKind.Invoke, callContext)
    }

    public static func create(retTy: Type, callContext: InvokeCallContext): Invoke {
        let expr = Invoke(callContext)
        expr._result._type = retTy 
        expr._result._expr = expr
        return expr
    }

    public override func getArgs(): Array<Value> {
        return operands[1..operands.size].toArray()
    }

    public operator func==(other: Invoke): Bool {
        return refEq(this, other)
    }
}

public class TryInvoke <: InvokeBase & Equatable<TryInvoke> {
    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    private init(callContext: InvokeCallContext, normal: Block, err: Block) {
        super(ExprKind.TryInvoke, callContext)
        _operands.add(normal)
        _operands.add(err)
    }

    public static func create(retTy: Type, callContext: InvokeCallContext, normal: Block, err: Block): TryInvoke {
        let expr = TryInvoke(callContext, normal, err)
        expr._result._type = retTy 
        expr._result._expr = expr
        return expr
    }

    public override func getArgs(): Array<Value> {
        return operands[1..operands.size - 2].toArray()
    }

    public operator func==(other: TryInvoke): Bool {
        return refEq(this, other)
    }
}

public class GetRTTI <: Expression & Equatable<GetRTTI> {
    private init(val: Value) {
        super(ExprKind.GetRtti, ArrayList<Value>([val]))
    }

    public static func create(val: Value): GetRTTI {
        let expr = GetRTTI(val)
        expr._result._type = UnitType.get() 
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: GetRTTI): Bool {
        return refEq(this, other)
    }
}

public class GetRTTIStatic <: Expression & Equatable<GetRTTIStatic> {
    internal let _ty: Type

    public prop ty: Type {
        get() {
            return _ty
        }
    }

    private init(ty: Type) {
        super(ExprKind.GetRttiStatic)
        this._ty = ty
    }

    public static func create(ty: Type): GetRTTIStatic {
        let expr = GetRTTIStatic(ty)
        expr._result._type = UnitType.get()
        return expr
    }

    protected override func operandsToString(): String {
        return ty.toString()
    }

    public operator func==(other: GetRTTIStatic): Bool {
        return refEq(this, other)
    }
}
sealed abstract class TypeCast <: Expression & Equatable<TypeCast> {
    public prop sourceType: Type {
        get() {
            return operands[0].ty
        }
    }

    public prop srcValue: Value {
        get() {
            return operands[0]
        }
    }

    public prop targetType: Type {
        get() {
            return result.ty
        }
    }

    internal init(kind: ExprKind, srcVal: Value) {
        super(kind, ArrayList<Value>([srcVal]))
    }

    public operator func==(other: TypeCast): Bool {
        return refEq(this, other)
    }
}

sealed abstract class NumericCastBase <: Expression & Equatable<NumericCastBase> {
    internal var _overflow: OverflowStrategy

    public mut prop overflow: OverflowStrategy {
        get() {
            return _overflow
        }
        set(v) {
            _overflow = v
        }
    }

    internal init(kind: ExprKind, srcVal: Value, overflow: OverflowStrategy) {
        super(kind, ArrayList<Value>([srcVal]))
        this._overflow = overflow
    }

    protected override func getExtraCommentString(): String {
        if (overflow != OverflowStrategy.NA) {
            return "Overflow: " + overflow.toString()
        }
        return ""
    }

    public operator func==(other: NumericCastBase): Bool {
        return refEq(this, other)
    }
}

public class NumericCast <: NumericCastBase & Equatable<NumericCast> {
    private init(srcVal: Value, overflow: OverflowStrategy) {
        super(ExprKind.NumericCast, srcVal, overflow)
    }

    public static func create(srcVal: Value, targetType: Type, overflow: OverflowStrategy): NumericCast {
        let expr = NumericCast(srcVal, overflow)
        expr._result._type = targetType 
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: NumericCast): Bool {
        return refEq(this, other)
    }
}

public class TryNumericCast <: NumericCastBase & Equatable<TryNumericCast> {
    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    private init(srcVal: Value, normal: Block, err: Block) {
        super(ExprKind.TryNumericCast, srcVal, OverflowStrategy.Throwing)
        _operands.add(normal)
        _operands.add(err)
    }

    public static func create(srcVal: Value, targetType: Type, normal: Block, err: Block): TryNumericCast {
        let expr = TryNumericCast(srcVal, normal, err)
        expr._result._type = targetType 
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: TryNumericCast): Bool {
        return refEq(this, other)
    }
}

public class StaticCast <: TypeCast & Equatable<StaticCast> {
    private init(srcVal: Value) {
        super(ExprKind.StaticCast, srcVal)
    }

    public static func create(srcVal: Value, targetType: Type): StaticCast {
        let expr = StaticCast(srcVal)
        expr._result._type = targetType 
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: StaticCast): Bool {
        return refEq(this, other)
    }
}

public class Box <: TypeCast & Equatable<Box> {
    private init(srcVal: Value) {
        super(ExprKind.Box, srcVal)
    }

    public static func create(srcVal: Value, targetType: Type): Box {
        let expr = Box(srcVal)
        expr._result._type = targetType
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: Box): Bool {
        return refEq(this, other)
    }
}

public class UnboxToValue <: TypeCast & Equatable<UnboxToValue> {
    private init(srcVal: Value) {
        super(ExprKind.UnboxToValue, srcVal)
    }

    public static func create(srcVal: Value, targetType: Type): UnboxToValue {
        let expr = UnboxToValue(srcVal)
        expr._result._type = targetType
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: UnboxToValue): Bool {
        return refEq(this, other)
    }
}

public class UnboxToRef <: TypeCast & Equatable<UnboxToRef> {
    private init(srcVal: Value) {
        super(ExprKind.UnboxToRef, srcVal)
    }

    public static func create(srcVal: Value, targetType: Type): UnboxToRef {
        let expr = UnboxToRef(srcVal)
        expr._result._type = targetType
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: UnboxToRef): Bool {
        return refEq(this, other)
    }
}

public class InstanceOf <: Expression & Equatable<InstanceOf> {
    private let _targetType: Type

    public prop targetType: Type {
        get() {
            return _targetType
        }
    }

    private init(srcVal: Value, targetTy: Type) {
        super(ExprKind.InstanceOf, ArrayList<Value>([srcVal]))
        this._targetType = targetTy
    }

    public static func create(srcVal: Value, targetTy: Type): InstanceOf {
        let expr = InstanceOf(srcVal, targetTy)
        expr._result._type = BoolType.get()
        expr._result._expr = expr
        return expr
    }

    protected override func operandsToString(): String {
        return baseOpsToString() + ", " + _targetType.toString()
    }

    public operator func==(other: InstanceOf): Bool {
        return refEq(this, other)
    }
}

public class Tuple <: Expression & Equatable<Tuple> {
    public prop elements: Array<Value> {
        get() {
            return operands.toArray()
        }
    }

    private init(elements: ArrayList<Value>) {
        super(ExprKind.Tuple, elements)
    }

    public static func create(elements: ArrayList<Value>): Tuple {
        let expr = Tuple(elements)
        expr._result._type = TupleType.get(elements.map({ e => e.ty }).toArray())
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: Tuple): Bool {
        return refEq(this, other)
    }
}

public class FieldByName <: Expression & Equatable<FieldByName> {
    internal let _fieldNames: ArrayList<String>

    public prop fieldNames: Array<String> {
        get() {
            return _fieldNames.toArray()
        }
    }

    private init(location: Value, fieldNames: ArrayList<String>) {
        super(ExprKind.FieldByName, ArrayList<Value>([location]))
        this._fieldNames = fieldNames
    }

    public static func create(location: Value, fieldNames: ArrayList<String>): FieldByName {
        let expr = FieldByName(location, fieldNames)
        let retTy = getFieldOfType(location.ty, fieldNames)
        expr._result._type = retTy
        expr._result._expr = expr
        return expr
    }

    protected override func operandsToString(): String {
        let fieldStr = "[" + String.join(_fieldNames.toArray(), delimiter: ", ") + "]"
        return baseOpsToString() + ", path: " + fieldStr
    }

    public operator func==(other: FieldByName): Bool {
        return refEq(this, other)
    }
}

public class Field <: Expression & Equatable<Field> {
    internal let _path: ArrayList<UInt64>

    public prop path: Array<UInt64> {
        get() {
            return _path.toArray()
        }
    }

    private init(location: Value, path: ArrayList<UInt64>) {
        super(ExprKind.Field, ArrayList<Value>([location]))
        this._path = path
    }

    public static func create(location: Value, path: ArrayList<UInt64>): Field {
        let expr = Field(location, path)
        let retTy = getFieldOfType(location.ty, path.map({ i => Int64(i) }))
        expr._result._type = retTy
        expr._result._expr = expr
        return expr
    }

    protected override func operandsToString(): String {
        let strArray = ArrayList<String>(_path.size, { i => _path[i].toString() })
        let pathStr = "[" + String.join(strArray.toArray(), delimiter: ", ") + "]"
        return baseOpsToString() + ", path: " + pathStr
    }

    public operator func==(other: Field): Bool {
        return refEq(this, other)
    }
}

sealed abstract class RawArrayAllocateBase <: Expression & Equatable<RawArrayAllocateBase> {
    private let _elementType: Type

    public prop elementType: Type {
        get() {
            return _elementType
        }
    }

    internal init(kind: ExprKind, elementType: Type, size: Value) {
        super(kind, ArrayList<Value>([size]))
        this._elementType = elementType
    }

    protected override func operandsToString(): String {
        return _elementType.toString() + ", " + baseOpsToString()
    }

    public operator func==(other: RawArrayAllocateBase): Bool {
        return refEq(this, other)
    }
}

public class RawArrayAllocate <: RawArrayAllocateBase & Equatable<RawArrayAllocate> {
    private init(elementType: Type, size: Value) {
        super(ExprKind.RawArrayAllocate, elementType, size)
    }

    public static func create(elementType: Type, size: Value): RawArrayAllocate {
        let expr = RawArrayAllocate(elementType, size)
        expr._result._type = RefType.get(RawArrayType.get(elementType, 1))
        return expr
    }

    public operator func==(other: RawArrayAllocate): Bool {
        return refEq(this, other)
    }
}

public class TryRawArrayAllocate <: RawArrayAllocateBase & Equatable<TryRawArrayAllocate> {
    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    private init(elementType: Type, size: Value, normal: Block, err: Block) {
        super(ExprKind.TryRawArrayAllocate, elementType, size)
        _operands.add(normal)
        _operands.add(err)
    }

    public static func create(elementType: Type, size: Value, normal: Block, err: Block): TryRawArrayAllocate {
        let expr = TryRawArrayAllocate(elementType, size, normal, err)
        expr._result._type = RefType.get(RawArrayType.get(elementType, 1))
        return expr
    }

    public operator func==(other: TryRawArrayAllocate): Bool {
        return refEq(this, other)
    }
}

public class RawArrayLiteralInit <: Expression & Equatable<RawArrayLiteralInit> {
    private init(memory: Value, elements: ArrayList<Value>) {
        super(ExprKind.RawArrayLiteralInit, elements)
        _operands.add(memory, at: 0)
    }

    public static func create(memory: Value, elements: ArrayList<Value>): RawArrayLiteralInit {
        let expr = RawArrayLiteralInit(memory, elements)
        expr._result._type = UnitType.get()
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: RawArrayLiteralInit): Bool {
        return refEq(this, other)
    }
}

public class RawArrayInitByValue <: Expression & Equatable<RawArrayInitByValue> {
    private init(memory: Value, size: Value, initVal: Value) {
        super(ExprKind.RawArrayInitByValue, ArrayList<Value>([memory, size, initVal]))
    }

    public static func create(memory: Value, size: Value, initVal: Value): RawArrayInitByValue {
        let expr = RawArrayInitByValue(memory, size, initVal)
        expr._result._type = UnitType.get()
        return expr
    }

    public operator func==(other: RawArrayInitByValue): Bool {
        return refEq(this, other)
    }
}

public class VArrayExpr <: Expression & Equatable<VArrayExpr> {
    private init(elements: ArrayList<Value>) {
        super(ExprKind.VArrayExpr, elements)
    }

    public static func create(elements: ArrayList<Value>): VArrayExpr {
        let expr = VArrayExpr(elements)
        let retTy = VArrayType.get(elements[0].ty, elements.size)
        expr._result._type = retTy
        return expr
    }

    public operator func==(other: VArrayExpr): Bool {
        return refEq(this, other)
    }
}

public class VArrayBuilder <: Expression & Equatable<VArrayBuilder> {
    private init(size: Value, initVal: Value, initFunc: Value) {
        super(ExprKind.VArrayBuilder, ArrayList<Value>([size, initVal, initFunc]))
    }

    public static func create(retTy: Type, size: Value, initVal: Value, initFunc: Value): VArrayBuilder {
        let expr = VArrayBuilder(size, initVal, initFunc)
        expr._result._type = retTy
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: VArrayBuilder): Bool {
        return refEq(this, other)
    }
}

public class GetException <: Expression & Equatable<GetException> {
    private init() {
        super(ExprKind.GetException)
    }

    public static func create(retTy: Type): GetException {
        let expr = GetException()
        expr._result._type = retTy
        return expr
    }

    public operator func==(other: GetException): Bool {
        return refEq(this, other)
    }
}

public class Lambda <: Expression & Equatable<Lambda> {
    internal let _funcType: FuncType
    internal var _genericTypeParams = ArrayList<GenericType>()
    internal let _identifier: String
    internal var _isCompileTimeValue: Bool = false
    internal var _isLocalFunc: Bool = false
    internal var _paramDftValHostFunc: ?Lambda = None
    internal var _parameters = ArrayList<Parameter>()
    internal var _returnValue: ?LocalVar = None
    internal let _srcCodeName: String

    public prop body: BlockGroup {
        get() {
            return _blockGroups[0]
        }
    }

    public prop funcType: FuncType {
        get() {
            return _funcType
        }
    }

    public prop genericTypeParams: Array<GenericType> {
        get() {
            return _genericTypeParams.toArray()
        }
    }

    public prop identifier: String {
        get() {
            return _identifier
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

    public mut prop isLocalFunc: Bool {
        get() {
            return _isLocalFunc
        }
        set(v) {
            _isLocalFunc = v
        }
    }

    public prop parameters: Array<Parameter> {
        get() {
            return _parameters.toArray()
        }
    }

    public prop returnValue: LocalVar {
        get() {
            return _returnValue.getOrThrow()
        }
    }

    public prop srcCodeName: String {
        get() {
            return _srcCodeName
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

    private init(ty: FuncType, identifier: String, srcName: String, genericTypeParams: ArrayList<GenericType>) {
        super(ExprKind.Lambda)
        this._identifier = identifier
        this._srcCodeName = srcName
        this._funcType = ty
        this._isLocalFunc = false
        this._genericTypeParams = genericTypeParams
    }

    public static func create(ty: FuncType, identifier: String, srcName: String, genericTypeParams: ArrayList<GenericType>): Lambda {
        // 1. create lambda expression
        let expr = Lambda(ty, identifier, srcName, genericTypeParams)
        expr._result._type = ty

        // 2. init parameters
        for (paramTy in ty.paramTypes) {
            expr.appendParameter(paramTy)
        }

        // 3. init body
        let bodyId = expr.topLevelFunc.generateBlockGroupId().toString()
        let body = BlockGroup(bodyId, expr._result)
        expr._blockGroups.add(body)
        let bb = body.appendBlock()
        body.setEntryBlock(bb)

        return expr
    }

    public func toString(): String {
        return lambdaToString(this, 0)
    }

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

    internal func appendParameter(ty: Type): Unit {
        let identifier = LOCAL_VAR_PREFIX + topLevelFunc.generateLocalId().toString()
        let result = Parameter(ty, identifier, this)
        _parameters.add(result)
    }

    public operator func==(other: Lambda): Bool {
        return refEq(this, other)
    }
}

public class Debug <: Expression & Equatable<Debug> {
    private let _srcCodeName: String

    public prop srcCodeName: String {
        get() {
            return _srcCodeName
        }
    }

    private init(location: Value, srcName: String) {
        super(ExprKind.Debug, ArrayList<Value>([location]))
        this._srcCodeName = srcName
    }

    public static func create(location: Value, srcName: String): Debug {
        let expr = Debug(location, srcName)
        expr._result._type = UnitType.get()
        return expr
    }

    protected override func operandsToString(): String {
        return baseOpsToString() + ", " + _srcCodeName
    }

    public operator func==(other: Debug): Bool {
        return refEq(this, other)
    }
}

sealed abstract class SpawnBase <: Expression & Equatable<SpawnBase> {
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

    internal init(kind: ExprKind, operands: ArrayList<Value>) {
        super(kind, operands)
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

    public operator func==(other: SpawnBase): Bool {
        return refEq(this, other)
    }
}

public class Spawn <: SpawnBase & Equatable<Spawn> {
    private init(lambda: Value) {
        super(ExprKind.Spawn, ArrayList<Value>([lambda]))
    }

    private init(lambda: Value, arg: Value) {
        super(ExprKind.Spawn, ArrayList<Value>([lambda, arg]))
    }

    public static func create(retTy: Type, lambda: Value): Spawn {
        let expr = Spawn(lambda)
        expr._result._type = retTy
        return expr
    }

    public static func create(retTy: Type, lambda: Value, arg: Value): Spawn {
        let expr = Spawn(lambda, arg)
        expr._result._type = retTy
        return expr
    }

    public operator func==(other: Spawn): Bool {
        return refEq(this, other)
    }
}

public class TrySpawn <: SpawnBase & Equatable<TrySpawn> {
    public prop errorBranch: Block {
        get() {
            return (operands[operands.size - 1] as Block).getOrThrow()
        }
    }

    public prop normalBranch: Block {
        get() {
            return (operands[operands.size - 2] as Block).getOrThrow()
        }
    }

    private init(lambda: Value, arg: Value, normal: Block, err: Block) {
        super(ExprKind.TrySpawn, ArrayList<Value>([lambda, arg]))
        _operands.add(normal)
        _operands.add(err)
    }

    private init(lambda: Value, normal: Block, err: Block) {
        super(ExprKind.TrySpawn, ArrayList<Value>([lambda]))
        _operands.add(normal)
        _operands.add(err)
    }

    public static func create(retTy: Type, lambda: Value, normal: Block, err: Block): TrySpawn {
        let expr = TrySpawn(lambda, normal, err)
        expr._result._type = retTy
        return expr
    }

    public static func create(retTy: Type, lambda: Value, arg: Value, normal: Block, err: Block): TrySpawn {
        let expr = TrySpawn(lambda, arg, normal, err)
        expr._result._type = retTy
        return expr
    }

    public operator func==(other: TrySpawn): Bool {
        return refEq(this, other)
    }
}

public class GetInstantiateValue <: Expression & Equatable<GetInstantiateValue> {
    internal let _instantiateTypes: ArrayList<Type>

    public prop instantiateTypes: Array<Type> {
        get() {
            return _instantiateTypes.toArray()
        }
    }

    private init(val: Function, instantiateTypes: ArrayList<Type>) {
        super(ExprKind.GetInstantiateValue, ArrayList<Value>([val]))
        this._instantiateTypes = instantiateTypes
    }

    public static func create(val: Function, instantiateTypes: ArrayList<Type>): GetInstantiateValue {
        let expr = GetInstantiateValue(val, instantiateTypes)
        expr._result._type = calculateFunctionInstType(val, instantiateTypes)
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: GetInstantiateValue): Bool {
        return refEq(this, other)
    }
}

public class GoTo <: Expression & Equatable<GoTo> {
    private init(target: Block) {
        super(ExprKind.Goto)
        _operands.add(target)
    }

    public static func create(target: Block): GoTo {
        let expr = GoTo(target)
        expr._result._type = UnitType.get()
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: GoTo): Bool {
        return refEq(this, other)
    }
}

public class Branch <: Expression & Equatable<Branch> {
    internal var _sourceExpr: SourceExpr = SourceExpr.Other

    public prop condition: Value {
        get() {
            assert(!operands.isEmpty(), "Branch: condition is not set")
            return operands[0]
        }
    }

    public prop falseTarget: Block {
        get() {
            assert(operands.size == 3, "Branch: false target is not set")
            if (let Some(b) <- (operands[2] as Block)) {
                return b
            }
            throw Exception("Branch: op[2] is not a block")
        }
    }

    public prop trueTarget: Block {
        get() {
            assert(operands.size == 3, "Branch: true target is not set")
            if (let Some(b) <- (operands[1] as Block)) {
                return b
            }
            throw Exception("Branch: op[1] is not a block")
        }
    }

    private init(condition: Value, trueTarget: Block, falseTarget: Block) {
        super(ExprKind.Branch, ArrayList<Value>([condition]))
        _operands.add(trueTarget)
        _operands.add(falseTarget)
    }

    public static func create(condition: Value, trueTarget: Block, falseTarget: Block): Branch {
        let expr = Branch(condition, trueTarget, falseTarget)
        expr._result._type = UnitType.get()
        expr._result._expr = expr
        return expr
    }

    protected override func getExtraCommentString(): String {
        return "sourceExpr: " + _sourceExpr.toString()
    }

    public operator func==(other: Branch): Bool {
        return refEq(this, other)
    }
}

public class MultiBranch <: Expression & Equatable<MultiBranch> {
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

    private init(condition: Value, default: Block, targets: ArrayList<Block>, caseValues: ArrayList<UInt64>) {
        super(ExprKind.MultiBranch, ArrayList<Value>([condition]))
        _operands.add(default)
        _operands.add(all: ArrayList<Value>(targets.size, { i => targets[i] }))
        _caseValues = caseValues
    }

    public static func create(condition: Value, default: Block, targets: ArrayList<Block>, caseValues: ArrayList<UInt64>): MultiBranch {
        let expr = MultiBranch(condition, default, targets, caseValues)
        expr._result._type = UnitType.get()
        expr._result._expr = expr
        return expr
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

    public operator func==(other: MultiBranch): Bool {
        return refEq(this, other)
    }
}

public class Exit <: Expression & Equatable<Exit> {
    private init() {
        super(ExprKind.Exit)
    }

    public static func create(): Exit {
        let expr = Exit()
        expr._result._type = UnitType.get()
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: Exit): Bool {
        return refEq(this, other)
    }
}

public class RaiseException <: Expression & Equatable<RaiseException> {
    private init(value: Value) {
        super(ExprKind.RaiseException, ArrayList<Value>([value]))
    }

    private init(value: Value, successor: Block) {
        super(ExprKind.RaiseException, ArrayList<Value>([value]))
        _operands.add(successor)
    }

    public static func create(value: Value, successor: Block): RaiseException {
        let expr = RaiseException(value, successor)
        expr._result._type = UnitType.get()
        return expr
    }

    public static func create(value: Value): RaiseException {
        let expr = RaiseException(value)
        expr._result._type = UnitType.get()
        expr._result._expr = expr
        return expr
    }

    public operator func==(other: RaiseException): Bool {
        return refEq(this, other)
    }
}
