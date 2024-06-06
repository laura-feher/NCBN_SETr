#' Interval Change Calculations
#'
#' @param data A data frame of either SET data or MH data. See details below for
#'   requirements.
#'
#' @description For SET data - pin-level interval change is first calculated as
#'   the difference between a pin reading and the prior pin reading. The column
#'   name in the $pin tibble is "intr". On the first date, this value is NA.
#'   Then, interval pin changes are averaged to the arm-level on each date,
#'   excluding NAs. Std. Deviation and Std. Error are also calculated. These
#'   columns in the $arm tibble are "mean_intr", "sd_intr", and "se_intr".
#'   Finally, the interval arm changes are then averaged to the station-level,
#'   also with st dev and st err. The columns in the $set tibble are again
#'   "mean_intr", "sd_intr", and "se_intr". Pin-level calculations are the most
#'   helpful for qa/qc, as it is possible to check for and follow-up on readings
#'   that have changed more than a certain amount (e.g., 25 mm) between
#'   readings.
#'
#'   For MH data - duplicate core readings ('core_measurement_number') are first
#'   averaged to the marker horizon-level. Then, interval change is calculated
#'   as the difference between the average marker horizon depth and the prior
#'   average depth. The column name in the $marker tibble is "intr". On the
#'   first date, this value is NA. Then, interval changes at each marker horizon
#'   are averaged to the station-level on each date, excluding NAs. Std.
#'   Deviation and Std. Error are also calculated. These columns in the
#'   $mh_station tibble are 'mean_intr", "sd_intr", and "se_intr". Marker
#'   horizon-level calculations are the most helpful for qa/qc, as it is
#'   possible to check for and follow-up on readings that have changed more than
#'   a certain amount (e.g. 25 mm) between readings.
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
#' calc_change_intr(example_sets)

calc_change_intr <- function(data){

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

        # by pin
        change_intr_pin <- data %>%
            dplyr::arrange(network_code, park_code, site_name, station_code, SET_direction, pin_position, event_date_UTC) %>%
            dplyr::group_by(network_code, park_code, site_name, station_code, SET_direction, pin_position) %>%
            dplyr::mutate(intr = pin_height_mm - dplyr::lag(pin_height_mm, 1)) %>%
            dplyr::ungroup()

        # pins averaged up to arms
        change_intr_arm <- change_intr_pin %>%
            dplyr::group_by(network_code, park_code, site_name, station_code, SET_direction, event_date_UTC) %>%
            dplyr::select(-pin_position) %>%
            dplyr::summarize(mean_intr = mean(intr, na.rm = TRUE),
                             sd_intr = stats::sd(intr, na.rm = TRUE),
                             se_intr = stats::sd(intr, na.rm = TRUE)/sqrt(length(!is.na(intr))),
                             .groups = "drop") %>%
            dplyr::ungroup() %>%
            dplyr::mutate(mean_intr = if_else(is.nan(mean_intr), NA_real_, mean_intr))

        # arms averaged up to stations
        change_intr_station <- change_intr_arm %>%
            dplyr::group_by(network_code, park_code, site_name, station_code, event_date_UTC) %>%
            dplyr::select(-SET_direction, mean_value = mean_intr) %>%
            dplyr::summarize(mean_intr = mean(mean_value, na.rm = TRUE),
                             sd_intr = stats::sd(mean_value, na.rm = TRUE),
                             se_intr = stats::sd(mean_value, na.rm = TRUE)/sqrt(length(!is.na(mean_value))),
                             .groups = "drop") %>%
            dplyr::ungroup() %>%
            dplyr::mutate(mean_intr = if_else(is.nan(mean_intr), NA_real_, mean_intr))

        return(list(pin = change_intr_pin, arm = change_intr_arm, station = change_intr_station))
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
        change_intr_mh <- data %>%
            dplyr::group_by(network_code, park_code, site_name, station_code, marker_horizon_name, event_date_UTC, established_date) %>%
            dplyr::summarise(mean_depth_mm = mean(core_measurement_depth_mm, na.rm = TRUE),
                             .groups = "drop") %>%
            dplyr::ungroup() %>%
            dplyr::group_by(network_code, park_code, site_name, station_code, marker_horizon_name, established_date) %>%
            dplyr::arrange(network_code, park_code, site_name, station_code, marker_horizon_name, established_date, event_date_UTC) %>%
            dplyr::mutate(intr = mean_depth_mm - dplyr::lag(mean_depth_mm, 1)) %>%
            dplyr::ungroup()

        # marker horizons averaged up to stations
        change_intr_mh_station <- change_intr_mh %>%
            dplyr::group_by(network_code, park_code, site_name, station_code, event_date_UTC, established_date) %>%
            dplyr::select(-marker_horizon_name) %>%
            dplyr::summarise(mean_intr = mean(intr, na.rm = TRUE),
                         sd_intr = stats::sd(intr, na.rm = TRUE),
                         se_intr = stats::sd(intr, na.rm = TRUE)/sqrt(length(!is.na(intr))),
                         .groups = "drop") %>%
            dplyr::ungroup() %>%
            dplyr::mutate(mean_intr = if_else(is.nan(mean_intr), NA_real_, mean_intr))

        return(list(mh = change_intr_mh, mh_station = change_intr_mh_station))
    }
}
