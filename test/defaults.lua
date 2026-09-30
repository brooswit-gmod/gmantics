package.path = "./lua/?.lua;" .. package.path
local Needs = require("gmantics.core.needs")
local defaults = require("gmantics.needs_default")
local count = 0
for id, rate in pairs(defaults) do
    local definition = Needs.get(id)
    assert(definition.decay_per_sec == rate and rate > 0)
    assert(definition.start == 100 and definition.min == 0 and definition.max == 100)
    count = count + 1
end
assert(count == 4)
print("All 4 default need definitions passed")
