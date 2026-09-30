ENT.Base = "gmantics_base"
ENT.Type = "anim"
ENT.PrintName = "gmantics Bed"
ENT.Category = "gmantics"
ENT.Spawnable = true
ENT.Model = "models/props_c17/FurnitureBed001a.mdl"

function ENT:Advertise(agent)
    return { { action = "sleep", satisfies = { energy = 70 }, duration = 8 } }
end
