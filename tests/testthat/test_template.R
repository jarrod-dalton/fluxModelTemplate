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
