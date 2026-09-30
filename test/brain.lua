local Brain = require("gmantics.brain.brain")
local Needs = require("gmantics.core.needs")
local NeedState = require("gmantics.core.needstate")
Needs.define("brain_food", { decay_per_sec = 1 })
Needs.define("brain_rest", { decay_per_sec = 10 })
local count = 0
local function test(name, fn)
    fn(); count = count + 1
    print("ok brain " .. count .. " - " .. name)
end
local function entity(id, distance, need)
    return { id = id, distance = distance, Advertise = function()
        return { { action = need, duration = 3, satisfies = { [need] = 50 } } }
    end }
end
local function setup(entities, values, config)
    local fake = { time = 0, entities = entities, moves = 0, begins = 0, ends = 0 }
    function fake:now() return self.time end
    function fake:valid(e) return not e.removed end
    function fake:find(_, radius) self.radius = radius; return self.entities end
    function fake:id(e) return e.id end
    function fake:distance(_, e) return e.distance end
    function fake:advertise(e, agent) if e.Advertise then return e:Advertise(agent) end end
    function fake:move() self.moves = self.moves + 1 end
    function fake:begin_use() self.begins = self.begins + 1 end
    function fake:end_use() self.ends = self.ends + 1 end
    local brain = Brain.new({}, NeedState.new(values), fake, config)
    local function step(dt) fake.time = fake.time + (dt or 0); brain:think(dt or 0) end
    return brain, fake, step
end
test("closest equal advertisement wins in either scan order", function()
    local far, close = entity(1, 200, "brain_food"), entity(2, 100, "brain_food")
    for _, list in ipairs({ { far, close }, { close, far } }) do
        local b, a, step = setup(list, { brain_food = 0 }, { scan_radius = 800 })
        step(); step()
        assert(b.state == "MOVE" and b.choice.entity == close and a.radius == 800)
    end
end)
test("urgent need beats equally distant alternative", function()
    local food, rest = entity(1, 10, "brain_food"), entity(2, 10, "brain_rest")
    local b, _, step = setup({ food, rest }, { brain_food = 80, brain_rest = 10 })
    step(); step(); assert(b.choice.entity == rest)
end)
test("MOVE asks adapter then times out without effects or hooks", function()
    local b, a, step = setup({ entity(1, 500, "brain_food") }, { brain_food = 20 },
        { move_timeout = 2, use_distance = 10 })
    step(); step(); step(1)
    assert(a.moves == 1 and b.state == "MOVE")
    step(1)
    assert(b.state == "IDLE" and b.choice == nil and b.needs:get("brain_food") == 18)
    assert(a.begins == 0 and a.ends == 0)
end)
test("duration precedes hooks completion and exactly one effect application", function()
    local b, a, step = setup({ entity(1, 0, "brain_food") }, { brain_food = 20 })
    step(); step(); step()
    assert(b.state == "PERFORM" and a.begins == 1)
    step(2.9)
    assert(b.state == "PERFORM" and a.ends == 0 and b.needs:get("brain_food") < 20)
    step(0.1)
    assert(b.state == "APPLY" and a.ends == 1 and b.needs:get("brain_food") == 17)
    step(); assert(b.state == "IDLE" and b.needs:get("brain_food") == 67)
    step(); assert(b.needs:get("brain_food") == 67 and a.begins == 1 and a.ends == 1)
end)
test("non-advertisers ignored and satisfied agent rescans periodically", function()
    local b, _, step = setup({ { id = 1, distance = 0 }, entity(2, 0, "brain_food") },
        { brain_food = 100 }, { rescan_interval = 2, min_score = 1 })
    step(); step(); assert(b.state == "IDLE" and not b.choice)
    step(1); assert(b.state == "IDLE")
    step(1); assert(b.state == "SCAN")
    step(); assert(b.state == "IDLE")
end)
test("decay throughout cycle changes next choice", function()
    local food, rest = entity(1, 0, "brain_food"), entity(2, 0, "brain_rest")
    local b, _, step = setup({ food, rest }, { brain_food = 20, brain_rest = 50 },
        { rescan_interval = 0 })
    step(); step(); assert(b.choice.entity == food)
    step(); step(3); step(); step(); step()
    assert(b.state == "MOVE" and b.choice.entity == rest)
    assert(b.needs:get("brain_rest") == 20)
end)
test("removed target cancels MOVE or PERFORM without applying", function()
    for _, performing in ipairs({ false, true }) do
        local target = entity(1, performing and 0 or 500, "brain_food")
        local b, _, step = setup({ target }, { brain_food = 20 })
        step(); step(); if performing then step() end
        target.removed = true; step(5)
        assert(b.state == "IDLE" and b.needs:get("brain_food") == 15)
    end
end)
test("unowned advertised needs ignored on apply and invalid config rejected", function()
    local target = entity(1, 0, "brain_food")
    target.Advertise = function()
        return { { action = "meal", duration = 1,
            satisfies = { brain_food = 10, brain_rest = 10 } } }
    end
    local b, _, step = setup({ target }, { brain_food = 0 })
    step(); step(); step(); step(1); step()
    assert(b.needs:get("brain_food") == 10)
    assert(not pcall(function() setup({}, {}, { move_timeout = -1 }) end))
end)
test("scan ignores the agent itself and removed objects", function()
    local removed, valid = entity(1, 0, "brain_food"), entity(2, 0, "brain_food")
    removed.removed = true
    local b, a, step = setup({ removed, valid }, { brain_food = 0 })
    b.agent = entity(0, 0, "brain_food")
    a.entities[#a.entities + 1] = b.agent
    step(); step()
    assert(b.choice.entity == valid)
end)

test("target removed before APPLY prevents effects and allows rescan", function()
    local target = entity(1, 0, "brain_food")
    local b, a, step = setup({ target }, { brain_food = 20 }, { rescan_interval = 2 })
    step(); step(); step(); step(3)
    assert(b.state == "APPLY" and a.begins == 1 and a.ends == 1)
    target.removed = true
    step()
    assert(b.state == "IDLE" and not b.choice and b.needs:get("brain_food") == 17)
    step(1); assert(b.state == "IDLE")
    a.entities = { entity(2, 0, "brain_food") }
    step(1); step()
    assert(b.state == "MOVE" and b.choice.entity.id == 2)
end)
print("All " .. count .. " brain tests passed")
