ENT.Base = "gmantics_base"
ENT.Type = "anim"
ENT.PrintName = "gmantics Fridge"
ENT.Category = "gmantics"
ENT.Spawnable = true
ENT.Model = "models/props_c17/FurnitureFridge001a.mdl"

function ENT:Advertise(agent)
    return { { action = "eat", satisfies = { hunger = 60 }, duration = 4 } }
end
