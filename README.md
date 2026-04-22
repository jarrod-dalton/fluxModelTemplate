# fluxModelTemplate

`fluxModelTemplate` is a starter scaffold for building a new model package on top of `fluxCore`.

This template is intentionally simple:

- each required function scaffold exists and runs with safe defaults
- worked example logic is commented so you can fill it in safely
- comments explain what each function takes and must return

## Major framework components

A flux model package has a small number of structural pieces:

- **State schema**: defines core variables that represent the evolving system state.
- **Event proposal**: proposes future candidate events on one or more processes.
- **Transition logic**: updates core state when an event is realized.
- **Stop logic**: decides when simulation ends.
- **Observation logic (optional)**: emits row-like outputs for analysis.
- **Derived variables (optional)**: computed summaries of state/history at snapshot time.
- **Bundle**: wires those functions into one object used by `fluxCore::Engine`.

Template mapping:

- `R/01_schema_model.R` -> state schema
- `R/03_propose_events_model.R` -> event proposal
- `R/04_transition_model.R` -> transition logic
- `R/05_stop_model.R` -> stop logic
- `R/06_observe_model.R` -> observation logic (optional)
- `R/02_derived_vars_model.R` -> derived variables (optional)
- `R/07_bundle_model.R` -> model bundle

## State variables vs derived variables

- **State variables** are the model's canonical evolving values. They are updated by `transition_model()`.
- **Derived variables** are computed views of state/history. They are not written by transitions; they are functions evaluated at snapshot time.

In short: transitions mutate core state; derived functions summarize it.

## Event index `j` vs time `t`

Flux models are event-driven with irregular time gaps.

- `j` indexes event order (`j = 0, 1, 2, ...`).
- `t` is simulation time on your chosen scale (hours, days, years, etc.).
- Events are ordered by `j`, but event times `t_j` are generally irregular.

This lets you model systems where updates happen at uneven times while still having a clear event sequence.

## First step: set a model time unit

Set your model time unit once in the package config JSON
(`inst/model_config/time_spec.json`) before you start writing model logic.
For the urban food delivery example, use **hours**.

Recommended pattern:

```r
# model_bundle() reads canonical time via model_time_spec() from JSON
bundle <- model_bundle()
```

`fluxCore` will propagate canonical time metadata into run contexts internally;
model-facing code should not pass runtime time-unit overrides.

## Tiny example problem used in comments

The inline comments use a small **urban food delivery operations** example as a teaching device.
Replace it with your own domain.

Example state variables:

- `route_zone`: where the courier is operating (for example, urban/suburban/rural).
- `battery_pct`: current battery level of the delivery vehicle.
- `payload_kg`: current package load being carried.
- `dispatch_mode`: current workflow state (idle, assigned, in transit, completed).

Example event types:

- `dispatch_check`: a dispatch decision point where assignment/reassignment can occur.
- `delivery_completed`: a drop-off completion event.
- `end_shift`: optional stop event for end-of-simulation scenarios.

Example behavior:

- `propose_events_model()` proposes candidate future events.
- `transition_model()` applies state updates when an event occurs.
- `stop_model()` decides whether simulation should stop.
- `observe_model()` optionally emits row-like output for analysis.

## Build order

Edit in this order:

1. `R/01_schema_model.R`
2. `R/03_propose_events_model.R`
3. `R/04_transition_model.R`
4. `R/05_stop_model.R`
5. `R/07_bundle_model.R`
6. `R/02_derived_vars_model.R` (optional)
7. `R/06_observe_model.R` (optional)

## Why scripts contain live code

The function shells are runnable on purpose (safe defaults) so the package can load/test immediately.
Worked examples inside those shells are commented on purpose; uncomment/adapt them as you build your model.

- `propose_events_model()` starts as `list()`
- `transition_model()` starts as `NULL`
- `stop_model()` starts as `FALSE` (unless you add a rule)
- `observe_model()` starts as `NULL`

That gives you a clean starting point while you replace placeholders with real model logic.
