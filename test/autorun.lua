-- Model GMod's require rejecting addon modules even if package.loaded has them.
local original_require = require
SERVER = true
CompileFile = function(path) return assert(loadfile("lua/" .. path)) end
require = function(name) error("engine require cannot load " .. name) end
local engine_require = require
dofile("lua/autorun/gmantics_init.lua")
assert(require == engine_require, "autorun replaced the engine's require")
assert(gmantics.Needs.get("hunger").decay_per_sec == 1)
local state = gmantics.NeedState.new({ hunger = 20 })
state:tick(1)
assert(state:get("hunger") == 19)
assert(gmantics.Brain.new({}, state, { now = function() return 0 end }).state == "IDLE")
assert(type(gmantics.Adapter.move) == "function")
require = original_require
print("Autorun loads dependencies without engine require or global replacement")
