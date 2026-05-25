# 函数

## func parseFile(String)

```cangjie
public func parseFile(filePath: String): ParsingResult<SourceFile>
```

功能：用于解析一个文本文件，获取一个符合仓颉语法的 [SourceFile](syntax_package_classes.md#class-sourcefile) 类型的抽象语法树。

参数：

- filePath: String - 待解析文件的路径，可以是绝对路径或相对路径。

返回值：

- ParsingResult\<SourceFile> - 一个根节点为 [SourceFile](syntax_package_classes.md#class-sourcefile) 类型的抽象语法树。

异常：

- Exception - 当输入的 `filePath` 不是正确的仓颉源码路径时，抛出异常，异常中包含报错提示信息。

示例：

<!-- compile -->
```cangjie
import stdx.syntax.*

main() {
    // 解析指定路径的文件，获取一个 SourceFile 类型的语法树
    if (let Some(node) <- parseFile("a.cj").node) {

        // 打印该语法树， 应与原文件中内容完全一致
        println(node.toString())
    }
}
```

## func parsePackage(String)

```cangjie
public func parsePackage(dirPath: String): ParsingResult<Package>
```

功能：用于解析一个文件目录，获取一个符合仓颉语法的 [Package](syntax_package_classes.md#class-package) 类型的抽象语法树。

参数：

- dirPath: String - 待解析的文件目录，可以是绝对路径或相对路径。

返回值：

- ParsingResult\<Package> - 一个根节点为 [Package](syntax_package_classes.md#class-package) 类型的抽象语法树。

异常：

- Exception - 当输入的 `dirPath` 不是正确的仓颉包路径时，抛出异常，异常中包含报错提示信息。

示例：

<!-- compile -->
```cangjie
import stdx.syntax.*

main() {
    // 解析指定路径的目录，获取一个 Package 类型的语法树
    if (let Some(pkg) <- parsePackage("/path/to/dir").node) {

        // 打印该语法树，包内的文件按文件名字母序排序，对每个文件依次打印文件名和文件内容
        println(pkg.toString())
    }
}
```

## func parseText(String)

```cangjie
public func parseText(programText: String): ParsingResult<SyntaxTreeNode>
```

功能：用于解析一个字符串文本，获取一个符合仓颉语法的抽象语法树节点。

> **注意：**
>
> - 此函数当前仅支持从文本解析出部分声明和大部分表达式节点，具体支持的节点如下：
> - 声明节点：`VarDecl`，`TypeAlias`，`StructDecl`，`StaticInit`，`PropDecl`，`MainDecl`，`MacroDecl`，`InterfaceDecl`，`FuncDecl` （类的主构造函数不支持），`EnumDecl`，`ClassDecl`
> - 表达式节点：除 `OptionalExpr`，`MacroExpandExpr` 和 `StrInterpolationContent` 外的所有表达式节点。

参数：

- programText: String - 待解析的字符串文本。

返回值：

- ParsingResult\<SyntaxTreeNode> - 一个根节点为 [SyntaxTreeNode](syntax_package_classes.md#class-syntaxtreenode) 类型的抽象语法树节点。

异常：

- Exception - 当根据输入文本无法正确解析出单个语法树节点时（包括解析出错和输入包含多个节点等情况），抛出异常，异常中包含报错提示消息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    // 解析字符串，获得一个语法树节点，示例中为 ClassDecl 类型节点
    if (let Some(node) <- parseText("class A {}").node) {

        // 输出该节点
        println("node is ClassDecl: ${node is ClassDecl}")
        println("node.toString(): ${node.toString()}")
    }
}
```

运行结果：

```text
node is ClassDecl: true
node.toString(): class A {}
```

## func parseTokens(Tokens, Bool)

```cangjie
public func parseTokens(tokens: Tokens, refreshPos!: Bool = true): ParsingResult<SyntaxTreeNode>
```

功能：用于解析一组词法单元，获取一个符合仓颉语法的抽象语法树节点。

> **注意：**
>
> - 此函数当前仅支持从输入的一组词法单元解析出部分声明和大部分表达式节点，具体支持的节点如下：
> - 声明节点：`VarDecl`，`TypeAlias`，`StructDecl`，`StaticInit`，`PropDecl`，`MainDecl`，`MacroDecl`，`InterfaceDecl`，`FuncDecl` （类的主构造函数不支持），`EnumDecl`，`ClassDecl`
> - 表达式节点：除 `OptionalExpr`，`MacroExpandExpr` 和 `StrInterpolationContent` 外的所有表达式节点。

参数：

- tokens: Tokens - 待解析的一组词法单元。
- refreshPos!: Bool - 是否刷新输入词法单元的位置信息，`true` 表示刷新位置信息，`false` 表示不刷新，保留原始位置信息，默认 `true`。

返回值：

- ParsingResult\<SyntaxTreeNode> - 一个根节点为 [SyntaxTreeNode](syntax_package_classes.md#class-syntaxtreenode) 类型的抽象语法树节点。

异常：

- Exception - 当根据输入词法单元无法正确解析出单个语法树节点（包括解析出错和输入包含多个节点等情况）或输入词法单元的位置信息有误时，抛出异常，异常中包含报错提示消息。

示例：

<!-- verify -->
```cangjie
import stdx.syntax.*

main() {
    let tokens = quote(
        class A      {let x=10}
    )
    
    // 解析 Tokens 获得一个语法树节点，示例中为 ClassDecl 类型节点
    // 默认刷新位置信息
    if (let Some(node) <- parseTokens(tokens).node) {

        // 输出该节点
        println("node is ClassDecl: ${node is ClassDecl}")
        println("node.toString(): ${node.toString()}")
    }

    // 设置不刷新位置信息
    if (let Some(node) <- parseTokens(tokens, refreshPos: false).node) {

        // 输出该节点
        println("node is ClassDecl: ${node is ClassDecl}")
        println("node.toString(): ${node.toString()}")
    }
}
```

运行结果：

```text
node is ClassDecl: true
node.toString(): class A { let x = 10 }
node is ClassDecl: true
node.toString(): class A      {let x=10}
```
