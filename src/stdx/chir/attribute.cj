/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.chir

import std.deriving.*

const ATTR_SIZE: UInt64 = 64

@Derive[Equatable]
internal enum Attribute <: ToString {
    ATTR_BEGIN |
    STATIC |    ///< Mark whether a member is a static one.
    PUBLIC |    ///< Mark whether a member is a public one.
    PRIVATE |   ///< Mark whether a member is a private one.
    PROTECTED | ///< Mark whether a member is a protected one.

    ABSTRACT | ///< Mark whether a function is an abstract one.
    VIRTUAL |  ///< Mark whether a declaration is in fact open (even if the user does not use `open` keyword).

    OVERRIDE | ///< Mark whether a declaration in fact overrides the inherited one
              ///(even if the user does not use `override` keyword).

    REDEF | ///< Mark whether a declaration in fact overrides the inherited one (even if the user does not use
           ///< `redef` keyword).

    SEALED |  ///< Mark whether a declaration is a sealed one.
    FOREIGN | ///< Mark whether a declaration is a foreign one.

    MUT |      ///< Mark whether a declaration is a mutable one.
    FINAL |    ///< Mark a Func override a parent class's func, and this func self does not have VIRTUAL Attribute.
    OPERATOR | ///< Mark whether a declaration is a operator one.
    READONLY |             ///< 'let x = xxx', 'x' enable READONLY attribute
    CONST |                ///< correspond `const` keyword in Cangjie source code.
    IMPORTED |             ///< Mark whether variable、func、enum、struct、class is imported from other package.
    GENERIC_INSTANTIATED | ///< Mark whether a `GlobalVar/Func/Type` is instantiated.
    NO_DEBUG_INFO |        ///< Mark a `Value` doesn't contain debug info, like line/column number.
    GENERIC |              ///< Mark a declaration is generic
    INTERNAL |             ///< GlobalVar/Func/Enum/Class/Struct/Interface is visible in current and sub package.
    COMPILER_ADD |         ///< Mark a `Value` is added by compiler, like "copied default func from interface".

    // compiler attribute
    NO_REFLECT_INFO | ///< Mark a `Value` is't used by `reflect` feature.
    NO_INLINE |       ///< Mark a Func can't be inlined.
    NON_RECOMPILE |   ///< only used in `ImportedValue` in incremental compilation, indicate this ImportedValue is
                     ///< converted from a decl in current package that is not recompiled.
    UNREACHABLE |     ///< Mark a Block is unreachable.
    NO_SIDE_EFFECT |  ///< Mark a Func does't have side effect.
    COMMON |          ///< Mark whether it's common declaration.
    PLATFORM |        ///< Mark whether it's platform declaration.
    SKIP_ANALYSIS |   ///< Mark node that is not used for analysis.
                     ///< e.g. Node can be skiped if it has no body when creating 'common part'
    DESERIALIZED |    ///< Node deserialized from .chir file
    INITIALIZER |     ///< Mark nodes that related to initialization process.
                     ///< Marked functions are package initializer, file initializers, variable initializer or so.
                     ///< On the block is used to search for it among other blocks of the function.
    UNSAFE |   ///< Mark whether a function that was marked as `unsafe`
    // Native FFI attributes
    JAVA_MIRROR |      ///< Mark whether it's @JavaMirror declaration (binding for a java type).
    JAVA_IMPL |        ///< Mark whether it's @JavaImpl declaration.
    OBJ_C_MIRROR |     ///< Mark whether it's @ObjCMirror declaration (binding for an Objective-C type).
    HAS_INITED_FIELD | ///< Mark whether a node is a special flag, which marks the class instance as initialized.
    JAVA_HAS_DEFAULT | ///< Mark whether JAVA_MIRROR interface has default method.

    ATTR_END

