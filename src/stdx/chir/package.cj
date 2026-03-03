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
    Internal
    | Protected
    | Public

    /**
     * @brief Converts this AccessLevel to its string representation.
     * @return A string representation of the access level ("internal", "protected", or "public").
     */
    public func toString(): String {
        return match (this) {
            case Internal => "internal"
            case Protected => "protected"
            case Public => "public"
        }
    }
}

/**
 * @brief Represents a package in the CHIR representation.
 *
 * A package contains classDefs, structDefs, enumDefs, and extendDefs, both defined locally
 * and imported from other packages. It also has an access level that controls
 * the visibility of its contents.
 */
public class Package <: ToString {
    private let _name: String
    private let _accessLevel: AccessLevel

    internal var _importedClassDefs = ArrayList<ClassLikeDef>()
    internal var _importedEnumDefs = ArrayList<EnumDef>()
    internal var _importedStructDefs = ArrayList<StructDef>()
    internal var _importedExtendDefs = ArrayList<ExtendDef>()

    internal var _classDefs = ArrayList<ClassLikeDef>()
    internal var _enumDefs = ArrayList<EnumDef>()
    internal var _structDefs = ArrayList<StructDef>()
    internal var _extendDefs = ArrayList<ExtendDef>()

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
     * and locally defined types (classDefs, structDefs, enumDefs, and extendDefs).
     * @return A string representation of the package.
     */
    public func toString(): String {
        let result = StringBuilder()
        result.append("package: ")
        result.append(name)
        result.append("\n")
        result.append("packageAccessLevel: ")
        result.append(accessLevel.toString())
        result.append("\n")
        result.append("\n")

        result.append("==========================imports===============================\n\n")
        for (d in importedClassDefs) {
            result.append(d.toString())
            result.append("\n")
        }
        for (d in importedStructDefs) {
            result.append(d.toString())
            result.append("\n")
        }
        for (d in importedEnumDefs) {
            result.append(d.toString())
            result.append("\n")
        }
        for (d in importedExtendDefs) {
            result.append(d.toString())
            result.append("\n")
        }
        result.append("\n")

        result.append("==========================types=================================\n\n")
        for (d in classDefs) {
            result.append(d.toString())
            result.append("\n\n")
        }
        for (d in structDefs) {
            result.append(d.toString())
            result.append("\n\n")
        }
        for (d in enumDefs) {
            result.append(d.toString())
            result.append("\n\n")
        }
        for (d in extendDefs) {
            result.append(d.toString())
            result.append("\n\n")
        }
        result.append("\n")
        return result.toString()
    }

    public prop name: String {
        get() {
            return _name
        }
    }

    public prop accessLevel: AccessLevel {
        get() {
            return _accessLevel
        }
    }

    public prop importedClassDefs: Array<ClassLikeDef> {
        get() {
            return _importedClassDefs.toArray()
        }
    }

    public prop importedEnumDefs: Array<EnumDef> {
        get() {
            return _importedEnumDefs.toArray()
        }
    }

    public prop importedStructDefs: Array<StructDef> {
        get() {
            return _importedStructDefs.toArray()
        }
    }

    public prop importedExtendDefs: Array<ExtendDef> {
        get() {
            return _importedExtendDefs.toArray()
        }
    }

    public prop classDefs: Array<ClassLikeDef> {
        get() {
            return _classDefs.toArray()
        }
    }

    public prop enumDefs: Array<EnumDef> {
        get() {
            return _enumDefs.toArray()
        }
    }

    public prop structDefs: Array<StructDef> {
        get() {
            return _structDefs.toArray()
        }
    }

    public prop extendDefs: Array<ExtendDef> {
        get() {
            return _extendDefs.toArray()
        }
    }

