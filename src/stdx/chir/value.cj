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
internal enum ValueKind {
    Invalid
    | GlobalVar
    | LocalVar
    | Parameter
    | Func
    | Block
    | BlockGroup
    | Literal
}

@Derive[Equatable]
@Derive[ToString]
internal enum FuncKind {
    Default
    | Getter
    | Setter
    | Lambda
    | ClassConstructor
    | PrimaryClassConstructor
    | StructConstructor
    | PrimaryStructConstructor
    | GlobalVarInit
    | Finalizer
    | MainEntry
    | AnnoFactoryFunc
    | MacroFunc
    | DefaultParameterFunc
    | InstanceVarInit
}

@Derive[Equatable]
@Derive[ToString]
internal enum LiteralKind {
    BoolLit
    | RuneLit
    | IntLit
    | FloatLit
    | StringLit
    | UnitLit
    | NullLit
}

sealed abstract class Value <: Base & ToString & Hashable & Equatable<Value> {
    internal var _hashCode: Int64 = 0
    internal var _identifier: String
    internal var _kind: ValueKind
    internal var _type: Type
    internal var _users = ArrayList<Expression>()

    public prop identifier: String {
        get() {
            return _identifier
        }
    }

    public prop identifierWithoutPrefix: String {
        get() {
            var s = _identifier
            if (s.startsWith(GLOBAL_SYMBOL_PREFIX)) {
                s = s.removePrefix(GLOBAL_SYMBOL_PREFIX)
            } else if (s.startsWith(BLOCK_PREFIX)) {
                s = s.removePrefix(BLOCK_PREFIX)
            } else if (s.startsWith(LOCAL_VAR_PREFIX)) {
                s = s.removePrefix(LOCAL_VAR_PREFIX)
            }
            return s
        }
    }

    public mut prop ty: Type {
        get() {
            return _type
        }
        set(v) {
            _type = v
        }
    }

    public prop users: Array<Expression> {
        get() {
            return _users.toArray()
        }
    }

    internal init(kind: ValueKind, identifier: String) {
        this._kind = kind
        this._type = InvalidType.get()
        this._identifier = identifier
    }

    internal init(kind: ValueKind, ty: Type, identifier: String) {
        this._kind = kind
        this._type = ty
        this._identifier = identifier
    }

    public func dump(): Unit {
        println(toString())
    }

    public func hashCode(): Int64 {
        return _hashCode
    }

    public func isBlock(): Bool {
        return _kind == ValueKind.Block
    }

    public func isBlockGroup(): Bool {
        return _kind == ValueKind.BlockGroup
    }

    public func isFunction(): Bool {
        return _kind == ValueKind.Func
    }

    public func isGlobalVar(): Bool {
        return _kind == ValueKind.GlobalVar
    }

    public func isLiteral(): Bool {
        return _kind == ValueKind.Literal
    }

    public func isLocalVar(): Bool {
        return _kind == ValueKind.LocalVar
    }

    public func isParameter(): Bool {
        return _kind == ValueKind.Parameter
    }

    protected open func calculateHashCode(): Int64

    internal func isInvalid(): Bool {
        return _kind == ValueKind.Invalid
    }

    public operator func==(other: Value): Bool {
        return refEq(this, other)
    }
}

public class Block <: Value & Equatable<Block> {
    internal var _exceptions: ?ArrayList<ClassLikeType> = None
    internal var _exprs = ArrayList<Expression>()
    internal var _owner: BlockGroup
    internal var _predecessors = ArrayList<Block>()

    public mut prop exceptions: Array<ClassLikeType> {
        get() {
            return _exceptions.getOrThrow().toArray()
        }
        set(value) {
            _exceptions = ArrayList<ClassLikeType>.of(value)
        }
    }

    public prop exprs: Array<Expression> {
        get() {
            return _exprs.toArray()
        }
    }

    public prop isLandingPadBlock: Bool {
        get() {
            return _exceptions.isSome()
        }
    }

    public prop owner: BlockGroup {
        get() {
            return _owner
        }
    }

