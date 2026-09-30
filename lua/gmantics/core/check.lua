local Check = {}

function Check.number(value, name)
    assert(type(value) == "number" and value == value
        and value ~= math.huge and value ~= -math.huge,
        name .. " must be a finite number")
    return value
end

function Check.clamp(value, definition)
    return math.max(definition.min, math.min(definition.max, value))
end

return Check
