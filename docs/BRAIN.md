# NPC brain

Outside GMod, set `package.path = "./lua/?.lua;" .. package.path`, require
`gmantics.brain.brain`, and create `Brain.new(agent, needstate, adapter, config)`.
The agent is opaque; the injected adapter uses colon methods:
`now()`, `valid(entity)`, `find(agent, radius)`, `id(entity)` (stable string or
number), `distance(agent, entity)`, `advertise(entity, agent)`,
`move(agent, entity, dt)`, `begin_use(entity, agent, ad)`, and
`end_use(entity, agent, ad)`. Missing entity advertisement/use hooks are
handled by the adapter. Advertisement lists are ordered arrays.

Call `brain:think(dt)` with nonnegative elapsed seconds and advance the
adapter's clock by that elapsed time. Every tick decays needs, including
while moving or performing. Each tick advances at most one state:
`IDLE -> SCAN -> MOVE -> PERFORM -> APPLY -> IDLE`.
SCAN uses core `Select.best`; non-advertisers are ignored. MOVE arrives at
or within use distance, otherwise requests movement until timeout. PERFORM
calls BeginUse once on arrival, waits the full duration, and calls EndUse
once on completion. APPLY on the following tick adds/clamps effects for
needs owned by this agent. A removed target cancels the cycle without
effects; no EndUse can be delivered to a removed entity.

| Config | Default | Meaning |
| --- | --- | --- |
| `scan_radius` | 1000 | Search radius in game units |
| `use_distance` | 64 | Arrival distance in game units |
| `move_timeout` | 15 | Maximum moving time in seconds |
| `rescan_interval` | 1 | Idle delay before next scan in seconds |

All four accept finite nonnegative numbers. Core scoring options
`falloff`, `urgency_exponent`, and `min_score` also pass through config.
An advertisement must score strictly above `min_score` (default 0);
use a higher threshold to leave mildly depleted agents idle.

The server autorun loads dependencies and seeds hunger/energy defaults.
`gmantics_npc` is a thin NextBot owning a NeedState and brain; override
`AgentNeeds` and `BrainConfig` on a derived entity. Engine calls are isolated
in `brain/adapter.lua`. Its simple locomotion approaches the target directly;
it does not navigate around obstacles and will time out when blocked.
Movement is driven from the behaviour coroutine. See the official
[locomotion API](https://wiki.facepunch.com/gmod/CLuaLocomotion:Approach).

Run `luajit test/run.lua` from the repository root for core and fake-adapter
brain tests. These cover selection, timing, hooks, timeout, rescan, decay,
removed targets, and effects. Live NextBot locomotion, rendering, and engine
loading require a GMod smoke test and are not validated by the portable suite.
