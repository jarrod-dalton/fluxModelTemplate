# patientSimModelTemplate

This is a **blank template** for building a model package that runs on top of
**patientSimCore**.

The intent is that you **copy/rename this repo** (e.g., to `patientSimCKD`) and then
replace the placeholder code in `R/` with your model logic.

## What you should edit first

1. `R/schema_model.R` — define your model's *core state* and block membership.
2. `R/bundle_model.R` — wires your functions into a ModelBundle.
3. `R/propose_events_model.R` — propose event candidates across processes.
4. `R/transition_model.R` — apply state transitions (return named list or NULL).
5. `R/stop_model.R` — stop conditions.
6. `R/observe_model.R` (optional) — emit observation rows.

## Documentation

This template intentionally keeps package documentation minimal.
Read `inst/MODEL_PACKAGE_GUIDE.md` and the `patientSimCore` documentation for details.
