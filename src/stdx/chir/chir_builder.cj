/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

import std.collection.*

public enum InsertPosition {
    | AtEnd(Block)
    | AtStart(Block)
    | Before(Expression)
    | After(Expression)
    | ...
}

public class CHIRBuilder {
    private var _insertPoint: Int64
    private var _parent: Block

    public init(parent: Block) {
        this._parent = parent
        _insertPoint = parent._exprs.size
    }

    public init(position: InsertPosition) {
        match (position) {
            case AtEnd(block) =>
                this._parent = block
                this._insertPoint = block._exprs.size
            case AtStart(block) =>
                this._parent = block
                this._insertPoint = 0
            case Before(expr) =>
                this._parent = expr.owner
                let index = expr.owner._exprs.indexOf(expr)
                if (index == -1) {
                    throw Exception("CHIRBuilder: ${expr.toString()} not found in block: ${expr.owner.toString()}")
                }
                this._insertPoint = index
            case After(expr) =>
                this._parent = expr.owner
                let index = expr.owner._exprs.indexOf(expr)
                if (index == -1) {
                    throw Exception("CHIRBuilder: ${expr.toString()} not found in block: ${expr.owner.toString()}")
                }
                this._insertPoint = index + 1
            case _ =>
                throw Exception("CHIRBuilder: Unknown position")
        }
    }

    public func createAllocate(ty: Type): Allocate {
        let expr = Allocate.create(ty)
        insertAndAdvance(expr)
        return expr
    }

