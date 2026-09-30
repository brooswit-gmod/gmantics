ENT.Base = "gmantics_base"
ENT.Type = "anim"
ENT.PrintName = "gmantics Toilet"
ENT.Category = "gmantics"
ENT.Spawnable = true
ENT.Model = "models/props_c17/FurnitureToilet001a.mdl"

function ENT:Advertise(agent)
    return { { action = "relieve", satisfies = { bladder = 80 }, duration = 3 } }
end
