local std = require "lib.std"

local ResourceManager = require "engine.resources"
local scenes = require "engine.scenes"
local screen = require "engine.screen"

--[[
    GameState
     Global game management and state
]]--

local GameState = std.Object:extend()

function GameState:new()
end

function GameState:init()
    self.input = std.Input()
    self.inputOld = std.wasx.new(1)
    self.resources = ResourceManager()
    self.sceneManager = scenes.SceneManager()
    self.screen = screen.Screen(1.0, { red = 0.2, green = 0.2, blue = 0.2, alpha = 1.0 })
end

function GameState:scene()
    return self.sceneManager:currentScene()
end

-- Global
Game = GameState()
