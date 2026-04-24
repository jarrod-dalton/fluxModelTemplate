# ------------------------------------------------------------------------------
# model_schema()
#
# PURPOSE
#   Define the core state schema for your model.
#
# WHAT A "STATE SCHEMA" IS
#   A state schema is the contract for your model's core state variables:
#   - which variables exist
#   - what type each variable is
#   - default values
#   - coercion/validation rules
#   - optional block membership for grouped updates
#
# INPUTS
#   None.
#
# OUTPUT
#   A named list. Each entry defines one variable, and together they define
#   your full set of core state variables.
#
# ABOUT fluxCore::default_entity_schema()
#   This provides a minimal base schema from Core so every new model starts from
#   a valid foundation (for example, canonical fields like alive status).
#   You then add model-specific variables on top.
#
# ALIVE FIELD NOTE
#   `alive` is optional in newer flux workflows:
#   - If included in schema, it is used directly for lifecycle eligibility.
#   - If omitted, lifecycle can be derived from bundle$terminal_events.
#   - If both are omitted, lifecycle defaults to active while runs are defined.
#
# VARIABLE DEFINITION SHAPE
#   schema$var_name <- list(
#     type = "continuous",  # one of: binary/categorical/ordinal/continuous/count
#     default = 0,
#     coerce = as.numeric,
#     validate = function(x) ...,  # returns TRUE/FALSE
#     required = FALSE,            # if TRUE, must be present at initialization
#     blocks = NULL                # optional grouping label(s) for joint updates
#   )
#
# WHAT TO EDIT
#   1) Keep `schema <- fluxCore::default_entity_schema()`.
#   2) Add your variables below.
#   3) Use strict validation to catch invalid inputs early.
# ------------------------------------------------------------------------------
model_schema <- function() {
  schema <- fluxCore::default_entity_schema()

  # --------------------------------------------------------------------------
  # Worked example (urban food delivery): route context
  #
  # Replace/extend these variables to fit your domain model.
  # --------------------------------------------------------------------------
  schema$route_zone <- list(
    type = "categorical",
    levels = c("urban", "suburban", "rural"),
    default = "urban",
    coerce = as.character,
    validate = function(x) length(x) == 1L && x %in% c("urban", "suburban", "rural")
  )

  # --------------------------------------------------------------------------
  # Worked example (urban food delivery): grouped vehicle state
  #
  # battery_pct and payload_kg share block "vehicle_status" so they can be
  # updated together with update_block(...) inside transition_model().
  # --------------------------------------------------------------------------
  schema$battery_pct <- list(
    type = "continuous",
    default = 100,
    coerce = as.numeric,
    validate = function(x) length(x) == 1L && is.finite(x) && x >= 0 && x <= 100,
    blocks = "vehicle_status"
  )

  schema$payload_kg <- list(
    type = "continuous",
    default = 0,
    coerce = as.numeric,
    validate = function(x) length(x) == 1L && is.finite(x) && x >= 0,
    blocks = "vehicle_status"
  )

  # --------------------------------------------------------------------------
  # Worked example (urban food delivery): workflow mode
  # --------------------------------------------------------------------------
  schema$dispatch_mode <- list(
    type = "categorical",
    levels = c("idle", "assigned", "in_transit", "completed"),
    default = "idle",
    coerce = as.character,
    validate = function(x) {
      length(x) == 1L && x %in% c("idle", "assigned", "in_transit", "completed")
    }
  )

  schema
}
