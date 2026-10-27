# stdx.aspect_cj

> **Note:**
>
> Under active development; functionality is not yet complete.

## Feature Description

The `stdx.aspect_cj` package provides annotations for Aspect-Oriented Programming (AOP) in Cangjie. Legacy annotations work with the libstdx.collect_aspects and libstdx.weave_aspects compilation plugins to enable function instrumentation (before/after) and implementation replacement. Rule-based annotations select entry or normal-exit join points through reusable pointcuts and Boolean expressions, using separate rule plugins and a build driver.

## API List

### Classes

| Class Name                                                    | Functionality                                                |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [InsertAtEntry](./aspect_cj_package_api/aspect_cj_package_classes.md#class-insertatentry) | An annotation class that provides aspect capability. Injects a call to the annotated function at the entry point of the specified method. |
| [InsertAtExit](./aspect_cj_package_api/aspect_cj_package_classes.md#class-insertatexit) | An annotation class that provides aspect capability. Injects a call to the annotated function at the exit point of the specified method. |
| [ReplaceFuncBody](./aspect_cj_package_api/aspect_cj_package_classes.md#class-replacefuncbody) | An annotation class that provides aspect capability. Replaces the method body of the specified method with a call to the annotated function. |
| [PointcutRule](./aspect_cj_package_api/aspect_cj_package_classes.md#class-pointcutrule) | Defines a reusable atomic pointcut, including a resolved business-annotation filter. |
| [PointcutExpression](./aspect_cj_package_api/aspect_cj_package_classes.md#class-pointcutexpression) | Combines rules in the same aspect package with AND, OR, and NOT. |
| [InsertAtEntryByRule](./aspect_cj_package_api/aspect_cj_package_classes.md#class-insertatentrybyrule) / [InsertAtExitByRule](./aspect_cj_package_api/aspect_cj_package_classes.md#class-insertatexitbyrule) | Selects entry or normal-exit join points by rule. |

## Specifications and Usage

### Specifications

#### Legacy Annotation Mode

This section applies to `InsertAtEntry`, `InsertAtExit`, and `ReplaceFuncBody`, not to the rule-based annotations described below.

**Annotation Scope:**

- Advice functions must not be generic or belong to a generic type;
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

**Parameter Constraints:**

- Functions annotated with @InsertAtEntry/@InsertAtExit must have a return type of Unit;
- Functions annotated with @ReplaceFuncBody should have the same return type as the function being woven into;
- A global or static @InsertAtEntry/@InsertAtExit advice with no explicit parameters receives none of the target function's explicit arguments. Instance-member advice follows the typed-parameter or `Array<Any>` mode below and uses its implicit `this` receiver;
- An @InsertAtEntry/@InsertAtExit advice may receive target arguments through typed parameters matching the target function's source parameter list. For an instance target, global or static advice must also declare the target instance as the first parameter. Instance-member advice of the same type uses its implicit `this` and does not declare this parameter again;
- An @ReplaceFuncBody advice must receive the original function's closure as its last explicit parameter; this parameter cannot be omitted. Its type contains only the target's explicit source parameters and return type, not the instance receiver, which weaving binds automatically. For a global or static target, the advice may declare only this closure parameter. If it also receives target arguments, the parameters before the closure must match the target function's parameters. Instance targets follow the receiver rules above, and the remaining parameters must match each explicit source parameter of the target;
    - For `func foo(x: Int64): Int64` on type `T`, member advice is written as `func aspect(x: Int64, original: (Int64) -> Int64): Int64`;
    - Global or static advice is written as `func aspect(self: T, x: Int64, original: (Int64) -> Int64): Int64`. The type of `self` must match the configured target type; its parameter name is not matched. Call the original implementation as `original(x)`, without passing `self` again;
- An @InsertAtEntry/@InsertAtExit aspect may instead declare exactly one explicit `Array<Any>` parameter. The array contains a shallow snapshot of the target function's explicit arguments in source order at function entry. It excludes the implicit `this`, and changing an array element does not write back to the target parameter;
- The `Array<Any>` argument mode does not apply to @ReplaceFuncBody.

#### Rule-Based Mode

- `PointcutRule` and `PointcutExpression` annotate top-level, non-generic ordinary classes in the current aspect package to declare pointcut rules; they do not annotate advice functions;
- `InsertAtEntryByRule` and `InsertAtExitByRule` only annotate public global or static advice functions, not instance-member advice. Advice must not be generic or belong to a generic type, and must return `Unit`;
- Rule-based advice accepts either zero explicit parameters or one `Array<Any>` parameter, not individually typed target parameters. Zero-argument advice may reference a wildcard `PointcutRule` without switching to `Array<Any>`;
- `Array<Any>` contains a shallow snapshot of the target function's explicit arguments at entry. It excludes the implicit `this`, and changing an array element does not write back to a target parameter. Exit advice also receives the entry snapshot, not the return value;
- Rule targets may be ordinary global, static, or instance-member functions with executable bodies, including concrete instances of generic functions or generic types, but not generic template bodies. `main`, constructors/destructors, property accessors, annotation factories, lambdas, compiler helpers, and advice bodies are excluded;
- `PointcutExpression` supports parentheses and `NOT`, `AND`, and `OR` in descending precedence. References are limited to the current aspect package. Each rule retains its own package scope; targets outside that scope cannot match through `NOT`.

#### Constraints Shared by Both Modes

**Global Variable Definition Constraints:**

- In packages defining aspects, only global variables with literal values of basic types (integer, float, Rune, Bool) are allowed; otherwise, compilation will fail. To use out-of-spec global variables, they must be defined in another package and imported to avoid potential circular dependencies after compilation.

**Pointcut Wildcards:**

- `*` in `packageName`, `className`, and `methodName` matches zero or more characters within one name segment;
- A complete `**` segment in `packageName` matches zero or more package-name segments;
- In `funcTypeStr`, a standalone `*` matches one type and a standalone `**` in the parameter list matches zero or more parameters. Qualified type names use the same `*` and `**` rules;
- At most one standalone `**` is allowed in a parameter list. Legacy @InsertAtEntry/@InsertAtExit annotations require the `Array<Any>` argument mode when `funcTypeStr` contains wildcards. This restriction does not apply to zero-argument rule-based advice referencing a `PointcutRule`;
- The `this` type of legacy instance-member advice is statically fixed, so its `packageName` and `className` must be exact. Rule-based mode does not support instance-member advice.
- Write names and type patterns directly in configuration fields. Backslash escapes (including `\n`, `\r`, and `\u{...}` in string literals) are not supported. Control characters or escape text are rejected during collection rather than producing rules that cannot match.

### Usage

Two compilation plugins are required when defining aspects with legacy annotations:

- libstdx.collect_aspects.so(.dll/.dylib)
- libstdx.weave_aspects.so(.dll/.dylib)

These compilation plugins are provided as dynamic libraries in stdx.aspect_cj, with different versions for different platforms.

First, use libstdx.collect_aspects to collect all aspect and join point information during compilation. Then use libstdx.weave_aspects for secondary compilation to weave the collected aspects into the join points.

Rule-based pointcuts additionally require `libstdx.collect_rules`, `libstdx.weave_rules`, and a matching compiler. They currently support Linux/cjnative. The installed `aspect-cj-driver` coordinates source collection, pure source selection, preflight, application, and final publication; the original two plugins do not automatically switch to rule mode. See the [class reference](./aspect_cj_package_api/aspect_cj_package_classes.md#class-pointcutrule) for rule parameters and the [driver guide (Chinese)](../../design/aspect_cj_driver.md) for build configuration and commands.
