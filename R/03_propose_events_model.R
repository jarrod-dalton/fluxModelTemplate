# ------------------------------------------------------------------------------
# propose_events_model(entity, ctx)
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
#     - process_id: process label (used to distinguish event streams)
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
propose_events_model <- function(entity, ctx) {
  # Worked example (commented, stochastic):
  # t_now <- entity$last_time
  #
  # # Example: dispatch intensity from a GLM-like linear predictor
  # payload <- entity$state("payload_kg")
  # battery <- entity$state("battery_pct")
  # lp_dispatch <- -0.8 + 0.03 * payload - 0.01 * battery
  # rate_dispatch <- exp(lp_dispatch)              # must be > 0
  # wait_dispatch <- rexp(1, rate = rate_dispatch)
  #
  # # Example: delivery completion intensity (could be process-specific)
  # lp_delivery <- -0.3 + 0.015 * battery
  # rate_delivery <- exp(lp_delivery)
  # wait_delivery <- rexp(1, rate = rate_delivery)
  #
  # ev_dispatch <- list(
  #   time_next = t_now + wait_dispatch,
  #   event_type = "dispatch_check",
  #   process_id = "dispatch"
  # )
  # ev_delivery <- list(
  #   time_next = t_now + wait_delivery,
  #   event_type = "delivery_completed",
  #   process_id = "delivery"
  # )
  # list(dispatch = ev_dispatch, delivery = ev_delivery)

  # Default scaffold behavior: no candidates.
  list()
}