    public prop predecessors: Array<Block> {
        get() {
            return _predecessors.toArray()
        }
    }

    public prop topLevelFunc: Function {
        get() {
            return _owner.topLevelFunc
        }
    }

    internal init(identifier: String, owner: BlockGroup) {
        super(ValueKind.Block, identifier)
        this._owner = owner
        this._hashCode = calculateHashCode()
        owner._blocks.add(this)
    }

    public func appendExpr(expr: Expression): Unit {
        _exprs.add(expr)
        expr._owner = this
        updateLocalVarIdAndHashCode(expr._result)
    }

    public func destroySelf(): Unit {
        for (expr in _exprs) {
            expr.destroySelf()
        }
        _predecessors.clear()
        _exceptions = None
        _owner._blocks.removeIf({ bb => bb == this })
        _kind = ValueKind.Invalid
    }

    public func insertExpr(expr: Expression, at: Int64): Unit {
        if (at < 0) {
            throw Exception("Invalid insert position: ${at}")
        }
        if (at >= _exprs.size) {
            _exprs.add(expr)
        } else {
            _exprs.add(expr, at: at)
        }
        expr._owner = this
        updateLocalVarIdAndHashCode(expr._result)
    }

    public func toString(): String {
        return blockToString(this, 0)
    }

    protected override func calculateHashCode(): Int64 {
        return (_owner.topLevelFunc.identifier + "_BG" + _owner.identifier + "_B" + identifier).hashCode()
    }

    public operator func==(other: Block): Bool {
        return refEq(this, other)
    }
}

public class BlockGroup <: Value & Equatable<BlockGroup> {
    internal var _blocks = ArrayList<Block>()
    // owner is lambda(LocalVar) or global function(Function)
    internal var _entryBlock: ?Block = None
    internal var _owner: Value

    public prop blocks: Array<Block> {
        get() {
            return _blocks.toArray()
        }
    }

    public prop entryBlock: Block {
        get() {
            if (let Some(b) <- _entryBlock) {
                return b
            } else {
                throw Exception("Entry block is not set")
            }
        }
    }

    public prop owner: Value {
        get() {
            return _owner
        }
    }

    public prop topLevelFunc: Function {
        get() {
            if (let Some(f) <- (_owner as Function)) {
                return f
            } else if (let Some(lv) <- (_owner as LocalVar)) {
                return lv.topLevelFunc
            } else {
                throw Exception("Invalid owner: ${_owner.toString()}")
            }
        }
    }

    internal init(identifier: String, owner: Value) {
        super(ValueKind.BlockGroup, identifier)
        this._owner = owner
        this._hashCode = calculateHashCode()
    }

    public func appendBlock(): Block {
        let identifier = BLOCK_PREFIX + topLevelFunc.generateBlockId().toString()
        let bb = Block(identifier, this)
        _blocks.add(bb)
        return bb
    }

    public func destroySelf(): Unit {
        for (block in _blocks) {
            block.destroySelf()
        }
        _blocks.clear()
        _entryBlock = None
        if (let Some(f) <- (_owner as Function)) {
            f._body = None
        } else if (let Some(lv) <- (_owner as LocalVar)) {
            lv.expr._blockGroups.removeIf({ bg => bg == this })
        } else {
            throw Exception("Invalid owner: ${_owner.toString()}")
        }
        _kind = ValueKind.Invalid
    }

    public func setEntryBlock(block: Block): Unit {
        if (!_blocks.contains(block)) {
            throw Exception("Entry block must push into BlockGroup first")
        }
        _entryBlock = block
    }

    public func toString(): String {
        return blockGroupToString(this, 0)
    }

    protected override func calculateHashCode(): Int64 {
        return (topLevelFunc.identifier + "_BG" + identifier).hashCode()
    }

    public operator func==(other: BlockGroup): Bool {
        return refEq(this, other)
    }
}

