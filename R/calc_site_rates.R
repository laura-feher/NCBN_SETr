#' Calculate site-level linear rates of elevation change
#'
#' @param data a data frame with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, pin_height_mm
#'
#' @return A data frame with linear regressions models, rates of change, standard errors, and confidence intervals for each site.
#'
#' @export
#'
#' @examples
#' calc_site_rates(example_sets)
#'
calc_site_rates <- function(data) {

    # first calculate cumulative change for each SET
    data <- calc_change_cumu(data)

    # use linear regression to get a rate of change for each SET
    data$set %>%
        group_by(network_code, park_code, site_name, event_date_UTC) %>%
        summarise(mean_site = mean(mean_cumu, na.rm = TRUE)) %>%
        # convert dates to decimal year since first date
        mutate(first_date = event_date_UTC[event_date_UTC == min(event_date_UTC[!is.na(mean_site)])],
               date_num = as.numeric(event_date_UTC - first_date)/365.25) %>%
        ungroup() %>%
        group_by(network_code, park_code, site_name) %>%
        nest() %>%
        mutate(site_lm_model = map(data, ~lm(mean_site ~ date_num, data = .)),
               site_lm_model_summary = map(site_lm_model, ~summary(.)),
               site_rate = map_dbl(site_lm_model, ~coefficients(.)[['date_num']]),
               se_rate = map_dbl(site_lm_model_summary, ~.$coefficients[['date_num', 'Std. Error']]),
               site_rate_r2 = map_dbl(site_lm_model_summary, ~.$r.squared),
               ci = map(site_lm_model, ~as.data.frame(confint(., parm = c("date_num"), level = 0.95))),
               ci_low = map_dbl(ci, ~.$`2.5 %`),
               ci_high =  map_dbl(ci, ~.$`97.5 %`),
               ci_abs_value = abs(ci_high - site_rate),
               ci_high =  map_dbl(ci, ~.$`97.5 %`)
        )
}
