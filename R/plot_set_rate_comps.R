#' Graphical comparison of station-level surface elevation change rates
#'
#' @param data Either 1) a data frame of raw SET data or 2) a data frame of
#'   station-level rates of surface elevation change. See details below for
#'   requirements.
#'
#' @param calc_rates do rates of change need to be calculated before generating
#'   plots? Defaults to TRUE. If supplying a data frame of raw SET data, use
#'   `calc_rates` = TRUE. If supplying a data frame with pre-calculated rates,
#'   use `calc_rates` = FALSE.
#'
#' @param station_ids required if a supplying a data frame with rates. Column
#'   name of values representing the station ID for each station. Defaults to
#'   'station_code'.
#'
#' @param rates required if supplying a data frame with rates. Column name of
#'   values representing the linear estimates (i.e., rates) of surface elevation
#'   change for each station. Defaults to 'station_rate'.
#'
#' @param station_se required if supplying a data frame with rates. Column name
#'   of values representing the standard errors for each station-level rate of
#'   surface elevation change. Defaults to 'station_se_rate'.
#'
#' @description Station-level cumulative change is calculated via the function
#'   'calc_change_cumu'. Linear rates of change are calculated via the function
#'   'calc_linear_rates'. See function documentation for details.
#'
#' @details `data` must be either 1) a data frame of raw SET data with 1 row per
#'   pin reading and the following columns, named exactly: event_date_UTC,
#'   network_code, park_code, site_name, station_code, SET_direction,
#'   pin_position, and pin_height_mm; or 2) a user-created data frame of
#'   station-level rates of surface elevation change with (at least) columns for
#'   station IDs, station-level rates, and station rate std errors, with one row
#'   per station.
#'
#' @return a ggplot object
#'
#' @export
#'
#' @import ggplot2
#' @import dplyr
#'
#' @examples
#'
#' plot_set_rate_comps(data = example_sets)
#'
#' Example with a user-supplied data frame of station-level rates
#' example_rates <- data.frame("station" = c("station_1", "station_2", "station_3"),
#'                             "rate" = c(3.2, 4.0, 5.4),
#'                             "se_rate" = c(1, 0.5, 0.25))
#'
#' plot_set_rate_comps(data = example_rates,
#'                 calc_rates = FALSE,
#'                 station_ids = station,
#'                 rates = rate,
#'                 station_se = se_rate)
#'
plot_set_rate_comps <- function(data,
                                calc_rates = TRUE,
                                station_ids = "station_code",
                                rates = "station_rate",
                                station_se = "station_se_rate"){

    # if supplying df of rates, make sure that the specified columns exist in the df
    if(calc_rates == FALSE & (!station_ids %in% colnames(data) |
                              !rates %in% colnames(data) |
                              !station_se %in% colnames(data))){
        stop(paste0("column names '", station_ids, "', '", rates, "', and/or '",
                    station_se, "' were not found in '", deparse(substitute(data)), "'"))
    }

    if(calc_rates == FALSE) {
        dataf <- data # if supplying a df of rates, don't use calc_linear_rates to get rates
    }
    else if(calc_rates == TRUE) {

        # make sure the data is SET data
        data_type <- detect_data_type(data)

        if(data_type != "SET") {
            stop(paste0("data must be SET data"))
        } else {
            dataf <- calc_linear_rates(data) # if supplying a raw data df, use calc_linear_rates to get rates
        }
    }

    # assemble plot
    ggplot2::ggplot(data = dataf, aes(x = .data[[rates]], y = .data[[station_ids]])) +
        ggplot2::geom_vline(aes(xintercept = 0), color = "gray70", linetype = "dashed") +
        ggplot2::geom_errorbar(aes(y = .data[[station_ids]], xmin = .data[[rates]] - .data[[station_se]], xmax = .data[[rates]] + .data[[station_se]]), color = "gray55", linewidth = 1) +
        ggplot2::geom_point(size = 3, color = "red3") +
        ggplot2::labs(title = "Rates of surface elevation change ± 1 standard error (mm/yr)", x = "Rate of surface elevation change (mm/yr)", y = "Station")

}
