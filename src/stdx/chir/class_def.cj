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
 * A ClassLikeDef can represent either a class or an interface. It extends CustomTypeDef
 * and provides methods to access class-specific information such as the super class.
 */
public class ClassLikeDef <: CustomTypeDef & Equatable<ClassLikeDef> {
    internal var _isClass: Bool
    internal var _isAnnotation: Bool = false
    internal var _superClass: ?ClassLikeType = None
    public mut prop isAnnotation: Bool {
        get() {
            return _isAnnotation
        }
        set(v) {
            _isAnnotation = v
        }
    }

    /**
     * @brief Gets the ClassLikeType associated with this class definition.
     * @return The ClassLikeType instance.
     */
    public prop classType: ClassLikeType {
        get() {
            return (_type.getOrThrow() as ClassLikeType).getOrThrow()
        }
    }

    /**
     * @brief Gets or sets the super class type of this class.
     *
     * If this class has no super class, the value is None.
     * @return An optional ClassLikeType representing the super class.
     */
    public mut prop superClass: ?ClassLikeType {
        get() {
            return _superClass
        }
        set(v) {
            _superClass = v
        }
    }

    public func setAbstract(enable: Bool): Unit {
        _attributes.setAttr(Attribute.Abstract, enable)
    }
    public func setOpen(enable: Bool): Unit {
        _attributes.setAttr(Attribute.Virtual, enable)
    }
    public func setSealed(enable: Bool): Unit {
        _attributes.setAttr(Attribute.Sealed, enable)
    }
    /**
     * @brief Checks if this ClassLikeDef is equal to another ClassLikeDef.
     * @param other The ClassLikeDef to compare with.
     * @return true if the definitions are equal, false otherwise.
     */
    public operator func==(other: ClassLikeDef): Bool {
        return isSameDef(other)
    }
    protected override func printTitle(): String {
        let superClassStr = StringBuilder()
        if (let Some(superClass) <- _superClass) {
            superClassStr.append(superClass.toString())
            superClassStr.append(if (implementedInterfaceTypes.isEmpty()) { " <: " } else { " & " })
            superClassStr.append(superClassStr)
        }
        return super.printTitle() + superClassStr.toString()
    }
    internal init(identifier: String, srcName: String, pkgName: String, isClass: Bool) {
        super(CustomDefKind.ClassLike, identifier, srcName, pkgName)
        this._isClass = isClass
        this._hashCode = calculateHashCode()
    }
}