/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

/**
 * @brief Represents a class definition in the CHIR representation.
 *
 * A ClassDef can represent either a class or an interface. It extends CustomTypeDef
 * and provides methods to access class-specific information such as the super class.
 */
public class ClassDef <: CustomTypeDef & Equatable<ClassDef> {
    internal var _isClass: Bool
    internal var _isAnnotation: Bool = false
    internal var _superClass: ?ClassType = None
    internal mut prop isAnnotation: Bool {
        get() {
            return _isAnnotation
        }
        set(v) {
            _isAnnotation = v
        }
    }

    /**
     * @brief Gets the ClassType associated with this class definition.
     * @return The ClassType instance.
     */
    public prop classType: ClassType {
        get() {
            return (_type.getOrThrow() as ClassType).getOrThrow()
        }
    }

    /**
     * @brief Gets or sets the super class type of this class.
     *
     * If this class has no super class, the value is None.
     * @return An optional ClassType representing the super class.
     */
    public mut prop superClass: ?ClassType {
        get() {
            return _superClass
        }
        set(v) {
            _superClass = v
        }
    }

    /**
     * @brief Checks if this definition represents a class (not an interface).
     * @return true if this is a class, false if it is an interface.
     */
    public override func isClass(): Bool {
        return _isClass
    }

    /**
     * @brief Checks if this definition represents an interface (not a class).
     * @return true if this is an interface, false if it is a class.
     */
    public override func isInterface(): Bool {
        return !_isClass
    }
    internal func setAttrAbstract(enable: Bool): Unit {
        _attributes.setAttr(Attribute.Abstract, enable)
    }
    internal func setAttrOpen(enable: Bool): Unit {
        _attributes.setAttr(Attribute.Virtual, enable)
    }
    internal func setAttrSealed(enable: Bool): Unit {
        _attributes.setAttr(Attribute.Sealed, enable)
    }
    /**
     * @brief Checks if this ClassDef is equal to another ClassDef.
     * @param other The ClassDef to compare with.
     * @return true if the definitions are equal, false otherwise.
     */
    public operator func==(other: ClassDef): Bool {
        return isSameDef(other)
    }
    protected override func printTitle(): String {
        let superClassStr = StringBuilder()
        if (_superClass.isSome()) {
            superClassStr.append(_superClass.getOrThrow().toString())
            superClassStr.append(if (implementedInterfaceTypes.isEmpty()) { " <: " } else { " & " })
            superClassStr.append(superClassStr)
        }
        return super.printTitle() + superClassStr.toString()
    }
    internal init(identifier: String, srcName: String, pkgName: String, isClass: Bool, curPackage: Package) {
        super(CustomDefKind.Class, identifier, srcName, pkgName, curPackage)
        this._isClass = isClass
        this._hashCode = calculateHashCode()
    }
}