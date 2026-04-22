# ------------------------------------------------------------------------------
# transition_model(entity, event, ctx)
#
# PURPOSE
#   Apply state updates for a realized event.
#
# INPUTS
#   entity: current entity object.
#   event: realized event (typically includes event_type, process_id, time_next).
#   ctx: run context list.
#
# OUTPUT
#   Either:
#   - named list of state updates, or
#   - NULL (no state change for this event).
#
# HOW THIS FITS THE EVENT MODEL
#   If event j+1 is realized at time t_{j+1}, this function maps:
#     state at j  ->  state at j+1
#   based on event_type and current context.
#
# WHAT TO EDIT
#   1) Branch on event$event_type.
#   2) Compute updates (possibly with update_block/combine_updates).
#   3) Return named update list (or NULL).
# ------------------------------------------------------------------------------
transition_model <- function(entity, event, ctx) {
  # Worked example (commented):
  # if (identical(event$event_type, "dispatch_check")) {
  #   # Stochastic assignment load (kg), e.g., from a lognormal model.
  #   new_payload <- as.numeric(rlnorm(1, meanlog = log(3), sdlog = 0.35))
  #   return(list(dispatch_mode = "assigned", payload_kg = new_payload))
  # }
  # if (identical(event$event_type, "delivery_completed")) {
  #   # Example of multi-variable update with stochastic decrement.
  #   payload_now <- entity$state("payload_kg")
  #   battery_now <- entity$state("battery_pct")
  #   delivered_kg <- as.numeric(rlnorm(1, meanlog = log(1.2), sdlog = 0.45))
  #   battery_drop <- as.numeric(rexp(1, rate = 1 / 6))
  #   payload_next <- max(0, payload_now - delivered_kg)
  #   battery_next <- max(0, battery_now - battery_drop)
  #   return(list(
  #     dispatch_mode = "completed",
  #     payload_kg = payload_next,
  #     battery_pct = battery_next
  #   ))
  # }

  # Default scaffold behavior: no state changes.
  NULL
}
