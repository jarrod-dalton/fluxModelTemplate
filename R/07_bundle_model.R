# ------------------------------------------------------------------------------
# model_bundle(params = list(), bundle_time_spec = model_time_spec())
#
# WHAT THIS FUNCTION IS
#   model_bundle() is the "wiring function" for your model package.
#   It returns one list object (ModelBundle) that tells fluxCore::Engine
#   which functions to call for simulation behavior.
#
# INPUTS
#   params: optional parameter list passed through to your model helpers.
#   bundle_time_spec: canonical time spec for the model.
#     In practice, source this from one central declaration in your package
#     (for example model_time_spec() that reads JSON config).
#
# OUTPUT
#   A named list with hook functions and optional defaults.
#
# EVENT ORGANIZATION (recommended)
#   Include:
#     - event_catalog: all allowed event_type labels in the model
#     - terminal_events: subset of event_catalog treated as terminal endpoints
#
#   Lifecycle behavior in downstream forecast tools:
#     - if schema defines `alive`, that is authoritative
#     - else if terminal_events declared, lifecycle is derived from first terminal event
#     - else lifecycle defaults to active while runs are defined
#
# RUNTIME CALL ORDER (mental model)
#   For each entity in Engine$run():
#     1) init_entity(entity, ctx)            # optional one-time setup
#     2) propose_events(entity, ctx)         # propose candidate next events
#     3) transition(entity, event, ctx)      # return state updates
#     4) entity$update(...)                  # Core applies updates internally
#     5) observe(entity, event, ctx)         # optional output row
#     6) stop(entity, event, ctx)            # stop/continue decision
#     7) loop until stop/max_events/max_time
#
# WHY init_entity EXISTS
#   init_entity is for per-run setup, not baseline state input.
#   Baseline state values come from Entity$new(..., init = ...) / new_entity(...).
#   Common init_entity use: register derived variables once before event loop.
#
# ABOUT params IN THE BUNDLE
#   params is stored on the bundle so model defaults are available during runs.
#   Core can propagate bundle$params into ctx$params if ctx$params is missing.
#
# WHY time_spec IS INCLUDED IN THE BUNDLE
#   Even when canonical time is defined centrally (for example in JSON),
#   Engine still needs an in-memory time_spec object at runtime.
#   Current fluxCore contract expects bundle$time_spec, and Engine propagates it
#   through run contexts. So: one central source of truth, attached here.
#
# WHAT TO EDIT
#   Usually minimal edits:
#   - keep function pointers aligned with your actual function names
#   - include/remove optional hooks as needed
# ------------------------------------------------------------------------------
model_bundle <- function(
  params = list(),
  bundle_time_spec = model_time_spec()
) {
  if (!inherits(bundle_time_spec, "time_spec")) {
    stop("bundle_time_spec must be a fluxCore::time_spec(...) object.", call. = FALSE)
  }

  init_entity <- function(entity, ctx) {
    # Example setup: register derived variable functions once per entity/run.
    dv <- derived_vars_model(params)
    if (!is.null(dv) && length(dv) > 0L) {
      fluxCore::check_derived(entity, dv, replace = FALSE)
    }
    invisible(NULL)
  }

  list(
    params = params,                         # default model parameters
    time_spec = bundle_time_spec,            # canonical model time declaration
    event_catalog = c("dispatch_check", "delivery_completed", "end_shift"),
    terminal_events = "end_shift",
    init_entity = init_entity,               # optional one-time setup
    propose_events = propose_events_model,   # required
    transition = transition_model,           # required
    stop = stop_model,                       # required
    observe = observe_model                  # optional
  )
}
