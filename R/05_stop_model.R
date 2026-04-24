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
#   Keep stop_model() aligned with model_bundle()$terminal_events when possible.
# ------------------------------------------------------------------------------
stop_model <- function(entity, event, ctx) {
  if (identical(event$event_type, "end_shift")) return(TRUE)

  active_followup <- tryCatch(entity$state("active_followup"), error = function(e) TRUE)
  if (isFALSE(active_followup)) return(TRUE)

  if (is.list(ctx) && !is.null(ctx$time_horizon)) {
    horizon <- suppressWarnings(as.numeric(ctx$time_horizon))
    if (length(horizon) == 1L && is.finite(horizon) && entity$last_time >= horizon) return(TRUE)
  }

  FALSE
}
