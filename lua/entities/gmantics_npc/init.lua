AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    local g = gmantics
    g.Adapter:initialize(self)
    self.Needs = g.NeedState.new(self.AgentNeeds or { hunger = true, energy = true })
    self.Brain = g.Brain.new(self, self.Needs, g.Adapter, self.BrainConfig)
end

function ENT:RunBehaviour()
    local previous = gmantics.Adapter:now()
    while true do
        local now = gmantics.Adapter:now()
        self.Brain:think(math.max(0, now - previous))
        previous = now
        coroutine.yield()
    end
end
