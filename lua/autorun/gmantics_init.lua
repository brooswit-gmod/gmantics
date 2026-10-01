if SERVER then
    -- GMod's require does not consult Lua's package.loaded. Give only these
    -- modules a private require environment; leave the engine's global alone.
    local modules = {}
    local environment = setmetatable({ require = function(name)
        assert(modules[name], "gmantics dependency not loaded: " .. name)
        return modules[name]
    end }, { __index = _G })
    local function load(name)
        local chunk = assert(CompileFile("gmantics/" .. name .. ".lua"))
        setfenv(chunk, environment)
        local module = chunk()
        modules["gmantics." .. name:gsub("/", ".")] = module
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
    load("needs_default")
end
print("[gmantics] loaded")
