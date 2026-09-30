local Needs = require("gmantics.core.needs")
local Ads = require("gmantics.core.ads")
require("gmantics.needs_default")
local function entity(name)
    local environment = setmetatable({ ENT = {} }, { __index = _G })
    local chunk = assert(loadfile("lua/entities/" .. name .. "/shared.lua"))
    setfenv(chunk, environment)()
    return environment.ENT
end
local cases = { fridge = "hunger", bed = "energy", toilet = "bladder", tv = "fun" }
for name, need in pairs(cases) do
    local e = entity("gmantics_" .. name)
    assert(e.Base == "gmantics_base" and e.Spawnable and e.Category == "gmantics")
    local ads = e:Advertise({})
    assert(#ads == 1 and Ads.validate(ads[1]))
    assert(ads[1].satisfies[need] > 0)
    ads[1].satisfies[need] = 0
    assert(e:Advertise({})[1].satisfies[need] > 0)
    print("ok example - " .. name)
end
local npc = entity("gmantics_example_npc")
assert(npc.Base == "gmantics_npc" and npc.Spawnable)
local state = require("gmantics.core.needstate").new(npc.AgentNeeds)
for _, need in pairs(cases) do assert(state:get(need) == Needs.get(need).start) end
assert(#entity("gmantics_base"):Advertise({}) == 0)
print("All example tests passed")
