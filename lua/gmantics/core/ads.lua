local Needs = require("gmantics.core.needs")
local Check = require("gmantics.core.check")
local Ads = {}

function Ads.validate(ad)
    assert(type(ad) == "table", "advertisement must be a table")
    assert(type(ad.action) == "string" and ad.action ~= "",
        "advertisement action must be a nonempty string")
    Check.number(ad.duration, "advertisement duration")
    assert(ad.duration > 0, "advertisement duration must be positive")
    assert(type(ad.satisfies) == "table", "advertisement satisfies must be a table")
    for id, amount in pairs(ad.satisfies) do
        Needs.get(id)
        Check.number(amount, "advertisement amount for " .. id)
    end
    if ad.cost ~= nil then Check.number(ad.cost, "advertisement cost") end
    return ad
end

return Ads
