# gmantics design

gmantics is a SimAntics-like smart-object system: entities advertise actions
and their effects on needs, while NPCs choose nearby opportunities to meet
their needs. GMOD-1 defines the staged work; GMOD-2 supplies this scaffold
only. The behavior below is planned, not implemented.

## Layers

- **Core (`lua/gmantics/core/`):** need registry, decay, advertisements,
  scoring and deterministic selection. Pure Lua 5.1/LuaJIT; no GMod globals.
- **Brain (`lua/gmantics/brain/`):** NPC needs and action state machine.
  Adapters supply scanning, distance, movement, time and entity validity.
  Keep engine calls out of core and make adapters replaceable in tests.
- **Entities (`lua/entities/`):** advertise actions and bridge performance
  to the game. Later examples include a fridge, bed, toilet, TV and NPC.
- **Autorun (`lua/autorun/`):** entry point and future realm-aware loading.
  The current stub only prints a load message.

## Needs

A registry gives each need a stable name, initial value and nonnegative
decay rate per second. Values represent satisfaction: 100 is fully satisfied
and 0 is empty. Clamp all updates to 0..100. Given elapsed seconds `dt`,
decay is `value = max(0, value - decay_per_second * dt)`; applying effects
adds satisfaction and clamps at 100. Pass elapsed time explicitly rather
than reading an engine clock in core. A proposed normalized urgency is
`urgency(need) = (100 - value) / 100`.

## Advertisements and choice

An entity offers one or more data advertisements:

```lua
{ action = "eat", satisfies = { hunger = 40 }, duration = 3 }
```

`action` identifies the operation, `satisfies` maps registered need names
to satisfaction amounts, and `duration` is seconds spent performing it.
An adapter attaches an entity identity and distance; core does not receive
or inspect engine objects. Reject malformed data, unknown needs, negative
durations and invalid distances at the appropriate boundary. Final API
validation rules will be established with the core task.

For a positive distance falloff, score an advertisement by summing its
need contributions:

```text
score = sum(urgency(need) * amount) / (1 + distance / falloff)
```

This rewards urgently needed effects and discounts distant opportunities.
Duration controls performance timing; it is not a divisor in this formula.
Choose the highest positive score; no usable candidate yields no selection.
Resolve equal scores using stable entity and action identifiers, with a
stable advertisement index as a final tie-breaker. Do not depend on `pairs`
iteration order or random choice. The core task will specify the concrete
identifier contract and test selection against reordered candidates.

## NPC state machine

```text
IDLE -> SCAN -> MOVE -> PERFORM -> APPLY -> IDLE
```

- **IDLE:** wait until a scan is due; continue need decay with elapsed time.
- **SCAN:** ask the adapter for nearby advertisements within a configured
  radius and choose a candidate using core scoring. If none exists, return
  to IDLE and retry on a later scan.
- **MOVE:** ask the movement adapter to approach the selected entity.
  Arrival starts PERFORM; invalidation or movement failure cancels to IDLE.
- **PERFORM:** perform the selected action for its advertised duration.
  Recheck validity; interruption cancels without applying satisfaction.
- **APPLY:** apply the selected effects exactly once, clamp needs and clear
  the action before returning to IDLE.

The brain task will define scan cadence, arrival tolerance, movement
timeouts and action cancellation hooks. Time and outcomes must be
controllable through fake adapters so tests need no live game.

## Tests and delivery

Core tests will cover registration, clamping, elapsed-time decay,
advertisement validation, multi-need scoring, distance falloff, empty
selection and deterministic ties. Brain tests will use fake clocks,
scanners and movers to cover transitions, failures, interruptions and
exactly-once effects. Optional in-game smoke checks cover engine adapters
and examples; they are not prerequisites for running the core suite.

1. **GMOD-2:** addon scaffold, conventions and this design; no gameplay.
2. **GMOD-3:** pure-Lua core and unit tests.
3. **Task 3:** brain, needs state and adapter-backed scan/move/perform/apply.
4. **Task 4:** example entities and NPC, plus entity-authoring documentation.
5. **Task 5:** test runner integration and GitHub Actions using LuaJIT.

The runner may be plain Lua or Busted. No executable test command exists
in the scaffold; later tasks must document the chosen invocation in README
and both contributor files rather than imply a nonexistent suite passes.

Addon metadata follows the allowed types, tags and ignore-list format in
the [Facepunch Workshop guide](https://wiki.facepunch.com/gmod/Workshop_Addon_Creation).