    public func toString(): String {
        match (this) {
            case STATIC                => "static"
            case PUBLIC                => "public"
            case PRIVATE               => "private"
            case PROTECTED             => "protected"
            case ABSTRACT              => "abstract"
            case VIRTUAL               => "virtual"
            case OVERRIDE              => "override"
            case REDEF                 => "redef"
            case SEALED                => "sealed"
            case FOREIGN               => "foreign"
            case MUT                   => "mut"
            case OPERATOR              => "operator"
            case CONST                 => "compileTimeVal"
            case READONLY              => "readOnly"
            case IMPORTED              => "imported"
            case NON_RECOMPILE         => "nonRecompile"
            case GENERIC_INSTANTIATED  => "generic_instantiated"
            case INTERNAL              => "internal"
            case COMPILER_ADD          => "compilerAdd"
            case GENERIC               => "generic"
            case NO_REFLECT_INFO       => "noReflectInfo"
            case NO_INLINE             => "noInline"
            case NO_DEBUG_INFO         => "noDebugInfo"
            case UNREACHABLE           => "unreachable"
            case NO_SIDE_EFFECT        => "noSideEffect"
            case FINAL                 => "final"
            case COMMON                => "common"
            case PLATFORM              => "platform"
            case SKIP_ANALYSIS         => "skip_analysis"
            case DESERIALIZED          => "deserialized"
            case INITIALIZER           => "initializer"
            case UNSAFE                => "unsafe"
            case JAVA_MIRROR           => "javaMirror"
            case JAVA_IMPL             => "javaImpl"
            case OBJ_C_MIRROR          => "objCMirror"
            case HAS_INITED_FIELD      => "hasInitedField"
            case JAVA_HAS_DEFAULT      => "javaHasDefault"
            case ATTR_BEGIN | ATTR_END => "UNKNOWN"
        }
    }

    internal func toUInt64(): UInt64 {
        match (this) {
            case ATTR_BEGIN           => 0  // just a placeholder
            case STATIC               => 0
            case PUBLIC               => 1
            case PRIVATE              => 2
            case PROTECTED            => 3
            case ABSTRACT             => 4
            case VIRTUAL              => 5
            case OVERRIDE             => 6
            case REDEF                => 7
            case SEALED               => 8
            case FOREIGN              => 9
            case MUT                  => 10
            case FINAL                => 11
            case OPERATOR             => 12
            case READONLY             => 13
            case CONST                => 14
            case IMPORTED             => 15
            case GENERIC_INSTANTIATED => 16
            case NO_DEBUG_INFO        => 17
            case GENERIC              => 18
            case INTERNAL             => 19
            case COMPILER_ADD         => 20
            case NO_REFLECT_INFO      => 21
            case NO_INLINE            => 22
            case NON_RECOMPILE        => 23
            case UNREACHABLE          => 24
            case NO_SIDE_EFFECT       => 25
            case COMMON               => 26
            case PLATFORM             => 27
            case SKIP_ANALYSIS        => 28
            case DESERIALIZED         => 29
            case INITIALIZER          => 30
            case UNSAFE               => 31
            case JAVA_MIRROR          => 32
            case JAVA_IMPL            => 33
            case OBJ_C_MIRROR         => 34
            case HAS_INITED_FIELD     => 35
            case JAVA_HAS_DEFAULT     => 36
            case ATTR_END             => ATTR_SIZE  // Invalid, return size to indicate error
        }
    }
    internal func getNextAttribute(): Attribute {
        match (this) {
            case ATTR_BEGIN           => STATIC
            case STATIC               => PUBLIC
            case PUBLIC               => PRIVATE
            case PRIVATE              => PROTECTED
            case PROTECTED            => ABSTRACT
            case ABSTRACT             => VIRTUAL
            case VIRTUAL              => OVERRIDE
            case OVERRIDE             => REDEF
            case REDEF                => SEALED
            case SEALED               => FOREIGN
            case FOREIGN              => MUT
            case MUT                  => FINAL
            case FINAL                => OPERATOR
            case OPERATOR             => READONLY
            case READONLY             => CONST
            case CONST                => IMPORTED
            case IMPORTED             => GENERIC_INSTANTIATED
            case GENERIC_INSTANTIATED => NO_DEBUG_INFO
            case NO_DEBUG_INFO        => GENERIC
            case GENERIC              => INTERNAL
            case INTERNAL             => COMPILER_ADD
            case COMPILER_ADD         => NO_REFLECT_INFO
            case NO_REFLECT_INFO      => NO_INLINE
            case NO_INLINE            => NON_RECOMPILE
            case NON_RECOMPILE        => UNREACHABLE
            case UNREACHABLE          => NO_SIDE_EFFECT
            case NO_SIDE_EFFECT       => COMMON
            case COMMON               => PLATFORM
            case PLATFORM             => SKIP_ANALYSIS
            case SKIP_ANALYSIS        => DESERIALIZED
            case DESERIALIZED         => INITIALIZER
            case INITIALIZER          => UNSAFE
            case UNSAFE               => JAVA_MIRROR
            case JAVA_MIRROR          => JAVA_IMPL
            case JAVA_IMPL            => OBJ_C_MIRROR
            case OBJ_C_MIRROR         => HAS_INITED_FIELD
            case HAS_INITED_FIELD     => JAVA_HAS_DEFAULT
            case JAVA_HAS_DEFAULT     => ATTR_END
            case ATTR_END             => ATTR_END
        }
    }
}

