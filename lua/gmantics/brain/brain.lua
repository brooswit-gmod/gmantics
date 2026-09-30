local Select = require("gmantics.core.select")
local Check = require("gmantics.core.check")
local Brain = {}
Brain.__index = Brain

Brain.defaults = { scan_radius = 1000, use_distance = 64,
    move_timeout = 15, rescan_interval = 1 }

function Brain.new(agent, needs, adapter, config)
    local options = {}
    for key, value in pairs(config or {}) do options[key] = value end
    for key, value in pairs(Brain.defaults) do
        if options[key] == nil then options[key] = value end
        Check.number(options[key], key)
        assert(options[key] >= 0, key .. " must be nonnegative")
    end
    return setmetatable({ agent = agent, needs = needs, adapter = adapter,
        config = options, state = "IDLE", next_scan = adapter:now() }, Brain)
end

function Brain:idle(now)
    self.choice = nil
    self.state = "IDLE"
    self.next_scan = now + self.config.rescan_interval
end

function Brain:think(dt)
    self.needs:tick(dt)
    local a, now = self.adapter, self.adapter:now()
    if self.choice and not a:valid(self.choice.entity) then
        self:idle(now)
        return
    end
    if self.state == "IDLE" then
        if now >= self.next_scan then self.state = "SCAN" end
    elseif self.state == "SCAN" then
        local candidates = {}
        for _, entity in ipairs(a:find(self.agent, self.config.scan_radius)) do
            if entity ~= self.agent and a:valid(entity) then
                for index, ad in ipairs(a:advertise(entity, self.agent) or {}) do
                    candidates[#candidates + 1] = { ad = ad, entity = entity,
                        source = a:id(entity), index = index,
                        distance = a:distance(self.agent, entity) }
                end
            end
        end
        self.choice = Select.best(candidates, self.needs, self.config)
        if self.choice then
            self.state = "MOVE"
            self.move_started = now
        else
            self:idle(now)
        end
    elseif self.state == "MOVE" then
        if a:distance(self.agent, self.choice.entity) <= self.config.use_distance then
            self.state = "PERFORM"
            self.perform_started = now
            a:begin_use(self.choice.entity, self.agent, self.choice.ad)
        elseif now - self.move_started >= self.config.move_timeout then
            self:idle(now)
        else
            a:move(self.agent, self.choice.entity, dt)
        end
    elseif self.state == "PERFORM" then
        if now - self.perform_started >= self.choice.ad.duration then
            a:end_use(self.choice.entity, self.agent, self.choice.ad)
            self.state = "APPLY"
        end
    elseif self.state == "APPLY" then
        for id, amount in pairs(self.choice.ad.satisfies) do
            if self.needs.values[id] ~= nil then self.needs:add(id, amount) end
        end
        self:idle(now)
    end
end

return Brain