    // ----------------------- create custom type def -----------------------
    public func addClass(mangledName: String, srcCodeName: String, isClass: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ClassLikeDef {
        let temp = createClassDef(mangledName, srcCodeName, isClass, genericTypeParams)
        _classDefs.add(temp)
        return temp
    }
    public func addImportedClass(mangledName: String, srcCodeName: String, packageName: String, isClass: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ClassLikeDef {
        let temp = createClassDef(mangledName, srcCodeName, isClass, genericTypeParams)
        temp._attributes.setAttr(Attribute.Imported, true)
        _importedClassDefs.add(temp)
        return temp
    }
    public func addStruct(mangledName: String, srcCodeName: String, genericTypeParams!: Array<GenericType> = Array<GenericType>()): StructDef {
        let temp = createStructDef(mangledName, srcCodeName, genericTypeParams)
        _structDefs.add(temp)
        return temp
    }
    public func addImportedStruct(mangledName: String, srcCodeName: String, packageName: String, genericTypeParams!: Array<GenericType> = Array<GenericType>()): StructDef {
        let temp = createStructDef(mangledName, srcCodeName, genericTypeParams)
        temp._attributes.setAttr(Attribute.Imported, true)
        _importedStructDefs.add(temp)
        return temp
    }
    public func addEnum(mangledName: String, srcCodeName: String, isExhaustive: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): EnumDef {
        let temp = createEnumDef(mangledName, srcCodeName, isExhaustive, genericTypeParams)
        _enumDefs.add(temp)
        return temp
    }
    public func addImportedEnum(mangledName: String, srcCodeName: String, packageName: String, isExhaustive: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): EnumDef {
        let temp = createEnumDef(mangledName, srcCodeName, isExhaustive, genericTypeParams)
        temp._attributes.setAttr(Attribute.Imported, true)
        _importedEnumDefs.add(temp)
        return temp
    }
    public func addExtend(mangledName: String, extendedType: Type, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ExtendDef {
        let temp = createExtendDef(mangledName, extendedType, genericTypeParams)
        _extendDefs.add(temp)
        return temp
    }
    public func addImportedExtend(mangledName: String, packageName: String, extendedType: Type, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ExtendDef {
        let temp = createExtendDef(mangledName, extendedType, genericTypeParams)
        temp._attributes.setAttr(Attribute.Imported, true)
        _importedExtendDefs.add(temp)
        return temp
    }

    public func getSpecifiedClassDef(packageName: String, srcCodeName: String): ?ClassLikeDef {
        for (def in _importedClassDefs) {
            if (def.packageName == packageName && def.srcCodeName == srcCodeName) {
                return def
            }
        }
        for (def in _classDefs) {
            if (def.packageName == packageName && def.srcCodeName == srcCodeName) {
                return def
            }
        }
        return None
    }
    public func getSpecifiedStructDef(packageName: String, srcCodeName: String): ?StructDef {
        for (def in _importedStructDefs) {
            if (def.packageName == packageName && def.srcCodeName == srcCodeName) {
                return def
            }
        }
        for (def in _structDefs) {
            if (def.packageName == packageName && def.srcCodeName == srcCodeName) {
                return def
            }
        }
        return None
    }
    public func getSpecifiedEnumDef(packageName: String, srcCodeName: String): ?EnumDef {
        for (def in _importedEnumDefs) {
            if (def.packageName == packageName && def.srcCodeName == srcCodeName) {
                return def
            }
        }
        for (def in _enumDefs) {
            if (def.packageName == packageName && def.srcCodeName == srcCodeName) {
                return def
            }
        }
        return None
    }

    private func createClassDef(mangledName: String, srcCodeName: String, isClass: Bool, genericTypeParams: Array<GenericType>): ClassLikeDef {
        let identifier = GLOBAL_SYMBOL_PREFIX + mangledName
        let temp = ClassLikeDef(identifier, srcCodeName, _name, isClass)
        if (!genericTypeParams.isEmpty()) {
            temp._attributes.setAttr(Attribute.Generic, true)
        }
        let ty = ClassLikeType.get(temp, Array<Type>(genericTypeParams.size, { i => genericTypeParams[i] }))
        temp._type = ty
        temp._attributes.setAttr(Attribute.PluginAdded, true)
        return temp
    }

    private func createStructDef(mangledName: String, srcCodeName: String, genericTypeParams: Array<GenericType>): StructDef {
        let identifier = GLOBAL_SYMBOL_PREFIX + mangledName
        let temp = StructDef(identifier, srcCodeName, _name)
        if (!genericTypeParams.isEmpty()) {
            temp._attributes.setAttr(Attribute.Generic, true)
        }
        let ty = StructType.get(temp, Array<Type>(genericTypeParams.size, { i => genericTypeParams[i] }))
        temp._type = ty
        temp._attributes.setAttr(Attribute.PluginAdded, true)
        return temp
    }

    private func createEnumDef(mangledName: String, srcCodeName: String, isExhaustive: Bool, genericTypeParams: Array<GenericType>): EnumDef {
        let identifier = GLOBAL_SYMBOL_PREFIX + mangledName
        let temp = EnumDef(identifier, srcCodeName, _name, !isExhaustive)
        if (!genericTypeParams.isEmpty()) {
            temp._attributes.setAttr(Attribute.Generic, true)
        }
        let ty = EnumType.get(temp, Array<Type>(genericTypeParams.size, { i => genericTypeParams[i] }))
        temp._type = ty
        temp._attributes.setAttr(Attribute.PluginAdded, true)
        return temp
    }

    private func createExtendDef(mangledName: String, extendedType: Type, genericTypeParams: Array<GenericType>): ExtendDef {
        let identifier = GLOBAL_SYMBOL_PREFIX + mangledName
        let temp = ExtendDef(identifier, _name, extendedType, ArrayList<GenericType>.of(genericTypeParams))
        if (!genericTypeParams.isEmpty()) {
            temp._attributes.setAttr(Attribute.Generic, true)
        }
        temp._attributes.setAttr(Attribute.PluginAdded, true)
        return temp
    }
}
