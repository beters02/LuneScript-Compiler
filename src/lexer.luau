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

    if string.find(tokenStr, "%(") then foundType = "call" end
    foundType = foundType or "def"

    return {_type = foundType, _value = tokenStr, _isEnd = isEnd} :: types.Token
end

function Lexer.Lex(self: types.Compiler, byteStr: string)
    local currtok = ""
    local lastc = ""

    local function finalizeToken(tokenStr)
        local token = false

        if tokenStr ~= "" and tokenStr ~= "\n" then
            token = createToken(self, tokenStr)
            currtok = ""

            local prev = self.tokens[#self.tokens]
            if prev and prev._type == "expr" and prev._value == "func" then
                token._type = "func"
            end

            table.insert(self.tokens, token)
            return token
        end

        if tokenStr == "\n" then
            self.tokens[#self.tokens]._isEnd = true
            currtok = ""
        end

        return token
    end

    byteStr:gsub(".", function(c)
        if c == " " then
            if currtok ~= "" then
                finalizeToken(currtok)
            end
            return
        end

        if c ~= "" then
            if self.keys.op[c] and not self.keys.op[c..c] then
                finalizeToken(currtok)
                finalizeToken(c)
                return
            elseif self.keys.op[lastc..c] then
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

    print(self.tokens)
    return self.tokens
end

return Lexer