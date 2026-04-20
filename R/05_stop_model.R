# ------------------------------------------------------------------------------
# stop_model(entity, event, ctx)
#
# Purpose
#   Decide whether the simulation stops after the current event.
#
# Inputs
#   - entity: Entity R6 object (use entity$state(...) and entity$last_time)
#   - event: realized event (event_type, time_next, process_id, etc.)
#   - ctx: context list (time_horizon, flags, etc.)
#
# Output
#   TRUE to stop, FALSE to continue.
#
# Common stop conditions
#   1) A terminal event occurred (death, MI, transplant, etc.)
#   2) A time horizon has been reached (entity$last_time >= ctx$time_horizon)
#
# Notes
#   - Keep stop() deterministic given the realized event and entity state.
#   - Decide whether your horizon is inclusive or exclusive and be consistent.
# ------------------------------------------------------------------------------
stop_model <- function(entity, event, ctx) {
  
  # --------------------------------------------------------------------------
  # 1) Terminal event by event type
  #
  # If your model treats certain event types as terminal, you can stop immediately.
  # --------------------------------------------------------------------------
  # if (event$event_type %in% c("death", "terminal_event")) {
  #   return(TRUE)
  # }
  
  # --------------------------------------------------------------------------
  # 2) Terminal state variable
  #
  # Alternatively, stop if a state variable indicates terminal status.
  # This is useful when multiple event types map to a single terminal concept.
  # --------------------------------------------------------------------------
  # if (isTRUE(entity$state("dead"))) {
  #   return(TRUE)
  # }
  
  # --------------------------------------------------------------------------
  # 3) Time horizon
  #
  # Put the horizon in ctx (same time units as entity$last_time).
  # Example: ctx$time_horizon <- 10  # (years)
  # --------------------------------------------------------------------------
  if (!is.null(ctx$time_horizon)) {
    if (isTRUE(entity$last_time >= ctx$time_horizon)) {
      return(TRUE)
    }
  }
  
  FALSE
}
