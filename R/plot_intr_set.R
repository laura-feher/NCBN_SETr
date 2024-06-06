#' Plot SET interval change between readings
#'
#' @param data A data frame of SET data. See details below for requirements.
#'
#' @param data_level Level of SET data to plot. One of "pin", "arm", or
#'   "station". "pin" and "arm" show pin- or arm-level (respectively) interval
#'   change by SET direction (i.e., arm-level) at 1 or more stations. "station"
#'   shows station-level interval change by station at 1 or more stations.
#'
#' @param station (optional) Plot SET interval data from specific station(s).
#'   Refers to the 'station_code' column in the SET data. Can be a single
#'   station code (e.g. "M11-1") or vector of multiple stations (e.g. c("M11-1",
#'   "M11-2)).
#'
#' @param site (optional) Plot SET interval data from specific site(s). Refers
#'   to the 'site_name' column in the SET data. Can be a single site name (e.g.
#'   "Marsh 11") or vector of multiple sites (e.g. c("Marsh 11", "Marsh 3")).
#'
#' @param park (optional) Plot SET interval data from specific park(s). Refers
#'   to the 'park_code' column in the SET data. Can be a single park code (e.g.
#'   "ASIS") or vector of multiple parks (e.g. c("ASIS", "GATE")) although it is
#'   not recommended to plot multiple parks because the individual station-level
#'   panels will be hard to see.
#'
#' @param threshold Numeric value for red horizontal lines (at +/- this value);
#'   can be used for QAQC of pin-level interval change; defaults to 25.
#'
#' @param columns Number of columns you want in the faceted output; defaults to
#'   4.
#'
#' @param pointsize Size of points you want (goes into the `size` argument of
#'   `ggplot2::geom_point`); defaults to 2.
#'
#' @param scales Do you want axis scales to be the same in all facets ("fixed")
#'   or to vary between facets "free_x" or "free_y" or "free" - goes into
#'   `scales` arg of `facet_wrap`; defaults to "fixed".
#'
#' @description Station-level interval change is calculated via the function
#'   'calc_change_intr' - see function documentation for details.
#'
#' @details `data` must be a data frame of SET data with 1 row per pin reading
#'   and the following columns, named exactly: event_date_UTC, network_code,
#'   park_code, site_name, station_code, SET_direction, pin_position, and
#'   pin_height_mm.
#'
#' @return a ggplot object
#'
#' @export
#'
#' @examples
#' plot_set_intr(example_sets, data_level = "pin", station = "M11-1")
#' plot_set_intr(example_sets, data_level = "arm", site = c("Marsh 11", "Marsh 3"), threshold = 5)
#' plot_set_intr(example_sets, data_level = "arm", park = "ASIS")
#' plot_set_intr(example_sets, data_level = "station", park = "ASIS")
#'
plot_intr_set <- function(data, data_level, station = NULL, site = NULL , park = NULL, threshold = 25, columns = 2, pointsize = 2, scales = "fixed"){

    # determine if the data has the correct columns for SET data
    cols <- colnames(data)

    ## conditions: have correct columns in data frame
    ## stop and give an informative message if this isn't met
    req_clms <- c("event_date_UTC", "network_code", "park_code", "site_name", "station_code", "SET_direction", "pin_position", "pin_height_mm")

    if(sum(req_clms %in% names(data)) != length(req_clms)){
        stop(paste("Your data frame must have the following columns, with these names, but is missing at least one:", paste(req_clms, collapse = ", ")))
    }

    list_intr_data <- calc_change_intr(data)

    if(data_level != "pin" & data_level != "arm" & data_level != "station") {
        stop("data_level required: please choose either 'pin, 'arm', or 'station' for data_level")
    }

    if(is.null(station) & is.null(site) & is.null(park)){

        if(data_level == "pin"){
            intr_data <- list_intr_data$pin %>%
                mutate(site_station_arm_id = paste(park_code, site_name, station_code, paste0("arm ", SET_direction)))

            ggplot2::ggplot(data = intr_data,
                            ggplot2::aes(x = event_date_UTC, y = intr,
                                         color = as.factor(pin_position))) +
                ggplot2::geom_point(size = pointsize) +
                ggplot2::geom_hline(yintercept = threshold, col = "red", linewidth = 1) +
                ggplot2::geom_hline(yintercept = -1*threshold, col = "red", linewidth = 1) +
                ggplot2::facet_wrap(~site_station_arm_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = 'Interval change by pin',
                              subtitle = paste('red lines at +/-', threshold, 'mm'),
                              x = 'Date',
                              y = 'Change since previous reading (mm)',
                              color = 'Pin') +
                ggplot2::theme_bw() +
                ggplot2::theme(
                    legend.position = 'bottom',
                    plot.subtitle = element_text(color = "red", size = 10)
                )
        }

        else if(data_level == "arm"){
            intr_data <- list_intr_data$arm %>%
                mutate(site_station_id = paste(park_code, site_name, station_code))

            ggplot2::ggplot(data = intr_data, ggplot2::aes(x = event_date_UTC,
                                                           y = mean_intr,
                                                           color = as.factor(SET_direction))) +
                ggplot2::geom_point(size = pointsize) +
                ggplot2::geom_hline(yintercept = threshold, col = "red", linewidth = 1) +
                ggplot2::geom_hline(yintercept = -1*threshold, col = "red", linewidth = 1) +
                ggplot2::facet_wrap(~site_station_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = "Interval change by SET direction",
                              subtitle = paste('red lines at +/-', threshold, 'mm'),
                              x = 'Date',
                              y = 'Change since previous reading (mm)',
                              color = 'SET direction') +
                ggplot2::theme_bw() +
                ggplot2::theme(legend.position = 'bottom',
                               plot.subtitle = element_text(color = "red", size = 10))
        }

        else if(data_level == "station"){
            intr_data <- list_intr_data$station %>%
                mutate(site_id = paste(park_code, site_name))

            ggplot2::ggplot(data = intr_data,
                            ggplot2::aes(x = event_date_UTC,
                                         y = mean_intr,
                                         color = station_code)) +
                ggplot2::geom_point(size = pointsize) +
                ggplot2::geom_hline(yintercept = threshold, col = "red", linewidth = 1) +
                ggplot2::geom_hline(yintercept = -1*threshold, col = "red", linewidth = 1) +
                ggplot2::facet_wrap(~site_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = "Interval change by station",
                              subtitle = paste('red lines at +/-', threshold, 'mm'),
                              x = 'Date',
                              y = 'Change since previous reading (mm)',
                              color = "Station code") +
                ggplot2::theme_bw() +
                ggplot2::theme(legend.position = 'bottom',
                               plot.subtitle = element_text(color = "red", size = 10))
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

        if(data_level == "pin"){
            to_plot <- intr_data %>%
                {
                    if(!is.null(station))
                        filter(., station_code %in% !!station)
                    else if(!is.null(site))
                        filter(., site_name %in% !!site)
                    else if(!is.null(park))
                        filter(., park_code %in% !!park)
                } %>%
                mutate(site_station_arm_id = paste(park_code, site_name, station_code, paste0("arm ", SET_direction), sep = ", "))

            ggplot2::ggplot(data = to_plot,
                            ggplot2::aes(x = event_date_UTC, y = intr,
                                         color = as.factor(pin_position))) +
                ggplot2::geom_point(size = pointsize) +
                ggplot2::geom_hline(yintercept = threshold, col = "red", linewidth = 1) +
                ggplot2::geom_hline(yintercept = -1*threshold, col = "red", linewidth = 1) +
                ggplot2::facet_wrap(~site_station_arm_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = 'Interval change by pin',
                              subtitle = paste('red lines at +/-', threshold, 'mm'),
                              x = 'Date',
                              y = 'Change since previous reading (mm)',
                              color = 'Pin') +
                ggplot2::theme_bw() +
                ggplot2::theme(
                    legend.position = 'bottom',
                    plot.subtitle = element_text(color = "red", size = 10)
                )
        }

        else if(data_level == "arm"){
            intr_data <- list_intr_data$arm

            to_plot <- intr_data %>%
                {
                    if(!is.null(station))
                        filter(., station_code %in% !!station)
                    else if(!is.null(site))
                        filter(., site_name %in% !!site)
                    else if(!is.null(park))
                        filter(., park_code %in% !!park)
                } %>%
                mutate(site_station_id = paste(park_code, site_name, station_code, sep = ", "))

            ggplot2::ggplot(data = to_plot, ggplot2::aes(x = event_date_UTC,
                                                         y = mean_intr,
                                                         color = as.factor(SET_direction))) +
                ggplot2::geom_point(size = pointsize) +
                ggplot2::geom_hline(yintercept = threshold, col = "red", linewidth = 1) +
                ggplot2::geom_hline(yintercept = -1*threshold, col = "red", linewidth = 1) +
                ggplot2::facet_wrap(~site_station_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = "Interval change by SET direction",
                              subtitle = paste('red lines at +/-', threshold, 'mm'),
                              x = 'Date',
                              y = 'Change since previous reading (mm)',
                              color = 'SET direction') +
                ggplot2::theme_bw() +
                ggplot2::theme(legend.position = 'bottom',
                               plot.subtitle = element_text(color = "red", size = 10))
        }

        else if(data_level == "station"){
            intr_data <- list_intr_data$station

            to_plot <- intr_data %>%
                {
                    if(!is.null(station))
                        filter(., station_code %in% !!station)
                    else if(!is.null(site))
                        filter(., site_name %in% !!site)
                    else if(!is.null(park))
                        filter(., park_code %in% !!park)
                } %>%
                mutate(site_id = paste(park_code, site_name, sep = ", "))

            ggplot2::ggplot(data = to_plot,
                            ggplot2::aes(x = event_date_UTC,
                                         y = mean_intr,
                                         color = station_code)) +
                ggplot2::geom_point(size = pointsize) +
                ggplot2::geom_hline(yintercept = threshold, col = "red", linewidth = 1) +
                ggplot2::geom_hline(yintercept = -1*threshold, col = "red", linewidth = 1) +
                ggplot2::facet_wrap(~site_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = "Interval change by station",
                              subtitle = paste('red lines at +/-', threshold, 'mm'),
                              x = 'Date',
                              y = 'Change since previous reading (mm)',
                              color = "Station code") +
                ggplot2::theme_bw() +
                ggplot2::theme(legend.position = 'bottom',
                               plot.subtitle = element_text(color = "red", size = 10))
        }
    }
}
