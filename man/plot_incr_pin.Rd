% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_incr_pin.R
\name{plot_incr_pin}
\alias{plot_incr_pin}
\title{Plot change between readings, by pin for a single SET/station}
\usage{
plot_incr_pin(
  data,
  set,
  threshold = 25,
  columns = 2,
  pointsize = 2,
  scales = "fixed"
)
}
\arguments{
\item{data}{Data frame with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, and pin_height_mm.}

\item{set}{SET (aka station) ID to plot (required).}

\item{threshold}{Numeric value for red horizontal lines (at +/- this value); can be used for QAQC of pin_level incremental change; defaults to 25.}

\item{columns}{Number of columns you want in the faceted output; defaults to 4.}

\item{pointsize}{Size of points you want (goes into the `size` argument of `ggplot2::geom_point`); defaults to 2.}

\item{scales}{Do you want axis scales to be the same in all facets ("fixed") or to vary between facets "free_x" or "free_y" or "free" - goes into `scales` arg of `facet_wrap`; defaults to "fixed".}
}
\value{
a ggplot object
}
\description{
Plot change between readings, by pin for a single SET/station
}
\examples{
plot_incr_pin(example_sets, set = "M11-1")
plot_incr_pin(example_sets, set = "M11-1", threshold = 5)
plot_incr_pin(example_sets, set = "M11-1", threshold = 5, columns = 1)
}
