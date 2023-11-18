local std = require "lib.std"

local scenes = require "engine.scenes"
local Scene = scenes.Scene

local screen = require "engine.screen"

local FrameTestScene = Scene:extend()

function FrameTestScene:init()
    self.frame = screen.Frame {
        anchor = std.Vector.new(-0.5, -0.5),
        size = std.Vector.new(0.5, 0.5),
        clipped = true,
        anchorType = "topleft",
    }
end

function FrameTestScene:update(dt)
    local inputDir = std.Vector.new(0, 0)
    local dirMap = {
        ["dpup"]    = std.Vector.new( 0, -1),
        ["dpdown"]  = std.Vector.new( 0,  1),
        ["dpleft"]  = std.Vector.new(-1,  0),
        ["dpright"] = std.Vector.new( 1,  0),
    }
    for button, dir in pairs(dirMap) do
        if Game.input:button(button) then
            inputDir = inputDir + dir
        end
    end

    inputDir:normalizeInplace()

    local modifier = Game.input:trigger("right") > 0.5

    if modifier then
        self.frame.size = self.frame.size + inputDir:permul(std.Vector.new(1, -1)) * dt;
        local frameSize = self.frame.size
        if frameSize.x < 0 then
            frameSize.x = 0
        end
        if frameSize.y < 0 then
            frameSize.y = 0
        end
    else
        self.frame.anchor = self.frame.anchor + inputDir * dt;
    end
end

function FrameTestScene:render()
    love.graphics.clear(0.25, 0.25, 0.25)

    -- Draw axes
    love.graphics.setLineWidth(0.000001)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.line(0, -1, 0, 1)
    love.graphics.line(-1, 0, 1, 0)
    --

    self.frame:debugDrawBounds()

    self.frame:draw(function()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, 1.5, 1)
    end)

    self.frame:debugDrawBounds()
end

return FrameTestScene
