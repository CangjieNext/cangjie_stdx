# Classes

## class Annotation

```cangjie
public class Annotation <: ToString
```

Function: Represents **one** annotation instance in CHIR, corresponding to the source form `@ClassName[k1=v1, k2=v2]`: stores the annotation class name and a mapping from parameter field names to string values.

Parent Types:

- ToString

### prop classSrcCodeName

```cangjie
public prop classSrcCodeName: String
```

Function: The annotation class name as it appears in source code.

Type: String

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let a = Annotation("MyAnno")
    println(a.classSrcCodeName)
}
```

Output:

```text
MyAnno
```

### init(String)

```cangjie
public init(classSrcCodeName: String)
```

Function: Constructs an `Annotation` object with the given annotation class name and an **initially empty** parameter list; use [`setFieldValue`](#func-setfieldvalue-string-string) to add key-value pairs.

Parameters:

- classSrcCodeName: String - The annotation class name in source code (e.g. `MyAnno`).

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let a = Annotation("Fresh")
    println(a.toString())
}
```

Output:

```text
@Fresh[]
```

### func getFieldValue(String)

```cangjie
public func getFieldValue(fieldName: String): ?String
```

Function: Looks up an annotation parameter by key; returns `None` if it does not exist.

Parameters:

- fieldName: String - The parameter field name (same as the key in `key=value` from `toString()`).

Return Value:

- ?String - `Some(string value)` if present, otherwise `None`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let a = Annotation("A")
    if (let None <- a.getFieldValue("noSuchKey")) {
        println("missing")
    }
}
```

Output:

```text
missing
```

### func setFieldValue(String, String)

```cangjie
public func setFieldValue(fieldName: String, value: String): Unit
```

Function: Sets or overrides the string value of a parameter field (used when building or testing CHIR).

Parameters:

- fieldName: String - Parameter name.
- value: String - Parameter value (as a string).

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let a = Annotation("S")
    a.setFieldValue("path", "/tmp")
    println(a.toString())
}
```

Output:

```text
@S[path=/tmp]
```

### func toString()

```cangjie
public func toString(): String
```

Function: Formats as `@ClassName[k1=v1, k2=v2]` for logging and debugging.

Return Value:

- String - Textual form of the annotation.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let a = Annotation("T")
    println(a.toString())
}
```

Output:

```text
@T[]
```

---

## class BoolType

```cangjie
public class BoolType <: BuiltinType & Equatable<BoolType>
```

Function: Represents the boolean type in the type system. This is a singleton type representing the Bool type.

Parent Types:

- [BuiltinType](#class-builtintype)
- Equatable\<[BoolType](#class-booltype)>

### static func get()

```cangjie
public static func get(): BoolType
```

Function: Gets the singleton instance of BoolType.

Return Value:

- BoolType - BoolType instance.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let boolType = BoolType.get()
    println("Boolean type: ${boolType.toString()}")
}
```

Output:

```text
Boolean type: Bool
```

### operator func==(BoolType)

```cangjie
public operator func==(_: BoolType): Bool
```

Function: Checks whether this BoolType is equal to another BoolType.

Parameters:

- _: BoolType - The other BoolType to compare with (unused; always returns true).

Return Value:

- Bool - Always returns true because all BoolType instances are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let boolType1 = BoolType.get()
    let boolType2 = BoolType.get()
    println("Two BoolType instances are equal: ${boolType1 == boolType2}")
}
```

Output:

```text
Two BoolType instances are equal: true
```

## class BoxType

```cangjie
public class BoxType <: Type & Equatable<BoxType>
```

Function: Represents the **boxed type** `Box<T>`, wrapping values in a box. The cache ensures a unique instance per `baseType`.

Parent Types:

- [Type](#class-type)
- Equatable\<[BoxType](#class-boxtype)>

### prop baseType

```cangjie
public prop baseType: Type
```

Function: The base type being boxed.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let b = BoxType.get(IntType.getInt32())
    println(b.baseType.toString())
}
```

Output:

```text
Int32
```

### static func get(Type)

```cangjie
public static func get(baseType: Type): BoxType
```

Function: Gets or creates the `BoxType` for the given base type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let b = BoxType.get(IntType.getInt32())
    println(b.toString())
}
```

Output:

```text
Box<Int32>
```

### func toString()

```cangjie
public func toString(): String
```

Function: String form, typically in the `Box<...>` style.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let b = BoxType.get(IntType.getUInt32())
    println(b.toString())
}
```

Output:

```text
Box<UInt32>
```

### operator func==(BoxType)

```cangjie
public operator func ==(other: BoxType): Bool
```

Function: Compares whether two `BoxType` instances are the same.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let base = IntType.getInt32()
    let b1 = BoxType.get(base)
    let b2 = BoxType.get(base)
    println("op_eq_BoxType: ${b1 == b2}")
}
```

Output:

```text
op_eq_BoxType: true
```

---

## class BuiltinType

```cangjie
sealed abstract class BuiltinType <: Type & Equatable<BuiltinType>
```

Function: Common base class for built-in types (numeric, Bool, Unit, pointer, array, etc.); can attach `ExtendDef` (`addExtend`) and collect interface parent types implemented via `extend` through `getSuperTypesRecusively`.

Parent Types:

- [Type](#class-type)
- Equatable\<[BuiltinType](#class-builtintype)>

### func addExtend(ExtendDef)

```cangjie
public func addExtend(extendDef: ExtendDef): Unit
```

Function: Registers one [ExtendDef](#class-extenddef) for this built-in type (corresponding to an `extend` block for that built-in type in source).

Parameters:

- extendDef: ExtendDef - Extension definition.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let ext = pkg.addExtend("ext_mangled", IntType.getInt32())
    IntType.getInt32().addExtend(ext)
    println("extend id: ${ext.identifier}")
}
```

Output:

```text
extend id: @ext_mangled
```

(The exact `identifier` prefix and mangling rules follow the source implementation.)

### func getSuperTypesRecusively(ArrayList\<(Type, Type)>)

```cangjie
public func getSuperTypesRecusively(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType>
```

Function: Starting from interfaces implemented via `extend` on this type, recursively collects [ClassLikeType](#class-classliketype) on the parent interface/class side (for semantic and inheritance analysis).

Parameters:

- visited! - Visitation table for cycle detection; usually pass the default empty table.

Return Value:

- Array\<ClassLikeType> - Collected sequence of types.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = IntType.getInt32()
    println("${t.getSuperTypesRecusively().size}")
}
```

Output:

```text
0
```

### operator func==(BuiltinType)

```cangjie
public operator func==(other: BuiltinType): Bool
```

Function: Compares whether two built-in types denote the same class and identical type arguments.

Parameters:

- other: BuiltinType - The other built-in type.

Return Value:

- Bool - `true` if equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let a = IntType.getInt32()
    let b = IntType.getInt32()
    let c = IntType.getInt64()
    println("op_eq_BuiltinType sameInt32: ${a == b}")
    println("op_eq_BuiltinType int32vsInt64: ${a == c}")
}
```

Output:

```text
op_eq_BuiltinType sameInt32: true
op_eq_BuiltinType int32vsInt64: false
```

## class CPointerType

```cangjie
public class CPointerType <: BuiltinType & Equatable<CPointerType>
```

Function: Represents a C pointer type in the type system. This type denotes a pointer to a C type for C interoperability. The class caches all C pointer types to ensure uniqueness.

Parent Types:

- [BuiltinType](#class-builtintype)
- Equatable\<[CPointerType](#class-cpointertype)>

### prop elementType

```cangjie
public prop elementType: Type
```

Function: Gets the element type that this C pointer type points to.

Return Value:

- Type - Element type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let cp = CPointerType.get(intType)
    println(cp.elementType.toString())
}
```

Output:

```text
Int32
```

### static func get(Type)

```cangjie
public static func get(elementType: Type): CPointerType
```

Function: Gets or creates the CPointerType for the given element type.

This method ensures there is at most one CPointerType instance per element type.

Parameters:

- elementType: Type - The type the pointer points to.

Return Value:

- CPointerType - The CPointerType instance for the given element type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let cPointerType = CPointerType.get(intType)
    println(cPointerType.toString())
}
```

Output:

```text
CPointer<Int32>
```

### func toString()

```cangjie
public func toString(): String
```

Function: Converts this CPointerType to a string representation.

Return Value:

- String - String form of the C pointer type (`CPointer\<elementType>`).

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let cPointerType = CPointerType.get(IntType.getUInt32())
    println(cPointerType.toString())
}
```

Output:

```text
CPointer<UInt32>
```

### operator func==(CPointerType)

```cangjie
public operator func==(other: CPointerType): Bool
```

Function: Checks whether this CPointerType equals another CPointerType.

Parameters:

- other: CPointerType - The CPointerType to compare with.

Return Value:

- Bool - Returns true if the types are equal, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let cPointerType1 = CPointerType.get(intType)
    let cPointerType2 = CPointerType.get(intType)
    println("op_eq_CPointerType: ${cPointerType1 == cPointerType2}")
}
```

Output:

```text
op_eq_CPointerType: true
```

## class CStringType

```cangjie
public class CStringType <: BuiltinType & Equatable<CStringType>
```

Function: Represents the C string type in the type system. This type denotes a C-style null-terminated string for C interoperability. It is a singleton type for the built-in C string type.

Parent Types:

