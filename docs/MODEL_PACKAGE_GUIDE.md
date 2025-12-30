# Model Package Guide (Template)

This template is the canonical starting point for building a new disease model package that plugs into the **patientSim ecosystem**:

- **patientSimCore**: simulation engine (patients, events, time, execution)
- **patientSimForecast**: forward simulation + summaries (risk, survival, state summaries)
- **Disease package (this one)**: *thin, declarative* model logic (schema, transitions, events)

The guiding idea is: **Core owns the simulation truth**. Disease packages define model rules and defaults, but do not re-implement engine logic.

## Repository layout

- `R/`  
  Numbered scaffolding files you edit in order (see below).
- `docs/`  
  Human-facing documentation and helper scripts that should *not* be part of package runtime:
  - `docs/optional_extensions/` – patterns you may or may not adopt
  - `docs/templates/` – snippets you can copy into your model package

Top-level `README.md` remains the entry point; `docs/` is the “manual”.

## Build your model in this order

1. `R/01_schema_model.R`  
   Define the **patient schema** (required fields, defaults, blocks, and canonical variables like `alive`).

2. `R/02_derived_vars_model.R`  
   Define **derived variables** (computed from base state). Keep these deterministic and side-effect free.

3. `R/03_propose_events_model.R`  
   Define how the model proposes candidate events from the current state.

4. `R/04_transition_model.R`  
   Define how state updates occur when an event fires.

5. `R/05_stop_model.R`  
   Define stop logic (when the engine should stop running for a patient).

6. `R/06_observe_model.R`  
   Define what gets “observed” at requested times (if your model needs custom observation behavior).

7. `R/07_bundle_model.R`  
   Assemble and export the `ModelBundle`.

## Alive vs follow-up (important semantics)

`alive` should be a **canonical schema variable**.

However, being **in follow-up / defined at time *t*** may depend on the model. A simulation can stop for reasons other than death (e.g., transplant, MI, stroke, administrative censoring). In those cases:

- state may be **undefined after stop time**
- `alive` at those later times is **unknown**, not `FALSE`

This distinction is critical for summaries that condition on “alive and in follow-up at time t”.

## Forecast integration

See `docs/optional_extensions/03_forecast_integration.R` for examples of running:

- `forecast(..., ctx=<list>)`
- `forecast(..., ctx=<list-of-ctx>)` where each context can provide its own `$params`
- summary workflows that pool runs across parameter sets as posterior predictive draws

For the math behind pooling and quantiles, see:
- `patientSimForecast/docs/posterior_summary_math.md`

## Optional extensions

The following scripts are intentionally kept out of `/R` so they don’t become part of package runtime:

- `docs/optional_extensions/01_bundle_sources.R`  
  Patterns for loading bundles from different **bundle sources** (package, file, registry).

- `docs/optional_extensions/02_compose_bundles.R`  
  Patterns for composing model modules into larger bundles.

- `docs/optional_extensions/03_forecast_integration.R`  
  End-to-end forecasting patterns, including list-of-ctx usage.

## What this template does *not* do

- It does not try to reproduce the engine internals (that belongs in Core).
- It does not enforce CRAN conventions beyond what helps catch real bugs.
- It does not mandate optional extensions—use only what you need.
