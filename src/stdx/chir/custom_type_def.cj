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
internal enum CustomDefKind <: ToString {
    CLASS | ENUM | EXTEND | STRUCT
    public func toString(): String {
        return match (this) {
            case CLASS => "class"
            case ENUM => "enum"
            case EXTEND => "extend"
            case STRUCT => "struct"
        }
    }
}

/**
 * @brief Represents a member variable in a custom type definition.
 *
 * A MemberVar stores information about instance variables in classes, structs, or enums,
 * including their name, type, attributes, and debug location.
 */
internal class MemberVar <: ToString {
    internal let _name: String
    internal var _rawMangledName: String = ""
    internal let _type: Type
    internal var _attributes: AttributeInfo = AttributeInfo()
    internal var _debugLocation: DebugLocation = DebugLocation.invalid()
    internal var _annoInfo: Annotation = Annotation()
    internal let _outerDef: CustomTypeDef

    /**
     * @brief Gets the name of this member variable.
     * @return The member variable name.
     */
    public prop name: String {
        get() {
            return _name
        }
    }
    /**
     * @brief Gets the type of this member variable.
     * @return The Type of the member variable.
     */
    public prop ty: Type {
        get() {
            return _type
        }
    }

    /**
     * @brief Gets or sets the debug location of this member variable.
     * @return The DebugLocation instance.
     */
    public mut prop location: DebugLocation {
        get() {
            return _debugLocation
        }
        set(v) {
            _debugLocation = v
        }
    }

    /**
     * @brief Gets or sets the annotation information of this member variable.
     * @return The Annotation instance.
     */
    public mut prop annoInfo: Annotation {
        get() {
            return _annoInfo
        }
        set(v) {
            _annoInfo = v
        }
    }

    /**
     * @brief Gets the outer definition that contains this member variable.
     * @return The CustomTypeDef that contains this member variable.
     */
    public prop outerDef: CustomTypeDef {
        get() {
            return _outerDef
        }
    }

    /**
     * @brief Sets the READONLY attribute for this member variable.
     * @param enable true to enable READONLY, false to disable.
     */
    public func setAttrReadOnly(enable: Bool): Unit {
        _attributes.setAttr(Attribute.READONLY, enable)
    }

    /**
     * @brief Enables the INTERNAL access level attribute for this member variable.
     */
    public func enableAttrInternal(): Unit {
        _attributes.enableAttrInternal()
    }

    /**
     * @brief Enables the PUBLIC access level attribute for this member variable.
     */
    public func enableAttrPublic(): Unit {
        _attributes.enableAttrPublic()
    }

    /**
     * @brief Enables the PRIVATE access level attribute for this member variable.
     */
    public func enableAttrPrivate(): Unit {
        _attributes.enableAttrPrivate()
    }

    /**
     * @brief Enables the PROTECTED access level attribute for this member variable.
     */
    public func enableAttrProtected(): Unit {
        _attributes.enableAttrProtected()
    }

    /**
     * @brief Checks if this member variable is read-only.
     * @return true if the READONLY attribute is set, false otherwise.
     */
    public func isReadOnly(): Bool {
        return _attributes.testAttr(Attribute.READONLY)
    }

    /**
     * @brief Checks if this member variable has INTERNAL access level.
     * @return true if INTERNAL attribute is set, false otherwise.
     */
    public func isInternal(): Bool {
        return _attributes.testAttr(Attribute.INTERNAL)
    }

    /**
     * @brief Checks if this member variable has PUBLIC access level.
     * @return true if PUBLIC attribute is set, false otherwise.
     */
    public func isPublic(): Bool {
        return _attributes.testAttr(Attribute.PUBLIC)
    }

    /**
     * @brief Checks if this member variable has PRIVATE access level.
     * @return true if PRIVATE attribute is set, false otherwise.
     */
    public func isPrivate(): Bool {
        return _attributes.testAttr(Attribute.PRIVATE)
    }

