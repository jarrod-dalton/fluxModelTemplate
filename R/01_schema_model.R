# ------------------------------------------------------------------------------
# model_schema()
#
# Define your model's *core state* schema for patientSimCore.
#
# The schema is a named list: variable name -> variable descriptor.
# Each variable descriptor must include:
#   - default  : scalar default value
#
# Optional fields recognized by patientSimCore:
#   - coerce   : function(x) -> scalar
#   - validate : function(x) -> TRUE/FALSE
#   - required : TRUE/FALSE (require value in init at patient creation)
#   - blocks   : character vector of panel membership (for update_block)
#
# Full spec: patientSimCore/inst/SCHEMA_SPEC.md
# ------------------------------------------------------------------------------
model_schema <- function() {
  schema <- patientSimCore::default_patient_schema()
  
  # --------------------------------------------------------------------------
  # EXAMPLE: Required demographics
  #
  # A common pattern is to require age/sex at patient creation so models
  # fail fast and assumptions remain explicit.
  # --------------------------------------------------------------------------
  schema$age <- list(
    type     = "continuous",
    default  = NA_real_,
    coerce   = as.numeric,
    validate = function(x) length(x) == 1L && !is.na(x) && is.finite(x) && x >= 0,
    required = TRUE
  )
  
  schema$sex <- list(
    type     = "categorical",
    levels   = c("F", "M"),
    default  = NA_character_,
    coerce   = as.character,
    validate = function(x) length(x) == 1L && x %in% c("F", "M"),
    required = TRUE
  )
  
  # --------------------------------------------------------------------------
  # EXAMPLE: A correlated measurement panel (block)
  #
  # Blocks are used to validate and package multi-variable updates.
  # Variables can belong to multiple blocks (many-to-many).
  # --------------------------------------------------------------------------
  schema$sbp <- list(
    type     = "continuous",
    default  = 120,
    coerce   = as.numeric,
    validate = function(x) length(x) == 1L && is.finite(x) && x > 50 && x < 300,
    blocks   = "bp"
  )
  
  schema$dbp <- list(
    type     = "continuous",
    default  = 80,
    coerce   = as.numeric,
    validate = function(x) length(x) == 1L && is.finite(x) && x > 30 && x < 200,
    blocks   = "bp"
  )
  
  # Later, your transition can update BP atomically via:
  #   upd_bp <- patientSimCore::update_block(patient, "bp", list(sbp=125, dbp=82))
  #   return(patientSimCore::combine_updates(other_updates, upd_bp))
  
  # --------------------------------------------------------------------------
  # EXAMPLE: Ordinal treatment intensity (integer cap)
  # --------------------------------------------------------------------------
  schema$n_antihypertensives <- list(
    type     = "count",
    default  = 0L,
    coerce   = as.integer,
    validate = function(x) length(x) == 1L && !is.na(x) && x >= 0L && x <= 4L,
    blocks   = "tx_htn"
  )
  
  # --------------------------------------------------------------------------
  # EXAMPLE: Ordered category stored as character (simple)
  # If you later want an ordered factor, implement that in coerce().
  # --------------------------------------------------------------------------
  schema$statin_intensity <- list(
    type     = "ordinal",
    levels   = c("none", "moderate", "high"),
    default  = "none",
    coerce   = as.character,
    validate = function(x) length(x) == 1L && x %in% c("none", "moderate", "high"),
    blocks   = "tx_lipid"
  )
  
  # --------------------------------------------------------------------------
  # EXAMPLE: Operational ordering state (encounter-driven labs)
  # --------------------------------------------------------------------------
  schema$bmp_order_time <- list(
    type     = "continuous",
    default  = NA_real_,
    coerce   = as.numeric,
    validate = function(x) length(x) == 1L && (is.na(x) || is.finite(x))
  )
  
  # --------------------------------------------------------------------------
  # TODO: Add your model-specific variables below
  #
  # schema$my_var <- list(
  #   default  = 0,
  #   coerce   = as.numeric,
  #   validate = function(x) length(x) == 1L && is.finite(x)
  # )
  # --------------------------------------------------------------------------
  
  schema
}
