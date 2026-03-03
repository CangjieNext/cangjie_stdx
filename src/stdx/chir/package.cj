/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

internal import std.collection.*
import std.deriving.*

/**
 * @brief Represents the access level of a package or declaration.
 *
 * Access levels control the visibility of declarations across package boundaries.
 */
@Derive[Equatable]
public enum AccessLevel <: ToString {
    INTERNAL | PROTECTED | PUBLIC

    /**
     * @brief Converts this AccessLevel to its string representation.
     * @return A string representation of the access level ("internal", "protected", or "public").
     */
    public func toString(): String {
        return match (this) {
            case INTERNAL => "internal"
            case PROTECTED => "protected"
            case PUBLIC => "public"
        }
    }
}

/**
 * @brief Represents a package in the CHIR representation.
 *
 * A package contains classes, structs, enums, and extends, both defined locally
 * and imported from other packages. It also has an access level that controls
 * the visibility of its contents.
 */
public class Package <: ToString {
    private let _name: String
    private let _accessLevel: AccessLevel

    internal var _importedClasses = ArrayList<ClassDef>()
    internal var _importedEnums = ArrayList<EnumDef>()
    internal var _importedStructs = ArrayList<StructDef>()
    internal var _importedExtends = ArrayList<ExtendDef>()

    internal var _classes = ArrayList<ClassDef>()
    internal var _enums = ArrayList<EnumDef>()
    internal var _structs = ArrayList<StructDef>()
    internal var _extends = ArrayList<ExtendDef>()

    // ----------------------- Public API -----------------------

    /**
     * @brief Creates a new Package instance.
     * @param name The name of the package.
     * @param accessLevel The access level of the package.
     */
    public init(name: String, accessLevel: AccessLevel) {
        this._name = name
        this._accessLevel = accessLevel
    }

    /**
     * @brief Prints the string representation of this package to standard output.
     */
    public func dump(): Unit {
        println(toString())
    }

    /**
     * @brief Converts this Package to its string representation.
     *
     * The string includes package name, access level, imported declarations,
     * and locally defined types (classes, structs, enums, and extends).
     * @return A string representation of the package.
     */
    public func toString(): String {
        var out = ""
        out += "package: " + name + "\n"
        out += "packageAccessLevel: " + accessLevel.toString() + "\n"
        out += "\n"

        out += "==========================imports===============================\n\n"
        for (d in importedClasses) {
            out += d.toString() + "\n"
        }
        for (d in importedStructs) {
            out += d.toString() + "\n"
        }
        for (d in importedEnums) {
            out += d.toString() + "\n"
        }
        for (d in importedExtends) {
            out += d.toString() + "\n"
        }
        out += "\n"

        out += "==========================types=================================\n\n"
        for (d in classes) {
            out += d.toString() + "\n\n"
        }
        for (d in structs) {
            out += d.toString() + "\n\n"
        }
        for (d in enums) {
            out += d.toString() + "\n\n"
        }
        for (d in extends) {
            out += d.toString() + "\n\n"
        }
        out += "\n"
        return out
    }

    public prop name: String {
        get() {
            return _name
        }
    }

    internal prop accessLevel: AccessLevel {
        get() {
            return _accessLevel
        }
    }

    public prop importedClasses: Array<ClassDef> {
        get() {
            return _importedClasses.toArray()
        }
    }

    public prop importedEnums: Array<EnumDef> {
        get() {
            return _importedEnums.toArray()
        }
    }

    public prop importedStructs: Array<StructDef> {
        get() {
            return _importedStructs.toArray()
        }
    }

    public prop importedExtends: Array<ExtendDef> {
        get() {
            return _importedExtends.toArray()
        }
    }

    public prop classes: Array<ClassDef> {
        get() {
            return _classes.toArray()
        }
    }

    public prop enums: Array<EnumDef> {
        get() {
            return _enums.toArray()
        }
    }

    public prop structs: Array<StructDef> {
        get() {
            return _structs.toArray()
        }
    }

    public prop extends: Array<ExtendDef> {
        get() {
            return _extends.toArray()
        }
    }

