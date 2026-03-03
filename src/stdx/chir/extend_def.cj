/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

/**
 * @brief Represents an extend definition in the CHIR representation.
 *
 * An ExtendDef extends a type (class, struct, or enum) with additional functionality
 * through interface implementations. It can have generic type parameters.
 */
public class ExtendDef <: CustomTypeDef {
    internal var _extendedType: Type
    internal var _genericTypeParams = ArrayList<GenericType>()

    /**
     * @brief Gets the type that is being extended.
     * @return The Type that this extend definition extends.
     */
    public prop extendedType: Type {
        get() {
            return _extendedType
        }
    }

    /**
     * @brief Gets the generic type parameters of this extend definition.
     * @return An array of GenericType objects representing the type parameters.
     */
    public override prop genericTypeParams: Array<GenericType> {
        get() {
            return _genericTypeParams.toArray()
        }
    }
    
    protected override func printTitle(): String {
        var typeStr = extendedType.toString()
        if (extendedType.isCustomType()) {
            typeStr = GLOBAL_SYMBOL_PREFIX + typeStr
        }
        var result = "extend" + typeVecToString("<", genericTypeParams, ">") + " " + typeStr
        if (!implementedInterfaceTypes.isEmpty()) {
            result += " <: "
            var superTypeStr = ArrayList<String>()
            for (superType in implementedInterfaceTypes) {
                superTypeStr.add(superType.toString())
            }
            result += String.join(superTypeStr.toArray(), delimiter: " & ")
        }
        return result
    }
    protected override func printComment(): String {
        let extraStr = "id: " + identifier
        if (let str <- super.printComment() && !str.isEmpty()) {
            return str + ", " + extraStr
        }
        return "// " + extraStr
    }
    internal init(identifier: String, pkgName: String, extendedType: Type, genericTypeParams: ArrayList<GenericType>, curPackage: Package) {
        super(CustomDefKind.Extend, identifier, "", pkgName, curPackage)
        this._extendedType = extendedType
        this._genericTypeParams = genericTypeParams
        this._hashCode = calculateHashCode()
    }
}