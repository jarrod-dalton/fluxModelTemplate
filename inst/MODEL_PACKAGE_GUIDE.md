# Model Package Guide (Template)

This template exists to help you create a model package that runs on `patientSimCore`.

The **core simulator** lives in `patientSimCore` (Patient, Engine, updates helpers).
Your model package should provide:
- a schema function (e.g., `model_schema()`)
- a bundle constructor (e.g., `model_bundle()`), which returns a ModelBundle with:
  - `propose_events(patient, ctx)`
  - `transition(patient, event, ctx)`
  - `stop(patient, event, ctx)`
  - optional `observe(patient, event, ctx)`

## Design rules (recommended)

- Keep signatures **event-centric**: `transition(patient, event, ctx)`.
- `transition()` returns a **named list** of scalar updates (mixed types OK) or `NULL`.
- Use `patientSimCore::update_block()` for panel updates and
  `patientSimCore::combine_updates()` to combine update lists safely.
- Document your time unit via `ctx$time_unit` (e.g., `"days"`, `"months"`, `"years"`).
- Avoid relying on schema ordering. Prefer named updates.

## Minimal runnable loop (after you implement)

- Build a patient:
  - `p <- patientSimCore::new_patient(init=..., schema=model_schema())`
- Build a bundle:
  - `b <- model_bundle()`
- Run:
  - `eng <- patientSimCore::Engine$new(bundle=b)`
  - `out <- eng$run(p, ctx=list(time_unit="years"), max_events=100)`

## Where to look in patientSimCore

- The ModelBundle contract and engine behavior
- Event objects and process_id
- Derived variables and snapshots
- Batch runs (`run_cohort()`)

This template does *not* duplicate that documentation.
