# ------------------------------------------------------------------------------
# model_bundle(params = list())
#
# WHAT THIS FUNCTION IS
#   model_bundle() is the "wiring function" for your model package.
#   It returns one list object (ModelBundle) that tells fluxCore::Engine
#   which functions to call for simulation behavior.
#
# INPUTS
#   params: optional parameter list passed through to your model helpers.
#
# OUTPUT
#   A named list with hook functions and optional defaults.
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
# WHAT TO EDIT
#   Usually minimal edits:
#   - keep function pointers aligned with your actual function names
#   - include/remove optional hooks as needed
# ------------------------------------------------------------------------------
model_bundle <- function(params = list()) {
  init_entity <- function(entity, ctx) {
    # Example setup: register derived variable functions once per entity/run.
    fluxCore::check_derived(entity, derived_vars_model(params), replace = FALSE)
    invisible(NULL)
  }

  list(
    params = params,                         # default model parameters
    init_entity = init_entity,               # optional one-time setup
    propose_events = propose_events_model,   # required
    transition = transition_model,           # required
    stop = stop_model,                       # required
    observe = observe_model                  # optional
  )
}
