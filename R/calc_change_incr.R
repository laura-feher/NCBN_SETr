#' Incremental Change Calculations
#'
#' @param data a data frame with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, pin_height_mm
#'
#' @return a list of three tibbles: one each for pin, arm, and set level calculations. Pin level change is calculated first, as the difference between a pin reading and the prior pin reading from that set_id--arm--pin. The column name in the $pin tibble is "incr". For every date of a pin reading, this calculated value will exist or be NA. On the first date, it is NA. Incremental pin changes are then averaged to the arm position level on each date, excluding NAs. St Deviation and St Error are also calculated. There is one calculated value for every arm on every reading date. These columns in the $arm tibble are "mean_incr", "sd_incr", and "se_incr". The cumulative arm changes are then averaged to the SET level, also with st dev and st err. There is one calculated value for every SET on every reading date. The columns in the $set tibble are again "mean_incr", "sd_incr", and "se_incr". Pin level calculations are the most helpful for qa/qc, as it is possible to check for and follow-up on readings that have changed more than a certain amount (e.g. 25 mm) between readings.
#'
#' @export
#'
#' @examples
#' calc_change_incr(example_sets)


calc_change_incr <- function(data){

    ## conditions: have correct columns in data frame
    ## stop and give an informative message if this isn't met
    req_clms <- c("event_date_UTC", "network_code", "park_code", "site_name", "station_code", "SET_direction", "pin_position", "pin_height_mm")

    if(sum(req_clms %in% names(data)) != length(req_clms)){
        stop(paste("Your data frame must have the following columns, with these names, but is missing at least one:", paste(req_clms, collapse = ", ")))
    }


    ## calculations


    # by pin
    change_incr_pin <- data %>%
        #dplyr::mutate(set_id = paste(network_code, park_code, station_code, sep = "_")) %>%
        dplyr::arrange(network_code, park_code, site_name, station_code, SET_direction, pin_position, event_date_UTC) %>%
        dplyr::group_by(network_code, park_code, site_name, station_code, SET_direction, pin_position) %>%
        dplyr::mutate(incr = pin_height_mm - dplyr::lag(pin_height_mm, 1)) %>%
        dplyr::ungroup()

    # pins averaged up to arms
    change_incr_arm <- change_incr_pin %>%
        dplyr::group_by(network_code, park_code, site_name, station_code, SET_direction, event_date_UTC) %>%
        dplyr::select(-pin_position) %>%
        dplyr::summarize(mean_incr = mean(incr, na.rm = TRUE),
                  sd_incr = stats::sd(incr, na.rm = TRUE),
                  se_incr = stats::sd(incr, na.rm = TRUE)/sqrt(length(!is.na(incr)))) %>%
        dplyr::ungroup()

    # arms averaged up to SETs
    change_incr_set <- change_incr_arm %>%
        dplyr::group_by(network_code, park_code, site_name, station_code, event_date_UTC) %>%
        dplyr::select(-SET_direction, mean_value = mean_incr) %>%
        dplyr::summarize(mean_incr = mean(mean_value, na.rm = TRUE),
                  sd_incr = stats::sd(mean_value, na.rm = TRUE),
                  se_incr = stats::sd(mean_value, na.rm = TRUE)/sqrt(length(!is.na(mean_value)))) %>%
        dplyr::ungroup()

    return(list(pin = change_incr_pin, arm = change_incr_arm, set = change_incr_set))
}
