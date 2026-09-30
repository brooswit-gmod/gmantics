local Needs = require("gmantics.core.needs")
local Check = require("gmantics.core.check")
local NeedState = {}
NeedState.__index = NeedState

-- A map of need ids to initial values; true uses the registered start.
function NeedState.new(agent_needs)
    assert(type(agent_needs) == "table", "agent_needs must be a table")
    local state = setmetatable({ values = {}, definitions = {} }, NeedState)
    for id, value in pairs(agent_needs) do
        local definition = Needs.get(id)
        if value == true then value = definition.start end
        Check.number(value, "initial need value")
        state.values[id] = Check.clamp(value, definition)
        state.definitions[id] = definition
    end
    return state
end

function NeedState:get(id)
    Needs.get(id)
    assert(self.values[id] ~= nil, "agent does not have need: " .. tostring(id))
    return self.values[id]
end

function NeedState:add(id, delta)
    local value = self:get(id)
    Check.number(delta, "need delta")
    self.values[id] = Check.clamp(value + delta, self.definitions[id])
    return self.values[id]
end

function NeedState:tick(dt)
    Check.number(dt, "dt")
    assert(dt >= 0, "dt must be nonnegative")
    for id, definition in pairs(self.definitions) do
        self.values[id] = Check.clamp(self.values[id] - definition.decay_per_sec * dt,
            definition)
    end
end

return NeedState