- [BuiltinType](#class-builtintype)
- Equatable\<[CStringType](#class-cstringtype)>

### static func get()

```cangjie
public static func get(): CStringType
```

Function: Gets the singleton instance of CStringType.

Return Value:

- CStringType - CStringType instance.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let cStringType = CStringType.get()
    println(cStringType.toString())
}
```

Output:

```text
CString
```

### operator func==(CStringType)

```cangjie
public operator func==(_: CStringType): Bool
```

Function: Checks whether this CStringType equals another CStringType.

Parameters:

- _: CStringType - The other CStringType to compare with (unused; always returns true).

Return Value:

- Bool - Always returns true because all CStringType instances are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let cStringType1 = CStringType.get()
    let cStringType2 = CStringType.get()
    println("op_eq_CStringType: ${cStringType1 == cStringType2}")
}
```

Output:

```text
op_eq_CStringType: true
```

## class ClassLikeDef

```cangjie
public class ClassLikeDef <: CustomTypeDef & Equatable<ClassLikeDef>
```

Function: Definition of a **class or interface**.

Parent Types:

- [CustomTypeDef](#class-customtypedef)
- Equatable\<[ClassLikeDef](#class-classlikedef)>

### prop classType

```cangjie
public prop classType: ClassLikeType
```

Function: The [ClassLikeType](#class-classliketype) corresponding to this definition.

Type: [ClassLikeType](#class-classliketype)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    println("prop_classType: ${def.classType.classLikeDef == def}")
}
```

Output:

```text
prop_classType: true
```

### prop isAnnotation

```cangjie
public mut prop isAnnotation: Bool
```

Function: Whether this is an annotation class.

Type: Bool

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    println(def.isAnnotation)
}
```

Output:

```text
false
```

### prop superClass

```cangjie
public mut prop superClass: ?ClassLikeType
```

Function: Superclass; `None` if there is no superclass.

Type: ?[ClassLikeType](#class-classliketype)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    println("mut_prop_superClass: ${def.superClass.isNone()}")
}
```

Output:

```text
mut_prop_superClass: true
```

### func setAbstract(Bool)

```cangjie
public func setAbstract(enable: Bool): Unit
```

Function: Sets or clears the `abstract` flag.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    def.setAbstract(true)
    println("fn_setAbstract: ${def.isAbstract()}")
}
```

Output:

```text
fn_setAbstract: true
```

### func setOpen(Bool)

```cangjie
public func setOpen(enable: Bool): Unit
```

Function: Sets or clears markers related to `open` (inheritability / virtual).

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    def.setOpen(true)
    println("fn_setOpen: ${def.isOpen()}")
}
```

Output:

```text
fn_setOpen: true
```

### func setSealed(Bool)

```cangjie
public func setSealed(enable: Bool): Unit
```

Function: Sets or clears the `sealed` flag.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    def.setSealed(true)
    println("fn_setSealed: ${def.isSealed()}")
}
```

Output:

```text
fn_setSealed: true
```

### operator func==(ClassLikeDef)

```cangjie
public operator func==(other: ClassLikeDef): Bool
```

Function: Compares whether two class/interface definitions are the same.

Parameters:

- other: ClassLikeDef - The other definition.

Return Value:

- Bool - Whether they are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addClass("C_m", "C", true)
    println("op_eq_ClassLikeDef: ${def == def}")
}
```

Output:

```text
op_eq_ClassLikeDef: true
```

---

## class ClassLikeType

```cangjie
public class ClassLikeType <: CustomType & Equatable<ClassLikeType>
```

Function: **Instantiated** type of a class or interface; `get(def, genericTypeParams)` caches a unique instance.

Parent Types:

- [CustomType](#class-customtype)
- Equatable\<[ClassLikeType](#class-classliketype)>

### prop classLikeDef

```cangjie
public prop classLikeDef: ClassLikeDef
```

Function: The corresponding [ClassLikeDef](#class-classlikedef).

Type: [ClassLikeDef](#class-classlikedef)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("C_m", "C", true)
    let ty = ClassLikeType.get(d, [])
    println(ty.classLikeDef.srcCodeName)
}
```

Output:

```text
C
```

### static func get(ClassLikeDef, Array\<Type>)

```cangjie
public static func get(def: ClassLikeDef, genericTypeParams: Array<Type>): ClassLikeType
```

Function: Gets or creates the cached unique instance from the definition and generic arguments.

Parameters:

- def: ClassLikeDef - Class/interface definition.
- genericTypeParams: Array\<Type> - Generic type arguments (empty array when not generic).

Return Value:

- ClassLikeType - Instantiated type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("C_m", "C", true)
    let ty = ClassLikeType.get(d, [])
    println("static_get: ${ty.classLikeDef.identifier.size > 0}")
}
```

Output:

```text
static_get: true
```

### operator func==(ClassLikeType)

```cangjie
public operator func==(other: ClassLikeType): Bool
```

Function: Compares whether two instantiated class/interface types are the same.

Parameters:

- other: ClassLikeType - The other type.

Return Value:

- Bool - Whether they are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("C_m", "C", true)
    let ty1 = ClassLikeType.get(d, [])
    let ty2 = ClassLikeType.get(d, [])
    println("op_eq_ClassLikeType: ${ty1 == ty2}")
}
```

Output:

```text
op_eq_ClassLikeType: true
```

---

## class CustomType

```cangjie
sealed abstract class CustomType <: Type & Equatable<CustomType>
```

Function: Common base class for instantiated user-defined types (class/interface/struct/enum), holding `CustomTypeDef` and generic arguments.

Parent Types:

- [Type](#class-type)
- Equatable\<[CustomType](#class-customtype)>

Subclasses include [ClassLikeType](#class-classliketype), [StructType](#class-structtype), [EnumType](#class-enumtype), etc.

### prop allMemberVarNames

```cangjie
public prop allMemberVarNames: Array<String>
```

Function: All instance member names from the linearized superclass chain up through this type’s declarations.

Type: Array\<String>

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    d.appendInstanceMemberVar("x", IntType.getInt32())
    let st = StructType.get(d, [])
    println("${st.allMemberVarNames.size}")
}
```

Output:

```text
1
```

### prop def

```cangjie
public prop def: CustomTypeDef
```

Function: The corresponding type definition node.

Type: [CustomTypeDef](#class-customtypedef)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println(st.def.srcCodeName)
}
```

Output:

```text
S
```

### prop genericTypeArgs

```cangjie
public prop genericTypeArgs: Array<Type>
```

Function: Generic type argument list (empty when not generic).

Type: Array\<Type>

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println("${st.genericTypeArgs.size}")
}
```

Output:

```text
0
```

### func getExtendDefs(ArrayList\<(Type, Type)>)

```cangjie
public func getExtendDefs(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ExtendDef>
```

Function: Returns extend definitions in `def.extends` whose `extendedType` matches the current type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println("${st.getExtendDefs().size}")
}
```

Output:

```text
0
```

### func getExtendImplementedInterfaceTypes(ArrayList\<(Type, Type)>)

```cangjie
public func getExtendImplementedInterfaceTypes(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType>
```

Function: Collects interfaces implemented by `extend` blocks applicable to this instance (with generics substituted).

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println("${st.getExtendImplementedInterfaceTypes().size}")
}
```

Output:

```text
0
```

### func getImplementedInterfaceTypes(ArrayList\<(Type, Type)>)

```cangjie
public func getImplementedInterfaceTypes(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType>
```

Function: Union of interfaces implemented via `extend` and `implementedInterfaceTypes` on the definition (instantiated).

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println("${st.getImplementedInterfaceTypes().size}")
}
```

Output:

```text
0
```

### func getInstantiatedMemberVarTypes()

```cangjie
public func getInstantiatedMemberVarTypes(): Array<Type>
```

Function: Member types aligned with `allMemberVarNames`, substituted with current generic arguments.

Return Value:

- Array\<Type> - Sequence of instantiated member types.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    d.appendInstanceMemberVar("x", IntType.getInt32())
    let st = StructType.get(d, [])
    println("${st.getInstantiatedMemberVarTypes().size}")
}
```

Output:

```text
1
```

### func getMemberVarInstantiatedType(String)

```cangjie
public func getMemberVarInstantiatedType(name: String): Type
```

Function: Looks up the instantiated member type by name (inner-to-outer shadowing).

Parameters:

- name: String - Member source name.

Return Value:

- Type - Member type.

Exception:

- Exception - Thrown when the member name is not found.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    d.appendInstanceMemberVar("x", IntType.getInt32())
    let st = StructType.get(d, [])
    println(st.getMemberVarInstantiatedType("x").toString())
}
```

Output:

```text
Int32
```

### func getSuperTypesRecusively(ArrayList\<(Type, Type)>)

```cangjie
public func getSuperTypesRecusively(visited!: ArrayList<(Type, Type)> = ArrayList<(Type, Type)>()): Array<ClassLikeType>
```

Function: Recursively collects superclass and interface parent types (instantiated).

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println("${st.getSuperTypesRecusively().size}")
}
```

Output:

```text
0
```

### func toString()

```cangjie
public func toString(): String
```

Function: Compact string of internal kind, identity, and generic arguments.

Return Value:

- String - Textual form.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println("fn_toString: ${st.toString().size > 0}")
}
```

Output:

```text
fn_toString: true
```

### operator func==(CustomType)

```cangjie
public operator func==(other: CustomType): Bool
```

Function: Compares whether kind, definition, and generic arguments match.

Parameters:

- other: CustomType - The other instantiated custom type.

Return Value:

- Bool - Whether they are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    let st = StructType.get(d, [])
    println("op_eq_CustomType: ${st == StructType.get(d, [])}")
}
```

Output:

```text
op_eq_CustomType: true
```

---

## class CustomTypeDef

```cangjie
sealed abstract class CustomTypeDef <: Base & Equatable<CustomTypeDef> & Hashable
```

Function: Common base class for **definitions** of class/interface/struct/enum/extension (combined with `Base`; includes attributes, CHIR annotations, debug locations, etc.).

Parent Types:

- Equatable\<[CustomTypeDef](#class-customtypedef)>
- Hashable

### prop identifier

```cangjie
public prop identifier: String
```

Function: Internal identifier; globally unique identifier.

Type: String

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("prop_identifier: ${d.identifier.size > 0}")
}
```

Output:

```text
prop_identifier: true
```


### prop srcCodeName

```cangjie
public prop srcCodeName: String
```

Function: Type name in source code (may be empty in `extend` scenarios; see source comments).

Type: String

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.srcCodeName)
}
```

Output:

```text
X
```


### prop packageName

```cangjie
public prop packageName: String
```

Function: Name of the owning package.

Type: String

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.packageName)
}
```

Output:

```text
p
```


### prop ty

```cangjie
public prop ty: Type
```

Function: For ordinary definitions, the instantiated type; for [ExtendDef](#class-extenddef), `extendedType`.

Type: [Type](#class-type)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("prop_ty: ${d.ty.toString().size > 0}")
}
```

Output:

```text
prop_ty: true
```


### prop genericTypeParams

```cangjie
public prop genericTypeParams: Array<GenericType>
```

Function: Generic type parameter list; empty if not generic or type arguments cannot be inferred.

Type: Array\<[GenericType](#class-generictype)>

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("${d.genericTypeParams.size}")
}
```

Output:

```text
0
```


### prop genericDecl

```cangjie
public mut prop genericDecl: ?CustomTypeDef
```

Function: Generic template definition paired with the current **monomorphic** definition; `set` validates kind, `srcCodeName`, and generic constraints (see source assertions).

Type: ?CustomTypeDef

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("mut_prop_genericDecl: ${d.genericDecl.isNone()}")
}
```

Output:

```text
mut_prop_genericDecl: true
```


### prop instanceVars

```cangjie
public prop instanceVars: Array<MemberVar>
```

Function: Instance member variable list (declaration order).

Type: Array\<[MemberVar](#class-membervar)>

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("${d.instanceVars.size}")
}
```

