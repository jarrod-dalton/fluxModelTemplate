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
  # Emit one observation row per event by default; trim fields as needed.
  snap <- entity$snapshot(vars = c(
    "route_zone", "battery_pct", "payload_kg",
    "dispatch_mode", "active_followup", "alive"
  ))

  data.frame(
    time = entity$last_time,
    event_type = as.character(event$event_type),
    process_id = if (!is.null(event$process_id)) as.character(event$process_id) else NA_character_,
    route_zone = as.character(snap$route_zone),
    battery_pct = as.numeric(snap$battery_pct),
    payload_kg = as.numeric(snap$payload_kg),
    dispatch_mode = as.character(snap$dispatch_mode),
    active_followup = as.logical(snap$active_followup),
    alive = as.logical(snap$alive),
    stringsAsFactors = FALSE
  )
}
