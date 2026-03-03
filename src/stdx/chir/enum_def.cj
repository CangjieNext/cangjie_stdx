/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

/**
 * @brief Represents information about an enum constructor.
 *
 * An enum constructor is a variant of an enum type with optional parameters.
 */
internal class EnumCtorInfo <: ToString {
    private let _srcCodeIdentifier: String
    private let _identifier: String
    private let _funcType: FuncType
    private var _annotations = ArrayList<Annotation>()
    private let _outerDef: EnumDef

    /**
     * @brief Converts this EnumCtorInfo to its string representation.
     * @return A string representation in the format "ConstructorName(param1, param2, ...)".
     */
    public func toString(): String {
        let result = StringBuilder()
        result.append(_srcCodeIdentifier)
        result.append(typeVecToString("(", _funcType.paramTypes, ")"))
        return result.toString()
    }

    /**
     * @brief Gets the source code identifier of this enum constructor.
     * @return The source code identifier.
     */
    public prop srcCodeIdentifier: String {
        get() {
            return _srcCodeIdentifier
        }
    }

    /**
     * @brief Gets the internal identifier (mangled name) of this enum constructor.
     * @return The internal identifier.
     */
    public prop identifier: String {
        get() {
            return _identifier
        }
    }

    /**
     * @brief Gets the function type of this enum constructor.
     *
     * The function type represents the parameter types and return type (which is the enum type).
     * @return The FuncType instance.
     */
    public prop funcType: FuncType {
        get() {
            return _funcType
        }
    }

    /**
     * @brief Gets or sets the annotations attached to this enum constructor.
     * @return An array of Annotation objects.
     */
    public mut prop annotations: Array<Annotation> {
        get() {
            return _annotations.toArray()
        }
        set(v) {
            _annotations = ArrayList<Annotation>.of(v)
        }
    }
    internal init(srcCodeIdentifier: String, identifier: String, funcType: FuncType, outerDef: EnumDef) {
        this._srcCodeIdentifier = srcCodeIdentifier
        this._identifier = identifier
        this._funcType = funcType
        this._outerDef = outerDef
    }
}

/**
 * @brief Represents an enum definition in the CHIR representation.
 *
 * An EnumDef extends CustomTypeDef and provides methods to access enum-specific
 * information such as whether it is exhaustive and its constructors.
 */
public class EnumDef <: CustomTypeDef & Equatable<EnumDef> {
    private var _nonExhaustive: Bool
    internal var _ctors = ArrayList<EnumCtorInfo>()

    /**
     * @brief Checks if this enum is exhaustive.
     *
     * An exhaustive enum is one where all possible values are known at compile time.
     * @return true if the enum is exhaustive, false otherwise.
     */
    public prop isExhaustive: Bool {
        get() {
            return !_nonExhaustive
        }
    }

    internal prop constructors: Array<EnumCtorInfo> {
        get() {
            return _ctors.toArray()
        }
    }

    /**
     * @brief Gets the EnumType associated with this enum definition.
     * @return The EnumType instance.
     */
    public prop enumType: EnumType {
        get() {
            return (_type.getOrThrow() as EnumType).getOrThrow()
        }
    }
    internal func appendEnumConstructor(mangledName: String, name: String, argTypes!: Array<Type> = Array<Type>(), annotations!: Array<Annotation> = Array<Annotation>()): EnumCtorInfo {
        let funcType = FuncType.get(argTypes, enumType)
        let ctor = EnumCtorInfo(name, mangledName, funcType, this)
        ctor.annotations = annotations
        _ctors.add(ctor)
        return ctor
    }
    
    internal init(identifier: String, srcName: String, pkgName: String, nonExhaustive: Bool, curPackage: Package) {
        super(CustomDefKind.Enum, identifier, srcName, pkgName, curPackage)
        this._nonExhaustive = nonExhaustive
        this._hashCode = calculateHashCode()
    }
    protected override func printMemberVars(indent: UInt64): String {
        let result = StringBuilder()
        for (ctor in _ctors) {
            result.append("\n")
            result.append(indentToString(indent))
            result.append(ctor.toString())
        }
        if (_nonExhaustive) {
            result.append("\n")
            result.append(indentToString(indent))
            result.append("...")
        }
        return result.toString()
    }
    /**
     * @brief Checks if this EnumDef is equal to another EnumDef.
     * @param other The EnumDef to compare with.
     * @return true if the definitions are equal, false otherwise.
     */
    public operator func==(other: EnumDef): Bool {
        return isSameDef(other)
    }
}