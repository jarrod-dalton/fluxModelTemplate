# docs/examples/08_multi_model_toy.R
#
# This is a toy sketch showing how to think about two models (hospital + ascvd)
# sharing a canonical patient time axis while owning separate state namespaces.
#
# It is intentionally light on implementation details: model packages should
# remain thin and declarative; Core owns execution mechanics.

# PSEUDO-CODE / SKETCH (not executable as-is)

t_admit <- 2.3
t_ldl   <- 2.6
t_dis   <- 3.2

# At baseline:
# core$model_active = c(ascvd=TRUE, hospital=FALSE)
# ascvd$ldl = 130
# hospital$ldl_measured = NA

# Admission event: hospital enters scope; ascvd updates bookkeeping.
patch_admit <- list(
  core = list(model_active = c(ascvd=TRUE, hospital=TRUE)),
  hospital = list(admit_time = t_admit, ldl_measured = NA_real_),
  ascvd = list(last_hosp_time = t_admit)
)

# LDL measurement during admission: update hospital namespace only.
patch_ldl <- list(
  hospital = list(ldl_measured = 110, ldl_measured_time = t_ldl)
)

# Discharge handoff: hospital exits scope; OPTIONAL assimilation into ascvd$ldl.
patch_discharge_overwrite <- list(
  core = list(model_active = c(ascvd=TRUE, hospital=FALSE)),
  hospital = list(discharge_time = t_dis),
  ascvd = list(ldl = 110)  # optional overwrite
)

patch_discharge_smooth <- list(
  core = list(model_active = c(ascvd=TRUE, hospital=FALSE)),
  hospital = list(discharge_time = t_dis),
  ascvd = list(ldl = 0.7*130 + 0.3*110)  # optional smoothing
)

# Derived variables should generally be computed from history snapshots:
# time_since_last_hosp(t) = t - last_hosp_time
# n_hosp_12mo(t) = count(admissions in (t-365, t])