Output:

```text
0
```


### prop extends

```cangjie
public mut prop extends: Array<ExtendDef>
```

Function: `extend` definitions nested under this type.

Type: Array\<[ExtendDef](#class-extenddef)>

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("${d.extends.size}")
}
```

Output:

```text
0
```


### prop implementedInterfaceTypes

```cangjie
public mut prop implementedInterfaceTypes: Array<ClassLikeType>
```

Function: List of directly implemented interface types.

Type: Array\<[ClassLikeType](#class-classliketype)>

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("${d.implementedInterfaceTypes.size}")
}
```

Output:

```text
0
```


### func setPublic()

```cangjie
public func setPublic(): Unit
```

Function: Marked as `public` visibility.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    d.setPublic()
    println("fn_setPublic: ${d.isPublic()}")
}
```

Output:

```text
fn_setPublic: true
```


### func setPrivate()

```cangjie
public func setPrivate(): Unit
```

Function: Marked as `private`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    d.setPrivate()
    println("fn_setPrivate: ${d.isPrivate()}")
}
```

Output:

```text
fn_setPrivate: true
```


### func setProtected()

```cangjie
public func setProtected(): Unit
```

Function: Marked as `protected`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    d.setProtected()
    println("fn_setProtected: ${d.isProtected()}")
}
```

Output:

```text
fn_setProtected: true
```


### func setInternal()

```cangjie
public func setInternal(): Unit
```

Function: Marked as `internal`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    d.setInternal()
    println("fn_setInternal: ${d.isInternal()}")
}
```

Output:

```text
fn_setInternal: true
```


### func isImported()

```cangjie
public func isImported(): Bool
```

Function: Whether this definition is imported from another package.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isImported())
}
```

Output:

```text
false
```


### func isPublic()

```cangjie
public func isPublic(): Bool
```

Function: Whether it has the `public` attribute.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isPublic())
}
```

Output:

```text
false
```


### func isPrivate()

```cangjie
public func isPrivate(): Bool
```

Function: Whether it has the `private` attribute.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isPrivate())
}
```

Output:

```text
false
```


### func isInternal()

```cangjie
public func isInternal(): Bool
```

Function: Whether it has the `internal` attribute.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isInternal())
}
```

Output:

```text
false
```


### func isProtected()

```cangjie
public func isProtected(): Bool
```

Function: Whether it has the `protected` attribute.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isProtected())
}
```

Output:

```text
false
```


### func isAbstract()

```cangjie
public func isAbstract(): Bool
```

Function: Whether it is `abstract`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isAbstract())
}
```

Output:

```text
false
```


### func isOpen()

```cangjie
public func isOpen(): Bool
```

Function: Whether it can be inherited/implemented (`virtual` or `abstract`).

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isOpen())
}
```

Output:

```text
false
```


### func isSealed()

```cangjie
public func isSealed(): Bool
```

Function: Whether it is `sealed`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isSealed())
}
```

Output:

```text
false
```


### func isGeneric()

```cangjie
public func isGeneric(): Bool
```

Function: Whether it is a generic definition.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isGeneric())
}
```

Output:

```text
false
```


### func isClassLike()

```cangjie
public func isClassLike(): Bool
```

Function: Whether the kind is class/interface.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("fn_isClassLike: ${d.isClassLike()}")
}
```

Output:

```text
fn_isClassLike: true
```


### func isClass()

```cangjie
public func isClass(): Bool
```

Function: Whether it is a class (not an interface).

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("fn_isClass: ${d.isClass()}")
}
```

Output:

```text
fn_isClass: true
```


### func isInterface()

```cangjie
public func isInterface(): Bool
```

Function: Whether it is an interface.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isInterface())
}
```

Output:

```text
false
```


### func isEnum()

```cangjie
public func isEnum(): Bool
```

Function: Whether it is an enum definition.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isEnum())
}
```

Output:

```text
false
```


### func isExtend()

```cangjie
public func isExtend(): Bool
```

Function: Whether it is an extend definition.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isExtend())
}
```

Output:

```text
false
```


### func isStruct()

```cangjie
public func isStruct(): Bool
```

Function: Whether it is a struct definition.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println(d.isStruct())
}
```

Output:

```text
false
```



### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Hash code of the definition.

Return Value:

- Int64 - Hash value.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("fn_hashCode: ${d.hashCode() != 0}")
}
```

Output:

```text
fn_hashCode: true
```

### operator func==(CustomTypeDef)

```cangjie
public operator func==(other: CustomTypeDef): Bool
```

Function: Compares by kind, identifier, source name, and package name.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("op_eq_CustomTypeDef: ${d == d}")
}
```

Output:

```text
op_eq_CustomTypeDef: true
```

### func toString()

```cangjie
public open func toString(): String
```

Function: Multi-line dump of class/interface/enum shape (including attributes, members, `extend` list).

Return Value:

- String - Readable dump of the definition.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("fn_toString: ${d.toString().size > 0}")
}
```

Output:

```text
fn_toString: true
```

### func dump()

```cangjie
public func dump(): Unit
```

Function: Prints `toString()` to standard output.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    d.dump()
}
```

Output:

```text
[pluginAdded]class @X_m { // srcCodeName: X, packageName: p
}
```

### func appendInstanceMemberVar(String, Type)

```cangjie
public func appendInstanceMemberVar(name: String, ty: Type): MemberVar
```

Function: **Appends** an instance member variable (name and type) to the current type definition and returns the corresponding [MemberVar](#class-membervar). Order in `instanceVars` matches call order; use after `Package.addClass` / `addStruct` for plugins or tests attaching CHIR members.

Return Value:

- [MemberVar](#class-membervar) - Newly created member variable node.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    let mv = d.appendInstanceMemberVar("f", IntType.getInt32())
    println(mv.name)
}
```

Output:

```text
f
```

### func getSuperTypesRecusively()

```cangjie
public func getSuperTypesRecusively(): Array<ClassLikeType>
```

Function: Recursively collects all superclasses of this definition, including interfaces implemented by superclasses via extension, but not interfaces implemented by this definition via extension.

Return Value:

- Array\<ClassLikeType> - Collected parent types; **order is not guaranteed**.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addClass("X_m", "X", true)
    println("${d.getSuperTypesRecusively().size}")
}
```

Output:

```text
0
```

---

## class DebugLocation

```cangjie
public class DebugLocation <: ToString
```

Function: **Source range** (start/end `Position` and file path) for debugging and printing.

Parent Types:

- ToString

### prop start

```cangjie
public prop start: Position
```

Function: Range start (inclusive), paired with [struct Position](chir_package_structs.md#struct-position).

Type: [Position](chir_package_structs.md#struct-position)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.location.start.line)
}
```

Output:

```text
0
```

### prop end

```cangjie
public prop end: Position
```

Function: Range end.

Type: [Position](chir_package_structs.md#struct-position)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.location.end.column)
}
```

Output:

```text
0
```

### prop filePath

```cangjie
public prop filePath: Path
```

Function: Source file path (absolute or project-relative; see `std.fs.Path`).

Type: Path

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println("prop_filePath: ${mv.location.filePath.isEmpty()}")
}
```

Output:

```text
prop_filePath: true
```

### func isValid()

```cangjie
public func isValid(): Bool
```

Function: Returns `true` when both `start` and `end` are valid and `filePath` is non-empty.

Return Value:

- Bool - Whether this is a usable debug range.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.location.isValid())
}
```

Output:

```text
false
```

### func toString()

```cangjie
public func toString(): String
```

Function: Returns empty string when invalid; otherwise prints file name, compact `start`/`end`, and optional scope chain (see source).

Return Value:

- String - Human-readable location description.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.location.toString().size)
}
```

Output:

```text
0
```

## class EnumCtorInfo

```cangjie
public class EnumCtorInfo <: ToString
```

Function: One **constructor/variant** of an enum (name, internal id, function type, annotations).

Parent Types:

- ToString

### prop identifier

```cangjie
public prop identifier: String
```

Function: Internal identifier; globally unique identifier.

Type: String

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    let ctor = e.appendEnumCtorInfo("A_m", "A")
    println("prop_identifier: ${ctor.identifier.size > 0}")
}
```

Output:

```text
prop_identifier: true
```

### prop funcType

```cangjie
public prop funcType: FuncType
```

Function: The [FuncType](#class-functype) for this variant’s parameter types and return type (return type is the owning enum type).

Type: [FuncType](#class-functype)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    let ctor = e.appendEnumCtorInfo("A_m", "A")
    println("${ctor.funcType.paramTypes.size}")
}
```

Output:

```text
0
```

### prop srcCodeName

```cangjie
public prop srcCodeName: String
```

Function: Constructor/variant name in source code.

Type: String

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    let ctor = e.appendEnumCtorInfo("A_m", "A")
    println(ctor.srcCodeName)
}
```

Output:

```text
A
```

### prop annotations

```cangjie
public mut prop annotations: Array<Annotation>
```

Function: List of annotation instances attached to this enum constructor (stored internally as `AnnoInfo`, exposed as `Array<Annotation>`); `set` replaces the whole list.

Type: Array\<[Annotation](#class-annotation)>

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    let ctor = e.appendEnumCtorInfo("A_m", "A")
    let ann = Annotation("Marker")
    ann.setFieldValue("x", "1")
    ctor.annotations = [ann]
    println("${ctor.annotations.size}")
}
```

Output:

```text
1
```

### func toString()

```cangjie
public func toString(): String
```

Function: Short description like `VariantName(paramTypes...)` (see source).

Return Value:

- String - Constructor text form.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    let ctor = e.appendEnumCtorInfo("A_m", "A")
    println(ctor.toString())
}
```

Output:

```text
A
```

---

## class EnumDef

```cangjie
public class EnumDef <: CustomTypeDef & Equatable<EnumDef>
```

Function: **Enum** definition; includes exhaustive flag, constructor list, etc.

Parent Types:

- [CustomTypeDef](#class-customtypedef)
- Equatable\<[EnumDef](#class-enumdef)>

### prop isExhaustive

```cangjie
public prop isExhaustive: Bool
```

Function: Whether this is an **exhaustive** enum (opposite of internal `nonExhaustive` flag).

Type: Bool

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    println("prop_isExhaustive: ${e.isExhaustive}")
}
```

Output:

```text
prop_isExhaustive: true
```

### prop constructors

```cangjie
public prop constructors: Array<EnumCtorInfo>
```

