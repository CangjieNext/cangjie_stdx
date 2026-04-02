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
    | PrimalClassConstructor
    | StructConstructor
    | PrimalStructConstructor
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
    internal let _kind: ValueKind
    internal var _type: Type
    internal var _identifier: String
    internal var _hashCode: Int64 = 0
    internal var _users = ArrayList<Expression>()

    internal func isInvalid(): Bool {
        return _kind == ValueKind.Invalid
    }
    public func isLiteralValue(): Bool {
        return _kind == ValueKind.Literal
    }
    public operator func==(other: Value): Bool {
        return refEq(this, other)
    }
    public mut prop ty: Type {
        get() {
            return _type
        }
        set(v) {
            _type = v
        }
    }
    public prop identifier: String {
        get() {
            return _identifier
        }
    }
    public prop users: Array<Expression> {
        get() {
            return _users.toArray()
        }
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
    public func isLocalVar(): Bool {
        return _kind == ValueKind.LocalVar
    }
    public func isParameter(): Bool {
        return _kind == ValueKind.Parameter
    }
    public func isFunction(): Bool {
        return _kind == ValueKind.Func
    }
    public func isLiteral(): Bool {
        return _kind == ValueKind.Literal
    }
    public func isGlobalVar(): Bool {
        return _kind == ValueKind.GlobalVar
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
    protected open func calculateHashCode(): Int64
}

public class Block <: Value & Equatable<Block> {
    internal var _owner: BlockGroup
    internal var _exprs = ArrayList<Expression>()
    internal var _predecessors = ArrayList<Block>()
    internal var _exceptions: ?ArrayList<ClassLikeType> = None

    internal static func invalid(): Block {
        return Block()
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
    public prop owner: BlockGroup {
        get() {
            return _owner
        }
    }
    public prop exprs: Array<Expression> {
        get() {
            return _exprs.toArray()
        }
    }
    public prop predecessors: Array<Block> {
        get() {
            return _predecessors.toArray()
        }
    }
    public mut prop exceptions: Array<ClassLikeType> {
        get() {
            return _exceptions.getOrThrow().toArray()
        }
        set(value) {
            _exceptions = ArrayList<ClassLikeType>.of(value)
        }
    }
    public prop topLevelFunc: Function {
        get() {
            return _owner.topLevelFunc
        }
    }
    public prop isLandingPadBlock: Bool {
        get() {
            return _exceptions.isSome()
        }
    }
    public func appendExpr(expr: Expression): Unit {
        _exprs.add(expr)
        expr._owner = this
        updateLocalVarIdAndHashCode(expr._result)
    }
    public func toString(): String {
        return blockToString(this, 0)
    }
    public func destroySelf(): Unit {
        for (expr in _exprs) {
            expr.destroySelf()
        }
        _predecessors.clear()
        _exceptions = None
        _owner._blocks.removeIf({ bb => bb == this })
    }
    public operator func==(other: Block): Bool {
        return refEq(this, other)
    }

    protected override func calculateHashCode(): Int64 {
        return (_owner.topLevelFunc.identifier + "_BG" + _owner.identifier + "_B" + identifier).hashCode()
    }
    internal init(identifier: String, owner: BlockGroup) {
        super(ValueKind.Block, identifier)
        this._owner = owner
        this._hashCode = calculateHashCode()
        owner._blocks.add(this)
    }
    private init() {
        super(ValueKind.Invalid, String.empty)
        this._owner = BlockGroup.invalid()
        this._hashCode = 0
    }
}

public class BlockGroup <: Value & Equatable<BlockGroup> {
    internal var _entryBlock: Block = Block.invalid()
    internal var _blocks = ArrayList<Block>()
    // owner is lambda(LocalVar) or global function(Function)
    internal var _owner: Value

    internal static func invalid(): BlockGroup {
        return BlockGroup()
    }
    public prop entryBlock: Block {
        get() {
            return _entryBlock
        }
    }
    public prop blocks: Array<Block> {
        get() {
            return _blocks.toArray()
        }
    }
    public func appendBlock(): Block {
        let identifier = BLOCK_PREFIX + topLevelFunc.generateBlockId().toString()
        let bb = Block(identifier, this)
        _blocks.add(bb)
        return bb
    }
    public func setEntryBlock(block: Block): Unit {
        if (!_blocks.contains(block)) {
            throw Exception("Entry block must push into BlockGroup first")
        }
        _entryBlock = block
    }
    public func destroySelf(): Unit {
        for (block in _blocks) {
            block.destroySelf()
        }
        _blocks.clear()
        _entryBlock = Block.invalid()
        if (_owner.isFunction()) {
            let f = (_owner as Function).getOrThrow()
            f._body = None
        } else if (_owner.isLocalVar()) {
            (_owner as LocalVar).getOrThrow()._expr._blockGroups.removeIf({ bg => bg == this })
        }
        _owner = Function.invalid()
    }
    public prop owner: Value {
        get() {
            return _owner
        }
    }
    public prop topLevelFunc: Function {
        get() {
            if (_owner.isFunction()) {
                return (_owner as Function).getOrThrow()
            } else {
                return (_owner as LocalVar).getOrThrow().topLevelFunc
            }
        }
    }
    public func toString(): String {
        return blockGroupToString(this, 0)
    }
    public operator func==(other: BlockGroup): Bool {
        return refEq(this, other)
    }

    protected override func calculateHashCode(): Int64 {
        return (topLevelFunc.identifier + "_BG" + identifier).hashCode()
    }
    internal init(identifier: String, owner: Value) {
        super(ValueKind.BlockGroup, identifier)
        this._owner = owner
        this._hashCode = calculateHashCode()
    }
    private init() {
        super(ValueKind.Invalid, String.empty)
        this._owner = Function.invalid()
        this._hashCode = 0
    }
}

sealed abstract class GlobalValue <: Value & Equatable<GlobalValue> {
    internal var _rawMangledName: String = ""
    internal let _srcCodeIdentifier: String
    internal let _packageName: String
    internal var _declaredParent: ?CustomTypeDef = None
    internal var _annoInfo: AnnoInfo = AnnoInfo()

    public func setPublic(): Unit {
        _attributes.setPublic()
    }
    public func setProtected(): Unit {
        _attributes.setProtected()
    }
    internal func setPrivate(): Unit {
        _attributes.setPrivate()
    }
    public func setInternal(): Unit {
        _attributes.setInternal()
    }
    public func setConst(enable: Bool): Unit {
        _attributes.setAttr(Attribute.Const, enable)
    }
    public func setStatic(enable: Bool): Unit {
        _attributes.setAttr(Attribute.Static, enable)
    }
    public func isImported(): Bool {
        return _attributes.testAttr(Attribute.Imported)
    }
    public func isPublic(): Bool {
        return _attributes.testAttr(Attribute.Public)
    }
    public func isPrivate(): Bool {
        return _attributes.testAttr(Attribute.Private)
    }
    public func isProtected(): Bool {
        return _attributes.testAttr(Attribute.Protected)
    }
    public func isInternal(): Bool {
        return _attributes.testAttr(Attribute.Internal)
    }
    public func isConst(): Bool {
        return _attributes.testAttr(Attribute.Const)
    }
    public func isStatic(): Bool {
        return _attributes.testAttr(Attribute.Static)
    }
    public func isForeign(): Bool {
        return _attributes.testAttr(Attribute.Foreign)
    }
    public func isCompilerAdd(): Bool {
        return _attributes.testAttr(Attribute.CompilerAdd)
    }
    public func isExternalLinkage(): Bool {
        return getAnno<LinkTypeInfo, LinkType>() == LinkType.External
    }
    public prop srcCodeIdentifier: String {
        get() {
            return _srcCodeIdentifier
        }
    }
    public prop packageName: String {
        get() {
            return _packageName
        }
    }
    public prop declaredParent: ?CustomTypeDef {
        get() {
            return _declaredParent
        }
    }
    public operator func==(other: GlobalValue): Bool {
        return refEq(this, other)
    }

    protected override func calculateHashCode(): Int64 {
        return identifier.hashCode()
    }
    internal init(kind: ValueKind, ty: Type, identifier: String, srcName: String, pkgName: String) {
        super(kind, ty, identifier)
        this._srcCodeIdentifier = srcName
        this._packageName = pkgName
    }

    internal func globalSymbolToString(): String {
        var comment = ArrayList<String>()
        if (!_srcCodeIdentifier.isEmpty()) {
            comment.add("srcCodeIdentifier: " + _srcCodeIdentifier)
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
}

public class GlobalVar <: GlobalValue & Equatable<GlobalVar> {
    internal var _initializer: ?Value = None

    internal static func invalid(): GlobalVar {
        return GlobalVar()
    }
    public operator func==(other: GlobalVar): Bool {
        return refEq(this, other)
    }
    public func setInitializer(initializer: Value): Unit {
        _initializer = initializer
    }
    public prop initializer: ?Value {
        get() {
            return _initializer
        }
    }
    public func setReadOnly(enable: Bool): Unit {
        _attributes.setAttr(Attribute.ReadOnly, enable)
    }
    public func isReadOnly(): Bool {
        return _attributes.testAttr(Attribute.ReadOnly)
    }
    public func isSrcCodeImported(): Bool {
        return isImported() && !_initializer.isNone()
    }
    public func toString(): String {
        var result = ""
        result += _attributes.toString()
        if (isReadOnly()) {
            result += "let "
        } else {
            result += "var "
        }
        result += identifier + ": " + ty.toString()
        if (initializer.isSome()) {
            if (initializer.getOrThrow().isLiteral()) {
                result += " = " + initializer.getOrThrow().toString()
            } else {
                // must be init function
                result += " = " + initializer.getOrThrow().identifier + "()"
            }
        }
        // TODO: 需要补充Annotation的to string
        var comment = ArrayList<String>()
        if (let str <- globalSymbolToString() && !str.isEmpty()) {
            comment.add(str)
        }
        if (let str <- chirAnnoToString() && !str.isEmpty()) {
            comment.add(str)
        }
        if (let str <- _debugLocation.toString() && !str.isEmpty()) {
            comment.add(str)
        }

        if (!comment.isEmpty()) {
            result += " // " + String.join(comment.toArray(), delimiter: ", ")
        }
        return result
    }

    internal init(ty: Type, identifier: String, srcName: String, pkgName: String) {
        super(ValueKind.GlobalVar, ty, identifier, srcName, pkgName)
        this._hashCode = calculateHashCode()
    }
    private init() {
        super(ValueKind.Invalid, InvalidType.get(), String.empty, String.empty, String.empty)
        this._hashCode = 0
    }
}

public class Function <: GlobalValue & Equatable<Function> {
    internal var _parameters = ArrayList<Parameter>()
    internal var _genericTypeParams = ArrayList<GenericType>()
    internal var _body: ?BlockGroup = None
    internal var _retValue: ?LocalVar = None
    internal var _localId: UInt64 = 0
    internal var _blockId: UInt64 = 0
    internal var _blockGroupId: UInt64 = 0
    internal var _genericDecl: ?Function = None
    internal var _funcKind: FuncKind = FuncKind.Default
    internal var _isFastNative: Bool = false
    internal var _isCFFIWrapper: Bool = false
    internal var _oriLambdaFuncTy: ?Type = None
    internal var _oriLambdaGenericTypeParams: ?ArrayList<GenericType> = None
    internal var _paramDftValHostFunc: ?Function = None
    internal var _propLocation: DebugLocation = DebugLocation.invalid()

    internal static func invalid(): Function {
        return Function()
    }
    public operator func==(other: Function): Bool {
        return refEq(this, other)
    }
    public func setAbstract(enable: Bool): Unit {
        _attributes.setAttr(Attribute.Abstract, enable)
    }
    public func setOpen(enable: Bool): Unit {
        _attributes.setAttr(Attribute.Virtual, enable)
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
    public func isOpen(): Bool {
        return _attributes.testAttr(Attribute.Virtual) || _attributes.testAttr(Attribute.Abstract)
    }
    public func isGeneric(): Bool {
        return _attributes.testAttr(Attribute.Generic)
    }
    public mut prop annotations: Array<Annotation> {
        get() {
            return _annoInfo._annoClasses.toArray()
        }
        set(v) {
            _annoInfo._annoClasses = ArrayList<Annotation>.of(v)
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
    internal func addBody(): BlockGroup {
        if (_body.isSome()) {
            throw Exception("Function body already set")
        }
        let identifier = generateBlockGroupId().toString()
        _body = BlockGroup(identifier, this)
        return _body.getOrThrow()
    }
    public func initParametersAndBody(): Unit {
        this._parameters.clear()
        for (paramTy in funcType.paramTypes) {
            appendParameter(paramTy)
        }
        let newBody = addBody()
        let bb = newBody.appendBlock()
        newBody.setEntryBlock(bb)
    }
    public prop body: ?BlockGroup {
        get() {
            return _body
        }
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
    public func toString(): String {
        return functionToString(this, 0)
    }
    public func isSrcCodeImported(): Bool {
        return isImported() && _body.isSome()
    }
    public func isDeclaredInCurPackage(): Bool {
        return !isImported()
    }
    public func isInstanceMemberMethod(): Bool {
        return isMemberMethod() && !isStatic()
    }
    public func isStaticMemberMethod(): Bool {
        return isMemberMethod() && isStatic()
    }
    public func isMemberMethod(): Bool {
        return _declaredParent.isSome()
    }
    internal func appendParameter(ty: Type): Parameter {
        let identifier = LOCAL_VAR_PREFIX + generateLocalId().toString()
        let result = Parameter(ty, identifier, this)
        _parameters.add(result)
        return result
    }

    internal init(ty: FuncType, identifier: String, srcName: String, pkgName: String) {
        super(ValueKind.Func, ty, identifier, srcName, pkgName)
        this._hashCode = calculateHashCode()
    }
    private init() {
        super(ValueKind.Invalid, InvalidType.get(), String.empty, String.empty, String.empty)
        this._hashCode = 0
    }

    internal func generateLocalId(): UInt64 {
        let tmp = _localId
        _localId++
        return tmp
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
}

sealed abstract class LiteralValue <: Value & Equatable<LiteralValue> {
    internal let literalKind: LiteralKind

    public operator func==(other: LiteralValue): Bool {
        return refEq(this, other)
    }
    internal init(ty: Type, literalKind: LiteralKind) {
        super(ValueKind.Literal, ty, String.empty)
        this.literalKind = literalKind
    }
}

public class BoolLiteral <: LiteralValue & Equatable<BoolLiteral> {
    internal let _value: Bool

    public prop value: Bool {
        get() {
            return _value
        }
    }
    public func toString(): String {
        return value.toString()
    }
    public operator func==(other: BoolLiteral): Bool {
        return refEq(this, other)
    }

    protected override func calculateHashCode(): Int64 {
        return ("BoolLiteral_" + _value.toString()).hashCode()
    }
    public init(ty: BoolType, value: Bool) {
        super(ty, LiteralKind.BoolLit)
        this._value = value
        this._hashCode = calculateHashCode()
    }
}

public class RuneLiteral <: LiteralValue & Equatable<RuneLiteral> {
    internal let _value: Rune

    public prop value: Rune {
        get() {
            return _value
        }
    }
    public operator func==(other: RuneLiteral): Bool {
        return refEq(this, other)
    }
    public func toString(): String {
        return "\'" + value.toString() + "\'"
    }

    public init(ty: RuneType, value: Rune) {
        super(ty, LiteralKind.RuneLit)
        this._value = value
        this._hashCode = calculateHashCode()
    }
    protected override func calculateHashCode(): Int64 {
        return ("RuneLiteral_" + _value.toString()).hashCode()
    }
}

public class IntLiteral <: LiteralValue & Equatable<IntLiteral> {
    internal let _value: UInt64

    public prop unsignedValue: UInt64 {
        get() {
            return _value
        }
    }
    public prop signedValue: Int64 {
        get() {
            return Int64(_value)
        }
    }
    public func isSigned(): Bool {
        return (ty as IntType).getOrThrow().isSigned()
    }
    public func toString(): String {
        let suffix = if (isSigned()) { "i" } else { "u" }
        return unsignedValue.toString() + suffix
    }
    public operator func==(other: IntLiteral): Bool {
        return refEq(this, other)
    }

    public init(ty: IntType, value: UInt64) {
        super(ty, LiteralKind.IntLit)
        this._value = value
        this._hashCode = calculateHashCode()
    }
    protected override func calculateHashCode(): Int64 {
        return (ty.toString() + "_" + _value.toString()).hashCode()
    }
}

public class FloatLiteral <: LiteralValue & Equatable<FloatLiteral> {
    internal let _value: Float64

    public prop value: Float64 {
        get() {
            return _value
        }
    }
    public func toString(): String {
        return value.toString() + "f"
    }
    public operator func==(other: FloatLiteral): Bool {
        return refEq(this, other)
    }

    public init(ty: Type, value: Float64) {
        super(ty, LiteralKind.FloatLit)
        this._value = value
        this._hashCode = calculateHashCode()
    }
    protected override func calculateHashCode(): Int64 {
        return (ty.toString() + "_" + _value.toString()).hashCode()
    }
}

public class StringLiteral <: LiteralValue & Equatable<StringLiteral> {
    internal let _value: String

    public prop value: String {
        get() {
            return _value
        }
    }
    public func toString(): String {
        return "\"" + value + "\""
    }
    public operator func==(other: StringLiteral): Bool {
        return refEq(this, other)
    }

    public init(ty: Type, value: String) {
        super(ty, LiteralKind.StringLit)
        this._value = value
        this._hashCode = calculateHashCode()
    }
    protected override func calculateHashCode(): Int64 {
        return (ty.toString() + "_" + _value.toString()).hashCode()
    }
}

public class UnitLiteral <: LiteralValue & Equatable<UnitLiteral> {
    public func toString(): String {
        return "Unit"
    }
    public operator func==(other: UnitLiteral): Bool {
        return refEq(this, other)
    }

    public init(ty: UnitType) {
        super(ty, LiteralKind.UnitLit)
        this._hashCode = calculateHashCode()
    }
    protected override func calculateHashCode(): Int64 {
        return ty.toString().hashCode()
    }
}

public class NullLiteral <: LiteralValue & Equatable<NullLiteral> {
    public func toString(): String {
        return "Null"
    }
    public operator func==(other: NullLiteral): Bool {
        return refEq(this, other)
    }

    public init(ty: Type) {
        super(ty, LiteralKind.NullLit)
        this._hashCode = calculateHashCode()
    }
    protected override func calculateHashCode(): Int64 {
        return ty.toString().hashCode()
    }
}

public class LocalVar <: Value & Equatable<LocalVar> {
    internal var _expr: Expression = Expression.invalid()
    internal var _isRetValue = false
    
    internal static func invalid(): LocalVar {
        return LocalVar()
    }
    public prop expr: Expression {
        get() {
            return _expr
        }
    }
    public prop topLevelFunc: Function {
        get() {
            return _expr.topLevelFunc
        }
    }
    public func toString(): String {
        return _expr.toString()
    }
    public operator func==(other: LocalVar): Bool {
        return refEq(this, other)
    }

    protected override func calculateHashCode(): Int64 {
        return (topLevelFunc.identifier + "_LV" + identifier).hashCode()
    }
    internal init(ty: Type) {
        super(ValueKind.LocalVar, ty, String.empty)
        this._hashCode = 0
    }
    private init() {
        super(ValueKind.Invalid, InvalidType.get(), String.empty)
        this._hashCode = 0
    }
}

public class Parameter <: Value & Equatable<Parameter> {
    internal var _owner: Value
    internal static func invalid(): Parameter {
        return Parameter()
    }
    public prop topLevelFunc: Function {
        get() {
            if (_owner.isFunction()) {
                return (_owner as Function).getOrThrow()
            } else {
                return (_owner as LocalVar).getOrThrow().topLevelFunc
            }
        }
    }
    public func toString(): String {
        return identifier + ": " + ty.toString()
    }
    public operator func==(other: Parameter): Bool {
        return refEq(this, other)
    }

    protected override func calculateHashCode(): Int64 {
        return (topLevelFunc.identifier + "_P" + identifier).hashCode()
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
    private init() {
        super(ValueKind.Invalid, InvalidType.get(), String.empty)
        this._owner = Function.invalid()
        this._hashCode = 0
    }
}