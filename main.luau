local luau = require("@lune/luau")

export type Token = {
    _type: TokenType,
    _value: string,
    _isEnd: boolean,
}

export type TokenType = "op" | "expr" | "func" | "def"

local testByteStr = [[
    a = 1
    a++
    print(a)
]]

local op = {
    ["="] = "=",
}

local expr = {
    ["++"] = "+=1"
}

local func = {
    print = print
}

local ast = {
    def = {op = true, expr = true},
    expr = {def = true},
    op = {def = true}
}

local reference = {op = op, expr = expr, func = func}

local function createToken(tokenStr): Token
    local isEnd = false
    if string.match(tokenStr, "\n") then
        tokenStr = string.gsub(tokenStr, "\n", "")
        isEnd = true
    end

    local foundType = false

    local p = string.find(tokenStr, "%(")
    if p then
        foundType = "func"

        local tempstr = string.sub(tokenStr, 1, p-1)
        assert(func[tempstr], "Cant find function " .. tempstr)
    end

    for _, toktype in pairs({"op", "expr", "func"}) do
        if reference[toktype][tokenStr] then
            foundType = toktype
            break
        end
    end

    foundType = foundType or "def"

    return {_type = foundType, _value = tokenStr, _isEnd = isEnd} :: Token
end

local function lex(byteStr: string)
    local currtok = ""
    local lastc = ""
    local tokens = {}

    local function finalizeToken(tokenStr)
        local token = false

        if tokenStr ~= "" and tokenStr ~= "\n" then
            token = createToken(tokenStr)
            table.insert(tokens, token)
            currtok = ""
            return token
        end

        if tokenStr == "\n" then
            tokens[#tokens]._isEnd = true
        end

        return token
    end

    byteStr:gsub(".", function(c)
        -- do something with c

        if c == " " then
            if currtok ~= "" then
                finalizeToken(currtok)
            end
            return
        end

        if c ~= "" then
            if op[c] then
                finalizeToken(currtok)
                finalizeToken(c)
                return
            elseif expr[lastc..c] then
                finalizeToken(string.sub(currtok, 1, string.len(currtok)-1))
                finalizeToken(lastc..c)
                return
            end
            lastc = c
        end

        currtok = currtok .. c
    end)

    -- final token
    finalizeToken(currtok)

    print(tokens)
    return tokens
end

local function parse(tokens)
    local str = ""

    local lastToken: Token? = nil
    for i, v: Token in pairs(tokens) do

        if i == 1 or lastToken and lastToken._isEnd then
            assert(v._type ~= "op", "Cannot start script with an operator.")
        end

        if lastToken and not lastToken._isEnd then
            assert(ast[lastToken._type][v._type], "Incorrect format " .. lastToken._type .. " cant " .. v._type)
        end

        local tokstr = v._value
        if v._type == "op" then
            tokstr = op[v._value]
        end

        if v._type == "expr" then
            tokstr = expr[v._value]
        end

        str = str .. tokstr
        if v._isEnd then
            str = str .. "\n"
        end

        lastToken = v
    end

    print('Parsed!')
    print(str)
    return str
end

local function compile()
    print('Beginning compilation for:\n' .. testByteStr)

    local tokens = lex(testByteStr)
    local str = parse(tokens)
    local bytecode = luau.compile(str)

    local cb = luau.load(bytecode)
    cb()
end

compile()