Function: All enum constructors/variants in declaration order.

Type: Array\<[EnumCtorInfo](#class-enumctorinfo)>

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    e.appendEnumCtorInfo("A_m", "A")
    println("${e.constructors.size}")
}
```

Output:

```text
1
```

### prop enumType

```cangjie
public prop enumType: EnumType
```

Function: The instantiated [EnumType](#class-enumtype) corresponding to this definition.

Type: [EnumType](#class-enumtype)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    println("prop_enumType: ${e.enumType.enumDef == e}")
}
```

Output:

```text
prop_enumType: true
```

### func appendEnumCtorInfo(String, String, Array\<Type>)

```cangjie
public func appendEnumCtorInfo(identifier: String, name: String, argTypes!: Array<Type> = Array<Type>()): EnumCtorInfo
```

Function: Appends an enum variant; zero-argument variants may omit `argTypes` or pass an empty array.

Parameters:

- identifier: String - Globally unique identifier.
- name: String - Variant name in source.
- argTypes!: Array\<Type> - Parameter type list.

Return Value:

- [EnumCtorInfo](#class-enumctorinfo) - Newly created constructor info.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_mangled", "E", true)
    let c = e.appendEnumCtorInfo("A_mangled", "A")
    println(c.srcCodeName)
}
```

Output:

```text
A
```

### operator func==(EnumDef)

```cangjie
public operator func==(other: EnumDef): Bool
```

Function: Compares whether two enum definitions are the same by definition id.

Parameters:

- other: EnumDef - The other enum definition.

Return Value:

- Bool - Whether they are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let e = pkg.addEnum("E_m", "E", true)
    println("op_eq_EnumDef: ${e == e}")
}
```

Output:

```text
op_eq_EnumDef: true
```

---

## class EnumType

```cangjie
public class EnumType <: CustomType & Equatable<EnumType>
```

Function: Instantiated type of the enum; `get(def, genericTypeParams)` caches a unique instance.

Parent Types:

- [CustomType](#class-customtype)
- Equatable\<[EnumType](#class-enumtype)>

### prop enumDef

```cangjie
public prop enumDef: EnumDef
```

Function: The corresponding [EnumDef](#class-enumdef).

Type: [EnumDef](#class-enumdef)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addEnum("E_m", "E", true)
    let t = EnumType.get(d, [])
    println(t.enumDef.srcCodeName)
}
```

Output:

```text
E
```

### static func get(EnumDef, Array\<Type>)

```cangjie
public static func get(def: EnumDef, genericTypeParams: Array<Type>): EnumType
```

Function: Gets or creates the cached instance from the enum definition and generic arguments.

Parameters:

- def: EnumDef - Enum definition.
- genericTypeParams: Array\<Type> - Generic type arguments.

Return Value:

- EnumType - Instantiated enum type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addEnum("E_m", "E", true)
    let t = EnumType.get(d, [])
    println(t.enumDef.srcCodeName)
}
```

Output:

```text
E
```

### operator func==(EnumType)

```cangjie
public operator func==(other: EnumType): Bool
```

Function: Compares whether two instantiated enum types are the same.

Parameters:

- other: EnumType - The other enum type.

Return Value:

- Bool - Whether they are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let d = pkg.addEnum("E_m", "E", true)
    let t1 = EnumType.get(d, [])
    let t2 = EnumType.get(d, [])
    println("op_eq_EnumType: ${t1 == t2}")
}
```

Output:

```text
op_eq_EnumType: true
```

---

## class ExtendDef

```cangjie
public class ExtendDef <: CustomTypeDef
```

Function: **Extension (extend)** definition: adds implementation for a type, with `extendedType` and generic parameters.

Parent Types:

- [CustomTypeDef](#class-customtypedef)

### prop extendedType

```cangjie
public prop extendedType: Type
```

Function: The type being extended (`T` in `extend T { ... }`).

Type: [Type](#class-type)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let ext = pkg.addExtend("ext_m", IntType.getInt32())
    println(ext.extendedType.toString())
}
```

Output:

```text
Int32
```

---

## class FloatType

```cangjie
public class FloatType <: NumericType & Equatable<FloatType>
```

Function: Represents a floating-point type in the type system. This class represents Float16, Float32, and Float64.

Parent Types:

- [NumericType](#class-numerictype)
- Equatable\<[FloatType](#class-floattype)>

### static func getFloat16()

```cangjie
public static func getFloat16(): FloatType
```

Function: Gets the Float16 type instance.

Return Value:

- FloatType - Float16 type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let float16Type = FloatType.getFloat16()
    println("Float16 type: ${float16Type.toString()}")
}
```

Output:

```text
Float16 type: Float16
```

### static func getFloat32()

```cangjie
public static func getFloat32(): FloatType
```

Function: Gets the Float32 type instance.

Return Value:

- FloatType - Float32 type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let float32Type = FloatType.getFloat32()
    println("Float32 type: ${float32Type.toString()}")
}
```

Output:

```text
Float32 type: Float32
```

### static func getFloat64()

```cangjie
public static func getFloat64(): FloatType
```

Function: Gets the Float64 type instance.

Return Value:

- FloatType - Float64 type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let float64Type = FloatType.getFloat64()
    println("Float64 type: ${float64Type.toString()}")
}
```

Output:

```text
Float64 type: Float64
```

### operator func==(FloatType)

```cangjie
public operator func==(other: FloatType): Bool
```

Function: Checks whether this FloatType equals another FloatType.

Parameters:

- other: FloatType - The FloatType to compare with.

Return Value:

- Bool - Returns true if the types are equal, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let float32Type1 = FloatType.getFloat32()
    let float32Type2 = FloatType.getFloat32()
    let float64Type = FloatType.getFloat64()
    println("Two Float32 instances are equal: ${float32Type1 == float32Type2}")
    println("Float32 and Float64 are equal: ${float32Type1 == float64Type}")
}
```

Output:

```text
Two Float32 instances are equal: true
Float32 and Float64 are equal: false
```

## class FuncType

```cangjie
public class FuncType <: Type & Equatable<FuncType>
```

Function: Function type (parameter type list + return type), optional varargs and C function flag; cached by signature.

Parent Types:

- [Type](#class-type)
- Equatable\<[FuncType](#class-functype)>

### prop hasVarArg

```cangjie
public prop hasVarArg: Bool
```

Function: Whether this is a varargs function type.

Type: Bool

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let i32 = IntType.getInt32()
    let f = FuncType.get([i32], i32)
    println(f.hasVarArg)
}
```

Output:

```text
false
```

### prop isCFunc

```cangjie
public prop isCFunc: Bool
```

Function: Whether this denotes a C function type (affects `toString()` prefix `CFunc<...>`).

Type: Bool

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let i32 = IntType.getInt32()
    let f = FuncType.get([i32], i32)
    println(f.isCFunc)
}
```

Output:

```text
false
```

### prop paramTypes

```cangjie
public prop paramTypes: Array<Type>
```

Function: Array of formal parameter types.

Type: Array\<Type>

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let i32 = IntType.getInt32()
    let f = FuncType.get([i32], i32)
    println("${f.paramTypes.size}")
}
```

Output:

```text
1
```

### prop returnType

```cangjie
public prop returnType: Type
```

Function: Return type.

Type: Type

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let i32 = IntType.getInt32()
    let f = FuncType.get([i32], i32)
    println(f.returnType.toString())
}
```

Output:

```text
Int32
```

### static func get(Array\<Type>, Type, Bool, Bool)

```cangjie
public static func get(paramTypes: Array<Type>, retType: Type, varArg!: Bool = false, cFunc!: Bool = false): FuncType
```

Function: Gets or creates the uniquely cached instance from parameter list, return type, and varargs/C flag.

Parameters:

- paramTypes: Array\<Type> - Formal parameter type sequence.
- retType: Type - Return type.
- varArg! - Whether this is a varargs function type; default `false`.
- cFunc! - Whether this is in `CFunc<...>` form; default `false`.

Return Value:

- FuncType - Function type instance.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let i32 = IntType.getInt32()
    let f = FuncType.get([i32], i32)
    println(f.toString())
}
```

Output:

```text
(Int32) -> Int32
```

### func toString()

```cangjie
public func toString(): String
```

Function: String like `(T1, T2) -> R` or `CFunc<(T1)-> R>` (see source).

Return Value:

- String - Function type text.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let u = IntType.getUInt32()
    let f = FuncType.get([u], UnitType.get())
    println(f.toString())
}
```

Output:

```text
(UInt32) -> Unit
```

### operator func==(FuncType)

```cangjie
public operator func==(other: FuncType): Bool
```

Function: Compares whether signature, `varArg`, and `cFunc` match.

Parameters:

- other: FuncType - The other function type.

Return Value:

- Bool - Whether they are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let i32 = IntType.getInt32()
    let f1 = FuncType.get([i32], i32)
    let f2 = FuncType.get([i32], i32)
    println("op_eq_FuncType: ${f1 == f2}")
}
```

Output:

```text
op_eq_FuncType: true
```

---

## class GenericType

```cangjie
public class GenericType <: Type & Equatable<GenericType>
```

Function: Generic **type parameter** (e.g. `T`), optional `upperBounds`; cached by internal `identifier`.

Parent Types:

- [Type](#class-type)
- Equatable\<[GenericType](#class-generictype)>

### prop srcCodeName

```cangjie
public prop srcCodeName: String
```

Function: Generic parameter name in source (e.g. `T`).

Type: String

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = GenericType.get("g:T", "T")
    println(t.srcCodeName)
}
```

Output:

```text
T
```

### prop upperBounds

```cangjie
public mut prop upperBounds: Array<Type>
```

Function: Upper bound type list; assignment rejects **value type** upper bounds (see source validation).

Type: Array\<Type>

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = GenericType.get("g:T", "T")
    println("${t.upperBounds.size}")
}
```

Output:

```text
0
```

### static func get(String, String)

```cangjie
public static func get(identifier: String, srcCodeName: String): GenericType
```

Function: Gets or creates the generic parameter type cached by internal `identifier` (e.g. `T`).

Parameters:

- identifier: String - Internal unique key (for mangling).
- srcCodeName: String - Parameter name in source.

Return Value:

- GenericType - Generic parameter type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = GenericType.get("g:T", "T")
    println("static_get: ${t.toString().size > 0}")
}
```

Output:

```text
static_get: true
```

### func toString()

```cangjie
public func toString(): String
```

Function: Internal debug string (includes kind and identifier).

Return Value:

