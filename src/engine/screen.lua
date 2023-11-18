local std = require "lib.std"

local Screen = std.Object:extend()

function Screen:new(aspect, backgroundColor)
    self.aspect = aspect
    self.backgroundColor = backgroundColor
    self.scissorStack = {}
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

-- override
function Screen:getTransform()
    local scaleFactor = self:_getVirtualScaleFactor()
    local offsetX, offsetY = self:_getVirtualOffset()
    return love.math.newTransform()
        :translate(offsetX, offsetY)
        :scale(scaleFactor, scaleFactor)
end

function Screen:startRender()
    love.graphics.clear(self.backgroundColor)
end

function Screen:finishRender()
    local screenWidth, screenHeight = self:width(), self:height()
    local realAspect = screenWidth / screenHeight

    local bars = {}

    if realAspect == self.aspect then
        return
    elseif realAspect > self.aspect then
        local barAspect = (realAspect - self.aspect) / 2.0
        local barWidth = barAspect * screenHeight

        -- Left-side bar
        table.insert(bars, { x1 = 0.0, y1 = 0.0, x2 = barWidth, y2 = screenHeight })

        -- Right-side bar
        table.insert(bars, { x1 = screenWidth - barWidth, y1 = 0.0, x2 = screenWidth, y2 = screenHeight })
    else
        local barAspect = ((1.0 / realAspect) - (1.0 / self.aspect)) / 2.0
        local barHeight = barAspect * screenWidth

        -- Top bar
        table.insert(bars, { x1 = 0.0, y1 = 0.0, x2 = screenWidth, y2 = barHeight })

        -- Bottom bar
        table.insert(bars, { x1 = 0.0, y1 = screenHeight - barHeight, x2 = screenWidth, y2 = screenHeight })
    end

    love.graphics.setColorWithTable(self.backgroundColor)
    for _, bar in ipairs(bars) do
        love.graphics.rectangle("fill", bar.x1, bar.y1, bar.x2 - bar.x1, bar.y2 - bar.y1)
    end
end

function Screen:pushScissor(bounds)
    table.insert(self.scissorStack, bounds)
    love.graphics.setScissor(bounds.x1, bounds.y1, bounds.x2 - bounds.x1, bounds.y2 - bounds.y1)
end

function Screen:popScissor()
    table.remove(self.scissorStack)
    if #self.scissorStack == 0 then
        love.graphics.setScissor(0, 0, self:width(), self:height())
    else
        local newScissor = self.scissorStack[#self.scissorStack]
        love.graphics.setScissor(newScissor.x1, newScissor.y1, newScissor.x2 - newScissor.x1, newScissor.y2 - newScissor.y1)
    end
end

local Frame = std.Object:extend()

Frame.new = std.argcheck {
    std.InstanceMethod,
    -- Required
    "anchor", "size", "clipped",
    -- Optional
    {"scale", 1.0},
    {"anchorType", "topleft"},
    {"parent", std.Nil},

    function(self, t)
        if t.scale == nil then
            t.scale = 1.0
        end

        if t.anchorType == nil then
            t.anchorType = "topleft"
        end

        self.anchor = t.anchor
        self.size = t.size
        self.scale = t.scale
        self.anchorType = t.anchorType
        self.parent = t.parent
    end
}

function Frame:_getVirtualScaleFactor()
    local aspect = self.size.x / self.size.y
    local scale

    if aspect >= 1.0 then
        -- Screen is wider than it is tall
        local localHeight = self.size.y
        local screenHeight = 2.0

        scale = localHeight / screenHeight
    elseif aspect < 1.0 then
        -- Screen is taller than it is wide
        local localWidth = self.size.x
        local screenWidth = 2.0

        scale = localWidth / screenWidth
    end

    if self.anchorType == "topleft" then
        -- Adjust coordinate system to be [0, 1]x[0,1] instead of [-1, 1]x[-1, 1]
        -- when our anchor is in the top-left
        return scale * 2
    else
        return scale
    end
end

function Frame:getParentTransform()
    if self.parent ~= nil then
        std.notImplementedException()
    else
        return love.math.newTransform()
    end
end

function Frame:getBounds()
    if self.anchorType == "topleft" then
        return std.Bounds.from(self.anchor, self.anchor + self.size)
    elseif self.anchorType == "center" then
        local radius = self.size / 2.0
        return std.Bounds.from(self.anchor - radius, self.anchor + radius)
    else
        error()
    end
end

function Frame:pixelLength(pixels)
    local baseTransform = Game.screen:getTransform()
    local transform = baseTransform:apply(self:getTransform())
    local inverseTransform = transform:inverse()

    local origin = std.Vector.new(0, 0)
    local pixelsPoint = std.Vector.new(pixels, 0)

    local inverseOrigin = std.Vector.new(inverseTransform:transformPoint(origin.x, origin.y))
    local inversePixelsPoint = std.Vector.new(inverseTransform:transformPoint(pixelsPoint.x, pixelsPoint.y))

    return inverseOrigin:dist(inversePixelsPoint)
end

function Frame:getTransform()
    local scale = self:_getVirtualScaleFactor()
    return self:getParentTransform()
        :translate(self.anchor.x, self.anchor.y)
        :scale(scale, scale)
end

function Frame:push()
    if self.parent ~= nil then
        std.notImplementedException()
    end

    local localBounds = self:getBounds()
    local screenBounds = std.Bounds.from(
        std.Vector.new(love.graphics.transformPoint(localBounds.x1, localBounds.y1)),
        std.Vector.new(love.graphics.transformPoint(localBounds.x2, localBounds.y2))
    )

    Game.screen:pushScissor(screenBounds)

    love.graphics.push()
    love.graphics.applyTransform(self:getTransform())
end

function Frame:pop()
    love.graphics.pop()

    Game.screen:popScissor()

    if self.parent ~= nil then
        std.notImplementedException()
    end
end

function Frame:draw(func)
    self:push()
    func()
    self:pop()
end

function Frame:debugDrawBounds()
    local bounds = self:getBounds()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setLineWidth(0.005)
    love.graphics.rectangle("line", bounds.x1, bounds.y1, bounds.x2 - bounds.x1, bounds.y2 - bounds.y1)
end

return {
    Screen = Screen,
    Frame = Frame,
}
