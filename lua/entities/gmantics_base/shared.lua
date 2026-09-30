ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "gmantics advertising object"
ENT.Category = "gmantics"
ENT.Spawnable = false
ENT.Model = "models/props_c17/FurnitureFridge001a.mdl"

function ENT:Advertise(agent) return {} end
-- Optional hooks; the brain applies need effects after duration.
function ENT:BeginUse(agent) end
function ENT:EndUse(agent) end