- String - Textual form.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = GenericType.get("g:U", "U")
    println("fn_toString: ${t.toString().size > 0}")
}
```

Output:

```text
fn_toString: true
```

### operator func==(GenericType)

```cangjie
public operator func==(other: GenericType): Bool
```

Function: Compares whether two generic parameter nodes are the same.

Parameters:

- other: GenericType - The other generic parameter.

Return Value:

- Bool - Whether they are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t1 = GenericType.get("g:T", "T")
    let t2 = GenericType.get("g:T", "T")
    println("op_eq_GenericType: ${t1 == t2}")
}
```

Output:

```text
op_eq_GenericType: true
```

---

## class IntType

```cangjie
public class IntType <: NumericType & Equatable<IntType>
```

Function: Represents an integer type in the type system. This class represents signed and unsigned integer types of various sizes.

Parent Types:

- [NumericType](#class-numerictype)
- Equatable\<[IntType](#class-inttype)>

### static func getInt16()

```cangjie
public static func getInt16(): IntType
```

Function: Gets the Int16 type instance.

Return Value:

- IntType - Int16 type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let int16Type = IntType.getInt16()
    println("Int16 type: ${int16Type.toString()}")
}
```

Output:

```text
Int16 type: Int16
```

### static func getInt32()

```cangjie
public static func getInt32(): IntType
```

Function: Gets the Int32 type instance.

Return Value:

- IntType - Int32 type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let int32Type = IntType.getInt32()
    println("Int32 type: ${int32Type.toString()}")
}
```

Output:

```text
Int32 type: Int32
```

### static func getInt64()

```cangjie
public static func getInt64(): IntType
```

Function: Gets the Int64 type instance.

Return Value:

- IntType - Int64 type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let int64Type = IntType.getInt64()
    println("Int64 type: ${int64Type.toString()}")
}
```

Output:

```text
Int64 type: Int64
```

### static func getInt8()

```cangjie
public static func getInt8(): IntType
```

Function: Gets the Int8 type instance.

Return Value:

- IntType - Int8 type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let int8Type = IntType.getInt8()
    println("Int8 type: ${int8Type.toString()}")
}
```

Output:

```text
Int8 type: Int8
```

### static func getIntNative()

```cangjie
public static func getIntNative(): IntType
```

Function: Gets the IntNative type instance.

Return Value:

- IntType - IntNative type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intNativeType = IntType.getIntNative()
    println("IntNative type: ${intNativeType.toString()}")
}
```

Output:

```text
IntNative type: IntNative
```

### static func getUInt16()

```cangjie
public static func getUInt16(): IntType
```

Function: Gets the UInt16 type instance.

Return Value:

- IntType - UInt16 type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let uint16Type = IntType.getUInt16()
    println("UInt16 type: ${uint16Type.toString()}")
}
```

Output:

```text
UInt16 type: UInt16
```

### static func getUInt32()

```cangjie
public static func getUInt32(): IntType
```

Function: Gets the UInt32 type instance.

Return Value:

- IntType - UInt32 type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let uint32Type = IntType.getUInt32()
    println("UInt32 type: ${uint32Type.toString()}")
}
```

Output:

```text
UInt32 type: UInt32
```

### static func getUInt64()

```cangjie
public static func getUInt64(): IntType
```

Function: Gets the UInt64 type instance.

Return Value:

- IntType - UInt64 type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let uint64Type = IntType.getUInt64()
    println("UInt64 type: ${uint64Type.toString()}")
}
```

Output:

```text
UInt64 type: UInt64
```

### static func getUInt8()

```cangjie
public static func getUInt8(): IntType
```

Function: Gets the UInt8 type instance.

Return Value:

- IntType - UInt8 type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let uint8Type = IntType.getUInt8()
    println("UInt8 type: ${uint8Type.toString()}")
}
```

Output:

```text
UInt8 type: UInt8
```

### static func getUIntNative()

```cangjie
public static func getUIntNative(): IntType
```

Function: Gets the UIntNative type instance.

Return Value:

- IntType - UIntNative type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let uintNativeType = IntType.getUIntNative()
    println("UIntNative type: ${uintNativeType.toString()}")
}
```

Output:

```text
UIntNative type: UIntNative
```

### operator func==(IntType)

```cangjie
public operator func==(other: IntType): Bool
```

Function: Checks whether this IntType equals another IntType.

Parameters:

- other: IntType - The IntType to compare with.

Return Value:

- Bool - Returns true if the types are equal, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let int32Type1 = IntType.getInt32()
    let int32Type2 = IntType.getInt32()
    let int64Type = IntType.getInt64()
    println("Two Int32 instances are equal: ${int32Type1 == int32Type2}")
    println("Int32 and Int64 are equal: ${int32Type1 == int64Type}")
}
```

Output:

```text
Two Int32 instances are equal: true
Int32 and Int64 are equal: false
```

### func isSigned()

```cangjie
public func isSigned(): Bool
```

Function: Checks whether this integer type is signed.

Return Value:

- Bool - Returns true if the type is signed, false if unsigned.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let int32Type = IntType.getInt32()
    let uint32Type = IntType.getUInt32()
    println("Int32 is signed: ${int32Type.isSigned()}")
    println("UInt32 is signed: ${uint32Type.isSigned()}")
}
```

Output:

```text
Int32 is signed: true
UInt32 is signed: false
```

## class MemberVar

```cangjie
public class MemberVar <: ToString
```

Function: Describes an **instance member variable** on a custom type (name, type, debug location, annotations, access modifiers, etc.).

Parent Types:

- ToString

### prop name

```cangjie
public prop name: String
```

Function: Member source name.

Type: String

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.name)
}
```

Output:

```text
x
```

### prop ty

```cangjie
public prop ty: Type
```

Function: Member type.

Type: [Type](#class-type)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.ty.toString())
}
```

Output:

```text
Int32
```

### prop location

```cangjie
public prop location: DebugLocation
```

Function: Source location; may be an invalid range when unset (see [DebugLocation](#class-debuglocation)).

Type: [DebugLocation](#class-debuglocation)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.location.isValid())
}
```

Output:

```text
false
```

### prop annotations

```cangjie
public mut prop annotations: Array<Annotation>
```

Function: List of annotation instances on the member (stored internally as `AnnoInfo`, exposed as `Array<Annotation>`); `set` replaces the whole list.

Type: Array\<[Annotation](#class-annotation)>

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println("${mv.annotations.size}")
}
```

Output:

```text
0
```

### prop outerDef

```cangjie
public prop outerDef: CustomTypeDef
```

Function: The outer type definition that contains this member.

Type: [CustomTypeDef](#class-customtypedef)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.outerDef.srcCodeName)
}
```

Output:

```text
S
```

### func setReadOnly(Bool)

```cangjie
public func setReadOnly(enable: Bool): Unit
```

Function: Sets or clears the read-only (`let`) flag.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    mv.setReadOnly(true)
    println("fn_setReadOnly: ${mv.isReadOnly()}")
}
```

Output:

```text
fn_setReadOnly: true
```

### func setInternal()

```cangjie
public func setInternal(): Unit
```

Function: Marks the member as `internal`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    mv.setInternal()
    println("fn_setInternal: ${mv.isInternal()}")
}
```

Output:

```text
fn_setInternal: true
```

### func setPublic()

```cangjie
public func setPublic(): Unit
```

Function: Marks the member as `public`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    mv.setPublic()
    println("fn_setPublic: ${mv.isPublic()}")
}
```

Output:

```text
fn_setPublic: true
```

### func setPrivate()

```cangjie
public func setPrivate(): Unit
```

Function: Marks the member as `private`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    mv.setPrivate()
    println("fn_setPrivate: ${mv.isPrivate()}")
}
```

Output:

```text
fn_setPrivate: true
```

### func setProtected()

```cangjie
public func setProtected(): Unit
```

Function: Marks the member as `protected`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    mv.setProtected()
    println("fn_setProtected: ${mv.isProtected()}")
}
```

Output:

```text
fn_setProtected: true
```

### func isReadOnly()

```cangjie
public func isReadOnly(): Bool
```

Function: Whether this is a read-only member.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.isReadOnly())
}
```

Output:

```text
false
```

### func isInternal()

```cangjie
public func isInternal(): Bool
```

Function: Whether this is `internal`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.isInternal())
}
```

Output:

```text
false
```

### func isPublic()

```cangjie
public func isPublic(): Bool
```

Function: Whether this is `public`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.isPublic())
}
```

Output:

```text
false
```

### func isPrivate()

```cangjie
public func isPrivate(): Bool
```

Function: Whether this is `private`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.isPrivate())
}
```

Output:

```text
false
```

### func isProtected()

```cangjie
public func isProtected(): Bool
```

Function: Whether this is `protected`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println(mv.isProtected())
}
```

Output:

```text
false
```

### func toString()

```cangjie
public func toString(): String
```

Function: Attribute prefix + `let`/`var`, name, type, and location comments.

Return Value:

- String - Single-line member description.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    println("fn_toString: ${mv.toString().size > 0}")
}
```

Output:

```text
fn_toString: true
```

### func dump()

```cangjie
public func dump(): Unit
```

Function: Prints `toString()`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("p", AccessLevel.Public)
    let st = pkg.addStruct("S_m", "S")
    let mv = st.appendInstanceMemberVar("x", IntType.getInt32())
    mv.dump()
}
```

Output:

```text
var x: Int32
```

## class NothingType

```cangjie
public class NothingType <: BuiltinType & Equatable<NothingType>
```

Function: Represents the Nothing type (bottom type) in the type system. Used for expressions that never return.

Parent Types:

- [BuiltinType](#class-builtintype)
- Equatable\<[NothingType](#class-nothingtype)>

### static func get()

```cangjie
public static func get(): NothingType
```

Function: Gets the singleton instance of NothingType.

Return Value:

- NothingType - NothingType instance.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let nothingType = NothingType.get()
    println("Nothing type: ${nothingType.toString()}")
}
```

Output:

```text
Nothing type: Nothing
```

### operator func==(NothingType)

```cangjie
public operator func==(_: NothingType): Bool
```

Function: Checks whether this NothingType equals another NothingType.

Parameters:

- _: NothingType - The other NothingType to compare with (unused; always returns true).

Return Value:

