#' Calculate station-level linear rates of change from SET or MH data
#'
#' @param data A data frame of either SET data or MH data. See details below for
#'   requirements.
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
#' @return For SET data, returns a tibble of station-level rates of surface
#'   elevation change.
#'
#'   For MH data, returns a tibble of station-level rates of surface accretion.
#'
#' @note Stations with fewer than 3 measurement dates are excluded from the
#'   calculation of rates. Stations from CACO with unexpected instrument/pin
#'   changes are also excluded (GUT1-3, HH1-9, HighToss1-3, Old N1-4, and
#'   Phrag1-3).
#'
#' @export
#'
#' @examples
#' calc_linear_rates(example_sets)
#'
calc_linear_rates <- function(data){

    # determine if the data is SET or MH
    cols <- colnames(data)

    if("pin_height_mm" %in% cols){

        # first calculate cumulative change for each station
        data_cumu <- calc_change_cumu(data)

        exclude_set_stations <- data.frame(
            station = c(rep("GUT", 3), rep("HH", 9), rep("HighToss", 3), rep("Old N", 4), rep("Phrag", 3))
        ) %>%
            group_by(station) %>%
            mutate(station_number = seq(1:length(station)),
                   station_code = paste0(station, station_number)) %>%
            pull(station_code)

        # use linear regression to get a rate of change for each station
        linear_rates_set_station <- data_cumu$station %>%
            group_by(network_code, park_code, site_name, station_code) %>%
            mutate(date_count = n_distinct(event_date_UTC)) %>%
            filter(!station_code %in% exclude_set_stations & # dont calc rates for CACO stations with instrument changes
                    date_count >= 3) %>% # limit calculation of rates to stations with at least 3 measurements - this is the min # needed to calculate a linear rate
            select(-date_count) %>%
            # convert dates to decimal year since first date
            mutate(first_date = event_date_UTC[event_date_UTC == min(event_date_UTC[!is.na(mean_cumu)])],
                   date_num = as.numeric(event_date_UTC - first_date)/365.25) %>%
            nest() %>%
            mutate(station_lm_model = map(data, ~lm(mean_cumu ~ date_num, data = .)),
                   station_lm_model_summary = map(station_lm_model, ~summary(.)),
                   station_rate = map_dbl(station_lm_model, ~coefficients(.)[['date_num']]),
                   station_se_rate = map_dbl(station_lm_model_summary, ~.$coefficients[['date_num', 'Std. Error']]),
                   station_rate_r2 = map_dbl(station_lm_model_summary, ~.$r.squared),
                   station_rate_p = map_dbl(station_lm_model_summary, ~.$coefficients[['date_num', 'Pr(>|t|)']]),
                   station_ci = map(station_lm_model, ~as.data.frame(confint(., parm = c("date_num"), level = 0.95))),
                   station_ci_low = map_dbl(station_ci, ~.$`2.5 %`),
                   station_ci_high =  map_dbl(station_ci, ~.$`97.5 %`),
                   station_ci_abs_value = abs(station_ci_high - station_rate),
                   date_count = map_int(data, ~n_distinct(.x$event_date_UTC))
            )

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

        # linear_rates_set_site <- data_cumu$station %>%
        #     group_by(network_code, park_code, site_name, station_code) %>%
        #     mutate(date_count = n_distinct(event_date_UTC)) %>%
        #     filter(!station_code %in% exclude_set_stations & # dont calc rates for CACO stations with instrument changes
        #                date_count >= 3) %>% # limit calculation of rates to stations with at least 3 measurements - this is the min # needed to calculate a linear rate
        #     select(-date_count) %>%
        #     group_by(network_code, park_code, site_name, event_date_UTC) %>%
        #     summarise(mean_site = mean(mean_cumu, na.rm = TRUE)) %>%
        #     # convert dates to decimal year since first date
        #     mutate(first_date = event_date_UTC[event_date_UTC == min(event_date_UTC[!is.na(mean_site)])],
        #            date_num = as.numeric(event_date_UTC - first_date)/365.25) %>%
        #     ungroup() %>%
        #     group_by(network_code, park_code, site_name) %>%
        #     nest() %>%
        #     mutate(site_lm_model = map(data, ~lm(mean_site ~ date_num, data = .)),
        #            site_lm_model_summary = map(site_lm_model, ~summary(.)),
        #            site_rate = map_dbl(site_lm_model, ~coefficients(.)[['date_num']]),
        #            site_se_rate = map_dbl(site_lm_model_summary, ~.$coefficients[['date_num', 'Std. Error']]),
        #            site_rate_r2 = map_dbl(site_lm_model_summary, ~.$r.squared),
        #            site_rate_p = map_dbl(site_lm_model_summary, ~.$coefficients[['date_num', "Pr(>|t|)"]]),
        #            site_ci = map(site_lm_model, ~as.data.frame(confint(., parm = c("date_num"), level = 0.95))),
        #            site_ci_low = map_dbl(site_ci, ~.$`2.5 %`),
        #            site_ci_high =  map_dbl(site_ci, ~.$`97.5 %`),
        #            site_ci_abs_value = abs(site_ci_high - site_rate),
        #            date_count = map_int(data, ~n_distinct(.x$event_date_UTC))
        #     )

        #return(list(set_station_rates = linear_rates_set_station, set_site_rates = linear_rates_set_site))
        return(linear_rates_set_station)
    }

    else if("core_measurement_depth_mm" %in% cols){

        # first calculate cumulative change for each station
        data_cumu <- calc_change_cumu(data)

        # use linear regression to get a rate of change for each station
        linear_rates_mh_station <- data_cumu$mh_station %>%
            group_by(network_code, park_code, site_name, station_code) %>%
            # find stations where established_date is not the first row
            mutate(first_date = event_date_UTC[event_date_UTC == min(event_date_UTC[!is.na(mean_cumu)])],
                   first_date_match = if_else(first_date == established_date, "y", "n")) %>%
            group_modify(~{
                if(all(.x$first_date_match == "y")) # if established_date = first row, do nothing
                    .x
                else if(any(.x$first_date_match == "n")) # if established date is not first row, add a blank row
                    add_row(.x, first_date_match = "n", .before = 0)
            }) %>%
            mutate(across(c(mean_cumu, sd_cumu, se_cumu), # fill in mean, sd, and se, columns with 0 for the blank rows
                          ~if_else(if_all(.cols = c(
                              event_date_UTC,
                              established_date,
                              mean_cumu,
                              sd_cumu,
                              se_cumu,
                              first_date),
                                          .f = is.na),
                                       0,
                                       mean_cumu))) %>%
            group_by(network_code, park_code, site_name, station_code) %>%
            fill(established_date, .direction = "up") %>% # fill established date in new first rows using the station's established date value in other rows
            mutate(first_date = if_else(
                first_date_match == "n",
                established_date,
                first_date
            ),
            event_date_UTC = if_else( # fill event_date_UTC in new first rows using the station's established date
                is.na(event_date_UTC) & first_date_match == "n" & mean_cumu == 0,
                established_date,
                event_date_UTC
            )) %>%
            mutate(date_count = n_distinct(event_date_UTC)) %>%
            filter(date_count >= 3) %>% # limit calculation of rates to sites with at least 3 measurements - this is the min # needed to calculate a linear rate
            select(-c(first_date_match, date_count)) %>%

            # convert dates to decimal year since first date
            mutate(date_num = as.numeric(event_date_UTC - first_date)/365.25) %>%
            nest() %>%
            mutate(station_lm_model = map(data, ~lm(mean_cumu ~ date_num, data = .)),
                   station_lm_model_summary = map(station_lm_model, ~summary(.)),
                   station_rate = map_dbl(station_lm_model, ~coefficients(.)[['date_num']]),
                   station_se_rate = map_dbl(station_lm_model_summary, ~.$coefficients[['date_num', 'Std. Error']]),
                   station_rate_r2 = map_dbl(station_lm_model_summary, ~.$r.squared),
                   station_rate_p = map_dbl(station_lm_model_summary, ~.$coefficients[['date_num', "Pr(>|t|)"]]),
                   station_ci = map(station_lm_model, ~as.data.frame(confint(., parm = c("date_num"), level = 0.95))),
                   station_ci_low = map_dbl(station_ci, ~.$`2.5 %`),
                   station_ci_high =  map_dbl(station_ci, ~.$`97.5 %`),
                   station_ci_abs_value = abs(station_ci_high - station_rate),
                   date_count = map_int(data, ~n_distinct(.x$event_date_UTC))
            )

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

        # linear_rates_mh_site <- linear_rates_mh_station %>%
        #     select(network_code, park_code, site_name, station_code, data) %>%
        #     unnest(data) %>%
        #     group_by(network_code, park_code, site_name, established_date, event_date_UTC) %>%
        #     summarise(mean_cumu = mean(mean_cumu, na.rm = T),
        #               sd_cumu = sd(mean_cumu, na.rm = T),
        #               se_cumu = sd(mean_cumu, na.rm = T)/sqrt(length(!is.na(mean_cumu)))) %>%
        #     # convert dates to decimal year since first date
        #     mutate(first_date = event_date_UTC[event_date_UTC == min(event_date_UTC[!is.na(mean_site)])],
        #            date_num = as.numeric(event_date_UTC - first_date)/365.25,
        #            date_count = n_distinct(event_date_UTC)) %>%
        #     filter(date_count >= 3) %>% # limit calculation of rates to sites with at least 3 measurements - this is the min # needed to calculate a linear rate
        #     nest() %>%
        #     mutate(site_lm_model = map(data, ~lm(mean_cumu ~ date_num, data = .)),
        #            site_lm_model_summary = map(site_lm_model, ~summary(.)),
        #            site_rate = map_dbl(site_lm_model, ~coefficients(.)[['date_num']]),
        #            site_se_rate = map_dbl(site_lm_model_summary, ~.$coefficients[['date_num', 'Std. Error']]),
        #            site_rate_r2 = map_dbl(site_lm_model_summary, ~.$r.squared),
        #            site_rate_p = map_dbl(site_lm_model_summary, ~.$coefficients[['date_num', "Pr(>|t|)"]]),
        #            site_ci = map(site_lm_model, ~as.data.frame(confint(., parm = c("date_num"), level = 0.95))),
        #            site_ci_low = map_dbl(site_ci, ~.$`2.5 %`),
        #            site_ci_high =  map_dbl(site_ci, ~.$`97.5 %`),
        #            site_ci_abs_value = abs(site_ci_high - site_rate),
        #            date_count = map_int(data, ~n_distinct(.x$event_date_UTC))
        #     )
        #return(list(mh_station_rates = linear_rates_mh_station, mh_site_rates = linear_rates_mh_site))
        return(linear_rates_mh_station)
    }
}
