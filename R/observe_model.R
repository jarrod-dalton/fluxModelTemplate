# ------------------------------------------------------------------------------
# observe_model(patient, event, ctx)   [optional]
#
# Purpose
#   Emit observation rows for downstream analysis (visits, labs, risk estimates,
#   utilization metrics, etc.) without mutating patient state.
#
# Inputs
#   - patient: Patient R6 object
#       * patient$time            current simulation time
#       * patient$state(name)     read core state
#       * patient$snapshot()      read core + derived variables (derived evaluated now)
#   - event: realized event
#       * event$time_next
#       * event$event_type
#       * event$process_id
#       * any custom metadata added in propose_events()
#   - ctx: context list
#
# Output
#   - A single observation row (list or 1-row data.frame), OR
#   - NULL to emit no observation for this event
#
# Design guidance
#   - observe() should NOT change core state.
#   - Prefer explicit, event-scoped rows (one row per event).
#   - Use snapshot() if you want derived variables included.
#   - Downstream code (Engine/run_cohort) is responsible for binding rows.
#
# Common use cases
#   - Visit records (attended vs no-show)
#   - Lab result records
#   - Risk score trajectories
#   - Resource utilization summaries
# ------------------------------------------------------------------------------
observe_model <- function(patient, event, ctx) {
  
  # --------------------------------------------------------------------------
  # Recommended pattern: branch on event type
  # --------------------------------------------------------------------------
  et <- event$event_type
  
  # --------------------------------------------------------------------------
  # Example: clinic visit observation
  # --------------------------------------------------------------------------
  if (et == "clinic_visit") {
    
    # snap <- patient$snapshot()
    #
    # return(list(
    #   time       = patient$time,
    #   event_type = et,
    #   attended   = TRUE,              # or FALSE if you encode no-shows
    #   age        = snap$age,
    #   sbp        = snap$sbp,
    #   dbp        = snap$dbp,
    #   n_tx       = snap$n_antihypertensives
    # ))
    return(NULL)
  }
  
  # --------------------------------------------------------------------------
  # Example: lab draw observation
  # --------------------------------------------------------------------------
  if (et == "bmp_draw") {
    
    # snap <- patient$snapshot()
    #
    # return(list(
    #   time       = patient$time,
    #   event_type = et,
    #   sodium     = snap$sodium,
    #   potassium  = snap$potassium,
    #   creatinine = snap$creatinine,
    #   glucose    = snap$glucose
    # ))
    return(NULL)
  }
  
  # --------------------------------------------------------------------------
  # Example: terminal event observation
  # --------------------------------------------------------------------------
  if (et == "terminal_event") {
    
    # return(list(
    #   time       = patient$time,
    #   event_type = et
    # ))
    return(NULL)
  }
  
  # --------------------------------------------------------------------------
  # Default: emit nothing
  # --------------------------------------------------------------------------
  NULL
}