    /**
     * @brief Checks if this member variable has PROTECTED access level.
     * @return true if PROTECTED attribute is set, false otherwise.
     */
    public func isProtected(): Bool {
        return _attributes.testAttr(Attribute.PROTECTED)
    }

    /**
     * @brief Converts this MemberVar to its string representation.
     * @return A string representation including attributes, name, type, and debug location.
     */
    public func toString(): String {
        var result = ""
        result += _attributes.toString()
        result += if (isReadOnly()) { "let " } else { "var " }
        result += _name + ": " + ty.toString()
        var comment = ArrayList<String>()
        if (_debugLocation.isValid()) {
            comment.add("loc: " + _debugLocation.toString())
        }
        if (!comment.isEmpty()) {
            result += " // " + String.join(comment.toArray(), delimiter: ", ")
        }
        return result
    }
    public func dump(): Unit {
        println(toString())
    }

    internal init(name: String, ty: Type, outerDef: CustomTypeDef) {
        this._name = name
        this._type = ty
        this._outerDef = outerDef
    }
}

/**
 * @brief Abstract base class for custom type definitions (class, enum, struct, extend).
 *
 * CustomTypeDef provides common functionality for all user-defined types, including
 * generic type parameters, instance variables, implemented interfaces, and extends.
 */
sealed abstract class CustomTypeDef <: Base & Equatable<CustomTypeDef> & Hashable {
    internal let _kind: CustomDefKind
    internal let _identifier: String
    internal let _srcCodeIdentifier: String
    internal let _packageName: String
    internal var _type : ?CustomType = None
    internal var _genericDecl : ?CustomTypeDef = None
    internal var _hashCode: Int64 = 0
    internal var _instanceVars = ArrayList<MemberVar>()
    internal var _extends = ArrayList<ExtendDef>()
    internal var _implementedInterfaceTypes = ArrayList<ClassType>()
    internal let _curPackage: Package

    internal func enableAttrPublic(): Unit {
        attributes.enableAttrPublic()
    }
    internal func enableAttrPrivate(): Unit {
        attributes.enableAttrPrivate()
    }
    internal func enableAttrProtected(): Unit {
        attributes.enableAttrProtected()
    }
    internal func enableAttrInternal(): Unit {
        attributes.enableAttrInternal()
    }
    internal func isImported(): Bool {
        return attributes.testAttr(Attribute.IMPORTED)
    }
    internal func isPublic(): Bool {
        return attributes.testAttr(Attribute.PUBLIC)
    }
    internal func isPrivate(): Bool {
        return attributes.testAttr(Attribute.PRIVATE)
    }
    internal func isInternal(): Bool {
        return attributes.testAttr(Attribute.INTERNAL)
    }
    internal func isProtected(): Bool {
        return attributes.testAttr(Attribute.PROTECTED)
    }
    internal func isAbstract(): Bool {
        return attributes.testAttr(Attribute.ABSTRACT)
    }
    internal func isOpen(): Bool {
        return attributes.testAttr(Attribute.VIRTUAL) || attributes.testAttr(Attribute.ABSTRACT)
    }
    internal func isSealed(): Bool {
        return attributes.testAttr(Attribute.SEALED)
    }
    internal func isGeneric(): Bool {
        return attributes.testAttr(Attribute.GENERIC)
    }
    /**
     * @brief Gets the generic type parameters of this custom type definition.
     *
     * If this type is not generic, returns an empty array.
     * @return An array of GenericType objects representing the type parameters.
     */
    public open prop genericTypeParams: Array<GenericType> {
        get() {
            if (!isGeneric()) {
                return Array<GenericType>()
            }
            let typeArgs = _type.getOrThrow().typeArgs
            return Array<GenericType>(typeArgs.size, { i =>
                (typeArgs[i] as GenericType).getOrThrow()
            })
        }
    }

