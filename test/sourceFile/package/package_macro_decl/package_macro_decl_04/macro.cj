macro package define

import std.ast.*

// 外层：收集所有 Inner 发来的 identifierName，然后生成一个 getCnt()，把它们加起来
public macro Outer(input: Tokens): Tokens {
    let messages = getChildMessages("Inner")

    let getTotalFunc = quote(
        public func getCnt() {
    )
    for (m in messages) {
        let identName = m.getString("identifierName")
        getTotalFunc.append(Token(TokenKind.IDENTIFIER, identName))
        getTotalFunc.append(quote(+))
    }
    getTotalFunc.append(quote(0))
    getTotalFunc.append(quote(}))

    let funcDecl = parseDecl(getTotalFunc)
    let decl = (parseDecl(input) as ClassDecl).getOrThrow()
    decl.body.decls.append(funcDecl)
    return decl.toTokens()
}

// 内层：强制要求自己必须处在 Outer 的语境内，然后把变量名发消息给 Outer
public macro Inner(input: Tokens): Tokens {
    assertParentContext("Outer")
    let decl = parseDecl(input)
    setItem("identifierName", decl.identifier.value)
    return input
}