- Bool - Always returns true because all NothingType instances are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let nothingType1 = NothingType.get()
    let nothingType2 = NothingType.get()
    println("Two NothingType instances are equal: ${nothingType1 == nothingType2}")
}
```

Output:

```text
Two NothingType instances are equal: true
```

## class NumericType

```cangjie
sealed abstract class NumericType <: BuiltinType & Equatable<NumericType>
```

Function: Abstract base class for numeric types. Represents numeric types, including integer and floating-point types.

Parent Types:

- [BuiltinType](#class-builtintype)
- Equatable\<[NumericType](#class-numerictype)>

### operator func==(NumericType)

```cangjie
public operator func==(other: NumericType): Bool
```

Function: Checks whether this numeric type equals another numeric type.

Parameters:

- other: NumericType - The numeric type to compare with.

Return Value:

- Bool - Returns true if the types are equal, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType1 = IntType.getInt32()
    let intType2 = IntType.getInt32()
    let floatType = FloatType.getFloat32()
    println("Two Int32 instances are equal: ${intType1 == intType2}")
    println("Int32 and Float32 are equal: ${intType1 == floatType}")
}
```

Output:

```text
Two Int32 instances are equal: true
Int32 and Float32 are equal: false
```

## class Package

```cangjie
public class Package <: ToString
```

Function: Represents a **CHIR package**: name, access level, imports, and type definitions declared in this package.

Parent Types:

- ToString

### prop name

```cangjie
public prop name: String
```

Function: Logical package name.

Type: String

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    println(pkg.name)
}
```

Output:

```text
demo
```

### prop accessLevel

```cangjie
public prop accessLevel: AccessLevel
```

Function: Package access level.

Type: [AccessLevel](chir_package_enums.md#enum-accesslevel)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    println("prop_accessLevel: ${pkg.accessLevel == AccessLevel.Public}")
}
```

Output:

```text
prop_accessLevel: true
```

### prop importedClassDefs

```cangjie
public prop importedClassDefs: Array<ClassLikeDef>
```

Function: Snapshot of class/interface definitions imported from other packages.