sealed abstract class GlobalValue <: Value & Equatable<GlobalValue> {
    internal var _annoInfo: AnnoInfo = AnnoInfo()
    internal var _declaredParent: ?CustomTypeDef = None
    internal let _packageName: String
    internal var _rawMangledName: String = ""
    internal let _srcCodeName: String

    public mut prop annotations: Array<Annotation> {
        get() {
            return _annoInfo._annoClasses.toArray()
        }
        set(v) {
            _annoInfo._annoClasses = ArrayList<Annotation>.of(v)
        }
    }

    public prop declaredParent: ?CustomTypeDef {
        get() {
            return _declaredParent
        }
    }

    public prop packageName: String {
        get() {
            return _packageName
        }
    }

    public prop srcCodeName: String {
        get() {
            return _srcCodeName
        }
    }

    internal init(kind: ValueKind, ty: Type, identifier: String, srcName: String, pkgName: String) {
        super(kind, ty, identifier)
        this._srcCodeName = srcName
        this._packageName = pkgName
    }

    public func isCompilerAdd(): Bool {
        return _attributes.testAttr(Attribute.CompilerAdd)
    }

    public func isConst(): Bool {
        return _attributes.testAttr(Attribute.Const)
    }

    public func isExternalLinkage(): Bool {
        return getAnno<LinkTypeInfo, LinkType>() == LinkType.External
    }

    public func isForeign(): Bool {
        return _attributes.testAttr(Attribute.Foreign)
    }

    public func isImported(): Bool {
        return _attributes.testAttr(Attribute.Imported)
    }

    public func isInternal(): Bool {
        return _attributes.testAttr(Attribute.Internal)
    }

    public func isPrivate(): Bool {
        return _attributes.testAttr(Attribute.Private)
    }

    public func isProtected(): Bool {
        return _attributes.testAttr(Attribute.Protected)
    }

    public func isPublic(): Bool {
        return _attributes.testAttr(Attribute.Public)
    }

    public func isStatic(): Bool {
        return _attributes.testAttr(Attribute.Static)
    }

    public func setConst(enable: Bool): Unit {
        _attributes.setAttr(Attribute.Const, enable)
    }

    public func setInternal(): Unit {
        _attributes.setInternal()
    }

    public func setPrivate(): Unit {
        _attributes.setPrivate()
    }

    public func setProtected(): Unit {
        _attributes.setProtected()
    }

    public func setPublic(): Unit {
        _attributes.setPublic()
    }

    public func setStatic(enable: Bool): Unit {
        _attributes.setAttr(Attribute.Static, enable)
    }

    protected override func calculateHashCode(): Int64 {
        return identifier.hashCode()
    }

    internal func globalValueToString(): String {
        var comment = ArrayList<String>()
        if (let str <- baseCommentToString() && !str.isEmpty()) {
            comment.add(str)
        }
        if (!_srcCodeName.isEmpty()) {
            comment.add("srcCodeName: " + _srcCodeName)
        }
        if (!_packageName.isEmpty()) {
            comment.add("packageName: " + _packageName)
        }
        if (_declaredParent.isSome()) {
            comment.add("declaredParent: " + _declaredParent.getOrThrow().identifier)
        }
        if (comment.isEmpty()) {
            return ""
        }
        return String.join(comment.toArray(), delimiter: ", ")
    }

    public operator func==(other: GlobalValue): Bool {
        return refEq(this, other)
    }
}

public class GlobalVar <: GlobalValue & Equatable<GlobalVar> {
    internal var _initializer: ?Value = None

    public prop initializer: ?Value {
        get() {
            return _initializer
        }
    }

    internal init(ty: Type, identifier: String, srcName: String, pkgName: String) {
        super(ValueKind.GlobalVar, ty, identifier, srcName, pkgName)
        this._hashCode = calculateHashCode()
    }

    public func isReadOnly(): Bool {
        return _attributes.testAttr(Attribute.ReadOnly)
    }

    public func isSrcCodeImported(): Bool {
        return isImported() && !_initializer.isNone()
    }

    public func setInitializer(initializer: Value): Unit {
        _initializer = initializer
    }

