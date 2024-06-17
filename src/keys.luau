local function range(tbl)
    return pairs(tbl)
end

local function _range(tbl, callback)
    for i, v in pairs(tbl) do
        callback(i, v)
    end
end

local Expressions = {}

Expressions.op = {
    ["="] = "=",
    ["+"] = "+",
    ["-"] = "-",
    ["++"] = "+=1",
    ["--"] = "-=1",
    [":"] = ":",
    [","] = ",",
    [".."] = ".."
}

Expressions.expr = {
    func = "function",
    ["end"] = "end",
    ["type"] = "type",
    ["export"] = "export",
    ["{"] = "{",
    ["}"] = "}",
    ["for"] = "for",
    ["in"] = "in",
    ["do"] = "do"
}

Expressions.func = {
    print = print,
    range = _range
}

Expressions.ast = {
    def = {op = true, expr = true, call = true},
    expr = {def = true, expr = true, func = true, call = true},
    op = {def = true, op = true, expr = true, call = true},
    func = {def = true, op = true},
    call = {expr = true, op = true, def = true}
}

return Expressions