local std = require "lib.std"

local function uniqueInsert(tbl, x)
    if not std.lume.any(tbl, function(y) return x == y end) then
        table.insert(tbl, x)
    end
end

local KeyTrigger = std.Object:extend()

function KeyTrigger:new(key, value)
    self.key = key
    self.value = value
end

local KeyStick = std.Object:extend()

function KeyStick:new(key, value)
    self.key = key
    self.value = value
end

local Input = std.Object:extend()

function Input:new()
    self.controllerButtons = {}
    self.keyButtons = {}
    self.controllerTriggers = {}
    self.keyTriggers = {}
    self.controllerSticks = {}
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
    -- Add update logic here if needed
end

-- Bind a key to a KeyButton
function Input:bindKeyButton(name, key)
    assert(type(name) == "string" and type(key) == "string")

    if self.keyButtons[name] == nil then
        self.keyButtons[name] = {}
    end

    uniqueInsert(self.keyButtons[name], key)
end

-- Bind a controller button to a KeyButton
function Input:bindControllerButton(name, button)
    assert(type(name) == "string" and type(button) == "string")

    if self.controllerButtons[name] == nil then
        self.controllerButtons[name] = {}
    end

    uniqueInsert(self.controllerButtons[name], button)
end

-- Bind a key to a KeyTrigger
function Input:bindKeyTrigger(name, key, value)
    assert(type(name) == "string" and type(key) == "string" and type(value) == "number")

    if self.keyTriggers[name] == nil then
        self.keyTriggers[name] = {}
    end

    table.insert(self.keyTriggers[name], KeyTrigger(key, value))
end

-- Bind a controller button to a KeyTrigger
function Input:bindControllerTrigger(name, trigger)
    assert(type(name) == "string" and type(trigger) == "string" and (trigger == "left" or trigger == "right"))

    if self.controllerTriggers[name] == nil then
        self.controllerTriggers[name] = {}
    end

    table.insert(self.controllerTriggers[name], trigger)
end

-- Bind a key to a KeyStick
function Input:bindKeyStick(name, key, value)
    assert(type(name) == "string" and type(key) == "string" and type(value) == "table")

    if self.keySticks[name] == nil then
        self.keySticks[name] = {}
    end

    table.insert(self.keySticks[name], KeyStick(key, value))
end

-- Bind a controller stick to a KeyStick
function Input:bindControllerStick(name, stick)
    assert(type(name) == "string" and type(stick) == "string" and (stick == "left" or stick == "right"))

    if self.controllerSticks[name] == nil then
        self.controllerSticks[name] = {}
    end

    table.insert(self.controllerSticks[name], stick)
end

-- Test bindings

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
        for _, keyTrigger in ipairs(self.keyTriggers[name]) do
            if self:_keyDown(keyTrigger.key) then
                return keyTrigger.value
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
    local dir = std.Vector.new(0, 0)

    if self.keySticks[name] ~= nil then
        for _, keyStick in ipairs(self.keySticks[name]) do
            if self:_keyDown(keyStick.key) then
                dir = dir + std.Vector.new(keyStick.value[1], keyStick.value[2])
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

                local axesValue = std.Vector.new(
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