    public func setReadOnly(enable: Bool): Unit {
        _attributes.setAttr(Attribute.ReadOnly, enable)
    }

    public func toString(): String {
        let result = StringBuilder()
        if (let str <- _annoInfo.toString() && !str.isEmpty()) {
            result.append(str)
            result.append("\n")
        }
        result.append(_attributes.toString())
        if (isReadOnly()) {
            result.append("let ")
        } else {
            result.append("var ")
        }
        result.append(identifier + ": " + ty.toString())
        if (let Some(v) <- initializer) {
            if (v.isLiteral()) {
                result.append(" = " + v.toString())
            } else {
                // must be init function
                result.append(" = " + v.identifier + "()")
            }
        }
        if (let str <- globalValueToString() && !str.isEmpty()) {
            result.append(" // ")
            result.append(str)
        }
        return result.toString()
    }

    public operator func==(other: GlobalVar): Bool {
        return refEq(this, other)
    }
}

public class Function <: GlobalValue & Equatable<Function> {
    internal var _blockGroupId: UInt64 = 0
    internal var _blockId: UInt64 = 0
    internal var _body: ?BlockGroup = None
    internal var _funcKind: FuncKind = FuncKind.Default
    internal var _genericDecl: ?Function = None
    internal var _genericTypeParams = ArrayList<GenericType>()
    internal var _isCFFIWrapper: Bool = false
    internal var _isFastNative: Bool = false
    internal var _localId: UInt64 = 0
    internal var _oriLambdaFuncTy: ?Type = None
    internal var _oriLambdaGenericTypeParams: ?ArrayList<GenericType> = None
    internal var _paramDftValHostFunc: ?Function = None
    internal var _parameters = ArrayList<Parameter>()
    internal var _propLocation: DebugLocation = DebugLocation.invalid()
    internal var _retValue: ?LocalVar = None

    public prop body: ?BlockGroup {
        get() {
            return _body
        }
    }

    public prop funcSrcCodeType: FuncType {
        get() {
            if (isInstanceMemberMethod()) {
                let (_, paramTypes) = funcType.paramTypes.splitAt(1)
                return FuncType.get(paramTypes, funcType.returnType)
            } else {
                return funcType
            }
        }
    }

    public prop funcType: FuncType {
        get() {
            (_type as FuncType).getOrThrow()
        }
    }

    public mut prop genericTypeParams: Array<GenericType> {
        get() {
            return _genericTypeParams.toArray()
        }
        set(v) {
            let enableGeneric = if (v.isEmpty()) {
                false
            } else {
                true
            }
            _attributes.setAttr(Attribute.Generic, enableGeneric)
            _genericTypeParams = ArrayList<GenericType>.of(v)
        }
    }

    public prop parameters: Array<Parameter> {
        get() {
            return _parameters.toArray()
        }
    }

    public prop returnValue: ?LocalVar {
        get() {
            return _retValue
        }
    }

    internal init(ty: FuncType, identifier: String, srcName: String, pkgName: String) {
        super(ValueKind.Func, ty, identifier, srcName, pkgName)
        this._hashCode = calculateHashCode()
    }

    public func initBody(): Unit {
        let newBody = addBody()
        let bb = newBody.appendBlock()
        newBody.setEntryBlock(bb)
    }

    public func isAbstract(): Bool {
        // 1. it is not implemented in the current class
        if (_attributes.testAttr(Attribute.Abstract)) {
            return true
        }
        // 2. it is a method in interface
        if (let Some(parent) <- _declaredParent) {
            return parent.isInterface()
        }
        return false
    }

    public func isDeclaredInCurPackage(): Bool {
        return !isImported()
    }

    public func isGeneric(): Bool {
        return _attributes.testAttr(Attribute.Generic)
    }

    public func isInstanceMemberMethod(): Bool {
        return isMemberMethod() && !isStatic()
    }

    public func isMemberMethod(): Bool {
        return _declaredParent.isSome()
    }

