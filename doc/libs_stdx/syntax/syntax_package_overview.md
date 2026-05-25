# stdx.syntax

## 功能介绍

syntax 包主要包含了仓颉源码的语法解析器和仓颉语法树节点，提供语法解析函数。可以将指定路径的仓颉文件或包解析为抽象语法树（Abstract Syntax Tree）节点对象。

> **注意：**
>
> syntax 包需要依赖 `cangjie/tools/lib` 目录下的 `libcangjie-lsp` 动态库。

## API 列表

### 函数

|              函数名          |           功能           |
| --------------------------- | ------------------------ |
| [parseFile(String)](./syntax_package_api/syntax_package_funcs.md#func-parsefilestring)  | 用于解析一个文本文件，获取一个符合仓颉语法的 `SourceFile` 类型的抽象语法树。 |
| [parsePackage(String)](./syntax_package_api/syntax_package_funcs.md#func-parsepackagestring)  | 用于解析一个文件目录，获取一个符合仓颉语法的 `Package` 类型的抽象语法树。 |
| [parseText(String)](./syntax_package_api/syntax_package_funcs.md#func-parsetextstring)  | 用于解析一个字符串文本，获取一个符合仓颉语法的抽象语法树节点。 |
| [parseTokens(Tokens, Bool)](./syntax_package_api/syntax_package_funcs.md#func-parsetokenstokens-bool)  | 用于解析一组词法单元，获取一个符合仓颉语法的抽象语法树节点。 |

### 类

|                 类名               |                功能                |
| --------------------------------- | ---------------------------------- |
| [Annotation](./syntax_package_api/syntax_package_classes.md#class-annotation) | 表示编译器内置的注解节点。 |
| [Argument](./syntax_package_api/syntax_package_classes.md#class-argument) | 表示函数调用的实参节点。 |
| [ArrayLiteral](./syntax_package_api/syntax_package_classes.md#class-arrayliteral) | 表示 `Array` 字面量节点。 |
| [AsExpr](./syntax_package_api/syntax_package_classes.md#class-asexpr) | 表示一个类型转换表达式。 |
| [AssignExpr](./syntax_package_api/syntax_package_classes.md#class-assignexpr) | 表示赋值表达式节点。 |
| [ASTRewriter](./syntax_package_api/syntax_package_classes.md#class-astrewriter) | 语法树的通用重写器基类。 |
| [ASTVisitor](./syntax_package_api/syntax_package_classes.md#class-astvisitor) | 语法树的通用访问器基类。 |
| [AtomicType](./syntax_package_api/syntax_package_classes.md#class-atomictype) | 表示一个基本类型节点。 |
| [BinaryExpr](./syntax_package_api/syntax_package_classes.md#class-binaryexpr) | 表示一个二元操作表达式节点。 |
| [Block](./syntax_package_api/syntax_package_classes.md#class-block) | 表示块节点。 |
| [Body](./syntax_package_api/syntax_package_classes.md#class-body) | 表示 `Class` 类型、 `Struct` 类型、 `Interface` 类型以及扩展中由 `{}` 和内部的一组声明节点组成的结构。 |
| [BreakExpr](./syntax_package_api/syntax_package_classes.md#class-breakexpr) | 表示中断表达式。 |
| [CallExpr](./syntax_package_api/syntax_package_classes.md#class-callexpr) | 表示函数调用节点。 |
| [CatchPattern](./syntax_package_api/syntax_package_classes.md#class-catchpattern) | 表示一个捕获模式。 |
| [ClassDecl](./syntax_package_api/syntax_package_classes.md#class-classdecl) | 表示一个类声明节点。 |
| [Comment](./syntax_package_api/syntax_package_classes.md#class-comment) | 表示一个注释节点。 |
| [CompositeType](./syntax_package_api/syntax_package_classes.md#class-compositetype) | 表示一个复合类型节点。 |
| [ConjunctionCondition](./syntax_package_api/syntax_package_classes.md#class-conjunctioncondition) | 表示原子条件的逻辑合取。 |
| [ConstPattern](./syntax_package_api/syntax_package_classes.md#class-constpattern) | 表示常量模式节点。 |
| [ContinueExpr](./syntax_package_api/syntax_package_classes.md#class-continueexpr) | 表示继续表达式。 |
| [Decl](./syntax_package_api/syntax_package_classes.md#class-decl) | 所有声明节点的父类，继承自 `SyntaxTreeNode` 节点，提供了所有声明节点的通用接口。 |
| [Diagnostic](./syntax_package_api/syntax_package_classes.md#class-diagnostic) | 表示仓颉语法树节点的诊断信息。 |
| [DisjunctionCondition](./syntax_package_api/syntax_package_classes.md#class-disjunctioncondition) | 表示合取条件的逻辑析取。 |
| [DoWhileExpr](./syntax_package_api/syntax_package_classes.md#class-dowhileexpr) | 表示 `do-while` 表达式。 |
| [EnumConstructor](./syntax_package_api/syntax_package_classes.md#class-enumconstructor) | 表示一个枚举构造器。 |
| [EnumDecl](./syntax_package_api/syntax_package_classes.md#class-enumdecl) | 表示一个 `Enum` 声明节点。 |
| [EnumPattern](./syntax_package_api/syntax_package_classes.md#class-enumpattern) | 表示 `enum` 模式节点。 |
| [Expr](./syntax_package_api/syntax_package_classes.md#class-expr) | 所有表达式节点的父类，继承自 `SyntaxTreeNode` 节点。 |
| [ExtendDecl](./syntax_package_api/syntax_package_classes.md#class-extenddecl) | 表示一个扩展声明节点。 |
| [FeatureId](./syntax_package_api/syntax_package_classes.md#class-featureid) | 一个 feature 标识节点。 |
| [FeaturesDirective](./syntax_package_api/syntax_package_classes.md#class-featuresdirective) | 一个 features  声明节点。 |
| [FeaturesSet](./syntax_package_api/syntax_package_classes.md#class-featuresset) | 一个 feature set 节点。 |
| [ForInExpr](./syntax_package_api/syntax_package_classes.md#class-forinexpr) | 表示 `for-in` 表达式。 |
| [FuncDecl](./syntax_package_api/syntax_package_classes.md#class-funcdecl) | 表示一个函数声明节点。 |
| [FuncParam](./syntax_package_api/syntax_package_classes.md#class-funcparam) | 表示函数参数节点，包括非命名参数和命名参数。 |
| [FuncType](./syntax_package_api/syntax_package_classes.md#class-functype) | 表示函数类型节点。 |
| [GenericConstraint](./syntax_package_api/syntax_package_classes.md#class-genericconstraint) | 表示一个泛型约束节点。 |
| [GenericConstraints](./syntax_package_api/syntax_package_classes.md#class-genericconstraints) | 表示一组泛型约束。 |
| [GenericParam](./syntax_package_api/syntax_package_classes.md#class-genericparam) | 表示一个泛型参数节点。 |
| [IfExpr](./syntax_package_api/syntax_package_classes.md#class-ifexpr) | 表示条件表达式。 |
| [ImportAlias](./syntax_package_api/syntax_package_classes.md#class-importalias) | 表示一个别名导入的包导入声明节点的具体项目。 |
| [ImportAll](./syntax_package_api/syntax_package_classes.md#class-importall) | 表示一个全导入的包导入声明节点的具体项目。 |
| [ImportContent](./syntax_package_api/syntax_package_classes.md#class-importcontent) | 表示一个包导入声明节点的具体声明内容。 |
| [ImportList](./syntax_package_api/syntax_package_classes.md#class-importlist) | 表示包导入节点。 |
| [ImportMulti](./syntax_package_api/syntax_package_classes.md#class-importmulti) | 表示一个多导入的包导入声明节点的具体项目。 |
| [ImportSingle](./syntax_package_api/syntax_package_classes.md#class-importsingle) | 表示一个单导入的包导入声明节点的具体项目。 |
| [IncOrDecExpr](./syntax_package_api/syntax_package_classes.md#class-incordecexpr) | 表示包含自增操作符（`++`）或自减操作符（`--`）的表达式。 |
| [InterfaceDecl](./syntax_package_api/syntax_package_classes.md#class-interfacedecl) | 表示接口声明节点。 |
| [IsExpr](./syntax_package_api/syntax_package_classes.md#class-isexpr) | 表示一个类型检查表达式。 |
| [Lambda](./syntax_package_api/syntax_package_classes.md#class-lambda) | 表示 `Lambda` 表达式，是一个匿名的函数。 |
| [LambdaParam](./syntax_package_api/syntax_package_classes.md#class-lambdaparam) | 表示 `Lambda` 表达式的参数。 |
| [LetPattern](./syntax_package_api/syntax_package_classes.md#class-letpattern) | 表示一个 `let` 模式绑定表达式。 |
| [LitConstExpr](./syntax_package_api/syntax_package_classes.md#class-litconstexpr) | 表示一个字面量表达式节点。 |
| [LitConstRuneExpr](./syntax_package_api/syntax_package_classes.md#class-litconstruneexpr) | 表示一个字符字面量表达式节点。 |
| [LitConstStrExpr](./syntax_package_api/syntax_package_classes.md#class-litconststrexpr) | 表示一个字符串字面量表达式节点。 |
| [MacroDecl](./syntax_package_api/syntax_package_classes.md#class-macrodecl) | 表示一个宏定义节点。 |
| [MacroExpandDecl](./syntax_package_api/syntax_package_classes.md#class-macroexpanddecl) | 表示宏展开声明。 |
| [MacroExpandExpr](./syntax_package_api/syntax_package_classes.md#class-macroexpandexpr) | 表示宏展开表达式。 |
| [MacroExpandParam](./syntax_package_api/syntax_package_classes.md#class-macroexpandparam) | 表示宏展开参数。 |
| [MainDecl](./syntax_package_api/syntax_package_classes.md#class-maindecl) | 表示一个 `main` 函数声明节点。 |
| [MatchCase](./syntax_package_api/syntax_package_classes.md#class-matchcase) | 表示 `match` 表达式中的一个 `case` 节点。 |
| [MatchExpr](./syntax_package_api/syntax_package_classes.md#class-matchexpr) | 表示模式匹配表达式，用于实现模式匹配。 |
| [MemberAccess](./syntax_package_api/syntax_package_classes.md#class-memberaccess) | 表示成员访问表达式。 |
| [Modifier](./syntax_package_api/syntax_package_classes.md#class-modifier) | 表示某个声明的修饰符，通常放在声明处的最前端。 |
| [OptionalExpr](./syntax_package_api/syntax_package_classes.md#class-optionalexpr) | 表示一个带有问号操作符的表达式节点。 |
| [Package](./syntax_package_api/syntax_package_classes.md#class-package) | 表示包节点。 |
| [PackageHeader](./syntax_package_api/syntax_package_classes.md#class-packageheader) | 表示包声明节点。 |
| [Parameter](./syntax_package_api/syntax_package_classes.md#class-parameter) | 表示参数节点的父节点。 |
| [ParameterList](./syntax_package_api/syntax_package_classes.md#class-parameterlist) | 表示参数列表节点。 |
| [ParenCondition](./syntax_package_api/syntax_package_classes.md#class-parencondition) | 表示一个括号条件节点，是指使用圆括号括起来的条件。 |
| [ParenExpr](./syntax_package_api/syntax_package_classes.md#class-parenexpr) | 表示一个括号表达式节点，是指使用圆括号括起来的表达式。 |
| [ParenType](./syntax_package_api/syntax_package_classes.md#class-parentype) | 表示括号类型节点。 |
| [ParsingResult\<T> where T <: SyntaxTreeNode](./syntax_package_api/syntax_package_classes.md#class-parsingresultt-where-t--syntaxtreenode) | 表示一个符合仓颉语法的抽象语法树。 |
| [Pattern](./syntax_package_api/syntax_package_classes.md#class-pattern) | 所有模式匹配节点的父类，继承自 `SyntaxTreeNode` 节点。 |
| [PrefixType](./syntax_package_api/syntax_package_classes.md#class-prefixtype) | 表示带前缀操作符的前缀类型节点。 |
| [PropDecl](./syntax_package_api/syntax_package_classes.md#class-propdecl) | 表示一个属性声明节点。 |
| [PropGetterOrSetter](./syntax_package_api/syntax_package_classes.md#class-propgetterorsetter) | 表示一个属性的 `getter` 或 `setter` 声明。 |
| [QuoteExpr](./syntax_package_api/syntax_package_classes.md#class-quoteexpr) | 表示 `quote` 表达式节点。 |
| [QuoteInterpolationExpr](./syntax_package_api/syntax_package_classes.md#class-quoteinterpolationexpr) | 表示 [QuoteExpr](./syntax_package_api/syntax_package_classes.md#class-quoteexpr) 中由 `()` 括起的内部引用表达式。 |
| [QuoteToken](./syntax_package_api/syntax_package_classes.md#class-quotetoken) | 表示 `quote` 表达式节点内任意合法的 `token`。 |
| [RangeExpr](./syntax_package_api/syntax_package_classes.md#class-rangeexpr) | 表示包含区间操作符的表达式。 |
| [ReturnExpr](./syntax_package_api/syntax_package_classes.md#class-returnexpr) | 表示 `return` 表达式节点。 |
| [SourceFile](./syntax_package_api/syntax_package_classes.md#class-sourcefile) | 表示一个仓颉源码文件节点。 |
| [SpawnExpr](./syntax_package_api/syntax_package_classes.md#class-spawnexpr) | 表示 `Spawn` 表达式。 |
| [StaticInit](./syntax_package_api/syntax_package_classes.md#class-staticinit) | 表示一个静态初始化器。 |
| [StrInterpolationContent](./syntax_package_api/syntax_package_classes.md#class-strinterpolationcontent) | 表示字符串插值内容的节点。 |
| [StructDecl](./syntax_package_api/syntax_package_classes.md#class-structdecl) | 表示一个 `Struct` 声明节点。 |
| [SubscriptExpr](./syntax_package_api/syntax_package_classes.md#class-subscriptexpr) | 表示索引访问表达式。 |
| [SymbolRef](./syntax_package_api/syntax_package_classes.md#class-symbolref) | 表示一个引用表达式节点。 |
| [SynchronizedExpr](./syntax_package_api/syntax_package_classes.md#class-synchronizedexpr) | 表示 `synchronized` 表达式。 |
| [SyntaxTreeNode](./syntax_package_api/syntax_package_classes.md#class-syntaxtreenode) | 所有仓颉语法树节点的父类。 |
| [ThrowExpr](./syntax_package_api/syntax_package_classes.md#class-throwexpr) | 表示一个 `throw` 表达式。 |
| [TrailingClosureExpr](./syntax_package_api/syntax_package_classes.md#class-trailingclosureexpr) | 表示尾随闭包表达式。 |
| [TryCatch](./syntax_package_api/syntax_package_classes.md#class-trycatch) | 表示 `try-catch` 表达式节点。 |
| [TupleLiteral](./syntax_package_api/syntax_package_classes.md#class-tupleliteral) | 表示元组字面量节点。 |
| [TuplePattern](./syntax_package_api/syntax_package_classes.md#class-tuplepattern) | 表示 `Tuple` 模式节点。 |
| [TupleType](./syntax_package_api/syntax_package_classes.md#class-tupletype) | 表示元组类型节点。 |
| [TypeAlias](./syntax_package_api/syntax_package_classes.md#class-typealias) | 表示类型别名节点。 |
| [TypeAnnotation](./syntax_package_api/syntax_package_classes.md#class-typeannotation) | 所有类型节点的父类，继承自 `SyntaxTreeNode`。 |
| [TypeConvExpr](./syntax_package_api/syntax_package_classes.md#class-typeconvexpr) | 表示类型转换表达式。 |
| [TypePattern](./syntax_package_api/syntax_package_classes.md#class-typepattern) | 表示类型模式节点。 |
| [UnaryExpr](./syntax_package_api/syntax_package_classes.md#class-unaryexpr) | 表示一个一元操作表达式节点。 |
| [UnsafeExpr](./syntax_package_api/syntax_package_classes.md#class-unsafeexpr) | 表示一个不安全代码块。 |
| [VarDecl](./syntax_package_api/syntax_package_classes.md#class-vardecl) | 表示变量声明节点。 |
| [VarOrEnumPattern](./syntax_package_api/syntax_package_classes.md#class-varorenumpattern) | 表示当模式的标识符为 `Enum` 构造器时的节点。 |
| [VarPattern](./syntax_package_api/syntax_package_classes.md#class-varpattern) | 表示绑定模式节点。 |
| [VArrayExpr](./syntax_package_api/syntax_package_classes.md#class-varrayexpr) | 表示 `VArray` 表达式的实例节点。 |
| [VArrayType](./syntax_package_api/syntax_package_classes.md#class-varraytype) | 表示 `VArray` 类型节点。 |
| [WhileExpr](./syntax_package_api/syntax_package_classes.md#class-whileexpr) | 表示 `while` 表达式。 |
| [WildcardPattern](./syntax_package_api/syntax_package_classes.md#class-wildcardpattern) | 表示通配符模式节点。 |

### 枚举

|                 枚举名             |                功能                |
| --------------------------------- | ---------------------------------- |
| [AssignOpKind](./syntax_package_api/syntax_package_enums.md#enum-assignopkind) | 表示赋值操作符的类型，包括 `+=`、`=`、`-=`、 `!=` 等。|
| [AtomicCondition](./syntax_package_api/syntax_package_enums.md#enum-atomiccondition) | 表示原子类型的条件或 `let` 声明的解构匹配，包括 `let` 声明、表达式类型、有括号修饰的条件等。|
| [AtomicTypeKind](./syntax_package_api/syntax_package_enums.md#enum-atomictypekind) | 表示原子类型的种类，包括布尔类型、整数类型、浮点类型、空类型等。|
| [AtOpKind](./syntax_package_api/syntax_package_enums.md#enum-atopkind) | 表示注解操作符的种类，包括 `@`、`@!` 等。|
| [BinaryOpKind](./syntax_package_api/syntax_package_enums.md#enum-binaryopkind) | 表示二元操作符的类型，包括 `+`、`-`、`*`、 `/` 等。|
| [CommentKind](./syntax_package_api/syntax_package_enums.md#enum-commentkind) | 表示注释的类型，包括块注释、文档注释、行注释等。|
| [DiagnosticInfo](./syntax_package_api/syntax_package_enums.md#enum-diagnosticinfo) | 表示语法树诊断信息的类型，包括 `Warning`, `Error` 等。|
| [FuncKind](./syntax_package_api/syntax_package_enums.md#enum-funckind) | 表示声明函数的类型，包括外部函数、普通函数、构造器函数等。|
| [ImportKind](./syntax_package_api/syntax_package_enums.md#enum-importkind) | 表示引用的类型，包括 `Alias`、`All`、`Multi`、`Single` 等 。|
| [IncOrDecOpKind](./syntax_package_api/syntax_package_enums.md#enum-incordecopkind) | 表示自增自减表达式的操作符类型，包括 `++` 和 `--` 两种类型。|
| [LitConstKind](./syntax_package_api/syntax_package_enums.md#enum-litconstkind) | 表示字面量表达式的类型，包括 `BoolLiteral`、`FloatLiteral`、`IntergerLiteral`、`RuneLiteral`、`StringLiteral` 和 `UnitLiteral` 六种类型。|
| [LitConstStrKind](./syntax_package_api/syntax_package_enums.md#enum-litconststrkind) | 表示字符串字面量表达式的类型，包括 `JStringLiteral`、`MultiLineString`、`MultiLineRawString` 和 `StringLiteral` 四种类型。|
| [MacroExpandInput](./syntax_package_api/syntax_package_enums.md#enum-macroexpandinput) | 表示宏展开的输入形式，区分不同的宏调用语法形式，包括无括号和有括号形式的宏输入。|
| [ModifierKind](./syntax_package_api/syntax_package_enums.md#enum-modifierkind) | 表示修饰符的类型，包括 `Abstract`、 `Internal`、 `Mut` 等。|
| [PostActionMode](./syntax_package_api/syntax_package_enums.md#enum-postactionmode) | 表示控制 ASTVisitor 在访问节点完成后的行为策略，包括 `Continue`、`Stop` 等。|
| [PreActionMode](./syntax_package_api/syntax_package_enums.md#enum-preactionmode) | 表示控制 ASTVisitor 在访问节点前的行为策略，包括 `Continue`、`Skip`、`Stop` 等。|
| [PrefixTypeOpKind](./syntax_package_api/syntax_package_enums.md#enum-prefixtypeopkind) | 表示前缀类型中的前缀操作符类型，包括 `?` 等。|
| [QuoteExprContent](./syntax_package_api/syntax_package_enums.md#enum-quoteexprcontent) | 表示 `quote` 表达式中由 `()` 括起的内容类型，包括 [QuoteToken](./syntax_package_api/syntax_package_classes.md#class-quotetoken) 和 [QuoteInterpolationExpr](./syntax_package_api/syntax_package_classes.md#class-quoteinterpolationexpr) 两种。|
| [RangeKind](./syntax_package_api/syntax_package_enums.md#enum-rangekind) | 表示区间表达式的操作符类型，包括 `:` 和 `:=` 两种。|
| [StrLiteralPart](./syntax_package_api/syntax_package_enums.md#enum-strliteralpart) | 表示字符串字面量的不同部分，包括常量部分和字符串插值部分。|
| [UnaryOpKind](./syntax_package_api/syntax_package_enums.md#enum-unaryopkind) | 表示一元表达式的操作符类型，包括 `!` 和 `-` 两种。|
| [VarKind](./syntax_package_api/syntax_package_enums.md#enum-varkind) | 表示变量声明表达式的类型，包括 `Const`、 `Let` 和 `Var` 三种。|

### 结构体

|            结构体名          |           功能           |
| --------------------------- | ------------------------ |
| [CodePositionRange](./syntax_package_api/syntax_package_structs.md#struct-codepositionrange) | 表示节点位置信息。|