local luau = require("@lune/luau")
local types = require("types")
local keys = require("keys")
local lexer = require("lexer")
local parser = require("parser")

local testByteStr = [[
    a = 1
    a++
    a = a + 1
    a--
    print(a)

    func b()
        print('worked')
    end
    b()

    tbl = {a = 1}
    print(tbl)

    for i, v in range(tbl) do
        print(v)
    end
]]

local self: types.Compiler = {
    tokens = {},
    keys = keys,
}

local function compile()
    print('Beginning compilation for:\n' .. testByteStr)

    lexer.Lex(self, testByteStr)
    local str = parser.parse(self)
    local bytecode = luau.compile(str)

    local lo: luau.LoadOptions = {
        environment = {keys = self.keys}
    }
    local cb = luau.load(bytecode, lo)
    cb()
end

compile()