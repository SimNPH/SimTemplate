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
    interim_events <- ceiling(final_events * 0.5)
  })


# Assumptions -------------------------------------------------------------

assumptions <- expand.grid(
  hazard_ctrl = nph::m2r(c(36, 12, 6)),
  censoring_prop = c(0, 0.1, 0.3),
  crossing = m2d(seq(0,9, by=2)),
  effect_size_ph = c(0, 0.5, 0.8, 0.9),
  hr_before = c(1.5, 3)
) |>
  within({
    hazard_trt_before = hazard_ctrl * hr_before
  })


# Merging Options and Assumptions -----------------------------------------

design <- merge(
  options,
  assumptions,
  by=NULL
)


# Callibrating Implicitly defined Parameters ------------------------------

# hazard rate after onset of treatment effect
# calculated such that the median survival is the same as under proportional
# hazards with the given effect size. Fails if onset of treatment effect is
# after the median survival time
design <- design |>
  hr_after_crossing_from_PH_effect_size()

# rate of random censoring
design <- design |>
  cen_rate_from_cen_prop_crossing_hazards()

# Excluding Scenarios which did not give Reasonable Parameter Value--------

# Excluding Scenarios for which a hazard in the treatment arm could not be calculated.
# This happens when the median of the survival functions is before onset of treatment effect.
design <- design |>
  subset(!is.na(hazard_trt_after))


# Calculating True Summary Statistics -------------------------------------

design <- design |> true_summary_statistics_crossing_hazards(
    milestones   = m2d(c("06m"=6, "12m"=12, "24m"=24, "36m"=36)),
    cutoff_stats = m2d(c("06m"=6, "12m"=12, "24m"=24, "36m"=36))
  )

# Saving ------------------------------------------------------------------

filename <- "parameters/parameters_crossing_hazards.csv"
write.table(design, file=filename, quote=FALSE, sep=", ", dec=".", row.names = FALSE, col.names = TRUE)

