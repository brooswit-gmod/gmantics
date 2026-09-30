package.path = "./lua/?.lua;" .. package.path
local Needs = require("gmantics.core.needs")
local NeedState = require("gmantics.core.needstate")
local Ads = require("gmantics.core.ads")
local Scoring = require("gmantics.core.scoring")
local Select = require("gmantics.core.select")
local count = 0
local function test(name, fn)
    fn()
    count = count + 1
    print("ok " .. count .. " - " .. name)
end
local function rejects(fragment, fn)
    local ok, err = pcall(fn)
    assert(not ok and tostring(err):find(fragment, 1, true), tostring(err))
end
local function near(actual, expected)
    assert(math.abs(actual - expected) < 1e-10, tostring(actual) .. " ~= " .. expected)
end
Needs.define("hunger", { decay_per_sec = 2, start = 80 })
Needs.define("energy", { min = -20, max = 20, start = 0, decay_per_sec = 1 })
local function ad(action, amount)
    return { action = action or "eat", satisfies = { hunger = amount or 40 }, duration = 3 }
end

test("registry defaults, copies and unknown ids", function()
    local defaults = Needs.define("fun")
    assert(defaults.min == 0 and defaults.max == 100 and defaults.start == 100)
    assert(defaults.decay_per_sec == 0)
    defaults.max = 5
    local all = Needs.all()
    all.fun.max = 7
    assert(Needs.get("fun").max == 100)
    rejects("unknown need", function() Needs.get("missing") end)
    rejects("already defined", function() Needs.define("fun") end)
end)
test("registry rejects invalid ranges and rates", function()
    rejects("max must exceed", function() Needs.define("bad", { min = 100 }) end)
    rejects("nonnegative", function() Needs.define("bad", { decay_per_sec = -1 }) end)
    rejects("within", function() Needs.define("bad", { start = 101 }) end)
    rejects("finite number", function() Needs.define("bad", { max = math.huge }) end)
end)
test("state starts, independence, addition and clamping", function()
    local a = NeedState.new({ hunger = true, energy = -100 })
    local b = NeedState.new({ hunger = true })
    assert(a:get("hunger") == 80 and a:get("energy") == -20)
    assert(a:add("hunger", 50) == 100)
    assert(a:add("hunger", -200) == 0)
    assert(b:get("hunger") == 80)
    rejects("does not have", function() b:get("energy") end)
    rejects("unknown need", function() NeedState.new({ missing = true }) end)
end)
test("elapsed decay, custom bounds and zero time", function()
    local state = NeedState.new({ hunger = true, energy = true })
    state:tick(5)
    assert(state:get("hunger") == 70 and state:get("energy") == -5)
    state:tick(0)
    assert(state:get("hunger") == 70)
    state:tick(1000)
    assert(state:get("hunger") == 0 and state:get("energy") == -20)
    rejects("nonnegative", function() state:tick(-1) end)
    rejects("finite number", function() state:tick(0 / 0) end)
end)
test("advertisement validation and optional cost", function()
    local valid = ad()
    valid.cost = 4
    assert(Ads.validate(valid) == valid)
    local invalid = ad(); invalid.action = nil
    rejects("action", function() Ads.validate(invalid) end)
    invalid = ad(); invalid.duration = 0
    rejects("positive", function() Ads.validate(invalid) end)
    invalid.duration = -1
    rejects("positive", function() Ads.validate(invalid) end)
    invalid = ad(); invalid.satisfies = { missing = 4 }
    rejects("unknown need", function() Ads.validate(invalid) end)
    invalid = ad(); invalid.satisfies.hunger = "40"
    rejects("finite number", function() Ads.validate(invalid) end)
    invalid = ad(); invalid.cost = false
    rejects("cost", function() Ads.validate(invalid) end)
    invalid = ad(); invalid.satisfies = nil
    rejects("satisfies", function() Ads.validate(invalid) end)
end)
test("scoring formula and monotonicity", function()
    local low = NeedState.new({ hunger = 20 })
    local high = NeedState.new({ hunger = 80 })
    near(Scoring.score(ad(), low, 0), 25.6)
    assert(Scoring.score(ad(), low, 0) > Scoring.score(ad(), high, 0))
    near(Scoring.score(ad(), low, 1000), 12.8)
    assert(Scoring.score(ad(), low, 10) < Scoring.score(ad(), low, 0))
    near(Scoring.score(ad(), low, 100, { falloff = 100, urgency_exponent = 3 }), 10.24)
    assert(Scoring.score(ad(), NeedState.new({ hunger = 100 }), 0) == 0)
end)
test("multi-need scoring, custom ranges and absent agent needs", function()
    local multi = { action = "meal", duration = 1, satisfies = { hunger = 40, energy = 20 } }
    near(Scoring.score(multi, NeedState.new({ hunger = 50, energy = 0 }), 0), 15)
    near(Scoring.score(multi, NeedState.new({ hunger = 50 }), 0), 10)
    near(Scoring.score(multi, NeedState.new({}), 0), 0)
end)
test("scoring rejects invalid distances and config", function()
    local state = NeedState.new({ hunger = true })
    rejects("nonnegative", function() Scoring.score(ad(), state, -1) end)
    rejects("positive", function() Scoring.score(ad(), state, 0, { falloff = 0 }) end)
    rejects("convex", function() Scoring.score(ad(), state, 0, { urgency_exponent = 1 }) end)
end)
test("selection ordering, threshold and empty list", function()
    local state = NeedState.new({ hunger = 0 })
    local a = { ad = ad(), distance = 1000, source = 1 }
    local b = { ad = ad(), distance = 0, source = 2 }
    assert(Select.best({ a, b }, state) == b)
    assert(Select.best({ b, a }, state) == b)
    assert(Select.best({}, state) == nil)
    assert(Select.best({ b }, state, { min_score = 40 }) == nil)
    assert(Select.best({ b }, NeedState.new({ hunger = 100 })) == nil)
end)
test("ties use action, source and stable advertisement index", function()
    local state = NeedState.new({ hunger = 0 })
    local a = { ad = ad("a"), distance = 0, source = 2, index = 2 }
    local b = { ad = ad("b"), distance = 0, source = 1 }
    assert(Select.best({ b, a }, state) == a)
    b.ad.action = "a"
    assert(Select.best({ a, b }, state) == b)
    b.source = 2; b.index = 1
    assert(Select.best({ a, b }, state) == b)
    assert(Select.best({ b, a }, state) == b)
    a.source = "bed"; b.source = "chair"
    assert(Select.best({ b, a }, state) == a)
    b.source = {}
    rejects("stable", function() Select.best({ b }, state) end)
end)
test("selection threshold is strict and mixed source ids are deterministic", function()
    local state = NeedState.new({ hunger = 0 })
    local numeric = { ad = ad(), distance = 0, source = 1 }
    local named = { ad = ad(), distance = 0, source = "1" }
    assert(Select.best({ numeric }, state, { min_score = 40 }) == nil)
    assert(Select.best({ numeric }, state, { min_score = 39.99 }) == numeric)
    for _, candidates in ipairs({ { numeric, named }, { named, numeric } }) do
        assert(Select.best(candidates, state) == numeric)
    end
    rejects("finite number", function()
        Select.best({ numeric }, state, { min_score = 0 / 0 })
    end)
end)

test("advertisements reject nonfinite duration and effects", function()
    for _, value in ipairs({ math.huge, -math.huge, 0 / 0 }) do
        local invalid = ad(); invalid.duration = value
        rejects("finite number", function() Ads.validate(invalid) end)
        invalid = ad(); invalid.satisfies.hunger = value
        rejects("finite number", function() Ads.validate(invalid) end)
    end
end)
print("All " .. count .. " tests passed")
