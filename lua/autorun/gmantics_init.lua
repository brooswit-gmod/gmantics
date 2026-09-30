if SERVER then
    -- include returns the same module tables that plain Lua loads with require.
    local function load(name)
        local module = include("gmantics/" .. name .. ".lua")
        package.loaded["gmantics." .. name:gsub("/", ".")] = module
        return module
    end
    load("core/check")
    local needs = load("core/needs")
    local state = load("core/needstate")
    load("core/ads")
    load("core/scoring")
    load("core/select")
    gmantics = { Needs = needs, NeedState = state,
        Brain = load("brain/brain"), Adapter = load("brain/adapter") }
    if not needs.all().hunger then needs.define("hunger", { decay_per_sec = 1 }) end
    if not needs.all().energy then needs.define("energy", { decay_per_sec = 0.5 }) end
end
print("[gmantics] loaded")
