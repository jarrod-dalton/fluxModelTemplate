# Optional extension: Bundle sources (a.k.a. "providers")
#
# In some clinical/HSR contexts, "provider" is a loaded term (clinician/provider).
# In the patientSim ecosystem, these are *code-level* mechanisms for loading ModelBundles.
#
# The core package currently implements several source types (names may vary):
# - Package source: load a ModelBundle from an installed R package
# - File source:    load a ModelBundle from an R file on disk
# - (Optional) registry / remote sources (e.g., MLflow)
#
# The key idea:
#   A disease model package stays thin and declarative: it exports (at minimum)
#   a function returning a ModelBundle, and the engine loads that bundle through
#   a chosen source mechanism.
#
# See patientSimCore documentation for the concrete source class names and constructors.
