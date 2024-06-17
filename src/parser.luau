local types = require("types")
local Parser = {}

function Parser.parse(self: types.Compiler)
    local currline = 1
    local str = ""
    local callsMade = {}

    local lastToken: types.Token? = nil
    for i, v: types.Token in pairs(self.tokens) do

        local lastWasEnd = lastToken and lastToken._isEnd
        if lastWasEnd then
            currline += 1
        end

        if i == 1 or lastWasEnd then
            assert(v._type ~= "op", "Cannot start script with an operator. " .. " ln " .. tostring(currline))
        end

        if lastToken and not lastToken._isEnd then
            assert(self.keys.ast[lastToken._type][v._type], "Incorrect format " .. lastToken._type .. " cant " .. v._type .. " ln " .. tostring(currline))
        end

        local tokstr = v._value
        if v._type == "op" then
            tokstr = self.keys.op[v._value]
        end

        if v._type == "expr" then
            tokstr = self.keys.expr[v._value] .. " "
        end

        if v._type == "def" then
            tokstr = tokstr .. " "
        end

        if v._type == "call" then
            local pi = string.find(v._value, "%(")
            local cv = string.sub(v._value, 1, pi-1)
            if not callsMade[cv] then
                callsMade[cv] = true
                local addstr = cv.." = false\nif keys.func['" .. cv .. "'] then " .. cv .. " = keys.func." .. cv .. " end\n"
                str = addstr..str
            end
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

return Parser