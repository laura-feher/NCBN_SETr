% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_raw_arm.R
\name{plot_raw_arm}
\alias{plot_raw_arm}
\title{Plot raw pin measurements, first averaged to SET_direction level, by date}
\usage{
plot_raw_arm(
  data,
  columns = 4,
  pointsize = 2,
  sdline = TRUE,
  sdlinesize = 1,
  scales = "free_y"
)
}
\arguments{
\item{data}{a data frame with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_height_mm}

\item{columns}{number of columns for the faceted graph}

\item{pointsize}{size of points for `geom_point()` layer}

\item{sdline}{logical; include error bars for +/- one standard deviation?}

\item{sdlinesize}{size for width of error bars}

\item{scales}{passed to `facet_wrap`; same fixed/free options as that function}
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
plot_raw_arm(example_sets, sdline = FALSE)
}
