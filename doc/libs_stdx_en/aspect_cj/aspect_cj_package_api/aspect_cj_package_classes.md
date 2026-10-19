# Classes

## class InsertAtEntry

```cangjie
public class InsertAtEntry {}
```

Function: Weaves a call to the annotated function at the entry point of the method specified by the annotation. Both the annotated method and the target function must comply with the [Specification Constraints](../aspect_cj_package_overview.md#specifications-and-usage).

Example: 

See the [InsertAtEntry example tutorial](../aspect_cj_samples/aspect_cj_sample.md#insertatentry-entry-instrumentation-example) for the end-to-end workflow.

### const init(String, String, String, Bool, Bool, String)

```cangjie
public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool, funcTypeStr!: String)
```

Function: Creates an [InsertAtEntry](aspect_cj_package_classes.md#class-insertatentry) object.

Example: 

See the [InsertAtEntry example tutorial](../aspect_cj_samples/aspect_cj_sample.md#insertatentry-entry-instrumentation-example) for the end-to-end workflow.

Parameters:

- packageName!: String - The package name of the target function, e.g., "default", "std.core". Supports `*` within a name segment and a complete `**` package segment;
- className!: String - For member functions, specifies the class name; for global functions, leave empty. Supports `*` within the name segment;
- methodName!: String - The name of the target function, e.g., "foo". Supports `*` within the name segment;
- isStatic!: Bool - Indicates whether the target function is a static member function;
- recursive!: Bool - For member functions, indicates whether to weave into override versions in subclasses; otherwise, this field should be false.
- funcTypeStr!: String - The type signature string of the target function (without spaces). For custom types, the package name must be included and separated by `.`. Does not include the implicit this parameter type. Example: "(Int64,std.core.Object)->Unit". A standalone `*` matches one type, a standalone `**` in the parameter list matches zero or more parameters, and qualified type names support `*` within a segment and a complete `**` segment. A wildcard function type requires the aspect function to have exactly one explicit `Array<Any>` parameter;

## class InsertAtExit

```cangjie
public class InsertAtExit {}
```

Function: Weaves a call to the annotated function at the exit point of the method specified by the annotation. Both the annotated method and the target function must comply with the [Specification Constraints](../aspect_cj_package_overview.md#specifications-and-usage).

Example: 

See the [InsertAtExit example tutorial](../aspect_cj_samples/aspect_cj_sample.md#insertatexit-exit-instrumentation-example) for the end-to-end workflow.

### const init(String, String, String, Bool, Bool, String)

```cangjie
public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool, funcTypeStr!: String)
```

Function: Creates an [InsertAtExit](aspect_cj_package_classes.md#class-insertatexit) object.

Example: 

See the [InsertAtExit example tutorial](../aspect_cj_samples/aspect_cj_sample.md#insertatexit-exit-instrumentation-example) for the end-to-end workflow.

Parameters:

- packageName!: String - The package name of the target function, e.g., "default", "std.core". Supports `*` within a name segment and a complete `**` package segment;
- className!: String - For member functions, specifies the class name; for global functions, leave empty. Supports `*` within the name segment;
- methodName!: String - The name of the target function, e.g., "foo". Supports `*` within the name segment;
- isStatic!: Bool - Indicates whether the target function is a static member function;
- recursive!: Bool - For member functions, indicates whether to weave into override versions in subclasses; otherwise, this field should be false.
- funcTypeStr!: String - The type signature string of the target function (without spaces). For custom types, the package name must be included and separated by `.`. Does not include the implicit this parameter type. Example: "(Int64,std.core.Object)->Unit". A standalone `*` matches one type, a standalone `**` in the parameter list matches zero or more parameters, and qualified type names support `*` within a segment and a complete `**` segment. A wildcard function type requires the aspect function to have exactly one explicit `Array<Any>` parameter;

## class ReplaceFuncBody

```cangjie
public class ReplaceFuncBody {}
```

Function: Replaces the method body specified by the annotation with a call to the annotated function. Both the annotated method and the target function must comply with the [Specification Constraints](../aspect_cj_package_overview.md#specifications-and-usage).

Example: 

See the [ReplaceFuncBody example tutorial](../aspect_cj_samples/aspect_cj_sample.md#replacefuncbody-function-body-replacement-example) for the end-to-end workflow.

### const init(String, String, String, Bool, Bool)

```cangjie
public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool)
```

Function: Creates a [ReplaceFuncBody](aspect_cj_package_classes.md#class-replacefuncbody) object.

Example: 

See the [ReplaceFuncBody example tutorial](../aspect_cj_samples/aspect_cj_sample.md#replacefuncbody-function-body-replacement-example) for the end-to-end workflow.

Parameters:

- packageName!: String - The package name of the target function, e.g., "default", "std.core";
- className!: String - For member functions, specifies the class name; for global functions, leave empty;
- methodName!: String - The name of the target function, e.g., "foo";
- isStatic!: Bool - Indicates whether the target function is a static member function;
- recursive!: Bool - For member functions, indicates whether to apply to override versions in subclasses; otherwise, this field should be false.

## class PointcutRule

```cangjie
public class PointcutRule {}
```

Function: Defines a reusable atomic pointcut on a top-level ordinary class in the aspect package. A target must satisfy all conditions. Name and type patterns follow the [pointcut wildcard rules](../aspect_cj_package_overview.md#specifications-and-usage).

### const init(String, String, String, String, String, Bool, String)

```cangjie
public const init(packageName!: String, className!: String, methodName!: String,
    funcTypeStr!: String, targetKind!: String, recursive!: Bool, annotationName!: String)
```

Function: Creates a [PointcutRule](#class-pointcutrule) object. All parameters are required named parameters.

Parameters:

- packageName!: String - The target function's package-name pattern. Supports `*` within a name segment and a complete `**` package segment.
- className!: String - The target member's declaring-type name pattern, supporting `*` within a name segment. A global function has an empty type name. This parameter must be empty when `targetKind` is `global`.
- methodName!: String - The target function-name pattern, supporting `*` within a name segment.
- funcTypeStr!: String - The target function-type pattern, without spaces or implicit `this`. A standalone `*` matches one type; a standalone `**` in the parameter list matches zero or more parameters, for example `(**)->*`.
- targetKind!: String - The target kind. Accepts only `any`, `global`, `static`, or `instance`, meaning any kind, global functions, static member functions, or instance member functions, respectively.
- recursive!: Bool - Whether to extend matching of the member's declaring-type name to its ancestor types. This does not inherit business annotations. When `true`, `className` must be nonempty and `targetKind` must not be `global`.
- annotationName!: String - The fully qualified class name of a business annotation directly applied to the target function's source declaration, for example `example.annotations.Trace`. An empty string imposes no annotation condition. Otherwise, matching uses the resolved declaration identity, not a source alias or an unrelated class with the same short name. Wildcards are not supported.

## class PointcutExpression

```cangjie
public class PointcutExpression {}
```

Function: Annotates a top-level ordinary class in the aspect package to combine reusable pointcut rules with a Boolean expression.

### const init(String, String)

```cangjie
public const init(packageScope!: String, expression!: String)
```

Function: Creates a [PointcutExpression](#class-pointcutexpression) object. All parameters are required named parameters.

Parameters:

- packageScope!: String - The target-package pattern allowed by this rule. Supports `*` within a name segment and a complete `**` package segment. Each rule retains its own scope; an outer scope does not override the scopes of referenced rules. `NOT` cannot match a target outside this scope.
- expression!: String - An expression referencing source names of rule classes in the same aspect package, for example `ReadRule AND NOT InternalRule`. Supports parentheses and the uppercase operators `NOT`, `AND`, and `OR`, in descending precedence. Unknown references, cycles, or invalid expressions fail during collection.

## class InsertAtEntryByRule

```cangjie
public class InsertAtEntryByRule {}
```

Function: Calls the annotated public global or static advice at the entry of matching targets. Advice returns `Unit` and accepts either no explicit argument or one exact `Array<Any>`. The array is a shallow snapshot in the order of explicit arguments at target entry, excluding implicit `this`. Changing an array element does not write back to the target parameter.

### const init(String)

```cangjie
public const init(rule!: String)
```

Function: Creates an [InsertAtEntryByRule](#class-insertatentrybyrule) object.

Parameters:

- rule!: String - A required named parameter specifying the fully qualified canonical ID of a rule class in the same aspect package: its declaring package name plus class name, for example `example.aspect.TraceRule`. The class must be annotated with [PointcutRule](#class-pointcutrule) or [PointcutExpression](#class-pointcutexpression). This is not an expression or wildcard pattern. An unknown reference fails during collection.

## class InsertAtExitByRule

```cangjie
public class InsertAtExitByRule {}
```

Function: Calls the annotated public global or static advice at normal exits of matching targets. An uncaught target exception does not run this exit advice. Advice signatures and argument snapshots follow [InsertAtEntryByRule](#class-insertatentrybyrule): the snapshot is still taken at target entry, not from the return value.

### const init(String)

```cangjie
public const init(rule!: String)
```

Function: Creates an [InsertAtExitByRule](#class-insertatexitbyrule) object.

Parameters:

- rule!: String - A required named parameter specifying the fully qualified canonical ID of a rule class in the same aspect package, for example `example.aspect.TraceRule`. The class must be annotated with [PointcutRule](#class-pointcutrule) or [PointcutExpression](#class-pointcutexpression). This is not an expression or wildcard pattern. An unknown reference fails during collection.
