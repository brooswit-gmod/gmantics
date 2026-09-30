# Adding an advertising entity

Objects offer actions; the NPC brain chooses an advertisement, approaches
the object, waits its duration, then adds its effects to the NPC's needs.
Need values measure satisfaction: low values are more urgent.

Create a folder under `lua/entities/`, for example `gmantics_water`.
Its `shared.lua` can contain this worked example:

```lua
ENT.Base = "gmantics_base"
ENT.Type = "anim"
ENT.PrintName = "Water"
ENT.Category = "gmantics"
ENT.Spawnable = true
ENT.Model = "models/props_junk/garbage_glassbottle003a.mdl"

function ENT:Advertise(agent)
    return {
        { action = "drink", satisfies = { thirst = 40 }, duration = 2 }
    }
end
```

Add `init.lua` with `AddCSLuaFile("shared.lua")`,
`AddCSLuaFile("cl_init.lua")` and `include("shared.lua")`.
Add `cl_init.lua` with `include("shared.lua")`.
The base initializes the model and prop physics. It is abstract and hidden
from the spawn menu; concrete entities set `Spawnable = true`.

An advertisement is `{ action, satisfies = { need = amount }, duration }`:
action is a nonempty string, duration is positive seconds, and effects
are finite numbers for registered needs. Optional `cost` is a finite
numeric scoring penalty. Return a list, even for one action; return an empty
list when nothing is available. Return fresh tables to avoid shared mutation.
`Ads.validate(ad)` checks the format. Positive amounts restore satisfaction.

Define thirst on the server before constructing an NPC's NeedState:

```lua
gmantics.Needs.define("thirst", { min = 0, max = 100, start = 100, decay_per_sec = 1 })
```

For bundled needs, edit `lua/gmantics/needs_default.lua`, loaded by
`lua/autorun/gmantics_init.lua`. Its four defaults are hunger 1, energy 0.5,
bladder 0.8 and fun 0.6 satisfaction points lost per second. Existing
definitions are preserved. A need must be registered once and added to
the NPC's `AgentNeeds`, such as `{ thirst = true }`, to affect its choices.
Extend the example NPC's four-need table if it should also drink.

Optional `BeginUse(agent, ad)` and `EndUse(agent, ad)` hooks can animate
or play sounds. The adapter passes the selected advertisement as a third
argument. Do not add the advertised need effects inside these hooks:
the brain owns that step. EndUse runs when the duration completes.
If an object is removed mid-use, the brain abandons the action without
calling EndUse, so hooks must not rely on it for guaranteed cleanup.

See `test/examples.lua` for loading shared entity definitions into fake
tables and validating their advertisements outside GMod. Run
`luajit test/run.lua` and `luajit test/defaults.lua`.
In-game verification still requires spawning the props and example NPC
on accessible ground and observing choices, movement and completed use.
The existing adapter moves directly; it does not navigate around obstacles.
