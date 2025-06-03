#' Example SET data
#'
#' A sample of data from M11 at ASIS
#'
#' @name example_sets
#' @format A data frame with 3888 rows and 11 variables:
#' \describe{
#'   \item{event_date_UTC}{Date UTC; measurement date, yyyy-mm-dd format}
#'   \item{network_code}{chr;, 4-letter I&M network code}
#'   \item{park_code}{chr; 4-letter NPS park code}
#'   \item{site_name}{chr; site name}
#'   \item{station_code}{chr; station/SET code}
#'   \item{SET_direction}{chr; one of four arm positions ("A", "B", "C", or "D")}
#'   \item{pin_position}{int; one of nine pins on each arm}
#'   \item{SET_offset_mm}{num; the height of the SET arm above the benchmark in mm}
#'   \item{pin_length_mm}{num; the length of the pins in mm}
#'   \item{pin_height_mm}{num; height of pin above arm, in mm}
#'   \item{set_type}{chr; the type of SET benchmark}
#' }
"example_sets"

#' Example MH data
#'
#' A sample of marker horizon data from M11 at ASIS
#'
#' @name example_mh
#' @format A data frame with 664 rows and 9 variables:
#' \describe{
#'   \item{event_date_UTC}{Date UTC; measurement date, yyyy-mm-dd format}
#'   \item{network_code}{chr;, 4-letter I&M network code}
#'   \item{park_code}{chr; 4-letter NPS park code}
#'   \item{site_name}{chr; site name}
#'   \item{station_code}{chr; station code}
#'   \item{marker_horizon_name}{chr; marker horizon replicate name}
#'   \item{core_measurement_number}{dbl; number of the measurement taken from a single core}
#'   \item{core_measurement_depth}{dbl; measured depth to the marker horizon in mm}
#'   \item{established_date}{Date UTC; date that the marker horizon plot was established, yyyy-mm-dd format}
#' }
"example_mh"
