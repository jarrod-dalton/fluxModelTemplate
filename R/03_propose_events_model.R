# ------------------------------------------------------------------------------
# propose_events_model(entity, ctx, process_ids = NULL, current_proposals = NULL)
#
# PURPOSE
#   Propose candidate future events for the current state.
#
# INPUTS
#   entity: current entity object (for example entity$last_time, entity$state(...)).
#   ctx: run context list (optional settings/parameters/time controls).
#
# OUTPUT
#   Named list of candidate event objects.
#
#   Each candidate should contain at least:
#     - time_next: numeric event time t_next
#     - event_type: string label handled by transition/stop/observe logic
#
#   IMPORTANT CONTRACT
#     - The returned list itself is keyed by process_id (names(out)).
#     - Each list name must be non-empty and unique.
#     - event_type labels should be declared in model_bundle()$event_catalog.
#
# EVENT INDEX AND TIME
#   This function proposes candidates for the *next* event index (j + 1), but
#   does so in continuous/irregular time by setting time_next values.
#
# WHAT TO EDIT
#   1) Add one candidate block per process.
#   2) Build candidates from current state/context.
#   3) Return named list of candidates.
#
# STOCHASTIC TIMING NOTE
#   In most models, event times should be stochastic (not fixed offsets).
#   A common pattern is:
#     waiting_time ~ rexp(rate = lambda(state, params))
#   where lambda can come from a model-based hazard/rate (for example a GLM-like
#   predictor mapped through exp()).
# ------------------------------------------------------------------------------
propose_events_model <- function(entity, ctx, process_ids = NULL, current_proposals = NULL) {
  params <- if (is.list(ctx) && is.list(ctx$params)) ctx$params else list()

  param_num <- function(name, default) {
    x <- params[[name]]
    if (is.null(x) || length(x) != 1L) return(default)
    x <- suppressWarnings(as.numeric(x))
    if (!is.finite(x)) default else x
  }

  t_now <- entity$last_time
  s <- entity$as_list(c("dispatch_mode", "payload_kg", "battery_pct"))

  mode <- as.character(s$dispatch_mode)
  payload <- as.numeric(s$payload_kg)
  battery <- as.numeric(s$battery_pct)
  if (!is.finite(payload)) payload <- 0
  if (!is.finite(battery)) battery <- 100

  dispatch_base <- param_num("dispatch_rate_base", 0.7)
  delivery_base <- param_num("delivery_rate_base", 1.0)
  dispatch_idle_multiplier <- param_num("dispatch_idle_multiplier", 1.2)
  delivery_payload_scale <- param_num("delivery_payload_scale", 0.15)
  battery_multiplier <- max(0.1, min(1.5, battery / 100))

  dispatch_rate <- dispatch_base * if (mode %in% c("idle", "completed")) dispatch_idle_multiplier else 0.7
  delivery_rate <- delivery_base * (1 + delivery_payload_scale * payload) * battery_multiplier
  if (payload <= 0 && mode %in% c("idle", "completed")) delivery_rate <- delivery_base * 0.1

  dispatch_rate <- max(1e-6, dispatch_rate)
  delivery_rate <- max(1e-6, delivery_rate)

  wait_dispatch <- stats::rexp(1, rate = dispatch_rate)
  wait_delivery <- stats::rexp(1, rate = delivery_rate)

  shift_start <- entity$events$time[[1]]
  shift_length_hours <- param_num("shift_length_hours", 8)
  shift_end_time <- param_num("shift_end_time", shift_start + shift_length_hours)
  if (shift_end_time <= t_now) shift_end_time <- t_now + 1e-6

  out <- list(
    dispatch = list(
      time_next = t_now + wait_dispatch,
      event_type = "dispatch_check"
    ),
    delivery = list(
      time_next = t_now + wait_delivery,
      event_type = "delivery_completed"
    ),
    end_shift = list(
      time_next = shift_end_time,
      event_type = "end_shift"
    )
  )

  if (is.null(process_ids)) return(out)
  process_ids <- unique(as.character(process_ids))
  out[intersect(process_ids, names(out))]
}
