local function range(tbl)
    return pairs(tbl)
end

local function _range(tbl, callback, s, e)
    if s or e then
        s = s or 1
        e = e or #tbl

        for i = s, e, 1 do
            callback(i, tbl[i])
        end
        return
    end

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
    expr = {def = true, expr = true, func = true, call = true, op = true},
    op = {def = true, op = true, expr = true, call = true},
    func = {def = true, op = true},
    call = {expr = true, op = true, def = true}
}

return Expressions