local Vector = require "lib.vendored.vector"

local Object = require "lib.vendored.classic"
local decorators = require "lib.local.decorators"

local argcheck = decorators.argcheck
local overload = decorators.overload
local InstanceMethod = decorators.InstanceMethod

local Bounds = Object:extend()

Bounds.new = argcheck {
    InstanceMethod,
    "x1", "y1", "x2", "y2",
    function (self, t)
        self.x1 = t.x1
        self.y1 = t.y1
        self.x2 = t.x2
        self.y2 = t.y2
    end
}

Bounds.from = overload {
    "number", "number", "number", "number",
    function(x1, y1, x2, y2)
        return Bounds { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
    end,

    "table", "table",
    function(topLeft, bottomRight)
        return Bounds { x1 = topLeft.x, y1 = topLeft.y, x2 = bottomRight.x, y2 = bottomRight.y }
    end
}

function Bounds.fromRect(topLeft, size)
    return Bounds { x1 = topLeft.x, y1 = topLeft.y, x2 = topLeft.x + size.x, y2 = topLeft.y + size.y }
end

function Bounds:topLeft()
    return Vector.new(self.x1, self.y1)
end

function Bounds:bottomRight()
    return Vector.new(self.x2, self.y2)
end

return Bounds
