# ------------------------------------------------------------------------------
# model_bundle(params = list())
#
# Purpose
#   Construct the ModelBundle that patientSimCore::Engine will run.
#   A ModelBundle is a named list of functions:
#     - propose_events(patient, ctx)
#     - transition(patient, event, ctx)
#     - stop(patient, event, ctx)
#     - (optional) observe(patient, event, ctx)
#
# Why have a bundle constructor at all?
#   - It’s the cleanest place to:
#       * validate + freeze model parameters
#       * register derived variables on the patient (if you want them)
#       * set defaults into ctx (time_unit, horizon, etc.) via closures
#       * optionally define refresh behavior (if you later expose it)
#
# Notes
#   - The Engine calls bundle functions; it does not care which package they come from.
#   - Prefer explicit "params" and explicit "ctx" usage over hidden globals.
#
# Derived variables
#   - Derived variables are NOT core state. They are computed at snapshot time.
#   - In patientSimCore, derived vars are attached to the patient object.
#   - Two common patterns:
#
#     Pattern A (recommended): register derived vars when you create the patient
#       - i.e., in your user-facing helper `new_<model>_patient()`
#
#     Pattern B (okay for templates/examples): register derived vars inside the bundle
#       - you must do it idempotently (don’t re-register every call)
#
# Below we show Pattern B with a safe "register once" helper.
# ------------------------------------------------------------------------------
model_bundle <- function(params = list()) {
  
  # --------------------------------------------------------------------------
  # Parameter handling
  #
  # Put all fixed model parameters into a local list. This makes the bundle
  # self-contained and easy to swap between parameter draws.
  #
  # Example: default parameters + user overrides
  # --------------------------------------------------------------------------
  default_params <- list(
    # Example knobs:
    # visit_rate = 2.0,              # visits per time-unit
    # p_no_show  = 0.10,
    # lab_turnaround = 0.02
  )
  
  p <- utils::modifyList(default_params, params)
  
  # Optional: validate params here (fail fast)
  # if (!is.numeric(p$visit_rate) || p$visit_rate <= 0) stop("visit_rate must be > 0")
  
  # --------------------------------------------------------------------------
  # Derived variable registration (Pattern B: register once on the patient)
  #
  # Derived variables are functions evaluated at snapshot time. They can use:
  #   - patient core state
  #   - lagged values (via helpers like lag_of)
  #   - event history and metadata (if your helper supports it)
  #
  # This template uses an idempotent registration helper so we don't keep adding
  # derived vars across repeated runs or batch contexts.
  #
  # IMPORTANT:
  #   The exact registration API depends on patientSimCore's derived-var helpers.
  #   The example below matches the design you described:
  #     - derive(name, target, lookback_t, lookback_j, fn, include_current, force)
  #     - lag_of(var, k)
  # --------------------------------------------------------------------------
  register_derived_once <- function(patient) {
    # Use a private marker in the patient object to avoid duplicate registration.
    # We store it in patient$.__private__ if available; otherwise attach an attribute.
    # (Pick ONE approach in your real codebase. This is template-friendly.)
    
    already <- FALSE
    # Attempt attribute marker first (safe and non-invasive)
    marker <- attr(patient, ".__template_derived_registered__")
    if (isTRUE(marker)) already <- TRUE
    if (already) return(invisible(NULL))
    
    # ---- Example derived vars (edit/remove as needed) -----------------------
    
    # Example 1: BP control flag (requires sbp/dbp in core state)
    # bp_controlled(t) = I(sbp <= 130 & dbp <= 80)
    #
    # patientSimCore::derive(
    #   name = "bp_controlled",
    #   target = NULL,              # derived vars are not stored in core state
    #   lookback_t = NULL,
    #   lookback_j = 0,
    #   include_current = TRUE,
    #   force = TRUE,
    #   fn = function(snap, patient, event, ctx) {
    #     isTRUE(snap$sbp <= 130 && snap$dbp <= 80)
    #   }
    # )
    
    # Example 2: last SBP (lag-1) using helper
    # patientSimCore::lag_of("sbp", k = 1)
    
    # Example 3: no-show counter as a derived variable
    # This depends on whether patientSimCore exposes event history accessors.
    # If you have patient$events() returning an event log:
    #
    # patientSimCore::derive(
    #   name = "n_no_show",
    #   target = NULL,
    #   lookback_t = NULL,
    #   lookback_j = NULL,
    #   include_current = TRUE,
    #   force = TRUE,
    #   fn = function(snap, patient, event, ctx) {
    #     ev <- patient$events()
    #     sum(ev$event_type == "clinic_no_show", na.rm = TRUE)
    #   }
    # )
    
    # Mark as registered
    attr(patient, ".__template_derived_registered__") <- TRUE
    invisible(NULL)
  }
  
  # --------------------------------------------------------------------------
  # Wrap the core bundle functions so we can:
  #   - ensure derived vars are registered
  #   - close over params (p) cleanly
  # --------------------------------------------------------------------------
  propose_events_wrapped <- function(patient, ctx) {
    register_derived_once(patient)
    # You can also merge params into ctx here if desired, but keep it explicit:
    # ctx$params <- p
    propose_events_model(patient, ctx = utils::modifyList(ctx, list(params = p)))
  }
  
  transition_wrapped <- function(patient, event, ctx) {
    register_derived_once(patient)
    transition_model(patient, event, ctx = utils::modifyList(ctx, list(params = p)))
  }
  
  stop_wrapped <- function(patient, event, ctx) {
    register_derived_once(patient)
    stop_model(patient, event, ctx = utils::modifyList(ctx, list(params = p)))
  }
  
  observe_wrapped <- function(patient, event, ctx) {
    register_derived_once(patient)
    observe_model(patient, event, ctx = utils::modifyList(ctx, list(params = p)))
  }
  
  # Return the ModelBundle
  list(
    propose_events = propose_events_wrapped,
    transition     = transition_wrapped,
    stop           = stop_wrapped,
    observe        = observe_wrapped
  )
}
