#' Plot marker horizon interval change between readings
#'
#' @param data A data frame of marker horizon data. See details below for
#'   requirements.
#'
#' @param data_level Level of marker horizon data to plot. One of "mh" or
#'   "mh_station". Option "mh" shows marker horizon replicate-level (i.e., A, B,
#'   or C) interval change by station_code. Option "mh_station" shows
#'   station-level marker horizon interval change by station_code.
#'
#' @param station (optional) Plot marker horizon interval data from specific
#'   station(s). Refers to the 'station_code' column in the marker horizon data.
#'   Can be a single station code (e.g. "M11-1") or vector of multiple stations
#'   (e.g. c("M11-1", "M11-2)).
#'
#' @param site (optional) Plot marker_horizon interval data from specific
#'   site(s). Refers to the 'site_name' column in the marker horizon data. Can
#'   be a single site name (e.g. "Marsh 11") or vector of multiple sites (e.g.
#'   c("Marsh 11", "Marsh 3")).
#'
#' @param park (optional) Plot marker horizon interval data from specific
#'   park(s). Refers to the 'park_code' column in the marker horizon data. Can
#'   be a single park code (e.g. "ASIS") or vector of multiple parks (e.g.
#'   c("ASIS", "GATE")) although it is not recommended to plot multiple parks
#'   because the individual station-level panels will be hard to see.
#'
#' @param threshold Numeric value for red horizontal lines (at +/- this value);
#'   can be used for QAQC of marker horizon-level interval change; defaults to
#'   25.
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
#' @details `data` must be a data frame of marker horizon data with 1 row per
#'   core measurement and the following columns, named exactly: event_date_UTC,
#'   network_code, park_code, site_name, marker_horizon_name,
#'   core_measurement_number, core_measurement_depth_mm, and established_date.
#'
#' @return a ggplot object
#'
#' @export
#'
#' @examples
#' plot_mh_intr(example_mh, data_level = "mh_station", station = "M11-1", threshold = 5, columns = 1)
#'
plot_intr_mh <- function(data, data_level, station = NULL, site = NULL , park = NULL, threshold = 25, columns = 2, pointsize = 2, scales = "fixed"){

    # determine if the data has the correct columns for MH data
    cols <- colnames(data)

    ## conditions: have correct columns in data frame
    ## stop and give an informative message if this isn't met
    req_clms <- c("event_date_UTC", "network_code", "park_code", "site_name", "station_code", "marker_horizon_name", "core_measurement_number", "core_measurement_depth_mm", "established_date")

    if(sum(req_clms %in% names(data)) != length(req_clms)){
        stop(paste("Your data frame must have the following columns, with these names, but is missing at least one:", paste(req_clms, collapse = ", ")))
    }

    list_intr_data <- calc_change_intr(data)

    if(data_level != "mh" & data_level != "mh_station") {
        stop("data_level required: please choose either 'mh' or 'mh_station' for data_level")
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
        if(data_level == "mh") {

            intr_data <- list_intr_data$mh %>%
                mutate(site_station_marker_id = paste(park_code, site_name, station_code, marker_horizon_name, sep = ", "))

            ggplot2::ggplot(data = intr_data,
                            ggplot2::aes(x = event_date_UTC, y = intr, color = marker_horizon_name)) +
                ggplot2::geom_point(size = pointsize, show.legend = FALSE) +
                ggplot2::geom_hline(yintercept = threshold, col = "red", linewidth = 1) +
                ggplot2::geom_hline(yintercept = -1*threshold, col = "red", linewidth = 1) +
                ggplot2::facet_wrap(~site_station_marker_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = "Interval change by marker horizon replicate",
                              subtitle = paste('red lines at +/-', threshold, 'mm'),
                              x = 'Date',
                              y = 'Change since previous reading (mm)') +
                ggplot2::theme_bw() +
                ggplot2::theme(
                    legend.position = 'bottom',
                    plot.subtitle = element_text(color = "red", size = 10)
                )
        }

        else if(data_level == "mh_station") {

            intr_data <- list_intr_data$mh_station %>%
                mutate(site_station = paste(park_code, site_name, station_code, sep = ", "))

            ggplot2::ggplot(data = intr_data,
                            ggplot2::aes(x = event_date_UTC, y = mean_intr)) +
                geom_line() +
                ggplot2::geom_point(size = pointsize) +
                ggplot2::geom_hline(yintercept = threshold, col = "red", linewidth = 1) +
                ggplot2::geom_hline(yintercept = -1*threshold, col = "red", linewidth = 1) +
                ggplot2::facet_wrap(~site_station_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = "Interval change by marker-horizon station",
                              subtitle = paste('red lines at +/-', threshold, 'mm'),
                              x = 'Date',
                              y = 'Change since previous reading (mm)') +
                ggplot2::theme_bw() +
                ggplot2::theme(
                    legend.position = 'bottom',
                    plot.subtitle = element_text(color = "red", size = 10)
                )
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
        if(length(matched_site) > 0 & length(unmatched_sites) > 0) {
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

        if(data_level == "mh"){
            intr_data <- list_intr_data$mh

            to_plot <- intr_data %>%
                {
                    if(!is.null(station))
                        filter(., station_code %in% !!station)
                    else if(!is.null(site))
                        filter(., site_name %in% !!site)
                    else if(!is.null(park))
                        filter(., park_code %in% !!park)
                } %>%
                mutate(site_station_marker_id = paste(park_code, site_name, station_code, marker_horizon_name, sep = ", "))

            ggplot2::ggplot(data = to_plot,
                            ggplot2::aes(x = event_date_UTC, y = intr, color = marker_horizon_name)) +
                ggplot2::geom_point(size = pointsize, show.legend = FALSE) +
                ggplot2::geom_hline(yintercept = threshold, col = "red", linewidth = 1) +
                ggplot2::geom_hline(yintercept = -1*threshold, col = "red", linewidth = 1) +
                ggplot2::facet_wrap(~site_station_marker_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = "Interval change by marker horizon replicate",
                              subtitle = paste('red lines at +/-', threshold, 'mm'),
                              x = 'Date',
                              y = 'Change since previous reading (mm)') +
                ggplot2::theme_bw() +
                ggplot2::theme(
                    legend.position = 'bottom',
                    plot.subtitle = element_text(color = "red", size = 10)
                )
        }

        else if(data_level == "mh_station"){
            intr_data <- list_intr_data$mh_station

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

            ggplot2::ggplot(data = to_plot,
                            ggplot2::aes(x = event_date_UTC, y = mean_intr)) +
                geom_line() +
                ggplot2::geom_point(size = pointsize) +
                ggplot2::geom_hline(yintercept = threshold, col = "red", linewidth = 1) +
                ggplot2::geom_hline(yintercept = -1*threshold, col = "red", linewidth = 1) +
                ggplot2::facet_wrap(~site_station_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = "Interval Change by marker-horizon station",
                              subtitle = paste('red lines at +/-', threshold, 'mm'),
                              x = 'Date',
                              y = 'Change since previous reading (mm)') +
                ggplot2::theme_bw() +
                ggplot2::theme(
                    legend.position = 'bottom',
                    plot.subtitle = element_text(color = "red", size = 10)
                )
        }
    }
}
