macro package macro_attr

import std.ast.*

public macro Foo(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    return attrTokens + inputTokens
}


public macro AttachPrefix(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    return attrTokens + Token(TokenKind.NL) + inputTokens
}
