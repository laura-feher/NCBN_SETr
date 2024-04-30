calc_set_rates <- function(data) {

    # first calculate cumulative change for each SET
    data <- calc_change_cumu(data)

    # use linear regression to get a rate of change for each SET
    data$set %>%
        group_by(network_code, park_code, site_name, station_code) %>%
        # convert dates to decimal year since first date
        mutate(first_date = event_date_UTC[event_date_UTC == min(event_date_UTC[!is.na(mean_cumu)])],
               date_num = as.numeric(event_date_UTC - first_date)/365.25) %>%
        nest() %>%
        mutate(set_lm_model = map(data, ~lm(mean_cumu ~ date_num, data = .)),
               set_lm_model_summary = map(set_lm_model, ~summary(.)),
               set_rate = map_dbl(set_lm_model, ~coefficients(.)[['date_num']]),
               se_rate = map_dbl(set_lm_model_summary, ~.$coefficients[['date_num', 'Std. Error']]),
               ci = map(set_lm_model, ~as.data.frame(confint(., parm = c("date_num"), level = 0.95))),
               ci_low = map_dbl(ci, ~.$`2.5 %`),
               ci_high =  map_dbl(ci, ~.$`97.5 %`),
               ci_abs_value = abs(ci_high - set_rate)
               )
}
