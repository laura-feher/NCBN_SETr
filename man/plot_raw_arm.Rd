% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_raw_arm.R
\name{plot_raw_arm}
\alias{plot_raw_arm}
\title{Plot raw pin measurements, first averaged to SET_direction level, by date}
\usage{
plot_raw_arm(
  data,
  set = NULL,
  columns = 4,
  pointsize = 2,
  seline = TRUE,
  selinesize = 1,
  scales = "free_y"
)
}
\arguments{
\item{data}{Data frame with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, and pin_height_mm.}

\item{columns}{Number of columns you want in the faceted output; defaults to 4.}

\item{pointsize}{Size of points you want (goes into the `size` argument of `ggplot2::geom_point`); defaults to 2.}

\item{seline}{logical; Include error bars for +/- one standard error? defaults to TRUE.}

\item{selinesize}{Size for width of error bars; defaults to 1.}

\item{scales}{Do you want axis scales to be the same in all facets ("fixed") or to vary between facets "free_x" or "free_y" or "free" - goes into `scales` arg of `facet_wrap`; defaults to "free_y".}
}
\value{
a ggplot object
}
\description{
Plot raw pin measurements, first averaged to SET_direction level, by date
}
\examples{
plot_raw_arm(example_sets)
plot_raw_arm(example_sets, columns = 1, pointsize = 3)
plot_raw_arm(example_sets, seline = FALSE)
}
