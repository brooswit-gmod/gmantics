-- All engine calls used by the brain and NPC integration live here.
local Adapter = {}

function Adapter:now() return CurTime() end
function Adapter:valid(entity) return IsValid(entity) end
function Adapter:position(entity) return entity:GetPos() end
function Adapter:distance(agent, entity)
    return self:position(agent):Distance(self:position(entity))
end
function Adapter:id(entity) return entity:EntIndex() end
function Adapter:find(agent, radius)
    return ents.FindInSphere(self:position(agent), radius)
end
function Adapter:advertise(entity, agent)
    if type(entity.Advertise) == "function" then return entity:Advertise(agent) end
end
function Adapter:begin_use(entity, agent, ad)
    if type(entity.BeginUse) == "function" then entity:BeginUse(agent, ad) end
end
function Adapter:end_use(entity, agent, ad)
    if type(entity.EndUse) == "function" then entity:EndUse(agent, ad) end
end
function Adapter:move(agent, entity)
    agent.loco:FaceTowards(self:position(entity))
    agent.loco:Approach(self:position(entity), 1)
end
function Adapter:initialize(agent)
    agent:SetModel("models/Humans/Group01/male_07.mdl")
    agent.loco:SetDesiredSpeed(100)
end

return Adapter
