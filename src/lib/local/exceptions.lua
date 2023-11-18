local e = {}

function e.abstractMethodException()
    error("Abstract method exception")
end

function e.notImplementedException()
    error("Not implemented exception")
end

return e
