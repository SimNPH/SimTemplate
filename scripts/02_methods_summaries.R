# custom analysis functions -----------------------------------------------

# example test using survival::survdiff
custom_test <- function(){
  function(condition, dat, fixed_objects = NULL) {
    list(
      p = survival::survdiff(Surv(t, evt) ~ trt, dat)$pvalue,
      N_pat = nrow(dat),
      N_evt = sum(dat$evt))
  }
}

custom_est <- function (level = 0.95)
{
  function(condition, dat, fixed_objects = NULL) {
    model <- survival::coxph(Surv(t, evt) ~ trt, dat)
    list(
      hr = exp(coefficients(model)[["trt"]]),
      hr_lower = confint(model) |> as.matrix() |> _["trt", ][1] |> exp(),
      hr_upper = confint(model) |> as.matrix() |> _["trt", ][1] |> exp(),
      CI_level = level,
      N_pat = nrow(dat),
      N_evt = sum(dat$evt))
  }
}

# define analyse functions ------------------------------------------------

# set nominal one-sided alpha for group-sequential tests
alpha <- 0.025
nominal_alpha <- ldbounds::ldBounds(c(0.5,1), sides=1, alpha = 0.025)$nom.alpha
# export to all cluster nodes
clusterExport(cl, "nominal_alpha")

my_analyse <- list(
  # example estimator: rmst
  rmst_diff_24m = analyse_rmst_diff(max_time=m2d(24), alternative = "one.sided"),
  # example test: logrank
  logrank = analyse_logrank(alternative = "one.sided"),
  # example group sequential test: group sequential logrank test
  logrank_gs = analyse_group_sequential(
    followup = c(condition$interim_events, condition$final_events),
    followup_type = c("event", "event"),
    alpha = nominal_alpha,
    analyse_functions = analyse_logrank(alternative = "one.sided")
  ),
  # adding the custom test
  my_test = custom_test(),
  # adding custom estimator,
  my_est = custom_est(),
  # descriptive statistics of the datasets
  descriptive = analyse_describe()
)

my_analyse <- wrap_all_in_trycatch(my_analyse)

# define summaries --------------------------------------------------------

my_summarise <- create_summarise_function(
  # summarise rmst difference, real value is 24m rmst of trt minus 24m rmst of ctrl
  rmst_diff_24m = summarise_estimator(est=rmst_diff, real=rmst_trt_24m-rmst_ctrl_24m, lower=rmst_diff_lower, upper=rmst_diff_upper, null=0),
  # summarise logrank test, testing at one sided alpha
  logrank = summarise_test(alpha),
  # summarise group sequential logrank test
  logrank_gs = summarise_group_sequential(),
  # summary for the custom test
  my_test = summarise_test(alpha),
  # summary for the custom estimator,
  my_est = summarise_estimator(est=hr, real=hazard_trt/hazard_ctrl, lower=hr_lower, upper=hr_upper, null=1),
  # summary of the desriptive statistics
  descriptive = summarise_describe()
)

