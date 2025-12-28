# Multi-model composition, namespaces, and handoffs (optional)

This page is an **advanced extension** to the standard single-model workflow (Scripts 01–07).
Use it only when multiple submodels govern different phases or episodes on the **same canonical
patient time axis** (e.g., hospitalization → chronic disease).

## Three pillars

1. **One canonical time axis** (Core): time is monotone; events occur at times; snapshots live on that axis.
2. **Alive is canonical truth**: `core$alive` is biological truth.
3. **Models own state**: each model keeps its variables in a namespace (`state$ascvd$...`, `state$hospital$...`).

## Why namespaces exist

If both a hospitalization model and an ASCVD model track LDL, they usually mean different things:

- `hospital$ldl_measured`: a lab measurement during admission (timing + noise + acute effects)
- `ascvd$ldl`: a latent chronic-risk state variable used for hazards

Namespaces allow both LDLs to coexist without collision.

## Scope is not life

A model can be out of scope while the patient is still alive.

- `core$alive`: biological truth
- `core$model_active`: which model(s) are currently responsible for updating state

## Handoffs are explicit payloads

A handoff event does two things:

1. Flip scope flags (e.g., hospital off, ascvd on).
2. Apply an explicit payload update (e.g., optionally assimilate `hospital$ldl_measured` into `ascvd$ldl`).

No silent copying.

## State vs history

The Patient object already records sparse history snapshots at event times. Prefer:

- Store *latent* evolving quantities in state (`ascvd$ldl`).
- Record *what happened when* via snapshots (admissions, discharges).
- Compute windowed summaries as derived variables from history:
  - `time_since_last_hosp(t)`
  - `n_hosp_12mo(t)`

## Worked toy example

See `docs/examples/08_multi_model_toy.R`.
