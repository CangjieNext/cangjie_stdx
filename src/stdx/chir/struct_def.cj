/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

/**
 * @brief Represents a struct definition in the CHIR representation.
 *
 * A StructDef extends CustomTypeDef and provides methods to access struct-specific
 * information such as whether it is a C struct.
 */
public class StructDef <: CustomTypeDef & Equatable<StructDef> {
    internal var _isCStruct: Bool = false

    /**
     * @brief Gets or sets whether this struct is a C struct.
     *
     * C structs are used for interoperability with C code.
     * @return true if this is a C struct, false otherwise.
     */
    public mut prop isCStruct: Bool {
        get() {
            return _isCStruct
        }
        set(v) {
            _isCStruct = v
        }
    }

    /**
     * @brief Gets the StructType associated with this struct definition.
     * @return The StructType instance.
     */
    public prop structType: StructType {
        get() {
            return (_type.getOrThrow() as StructType).getOrThrow()
        }
    }

    /**
     * @brief Checks if this StructDef is equal to another StructDef.
     * @param other The StructDef to compare with.
     * @return true if the definitions are equal, false otherwise.
     */
    public operator func==(other: StructDef): Bool {
        return isSameDef(other)
    }
    protected override func printComment(): String {
        let extraStr = "isCStruct: " + _isCStruct.toString()
        if (let str <- super.printComment() && !str.isEmpty()) {
            return str + ", " + extraStr
        }
        return "// " + extraStr
    }
    internal init(identifier: String, srcName: String, pkgName: String, curPackage: Package) {
        super(CustomDefKind.Struct, identifier, srcName, pkgName, curPackage)
        this._hashCode = calculateHashCode()
    }
}