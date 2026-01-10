# ------------------------------------------------------------------------------
# propose_events_model(patient, ctx)
#
# Purpose
#   Propose candidate future events across multiple processes that share one
#   global time axis (same units as patient$last_time).
#
# Inputs
#   - patient: Patient R6 object
#   - ctx: list-like context (time unit, horizons, parameters, etc.)
#
# Output
#   A named list of event candidates, one per process. Each candidate is a list
#   that must include:
#     - time_next  (numeric scalar)
#     - event_type (character scalar)
#     - process_id (character scalar)
#
#   You may add additional metadata fields to the event object; Engine will pass
#   the entire event to transition().
#
# Example
#   list(
#     clinic = list(time_next=t1, event_type="clinic_visit", process_id="clinic"),
#     labs   = list(time_next=t2, event_type="lab_draw",     process_id="labs")
#   )
#
# Notes / Patterns
#   - Return NULL for a process if no event is currently pending.
#   - "Encounter-driven" labs pattern:
#       * transition() sets an order time in state (e.g., bmp_order_time)
#       * propose_events() only proposes a lab draw if order time is not NA
#       * transition() clears the order time when the draw occurs
#   - You can choose to avoid proposing events beyond a horizon (ctx$time_horizon)
#     to reduce work/noise.
#   - Keep this function lightweight; heavy computation belongs in transition().
# ------------------------------------------------------------------------------
propose_events_model <- function(patient, ctx) {
  # Recommended: document your model's time unit in ctx$time$unit.
  # Example: ctx$time$unit <- "years" or "months" or "days"
  #
  # If you use a time horizon, put it in ctx (same units as patient$last_time):
  #   ctx$time_horizon
  
  # --------------------------------------------------------------------------
  # TODO: Define your processes (each process proposes its next event)
  #
  # Common process archetypes:
  #   - clinic scheduling process
  #   - lab draw processes (only if ordered)
  #   - disease progression process
  #   - terminal event process
  # --------------------------------------------------------------------------
  
  # Example placeholder: return an empty set of candidates (Engine will stop)
  # In a real model you would propose at least one process, usually "clinic".
  list()
  
  # Skeleton you can adapt:
  #
  # t_now <- patient$last_time
  #
  # ev_clinic <- list(
  #   time_next  = t_now + rexp(1, rate = 2),   # <-- replace with your logic
  #   event_type = "clinic_visit",
  #   process_id = "clinic"
  # )
  #
  # # Encounter-driven lab: only propose if ordered
  # bmp_order_time <- patient$state("bmp_order_time")  # may be NA
  # ev_bmp <- NULL
  # if (!is.na(bmp_order_time)) {
  #   ev_bmp <- list(
  #     time_next  = bmp_order_time,
  #     event_type = "bmp_draw",
  #     process_id = "bmp"
  #   )
  # }
  #
  # # Terminal event: propose always (or only if not already terminal)
  # ev_term <- list(
  #   time_next  = t_now + rexp(1, rate = 0.05),
  #   event_type = "terminal_event",
  #   process_id = "terminal"
  # )
  #
  # candidates <- list(clinic = ev_clinic, bmp = ev_bmp, terminal = ev_term)
  #
  # # Optional: horizon trimming
  # if (!is.null(ctx$time_horizon)) {
  #   candidates <- lapply(candidates, function(ev) {
  #     if (is.null(ev)) return(NULL)
  #     if (isTRUE(ev$time_next > ctx$time_horizon)) return(NULL)
  #     ev
  #   })
  # }
  #
  # candidates
}
