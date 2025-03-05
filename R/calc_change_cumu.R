#' Cumulative Change Calculations
#'
#' @param data A data frame of either SET data or MH data. See details below for
#'   requirements.
#'
#' @description For SET data - Pin-level cumulative change is first calculated
#'   as the difference between each pin reading and the reading from the
#'   earliest date that was not NA. The column name in the $pin tibble is
#'   "cumu". Then, cumulative pin changes are averaged to the arm-level on each
#'   date, excluding NAs. Std. Deviation and Std. Error are also calculated.
#'   These columns in the $arm tibble are "mean_cumu", "sd_cumu", and "se_cumu".
#'   Finally, the cumulative arm changes are then averaged to the station-level,
#'   also with st dev and st err. The columns in the $set tibble are again
#'   "mean_cumu", "sd_cumu", and "se_cumu".
#'
#'   For MH data - Duplicate core readings ('core_measurement_number') are first
#'   averaged to the marker horizon-level. The column name in the $mh tibble is
#'   "cumu". Then, average marker horizon depths are averaged to the
#'   station-level on each date, excluding NAs. Std. Deviation and Std. Error
#'   are also calculated. These columns in the $mh_station tibble are
#'   'mean_cumu", "sd_cumu", and "se_cumu".
#'
#' @details For SET data, `data` must be a data frame of SET data with 1 row per
#'   pin reading and the following columns, named exactly: event_date_UTC,
#'   network_code, park_code, site_name, station_code, SET_direction,
#'   pin_position, and pin_height_mm.
#'
#'   For MH data, `data` must be a data frame of marker horizon data with 1 row
#'   per core measurement and the following columns, named exactly:
#'   event_date_UTC, network_code, park_code, site_name, marker_horizon_name,
#'   core_measurement_number, core_measurement_depth_mm, and established_date.
#'
#' @return For SET data, returns a data frame of station-level cumulative
#'   surface elevation change. For MH data, returns a data frame of
#'   station-level vertical accretion.
#'
#' @export
#'
#' @import dplyr
#'
#' @examples
#' calc_change_cumu(example_sets)
#'
#' calc_change_cumu(example_mh)
#'
calc_change_cumu <- function(data) {

    # determine if the data is SET or MH
    data_type <- detect_data_type(data)

    ## do calculations based on data type
    if(data_type != "SET" & data_type != "MH") {
        stop(paste0("data must be either SET or MH data and contain the correct columns"))

    } else if(data_type == "SET") {

        change_cumu_set_station <- data %>%

            # first get cumulative change for each pin
            dplyr::arrange(network_code, park_code, site_name, station_code, SET_direction, pin_position, event_date_UTC) %>%
            dplyr::group_by(network_code, park_code, site_name, station_code, SET_direction, pin_position) %>%
            dplyr::mutate(first_pin_height = pin_height_mm[event_date_UTC == min(event_date_UTC[!is.na(pin_height_mm)])],
                          cumu = pin_height_mm - first_pin_height) %>%
            # dplyr::mutate(cumu = pin_height_mm - pin_height_mm[1]) %>% # this is Kim's formula for getting cumulative change but it doesn't work if the earliest date is NA
            # mutate(cumu = pin_height_mm - pin_height_mm[min(which(!is.na(pin_height_mm)))]) %>% ##### subtract off the first pin reading that's not NA
            dplyr::ungroup() %>%

            # average cumulative pin change up to the arm-level
            dplyr::group_by(network_code, park_code, site_name, station_code, SET_direction, event_date_UTC) %>%
            dplyr::select(-pin_position) %>%
            dplyr::summarize(mean_cumu = mean(cumu, na.rm = TRUE),
                             sd_cumu = stats::sd(cumu, na.rm = TRUE),
                             se_cumu = stats::sd(cumu, na.rm = TRUE)/sqrt(length(!is.na(cumu))),
                             .groups = "drop") %>%

            #average cumulative arm-level change up to the station-level
            dplyr::group_by(network_code, park_code, site_name, station_code, event_date_UTC) %>%
            dplyr::select(-SET_direction, mean_value = mean_cumu) %>%
            dplyr::summarize(mean_cumu = mean(mean_value, na.rm = TRUE),
                             sd_cumu = stats::sd(mean_value, na.rm = TRUE),
                             se_cumu = stats::sd(mean_value, na.rm = TRUE)/sqrt(length(!is.na(mean_value))),
                             .groups = "drop")

        return(change_cumu_set_station)

    } else if(data_type == "MH"){

        change_cumu_mh_station <- data %>%

            # first average all core measurements from each date
            dplyr::group_by(network_code, park_code, site_name, station_code, marker_horizon_name, event_date_UTC, established_date) %>%
            dplyr::summarise(cumu = mean(core_measurement_depth_mm, na.rm = TRUE),
                             .groups = "drop") %>%
            dplyr::ungroup() %>%

            # average the core measurements from each plot up to the station-level
            dplyr::group_by(network_code, park_code, site_name, station_code, event_date_UTC, established_date) %>%
            dplyr::select(-marker_horizon_name) %>%
            dplyr::summarise(mean_cumu = mean(cumu, na.rm = TRUE),
                             sd_cumu = stats::sd(cumu, na.rm = TRUE),
                             se_cumu = stats::sd(cumu, na.rm = TRUE)/sqrt(length(!is.na(cumu))),
                             .groups = "drop") %>%
            dplyr::mutate(mean_cumu = if_else(is.nan(mean_cumu), NA_real_, mean_cumu)) %>%
            dplyr::ungroup()

        return(change_cumu_mh_station)
    }
}
