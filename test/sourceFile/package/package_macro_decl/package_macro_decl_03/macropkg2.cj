macro package pkg2

import std.ast.*
import pkg1.*

// 在宏定义里调用另一个宏（嵌套宏调用）
// 输入：一条 VarDecl，例如  private let a_: Int64 = 1
// 产出：原 VarDecl + 一个 public prop a: <type> { get(){ this.a_ } }
public macro Prop(input: Tokens): Tokens {
    let v = parseDecl(input)
    @getIdent[ident](input)

    return quote(
        $(input)
        public prop $(ident): $(decl.declType) {
            get() {
                this.$(v.identifier)
            }
        }
    )
}
