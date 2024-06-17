local function range(tbl)
    return pairs(tbl)
end

local Expressions = {}

Expressions.op = {
    ["="] = "=",
    ["+"] = "+",
    ["-"] = "-",
    ["++"] = "+=1",
    ["--"] = "-=1",
    [":"] = ":",
    [","] = ","
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
    range = range
}

Expressions.ast = {
    def = {op = true, expr = true},
    expr = {def = true, expr = true, func = true, call = true},
    op = {def = true, op = true, expr = true},
    func = {def = true},
    call = {expr = true}
}

return Expressions