    public func isOpen(): Bool {
        return _attributes.testAttr(Attribute.Virtual) || _attributes.testAttr(Attribute.Abstract)
    }

    public func isSrcCodeImported(): Bool {
        return isImported() && _body.isSome()
    }

    public func isStaticMemberMethod(): Bool {
        return isMemberMethod() && isStatic()
    }

    public func moveBodyTo(other: Function): Unit {
        if (let Some(oBody) <- other._body) {
            oBody.destroySelf()
        }
        other._body = _body
        this._body = None
        other._parameters = _parameters
        this._parameters.clear()
        other._genericTypeParams = _genericTypeParams
        this._genericTypeParams.clear()
        other._retValue = _retValue
        this._retValue = None
        other._localId = _localId
        this._localId = 0
        other._blockId = _blockId
        this._blockId = 0
        other._blockGroupId = _blockGroupId
        this._blockGroupId = 0
    }

    public func selfOrParentIsGeneric(): Bool {
        return isGeneric() || (_declaredParent.isSome() && _declaredParent.getOrThrow().isGeneric())
    }

    public func setAbstract(enable: Bool): Unit {
        _attributes.setAttr(Attribute.Abstract, enable)
    }

    public func setOpen(enable: Bool): Unit {
        _attributes.setAttr(Attribute.Virtual, enable)
    }

    public func toString(): String {
        return functionToString(this, 0)
    }

    internal func addBody(): BlockGroup {
        if (_body.isSome()) {
            throw Exception("Function body already set")
        }
        let identifier = generateBlockGroupId().toString()
        _body = BlockGroup(identifier, this)
        return _body.getOrThrow()
    }

    internal func appendParameter(ty: Type): Parameter {
        let identifier = LOCAL_VAR_PREFIX + generateLocalId().toString()
        let result = Parameter(ty, identifier, this)
        _parameters.add(result)
        return result
    }

    internal func generateBlockGroupId(): UInt64 {
        let tmp = _blockGroupId
        _blockGroupId++
        return tmp
    }

    internal func generateBlockId(): UInt64 {
        let tmp = _blockId
        _blockId++
        return tmp
    }

    internal func generateLocalId(): UInt64 {
        let tmp = _localId
        _localId++
        return tmp
    }

    public operator func==(other: Function): Bool {
        return refEq(this, other)
    }
}

sealed abstract class LiteralValue <: Value & Equatable<LiteralValue> {
    internal let literalKind: LiteralKind

    internal init(ty: Type, literalKind: LiteralKind) {
        super(ValueKind.Literal, ty, String.empty)
        this.literalKind = literalKind
    }

    public operator func==(other: LiteralValue): Bool {
        return refEq(this, other)
    }
}

public class BoolLiteral <: LiteralValue & Equatable<BoolLiteral> {
    private static var CACHE = ArrayList<BoolLiteral>()
    internal let _value: Bool

    public prop value: Bool {
        get() {
            return _value
        }
    }

    static init() {
        CACHE.add(BoolLiteral(BoolType.get(), false))
        CACHE.add(BoolLiteral(BoolType.get(), true))
    }

    private init(ty: BoolType, value: Bool) {
        super(ty, LiteralKind.BoolLit)
        this._value = value
        this._hashCode = calculateHashCode()
    }

    public static func get(value: Bool): BoolLiteral {
        if (value) {
            return CACHE[1]
        } else {
            return CACHE[0]
        }
    }

    public func toString(): String {
        return value.toString()
    }

    protected override func calculateHashCode(): Int64 {
        return ("BoolLiteral_" + _value.toString()).hashCode()
    }

    public operator func==(other: BoolLiteral): Bool {
        return refEq(this, other)
    }
}

public class RuneLiteral <: LiteralValue & Equatable<RuneLiteral> {
    private static var CACHE = HashMap<Rune, RuneLiteral>()
    internal let _value: Rune

    public prop value: Rune {
        get() {
            return _value
        }
    }

    private init(ty: RuneType, value: Rune) {
        super(ty, LiteralKind.RuneLit)
        this._value = value
        this._hashCode = calculateHashCode()
    }

