# gmantics

A SimAntics-like smart-object system for Garry's Mod: entities advertise the actions that can be done to them and the needs those satisfy; NPCs have needs and look for nearby entities to meet them.

This repository contains the addon scaffold and portable core. The
autorun stub prints a load message; gameplay will arrive in later tasks.

## Layout

| Path | Purpose |
| --- | --- |
| `addon.json` | Workshop metadata and packaging exclusions |
| `lua/autorun/` | Addon entry point and future module loading |
| `lua/gmantics/core/` | Pure Lua need, advertisement, scoring and selection logic |
| `lua/gmantics/brain/` | NPC orchestration and thin GMod adapters |
| `lua/entities/` | Future advertising entities and example NPC |
| `test/` | Plain-Lua core tests runnable outside GMod |
| `docs/DESIGN.md` | Architecture, behavior and delivery plan |
| `AGENTS.md`, `CLAUDE.md` | Identical contributor conventions |

## Development and tests

Use Lua 5.1/LuaJIT-compatible syntax. Run the dependency-free assert suite
from the repository root:

```sh
luajit test/run.lua
```

See [the core API](docs/CORE.md) for module loading, defaults and tie rules,
[the design](docs/DESIGN.md) for later stages and
[contributor conventions](AGENTS.md) for PR rules. LuaJIT CI arrives in the
final task.

For an optional local game smoke check, place the repository as an addon
folder under `garrysmod/addons/gmantics/` and start the game. The stub prints
`[gmantics] loaded` in the realm where it runs; there is nothing to spawn yet.

Binary assets listed in `.gitattributes` use Git LFS. Install Git LFS before
adding or checking out those assets; this scaffold contains none.
