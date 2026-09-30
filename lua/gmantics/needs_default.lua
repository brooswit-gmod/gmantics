local Needs = require("gmantics.core.needs")
local defaults = { hunger = 1, energy = 0.5, bladder = 0.8, fun = 0.6 }
for id, rate in pairs(defaults) do
    if not Needs.all()[id] then Needs.define(id, { decay_per_sec = rate }) end
end
return defaults
