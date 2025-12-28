# ------------------------------------------------------------------------------
# 08_multi_model_composition.R  (OPTIONAL / ADVANCED)
# ------------------------------------------------------------------------------
#
# Use this script ONLY if you are composing multiple submodels that each govern
# different phases or episodes over the SAME canonical patient time axis.
#
# If you have a single disease model, stop here and stick with Scripts 01–07.
#
# This script introduces three concepts:
#   1) Namespaced state: state$ascvd$..., state$hospital$..., etc.
#   2) model scope: core$model_active indicates which model(s) are “in scope”.
#   3) explicit handoffs: events can flip scope and pass payload variables.
#
# Implementation note (how this maps to patientSimCore today):
#   patientSimCore stores state variables in a flat schema. If you return a
#   *namespaced* patch from transition(), patientSimCore flattens it using:
#     "<namespace>__<var>"
#   Example: list(ascvd=list(ldl=118)) -> updates variable "ascvd__ldl".
#   The special namespace "core" preferentially maps to unprefixed schema
#   variables (e.g., alive), and otherwise uses "core__<var>".

# ------------------------------------------------------------------------------
# 08.1 One canonical time axis, many model namespaces
# ------------------------------------------------------------------------------
#
# Core owns time monotonicity and “biological truth” (e.g., core$alive).
# Models own their variables inside a namespace to avoid collisions.
#
# Example snapshot shape (conceptual):
#
# list(
#   core = list(time=2.3, alive=TRUE, model_active=c(ascvd=TRUE, hospital=FALSE)),
#   ascvd = list(ldl=130, smoker=TRUE),
#   hospital = list(icu=FALSE, ldl_measured=NA_real_)
# )

# ------------------------------------------------------------------------------
# 08.2 The “two LDLs” pattern
# ------------------------------------------------------------------------------
#
# It is normal for multiple models to track LDL, but they usually mean different things:
#   - hospital$ldl_measured: a lab measurement during admission (timing + noise)
#   - ascvd$ldl: a latent chronic-risk state variable used for event hazards
#
# Do NOT force these to be the same variable in a flat state. Keep both, and only
# connect them via explicit events/payloads (see below).

# ------------------------------------------------------------------------------
# 08.3 State vs history (Patient already has history)
# ------------------------------------------------------------------------------
#
# The Patient class already records sparse history snapshots at event times.
# Use history for “what happened when”, and derived variables for windowed summaries.
#
# Recommended:
#   - store admission/discharge times implicitly via snapshots (events on the time axis)
#   - compute:
#       time_since_last_hosp(t) = t - last_hosp_time
#       n_hosp_12mo(t) = count(admissions in (t-365, t])
#
# Avoid maintaining drifting counters unless you truly need them for performance.

# ------------------------------------------------------------------------------
# 08.4 Scope is not life
# ------------------------------------------------------------------------------
#
# A model can go out of scope while the patient is still alive.
# core$alive answers: “biological truth”
# core$model_active answers: “is this model responsible for evolving state now?”

# ------------------------------------------------------------------------------
# 08.5 Explicit handoffs (admission/discharge)
# ------------------------------------------------------------------------------
#
# Admission event:
#   - flip hospital in scope
#   - optionally update ASCVD bookkeeping (e.g., last_hosp_time)
#
# patch <- list(
#   core = list(model_active = c(ascvd=TRUE, hospital=TRUE)),
#   hospital = list(admit_time = t, ldl_measured = NA_real_),
#   ascvd = list(last_hosp_time = t)
# )
#
# LDL measurement event during hospital:
#   patch <- list(hospital = list(ldl_measured = 110, ldl_measured_time = t))
#
# Discharge event:
#   - flip hospital out of scope
#   - OPTIONAL: pass LDL to ASCVD (explicit overwrite or smoothing)
#
# Overwrite:
# patch <- list(
#   core = list(model_active = c(ascvd=TRUE, hospital=FALSE)),
#   ascvd = list(ldl = hospital$ldl_measured),
#   hospital = list(discharge_time = t)
# )
#
# Smoothing (advanced):
# patch <- list(
#   core = list(model_active = c(ascvd=TRUE, hospital=FALSE)),
#   ascvd = list(ldl = 0.7*ascvd$ldl + 0.3*hospital$ldl_measured)
# )

# ------------------------------------------------------------------------------
# 08.6 Forecast semantics (avoid lying)
# ------------------------------------------------------------------------------
#
# Forecast summaries should never manufacture death-only survival beyond the last
# time core$alive is defined. If simulation stops (hard stop), values beyond are NA.
#
# Eligibility presets you may use in your model-specific wrappers:
#   - alive (overall survival)
#   - alive & in_scope('ascvd') (ASCVD hazards/state while ASCVD active)
#   - alive & in_scope('hospital') (hospital summaries during admission)
#
# See docs/MULTI_MODEL_COMPOSITION.md for a worked toy example.
