#' Example SET data
#'
#' A sample of data from M11 at ASIS
#'
#' @format A data frame with 36 rows and 5 variables:
#' \describe{
#'   \item{event_date_UTC}{Date UTC; measurement date, yyyy-mm-dd format}
#'   \item{network_code}{chr;, 4-letter I&M network code}
#'   \item{park_code}{chr; 4-letter NPS park code}
#'   \item{site_name}{chr; site name}
#'   \item{station_code}{chr; station/SET name}
#'   \item{SET_direction}{chr; one of four arm positions ("A", "B", "C", or "D")}
#'   \item{pin_position}{int; one of nine pins on each arm}
#'   \item{pin_height_mm}{num; height of pin above arm, in mm}
#' }
"example_sets"
