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
- Tests belong in `test/`. No runner exists yet. Core tests arrive in
  GMOD-3; the final task wires a plain-Lua or Busted runner and LuaJIT CI.
  Once implemented, document the exact command in README and here.
  Test core behavior outside GMod and use fake adapters for brain tests.
- Open PRs into `main`; never push directly to `main`.
- Commit with a GitHub noreply author address, never a personal email.
- Use LF line endings and Git LFS for binary types in `.gitattributes`.
  Do not commit secrets, generated packages, logs or editor files.
- Keep this file and `CLAUDE.md` identical whenever conventions change.
