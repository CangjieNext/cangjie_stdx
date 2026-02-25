macro package pkg1

import std.ast.*

// 目标：从一个 VarDecl 里拿到变量名，截掉末尾 '_'，写到一个 Token 变量里（由 attr 指定变量名）
public macro getIdent(attr: Tokens, input: Tokens): Tokens {
    return quote(
        let decl = (parseDecl(input) as VarDecl).getOrThrow()
        let name = decl.identifier.value
        let size = name.size - 1
        let $(attr) = Token(TokenKind.IDENTIFIER, name[0..size])
    )
}
