export type Token = {
    _type: TokenType,
    _value: string,
    _isEnd: boolean,
}

export type TokenType = "op" | "expr" | "func" | "def" | "call"

export type Keys = {
    op: {string: string},
    expr: {string: string},
    func: {string: (...any)->(...any)},
    ast: {string: {string: boolean}}
}

export type Compiler = {
    tokens: {Token},
    keys: Keys,
}

return nil