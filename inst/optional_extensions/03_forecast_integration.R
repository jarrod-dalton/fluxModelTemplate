# Optional extension: Forecast integration (patientSimForecast)
#
# This script demonstrates the intended *consumer* workflow with patientSimForecast:
#   - use forecast(ctx=...) with either a single ctx list OR a list of ctx lists (one per param set)
#   - compute posterior-predictive summaries by pooling simulation runs across parameter sets
#   - for state summaries, condition on "alive" and any model-defined follow-up logic
#
# NOTE: This template package is intentionally not a full disease model. For a fully worked example,
# see patientSimASCVD/inst/examples which demonstrates:
#   - initializing a "real" patient from a 1-row data.frame (or named list)
#   - simulating 100 trajectories for that patient
#   - summarizing via forecast(return='summary_stats', summary_stats='both', ...) (or equivalent helpers)
#
# --- Sketch (pseudo-code) ---
# engine <- patientSimCore::Engine$new(bundle = patientSimModelTemplate::model_bundle())
# patient_df <- data.frame(...)   # 1-row input
# pat <- patientSimCore::new_patient(schema = patientSimModelTemplate::model_schema(), data = patient_df)
#
# # Single ctx:
# ctx <- list(params = list(...))
# res <- patientSimForecast::forecast(
#   engine = engine, patients = pat, times = c(0, 1, 5),
#   S = 100, param_sets = list(ctx$params),
#   ctx = ctx,
#   backend = "none",
#   return = "summary_stats",
#   summary_stats = "both",
#   summary_spec = list(
#     risk = list(event_type = c("death"), start_time = 0),
#     state = list(vars = c("age", "alive"))
#   )
# )
#
# # Multiple parameter sets via list-of-ctx (equal-weight posterior pooling):
# ctx_list <- list(
#   list(params = list(...)),
#   list(params = list(...))
# )
# res2 <- patientSimForecast::forecast(
#   engine = engine, patients = pat, times = c(0, 1, 5),
#   S = 50, param_sets = lapply(ctx_list, `[[`, "params"),
#   ctx = ctx_list,
#   backend = "none",
#   return = "summary_stats",
#   summary_stats = "both",
#   summary_spec = list(
#     risk = list(event_type = c("death"), start_time = 0),
#     state = list(vars = c("age", "alive"))
#   )
# )