    public static func get(value: Rune): RuneLiteral {
        if (let Some(literal) <- CACHE.get(value)) {
            return literal
        }
        let newLiteral = RuneLiteral(RuneType.get(), value)
        CACHE[value] = newLiteral
        return newLiteral
    }

    public func toString(): String {
        return "\'" + value.toString() + "\'"
    }

    protected override func calculateHashCode(): Int64 {
        return ("RuneLiteral_" + _value.toString()).hashCode()
    }

    public operator func==(other: RuneLiteral): Bool {
        return refEq(this, other)
    }
}

public class IntLiteral <: LiteralValue & Equatable<IntLiteral> {
    private static var CACHE = HashMap<IntType, HashMap<UInt64, IntLiteral>>()
    internal let _value: UInt64

    public prop signedValue: Int64 {
        get() {
            return Int64(_value)
        }
    }

    public prop unsignedValue: UInt64 {
        get() {
            return _value
        }
    }

    private init(ty: IntType, value: UInt64) {
        super(ty, LiteralKind.IntLit)
        this._value = value
        this._hashCode = calculateHashCode()
    }

    public static func get(ty: IntType, value: UInt64): IntLiteral {
        if (let Some(intTypes) <- CACHE.get(ty)) {
            if (let Some(literal) <- intTypes.get(value)) {
                return literal
            } else {
                let newLiteral = IntLiteral(ty, value)
                intTypes[value] = newLiteral
                return newLiteral
            }
        }
        let newLiteral = IntLiteral(ty, value)
        CACHE[ty] = HashMap<UInt64, IntLiteral>((value, newLiteral))
        return newLiteral
    }

    public func isSigned(): Bool {
        return (ty as IntType).getOrThrow().isSigned()
    }

    public func toString(): String {
        let suffix = if (isSigned()) { "i" } else { "u" }
        return unsignedValue.toString() + suffix
    }

    protected override func calculateHashCode(): Int64 {
        return (ty.toString() + "_" + _value.toString()).hashCode()
    }

    public operator func==(other: IntLiteral): Bool {
        return refEq(this, other)
    }
}

public class FloatLiteral <: LiteralValue & Equatable<FloatLiteral> {
    private static var CACHE = HashMap<FloatType, HashMap<Float64, FloatLiteral>>()
    internal let _value: Float64

    public prop value: Float64 {
        get() {
            return _value
        }
    }

    private init(ty: FloatType, value: Float64) {
        super(ty, LiteralKind.FloatLit)
        this._value = value
        this._hashCode = calculateHashCode()
    }

    public static func get(ty: FloatType, value: Float64): FloatLiteral {
        if (let Some(floatTypes) <- CACHE.get(ty)) {
            if (let Some(literal) <- floatTypes.get(value)) {
                return literal
            } else {
                let newLiteral = FloatLiteral(ty, value)
                floatTypes[value] = newLiteral
                return newLiteral
            }
        }
        let newLiteral = FloatLiteral(ty, value)
        CACHE[ty] = HashMap<Float64, FloatLiteral>((value, newLiteral))
        return newLiteral
    }

    public func toString(): String {
        return value.toString() + "f"
    }

    protected override func calculateHashCode(): Int64 {
        return (ty.toString() + "_" + _value.toString()).hashCode()
    }

    public operator func==(other: FloatLiteral): Bool {
        return refEq(this, other)
    }
}

public class StringLiteral <: LiteralValue & Equatable<StringLiteral> {
    private static var CACHE = HashMap<String, StringLiteral>()
    internal let _value: String

    public prop value: String {
        get() {
            return _value
        }
    }

    private init(ty: Type, value: String) {
        super(ty, LiteralKind.StringLit)
        this._value = value
        this._hashCode = calculateHashCode()
    }

    public static func get(ty: Type, value: String): StringLiteral {
        if (let Some(literal) <- CACHE.get(value)) {
            return literal
        }
        let newLiteral = StringLiteral(ty, value)
        CACHE[value] = newLiteral
        return newLiteral
    }

