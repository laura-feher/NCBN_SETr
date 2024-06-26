% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{example_sets}
\alias{example_sets}
\title{Example SET data}
\format{
A data frame with 36 rows and 5 variables:
\describe{
  \item{date}{measurement date, yyyy-mm-dd format}
  \item{set_id}{unique name of measured SET}
  \item{arm_position}{one of two arm positions, each containing three pins (real SETs typically contain measurements for 9 pins on each of 4 arm positions, for 36 measurements on a given date; this dataset has been simplified for illustration)}
  \item{pin_number}{one of three pins on each arm (real SETs typically contain measurements for 9 pins on each of 4 arm positions, for 36 measurements on a given date; this dataset has been simplified for illustration)}
  \item{pin_height}{height of pin above arm, in mm (completely made up in this example dataset)}
}
}
\usage{
example_sets
}
\description{
Completely made up, but with
characteristics of actual SET data
}
\keyword{datasets}