    /**
     * @brief Converts this CustomTypeDef to its string representation.
     *
     * The string includes attributes, title, generic constraints, member variables,
     * and extends.
     * @return A string representation of the custom type definition.
     */
    public open func toString(): String {
        /*  [public][generic][...] class XXX {      // loc: xxx, genericDecl: xxx
            ^^^^^^^^^^^^^^ attr    ^^^^^^^^^ title  ^^^^^^^^^^^^^^^^^^ comment
                local var
                static var
                method
            }
       */
        var result = ""
        result += attributes.toString()
        result += printTitle()
        result += genericTypeParamsConstraintToString(genericTypeParams)
        result += " {" + printComment()
        result += printMemberVars(INDENT_SPACE)
        for (exDef in _extends) {
            result += "\n" + indentToString(INDENT_SPACE)
            result += "extend " + exDef.identifier
        }
        result += "\n}"
        return result
    }
    internal prop instanceVars: Array<MemberVar> {
        get() {
            return _instanceVars.toArray()
        }
    }
    internal mut prop extends: Array<ExtendDef> {
        get() {
            return _extends.toArray()
        }
        set(v) {
            _extends = ArrayList<ExtendDef>.of(v)
        }
    }
    /**
     * @brief Gets or sets the list of interface types implemented by this custom type.
     * @return An array of ClassType objects representing the implemented interfaces.
     */
    public mut prop implementedInterfaceTypes: Array<ClassType> {
        get() {
            return _implementedInterfaceTypes.toArray()
        }
        set(v) {
            _implementedInterfaceTypes = ArrayList<ClassType>.of(v)
        }
    }

    /**
     * @brief Gets the Type associated with this custom type definition.
     *
     * For ExtendDef, returns the extended type. For other types, returns the type itself.
     * @return The Type instance.
     */
    public prop ty: Type {
        get() {
            if (this.isExtend()) {
                return (this as ExtendDef).getOrThrow().extendedType
            }
            return _type.getOrThrow()
        }
    }

    /**
     * @brief Gets the hash code of this custom type definition.
     * @return The hash code as an Int64.
     */
    public func hashCode(): Int64 {
        return _hashCode
    }

    /**
     * @brief Gets the internal identifier (mangled name) of this custom type definition.
     * @return The identifier string.
     */
    public prop identifier: String {
        get() {
            return _identifier
        }
    }

    /**
     * @brief Gets the source code identifier of this custom type definition.
     * @return The source code identifier string.
     */
    public prop srcCodeIdentifier: String {
        get() {
            return _srcCodeIdentifier
        }
    }

    /**
     * @brief Gets the package name where this custom type is defined.
     * @return The package name string.
     */
    public prop packageName: String {
        get() {
            return _packageName
        }
    }

    /**
     * @brief Checks if this definition is class-like (class or interface).
     * @return true if the kind is CLASS, false otherwise.
     */
    public func isClassLike(): Bool {
        return kind == CustomDefKind.CLASS
    }

    /**
     * @brief Checks if this definition represents a class (not an interface).
     * @return true if this is a class, false otherwise. Overridden in ClassDef.
     */
    public open func isClass(): Bool {
        return false
    }

    /**
     * @brief Checks if this definition represents an interface (not a class).
     * @return true if this is an interface, false otherwise. Overridden in ClassDef.
     */
    public open func isInterface(): Bool {
        return false
    }

    /**
     * @brief Checks if this definition represents an enum.
     * @return true if the kind is ENUM, false otherwise.
     */
    public func isEnum(): Bool {
        return kind == CustomDefKind.ENUM
    }

    /**
     * @brief Checks if this definition represents an extend.
     * @return true if the kind is EXTEND, false otherwise.
     */
    public func isExtend(): Bool {
        return kind == CustomDefKind.EXTEND
    }

    /**
     * @brief Checks if this definition represents a struct.
     * @return true if the kind is STRUCT, false otherwise.
     */
    public func isStruct(): Bool {
        return kind == CustomDefKind.STRUCT
    }

