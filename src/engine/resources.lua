local std = require "lib.std"

--[[
    Resource management
]]--

---@class (exact) ResourceManager
---@field sprites table
---@field fonts table
---@operator call:ResourceManager
local ResourceManager = std.Object:extend()

function ResourceManager:new()
    self.sprites = {}
    self.fonts = {}
end

function ResourceManager:bindSprite(name, path)
    self.sprites[name] = path
end

function ResourceManager:bindFont(name, path)
    self.fonts[name] = path
end

function ResourceManager:sprite(name)
    return self.sprites[name]
end

function ResourceManager:font(name)
    return self.fonts[name]
end

return ResourceManager
