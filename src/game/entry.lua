require "game.Game"
require "engine.graphics"

local std = require "lib.std"
local ResourceManager = require "engine.resources"

local scenes = require "engine.scenes"
local Scene = scenes.Scene
local SceneManager = scenes.SceneManager

local screen = require "engine.screen"
local Frame = screen.Frame

local function boundsToRect(bounds)
    return {
        bounds.x1,
        bounds.y1,
        bounds.x2 - bounds.x1,
        bounds.y2 - bounds.y1,
    }
end

--[[
    TrialScene
]]--

local Board = std.Object:extend()

function Board:new(size)
    self.size = size
    self.selectedRow, self.selectedColumn = 1, 1

    self.directionJustPushed = nil
    self.directionPushedFor = 0
end

function Board:handleInput(dt)
    local dir
    do
        local axes = Game.input:stick("testStick")
        if axes:len() > 0.5 then
            local normalized = axes:normalized()
            if math.abs(normalized.y) >= math.abs(normalized.x) then
                if normalized.y >= 0 then
                    dir = std.Vector.new(0, -1)
                else
                    dir = std.Vector.new(0, 1)
                end
            else
                if normalized.x >= 0 then
                    dir = std.Vector.new(1, 0)
                else
                    dir = std.Vector.new(-1, 0)
                end
            end
        else
            dir = std.Vector.new(0, 0)
        end
    end

    if self.directionPushedFor > 0.15 then
        self.directionJustPushed = nil
        self.directionPushedFor = 0
    end

    if dir:len() > 0 then
        if self.directionJustPushed == nil or dir:dist(self.directionJustPushed) > 0.01 then
            self.directionJustPushed = dir

            -- Flip Y-axis
            dir = dir:permul(std.Vector.new(1, -1))

            self.selectedRow    = std.lume.clamp(self.selectedRow    + dir.y, 1, self.size)
            self.selectedColumn = std.lume.clamp(self.selectedColumn + dir.x, 1, self.size)
        end
    else
        self.directionJustPushed = nil
    end

    if self.directionJustPushed == nil then
        self.directionPushedFor = 0
    else
        self.directionPushedFor = self.directionPushedFor + dt
    end
end

local BoardRenderer = std.Object:extend()

function BoardRenderer:new(board)
    self.board = board

    self.frame = Frame {
        anchor  = std.Vector { x = -0.75, y = -0.375 },
        size    = std.Vector { x = 1.125, y =  1.125 },
        clipped = true,
    }
end

function BoardRenderer:selectionBoxThickness()
    return self.frame:pixelLength(2)
end

function BoardRenderer:tilePadding()
    return self.frame:pixelLength(1)
end

function BoardRenderer:tileSize()
    local gridSize = self.board.size
    local totalPadding = self:tilePadding() * (gridSize + 1)
    assert(totalPadding <= 1)
    local remainingSize = 1.0 - totalPadding
    local tileSize = remainingSize / gridSize
    return tileSize
end

function BoardRenderer:render()
    self.frame:draw(function()
        -- Background
        do
            love.graphics.setColor(0.9, 0.9, 0.9, 1)
            love.graphics.rectangle("fill", 0, 0, 1, 1)
        end

        -- Tiles
        local tileSize = self:tileSize()
        local tilePadding = self:tilePadding()
        do
            love.graphics.setColor(0.35, 0.35, 0.35, 1)
            for row = 1, self.board.size do
                for column = 1, self.board.size do
                    love.graphics.rectangle("fill",
                        tilePadding + (column - 1) * (tileSize + tilePadding),
                        tilePadding + (row - 1) * (tileSize + tilePadding),
                        tileSize, tileSize
                    )
                end
            end
        end

        -- Selected tile
        do
            local row, column = self.board.selectedRow, self.board.selectedColumn
            love.graphics.setColor(1, 0.15, 0.15, 1)
            love.graphics.setLineWidth(self:selectionBoxThickness())
            love.graphics.rectangle("line",
                tilePadding + (column - 1) * (tileSize + tilePadding),
                tilePadding + (row - 1) * (tileSize + tilePadding),
                tileSize, tileSize
            )
        end
    end)
end

local TrialScene = Scene:extend()

function TrialScene:init()
    self.board = Board(11)
    self.boardRenderer = BoardRenderer(self.board)
end

function TrialScene:update(dt)
    self.board:handleInput(dt)
end

function TrialScene:render()
    self.boardRenderer:render()
end

--[[
    Love hooks
]]--

function love.load()
    Game:init()

    Game.input:bindKeyStick("testStick", "w", std.Vector.new(0, -1))
    Game.input:bindKeyStick("testStick", "a", std.Vector.new(-1, 0))
    Game.input:bindKeyStick("testStick", "s", std.Vector.new(0, 1))
    Game.input:bindKeyStick("testStick", "d", std.Vector.new(1, 0))
    Game.input:bindControllerStick("testStick", "left")

    Game.sceneManager:pushScene(TrialScene())
end

function love.update(dt)
    Game.input:update(dt)
    Game.inputOld:updateData(dt)
    Game.sceneManager:update(dt)
end

function love.draw()
    Game.screen:startRender()

    love.graphics.push()
    love.graphics.applyTransform(Game.screen:getTransform())

    Game.sceneManager:render()

    love.graphics.pop()

    Game.screen:finishRender()
end