Type: Array\<[ClassLikeDef](#class-classlikedef)>

### prop importedEnumDefs

```cangjie
public prop importedEnumDefs: Array<EnumDef>
```

Function: Imported enum definitions.

Type: Array\<[EnumDef](#class-enumdef)>

### prop importedStructDefs

```cangjie
public prop importedStructDefs: Array<StructDef>
```

Function: Imported struct definitions.

Type: Array\<[StructDef](#class-structdef)>

### prop importedExtendDefs

```cangjie
public prop importedExtendDefs: Array<ExtendDef>
```

Function: Imported extend definitions.

Type: Array\<[ExtendDef](#class-extenddef)>

### prop classDefs

```cangjie
public prop classDefs: Array<ClassLikeDef>
```

Function: Class/interface definitions declared in this package.

Type: Array\<[ClassLikeDef](#class-classlikedef)>

### prop enumDefs

```cangjie
public prop enumDefs: Array<EnumDef>
```

Function: Enum definitions declared in this package.

Type: Array\<[EnumDef](#class-enumdef)>

### prop structDefs

```cangjie
public prop structDefs: Array<StructDef>
```

Function: Struct definitions declared in this package.

Type: Array\<[StructDef](#class-structdef)>

### prop extendDefs

```cangjie
public prop extendDefs: Array<ExtendDef>
```

Function: Extend definitions declared in this package.

Type: Array\<[ExtendDef](#class-extenddef)>

### init(String, AccessLevel)

```cangjie
public init(name: String, accessLevel: AccessLevel)
```

Function: Creates an empty package with the given logical name and [AccessLevel](chir_package_enums.md#enum-accesslevel).

Parameters:

- name: String - Package name.
- accessLevel: AccessLevel - Package access level.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    println(pkg.name)
}
```

Output:

```text
demo
```

### func addClass(String, String, Bool, Array\<GenericType>)

```cangjie
public func addClass(identifier: String, srcCodeName: String, isClass: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ClassLikeDef
```

Function: Creates a new class or interface definition in this package and adds it to `classDefs`.

Return Value:

- [ClassLikeDef](#class-classlikedef) - New definition.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addClass("C_m", "C", true)
    println("${pkg.classDefs.size}")
    println(d.srcCodeName)
}
```

Output:

```text
1
C
```

### func addImportedClass(String, String, String, Bool, Array\<GenericType>)

```cangjie
public func addImportedClass(identifier: String, srcCodeName: String, packageName: String, isClass: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ClassLikeDef
```

Function: Registers an imported class/interface definition (with `Imported` flag).

Return Value:

- [ClassLikeDef](#class-classlikedef) - New definition.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addImportedClass("I_m", "I", "other", true)
    println("fn_addImportedClass importedCount: ${pkg.importedClassDefs.size}")
    println("fn_addImportedClass isImported: ${d.isImported()}")
}
```

Output:

```text
fn_addImportedClass importedCount: 1
fn_addImportedClass isImported: true
```

### func addStruct(String, String, Array\<GenericType>)

```cangjie
public func addStruct(identifier: String, srcCodeName: String, genericTypeParams!: Array<GenericType> = Array<GenericType>()): StructDef
```

Function: Creates a new struct definition in this package.

Return Value:

- [StructDef](#class-structdef) - New definition.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addStruct("S_m", "S")
    println("${pkg.structDefs.size}")
    println(d.srcCodeName)
}
```

Output:

```text
1
S
```

### func addImportedStruct(String, String, String, Array\<GenericType>)

```cangjie
public func addImportedStruct(identifier: String, srcCodeName: String, packageName: String, genericTypeParams!: Array<GenericType> = Array<GenericType>()): StructDef
```

Function: Registers an imported struct definition.

Return Value:

- [StructDef](#class-structdef) - New definition.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addImportedStruct("IS_m", "IS", "other")
    println("${pkg.importedStructDefs.size}")
    println(d.srcCodeName)
}
```

Output:

```text
1
IS
```

### func addEnum(String, String, Bool, Array\<GenericType>)

```cangjie
public func addEnum(identifier: String, srcCodeName: String, isExhaustive: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): EnumDef
```

Function: Creates a new enum definition in this package.

Return Value:

- [EnumDef](#class-enumdef) - New definition.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addEnum("E_m", "E", true)
    println("${pkg.enumDefs.size}")
    println(d.srcCodeName)
}
```

Output:

```text
1
E
```

### func addImportedEnum(String, String, String, Bool, Array\<GenericType>)

```cangjie
public func addImportedEnum(identifier: String, srcCodeName: String, packageName: String, isExhaustive: Bool, genericTypeParams!: Array<GenericType> = Array<GenericType>()): EnumDef
```

Function: Registers an imported enum definition.

Return Value:

- [EnumDef](#class-enumdef) - New definition.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addImportedEnum("IE_m", "IE", "other", true)
    println("${pkg.importedEnumDefs.size}")
    println(d.srcCodeName)
}
```

Output:

```text
1
IE
```

### func addExtend(String, Type, Array\<GenericType>)

```cangjie
public func addExtend(identifier: String, extendedType: Type, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ExtendDef
```

Function: Creates a new extend definition in this package.

Return Value:

- [ExtendDef](#class-extenddef) - New definition.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addExtend("ext_m", IntType.getInt32())
    println("${pkg.extendDefs.size}")
    println(d.extendedType.toString())
}
```

Output:

```text
1
Int32
```

### func addImportedExtend(String, String, Type, Array\<GenericType>)

```cangjie
public func addImportedExtend(identifier: String, packageName: String, extendedType: Type, genericTypeParams!: Array<GenericType> = Array<GenericType>()): ExtendDef
```

Function: Registers an imported extend definition.

Return Value:

- [ExtendDef](#class-extenddef) - New definition.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let d = pkg.addImportedExtend("iext_m", "other", IntType.getInt32())
    println("${pkg.importedExtendDefs.size}")
    println(d.extendedType.toString())
}
```

Output:

```text
1
Int32
```

### func getSpecifiedClassDef(String, String)

```cangjie
public func getSpecifiedClassDef(packageName: String, srcCodeName: String): ?ClassLikeDef
```

Function: Looks up a class/interface definition by declared package name + source type name among imports and local `classDefs`.

Return Value:

- ?ClassLikeDef - `Some` if found, otherwise `None`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let _ = pkg.addImportedClass("I_m", "I", "other", true)
    let r = pkg.getSpecifiedClassDef("other", "I")
    println("fn_getSpecifiedClassDef: ${r.isSome()}")
}
```

Output:

```text
fn_getSpecifiedClassDef: true
```

### func getSpecifiedStructDef(String, String)

```cangjie
public func getSpecifiedStructDef(packageName: String, srcCodeName: String): ?StructDef
```

Function: Same as above, for struct definitions.

Return Value:

- ?StructDef - Optional result.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let _ = pkg.addImportedStruct("IS_m", "IS", "other")
    let r = pkg.getSpecifiedStructDef("other", "IS")
    println("fn_getSpecifiedStructDef: ${r.isSome()}")
}
```

Output:

```text
fn_getSpecifiedStructDef: true
```

### func getSpecifiedEnumDef(String, String)

```cangjie
public func getSpecifiedEnumDef(packageName: String, srcCodeName: String): ?EnumDef
```

Function: Same as above, for enum definitions.

Return Value:

- ?EnumDef - Optional result.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let _ = pkg.addImportedEnum("IE_m", "IE", "other", true)
    let r = pkg.getSpecifiedEnumDef("other", "IE")
    println("fn_getSpecifiedEnumDef: ${r.isSome()}")
}
```

Output:

```text
fn_getSpecifiedEnumDef: true
```

### func toString()

```cangjie
public func toString(): String
```

Function: Concatenated text of package name, access level, import section, and local type section (for debugging).

Return Value:

- String - Full package description.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("my.pkg", AccessLevel.Public)
    let _ = pkg.addClass("C1", "C", true)
    println("fn_toString: ${pkg.toString().size > 0}")
}
```

Output:

```text
fn_toString: true
```

### func dump()

```cangjie
public func dump(): Unit
```

Function: Prints `toString()` to standard output.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("my.pkg", AccessLevel.Public)
    let _ = pkg.addClass("C1", "C", true)
    pkg.dump()
}
```

Output:

```text
package: my.pkg
packageAccessLevel: public

==========================imports===============================


==========================types=================================

[pluginAdded]class @C1 { // srcCodeName: C, packageName: my.pkg
}
```

---

## class RawArrayType

```cangjie
public class RawArrayType <: BuiltinType & Equatable<RawArrayType>
```

Function: **Raw array** type with element type and dimension count `dims`. Cached uniquely by `(elementType, dims)`.

Parent Types:

- [BuiltinType](#class-builtintype)
- Equatable\<[RawArrayType](#class-rawarraytype)>

### prop elementType

```cangjie
public prop elementType: Type
```

Function: Array element type.

Type: Type

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = RawArrayType.get(IntType.getUInt32(), 1)
    println(t.elementType.toString())
}
```

Output:

```text
UInt32
```

### prop dims

```cangjie
public prop dims: UInt32
```

Function: Raw array dimension count.

Type: UInt32

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = RawArrayType.get(IntType.getInt32(), 3)
    println("${t.dims}")
}
```

Output:

```text
3
```

### static func get(Type, UInt32)

```cangjie
public static func get(elementType: Type, dims: UInt32): RawArrayType
```

Function: Gets or creates a raw array type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = RawArrayType.get(IntType.getInt32(), 2)
    println("static_get: ${t.toString().size > 0}")
}
```

Output:

```text
static_get: true
```

### func toString()

```cangjie
public func toString(): String
```

Function: String form of the type (e.g. multi-dimensional `[[[T]]]` style; see source).

Return Value:

- String - Text representation.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t = RawArrayType.get(IntType.getInt32(), 2)
    println(t.toString())
}
```

Output:

```text
RawArray<RawArray<Int32>>
```

### operator func==(RawArrayType)

```cangjie
public operator func==(other: RawArrayType): Bool
```

Function: Compares whether element type and dimension count match.

Parameters:

- other: RawArrayType - The other raw array type.

Return Value:

- Bool - Whether they are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t1 = RawArrayType.get(IntType.getInt32(), 2)
    let t2 = RawArrayType.get(IntType.getInt32(), 2)
    println("op_eq_RawArrayType: ${t1 == t2}")
}
```

Output:

```text
op_eq_RawArrayType: true
```

---

## class RefType

```cangjie
public class RefType <: Type & Equatable<RefType>
```

Function: Represents a reference type in the type system. Wraps another type to denote a reference to it. The class caches all reference types to ensure uniqueness.

Parent Types:

- [Type](#class-type)
- Equatable\<[RefType](#class-reftype)>

### prop baseType

```cangjie
public prop baseType: Type
```

Function: Gets the base type that this reference type refers to.

Return Value:

- Type - Base type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let refType = RefType.get(intType)
    println(refType.baseType.toString())
}
```

Output:

```text
Int32
```

### static func get(Type)

```cangjie
public static func get(baseType: Type): RefType
```

Function: Gets or creates the RefType for the given base type.

This method ensures there is at most one RefType instance per base type.

Parameters:

- baseType: Type - The base type to reference.

Return Value:

- RefType - RefType instance for the given base type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let refType = RefType.get(intType)
    println(refType.toString())
}
```

Output:

```text
Int32&
```

### func toString()

```cangjie
public func toString(): String
```

Function: Converts this RefType to a string representation.

Return Value:

- String - String form of the reference type (base type followed by `&`).

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let refType = RefType.get(IntType.getUInt32())
    println(refType.toString())
}
```

Output:

```text
UInt32&
```

### operator func==(RefType)

```cangjie
public operator func==(other: RefType): Bool
```

Function: Checks whether this RefType equals another RefType.

Parameters:

- other: RefType - The RefType to compare with.

Return Value:

- Bool - Returns true if the types are equal, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let refType1 = RefType.get(intType)
    let refType2 = RefType.get(intType)
    println("op_eq_RefType: ${refType1 == refType2}")
}
```

Output:

```text
op_eq_RefType: true
```

## class RuneType

```cangjie
public class RuneType <: BuiltinType & Equatable<RuneType>
```

Function: Represents the Rune type in the type system. This type represents a character type.

Parent Types:

- [BuiltinType](#class-builtintype)
- Equatable\<[RuneType](#class-runetype)>

### static func get()

```cangjie
public static func get(): RuneType
```

Function: Gets the singleton instance of RuneType.

Return Value:

- RuneType - RuneType instance.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let runeType = RuneType.get()
    println("Rune type: ${runeType.toString()}")
}
```

Output:

```text
Rune type: Rune
```

### operator func==(RuneType)

```cangjie
public operator func==(_: RuneType): Bool
```

Function: Checks whether this RuneType equals another RuneType.

Parameters:

- _: RuneType - The other RuneType to compare with (unused; always returns true).

Return Value:

- Bool - Always returns true because all RuneType instances are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let runeType1 = RuneType.get()
    let runeType2 = RuneType.get()
    println("Two RuneType instances are equal: ${runeType1 == runeType2}")
}
```

Output:

```text
Two RuneType instances are equal: true
```

## class StructDef

```cangjie
public class StructDef <: CustomTypeDef & Equatable<StructDef>
```

Function: **Struct** definition; `isCStruct` marks C-interop structs.

Parent Types:

- [CustomTypeDef](#class-customtypedef)
- Equatable\<[StructDef](#class-structdef)>

### prop structType

```cangjie
public prop structType: StructType
```

Function: The instantiated [StructType](#class-structtype) corresponding to this definition.

Type: [StructType](#class-structtype)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let s = pkg.addStruct("S_m", "S")
    println("prop_structType: ${s.structType.structDef == s}")
}
```

Output:

```text
prop_structType: true
```

### prop isCStruct

```cangjie
public mut prop isCStruct: Bool
```

Function: Whether this is marked as a C-interop struct.

Type: Bool

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let s = pkg.addStruct("S_m", "S")
    s.isCStruct = true
    println("mut_prop_isCStruct: ${s.isCStruct}")
}
```

Output:

```text
mut_prop_isCStruct: true
```

### operator func==(StructDef)

```cangjie
public operator func==(other: StructDef): Bool
```

Function: Compares whether two struct definitions are the same.

Parameters:

- other: StructDef - The other struct definition.

Return Value:

- Bool - Whether they are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let s = pkg.addStruct("S_m", "S")
    println("op_eq_StructDef: ${s == s}")
}
```

Output:

```text
op_eq_StructDef: true
```

---

## class StructType

```cangjie
public class StructType <: CustomType & Equatable<StructType>
```

Function: Instantiated type of the struct; `get(def, genericTypeParams)` caches a unique instance.

Parent Types:

- [CustomType](#class-customtype)
- Equatable\<[StructType](#class-structtype)>

### prop structDef

```cangjie
public prop structDef: StructDef
```

Function: The corresponding [StructDef](#class-structdef).

Type: [StructDef](#class-structdef)

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addStruct("S_m", "S")
    let st = StructType.get(def, [])
    println(st.structDef.srcCodeName)
}
```

Output:

```text
S
```

### static func get(StructDef, Array\<Type>)

```cangjie
public static func get(def: StructDef, genericTypeParams: Array<Type>): StructType
```

Function: Gets or creates the cached instance from the struct definition and generic arguments.

Parameters:

- def: StructDef - Struct definition.
- genericTypeParams: Array\<Type> - Generic type arguments.

Return Value:

- StructType - Instantiated struct type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addStruct("S_m", "S")
    let st = StructType.get(def, [])
    println(st.structDef.srcCodeName)
}
```

Output:

```text
S
```

### operator func==(StructType)

```cangjie
public operator func==(other: StructType): Bool
```

Function: Compares whether two instantiated struct types are the same.

Parameters:

- other: StructType - The other struct type.

Return Value:

- Bool - Whether they are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let pkg = Package("demo", AccessLevel.Public)
    let def = pkg.addStruct("S_m", "S")
    let st1 = StructType.get(def, [])
    let st2 = StructType.get(def, [])
    println("op_eq_StructType: ${st1 == st2}")
}
```

Output:

```text
op_eq_StructType: true
```

---

## class ThisType

```cangjie
public class ThisType <: Type & Equatable<ThisType>
```

Function: The **`This`** type inside a class/struct body; singleton.

Parent Types:

- [Type](#class-type)
- Equatable\<[ThisType](#class-thistype)>

### static func get()

```cangjie
public static func get(): ThisType
```

Function: Returns the unique singleton of `This` type.

Return Value:

- ThisType - Singleton.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    println("static_get: ${ThisType.get().toString().size > 0}")
}
```

Output:

```text
static_get: true
```

### operator func==(ThisType)

```cangjie
public operator func==(_: ThisType): Bool
```

Function: Compares with another `ThisType` (singleton identity).

Parameters:

- _: ThisType - The other instance.

Return Value:

- Bool - Always `true`.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let t1 = ThisType.get()
    let t2 = ThisType.get()
    println("op_eq_ThisType: ${t1 == t2}")
}
```

Output:

```text
op_eq_ThisType: true
```

---

## class TupleType

```cangjie
public class TupleType <: Type & Equatable<TupleType>
```

Function: Tuple type; cached uniquely by element type sequence signature.

Parent Types:

- [Type](#class-type)
- Equatable\<[TupleType](#class-tupletype)>

### prop elementTypes

```cangjie
public prop elementTypes: Array<Type>
```

Function: Types at each tuple position.

Type: Array\<Type>

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let u = UnitType.get()
    let tup = TupleType.get([IntType.getInt32(), u])
    println("${tup.elementTypes.size}")
}
```

Output:

```text
2
```

### static func get(Array\<Type>)

```cangjie
public static func get(elementTypes: Array<Type>): TupleType
```

Function: Gets or creates the unique tuple type for the given element type sequence.

Parameters:

- elementTypes: Array\<Type> - Element types from left to right.

Return Value:

- TupleType - Tuple type instance.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let tup = TupleType.get([IntType.getInt32()])
    println("${tup.elementTypes.size}")
}
```

Output:

```text
1
```

### func toString()

```cangjie
public func toString(): String
```

Function: String representation of the tuple type.

Return Value:

- String - Textual form.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let tup = TupleType.get([IntType.getUInt32()])
    println(tup.toString())
}
```

Output:

```text
Tuple(UInt32)
```

### operator func==(TupleType)

```cangjie
public operator func==(other: TupleType): Bool
```

Function: Compares whether two tuple types have the same element type sequence.

Parameters:

- other: TupleType - The other tuple type.

Return Value:

- Bool - Whether they are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let u = UnitType.get()
    let t1 = TupleType.get([IntType.getInt32(), u])
    let t2 = TupleType.get([IntType.getInt32(), u])
    println("op_eq_TupleType: ${t1 == t2}")
}
```

Output:

```text
op_eq_TupleType: true
```

---

## class Type

```cangjie
sealed abstract class Type <: ToString & Hashable & Equatable<Type>
```

Function: Abstract base class of all types in the type system. Provides equality, hashing, and string conversion.

Parent Types:

- ToString
- Hashable
- Equatable\<[Type](#class-type)>

### prop qualifiedName

```cangjie
public prop qualifiedName: String
```

Function: Qualified name of the type (for debugging and display; see `qualifiedName` `match` in source).

Type: String

### prop typeArgs

```cangjie
public prop typeArgs: Array<Type>
```

Function: Type parameter / subtype argument list for this type (depends on `TypeKind`).

Return Value:

- Array\<Type> - Type parameter array.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    println("Type argument count: ${intType.typeArgs.size}")
}
```

Output:

```text
Type argument count: 0
```

### func dump()

```cangjie
public func dump(): Unit
```

Function: Prints the string representation of the type to standard output.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    intType.dump()
}
```

Output:

```text
Int32
```

### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the hash code of this type.

Return Value:

- Int64 - Hash code of the type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    println("Hash code: ${intType.hashCode()}")
}
```

Output:

```text
Hash code: -7959616418923165251
```

### func isBoolType()

```cangjie
public func isBoolType(): Bool
```

Function: Checks whether this type is a boolean type.

Return Value:

- Bool - Returns true if the type is Bool, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let boolType = BoolType.get()
    let intType = IntType.getInt32()
    println("BoolType is boolean type: ${boolType.isBoolType()}")
    println("Int32 is boolean type: ${intType.isBoolType()}")
}
```

Output:

```text
BoolType is boolean type: true
Int32 is boolean type: false
```

### func isFloatType()

```cangjie
public func isFloatType(): Bool
```

Function: Checks whether this type is a floating-point type.

Return Value:

- Bool - Returns true if the type is Float16, Float32, or Float64, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let floatType = FloatType.getFloat32()
    let intType = IntType.getInt32()
    println("Float32 is float type: ${floatType.isFloatType()}")
    println("Int32 is float type: ${intType.isFloatType()}")
}
```

