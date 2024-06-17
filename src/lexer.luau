local types = require("types")
local Lexer = {}

local function createToken(self: types.Compiler, tokenStr: string): types.Token
    local isEnd = false

    if string.match(tokenStr, "\n") then
        tokenStr = string.gsub(tokenStr, "\n", "")
        isEnd = true
    end

    local foundType = false

    for _, toktype in pairs({"op", "expr", "func"}) do
        if self.keys[toktype][tokenStr] then
            foundType = toktype
            break
        end
    end

    if string.find(tokenStr, "%(") then 
        foundType = "call" 
    elseif string.find(tokenStr, "%)") then
        foundType = "expr" 
    end
    foundType = foundType or "def"

    return {_type = foundType, _value = tokenStr, _isEnd = isEnd} :: types.Token
end

local function finalizeToken(self: types.Compiler, tokenStr: string)
    local token = false

    if tokenStr ~= "" and tokenStr ~= "\n" then
        token = createToken(self, tokenStr)
        self.currToken = ""

        local prev = self.tokens[#self.tokens]
        if prev and prev._type == "expr" and prev._value == "func" then
            token._type = "func"
        end

        table.insert(self.tokens, token)
        return
    end

    if tokenStr == "\n" then
        self.tokens[#self.tokens]._isEnd = true
        self.currToken = ""
    end
end

function Lexer.Lex(self: types.Compiler, byteStr: string)
    local lastc = ""

    byteStr:gsub(".", function(c)

        if c == " " then
            if self.currToken ~= "" then
                finalizeToken(self, self.currToken)
            end
            return
        end

        if c ~= "" then
            if self.keys.op[c] and not self.keys.op[c..c] then
                finalizeToken(self, self.currToken)
                finalizeToken(self, c)
                return
            elseif self.keys.op[lastc..c] then
                finalizeToken(self, string.sub(self.currToken, 1, string.len(self.currToken)-1))
                finalizeToken(self, lastc..c)
                return
            end
            lastc = c
        end

        self.currToken = self.currToken .. c
    end)

    -- final token
    finalizeToken(self, self.currToken)

    print(self.tokens)
    return self.tokens
end

return Lexer