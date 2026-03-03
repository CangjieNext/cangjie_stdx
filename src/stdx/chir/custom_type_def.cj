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
    ClassLike
    | Enum
    | Extend
    | Struct
    public func toString(): String {
        return match (this) {
            case ClassLike => "classLike"
            case Enum =>      "enum"
            case Extend =>    "extend"
            case Struct =>    "struct"
        }
    }
}

/**
 * @brief Represents a member variable in a custom type definition.
 *
 * A MemberVar stores information about instance variables in classes, structs, or enums,
 * including their name, type, attributes, and debug location.
 */
public class MemberVar <: ToString {
    internal let _name: String
    internal var _rawMangledName: String = ""
    internal let _type: Type
    internal var _attributes: AttributeInfo = AttributeInfo()
    internal var _debugLocation: DebugLocation = DebugLocation.invalid()
    internal var _annoInfo: AnnoInfo = AnnoInfo()
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

    public prop location: DebugLocation {
        get() {
            return _debugLocation
        }
    }

    /**
     * @brief Gets or sets the annotation information of this member variable.
     * @return The AnnoInfo instance.
     */
    public mut prop annoInfo: AnnoInfo {
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
    public func setReadOnly(enable: Bool): Unit {
        _attributes.setAttr(Attribute.ReadOnly, enable)
    }

    /**
     * @brief Sets the INTERNAL access level attribute for this member variable.
     */
    public func setInternal(): Unit {
        _attributes.setInternal()
    }

    /**
     * @brief Sets the PUBLIC access level attribute for this member variable.
     */
    public func setPublic(): Unit {
        _attributes.setPublic()
    }

    /**
     * @brief Sets the PRIVATE access level attribute for this member variable.
     */
    public func setPrivate(): Unit {
        _attributes.setPrivate()
    }

    /**
     * @brief Sets the PROTECTED access level attribute for this member variable.
     */
    public func setProtected(): Unit {
        _attributes.setProtected()
    }

    /**
     * @brief Checks if this member variable is read-only.
     * @return true if the READONLY attribute is set, false otherwise.
     */
    public func isReadOnly(): Bool {
        return _attributes.testAttr(Attribute.ReadOnly)
    }

    /**
     * @brief Checks if this member variable has INTERNAL access level.
     * @return true if INTERNAL attribute is set, false otherwise.
     */
    public func isInternal(): Bool {
        return _attributes.testAttr(Attribute.Internal)
    }

    /**
     * @brief Checks if this member variable has PUBLIC access level.
     * @return true if PUBLIC attribute is set, false otherwise.
     */
    public func isPublic(): Bool {
        return _attributes.testAttr(Attribute.Public)
    }

    /**
     * @brief Checks if this member variable has PRIVATE access level.
     * @return true if PRIVATE attribute is set, false otherwise.
     */
    public func isPrivate(): Bool {
        return _attributes.testAttr(Attribute.Private)
    }

    /**
     * @brief Checks if this member variable has PROTECTED access level.
     * @return true if PROTECTED attribute is set, false otherwise.
     */
    public func isProtected(): Bool {
        return _attributes.testAttr(Attribute.Protected)
    }

    /**
     * @brief Converts this MemberVar to its string representation.
     * @return A string representation including attributes, name, type, and debug location.
     */
    public func toString(): String {
        let result = StringBuilder()
        result.append(_attributes.toString())
        result.append(if (isReadOnly()) { "let " } else { "var " })
        result.append(_name)
        result.append(": ")
        result.append(ty.toString())
        var comment = ArrayList<String>()
        if (_debugLocation.isValid()) {
            comment.add("loc: " + _debugLocation.toString())
        }
        if (!comment.isEmpty()) {
            result.append(" // ")
            result.append(String.join(comment.toArray(), delimiter: ", "))
        }
        return result.toString()
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
    internal let _srcCodeName: String
    internal let _packageName: String
    internal var _type : ?CustomType = None
    internal var _genericDecl : ?CustomTypeDef = None
    internal var _hashCode: Int64 = 0
    internal var _instanceVars = ArrayList<MemberVar>()
    internal var _extends = ArrayList<ExtendDef>()
    internal var _implementedInterfaceTypes = ArrayList<ClassLikeType>()

    public func setPublic(): Unit {
        _attributes.setPublic()
    }
    public func setPrivate(): Unit {
        _attributes.setPrivate()
    }
    public func setProtected(): Unit {
        _attributes.setProtected()
    }
    public func setInternal(): Unit {
        _attributes.setInternal()
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
    public func isInternal(): Bool {
        return _attributes.testAttr(Attribute.Internal)
    }
    public func isProtected(): Bool {
        return _attributes.testAttr(Attribute.Protected)
    }
    public func isAbstract(): Bool {
        return _attributes.testAttr(Attribute.Abstract)
    }
    public func isOpen(): Bool {
        return _attributes.testAttr(Attribute.Virtual) || _attributes.testAttr(Attribute.Abstract)
    }
    public func isSealed(): Bool {
        return _attributes.testAttr(Attribute.Sealed)
    }
    public func isGeneric(): Bool {
        return _attributes.testAttr(Attribute.Generic)
    }
    /**
     * @brief Gets the generic type parameters of this custom type definition.
     *
     * If this type is not generic, returns an empty array.
     * @return An array of GenericType objects representing the type parameters.
     */
    public prop genericTypeParams: Array<GenericType> {
        get() {
            if (!isGeneric()) {
                return Array<GenericType>()
            }
            if (_kind == CustomDefKind.Extend) {
                return (this as ExtendDef).getOrThrow()._genericTypeParams.toArray()
            } else {
                let typeArgs = _type.getOrThrow().typeArgs
                return Array<GenericType>(typeArgs.size, { i =>
                    (typeArgs[i] as GenericType).getOrThrow()
                })
            }
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
        let result = StringBuilder()
        result.append(_attributes.toString())
        result.append(printTitle())
        result.append(genericTypeParamsConstraintToString(genericTypeParams))
        result.append(" {")
        result.append(printComment())
        result.append(printMemberVars(INDENT_SPACE))
        for (exDef in _extends) {
            result.append("\n")
            result.append(indentToString(INDENT_SPACE))
            result.append("extend ")
            result.append(exDef.identifier)
        }
        result.append("\n}")
        return result.toString()
    }
    public prop instanceVars: Array<MemberVar> {
        get() {
            return _instanceVars.toArray()
        }
    }
    public mut prop extends: Array<ExtendDef> {
        get() {
            return _extends.toArray()
        }
        set(v) {
            _extends = ArrayList<ExtendDef>.of(v)
        }
    }
    /**
     * @brief Gets or sets the list of interface types implemented by this custom type.
     * @return An array of ClassLikeType objects representing the implemented interfaces.
     */
    public mut prop implementedInterfaceTypes: Array<ClassLikeType> {
        get() {
            return _implementedInterfaceTypes.toArray()
        }
        set(v) {
            _implementedInterfaceTypes = ArrayList<ClassLikeType>.of(v)
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
    public prop srcCodeName: String {
        get() {
            return _srcCodeName
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
     * @return true if the kind is ClassLike, false otherwise.
     */
    public func isClassLike(): Bool {
        return _kind == CustomDefKind.ClassLike
    }

    /**
     * @brief Checks if this definition represents a class (not an interface).
     * @return true if this is a class, false otherwise. Overridden in ClassLikeDef.
     */
    public func isClass(): Bool {
        if (_kind == CustomDefKind.ClassLike) {
            return (this as ClassLikeDef).getOrThrow()._isClass
        }
        return false
    }

    /**
     * @brief Checks if this definition represents an interface (not a class).
     * @return true if this is an interface, false otherwise. Overridden in ClassLikeDef.
     */
    public func isInterface(): Bool {
        if (_kind == CustomDefKind.ClassLike) {
            return !(this as ClassLikeDef).getOrThrow()._isClass
        }
        return false
    }

    /**
     * @brief Checks if this definition represents an enum.
     * @return true if the kind is Enum, false otherwise.
     */
    public func isEnum(): Bool {
        return _kind == CustomDefKind.Enum
    }

    /**
     * @brief Checks if this definition represents an extend.
     * @return true if the kind is Extend, false otherwise.
     */
    public func isExtend(): Bool {
        return _kind == CustomDefKind.Extend
    }

    /**
     * @brief Checks if this definition represents a struct.
     * @return true if the kind is Struct, false otherwise.
     */
    public func isStruct(): Bool {
        return _kind == CustomDefKind.Struct
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
     * @return An array of ClassLikeType objects representing all super types.
     * @throws Exception if the type is neither a CustomType nor a BuiltinType.
     */
    public func getSuperTypesRecusively(): Array<ClassLikeType> {
        if (ty.isCustomType()) {
            return (ty as CustomType).getOrThrow().getSuperTypesRecusively()
        } else if (ty.isBuiltinType()) {
            return (ty as BuiltinType).getOrThrow().getSuperTypesRecusively()
        }
        throw Exception("wrong type: ${ty.toString()} in CustomTypeDef: ${identifier}")
    }

    internal func isSameDef(other: CustomTypeDef): Bool {
        return this.identifier == other.identifier
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
        return this.packageName == packageName && this.srcCodeName == srcCodeName
    }

    internal init(kind: CustomDefKind, identifier: String, srcName: String, pkgName: String) {
        this._kind = kind
        this._identifier = identifier
        this._srcCodeName = srcName
        this._packageName = pkgName
    }
    internal prop identifierWithoutPrefix: String {
        get() {
            return _identifier.removePrefix(GLOBAL_SYMBOL_PREFIX)
        }
    }
    public mut prop genericDecl: ?CustomTypeDef {
        get() {
            return _genericDecl
        }
        set(v) {
            if (let Some(gDef) <- v) {
                assert(gDef._srcCodeName == _srcCodeName,
                    "genericDecl's srcCodeName must be the same as the current def's srcCodeName")
                assert(gDef._kind == _kind, "genericDecl's kind must be the same as the current def's kind")
                assert(gDef.isGeneric(), "genericDecl must be generic")
                assert(!this.isGeneric(), "current def can't be generic")
                // we don't check whether this.ty meet generic constraint of gDef.ty, it will cost much time
                // we will check it in ir checker
            }
            _genericDecl = v
        }
    }
    protected open func printTitle(): String {
        var kindStr = ""
        if (isInterface()) {
            kindStr = "interface"
        } else if (isClass()) {
            kindStr = "class"
        } else {
            kindStr = _kind.toString()
        }
        let result = StringBuilder()
        result.append(kindStr)
        result.append(" ")
        result.append(identifier)
        result.append(typeVecToString("<", genericTypeParams, ">"))
        if (!_implementedInterfaceTypes.isEmpty()) {
            result.append(" <: ")
            var superTypeStr = ArrayList<String>()
            for (superType in _implementedInterfaceTypes) {
                superTypeStr.add(superType.toString())
            }
            result.append(String.join(superTypeStr.toArray(), delimiter: " & "))
        }
        return result.toString()
    }
    protected open func printComment(): String {
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
        if (let Some(gDecl) <- _genericDecl) {
            comment.add("genericDecl: " + gDecl.identifier)
        }
        if (!comment.isEmpty()) {
            return " // " + String.join(comment.toArray(), delimiter: ", ")
        }
        return ""
    }
    protected open func printMemberVars(indent: UInt64): String {
        let result = StringBuilder()
        var index = 0
        while (index < _instanceVars.size) {
            result.append("\n")
            result.append(indentToString(indent))
            result.append(_instanceVars[index].toString())
            index += 1
        }
        return result.toString()
    }

    internal func calculateHashCode(): Int64 {
        return identifier.hashCode()
    }
}