# gmantics

A SimAntics-like smart-object system for Garry's Mod: entities advertise the actions that can be done to them and the needs those satisfy; NPCs have needs and look for nearby entities to meet them.

This repository currently contains the addon scaffold and design only. The
autorun stub prints a load message; gameplay will arrive in later tasks.

## Layout

| Path | Purpose |
| --- | --- |
| `addon.json` | Workshop metadata and packaging exclusions |
| `lua/autorun/` | Addon entry point and future module loading |
| `lua/gmantics/core/` | Pure Lua need, advertisement, scoring and selection logic |
| `lua/gmantics/brain/` | NPC orchestration and thin GMod adapters |
| `lua/entities/` | Future advertising entities and example NPC |
| `test/` | Future tests runnable outside GMod |
| `docs/DESIGN.md` | Architecture, behavior and delivery plan |
| `AGENTS.md`, `CLAUDE.md` | Identical contributor conventions |

## Development and tests

Use Lua 5.1/LuaJIT-compatible syntax. No live Garry's Mod installation is
needed for development of the core. There is no test runner or unit suite yet:
GMOD-3 adds core tests, and the final task wires the runner and LuaJIT CI.
The exact test command will be documented here when that runner exists.

For this scaffold, check that `addon.json` parses as JSON and that
`AGENTS.md` and `CLAUDE.md` are identical. See [the design](docs/DESIGN.md)
for planned testing and [contributor conventions](AGENTS.md) for PR rules.

For an optional local game smoke check, place the repository as an addon
folder under `garrysmod/addons/gmantics/` and start the game. The stub prints
`[gmantics] loaded` in the realm where it runs; there is nothing to spawn yet.

Binary assets listed in `.gitattributes` use Git LFS. Install Git LFS before
adding or checking out those assets; this scaffold contains none.
