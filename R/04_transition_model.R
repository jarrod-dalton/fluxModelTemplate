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
  params <- if (is.list(ctx) && is.list(ctx$params)) ctx$params else list()

  param_num <- function(name, default) {
    x <- params[[name]]
    if (is.null(x) || length(x) != 1L) return(default)
    x <- suppressWarnings(as.numeric(x))
    if (!is.finite(x)) default else x
  }

  if (identical(event$event_type, "dispatch_check")) {
    route_levels <- c("urban", "suburban", "rural")
    route_probs <- params$route_zone_probs
    if (is.null(route_probs) || !is.numeric(route_probs) || length(route_probs) != length(route_levels)) {
      route_probs <- c(0.55, 0.30, 0.15)
    }
    route_probs <- pmax(route_probs, 0)
    if (sum(route_probs) <= 0) route_probs <- c(0.55, 0.30, 0.15)
    route_probs <- route_probs / sum(route_probs)

    payload_mean <- max(0.1, param_num("dispatch_payload_mean_kg", 3.0))
    payload_sdlog <- max(0.05, param_num("dispatch_payload_sdlog", 0.35))
    battery_drop_mean <- max(0.1, param_num("dispatch_battery_drop_mean", 2.5))

    s <- entity$as_list(c("battery_pct"))
    battery_now <- as.numeric(s$battery_pct)
    if (!is.finite(battery_now)) battery_now <- 100

    new_payload <- as.numeric(stats::rlnorm(1, meanlog = log(payload_mean), sdlog = payload_sdlog))
    battery_drop <- as.numeric(stats::rexp(1, rate = 1 / battery_drop_mean))
    battery_next <- max(0, min(100, battery_now - battery_drop))

    return(list(
      route_zone = sample(route_levels, size = 1, prob = route_probs),
      dispatch_mode = "assigned",
      payload_kg = new_payload,
      battery_pct = battery_next
    ))
  }

  if (identical(event$event_type, "delivery_completed")) {
    payload_sdlog <- max(0.05, param_num("delivery_payload_sdlog", 0.45))
    delivery_mean <- max(0.1, param_num("delivery_payload_mean_kg", 1.2))
    battery_drop_mean <- max(0.1, param_num("delivery_battery_drop_mean", 4.0))

    s <- entity$as_list(c("payload_kg", "battery_pct"))
    payload_now <- as.numeric(s$payload_kg)
    battery_now <- as.numeric(s$battery_pct)
    if (!is.finite(payload_now)) payload_now <- 0
    if (!is.finite(battery_now)) battery_now <- 100

    delivered_kg <- min(payload_now, as.numeric(stats::rlnorm(1, meanlog = log(delivery_mean), sdlog = payload_sdlog)))
    payload_next <- max(0, payload_now - delivered_kg)
    battery_drop <- as.numeric(stats::rexp(1, rate = 1 / battery_drop_mean))
    battery_next <- max(0, battery_now - battery_drop)
    mode_next <- if (payload_next > 0) "in_transit" else "completed"

    return(list(
      dispatch_mode = mode_next,
      payload_kg = payload_next,
      battery_pct = battery_next
    ))
  }

  if (identical(event$event_type, "end_shift")) {
    return(list(
      dispatch_mode = "idle"
    ))
  }

  NULL
}
