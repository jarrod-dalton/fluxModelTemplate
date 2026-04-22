# ------------------------------------------------------------------------------
# observe_model(entity, event, ctx)
#
# PURPOSE
#   Optionally emit one row-like output after an event is processed.
#
# INPUTS
#   entity: current entity object.
#   event: realized event.
#   ctx: run context list.
#
# OUTPUT
#   Either:
#   - a single row-like object (named list or 1-row data.frame), or
#   - NULL (emit nothing).
#
# WHAT TO EDIT
#   1) Decide which events produce observations.
#   2) Build one row using state/snapshot/event fields.
# ------------------------------------------------------------------------------
observe_model <- function(entity, event, ctx) {
  # Worked example (commented):
  # if (identical(event$event_type, "delivery_completed")) {
  #   snap <- entity$snapshot()
  #   return(list(
  #     time = entity$last_time,
  #     event_type = event$event_type,
  #     payload_kg = snap$payload_kg,
  #     dispatch_mode = snap$dispatch_mode
  #   ))
  # }

  # Default scaffold behavior: emit nothing.
  NULL
}
