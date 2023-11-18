local std = require "lib.std"
local Vector = std.Vector

-- local function overloadVectorMethod(func)
--     return std.overload {
--         std.InstanceMethod,
--         "table", func,
--         "number", "number", function (self, x, y) func(self, Vector.new(x, y)) end,
--     }
-- end

--[[
    Screen (represents entire drawing area)
]]--

local Screen = std.Object:extend()

function Screen:new()
end

function Screen:width()
    local width, _, _ = love.window.getMode()
    return width
end

function Screen:height()
    local _, height, _ = love.window.getMode()
    return height
end

function Screen:_getVirtualScaleFactor()
    local screenWidth, screenHeight = self:width(), self:height()

    local aspect = screenWidth / screenHeight
    if aspect >= 1.0 then
        -- Screen is wider than it is tall
        return screenHeight / 2.0
    elseif aspect < 1.0 then
        -- Screen is taller than it is wide
        return screenWidth / 2.0
    end
end

function Screen:_getVirtualOffset()
    local screenWidth, screenHeight = self:width(), self:height()
    return screenWidth / 2.0, screenHeight / 2.0
end

function Screen:getTransform()
    local scaleFactor = self:_getVirtualScaleFactor()
    local offsetX, offsetY = self:_getVirtualOffset()
    return love.math.newTransform()
        :translate(offsetX, offsetY)
        :scale(scaleFactor, scaleFactor)
end

--[[
function Screen:toRealPos(virtualPos)
    local scaleFactor = self:_getVirtualScaleFactor()
    local offsetX, offsetY = self:_getVirtualOffset()

    local realX, realY =
        (virtualPos.x * scaleFactor) + offsetX,
        (virtualPos.y * scaleFactor) + offsetY

    return Vector.new(realX, realY)
end

function Screen:toRealBounds(bounds)
    local topLeft = self:toRealPos(Vector.new(bounds.x1, bounds.y1))
    local bottomRight = self:toRealPos(Vector.new(bounds.x2, bounds.y2))
    return std.Bounds.from(topLeft, bottomRight)
end

function Screen:toRealLength(virtualSize)
    local scaleFactor = self:_getVirtualScaleFactor();
    local realSize = virtualSize * scaleFactor

    return realSize
end
]]--

function Screen:clipToAspectRatio(aspect, color)
    love.graphics.setColor(unpack(color))

    local screenWidth, screenHeight = self:width(), self:height()
    local realAspect = screenWidth / screenHeight

    local bars = {}

    if realAspect == aspect then
        return
    elseif realAspect > aspect then
        local barAspect = (realAspect - aspect) / 2.0
        local barWidth = barAspect * screenHeight

        -- Left-side bar
        table.insert(bars, { x1 = 0.0, y1 = 0.0, x2 = barWidth, y2 = screenHeight })

        -- Right-side bar
        table.insert(bars, { x1 = screenWidth - barWidth, y1 = 0.0, x2 = screenWidth, y2 = screenHeight })
    else
        local barAspect = ((1.0 / realAspect) - (1.0 / aspect)) / 2.0
        local barHeight = barAspect * screenWidth

        -- Top bar
        table.insert(bars, { x1 = 0.0, y1 = 0.0, x2 = screenWidth, y2 = barHeight })

        -- Bottom bar
        table.insert(bars, { x1 = 0.0, y1 = screenHeight - barHeight, x2 = screenWidth, y2 = screenHeight })
    end

    for _, bar in ipairs(bars) do
        love.graphics.rectangle("fill", bar.x1, bar.y1, bar.x2 - bar.x1, bar.y2 - bar.y1)
    end
end

--[[
    Canvas (represents virtualized region of a Screen or another Canvas)
]]--

local Canvas = std.Object:extend()

Canvas.new = std.argcheck {
    std.InstanceMethod,
    "bounds",
    function (self, t)
        self.bounds = t.bounds
        self.parent = t.parent
        self.scale  = t.scale or 1.0

        local anchor = t.anchor
        if anchor == nil then
            anchor = "topleft"
        end

        if anchor == "topleft" then
            self.anchor = Vector { x = self.bounds.x1, y = self.bounds.y1  }
        elseif anchor == "topright" then
            self.anchor = Vector { x = self.bounds.x2, y = self.bounds.y1 }
        elseif anchor == "bottomleft" then
            self.anchor = Vector { x = self.bounds.x1, y = self.bounds.y2 }
        elseif anchor == "bottomright" then
            self.anchor = Vector { x = self.bounds.x2, y = self.bounds.y2 }
        elseif anchor == "center" then
            self.anchor = Vector {
                x = (self.bounds.x1 + self.bounds.x2) / 2.0,
                y = (self.bounds.y1 + self.bounds.y2) / 2.0,
            }
        else
            self.anchor = anchor
        end
    end
}

--[[function Canvas:toRealPos(pos)
    local scaledPos = pos * self.scale
    local offsetPos = self.anchor + scaledPos

    if self.parent ~= nil then
        return self.parent:toRealPos(offsetPos)
    else
        return Game.screen:toRealPos(offsetPos)
    end
end

function Canvas:toRealBounds(bounds)
    local topLeft = self:toRealPos(Vector.new(bounds.x1, bounds.y1))
    local bottomRight = self:toRealPos(Vector.new(bounds.x2, bounds.y2))
    return std.Bounds.from(topLeft, bottomRight)
end]]--

function Canvas:getTransform()
    return love.math.newTransform()
        :translate(self.anchor.x, self.anchor.y)
end

function Canvas:width()
    return self.virtualBounds.x2 - self.virtualBounds.x1
end

function Canvas:height()
    return self.virtualBounds.y2 - self.virtualBounds.y1
end

function Canvas:clearStencil()
    local function clear()
        love.graphics.clear(1, 1, 1, 1)
    end
    love.graphics.setStencilTest("always", 0)
    love.graphics.stencil(clear, "replace", 1)
end

function Canvas:setStencil()
    local function clear()
        love.graphics.clear(1, 1, 1, 1)
    end
    local function rect()
        -- local realBounds = Game.screen:toRealBounds(self.bounds)
        local transform = self:getTransform()
        local left, top = transform:transformPoint(self.bounds.x1, self.bounds.y1)
        local right, bottom = transform:transformPoint(self.bounds.x2, self.bounds.y2)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle(
            "fill",
            left, top,
            right - left, bottom - top
        )
    end
    love.graphics.setStencilTest("greater", 0)
    love.graphics.stencil(clear, "replace", 0)
    love.graphics.stencil(rect, "replace", 1)
end

function Canvas:withStencil(f)
    self:setStencil()
    f()
    self:clearStencil()
end

return {
    Screen = Screen,
    Canvas = Canvas,
}
