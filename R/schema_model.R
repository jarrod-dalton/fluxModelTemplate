model_schema <- function() {
  schema <- patientSimCore::default_patient_schema()

  # TODO: mark required variables (recommended)
  # schema$age$required <- TRUE
  # schema$sex$required <- TRUE

  # TODO: add model variables and defaults
  # schema$my_var <- list(default = 0)

  # TODO: define blocks (panels) for vectorized updates
  # schema$a$blocks <- "panel1"
  # schema$b$blocks <- c("panel1", "panel2")

  schema
}
