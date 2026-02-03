# 遍历时修改节点示例

## ASTRewriter 使用示例

ASTRewriter 是 SyntaxTreeNode 重写器的基类。

使用方式：

1. 继承 `ASTRewriter` 并重写 `rewrite` 方法，可实现自定义节点转换；
2. 调用 `walk` 从任意节点开始遍历, 对每一个节点，遍历完其所有的子节点后，会调用自定义的 `rewrite` 方法，对该节点进行重写；
3. 调用 `walk` 时，可以选择是否断开与父节点的关联，若 `detach` 为 `true`，遍历后产生一颗独立的新树，新树的父节点为空；若 `detach` 为 `false`，会向上刷新父节点中的内容；
4. 返回修改后的新节点。

假设我们有一段需要修改的代码，现在需要为所有函数自动生成空的注释模板，方便后续补全文档：

<!-- compile -->

```cangjie
package a

struct Rectangle {
    public var width: Int64
    public var height: Int64

    public init(width: Int64, height: Int64) {
        this.width = width
        this.height = height
    }

    public func area() {
        width * height
    }
}
```

下面演示如何继承 `ASTRewriter`，在遍历过程生成 API 文档注释模板：

<!-- compile -->

```cangjie
import stdx.syntax.*
import std.collection.ArrayList

// 1. 继承 ASTRewriter
class DocStubGenerator <: ASTRewriter {
    public override func rewrite(node: SyntaxTreeNode): SyntaxTreeNode {
        match (node) {
            case fn: FuncDecl =>
                let comment = Comment(
                    CommentKind.Document,
                    "// @brief describe ${fn.name}"
                )
                let newComments = ArrayList<Comment>(fn.comments)
                newComments.add(comment)
                // 2. 修改 FuncDecl 中的 comments 属性
                let f = FuncDecl(
                    fn.body,
                    fn.genericConstraints,
                    fn.genericParams,
                    fn.kind,
                    fn.name,
                    fn.params,
                    fn.retTyAnnotation,
                    annotations: fn.annotations,
                    modifiers: fn.modifiers,
                    comments: newComments.toArray()
                )
                return f
            case _ => return node
        }
    }
}

// 3. 使用示例
main() {
    let root = parseFile("rewrite.cj")

    let generator = DocStubGenerator()
    let newNode = generator.walk(root.node.getOrThrow(), detach: true)

    println(newNode)
}
```

运行结果为：

```text
package a

struct Rectangle {
    public var width: Int64
    public var height: Int64

    // @brief describe init
public init(width: Int64, height: Int64) {
        this.width = width
        this.height = height
    }

    // @brief describe area
public func area() {
        width * height
    }
}
```
