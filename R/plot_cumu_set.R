#' Plot SET cumulative change
#'
#' @param data A data frame of SET data. See details below for requirements.
#'
#' @param data_level Level of SET data to plot. One of "arm" or "station". "arm"
#'   shows arm-level cumulative change at 1 or more stations. "station" shows
#'   station-level interval change by station_code at 1 or more stations.
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
#' @param columns Number of columns you want in the faceted output; defaults to
#'   4.
#'
#' @param pointsize Size of points you want (goes into the `size` argument of
#'   `ggplot2::geom_point`); defaults to 3.5.
#'
#' @param scales Do you want axis scales to be the same in all facets ("fixed")
#'   or to vary between facets "free_x" or "free_y" or "free" - goes into
#'   `scales` arg of `facet_wrap`; defaults to "free_y".
#'
#' @description Arm- and station-level cumulative change is calculated via the function
#'   'calc_change_cumu'. Linear rates of change are calculated via the function
#'   'calc_linear_rates'. See function documentation for details.
#'
#' @details `data` must be data frame of SET data with 1 row per pin reading and
#'   the following columns, named exactly: event_date_UTC, network_code,
#'   park_code, site_name, station_code, SET_direction, pin_position, and
#'   pin_height_mm.
#'
#' @return a ggplot object: x-axis is date; y-axis is the average of the 36 pin
#'   heights' difference from baseline (first measurement). One facet per
#'   station.
#'
#' @export
#'
#' @examples
#' plot_cumu_set(example_sets, data_level = "arm", site = "Elders East", columns = 3, pointsize = 2)
#' plot_cumu_set(example_sets, data_level = "station")
#'
plot_cumu_set <- function(data, data_level, station = NULL, site = NULL , park = NULL, columns = 4, pointsize = 2, scales = "fixed") {

    # determine if the data has the correct columns for SET data
    cols <- colnames(data)

    ## conditions: have correct columns in data frame
    ## stop and give an informative message if this isn't met
    req_clms <- c("event_date_UTC", "network_code", "park_code", "site_name", "station_code", "SET_direction", "pin_position", "pin_height_mm")

    if(sum(req_clms %in% names(data)) != length(req_clms)){
        stop(paste("Your data frame must have the following columns, with these names, but is missing at least one:", paste(req_clms, collapse = ", ")))
    }

    list_cumu_data <- calc_change_cumu(data)

    if(data_level != "arm" & data_level != "station") {
        stop("data_level required: please choose either 'arm' or 'station' for data_level")
    }

    list_stations <- data %>%
        distinct(station_code) %>%
        pull()

    list_sites <- data %>%
        distinct(site_name) %>%
        pull()

    list_parks <- data %>%
        distinct(park_code) %>%
        pull()

    if(is.null(station) & is.null(site) & is.null(park)) {
        if(data_level == "arm"){

            cumu_data <- list_cumu_data$arm %>%
                mutate(site_station_id = paste(park_code, site_name, station_code, sep = ", "))

            ggplot2::ggplot(cumu_data, ggplot2::aes(x = event_date_UTC, y = mean_cumu, col = as.factor(SET_direction))) +
                ggplot2::geom_point(size = pointsize) +
                ggplot2::geom_line() +
                ggplot2::facet_wrap(~site_station_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = "Cumulative surface elevation change by SET direction",
                              x = 'Date',
                              y = 'Cumulative surface elevation change (mm)',
                              color = "SET direction") +
                ggplot2::theme_bw() +
                ggplot2::theme(legend.position = 'bottom')

        }
        else if(data_level == "station"){

            cumu_data <- list_cumu_data$station %>%
                mutate(site_station_id = paste(park_code, site_name, station_code, sep = ", "))

            rates <- calc_linear_rates(data) %>%
                mutate(site_station_id = paste(park_code, site_name, station_code, sep = ", "))

            ggplot2::ggplot(cumu_data, ggplot2::aes(x = event_date_UTC, y = mean_cumu)) +
                ggplot2::geom_line(col = 'lightsteelblue4') +
                ggplot2::geom_smooth(se = FALSE, method = 'lm',
                                     col = 'steelblue4', linewidth = 1) +
                ggplot2::geom_point(shape = 21,
                                    fill = 'lightsteelblue1', col = 'steelblue3',
                                    size = pointsize, alpha = 0.9) +
                ggplot2::geom_text(
                    data = rates,
                    aes(x = structure(Inf, class = "Date"), y = Inf, label =
                            paste("rate:", format(round(station_rate, 2), nsmall = 2), "+",
                                  format(round(station_se_rate, 2), nsmall = 2), "\n" , "r2:",
                                  format(round(station_rate_r2, 2), nsmall = 2), sep = " ")),
                    hjust = 1,
                    vjust = 2) +
                ggplot2::facet_wrap(~site_station_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = 'Cumulative surface elevation change by station',
                              x = 'Date',
                              y = 'Cumulative surface elevation change (mm)') +
                ggplot2::theme_classic()
        }
    }

    else {

        # if any stations/sites/parks are not found, print a warning but plot the stations/sites/parks that are found
        # if all stations/sites/parks are not found, stop on error

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

        if(data_level == "arm"){
            cumu_data <- list_cumu_data$arm

            to_plot <- cumu_data %>%
                {
                    if(!is.null(station))
                        filter(., station_code %in% !!station)
                    else if(!is.null(site))
                        filter(., site_name %in% !!site)
                    else if(!is.null(park))
                        filter(., park_code %in% !!park)
                } %>%
                mutate(site_station_id = paste(park_code, site_name, station_code, sep = ", "))

            ggplot2::ggplot(to_plot, ggplot2::aes(x = event_date_UTC, y = mean_cumu, col = as.factor(SET_direction))) +
                ggplot2::geom_point(size = pointsize) +
                ggplot2::geom_line() +
                ggplot2::facet_wrap(~site_station_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = "Cumulative surface elevation change by SET direction",
                              x = 'Date',
                              y = 'Cumulative surface elevation change (mm)',
                              color = "SET direction") +
                ggplot2::theme_bw() +
                ggplot2::theme(legend.position = 'bottom')
        }

        else if(data_level == "station"){
            cumu_data <- list_cumu_data$station

            to_plot <- cumu_data %>%
                {
                    if(!is.null(station))
                        filter(., station_code %in% !!station)
                    else if(!is.null(site))
                        filter(., site_name %in% !!site)
                    else if(!is.null(park))
                        filter(., park_code %in% !!park)
                } %>%
                mutate(site_station_id = paste(park_code, site_name, station_code, sep = ", "))

            # calculate linear rates of change for each station
            rates <- calc_linear_rates(data) %>%
                {
                    if(!is.null(station))
                        filter(., station_code %in% !!station)
                    else if(!is.null(site))
                        filter(., site_name %in% !!site)
                    else if(!is.null(park))
                        filter(., park_code %in% !!park)
                } %>%
                mutate(site_station_id = paste(park_code, site_name, station_code, sep = ", "))

            ggplot2::ggplot(to_plot, ggplot2::aes(x = event_date_UTC, y = mean_cumu)) +
                ggplot2::geom_line(col = 'lightsteelblue4') +
                ggplot2::geom_smooth(se = FALSE, method = 'lm',
                                     col = 'steelblue4', linewidth = 1) +
                ggplot2::geom_point(shape = 21,
                                    fill = 'lightsteelblue1', col = 'steelblue3',
                                    size = pointsize, alpha = 0.9) +
                ggplot2::geom_text(
                    data = rates,
                    aes(x = structure(Inf, class = "Date"), y = Inf, label =
                            paste("rate:", format(round(station_rate, 2), nsmall = 2), "+",
                                  format(round(station_se_rate, 2), nsmall = 2), "\n" , "r2:",
                                  format(round(station_rate_r2, 2), nsmall = 2), sep = " ")),
                    hjust = 1,
                    vjust = 2) +
                ggplot2::facet_wrap(~site_station_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = 'Cumulative surface elevation change by station',
                              x = 'Date',
                              y = 'Cumulative surface elevation change (mm)') +
                ggplot2::theme_classic()
        }
    }
}