Output:

```text
Float32 is float type: true
Int32 is float type: false
```

### func isIntType()

```cangjie
public func isIntType(): Bool
```

Function: Checks whether this type is an integer type (signed or unsigned).

Return Value:

- Bool - Returns true if the type is any integer type, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let floatType = FloatType.getFloat32()
    println("Int32 is integer type: ${intType.isIntType()}")
    println("Float32 is integer type: ${floatType.isIntType()}")
}
```

Output:

```text
Int32 is integer type: true
Float32 is integer type: false
```

### func isNothingType()

```cangjie
public func isNothingType(): Bool
```

Function: Checks whether this type is the Nothing type.

Return Value:

- Bool - Returns true if the type is Nothing, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let nothingType = NothingType.get()
    let intType = IntType.getInt32()
    println("NothingType is Nothing type: ${nothingType.isNothingType()}")
    println("Int32 is Nothing type: ${intType.isNothingType()}")
}
```

Output:

```text
NothingType is Nothing type: true
Int32 is Nothing type: false
```

### func isNumericType()

```cangjie
public func isNumericType(): Bool
```

Function: Checks whether this type is a numeric type (integer or floating-point).

Return Value:

- Bool - Returns true if the type is numeric, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let floatType = FloatType.getFloat32()
    let boolType = BoolType.get()
    println("Int32 is numeric type: ${intType.isNumericType()}")
    println("Float32 is numeric type: ${floatType.isNumericType()}")
    println("Bool is numeric type: ${boolType.isNumericType()}")
}
```

Output:

```text
Int32 is numeric type: true
Float32 is numeric type: true
Bool is numeric type: false
```

### func isPrimitiveType()

```cangjie
public func isPrimitiveType(): Bool
```

Function: Checks whether this type is a primitive type.

Return Value:

- Bool - Returns true if the type is primitive (int, float, bool, rune, unit, or nothing), false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let boolType = BoolType.get()
    println("Int32 is primitive type: ${intType.isPrimitiveType()}")
    println("Bool is primitive type: ${boolType.isPrimitiveType()}")
}
```

Output:

```text
Int32 is primitive type: true
Bool is primitive type: true
```

### func isRefType()

```cangjie
public func isRefType(): Bool
```

Function: Checks whether this type is a reference type.

Return Value:

- Bool - Returns true if the type is a reference type, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let refType = RefType.get(intType)
    println("Int32 is reference type: ${intType.isRefType()}")
    println("Int32& is reference type: ${refType.isRefType()}")
}
```

Output:

```text
Int32 is reference type: false
Int32& is reference type: true
```

### func isRuneType()

```cangjie
public func isRuneType(): Bool
```

Function: Checks whether this type is the Rune type.

Return Value:

- Bool - Returns true if the type is Rune, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let runeType = RuneType.get()
    let intType = IntType.getInt32()
    println("RuneType is Rune type: ${runeType.isRuneType()}")
    println("Int32 is Rune type: ${intType.isRuneType()}")
}
```

Output:

```text
RuneType is Rune type: true
Int32 is Rune type: false
```

### func isSignedIntType()

```cangjie
public func isSignedIntType(): Bool
```

Function: Checks whether this type is a signed integer type.

Return Value:

- Bool - Returns true if the type is a signed integer type, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let uintType = IntType.getUInt32()
    println("Int32 is signed integer: ${intType.isSignedIntType()}")
    println("UInt32 is signed integer: ${uintType.isSignedIntType()}")
}
```

Output:

```text
Int32 is signed integer: true
UInt32 is signed integer: false
```

### func isUnitType()

```cangjie
public func isUnitType(): Bool
```

Function: Checks whether this type is the Unit type.

Return Value:

- Bool - Returns true if the type is Unit, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let unitType = UnitType.get()
    let intType = IntType.getInt32()
    println("UnitType is Unit type: ${unitType.isUnitType()}")
    println("Int32 is Unit type: ${intType.isUnitType()}")
}
```

Output:

```text
UnitType is Unit type: true
Int32 is Unit type: false
```

### func isUnsignedIntType()

```cangjie
public func isUnsignedIntType(): Bool
```

Function: Checks whether this type is an unsigned integer type.

Return Value:

- Bool - Returns true if the type is an unsigned integer type, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let uintType = IntType.getUInt32()
    println("Int32 is unsigned integer: ${intType.isUnsignedIntType()}")
    println("UInt32 is unsigned integer: ${uintType.isUnsignedIntType()}")
}
```

Output:

```text
Int32 is unsigned integer: false
UInt32 is unsigned integer: true
```

### operator func==(Type)

```cangjie
public open operator func==(other: Type): Bool
```

Function: Checks whether this type equals another type.

Parameters:

- other: Type - The type to compare with.

Return Value:

- Bool - Returns true if the types have the same kind and type arguments, false otherwise.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let type1 = IntType.getInt32()
    let type2 = IntType.getInt32()
    let type3 = IntType.getInt64()
    println("type1 == type2: ${type1 == type2}")
    println("type1 == type3: ${type1 == type3}")
}
```

Output:

```text
type1 == type2: true
type1 == type3: false
```

### func stripAllRefs()

```cangjie
public func stripAllRefs(): Type
```

Function: Strips all reference wrappers from this type.

Recursively removes all `Ref` wrappers until a non-reference type is reached.

Return Value:

- Type - Base type after stripping all reference wrappers.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    let refType = RefType.get(intType)
    let baseType = refType.stripAllRefs()
    println("Reference type: ${refType.toString()}")
    println("After stripping reference: ${baseType.toString()}")
}
```

Output:

```text
Reference type: Int32&
After stripping reference: Int32
```

### func toString()

```cangjie
public open func toString(): String
```

Function: Converts this type to a string representation.

Return Value:

- String - String representation of the type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let intType = IntType.getInt32()
    println("Type: ${intType.toString()}")
}
```

Output:

```text
Type: Int32
```

## class UnitType

```cangjie
public class UnitType <: BuiltinType & Equatable<UnitType>
```

Function: Represents the Unit type in the type system. Denotes no meaningful value, similar to `void` in C.

Parent Types:

- [BuiltinType](#class-builtintype)
- Equatable\<[UnitType](#class-unittype)>

### static func get()

```cangjie
public static func get(): UnitType
```

Function: Gets the singleton instance of UnitType.

Return Value:

- UnitType - UnitType instance.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let unitType = UnitType.get()
    println("Unit type: ${unitType.toString()}")
}
```

Output:

```text
Unit type: Unit
```

### operator func==(UnitType)

```cangjie
public operator func==(_: UnitType): Bool
```

Function: Checks whether this UnitType equals another UnitType.

Parameters:

- _: UnitType - The other UnitType to compare with (unused; always returns true).

Return Value:

- Bool - Always returns true because all UnitType instances are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let unitType1 = UnitType.get()
    let unitType2 = UnitType.get()
    println("Two UnitType instances are equal: ${unitType1 == unitType2}")
}
```

Output:

```text
Two UnitType instances are equal: true
```

## class VArrayType

```cangjie
public class VArrayType <: BuiltinType & Equatable<VArrayType>
```

Function: **Fixed-length VArray** type `VArray<T, $n>` with compile-time fixed length. Cached uniquely by `(elementType, size)`.

Parent Types:

- [BuiltinType](#class-builtintype)
- Equatable\<[VArrayType](#class-varraytype)>

### prop elementType

```cangjie
public prop elementType: Type
```

Function: Element type.

Type: Type

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let v = VArrayType.get(IntType.getUInt32(), 4)
    println(v.elementType.toString())
}
```

Output:

```text
UInt32
```

### prop size

```cangjie
public prop size: Int64
```

Function: Compile-time fixed length.

Type: Int64

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let v = VArrayType.get(IntType.getInt32(), 8)
    println("${v.size}")
}
```

Output:

```text
8
```

### static func get(Type, Int64)

```cangjie
public static func get(elementType: Type, size: Int64): VArrayType
```

Function: Gets or creates a VArray type.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let v = VArrayType.get(IntType.getInt32(), 8)
    println("static_get: ${v.toString().size > 0}")
}
```

Output:

```text
static_get: true
```

### func toString()

```cangjie
public func toString(): String
```

Function: String representation of the fixed-length VArray.

Return Value:

- String - Textual form.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let v = VArrayType.get(IntType.getInt32(), 2)
    println(v.toString())
}
```

Output:

```text
VArray<Int32, $2>
```

### operator func==(VArrayType)

```cangjie
public operator func==(other: VArrayType): Bool
```

Function: Compares whether element type and length match.

Parameters:

- other: VArrayType - The other VArray type.

Return Value:

- Bool - Whether they are equal.

Example:

<!-- verify -->
```cangjie
import stdx.chir.*

main() {
    let v1 = VArrayType.get(IntType.getInt32(), 8)
    let v2 = VArrayType.get(IntType.getInt32(), 8)
    println("op_eq_VArrayType: ${v1 == v2}")
}
```

Output:

```text
op_eq_VArrayType: true
```

---
