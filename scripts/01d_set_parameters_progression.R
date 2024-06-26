library(SimNPH)

# Options -----------------------------------------------------------------

options <- expand.grid(
  recruitment = m2d(c(18, 30)),
  n_pat = c(300, 500, 1000, 1500)
) |>
  within({
    n_trt <- n_pat / 2
    n_ctrl <- n_pat / 2
    final_events <- ceiling(n_pat * 0.75)
    interim_events <- ceiling(final_events * 0.5) # 75% estimated from reconstructed KM curves
  })


# Assumptions -------------------------------------------------------------

assumptions <- expand.grid(
  hazard_ctrl = nph::m2r(c(36, 12, 6)),
  prog_prop_trt  = c(0.1, 0.2),
  prog_prop_ctrl = c(0.1, 0.2),
  hr_before_after = c(0.8, 0.5),
  censoring_prop = c(0, 0.1, 0.3),
  effect_size_ph = c(0, 0.5, 0.8, 0.9)
) |>
  subset(prog_prop_ctrl >= prog_prop_trt)

assumptions$hazard_after_prog <- assumptions$hazard_ctrl / assumptions$hr_before_after

# temporary used for progression rates, later updated to match effect size
assumptions$hazard_trt <- assumptions$hazard_ctrl

# Merging Options and Assumptions -----------------------------------------

design <- merge(
  options,
  assumptions,
  by=NULL
)

# calculate progression rate from progression proportion  -----------------

design <- progression_rate_from_progression_prop(design)

# calculate hazards from PH effect size -----------------------------------

design <- hazard_before_progression_from_PH_effect_size(design)

# calculate random withdrawal ---------------------------------------------

design <- cen_rate_from_cen_prop_progression(design)

# Calculating True Summary Statistics -------------------------------------

design_os <- design |> true_summary_statistics_progression(
    milestones   = m2d(c("06m"=6, "12m"=12, "24m"=24, "36m"=36)),
    cutoff_stats = m2d(c("06m"=6, "12m"=12, "24m"=24, "36m"=36)),
    what = "os"
  )

# Saving ------------------------------------------------------------------

filename_os <- "parameters/parameters_progression_os.csv"
write.table(design_os, file=filename_os, quote=FALSE, sep=", ", dec=".", row.names = FALSE, col.names = TRUE)
