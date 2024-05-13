library(SimNPH)
library(SimDesign)
library(parallel)

N_sim <- 2500

# setup cluster -----------------------------------------------------------
source("scripts/02_setup_cluster.R")

# setup data generation ---------------------------------------------------

# load parameters
design <- read.table("parameters/parameters_delayed_effect.csv", sep=",", dec=".", header=TRUE)

# define generator
my_generator <- function(condition, fixed_objects=NULL){
  generate_delayed_effect(condition, fixed_objects) |>
    recruitment_uniform(condition$recruitment) |>
    random_censoring_exp(condition$random_withdrawal) |>
    admin_censoring_events(condition$final_events)
}

# define analysis and summarise functions ---------------------------------
source("scripts/02_methods_summaries.R")

# run ---------------------------------------------------------------------

save_folder <- paste0("results/delayed_effect_", Sys.info()["nodename"], "_", strftime(Sys.time(), "%Y-%m-%d_%H%M%S"))
dir.create(save_folder, showWarnings = FALSE, recursive = TRUE)

results <- runSimulation(
  design,
  replications = N_sim,
  generate = my_generator,
  analyse = my_analyse,
  summarise = my_summarise,
  seed = design$old_seed,
  cl = cl,
  parallel = TRUE,
  save_details = list(
    out_rootdir = save_folder
  ),
  control = list(
    store_warning_seeds = TRUE,
    allow_na = TRUE
  )
)

saveRDS(results, paste0(save_folder, "/results.Rds"))


