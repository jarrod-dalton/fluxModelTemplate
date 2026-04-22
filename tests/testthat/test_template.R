test_that("Template exports exist", {
  expect_true(is.function(model_schema))
  expect_true(is.function(model_bundle))
})

test_that("model_schema returns a default-compatible schema", {
  schema <- model_schema()
  expect_true(is.list(schema))
  expect_true("alive" %in% names(schema))
})

test_that("model_bundle exposes required hooks", {
  b <- model_bundle()
  expect_true(is.list(b))
  expect_true(is.function(b$propose_events))
  expect_true(is.function(b$transition))
  expect_true(is.function(b$stop))
  expect_true(is.function(b$observe))
  expect_true(is.function(b$init_entity))
})

test_that("minimal run path works without editing optional derived vars scaffold", {
  b <- model_bundle()

  # Minimal runnable overrides for required model logic.
  b$propose_events <- function(entity, ctx) {
    list(dispatch = list(
      time_next = entity$last_time + 1,
      event_type = "dispatch_check",
      process_id = "dispatch"
    ))
  }
  b$transition <- function(entity, event, ctx) NULL
  b$stop <- function(entity, event, ctx) TRUE

  prov <- list(load = function(model_spec, ...) b)
  eng <- fluxCore::Engine$new(provider = prov, model_spec = list(name = "default"))
  e <- fluxCore::new_entity(
    init = list(alive = TRUE),
    schema = model_schema(),
    entity_type = "agent",
    time0 = 0
  )

  expect_no_error({
    out <- eng$run(e, max_events = 5, ctx = list(time = list(unit = "hours")))
    expect_true(is.list(out))
    expect_true(nrow(out$events) >= 2L) # init + at least one realized event
  })
})
