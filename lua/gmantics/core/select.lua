local Scoring = require("gmantics.core.scoring")
local Check = require("gmantics.core.check")
local Select = {}

local function source_id(candidate)
    local source = candidate.source
    assert(type(source) == "string" or type(source) == "number",
        "candidate source must be a stable string or number id")
    if type(source) == "number" then Check.number(source, "candidate source") end
    return source
end

local function precedes(a, b)
    if a.ad.action ~= b.ad.action then return a.ad.action < b.ad.action end
    local a_id, b_id = source_id(a), source_id(b)
    if type(a_id) ~= type(b_id) then return type(a_id) < type(b_id) end
    if a_id ~= b_id then return a_id < b_id end
    return (a.index or 0) < (b.index or 0)
end

function Select.best(candidates, needstate, config)
    config = config or {}
    local threshold = config.min_score or 0
    Check.number(threshold, "min_score")
    local best, best_score = nil, threshold
    for _, candidate in ipairs(candidates) do
        source_id(candidate)
        if candidate.index ~= nil then Check.number(candidate.index, "candidate index") end
        local score = Scoring.score(candidate.ad, needstate, candidate.distance, config)
        if score > best_score or (best and score == best_score and precedes(candidate, best)) then
            best, best_score = candidate, score
        end
    end
    return best
end

return Select