    // ----------------------- create custom type def -----------------------
    internal func addClass(mangledName: String, srcCodeIdentifier: String, isClass: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ClassDef {
        let identifier = GLOBAL_SYMBOL_PREFIX + mangledName
        let temp = ClassDef(identifier, srcCodeIdentifier, _name, isClass, this)
        if (!genericTypeParams.isEmpty()) {
            temp.attributes.setAttr(Attribute.GENERIC, true)
        }
        _classes.add(temp)
        let ty = ClassType.get(temp, Array<Type>(genericTypeParams.size, { i => genericTypeParams[i] }))
        temp._type = ty
        return temp
    }
    internal func addImportedClass(mangledName: String, srcCodeIdentifier: String, packageName: String, isClass: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ClassDef {
        let identifier = GLOBAL_SYMBOL_PREFIX + mangledName
        let temp = ClassDef(identifier, srcCodeIdentifier, packageName, isClass, this)
        temp.attributes.setAttr(Attribute.IMPORTED, true)
        if (!genericTypeParams.isEmpty()) {
            temp.attributes.setAttr(Attribute.GENERIC, true)
        }
        _importedClasses.add(temp)
        let ty = ClassType.get(temp, Array<Type>(genericTypeParams.size, { i => genericTypeParams[i] }))
        temp._type = ty
        return temp
    }
    internal func addStruct(mangledName: String, srcCodeIdentifier: String, genericTypeParams!: Array<GenericType> = Array<GenericType>()): StructDef {
        let identifier = GLOBAL_SYMBOL_PREFIX + mangledName
        let temp = StructDef(identifier, srcCodeIdentifier, _name, this)
        if (!genericTypeParams.isEmpty()) {
            temp.attributes.setAttr(Attribute.GENERIC, true)
        }
        _structs.add(temp)
        let ty = StructType.get(temp, Array<Type>(genericTypeParams.size, { i => genericTypeParams[i] }))
        temp._type = ty
        return temp
    }
    internal func addImportedStruct(mangledName: String, srcCodeIdentifier: String, packageName: String, genericTypeParams!: Array<GenericType> = Array<GenericType>()): StructDef {
        let identifier = GLOBAL_SYMBOL_PREFIX + mangledName
        let temp = StructDef(identifier, srcCodeIdentifier, packageName, this)
        temp.attributes.setAttr(Attribute.IMPORTED, true)
        if (!genericTypeParams.isEmpty()) {
            temp.attributes.setAttr(Attribute.GENERIC, true)
        }
        _importedStructs.add(temp)
        let ty = StructType.get(temp, Array<Type>(genericTypeParams.size, { i => genericTypeParams[i] }))
        temp._type = ty
        return temp
    }
    internal func addEnum(mangledName: String, srcCodeIdentifier: String, isExhaustive: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): EnumDef {
        let identifier = GLOBAL_SYMBOL_PREFIX + mangledName
        let temp = EnumDef(identifier, srcCodeIdentifier, _name, !isExhaustive, this)
        if (!genericTypeParams.isEmpty()) {
            temp.attributes.setAttr(Attribute.GENERIC, true)
        }
        _enums.add(temp)
        let ty = EnumType.get(temp, Array<Type>(genericTypeParams.size, { i => genericTypeParams[i] }))
        temp._type = ty
        return temp
    }
    internal func addImportedEnum(mangledName: String, srcCodeIdentifier: String, packageName: String, isExhaustive: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): EnumDef {
        let identifier = GLOBAL_SYMBOL_PREFIX + mangledName
        let temp = EnumDef(identifier, srcCodeIdentifier, packageName, !isExhaustive, this)
        temp.attributes.setAttr(Attribute.IMPORTED, true)
        if (!genericTypeParams.isEmpty()) {
            temp.attributes.setAttr(Attribute.GENERIC, true)
        }
        _importedEnums.add(temp)
        let ty = EnumType.get(temp, Array<Type>(genericTypeParams.size, { i => genericTypeParams[i] }))
        temp._type = ty
        return temp
    }
    internal func addExtend(mangledName: String, extendedType: Type, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ExtendDef {
        let identifier = GLOBAL_SYMBOL_PREFIX + mangledName
        let temp = ExtendDef(identifier, _name, extendedType, ArrayList<GenericType>.of(genericTypeParams), this)
        if (!genericTypeParams.isEmpty()) {
            temp.attributes.setAttr(Attribute.GENERIC, true)
        }
        _extends.add(temp)
        return temp
    }
    internal func addImportedExtend(mangledName: String, packageName: String, extendedType: Type, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ExtendDef {
        let identifier = GLOBAL_SYMBOL_PREFIX + mangledName
        let temp = ExtendDef(identifier, packageName, extendedType, ArrayList<GenericType>.of(genericTypeParams), this)
        temp.attributes.setAttr(Attribute.IMPORTED, true)
        if (!genericTypeParams.isEmpty()) {
            temp.attributes.setAttr(Attribute.GENERIC, true)
        }
        _importedExtends.add(temp)
        return temp
    }

    internal func getSpecifiedClassDef(packageName: String, srcCodeIdentifier: String): ?ClassDef {
        for (def in _importedClasses) {
            if (def.packageName == packageName && def.srcCodeIdentifier == srcCodeIdentifier) {
                return def
            }
        }
        for (def in _classes) {
            if (def.packageName == packageName && def.srcCodeIdentifier == srcCodeIdentifier) {
                return def
            }
        }
        return None
    }
    internal func getSpecifiedStructDef(packageName: String, srcCodeIdentifier: String): ?StructDef {
        for (def in _importedStructs) {
            if (def.packageName == packageName && def.srcCodeIdentifier == srcCodeIdentifier) {
                return def
            }
        }
        for (def in _structs) {
            if (def.packageName == packageName && def.srcCodeIdentifier == srcCodeIdentifier) {
                return def
            }
        }
        return None
    }
    internal func getSpecifiedEnumDef(packageName: String, srcCodeIdentifier: String): ?EnumDef {
        for (def in _importedEnums) {
            if (def.packageName == packageName && def.srcCodeIdentifier == srcCodeIdentifier) {
                return def
            }
        }
        for (def in _enums) {
            if (def.packageName == packageName && def.srcCodeIdentifier == srcCodeIdentifier) {
                return def
            }
        }
        return None
    }
}
