macro package define

import std.ast.*


public macro Outer(input: Tokens): Tokens {
    let messages = getChildMessages("Inner")

    let getTotalFunc = quote(
        public func getCnt() {
    )
    for (m in messages) {
        let identName = m.getString("identifierName")
        getTotalFunc.concat(quote(+))
    }
    getTotalFunc.concat(quote(0))
    getTotalFunc.concat(quote(}))

    let decl = (parseDecl(input) as ClassDecl).getOrThrow()
    return decl.toTokens()
}

public macro Inner(input: Tokens): Tokens {
    assertParentContext("Outer")
    let decl = parseDecl(input)
    setItem("identifierName", decl.identifier.value)
    return input
}
