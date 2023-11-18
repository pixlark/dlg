local Object = require "lib.vendored.classic"
local lume = require "lib.vendored.lume"
local Vector = require "lib.vendored.vector"

local except = require "lib.local.exceptions"

local function uniqueInsert(tbl, x)
    if not lume.any(tbl, function(y) return x == y end) then
        table.insert(tbl, x)
    end
end

local KeyTrigger = Object:extend()

function KeyTrigger:new(key, value)
    self.key = key
    self.value = value
end

local KeyStick = Object:extend()

function KeyStick:new(key, value)
    self.key = key
    self.value = value
end

local Input = Object:extend()

function Input:new()
    -- maps bindings -> controller buttons
    self.controllerButtons = {}
    -- maps bindings -> key buttons
    self.keyButtons = {}
    -- maps bindings -> controller triggers
    self.controllerTriggers = {}
    -- maps bindings -> array({ key button, value })
    self.keyTriggers = {}
    -- maps bindings -> controller sticks
    self.controllerSticks = {}
    -- maps bindings -> array({ key button, { x, y } })
    self.keySticks = {}

    self.deadzones = {
        trigger = {
            left = 0.25,
            right = 0.25,
        },
        stick = {
            left = 0.25,
            right = 0.25,
        },
    }
end

function Input:update(dt)
end

--
-- Create bindings
--

function Input:bindKeyButton(name, key)
    do
        assert(type(name) == "string")
        assert(type(key) == "string")
    end

    if self.keyButtons[name] == nil then
        self.keyButtons[name] = {}
    end

    uniqueInsert(self.keyButtons[name], key)
end

function Input:bindControllerButton(name, button)
    do
        assert(type(name) == "string")
        assert(type(button) == "string")
    end

    if self.controllerButtons[name] == nil then
        self.controllerButtons[name] = {}
    end

    uniqueInsert(self.controllerButtons[name], button)
end

function Input:bindKeyTrigger(name, key, value)
    do
        assert(type(name) == "string")
        assert(type(key) == "string")
        assert(type(value) == "number")
    end

    if self.keyTriggers[name] == nil then
        self.keyTriggers[name] = {}
    end

    self.keyTriggers[name][key] = value
end

function Input:bindControllerTrigger(name, trigger)
    do
        assert(type(name) == "string")
        assert(type(trigger) == "string")
        assert(trigger == "left" or trigger == "right")
    end

    if self.controllerTriggers[name] == nil then
        self.controllerTriggers[name] = {}
    end

    uniqueInsert(self.controllerTriggers[name], trigger)
end

function Input:bindKeyStick(name, key, value)
    do
        assert(type(name) == "string")
        assert(type(key) == "string")
        assert(type(value) == "table")
    end

    if self.keySticks[name] == nil then
        self.keySticks[name] = {}
    end

    self.keySticks[name][key] = value
end

function Input:bindControllerStick(name, stick)
    do
        assert(type(name) == "string")
        assert(type(stick) == "string")
        assert(stick == "left" or stick == "right")
    end

    if self.controllerSticks[name] == nil then
        self.controllerSticks[name] = {}
    end

    uniqueInsert(self.controllerSticks[name], stick)
end

--
-- Test bindings
--

local mouseKeys = {
    mouse1 = 1,
    mouse2 = 2,
    mouse3 = 3,
}

function Input:_keyDown(key)
    if mouseKeys[key] ~= nil then
        return love.mouse.isDown(mouseKeys[key])
    end

    return love.keyboard.isDown(key)
end

function Input:buttonDown(name)
    if self.keyButtons[name] ~= nil then
        for _, key in ipairs(self.keyButtons[name]) do
            if self:_keyDown(key) then
                return true
            end
        end
    end

    if self.controllerButtons[name] ~= nil then
        for _, joystick in ipairs(love.joystick.getJoysticks()) do
            if joystick:isGamepadDown(unpack(self.controllerButtons[name])) then
                return true
            end
        end
    end

    return false
end

function Input:trigger(name)
    if self.keyTriggers[name] ~= nil then
        for key, value in pairs(self.keyTriggers[name]) do
            if self:_keyDown(key) then
                return value
            end
        end
    end

    if self.controllerTriggers[name] ~= nil then
        for _, joystick in ipairs(love.joystick.getJoysticks()) do
            for _, trigger in ipairs(self.controllerTriggers[name]) do
                local triggerAxis
                if trigger == "left" then
                    triggerAxis = "triggerleft"
                elseif trigger == "right" then
                    triggerAxis = "triggerright"
                else
                    error()
                end

                local axisValue = joystick:getGamepadAxis(triggerAxis)
                if axisValue > self.deadzones.trigger[trigger] then
                    return axisValue
                end
            end
        end
    end

    return 0.0
end

function Input:stick(name)
    local dir = Vector.new(0, 0)

    if self.keySticks[name] ~= nil then
        for key, value in pairs(self.keySticks[name]) do
            if self:_keyDown(key) then
                dir = dir + value
            end
        end
    end

    if self.controllerSticks[name] ~= nil then
        for _, joystick in ipairs(love.joystick.getJoysticks()) do
            for _, stick in ipairs(self.controllerSticks[name]) do
                local axes
                if stick == "left" then
                    axes = { "leftx", "lefty" }
                elseif stick == "right" then
                    axes = { "rightx", "righty" }
                else
                    error()
                end

                local axesValue = Vector.new(
                    joystick:getGamepadAxis(axes[1]),
                    joystick:getGamepadAxis(axes[2])
                )

                if axesValue:len() > self.deadzones.stick[stick] then
                    dir = dir + axesValue
                end
            end
        end
    end

    return dir:normalized()
end

return Input