/**
 * AttributeInfo class for managing attribute flags
 * Uses a bitset-like approach with UInt64 to store up to 64 attributes
 */
internal class AttributeInfo <: ToString {
    internal var attributesInfo: UInt64 = 0

    internal init() {
        this.attributesInfo = 0
    }

    internal init(attrs: UInt64) {
        this.attributesInfo = attrs
    }

    internal func clone(): AttributeInfo {
        return AttributeInfo(attributesInfo)
    }

    /**
     * Set an attribute to enabled or disabled
     */
    internal func setAttr(attr: Attribute, enable: Bool): Unit {
        if (enable) {
            let bitIndex = attr.toUInt64()
            if (bitIndex < ATTR_SIZE) {
                attributesInfo |= UInt64(1)  << bitIndex
            }
        } else {
            let bitIndex = attr.toUInt64()
            if (bitIndex < ATTR_SIZE) {
                attributesInfo &= !(UInt64(1) << bitIndex)
            }
        }
    }

    /**
     * Test whether an attribute is set
     */
    internal func testAttr(attr: Attribute): Bool {
        let bitIndex = attr.toUInt64()
        if (bitIndex >= ATTR_SIZE) {
            return false
        }
        return (attributesInfo & (UInt64(1) << bitIndex)) != 0
    }

    internal func appendAttrs(info : AttributeInfo): Unit {
        attributesInfo |= info.attributesInfo
    }

    public func toString(): String {
        var result = ArrayList<String>()
        // Iterate through all attributes and build string
        var current: Attribute = Attribute.ATTR_BEGIN.getNextAttribute()
        while (true) {
            if (testAttr(current)) {
                result.add("[" + current.toString() + "]")
            }
            // Move to next attribute (simplified iteration)
            current = current.getNextAttribute()
            if (current == Attribute.ATTR_END) {
                break
            }
        }
        if (result.isEmpty()) {
            return ""
        }
        return String.join(result.toArray())
    }

    internal func getRawAttrs(): UInt64 {
        return attributesInfo
    }

    internal func enableAttrInternal(): Unit {
        setAttr(Attribute.INTERNAL, true)
        setAttr(Attribute.PUBLIC, false)
        setAttr(Attribute.PRIVATE, false)
        setAttr(Attribute.PROTECTED, false)
    }
    internal func enableAttrPublic(): Unit {
        setAttr(Attribute.PUBLIC, true)
        setAttr(Attribute.PRIVATE, false)
        setAttr(Attribute.PROTECTED, false)
        setAttr(Attribute.INTERNAL, false)
    }
    internal func enableAttrPrivate(): Unit {
        setAttr(Attribute.PRIVATE, true)
        setAttr(Attribute.PUBLIC, false)
        setAttr(Attribute.PROTECTED, false)
        setAttr(Attribute.INTERNAL, false)
    }
    internal func enableAttrProtected(): Unit {
        setAttr(Attribute.PROTECTED, true)
        setAttr(Attribute.PUBLIC, false)
        setAttr(Attribute.PRIVATE, false)
        setAttr(Attribute.INTERNAL, false)
    }
}