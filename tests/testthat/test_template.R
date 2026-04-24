test_that("Template exports exist", {
  expect_true(is.function(model_schema))
  expect_true(is.function(model_bundle))
  expect_true(is.function(model_time_spec))
})

test_that("model_time_spec reads canonical JSON config", {
  ts <- model_time_spec()
  expect_true(inherits(ts, "time_spec"))
  expect_identical(ts$unit, "hours")
})

test_that("model_schema returns a default-compatible schema with worked-example vars", {
  schema <- model_schema()
  expect_true(is.list(schema))
  expect_true("alive" %in% names(schema))
  expect_true(all(c("route_zone", "battery_pct", "payload_kg", "dispatch_mode") %in% names(schema)))
})

test_that("model_bundle exposes required hooks and optional refresh_rules remains optional", {
  b <- model_bundle()
  expect_true(is.list(b))
  expect_true(inherits(b$time_spec, "time_spec"))
  expect_true(is.function(b$propose_events))
  expect_true(is.function(b$transition))
  expect_true(is.function(b$stop))
  expect_true(is.function(b$observe))
  expect_true(is.function(b$init_entity))
  expect_null(b$refresh_rules)
  expect_true(all(c("dispatch_check", "delivery_completed", "end_shift") %in% b$event_catalog))
  expect_identical(b$terminal_events, "end_shift")
})

test_that("propose_events_model returns named process proposals and supports process_ids filtering", {
  e <- fluxCore::new_entity(
    init = list(),
    schema = model_schema(),
    entity_type = "agent",
    time0 = 0
  )
  out_all <- propose_events_model(e, ctx = list(params = list(shift_end_time = 2)))
  expect_true(is.list(out_all))
  expect_true(all(c("dispatch", "delivery", "end_shift") %in% names(out_all)))
  expect_true(all(vapply(out_all, function(x) is.list(x) && is.numeric(x$time_next), logical(1))))

  out_subset <- propose_events_model(
    e,
    ctx = list(params = list(shift_end_time = 2)),
    process_ids = c("dispatch", "end_shift")
  )
  expect_setequal(names(out_subset), c("dispatch", "end_shift"))
})

test_that("default bundle run path works end-to-end without overrides", {
  set.seed(42)
  b <- model_bundle(params = list(shift_end_time = 2))
  prov <- list(load = function(model_spec, ...) b)
  eng <- fluxCore::Engine$new(provider = prov, model_spec = list(name = "default"))
  e <- fluxCore::new_entity(
    init = list(),
    schema = model_schema(),
    entity_type = "agent",
    time0 = 0
  )

  out <- eng$run(e, max_events = 100, return_observations = TRUE)
  expect_true(is.list(out))
  expect_true(nrow(out$events) >= 2L) # init + at least one realized event
  expect_true(any(out$events$event_type == "end_shift"))
  expect_identical(tail(out$events$event_type, 1), "end_shift")

  expect_true(is.data.frame(out$observations))
  expect_true(all(c(
    "time", "event_type", "process_id", "route_zone",
    "battery_pct", "payload_kg", "dispatch_mode",
    "active_followup", "alive"
  ) %in% names(out$observations)))

  snap <- out$entity$snapshot()
  expect_true(all(c(
    "low_battery", "deliveries_completed",
    "deliveries_last_4h", "last_route_zone"
  ) %in% names(snap)))
})

test_that("transition_model and stop_model handle end_shift terminal behavior", {
  e <- fluxCore::new_entity(
    init = list(),
    schema = model_schema(),
    entity_type = "agent",
    time0 = 0
  )

  ch <- transition_model(e, event = list(event_type = "end_shift"), ctx = list(params = list()))
  expect_true(is.list(ch))
  expect_identical(ch$active_followup, FALSE)
  expect_identical(ch$dispatch_mode, "idle")

  e$update(time = 1, event_type = "end_shift", changes = ch)
  expect_true(stop_model(e, event = list(event_type = "end_shift"), ctx = list()))
})
