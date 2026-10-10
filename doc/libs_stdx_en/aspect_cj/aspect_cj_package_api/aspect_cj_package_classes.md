# Classes

## class InsertAtEntry

```cangjie
public class InsertAtEntry {
    public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool, funcTypeStr!: String)
}
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
public class InsertAtExit {
    public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool, funcTypeStr!: String)
}
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
public class ReplaceFuncBody {
    public const init(packageName!: String, className!: String, methodName!: String, isStatic!: Bool, recursive!: Bool)
}
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
public class PointcutRule {
    public const init(packageName!: String, className!: String, methodName!: String,
        funcTypeStr!: String, targetKind!: String, recursive!: Bool, annotationName!: String)
}
```

Defines a reusable atomic pointcut on a top-level ordinary class in the aspect package. The first four fields follow the existing wildcard syntax. `targetKind` is `any`, `global`, `static`, or `instance`. A nonempty `annotationName` matches the resolved fully qualified class name of a direct business annotation, not a source alias or an unrelated class with the same short name. `recursive` extends receiver-type matching to ancestors; it does not inherit annotations. All named arguments are required.

## class PointcutExpression

```cangjie
public class PointcutExpression {
    public const init(packageScope!: String, expression!: String)
}
```

Combines rule class names from the same aspect package using parentheses, `NOT`, `AND`, and `OR` (in descending precedence). `packageScope` limits this rule's own target-package scope. Both named arguments are required.

## class InsertAtEntryByRule

```cangjie
public class InsertAtEntryByRule {
    public const init(rule!: String)
}
```

Calls the annotated public global or static advice at the entry of targets selected by the fully qualified `rule` ID. Advice returns `Unit` and accepts either no explicit argument or one exact `Array<Any>`. The array excludes implicit `this` and does not write back target parameters.

## class InsertAtExitByRule

```cangjie
public class InsertAtExitByRule {
    public const init(rule!: String)
}
```

Uses the same rule and advice signature as `InsertAtEntryByRule`, but runs only at normal exits. An uncaught target exception does not run this exit advice.
