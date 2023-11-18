-- This module re-exports the majority of the libraries in lib/ into a single namespace.
-- It also defines some small exports/modifications that aren't worth separating into their own module.

local std = {}

-- Forked libraries
local inspect    = require "lib.forked.inspect"

-- Local libraries
std.Bounds       = require "lib.local.Bounds"
local decorators = require "lib.local.decorators"
local exceptions = require "lib.local.exceptions"
std.Input        = require "lib.local.input"

-- Vendored libraries
std.copy         = require "lib.vendored.copy"
std.lume         = require "lib.vendored.lume"
std.Object       = require "lib.vendored.classic"
std.Vector       = require "lib.vendored.vector"
std.wasx         = require "lib.vendored.Wasx"

function std.inspect(...)
    local function process(value)
        if type(value) == "table" then
            local metatable = getmetatable(value)
            local newMetatable = nil
            if metatable ~= nil and metatable.__pretty ~= nil then
                newMetatable = { __pretty = metatable.__pretty  }
            end
            return setmetatable(
                std.copy(value),
                newMetatable
            )
        end
        return value
    end
    return inspect(..., { process = process })
end

function std.pretty(...)
    print(std.inspect(...))
end

function std.debug(name, x)
    print("[debug] "..name..": "..std.inspect(x))
end

local vectorTypeMetatable = getmetatable(std.Vector)
vectorTypeMetatable.__call = function(_, t)
    return std.Vector.new(t.x, t.y)
end

local vectorMetatable = getmetatable(std.Vector.new(0, 0))
vectorMetatable.__pretty = function(_, v)
    return "Vector("..v.x..", "..v.y..")"
    -- return "{ x="..v.x..", y="..v.y.." }"
end

std.abstractMethodException = exceptions.abstractMethodException
std.notImplementedException = exceptions.notImplementedException

std.argcheck = decorators.argcheck
std.enum = decorators.enum
std.overload = decorators.overload
std.InstanceMethod = decorators.InstanceMethod
std.Nil = decorators.Nil

return std
