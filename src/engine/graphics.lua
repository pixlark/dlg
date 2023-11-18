-- Extensions to love.graphics

local std = require "lib.std"

function love.graphics.rectWithBounds(mode, bounds)
    love.graphics.rectangle(mode, bounds.x1, bounds.y1, bounds.x2 - bounds.x1, bounds.y2 - bounds.y1)
end

function love.graphics.setColorWithTable(table)
    love.graphics.setColor(table.red, table.green, table.blue, table.alpha)
end
