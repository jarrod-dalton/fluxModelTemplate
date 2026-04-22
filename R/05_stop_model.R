# ------------------------------------------------------------------------------
# stop_model(entity, event, ctx)
#
# PURPOSE
#   Decide whether simulation stops after the current event.
#
# INPUTS
#   entity: current entity object.
#   event: realized event.
#   ctx: run context list.
#
# OUTPUT
#   TRUE to stop, FALSE to continue.
#
# WHAT TO EDIT
#   Add explicit stopping rules, for example:
#   - terminal event encountered
#   - horizon reached (time-based stop)
# ------------------------------------------------------------------------------
stop_model <- function(entity, event, ctx) {
  # Worked example (commented):
  # if (identical(event$event_type, "end_shift")) return(TRUE)
  # if (!is.null(ctx$time_horizon) && entity$last_time >= ctx$time_horizon) return(TRUE)

  # Default scaffold behavior: keep running.
  FALSE
}
