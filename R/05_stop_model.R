# ------------------------------------------------------------------------------
# stop_model(entity, event, param_ctx = NULL)
#
# PURPOSE
#   Decide whether simulation stops after the current event.
#
# INPUTS
#   entity: current entity object.
#   event: realized event.
#   param_ctx: parameter context (optional).
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
stop_model <- function(entity, event, param_ctx = NULL) {
  if (identical(event$event_type, "end_shift")) return(TRUE)

  if (is.list(param_ctx) && !is.null(param_ctx$params$time_horizon)) {
    horizon <- suppressWarnings(as.numeric(param_ctx$params$time_horizon))
    if (length(horizon) == 1L && is.finite(horizon) && entity$last_time >= horizon) return(TRUE)
  }

  FALSE
}
