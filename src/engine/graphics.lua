-- Extensions to love.graphics

local std = require "lib.std"

-- Function to draw a filled rectangle with rounded corners
function love.graphics.roundedRect(mode, bounds, cornerRadius, segments, blendMode)
    if not mode or not bounds or not cornerRadius or not segments then
        error("love.graphics.roundedRect: Missing required arguments.")
    end

    love.graphics.setBlendMode(blendMode or "alpha")

    local x, y, w, h = bounds.x1, bounds.y1, bounds.x2 - bounds.x1, bounds.y2 - bounds.y1
    local rx, ry = cornerRadius, cornerRadius

    love.graphics.rectangle(mode, x + rx, y, w - 2 * rx, h)
    love.graphics.rectangle(mode, x, y + ry, rx, h - 2 * ry)

    love.graphics.arc(mode, x + rx, y + ry, rx, math.rad(-180), math.rad(-90), segments)
    love.graphics.arc(mode, x + w - rx, y + ry, rx, math.rad(-90), 0, segments)
    love.graphics.arc(mode, x + w - rx, y + h - ry, rx, 0, math.rad(90), segments)
    love.graphics.arc(mode, x + rx, y + h - ry, rx, math.rad(90), math.rad(180), segments)
end

-- Function to draw a line with a specified thickness
function love.graphics.lineWithThickness(points, thickness, blendMode)
    if not points or not thickness then
        error("love.graphics.lineWithThickness: Missing required arguments.")
    end

    love.graphics.setBlendMode(blendMode or "alpha")
    love.graphics.setLineWidth(thickness)
    love.graphics.line(points)
    love.graphics.setLineWidth(1) -- Reset line width to default
end

-- Function to draw text with an outline
function love.graphics.printWithOutline(text, x, y, outlineWidth, color, outlineColor, font)
    if not text or not x or not y or not outlineWidth then
        error("love.graphics.printWithOutline: Missing required arguments.")
    end

    love.graphics.setColor(outlineColor or { 0, 0, 0, 1 })
    for i = 1, 8 do
        love.graphics.print(text, x - outlineWidth / 2 + i, y - outlineWidth / 2)
        love.graphics.print(text, x + outlineWidth / 2, y - outlineWidth / 2 + i)
        love.graphics.print(text, x - outlineWidth / 2 - i, y + outlineWidth / 2)
        love.graphics.print(text, x + outlineWidth / 2 - i, y + outlineWidth / 2)
    end

    love.graphics.setColor(color or { 1, 1, 1, 1 })
    love.graphics.print(text, x, y, 0, 1, 1, outlineWidth / 2, outlineWidth / 2, 0, 0, 0, font)
end

-- You can add more functions based on your requirements.