    public func toString(): String {
        return "\"" + value + "\""
    }

    protected override func calculateHashCode(): Int64 {
        return (ty.toString() + "_" + _value.toString()).hashCode()
    }

    public operator func==(other: StringLiteral): Bool {
        return refEq(this, other)
    }
}

public class UnitLiteral <: LiteralValue & Equatable<UnitLiteral> {
    private static let unitLit = UnitLiteral(UnitType.get())

    private init(ty: UnitType) {
        super(ty, LiteralKind.UnitLit)
        this._hashCode = calculateHashCode()
    }

    public static func get(): UnitLiteral {
        return unitLit
    }

    public func toString(): String {
        return "Unit"
    }

    protected override func calculateHashCode(): Int64 {
        return ty.toString().hashCode()
    }

    public operator func==(other: UnitLiteral): Bool {
        return refEq(this, other)
    }
}

public class NullLiteral <: LiteralValue & Equatable<NullLiteral> {
    private static var CACHE = HashMap<Type, NullLiteral>()

    private init(ty: Type) {
        super(ty, LiteralKind.NullLit)
        this._hashCode = calculateHashCode()
    }

    public static func get(ty: Type): NullLiteral {
        if (let Some(literal) <- CACHE.get(ty)) {
            return literal
        }
        let newLiteral = NullLiteral(ty)
        CACHE[ty] = newLiteral
        return newLiteral
    }

    public func toString(): String {
        return "Null"
    }

    protected override func calculateHashCode(): Int64 {
        return ty.toString().hashCode()
    }

    public operator func==(other: NullLiteral): Bool {
        return refEq(this, other)
    }
}

public class LocalVar <: Value & Equatable<LocalVar> {
    internal var _expr: ?Expression = None
    internal var _isRetValue = false

    public prop expr: Expression {
        get() {
            if (let Some(e) <- _expr) {
                return e
            } else {
                throw Exception("Expression is not set")
            }
        }
    }

    public prop topLevelFunc: Function {
        get() {
            return expr.topLevelFunc
        }
    }

    internal init(ty: Type) {
        super(ValueKind.LocalVar, ty, String.empty)
        this._hashCode = 0
    }

    public func toString(): String {
        return expr.toString()
    }

    protected override func calculateHashCode(): Int64 {
        return (topLevelFunc.identifier + "_LV" + identifier).hashCode()
    }

    public operator func==(other: LocalVar): Bool {
        return refEq(this, other)
    }
}

public class Parameter <: Value & Equatable<Parameter> {
    internal var _annoInfo: AnnoInfo = AnnoInfo()
    internal var _owner: Value

    public mut prop annotations: Array<Annotation> {
        get() {
            return _annoInfo._annoClasses.toArray()
        }
        set(v) {
            _annoInfo._annoClasses = ArrayList<Annotation>.of(v)
        }
    }

    public prop topLevelFunc: Function {
        get() {
            if (let Some(f) <- (_owner as Function)) {
                return f
            } else if (let Some(lv) <- (_owner as LocalVar)) {
                return lv.topLevelFunc
            } else {
                throw Exception("Invalid owner: ${_owner.toString()}")
            }
        }
    }

    internal init(ty: Type, identifier: String, owner: Function) {
        super(ValueKind.Parameter, ty, identifier)
        this._owner = owner
        this._hashCode = calculateHashCode()
        _attributes.setAttr(Attribute.ReadOnly, true)
    }

    internal init(ty: Type, identifier: String, owner: Lambda) {
        super(ValueKind.Parameter, ty, identifier)
        this._owner = owner.result
        this._hashCode = calculateHashCode()
        _attributes.setAttr(Attribute.ReadOnly, true)
    }

    public func toString(): String {
        return parameterToString(this, 0)
    }

    protected override func calculateHashCode(): Int64 {
        return (topLevelFunc.identifier + "_P" + identifier).hashCode()
    }

    public operator func==(other: Parameter): Bool {
        return refEq(this, other)
    }
}