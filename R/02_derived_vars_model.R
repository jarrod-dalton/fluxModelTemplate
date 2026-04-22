# ------------------------------------------------------------------------------
# derived_vars_model(params = list())
#
# PURPOSE
#   Define optional derived variables evaluated at snapshot time.
#
# STATE VS DERIVED (important)
#   - Core state variables are mutated by transition_model().
#   - Derived variables are computed views of state/history. They do NOT mutate
#     state and should not be treated as canonical state variables.
#
# INPUTS
#   params: optional model-level parameter list.
#
# OUTPUT
#   Named list of functions. Each function must have signature:
#     f(entity, j, t)
#   where:
#     - j: event index at the evaluation point
#     - t: time coordinate at the evaluation point
#
# HOW j AND t ARE PASSED IN fluxCore
#   - snapshot(): j = entity$last_j, t = entity$last_time
#   - snapshot_at(j0): j = j0, t = event time at j0
#   - snapshot_at_time(t_query): j = latest event index with event_time <= t_query,
#     and t = t_query
#   This supports irregular event timing while still anchoring each derived value
#   to a specific event index/time evaluation point.
#
# WHAT TO EDIT
#   1) Add one function per derived variable.
#   2) Use clear names matching the returned list names.
#   3) Return list(name = function, ...).
# ------------------------------------------------------------------------------
derived_vars_model <- function(params = list()) {
  # --------------------------------------------------------------------------
  # Worked example: low battery flag from current state
  # --------------------------------------------------------------------------
  # low_battery <- function(entity, j, t) {
  #   cutoff <- if (!is.null(params$low_battery_cutoff)) params$low_battery_cutoff else 20
  #   b <- entity$state("battery_pct")
  #   if (is.null(b) || is.na(b)) return(NA)
  #   b < cutoff
  # }

  # --------------------------------------------------------------------------
  # Worked example: count deliveries observed by event index/time
  #
  # This example is intentionally simple and assumes event log has columns such
  # as event_type and time. Adapt to your event log schema.
  # --------------------------------------------------------------------------
  # deliveries_completed <- function(entity, j, t) {
  #   ev <- entity$events
  #   if (is.null(ev) || nrow(ev) == 0L) return(0L)
  #   if (!all(c("event_type", "time") %in% names(ev))) return(0L)
  #   sum(ev$event_type == "delivery_completed" & ev$time <= t, na.rm = TRUE)
  # }

  # --------------------------------------------------------------------------
  # Worked example: deliveries in the last 4 hours
  #
  # Assumes model time unit is "hours".
  # deliveries_last_4h returns count of delivery_completed events in (t - 4, t].
  #
  # Why filter on BOTH ev$j <= j and ev$time <= t?
  # - ev$time <= t enforces the time window.
  # - ev$j <= j enforces event-order consistency when multiple events share
  #   the same timestamp. Without the j filter, an event at the same time but
  #   with later index could leak into a snapshot anchored at earlier j.
  # --------------------------------------------------------------------------
  # deliveries_last_4h <- function(entity, j, t) {
  #   ev <- entity$events
  #   if (is.null(ev) || nrow(ev) == 0L) return(0L)
  #   if (!all(c("j", "time", "event_type") %in% names(ev))) return(0L)
  #
  #   in_window <- ev$event_type == "delivery_completed" &
  #     ev$j <= j &
  #     ev$time > (t - 4) &
  #     ev$time <= t
  #
  #   as.integer(sum(in_window, na.rm = TRUE))
  # }

  # --------------------------------------------------------------------------
  # Worked example: most recent route zone by event index (j-based)
  #
  # This example uses j directly (not a time window) and returns the route_zone
  # value as of event index j.
  # --------------------------------------------------------------------------
  # last_route_zone <- function(entity, j, t) {
  #   h <- entity$hist$route_zone
  #   if (is.null(h) || length(h$j) == 0L) return(NA_character_)
  #   idx <- findInterval(j, h$j)
  #   if (idx <= 0L) return(NA_character_)
  #   as.character(h$v[[idx]])
  # }

  # Return empty list until you add derived variables.
  list()
}
