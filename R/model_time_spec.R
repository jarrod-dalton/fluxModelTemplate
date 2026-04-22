# ------------------------------------------------------------------------------
# model_time_spec()
#
# Canonical model time declaration loaded from inst/model_config/time_spec.json.
# This keeps time metadata in a language-agnostic file for R/Python interoperability
# while still returning a fluxCore runtime object.
# ------------------------------------------------------------------------------
model_time_spec <- function() {
  pkg <- utils::packageName()
  path <- system.file("model_config", "time_spec.json", package = pkg)

  # Fallback for source-tree usage when the package is not installed.
  if (!nzchar(path) || !file.exists(path)) {
    fallback <- file.path("inst", "model_config", "time_spec.json")
    if (file.exists(fallback)) path <- fallback
  }

  if (!nzchar(path) || !file.exists(path)) {
    stop(
      "Could not locate model time spec JSON at inst/model_config/time_spec.json.",
      call. = FALSE
    )
  }

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Package 'jsonlite' is required to read model time spec JSON.", call. = FALSE)
  }

  cfg <- jsonlite::fromJSON(path, simplifyVector = TRUE)
  if (!is.list(cfg) || is.null(cfg$unit) || !is.character(cfg$unit) || length(cfg$unit) != 1L) {
    stop("time_spec.json must contain a scalar string field `unit`.", call. = FALSE)
  }

  origin <- cfg$origin
  if (is.null(origin)) origin <- NULL
  zone <- cfg$zone
  if (is.null(zone)) zone <- "UTC"

  fluxCore::time_spec(
    unit = cfg$unit,
    origin = origin,
    zone = zone
  )
}
