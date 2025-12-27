# ------------------------------------------------------------------------------
# derived_vars_model(params = list())
#
# Purpose
#   Define derived variables for your model in ONE place.
#
# Derived variables are NOT core state. They are computed at snapshot time.
# In patientSimCore, derived variables are stored on the Patient object as a
# named list of functions:
#   f(patient, j, t) -> scalar (or NULL)
#
# Notes
#   - Derived vars should depend on core state and/or event history.
#   - Keep derived vars non-recursive (do not call patient$snapshot() inside).
#   - If you need history, use patient$events (event log) and patient$state_at(...)
#     (or add model-specific helper accessors).
# ------------------------------------------------------------------------------
derived_vars_model <- function(params = list()) {

  # Example 1: blood pressure control indicator (depends on core state)
  bp_controlled <- function(patient, j, t) {
    # Read from core state cache (current state at last_j).
    sbp <- patient$state("sbp")
    dbp <- patient$state("dbp")
    if (is.null(sbp) || is.null(dbp) || any(is.na(c(sbp, dbp)))) return(NA)
    isTRUE(sbp <= 130 && dbp <= 80)
  }

  # Example 2: count of no-shows to date (depends on event history)
  n_no_show <- function(patient, j, t) {
    # patient$events is a data.frame-like event log.
    ev <- patient$events
    if (is.null(ev) || nrow(ev) == 0) return(0L)
    if (!("event_type" %in% names(ev))) return(0L)
    sum(ev$event_type == "clinic_no_show", na.rm = TRUE)
  }

  # Return a named list of derived var functions
  list(
    bp_controlled = bp_controlled,
    n_no_show = n_no_show
  )
}
