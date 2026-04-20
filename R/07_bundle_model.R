# ------------------------------------------------------------------------------
# model_bundle(params = list())
#
# Construct the ModelBundle consumed by fluxCore::Engine.
#
# A ModelBundle is a named list of functions with these signatures:
#   - propose_events(entity, ctx)
#   - transition(entity, event, ctx)
#   - stop(entity, event, ctx)
#   - (optional) observe(entity, event, ctx)
#   - (optional) init_entity(entity, ctx)
#
# Why have a bundle constructor at all?
#   This is the cleanest place to:
#     - validate and freeze model parameters (params)
#     - register derived variables once (via init_entity)
#     - avoid globals by keeping params in the bundle
#
# Derived variables
#   - Derived variables are NOT core state. They are computed at snapshot time.
#   - In this template, derived vars are defined in R/derived_vars_model.R.
#   - fluxCore::Engine will call init_entity(entity, ctx) once at the
#     start of each run (if provided). We use that hook to register derived vars
#     by name via fluxCore::check_derived().
#
# Parameters
#   - fluxCore::Engine normalizes ctx once per run:
#       * ctx is always a list (NULL -> list())
#       * ctx$params always exists and is a list
#       * if ctx$params is missing, Engine can default it from bundle$params
#   - Therefore, downstream model code can consistently do:
#       p <- ctx$params
# ------------------------------------------------------------------------------
model_bundle <- function(params = list()) {
  
  # Optional: validate params here (fail fast)
  # if (!is.numeric(params$visit_rate) || params$visit_rate <= 0) stop("visit_rate must be > 0")
  
  init_entity <- function(entity, ctx) {
    # Register derived variables once. Idempotent by name.
    fluxCore::check_derived(entity, derived_vars_model(params), replace = FALSE)
    invisible(NULL)
  }
  
  list(
    # Optional defaults for ctx$params (Engine will use these if ctx$params not provided)
    params        = params,
    
    init_entity  = init_entity,
    propose_events = propose_events_model,
    transition     = transition_model,
    stop           = stop_model,
    observe        = observe_model
  )
}
