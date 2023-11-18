local std = require "lib.std"

local Scene = std.Object:extend()

function Scene:init()
end

function Scene:load()
end

function Scene:die()
end

function Scene:update(dt)
end

function Scene:render()
end

local SceneManager = std.Object:extend()

function SceneManager:new()
    self.current_scenes = {}
    self.operations_queue = {}
end

function SceneManager:currentScene()
    return self.current_scenes[#self.current_scenes]
end

function SceneManager:pushScene(scene)
    table.insert(
        self.operations_queue,
        function()
            scene:init()
            scene:load()
            table.insert(self.current_scenes, scene)
        end
    )
end

function SceneManager:popScene()
    table.insert(
        self.operations_queue,
        function()
            assert(#self.current_scenes > 0)
            local scene = table.remove(self.current_scenes)
            scene:die()
            self:currentScene():load()
        end
    )
end

function SceneManager:changeScene(scene)
    self:popScene()
    self:pushScene(scene)
end

function SceneManager:update(dt)
    -- Drain operations queue first
    for _, operation in ipairs(self.operations_queue) do
        operation()
    end
    self.operations_queue = {}

    assert(#self.current_scenes > 0)
    self:currentScene():update(dt)
end

function SceneManager:render()
    assert(#self.current_scenes > 0)
    self:currentScene():render()
end

return {
    Scene = Scene,
    SceneManager = SceneManager,
}
