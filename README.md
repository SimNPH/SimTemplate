# SimTemplate

Template Scripts for Simulation Studies in the Scenarios of the CONFIRMS Study,
with different Analysis Methods. 

# How to Use

## Adding Summary Statistics

In the scripts `01a_`, `01b_`, ... add additional cutoff values for RMST,
average hazard ratios and milestone survival and/or manually compute your own
summary statistics from the parameter values.

## Adding Analysis Methods

Add your analysis methods, see example in `02_methods_summaries.R`. Add
summarise-functions as appropriate or use the built-in `summarise_test` and
`summarise_estimator`.

## Running the Simulations

Install the `SimNPH` package from CRAN.

Run the simulations by running the scripts `01a_`, `01b_`, ...., `02a_`, `02b_`,
..., the scripts `02_methods_summaries.R` and `02_setup_cluster.R` do not need
to be run manually, they are sourced from the other scripts. Use the project
root directory as working directory.
