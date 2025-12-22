model_bundle <- function(params = list()) {
  list(
    propose_events = propose_events_model,
    transition     = transition_model,
    stop           = stop_model,
    observe        = observe_model
  )
}
