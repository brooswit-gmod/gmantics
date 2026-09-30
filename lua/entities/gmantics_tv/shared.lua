ENT.Base = "gmantics_base"
ENT.Type = "anim"
ENT.PrintName = "gmantics TV"
ENT.Category = "gmantics"
ENT.Spawnable = true
ENT.Model = "models/props_c17/tv_monitor01.mdl"

function ENT:Advertise(agent)
    return { { action = "watch", satisfies = { fun = 50 }, duration = 6 } }
end
