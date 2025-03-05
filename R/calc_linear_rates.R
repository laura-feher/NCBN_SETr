#' Calculate station-level linear rates of change from SET or MH data
#'
#' @param data A data frame of either SET data or MH data. See details below for
#'   requirements.
#'
#' @param station (optional) Plot SET cumulative data from specific station(s).
#'   Refers to the 'station_code' column in the SET data. Can be a single
#'   station code (e.g. "M11-1") or vector of multiple stations (e.g. c("M11-1",
#'   "M11-2)).
#'
#' @param site (optional) Plot SET cumulative data from specific site(s). Refers
#'   to the 'site_name' column in the SET data. Can be a single site name (e.g.
#'   "Marsh 11") or vector of multiple sites (e.g. c("Marsh 11", "Marsh 3")).
#'
#' @param park (optional) Plot SET cumulative data from specific park(s). Refers
#'   to the 'park_code' column in the SET data. Can be a single park code (e.g.
#'   "ASIS") or vector of multiple parks (e.g. c("ASIS", "GATE")) although it is
#'   not recommended to plot multiple parks because the individual station-level
#'   panels will be hard to see.
#'
#' @description Station-level cumulative change is calculated via the function
#'   'calc_change_cumu' - see function documentation for details.
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
#' @return For SET data, returns a data frame of station-level rates of surface
#'   elevation change. For MH data, returns a data frame of station-level rates of
#'   surface accretion. Note that units for rates of change are mm/yr.
#'
#' @note Stations with fewer than 3 measurement dates are excluded from the
#'   calculation of rates.
#'
#' @export
#'
#' @import dplyr
#' @import purrr
#' @import tidyr
#' @import tibble
#'
#' @examples
#' calc_linear_rates(example_sets)
#'
#' calc_linear_rates(example_mh, station = station = c("M11-1", "M11-3"))
#'
#' calc_linear_rates(example_sets, site = "Elders East")
#'
calc_linear_rates <- function(data, station = NULL, site = NULL , park = NULL){

    # determine if the data is SET or MH
    data_type <- detect_data_type(data)

    if(data_type != "SET" & data_type != "MH") {
        stop(paste0("data must be either SET or MH data"))
    } else if (data_type == "SET") {

        # if any of the select stations or sites are not in the data, return a warning
        list_stations <- data %>%
            dplyr::distinct(station_code) %>%
            dplyr::pull()

        list_sites <- data %>%
            dplyr::distinct(site_name) %>%
            dplyr::pull()

        list_parks <- data %>%
            distinct(park_code) %>%
            dplyr::pull()

        unmatched_stations <- station[!station %in% list_stations]
        matched_stations <- station[station %in% list_stations]
        if(length(matched_stations) > 0 & length(unmatched_stations) > 0) {
            warning(paste0(" station '", unmatched_stations, "' not found "))
        }
        else if(length(matched_stations) == 0 & length(unmatched_stations) > 0) {
            stop(paste0("station '", unmatched_stations, "' not found "))
        }

        unmatched_sites <- site[!site %in% list_sites]
        matched_sites <- site[site %in% list_sites]
        if(length(matched_sites) > 0 & length(unmatched_sites) > 0) {
            warning(paste0(" site '", unmatched_site, "' not found "))
        }
        else if(length(matched_sites) == 0 & length(unmatched_sites) > 0) {
            stop(paste0("site '", unmatched_sites, "' not found "))
        }

        unmatched_parks <- park[!park %in% list_parks]
        matched_parks <- park[park %in% list_parks]
        if(length(matched_parks) > 0 & length(unmatched_parks) > 0) {
            warning(paste0(" park '", unmatched_parks, "' not found "))
        }
        else if(length(matched_parks) == 0 & length(unmatched_parks) > 0) {
            stop(paste0("park '", unmatched_parks, "' not found "))
        }

        # filter the data based on station/site/park selections or return unfiltered data
        calc_df <- data %>%
            {
                if(!is.null(park) & is.null(site) & is.null(station))
                    filter(., park_code %in% !!park)
                else if(is.null(park) & !is.null(site) & is.null(station))
                    filter(., site_name %in% !!site)
                else if(is.null(park) & is.null(site) & !is.null(station))
                    filter(., station_code %in% !!station)
                else # if no selections are made, return plots for all stations in the data
                    .
            }

        # first calculate cumulative change for each station
        data_cumu <- calc_change_cumu(calc_df)

        exclude_set_stations <- data.frame(
            station = c(rep("GUT", 3), rep("HH", 9), rep("HighToss", 3), rep("Old N", 4), rep("Phrag", 3))
        ) %>%
            dplyr::group_by(station) %>%
            dplyr::mutate(station_number = seq(1:length(station)),
                   station_code = paste0(station, station_number)) %>%
            dplyr::pull(station_code)

        # use linear regression to get a rate of change for each station
        linear_rates_set_station <- data_cumu %>%
            dplyr::group_by(network_code, park_code, site_name, station_code) %>%
            dplyr::mutate(date_count = dplyr::n_distinct(event_date_UTC)) %>%
            # limit calculation of rates to stations with at least 3
            # measurements - this is the min # needed to calculate a linear rate
            dplyr::filter(date_count >= 3) %>%
            dplyr::select(-date_count) %>%
            # convert dates to decimal year since first date
            dplyr::mutate(first_date = event_date_UTC[event_date_UTC == min(event_date_UTC[!is.na(mean_cumu)])],
                   date_num = as.numeric(event_date_UTC - first_date)/365.25) %>%
            tidyr::nest() %>%
            dplyr::mutate(station_lm_model = purrr::map(data, ~lm(mean_cumu ~ date_num, data = .)),
                   station_lm_model_summary = purrr::map(station_lm_model, ~summary(.)),
                   station_rate = purrr::map_dbl(station_lm_model, ~coefficients(.)[['date_num']]),
                   station_se_rate = purrr::map_dbl(station_lm_model_summary, ~.$coefficients[['date_num', 'Std. Error']]),
                   station_rate_r2 = purrr::map_dbl(station_lm_model_summary, ~.$r.squared),
                   station_rate_p = purrr::map_dbl(station_lm_model_summary, ~.$coefficients[['date_num', 'Pr(>|t|)']]),
                   station_ci = purrr::map(station_lm_model, ~as.data.frame(confint(., parm = c("date_num"), level = 0.95))),
                   station_ci_low = purrr::map_dbl(station_ci, ~.$`2.5 %`),
                   station_ci_high =  purrr::map_dbl(station_ci, ~.$`97.5 %`),
                   station_ci_abs_value = abs(station_ci_high - station_rate),
                   date_count = purrr::map_int(data, ~dplyr::n_distinct(.x$event_date_UTC))
            )

        return(linear_rates_set_station)

        # For now, don't calculate site-level rates because: 1. there are some
        # confounding-type issues with grouping all of the stations at each site
        # together since there some stations with very different start times
        # (e.g. one station started in 2002 and the other started in 2019 - the
        # zeros at the start of the new stations get averaged into the
        # cumulative change values with the other stations for that date) with
        # different treatments use linear regression to get a rate for each
        # site. 2. Some stations have different treatments (e.g. the fenced
        # sites at ASIS) or different SET types (e.g. EE1S at GATE is a shallow
        # SET) so they aren't meant to be grouped together at the site-level.
        # Therefore, the grouping that needs to be done before calculating site
        # rates needs to be done manually/carefully.

    }
    else if(data_type == "MH"){

        # if any of the select stations or sites are not in the data, return a warning
        list_stations <- data %>%
            dplyr::distinct(station_code) %>%
            dplyr::pull()

        list_sites <- data %>%
            dplyr::distinct(site_name) %>%
            dplyr::pull()

        list_parks <- data %>%
            distinct(park_code) %>%
            dplyr::pull()

        unmatched_stations <- station[!station %in% list_stations]
        matched_stations <- station[station %in% list_stations]
        if(length(matched_stations) > 0 & length(unmatched_stations) > 0) {
            warning(paste0(" station '", unmatched_stations, "' not found "))
        }
        else if(length(matched_stations) == 0 & length(unmatched_stations) > 0) {
            stop(paste0("station '", unmatched_stations, "' not found "))
        }

        unmatched_sites <- site[!site %in% list_sites]
        matched_sites <- site[site %in% list_sites]
        if(length(matched_sites) > 0 & length(unmatched_sites) > 0) {
            warning(paste0(" site '", unmatched_site, "' not found "))
        }
        else if(length(matched_sites) == 0 & length(unmatched_sites) > 0) {
            stop(paste0("site '", unmatched_sites, "' not found "))
        }

        unmatched_parks <- park[!park %in% list_parks]
        matched_parks <- park[park %in% list_parks]
        if(length(matched_parks) > 0 & length(unmatched_parks) > 0) {
            warning(paste0(" park '", unmatched_parks, "' not found "))
        }
        else if(length(matched_parks) == 0 & length(unmatched_parks) > 0) {
            stop(paste0("park '", unmatched_parks, "' not found "))
        }

        # filter the data based on station/site/park selections or return unfiltered data
        calc_df <- data %>%
            {
                if(!is.null(park) & is.null(site) & is.null(station))
                    filter(., park_code %in% !!park)
                else if(is.null(park) & !is.null(site) & is.null(station))
                    filter(., site_name %in% !!site)
                else if(is.null(park) & is.null(site) & !is.null(station))
                    filter(., station_code %in% !!station)
                else # if no selections are made, return plots for all stations in the data
                    .
            }

        # first calculate cumulative change for each station
        data_cumu <- calc_change_cumu(calc_df)

        # use linear regression to get a rate of change for each station
        linear_rates_mh_station <- data_cumu %>%
            dplyr::group_by(network_code, park_code, site_name, station_code) %>%
            # find stations where established_date is not the first row
            dplyr::mutate(first_date = event_date_UTC[event_date_UTC == min(event_date_UTC[!is.na(mean_cumu)])],
                   first_date_match = dplyr::if_else(first_date == established_date, "y", "n")) %>%
            dplyr::group_modify(~{
                if(all(.x$first_date_match == "y")) # if established_date = first row, do nothing
                    .x
                else if(any(.x$first_date_match == "n")) # if established date is not first row, add a blank row
                    tibble::add_row(.x, first_date_match = "n", .before = 0)
            }) %>%
            dplyr::mutate(dplyr::across(c(mean_cumu, sd_cumu, se_cumu), # fill in mean, sd, and se, columns with 0 for the blank rows
                          ~dplyr::if_else(if_all(.cols = c(
                              event_date_UTC,
                              established_date,
                              mean_cumu,
                              sd_cumu,
                              se_cumu,
                              first_date),
                                          .f = is.na),
                                       0,
                                       mean_cumu))) %>%
            dplyr::group_by(network_code, park_code, site_name, station_code) %>%
            tidyr::fill(established_date, .direction = "up") %>% # fill established date in new first rows using the station's established date value in other rows
            dplyr::mutate(first_date = dplyr::if_else(
                first_date_match == "n",
                established_date,
                first_date
            ),
            event_date_UTC = dplyr::if_else( # fill event_date_UTC in new first rows using the station's established date
                is.na(event_date_UTC) & first_date_match == "n" & mean_cumu == 0,
                established_date,
                event_date_UTC
            )) %>%
            dplyr::mutate(date_count = n_distinct(event_date_UTC)) %>%
            dplyr::filter(date_count >= 3) %>% # limit calculation of rates to sites with at least 3 measurements - this is the min # needed to calculate a linear rate
            dplyr::select(-c(first_date_match, date_count)) %>%

            # convert dates to decimal year since first date
            dplyr::mutate(date_num = as.numeric(event_date_UTC - first_date)/365.25) %>%
            tidyr::nest() %>%
            dplyr::mutate(station_lm_model = purrr::map(data, ~lm(mean_cumu ~ date_num, data = .)),
                   station_lm_model_summary = purrr::map(station_lm_model, ~summary(.)),
                   station_rate = purrr::map_dbl(station_lm_model, ~coefficients(.)[['date_num']]),
                   station_se_rate = purrr::map_dbl(station_lm_model_summary, ~.$coefficients[['date_num', 'Std. Error']]),
                   station_rate_r2 = purrr::map_dbl(station_lm_model_summary, ~.$r.squared),
                   station_rate_p = purrr::map_dbl(station_lm_model_summary, ~.$coefficients[['date_num', "Pr(>|t|)"]]),
                   station_ci = purrr::map(station_lm_model, ~as.data.frame(confint(., parm = c("date_num"), level = 0.95))),
                   station_ci_low = purrr::map_dbl(station_ci, ~.$`2.5 %`),
                   station_ci_high =  purrr::map_dbl(station_ci, ~.$`97.5 %`),
                   station_ci_abs_value = abs(station_ci_high - station_rate),
                   date_count = purrr::map_int(data, ~dplyr::n_distinct(.x$event_date_UTC))
            )

        return(linear_rates_mh_station)
    }
}
