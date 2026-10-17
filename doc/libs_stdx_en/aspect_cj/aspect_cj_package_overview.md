# stdx.aspect_cj

> **Note:**
>
> Under active development; functionality is not yet complete.

## Feature Description

The `stdx.aspect_cj` package provides annotations for Aspect-Oriented Programming (AOP) in Cangjie. When used in conjunction with the libstdx.collect_aspects and libstdx.weave_aspects compilation plugins, it enables function instrumentation (before/after) and implementation replacement.

## API List

### Classes

| Class Name                                                    | Functionality                                                |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [InsertAtEntry](./aspect_cj_package_api/aspect_cj_package_classes.md#class-insertatentry) | An annotation class that provides aspect capability. Injects a call to the annotated function at the entry point of the specified method. |
| [InsertAtExit](./aspect_cj_package_api/aspect_cj_package_classes.md#class-insertatexit) | An annotation class that provides aspect capability. Injects a call to the annotated function at the exit point of the specified method. |
| [ReplaceFuncBody](./aspect_cj_package_api/aspect_cj_package_classes.md#class-replacefuncbody) | An annotation class that provides aspect capability. Replaces the method body of the specified method with a call to the annotated function. |

## Specifications and Usage

### Specifications

**Annotation Scope:**

- Annotations currently do not support generic functions, nor can they weave into generic functions;
- Annotations can only be applied to public functions;
- Annotations can be applied to global functions, supporting:
    - Weaving into another global function,
    - Weaving into another instance member function,
    - Weaving into another static member function;
- Annotations can be applied to static member functions, supporting:
    - Weaving into another global function,
    - Weaving into another instance member function,
    - Weaving into another static member function;
- Annotations can be applied to instance member functions, supporting:
    - Weaving into other instance member functions of the same type.

**Global Variable Definition Constraints:**

- In packages defining aspects, only global variables with literal values of basic types (integer, float, Rune, Bool) are allowed; otherwise, compilation will fail. To use out-of-spec global variables, they must be defined in another package and imported to avoid potential circular dependencies after compilation.

**Parameter Constraints:**

- Functions annotated with @InsertAtEntry/@InsertAtExit must have a return type of Unit;
- Functions annotated with @ReplaceFuncBody should have the same return type as the function being woven into;
- If functions annotated with @InsertAtEntry/@InsertAtExit/@ReplaceFuncBody have no parameters, they will always be called without parameters after weaving;
- If a function annotated with @InsertAtEntry/@InsertAtExit/@ReplaceFuncBody has parameters, collection first removes the receiver according to the aspect form, then compares the remaining parameters with the source parameters of the function being woven into:
    - When the aspect itself is an instance member of the woven type, the receiver is that aspect's implicit `this` and is not declared again in the source parameter list. After collection drops this implicit `this`, the remaining parameters match the woven function's source parameters. This form of aspect can only weave into an instance member of the same type;
    - When the aspect is a global function or a static member and the woven function is an instance member, the first source parameter is written explicitly with that instance type, for example `self: T`. The check is on the type: it must equal `packageName.className` from the annotation. The parameter name is not checked. After this parameter is dropped, the remaining parameters match the woven function's source parameters;
    - When the woven function is a global function or a static member, the aspect cannot be an instance member, and its parameter list matches the woven function's source parameters directly.
- A function annotated with @ReplaceFuncBody takes one more parameter after the parameters above. That last parameter is the original implementation. Its function type contains only the woven function's source parameters and return type; the receiver is not part of it. The aspect's return type must match both the woven function and this parameter. For a woven `func foo(x: Int64): Int64`:
    - a member aspect is written as `func aspect(x: Int64, original: (Int64) -> Int64): Int64`;
    - a global or static aspect is written as `func aspect(self: T, x: Int64, original: (Int64) -> Int64): Int64`.

### Usage

To fully implement AOP functionality, in addition to using the aforementioned annotation classes to define aspects, two compilation plugins are required:

- libstdx.collect_aspects.so(.dll/.dylib)
- libstdx.weave_aspects.so(.dll/.dylib)

These compilation plugins are provided as dynamic libraries in stdx.aspect_cj, with different versions for different platforms.

First, use libstdx.collect_aspects to collect all aspect and join point information during compilation. Then use libstdx.weave_aspects for secondary compilation to weave the collected aspects into the join points.