    public func createTryAllocate(ty: Type, normal: Block, err: Block): TryAllocate {
        let expr = TryAllocate.create(ty, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createApply(callee: Value, funcCallCtx: FuncCallContext): Apply {
        let expr = Apply.create(callee, funcCallCtx)
        insertAndAdvance(expr)
        return expr
    }

    public func createTryApply(callee: Value, funcCallCtx: FuncCallContext, normal: Block, err: Block): TryApply {
        let expr = TryApply.create(callee, funcCallCtx, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryAdd(leftOp: Value, rightOp: Value, overflow: OverflowStrategy): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.Add, leftOp, rightOp)
        expr.overflow = overflow
        insertAndAdvance(expr)
        return expr
    }

    public func createTryBinaryAdd(leftOp: Value, rightOp: Value, normal: Block, err: Block): TryBinaryExpression {
        let expr = TryBinaryExpression.create(BinaryExprKind.Add, leftOp, rightOp, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryAnd(leftOp: Value, rightOp: Value): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.And, leftOp, rightOp)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryBitAnd(leftOp: Value, rightOp: Value): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.BitAnd, leftOp, rightOp)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryBitOr(leftOp: Value, rightOp: Value): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.BitOr, leftOp, rightOp)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryBitXor(leftOp: Value, rightOp: Value): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.BitXor, leftOp, rightOp)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryDiv(leftOp: Value, rightOp: Value, overflow: OverflowStrategy): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.Div, leftOp, rightOp)
        expr.overflow = overflow
        insertAndAdvance(expr)
        return expr
    }

    public func createTryBinaryDiv(leftOp: Value, rightOp: Value, overflow: OverflowStrategy, normal: Block, err: Block): TryBinaryExpression {
        let expr = TryBinaryExpression.create(BinaryExprKind.Div, leftOp, rightOp, normal, err)
        expr.overflow = overflow
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryEqual(leftOp: Value, rightOp: Value): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.Equal, leftOp, rightOp)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryExp(leftOp: Value, rightOp: Value, overflow: OverflowStrategy): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.Exp, leftOp, rightOp)
        expr.overflow = overflow
        insertAndAdvance(expr)
        return expr
    }

    public func createTryBinaryExp(leftOp: Value, rightOp: Value, normal: Block, err: Block): TryBinaryExpression {
        let expr = TryBinaryExpression.create(BinaryExprKind.Exp, leftOp, rightOp, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryGreaterThan(leftOp: Value, rightOp: Value): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.GT, leftOp, rightOp)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryGreaterThanOrEqual(leftOp: Value, rightOp: Value): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.GE, leftOp, rightOp)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryLShift(leftOp: Value, rightOp: Value, overflow: OverflowStrategy): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.LShift, leftOp, rightOp)
        expr.overflow = overflow
        insertAndAdvance(expr)
        return expr
    }

    public func createTryBinaryLShift(leftOp: Value, rightOp: Value, normal: Block, err: Block): TryBinaryExpression {
        let expr = TryBinaryExpression.create(BinaryExprKind.LShift, leftOp, rightOp, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryLessThan(leftOp: Value, rightOp: Value): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.LT, leftOp, rightOp)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryLessThanOrEqual(leftOp: Value, rightOp: Value): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.LE, leftOp, rightOp)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryMod(leftOp: Value, rightOp: Value, overflow: OverflowStrategy): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.Mod, leftOp, rightOp)
        expr.overflow = overflow
        insertAndAdvance(expr)
        return expr
    }

    public func createTryBinaryMod(leftOp: Value, rightOp: Value, normal: Block, err: Block): TryBinaryExpression {
        let expr = TryBinaryExpression.create(BinaryExprKind.Mod, leftOp, rightOp, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryMul(leftOp: Value, rightOp: Value, overflow: OverflowStrategy): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.Mul, leftOp, rightOp)
        expr.overflow = overflow
        insertAndAdvance(expr)
        return expr
    }

    public func createTryBinaryMul(leftOp: Value, rightOp: Value, normal: Block, err: Block): TryBinaryExpression {
        let expr = TryBinaryExpression.create(BinaryExprKind.Mul, leftOp, rightOp, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryNotEqual(leftOp: Value, rightOp: Value): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.NotEqual, leftOp, rightOp)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryOr(leftOp: Value, rightOp: Value): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.Or, leftOp, rightOp)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinaryRShift(leftOp: Value, rightOp: Value, overflow: OverflowStrategy): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.RShift, leftOp, rightOp)
        expr.overflow = overflow
        insertAndAdvance(expr)
        return expr
    }

    public func createTryBinaryRShift(leftOp: Value, rightOp: Value, normal: Block, err: Block): TryBinaryExpression {
        let expr = TryBinaryExpression.create(BinaryExprKind.RShift, leftOp, rightOp, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createBinarySub(leftOp: Value, rightOp: Value, overflow: OverflowStrategy): BinaryExpression {
        let expr = BinaryExpression.create(BinaryExprKind.Sub, leftOp, rightOp)
        expr.overflow = overflow
        insertAndAdvance(expr)
        return expr
    }

    public func createTryBinarySub(leftOp: Value, rightOp: Value, normal: Block, err: Block): TryBinaryExpression {
        let expr = TryBinaryExpression.create(BinaryExprKind.Sub, leftOp, rightOp, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createBranch(condition: Value, trueTarget: Block, falseTarget: Block): Branch {
        let expr = Branch.create(condition, trueTarget, falseTarget)
        insertAndAdvance(expr)
        return expr
    }

    public func createBox(srcVal: Value, dstTy: Type): Box {
        let expr = Box.create(srcVal, dstTy)
        insertAndAdvance(expr)
        return expr
    }

    public func createConstant(val: LiteralValue): Constant {
        let expr = Constant.create(val)
        insertAndAdvance(expr)
        return expr
    }

    public func createDebug(location: Value, srcCodeName: String): Debug {
        let expr = Debug.create(location, srcCodeName)
        insertAndAdvance(expr)
        return expr
    }

    public func createExit(): Exit {
        let expr = Exit.create()
        insertAndAdvance(expr)
        return expr
    }

    public func createField(val: Value, path: ArrayList<UInt64>): Field {
        let expr = Field.create(val, path)
        insertAndAdvance(expr)
        return expr
    }

    public func createFieldByName(val: Value, fieldNames: ArrayList<String>): FieldByName {
        let expr = FieldByName.create(val, fieldNames)
        insertAndAdvance(expr)
        return expr
    }

    public func createGetElementByName(location: Value, fieldNames: ArrayList<String>): GetElementByName {
        let expr = GetElementByName.create(location, fieldNames)
        insertAndAdvance(expr)
        return expr
    }

    public func createGetException(retTy: Type): GetException {
        let expr = GetException.create(retTy)
        insertAndAdvance(expr)
        return expr
    }

    public func createGetInstantiateValue(val: Function, instantiateTypes: ArrayList<Type>): GetInstantiateValue {
        let expr = GetInstantiateValue.create(val, instantiateTypes)
        insertAndAdvance(expr)
        return expr
    }

    public func createGetRTTI(val: Value): GetRTTI {
        let expr = GetRTTI.create(val)
        insertAndAdvance(expr)
        return expr
    }

    public func createGetRTTIStatic(rttiType: Type): GetRTTIStatic {
        let expr = GetRTTIStatic.create(rttiType)
        insertAndAdvance(expr)
        return expr
    }

    public func createGoTo(target: Block): GoTo {
        let expr = GoTo.create(target)
        insertAndAdvance(expr)
        return expr
    }

    public func createInstanceOf(srcVal: Value, targetTy: Type): InstanceOf {
        let expr = InstanceOf.create(srcVal, targetTy)
        insertAndAdvance(expr)
        return expr
    }

    public func createInvoke(retTy: Type, callContext: InvokeCallContext): Invoke {
        let expr = Invoke.create(retTy, callContext)
        insertAndAdvance(expr)
        return expr
    }

    public func createTryInvoke(retTy: Type, callContext: InvokeCallContext, normal: Block, err: Block): TryInvoke {
        let expr = TryInvoke.create(retTy, callContext, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createLambda(ty: FuncType, mangledName: String, srcName: String, genericTypeParams!: Array<GenericType> = Array<GenericType>()): Lambda {
        // 1. create lambda expression
        let expr = Lambda.create(ty, mangledName, srcName, ArrayList<GenericType>.of(genericTypeParams))
        insertAndAdvance(expr)

        // 2. init parameters
        expr.initParameters()

        // 3. init body
        expr.initBody()

        return expr
    }

    public func createLoad(location: Value): Load {
        let expr = Load.create(location)
        insertAndAdvance(expr)
        return expr
    }

    public func createMultiBranch(condition: Value, defaultBlock: Block, targets: ArrayList<Block>, caseValues: ArrayList<UInt64>): MultiBranch {
        let expr = MultiBranch.create(condition, defaultBlock, targets, caseValues)
        insertAndAdvance(expr)
        return expr
    }

    public func createNumericCast(srcVal: Value, dstTy: Type, overflow: OverflowStrategy): NumericCast {
        let expr = NumericCast.create(srcVal, dstTy, overflow)
        insertAndAdvance(expr)
        return expr
    }

    public func createTryNumericCast(srcVal: Value, dstTy: Type, normal: Block, err: Block): TryNumericCast {
        let expr = TryNumericCast.create(srcVal, dstTy, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createRaiseException(value: Value): RaiseException {
        let expr = RaiseException.create(value)
        insertAndAdvance(expr)
        return expr
    }

    public func createRaiseException(value: Value, successor: Block): RaiseException {
        let expr = RaiseException.create(value, successor)
        insertAndAdvance(expr)
        return expr
    }

    public func createRawArrayAllocate(elementType: Type, size: Value): RawArrayAllocate {
        let expr = RawArrayAllocate.create(elementType, size)
        insertAndAdvance(expr)
        return expr
    }

    public func createTryRawArrayAllocate(elementType: Type, size: Value, normal: Block, err: Block): TryRawArrayAllocate {
        let expr = TryRawArrayAllocate.create(elementType, size, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createRawArrayInitByValue(memory: Value, size: Value, initVal: Value): RawArrayInitByValue {
        let expr = RawArrayInitByValue.create(memory, size, initVal)
        insertAndAdvance(expr)
        return expr
    }

    public func createRawArrayLiteralInit(memory: Value, elements: ArrayList<Value>): RawArrayLiteralInit {
        let expr = RawArrayLiteralInit.create(memory, elements)
        insertAndAdvance(expr)
        return expr
    }

    public func createSpawn(retTy: Type, val: Value): Spawn {
        let expr = Spawn.create(retTy, val)
        insertAndAdvance(expr)
        return expr
    }

    public func createSpawn(retTy: Type, val: Value, arg: Value): Spawn {
        let expr = Spawn.create(retTy, val, arg)
        insertAndAdvance(expr)
        return expr
    }

    public func createTrySpawn(retTy: Type, val: Value, normal: Block, err: Block): TrySpawn {
        let expr = TrySpawn.create(retTy, val, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createTrySpawn(retTy: Type, val: Value, arg: Value, normal: Block, err: Block): TrySpawn {
        let expr = TrySpawn.create(retTy, val, arg, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createStaticCast(srcVal: Value, dstTy: Type): StaticCast {
        let expr = StaticCast.create(srcVal, dstTy)
        insertAndAdvance(expr)
        return expr
    }

    public func createStore(val: Value, location: Value): Store {
        let expr = Store.create(val, location)
        insertAndAdvance(expr)
        return expr
    }

    public func createStoreElementByName(val: Value, location: Value, fieldNames: ArrayList<String>): StoreElementByName {
        let expr = StoreElementByName.create(val, location, fieldNames)
        insertAndAdvance(expr)
        return expr
    }

    public func createTuple(elements: Array<Value>): Tuple {
        let expr = Tuple.create(ArrayList<Value>.of(elements))
        insertAndAdvance(expr)
        return expr
    }

    public func createUnboxToRef(srcVal: Value, dstTy: Type): UnboxToRef {
        let expr = UnboxToRef.create(srcVal, dstTy)
        insertAndAdvance(expr)
        return expr
    }

    public func createUnboxToValue(srcVal: Value, dstTy: Type): UnboxToValue {
        let expr = UnboxToValue.create(srcVal, dstTy)
        insertAndAdvance(expr)
        return expr
    }

    public func createUnaryBitNot(op: Value): UnaryExpression {
        let expr = UnaryExpression.create(UnaryExprKind.BitNot, op)
        insertAndAdvance(expr)
        return expr
    }

    public func createUnaryNeg(op: Value, overflow: OverflowStrategy): UnaryExpression {
        let expr = UnaryExpression.create(UnaryExprKind.Neg, op)
        expr.overflow = overflow
        insertAndAdvance(expr)
        return expr
    }

    public func createTryUnaryNeg(op: Value, normal: Block, err: Block): TryUnaryExpression {
        let expr = TryUnaryExpression.create(op, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    public func createUnaryNot(op: Value): UnaryExpression {
        let expr = UnaryExpression.create(UnaryExprKind.Not, op)
        insertAndAdvance(expr)
        return expr
    }

    public func createVArray(elements: ArrayList<Value>): VArrayExpr {
        let expr = VArrayExpr.create(elements)
        insertAndAdvance(expr)
        return expr
    }

    public func createVArrayBuilder(retTy: Type, size: Value, initVal: Value, initFunc: Value): VArrayBuilder {
        let expr = VArrayBuilder.create(retTy, size, initVal, initFunc)
        insertAndAdvance(expr)
        return expr
    }

    internal func createIntrinsic(retTy: Type, kind: IntrinsicKind, funcCallCtx: FuncCallContext): Intrinsic {
        let expr = Intrinsic.create(retTy, kind, funcCallCtx)
        insertAndAdvance(expr)
        return expr
    }

    internal func createTryIntrinsic(retTy: Type, kind: IntrinsicKind, funcCallCtx: FuncCallContext, normal: Block, err: Block): TryIntrinsic {
        let expr = TryIntrinsic.create(retTy, kind, funcCallCtx, normal, err)
        insertAndAdvance(expr)
        return expr
    }

    private func insertAndAdvance(expr: Expression): Unit {
        _parent.insertExpr(expr, _insertPoint)
        _insertPoint++
    }
}

extend ArrayList<Expression> {
    internal func indexOf(item: Expression): Int64 {
        for (i in 0..size) {
            if (this[i] == item) {
                return i
            }
        }
        return -1
    }
}
