# ------------------------------------------------------------------------------
# transition_model(entity, event, ctx)
#
# Purpose
#   Apply the state transition associated with a realized event.
#
# Inputs
#   - entity: Entity R6 object
#       * entity$last_time            current simulation time
#       * entity$state(name)     read a core state variable
#       * entity$snapshot()      read core + derived variables (evaluated "now")
#   - event: list-like event chosen by Engine
#       * event$time_next
#       * event$event_type
#       * event$process_id
#       * any additional metadata you attached in propose_events()
#   - ctx: list-like context (time unit, parameters, horizons, etc.)
#
# Output
#   - A named *list* of scalar state updates (mixed types allowed), OR
#   - NULL to indicate "no state changes" for this event
#
# Design rules
#   - State changes occur ONLY via the returned list.
#   - Prefer explicit named updates; never rely on ordering.
#   - If multiple correlated variables change together, update them atomically
#     using update_block() + combine_updates().
#   - Returning NULL is valid and common (e.g., no-show events).
# ------------------------------------------------------------------------------
transition_model <- function(entity, event, ctx) {
  
  # --------------------------------------------------------------------------
  # Recommended pattern: branch on event type
  # --------------------------------------------------------------------------
  et <- event$event_type
  
  # --------------------------------------------------------------------------
  # Example: clinic visit
  # --------------------------------------------------------------------------
  if (et == "clinic_visit") {
    
    # ---- No-show pattern ----------------------------------------------------
    # If the entity does not attend, return NULL.
    # The event is still recorded in the event log.
    #
    # p_no_show <- 0.1
    # if (runif(1) < p_no_show) {
    #   return(NULL)
    # }
    
    # ---- Read current state -------------------------------------------------
    # sbp <- entity$state("sbp")
    # dbp <- entity$state("dbp")
    # age <- entity$state("age")
    
    # ---- Update age explicitly (if desired) --------------------------------
    # Decide whether age advances with time in your model.
    #
    # dt <- event$time_next - entity$last_time
    # upd_age <- list(age = age + dt)
    
    # ---- Vectorized panel update example (BP) -------------------------------
    # Suppose a joint BP model predicts SBP/DBP together.
    #
    # bp_pred <- list(sbp = 128, dbp = 82)   # <-- replace with your model
    #
    # upd_bp <- fluxCore::update_block(
    #   entity,
    #   block       = "bp",
    #   values      = bp_pred,
    #   require_all = TRUE,        # require all vars in block
    #   unknown     = "error"      # or "drop" if partial outputs are allowed
    # )
    
    # ---- Treatment decision example -----------------------------------------
    # n_tx <- entity$state("n_antihypertensives")
    #
    # if (bp_pred$sbp > 130 || bp_pred$dbp > 80) {
    #   n_tx_new <- min(n_tx + 1L, 4L)
    # } else {
    #   n_tx_new <- n_tx
    # }
    #
    # upd_tx <- list(n_antihypertensives = n_tx_new)
    
    # ---- Ordering labs (encounter-driven) -----------------------------------
    # updates$order_time <- event$time_next + turnaround
    #
    # upd_orders <- list(
    #   bmp_order_time    = event$time_next,
    #   lipid_order_time  = event$time_next
    # )
    
    # ---- Combine updates safely ---------------------------------------------
    # upd <- fluxCore::combine_updates(
    #   upd_age,
    #   upd_bp,
    #   upd_tx,
    #   upd_orders
    # )
    #
    # return(upd)
    
    return(NULL)  # placeholder until logic is implemented
  }
  
  # --------------------------------------------------------------------------
  # Example: lab draw
  # --------------------------------------------------------------------------
  if (et == "bmp_draw") {
    
    # ---- Read order time or other metadata ---------------------------------
    # order_time <- entity$state("bmp_order_time")
    
    # ---- Generate lab values ------------------------------------------------
    # bmp_vals <- list(
    #   sodium     = 140,
    #   potassium  = 4.2,
    #   creatinine = 1.0,
    #   glucose    = 95
    # )
    #
    # upd_bmp <- fluxCore::update_block(
    #   entity,
    #   block  = "bmp",
    #   values = bmp_vals
    # )
    
    # ---- Clear order state --------------------------------------------------
    # upd_clear <- list(bmp_order_time = NA_real_)
    
    # return(fluxCore::combine_updates(upd_bmp, upd_clear))
    
    return(NULL)
  }
  
  # --------------------------------------------------------------------------
  # Example: terminal event
  # --------------------------------------------------------------------------
  if (et == "terminal_event") {
    
    # ---- Mark terminal state explicitly ------------------------------------
    # upd_term <- list(dead = TRUE)
    
    # return(upd_term)
    
    return(NULL)
  }
  
  # --------------------------------------------------------------------------
  # Default: no state change
  # --------------------------------------------------------------------------
  NULL
}
