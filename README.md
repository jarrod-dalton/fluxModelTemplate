# fluxModelTemplate
[![Release](https://img.shields.io/github/v/release/jarrod-dalton/fluxModelTemplate?display_name=tag)](https://github.com/jarrod-dalton/fluxModelTemplate/releases)
[![Downloads](https://img.shields.io/github/downloads/jarrod-dalton/fluxModelTemplate/total)](https://github.com/jarrod-dalton/fluxModelTemplate/releases)
[![License: Apache-2.0](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![Language: R](https://img.shields.io/badge/language-R-276DC3?logo=r&logoColor=white)](https://www.r-project.org/)

`fluxModelTemplate` is a starter scaffold for building a new model package on top of `fluxCore`.

This template is intentionally simple:

- each required function scaffold exists and runs with safe defaults
- urban delivery worked-example logic is active and editable
- comments explain what each function takes and must return

## Major framework components

A flux model package has a small number of structural pieces:

- **State schema**: defines core variables that represent the evolving system state.
- **Event proposal**: proposes future candidate events on one or more processes.
- **Event organization**: declares allowed event labels and terminal endpoint set.
- **Transition logic**: updates core state when an event is realized.
- **Stop logic**: decides when simulation ends.
- **Observation logic (optional)**: emits row-like outputs for analysis.
- **Derived variables (optional)**: computed summaries of state/history at snapshot time.
- **Bundle**: wires those functions into one object used by `fluxCore::Engine`.
- **Refresh rules (optional)**: post-event scheduler hook selecting which process clocks to recompute.

Template mapping:

- `R/01_schema_model.R` -> state schema
- `R/03_propose_events_model.R` -> event proposal
- `R/07_bundle_model.R` -> event catalog + terminal endpoint declaration
- `R/04_transition_model.R` -> transition logic
- `R/05_stop_model.R` -> stop logic
- `R/06_observe_model.R` -> observation logic (optional)
- `R/02_derived_vars_model.R` -> derived variables (optional)
- `R/07_bundle_model.R` -> model bundle
- `R/07_bundle_model.R` -> optional `refresh_rules(...)` targeting hook

## State variables vs derived variables

- **State variables** are the model's canonical evolving values. They are updated by `transition_model()`.
- **Derived variables** are computed views of state/history. They are not written by transitions; they are functions evaluated at snapshot time.

In short: transitions mutate core state; derived functions summarize it.

## Lifecycle semantics (practical default)

Forecast/summary tools construct lifecycle eligibility in this order:

1. Use modeled `alive` if your schema includes it.
2. Else, derive lifecycle from first occurrence of `terminal_events` declared in the bundle.
3. Else, fallback to lifecycle-active wherever runs are defined.

For most models, declare `event_catalog` and `terminal_events` in `model_bundle()` even if you also keep `alive`.

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
- `model_bundle()` declares `event_catalog` and `terminal_events`.
- `transition_model()` applies state updates when an event occurs.
- `stop_model()` decides whether simulation should stop.
- `observe_model()` optionally emits row-like output for analysis.

Optional scheduler behavior:

- Omit `refresh_rules(...)` and engine defaults to `"ALL"` refresh (safe path).
- Add `refresh_rules(...)` only when you want targeted process refresh.
- If implemented, return either:
  - `"ALL"` (exact scalar), or
  - character vector of unique `process_id` values.

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

The function shells are runnable on purpose so the package can load/test immediately and run a short simulation without edits.
The urban delivery behavior is a teaching baseline, not a required design.
Adapt or replace each function as you build your own model.
