# gmantics

A SimAntics-like smart-object system for Garry's Mod: entities advertise the actions that can be done to them and the needs those satisfy; NPCs have needs and look for nearby entities to meet them.

This repository contains the addon scaffold, portable core and NPC brain,
with a minimal `gmantics_npc` NextBot and an injectable engine adapter.

## Layout

| Path | Purpose |
| --- | --- |
| `addon.json` | Workshop metadata and packaging exclusions |
| `lua/autorun/` | Addon entry point and future module loading |
| `lua/gmantics/core/` | Pure Lua need, advertisement, scoring and selection logic |
| `lua/gmantics/brain/` | NPC orchestration and thin GMod adapters |
| `lua/entities/` | Minimal gmantics NPC; advertising entities arrive later |
| `test/` | Plain-Lua core and fake-adapter brain tests outside GMod |
| `docs/DESIGN.md` | Architecture, behavior and delivery plan |
| `AGENTS.md`, `CLAUDE.md` | Identical contributor conventions |

## Development and tests

Use Lua 5.1/LuaJIT-compatible syntax. Run the dependency-free assert suite
from the repository root:

```sh
luajit test/run.lua
```

See [the brain API](docs/BRAIN.md) for its state machine, adapter and config,
[the core API](docs/CORE.md) for module loading, defaults and tie rules,
[the design](docs/DESIGN.md) for later stages and
[contributor conventions](AGENTS.md) for PR rules. LuaJIT CI arrives in the
final task.

For an optional local game smoke check, place the repository as an addon
folder under `garrysmod/addons/gmantics/` and start the game. The stub prints
`[gmantics] loaded`. Spawn `gmantics_npc` from the gmantics category.
Advertising entities arrive in the next stage, so it initially remains idle.
Live GMod loading and locomotion need a game smoke check; the portable suite
does not exercise those engine APIs.

Binary assets listed in `.gitattributes` use Git LFS. Install Git LFS before
adding or checking out those assets; this scaffold contains none.
