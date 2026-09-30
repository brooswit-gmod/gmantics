local Needs = require("gmantics.core.needs")
local Ads = require("gmantics.core.ads")
local Check = require("gmantics.core.check")
local Scoring = {}

function Scoring.score(ad, needstate, distance, config)
    Ads.validate(ad)
    Check.number(distance, "distance")
    assert(distance >= 0, "distance must be nonnegative")
    config = config or {}
    local falloff = config.falloff or 1000
    local exponent = config.urgency_exponent or 2
    Check.number(falloff, "falloff")
    Check.number(exponent, "urgency_exponent")
    assert(falloff > 0, "falloff must be positive")
    assert(exponent > 1, "urgency_exponent must exceed 1 (convex urgency)")
    -- Sort for reproducible floating-point accumulation across hash orders.
    local ids = {}
    for id in pairs(ad.satisfies) do ids[#ids + 1] = id end
    table.sort(ids)
    local score = 0
    for _, id in ipairs(ids) do
        local definition = Needs.get(id)
        if needstate.values[id] ~= nil then
            local value = needstate:get(id)
            local urgency = ((definition.max - value) / (definition.max - definition.min))
                ^ exponent
            score = score + urgency * ad.satisfies[id]
        end
    end
    return score / (1 + distance / falloff)
end

return Scoring
