# 遍历节点示例

## ASTVisitor 使用示例

ASTVisitor 是 SyntaxTreeNode 访问器的基类。

使用方式：

1. 继承 `ASTVisitor` 并重写 `preAction` / `postAction` 或特定 `visit*` 方法；
2. 调用 `walk(root)` 从任意节点开始遍历；
3. 通过返回 [PreActionMode](../syntax_package_api/syntax_package_enums.md#enum-preactionmode) 或 [PostActionMode](../syntax_package_api/syntax_package_enums.md#enum-postactionmode) 控制遍历流程。

假设我们有一段需要分析的代码：

<!-- compile -->

```cangjie
package a

main(){
  var expr = 1 + 2
  println(expr)
  var nextExpr = expr + 1
  println(nextExpr)
}
```

下面演示如何继承 `ASTVisitor`，在遍历过程中统计所有 `BinaryExpr` 节点，并在遇到第一个 `CallExpr` 后立即停止遍历：

<!-- compile -->

```cangjie
import stdx.syntax.*

// 1. 继承 ASTVisitor
public class BinaryCounter <: ASTVisitor {
    public var count = 0

    // 2. 重写 preAction，只在进入节点前做判断
    public override func preAction(node: SyntaxTreeNode): PreActionMode {
        match (node) {
            // 遇到 BinaryExpr 时计数 +1 并继续
            case _: BinaryExpr =>
                count += 1
                return PreActionMode.Continue

            // 遇到 CallExpr 立即停止整个遍历
            case _: CallExpr =>
                println("Found CallExpr, stop traversal")
                return PreActionMode.Stop

            // 其它节点保持默认行为
            case _ => PreActionMode.Continue
        }
    }
}

// 3. 使用示例
main() {
    let root = parseFile("example.cj")

    let counter = BinaryCounter()
    counter.walk(root.node.getOrThrow())          // 开始遍历

    println("Total BinaryExpr count: ${counter.count}")
}
```

运行流程：

1. `walk(root)` 从根节点开始深度优先遍历；
2. 每进入一个节点会调用 `preAction`：
   - 如果是 `BinaryExpr`，计数器自增并返回 `CONTINUE` 继续；
   - 如果是 `CallExpr`，返回 `STOP`，遍历立即终止；
3. 最终打印统计结果。

运行结果为：

```text
Found CallExpr, stop traversal
Total BinaryExpr count: 1
```
