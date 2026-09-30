local Check = require("gmantics.core.check")
local Needs = {}
local registry = {}

local function copy(definition)
    local result = {}
    for key, value in pairs(definition) do result[key] = value end
    return result
end

function Needs.define(id, options)
    assert(type(id) == "string" and id ~= "", "need id must be a nonempty string")
    assert(not registry[id], "need already defined: " .. id)
    options = options or {}
    assert(type(options) == "table", "need options must be a table")
    local definition = {
        min = options.min or 0,
        max = options.max or 100,
        decay_per_sec = options.decay_per_sec or 0,
    }
    definition.start = options.start or definition.max
    for key, value in pairs(definition) do Check.number(value, key) end
    assert(definition.max > definition.min, "need max must exceed min")
    assert(definition.decay_per_sec >= 0, "need decay_per_sec must be nonnegative")
    assert(definition.start >= definition.min and definition.start <= definition.max,
        "need start must be within min and max")
    registry[id] = definition
    return copy(definition)
end

function Needs.get(id)
    assert(registry[id], "unknown need: " .. tostring(id))
    return copy(registry[id])
end

function Needs.all()
    local result = {}
    for id, definition in pairs(registry) do result[id] = copy(definition) end
    return result
end

return Needs
