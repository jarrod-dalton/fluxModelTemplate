# Optional extension: Composing bundles
#
# Some models are naturally modular (e.g., demographics module + disease module + treatment module).
# patientSimCore supports composing multiple ModelBundles into a single bundle.
#
# A common pattern:
#   b1 <- moduleA::model_bundle()
#   b2 <- moduleB::model_bundle()
#   b  <- patientSimCore::compose_bundles(list(b1, b2))
#
# The composed bundle should:
# - have a unified schema (or consistent schema + derived vars)
# - define transitions/events without conflicting event_type names
# - define a clear stopping rule (or combine stopping rules)
