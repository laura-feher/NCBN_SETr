
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SETrNCBN

<!-- badges: start -->
<!-- badges: end -->

The goal of SETrNCBN is to simplify calculations and make graphs for
QA/QC and communication of NCBN Surface Elevation Table (SET) data.

This package is under development [GitHub,
here](https://github.com/laura-feher/NCBN_SETr).

This README still needs a lot of attention too; the example below is
very minimal.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("laura-feher/NCBN_SETr")
```

## Example

This is a basic example which shows you how to make a simple graph of
change since the first reading at each SET:

``` r
library(SETrNCBN)

# first, perform cumulative change calculations
cumu_set <- calc_change_cumu(example_sets)

# now plot cumulative change by SET
plot_cumu_set(example_sets)
```

<img src="man/figures/README-example-1.png" width="70%" />

``` r

# or by arm, at a single SET
plot_cumu_arm(example_sets)
```

<img src="man/figures/README-example-2.png" width="70%" />
