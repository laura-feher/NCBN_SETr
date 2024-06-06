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
#' @return For SET data, returns a list of three tibbles: one each for pin-,
#'   arm-, and station-level calculations.
#'
#'   For MH data, returns a list of two tibbles: one for each marker horizon-
#'   and station-level calculations.
#'
#' @export
#'
#' @examples
#' calc_change_cumu(example_sets)
#'
calc_change_cumu <- function(data) {

    # determine if the data is SET or MH
    cols <- colnames(data)

    if("pin_height_mm" %in% cols){

        ## conditions: have correct columns in data frame
        ## stop and give an informative message if this isn't met
        req_clms <- c("event_date_UTC", "network_code", "park_code", "site_name", "station_code", "SET_direction", "pin_position", "pin_height_mm")

        if(sum(req_clms %in% names(data)) != length(req_clms)){
            stop(paste("Your data frame must have the following columns, with these names, but is missing at least one:", paste(req_clms, collapse = ", ")))
        }

    ## calculations

    # have to make sure to arrange properly so correct pin reading is subtracted off

    # by pin
    change_cumu_pin <- data %>%
        dplyr::arrange(network_code, park_code, site_name, station_code, SET_direction, pin_position, event_date_UTC) %>%
        dplyr::group_by(network_code, park_code, site_name, station_code, SET_direction, pin_position) %>%
        dplyr::mutate(first_pin_height = pin_height_mm[event_date_UTC == min(event_date_UTC[!is.na(pin_height_mm)])],
                      cumu = pin_height_mm - first_pin_height) %>%
        # dplyr::mutate(cumu = pin_height_mm - pin_height_mm[1]) %>% # this is Kim's formula for getting cumulative change but it doesn't work if the earliest date is NA
        # mutate(cumu = pin_height_mm - pin_height_mm[min(which(!is.na(pin_height_mm)))]) %>% ##### subtract off the first pin reading that's not NA
        dplyr::ungroup()

    # pins averaged up to arms
    change_cumu_arm <- change_cumu_pin %>%
        dplyr::group_by(network_code, park_code, site_name, station_code, SET_direction, event_date_UTC) %>%
        dplyr::select(-pin_position) %>%
        dplyr::summarize(mean_cumu = mean(cumu, na.rm = TRUE),
                         sd_cumu = stats::sd(cumu, na.rm = TRUE),
                         se_cumu = stats::sd(cumu, na.rm = TRUE)/sqrt(length(!is.na(cumu))),
                         .groups = "drop")

    # arms averaged up to SETs
    change_cumu_station <- change_cumu_arm %>%
        dplyr::group_by(network_code, park_code, site_name, station_code, event_date_UTC) %>%
        dplyr::select(-SET_direction, mean_value = mean_cumu) %>%
        dplyr::summarize(mean_cumu = mean(mean_value, na.rm = TRUE),
                         sd_cumu = stats::sd(mean_value, na.rm = TRUE),
                         se_cumu = stats::sd(mean_value, na.rm = TRUE)/sqrt(length(!is.na(mean_value))),
                         .groups = "drop")

    return(list(pin = change_cumu_pin, arm = change_cumu_arm, station = change_cumu_station))
    }

    else if("core_measurement_depth_mm" %in% cols){

        ## conditions: have correct columns in data frame
        ## stop and give an informative message if this isn't met
        req_clms <- c("event_date_UTC", "network_code", "park_code", "site_name", "station_code", "marker_horizon_name", "core_measurement_number", "core_measurement_depth_mm", "established_date")

        if(sum(req_clms %in% names(data)) != length(req_clms)){
            stop(paste("Your data frame must have the following columns, with these names, but is missing at least one:", paste(req_clms, collapse = ", ")))
        }

        ## calculations
        # by marker horizon
        change_cumu_mh <- data %>%
            dplyr::group_by(network_code, park_code, site_name, station_code, marker_horizon_name, event_date_UTC, established_date) %>%
            dplyr::summarise(cumu = mean(core_measurement_depth_mm, na.rm = TRUE),
                             .groups = "drop") %>%
            dplyr::ungroup()

        # marker horizons averaged up to stations
        change_cumu_mh_station <- change_cumu_mh %>%
            dplyr::group_by(network_code, park_code, site_name, station_code, event_date_UTC, established_date) %>%
            dplyr::select(-marker_horizon_name) %>%
            dplyr::summarise(mean_cumu = mean(cumu, na.rm = TRUE),
                             sd_cumu = stats::sd(cumu, na.rm = TRUE),
                             se_cumu = stats::sd(cumu, na.rm = TRUE)/sqrt(length(!is.na(cumu))),
                             .groups = "drop") %>%
            dplyr::mutate(mean_cumu = if_else(is.nan(mean_cumu), NA_real_, mean_cumu))

        return(list(mh = change_cumu_mh, mh_station = change_cumu_mh_station))
    }
}
