test_that("Template exports exist", {
  expect_true(is.function(model_schema))
  expect_true(is.function(model_bundle))
  b <- model_bundle()
  expect_true(is.list(b))
  expect_true(is.function(b$propose_events))
  expect_true(is.function(b$transition))
  expect_true(is.function(b$stop))
})
