-- Extensions to love.graphics

local std = require "lib.std"

function love.graphics.rectWithBounds(mode, bounds, blendMode)
    if not mode or not bounds then
        error("love.graphics.rectWithBounds: Missing required arguments.")
    end

    love.graphics.setBlendMode(blendMode or "alpha")
    love.graphics.rectangle(mode, bounds.x1, bounds.y1, bounds.x2 - bounds.x1, bounds.y2 - bounds.y1)
end

function love.graphics.setColorWithTable(table)
    local defaultColor = { red = 1, green = 1, blue = 1, alpha = 1 }
    local color = table or defaultColor

    love.graphics.setColor(color.red, color.green, color.blue, color.alpha)
end
