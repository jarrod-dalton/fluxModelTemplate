# ------------------------------------------------------------------------------
# model_bundle(params = list())
#
# Construct the ModelBundle consumed by patientSimCore::Engine.
#
# A ModelBundle is a named list of functions with these signatures:
#   - propose_events(patient, ctx)
#   - transition(patient, event, ctx)
#   - stop(patient, event, ctx)
#   - (optional) observe(patient, event, ctx)
#   - (optional) init_patient(patient, ctx)
#
# Why have a bundle constructor at all?
#   This is the cleanest place to:
#     - validate and freeze model parameters (params)
#     - register derived variables once (via init_patient)
#     - avoid globals by keeping params in the bundle
#
# Derived variables
#   - Derived variables are NOT core state. They are computed at snapshot time.
#   - In this template, derived vars are defined in R/derived_vars_model.R.
#   - patientSimCore::Engine will call init_patient(patient, ctx) once at the
#     start of each run (if provided). We use that hook to register derived vars
#     by name via patientSimCore::check_derived().
#
# Parameters
#   - patientSimCore::Engine normalizes ctx once per run:
#       * ctx is always a list (NULL -> list())
#       * ctx$params always exists and is a list
#       * if ctx$params is missing, Engine can default it from bundle$params
#   - Therefore, downstream model code can consistently do:
#       p <- ctx$params
# ------------------------------------------------------------------------------
model_bundle <- function(params = list()) {
  
  # Optional: validate params here (fail fast)
  # if (!is.numeric(params$visit_rate) || params$visit_rate <= 0) stop("visit_rate must be > 0")
  
  init_patient <- function(patient, ctx) {
    # Register derived variables once. Idempotent by name.
    patientSimCore::check_derived(patient, derived_vars_model(params), replace = FALSE)
    invisible(NULL)
  }
  
  list(
    # Optional defaults for ctx$params (Engine will use these if ctx$params not provided)
    params        = params,
    
    init_patient  = init_patient,
    propose_events = propose_events_model,
    transition     = transition_model,
    stop           = stop_model,
    observe        = observe_model
  )
}
