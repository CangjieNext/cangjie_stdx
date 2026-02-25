macro package macro_attr

import std.ast.*

// 属性宏：两个 Tokens 入参（attrTokens + inputTokens）
// 调用形式：@Foo[...](...)  或  @Foo[...] <Decl>
public macro Foo(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    return attrTokens + inputTokens
}

// 一个更“实用”的属性宏：给声明前面加上 attribute 里的修饰符/注解等
// 用法示意（仅示意，不在此文件写调用）：
//   @AttachPrefix[public] struct Data { ... }
public macro AttachPrefix(attrTokens: Tokens, inputTokens: Tokens): Tokens {
    return attrTokens + Token(TokenKind.NL) + inputTokens
}
