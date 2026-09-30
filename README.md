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
| `lua/entities/` | Advertising prop base, four example props and NPCs |
| `test/` | Plain-Lua core and fake-adapter brain tests outside GMod |
| `docs/DESIGN.md` | Architecture, behavior and delivery plan |
| `AGENTS.md`, `CLAUDE.md` | Identical contributor conventions |

## Testing and CI

Use Lua 5.1/LuaJIT-compatible syntax. Install LuaJIT and Git, then run the
dependency-free assert suites from the repository root:

```sh
luajit test/run.lua
```

The runner discovers every tracked or unignored new `.lua` file recursively
under `test/`, except itself. Each file runs in a fresh LuaJIT process with
the addon module path configured, so need registries do not leak between
suites. Keep helper modules outside `test/`. It runs all suites and exits
non-zero if any fail; discovery errors and an empty test directory also fail.

GitHub Actions runs on pushes to `main` and on pull requests, with read-only
repository permissions. It installs LuaJIT, syntax-checks every `.lua` file
(including engine-facing code), runs `bash test/check-core.sh`, and runs the
same test command above. No busted dependency is needed.

The portable-core guard keeps its prohibited GMod names in one place:
[`test/gmod-globals.txt`](test/gmod-globals.txt). Add newly encountered engine
globals there. The grep checks whole identifiers conservatively, including
comments and strings, so describe engine dependencies outside core files.
This list is a guardrail, not a complete inventory of every GMod API.

See [the brain API](docs/BRAIN.md) for its state machine, adapter and config,
[the core API](docs/CORE.md) for module loading, defaults and tie rules,
[the design](docs/DESIGN.md) for later stages and
[contributor conventions](AGENTS.md) for PR rules.

For an optional local game smoke check, place the repository as an addon
folder under `garrysmod/addons/gmantics/` and start the game. The stub prints
`[gmantics] loaded`. Spawn `gmantics_npc` from the gmantics category.
Spawn the fridge, bed, toilet and TV from the gmantics Entities category,
then spawn `gmantics_example_npc`. It has hunger, energy, bladder and fun
needs and uses nearby props as its needs decay. Place them within its
scan radius on accessible ground; the adapter moves directly toward objects.
Live GMod loading and locomotion need a game smoke check; the portable suite
does not exercise those engine APIs.

Binary assets listed in `.gitattributes` use Git LFS. Install Git LFS before
adding or checking out those assets; this scaffold contains none.

## Example objects and extending the addon

The fridge restores hunger, bed energy, toilet bladder and TV fun.
Their models are `models/props_c17/FurnitureFridge001a.mdl`,
`models/props_c17/FurnitureBed001a.mdl`,
`models/props_c17/FurnitureToilet001a.mdl` and
`models/props_c17/tv_monitor01.mdl`, respectively.
Default need definitions live in `lua/gmantics/needs_default.lua`.
See [Adding an entity](docs/ADDING_AN_ENTITY.md) for a minimal skeleton,
advertisement contract, new needs and a worked water-bottle example.

The test command also validates every example advertisement with fake entity
tables and verifies default need rates in a fresh registry. No in-game
behavior has been exercised here.