    /**
     * @brief Prints the string representation of this custom type definition to standard output.
     */
    public func dump(): Unit {
        println(toString())
    }
    internal func appendInstanceMemberVar(name: String, ty: Type): MemberVar {
        let v = MemberVar(name, ty, this)
        _instanceVars.add(v)
        return v
    }
    /**
     * @brief Gets all super types (parent classes and interfaces) recursively.
     *
     * This method traverses the inheritance hierarchy to collect all parent types.
     * @return An array of ClassType objects representing all super types.
     * @throws Exception if the type is neither a CustomType nor a BuiltinType.
     */
    public func getSuperTypesRecusively(): Array<ClassType> {
        if (ty.isCustomType()) {
            return (ty as CustomType).getOrThrow().getSuperTypesRecusively()
        } else if (ty.isBuiltinType()) {
            return (ty as BuiltinType).getOrThrow().getSuperTypesRecusively()
        }
        throw Exception("wrong type: ${ty.toString()} in CustomTypeDef: ${identifier}")
    }

    internal func isSameDef(other: CustomTypeDef): Bool {
        return this.kind == other.kind &&
            this.identifier == other.identifier &&
            this.srcCodeIdentifier == other.srcCodeIdentifier &&
            this.packageName == other.packageName
    }

    /**
     * @brief Checks if this CustomTypeDef is equal to another CustomTypeDef.
     * @param other The CustomTypeDef to compare with.
     * @return true if the definitions are equal (same kind, identifier, source code identifier, and package name), false otherwise.
     */
    public operator func==(other: CustomTypeDef): Bool {
        return isSameDef(other)
    }
    internal func defIsExpected(packageName: String, srcCodeName: String): Bool {
        return this.packageName == packageName && this.srcCodeIdentifier == srcCodeName
    }

    internal init(kind: CustomDefKind, identifier: String, srcName: String, pkgName: String, curPackage: Package) {
        this._kind = kind
        this._identifier = identifier
        this._srcCodeIdentifier = srcName
        this._packageName = pkgName
        this._curPackage = curPackage
    }
    internal prop identifierWithoutPrefix: String {
        get() {
            return _identifier.removePrefix(GLOBAL_SYMBOL_PREFIX)
        }
    }
    internal prop kind: CustomDefKind {
        get() {
            return _kind
        }
    }
    internal mut prop genericDecl: ?CustomTypeDef {
        get() {
            return _genericDecl
        }
        set(v) {
            _genericDecl = v
        }
    }
    protected open func printTitle(): String {
        var kindStr = _kind.toString()
        if (isInterface()) {
            kindStr = "interface"
        }
        var result = kindStr + " " + identifier + typeVecToString("<", genericTypeParams, ">")
        if (!_implementedInterfaceTypes.isEmpty()) {
            result += " <: "
            var superTypeStr = ArrayList<String>()
            for (superType in _implementedInterfaceTypes) {
                superTypeStr.add(superType.toString())
            }
            result += String.join(superTypeStr.toArray(), delimiter: " & ")
        }
        return result
    }
    protected open func printComment(): String {
        var comment = ArrayList<String>()
        if (let str <- baseCommentToString() && !str.isEmpty()) {
            comment.add(str)
        }
        if (!_srcCodeIdentifier.isEmpty()) {
            comment.add("srcCodeIdentifier: " + _srcCodeIdentifier)
        }
        if (!_packageName.isEmpty()) {
            comment.add("packageName: " + _packageName)
        }
        if (_genericDecl.isSome()) {
            comment.add("genericDecl: " + _genericDecl.getOrThrow().identifier)
        }
        if (!comment.isEmpty()) {
            return " // " + String.join(comment.toArray(), delimiter: ", ")
        }
        return ""
    }
    protected open func printMemberVars(indent: UInt64): String {
        var result = ""
        for (memberVar in _instanceVars) {
            result += "\n" + indentToString(indent) + memberVar.toString()
        }
        return result
    }

    internal func calculateHashCode(): Int64 {
        return identifier.hashCode()
    }
}