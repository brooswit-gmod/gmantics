# Contributor conventions

- Target GMod's Lua 5.1/LuaJIT environment. Avoid newer Lua syntax and
  GMod-only syntax extensions in portable modules.
- Keep `lua/gmantics/core/` free of all GMod globals and APIs. It must run
  under plain `luajit`, without a game installation. Pass time, distances,
  data and dependencies explicitly.
- Keep GMod-facing code thin and isolated behind adapters in
  `lua/gmantics/brain/` and entity integration in `lua/entities/`.
  Autorun is responsible for loading, not gameplay logic.
- Keep changes small and single-purpose. This scaffold introduces no
  gameplay logic; follow the staged plan in `docs/DESIGN.md`.
- Tests belong in `test/`. Run `luajit test/run.lua` from the repo root.
  The core suite uses plain-Lua assertions and needs no test dependencies.
  Test core behavior outside GMod and use fake adapters for brain tests.
- Open PRs into `main`; never push directly to `main`.
- Commit with a GitHub noreply author address, never a personal email.
- Use LF line endings and Git LFS for binary types in `.gitattributes`.
  Do not commit secrets, generated packages, logs or editor files.
- Keep this file and `CLAUDE.md` identical whenever conventions change.
