# Portable core API

Modules use standard Lua `require`. From the repository root, prepend
`./lua/?.lua;` to `package.path`. Modules live under `gmantics.core`:
`needs`, `needstate`, `ads`, `scoring`, and `select`. No engine is required.

```lua
package.path = "./lua/?.lua;" .. package.path
local Needs = require("gmantics.core.needs")
local NeedState = require("gmantics.core.needstate")
local Select = require("gmantics.core.select")
Needs.define("hunger", { decay_per_sec = 2, start = 80 })
local state = NeedState.new({ hunger = true })
state:tick(5) -- hunger is now 70
local candidate = Select.best({
    { ad = { action = "eat", satisfies = { hunger = 40 }, duration = 3 },
      distance = 100, source = "fridge-1" }
}, state)
```

`Needs.define(id, options)` registers a unique nonempty string id. Defaults
are min 0, max 100, start at max, decay 0. Bounds must have positive width,
start must be in bounds and decay must be nonnegative. `Needs.get(id)` and
`Needs.all()` return copies (the latter is a map keyed by id). Unknown ids
and duplicate definitions error. All numeric input must be finite.

`NeedState.new(agent_needs)` takes a map of registered ids to initial
numbers, or `true` to use the registered start. An empty map is valid.
Initial values and `state:add(id, delta)` clamp to the need's own bounds.
`state:get(id)` errors if the need is unknown or absent from that agent.
`state:tick(dt)` subtracts decay times nonnegative elapsed seconds and
clamps; states are independent. Treat the state's `values` and `definitions`
tables as internal and update through methods.

`Ads.validate(ad)` returns the validated table or errors. The action must
be a nonempty string, duration positive, and satisfies a map of registered
need ids to finite amounts. Signed amounts and empty effects are allowed;
optional cost must be finite. Duration and cost are metadata and do not
change scoring.

`Scoring.score(ad, state, distance, config)` sums
`((max - value) / (max - min))^urgency_exponent * amount` for the agent's
needs, then divides by `1 + distance / falloff`. Registered needs absent
from the agent contribute zero. Distance must be nonnegative. Defaults
are `falloff = 1000` and `urgency_exponent = 2`; falloff must be positive,
exponent greater than 1 to retain convex urgency. Sorted need ids make
floating-point accumulation reproducible.

`Select.best(candidates, state, config)` accepts a dense array of
`{ad, distance, source, index?}` tables and returns the original candidate.
`source` must be a stable string or finite number supplied by an adapter,
never an engine object. Only scores strictly above `config.min_score`
(default 0) qualify; empty lists or no qualifying score return nil.
Exact ties use action name, then source id (numeric before string, numbers
numerically and strings lexically), then numeric index (default 0).
Use unique stable advertisement indices for different ads sharing an
action and source. Candidates with identical tie keys are equivalent;
their first occurrence wins. Config tables are read without mutation.

Run `luajit test/run.lua` from the repository root. The suite uses plain-Lua
assertions, with no Busted dependency.
