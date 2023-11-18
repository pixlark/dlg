-- http://lua-users.org/wiki/CopyTable
local function copy(x)
    if type(x) == "table" then
        local copied = {}
        for key, value in next, x, nil do
            copied[key] = value
        end
        return copied
    else
        return x
    end
end

return copy
