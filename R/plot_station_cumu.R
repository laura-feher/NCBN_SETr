#' Plot station-level SET and/or MH cumulative change
#'
#' @param SET_data (optional) A data frame of SET data. See details below for
#'   requirements. If both SET and MH data are supplied, plots both.
#'
#' @param MH_data (optional) A data frame of MH data. See details below for
#'   requirements. If both SET and MH data are supplied, plots both.
#'
#' @param station (optional) Plot cumulative SET or MH data from specific
#'   station(s). Refers to the 'station_code' column in the data. Can be a
#'   single station code (e.g. "M11-1") or vector of multiple stations (e.g.
#'   c("M11-1", "M11-2)).
#'
#' @param site (optional) Plot cumulative SET or MH data from specific site(s).
#'   Refers to the 'site_name' column in the data. Can be a single site name
#'   (e.g. "Marsh 11") or vector of multiple sites (e.g. c("Marsh 11", "Marsh
#'   3")).
#'
#' @param park (optional) Plot cumulative SET or MH data from specific park(s).
#'   Refers to the 'park_code' column in the data. Can be a single park code
#'   (e.g. "ASIS") or vector of multiple parks (e.g. c("ASIS", "GATE")) although
#'   it is not recommended to plot multiple parks because the individual
#'   station-level panels will be hard to see.
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
#' @description Station-level cumulative surface elevation change and vertical
#'   accretion is calculated via the function 'calc_change_cumu'. See function
#'   documentation for details.
#'
#' @details `SET_data` must be data frame of SET data with 1 row per pin reading
#'   and the following columns, named exactly: event_date_UTC, network_code,
#'   park_code, site_name, station_code, SET_direction, pin_position, and
#'   pin_height_mm.
#'
#'   `MH_data` must be a data frame of marker horizon data with 1 row per core
#'   measurement and the following columns named exactly: event_date_UTC,
#'   network_code, park_code, site_name, station_code, marker_horizon_name,
#'   core_measurement_number, core_measurement_depth_mm, and established_date.
#'
#' @return a ggplot object: x-axis is date; depending on the type of data
#'   supplied, y-axis is either (a) cumulative surface elevation change and/or
#'   (b) vertical accretion. One facet per station.
#'
#' @export
#'
#' @import ggplot2
#' @import dplyr
#' @import purrr
#'
#' @examples
#' plot_station_cumu(SET_data = example_sets)
#'
#' plot_station_cumu(SET_data = example_sets, station = c("M11-1", "M11-3"))
#'
#' plot_station_cumu(SET_data = example_sets, site = "Elders East", columns = 3, pointsize = 2)
#'
#' plot_station_cumu(MH_data = example_mh)
#'
#' plot_station_cumu(SET_data = example_sets, MH_data = example_mh)
#'
plot_station_cumu <- function(SET_data = NULL, MH_data = NULL, station = NULL, site = NULL , park = NULL, columns = 4, pointsize = 2, scales = "fixed") {

    if(!is.null(SET_data) & is.null(MH_data)) {

        # make sure SET_data is SET data
        data_type <- detect_data_type(SET_data)

        if(data_type != "SET") {
            stop(paste0("SET_data must be SET data"))
        } else {

            # if any of the select stations or sites are not in the data, return a warning
            list_stations <- SET_data %>%
                dplyr::distinct(station_code) %>%
                dplyr::pull()

            list_sites <- SET_data %>%
                dplyr::distinct(site_name) %>%
                dplyr::pull()

            list_parks <- SET_data %>%
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
            plot_df <- SET_data %>%
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

            # plot data
            plot_df %>%
                calc_change_cumu(.) %>%
                ggplot2::ggplot(., ggplot2::aes(x = event_date_UTC, y = mean_cumu)) +
                ggplot2::geom_line(col = 'lightsteelblue4') +
                ggplot2::geom_smooth(formula = y~x, se = FALSE, method = 'lm', col = 'steelblue4', linewidth = 1) +
                ggplot2::geom_errorbar(aes(x = event_date_UTC, ymin = mean_cumu - se_cumu, ymax = mean_cumu + se_cumu)) +
                ggplot2::geom_point(shape = 21, fill = 'lightsteelblue1', col = 'steelblue3', size = pointsize, alpha = 0.9) +
                ggplot2::facet_wrap(~station_code, ncol = columns, scales = scales) +
                ggplot2::labs(title = 'Cumulative surface elevation change by station', x = 'Date', y = 'Cumulative surface elevation change (mm)') +
                ggplot2::theme_classic()
        }
    } else if(is.null(SET_data) & !is.null(MH_data)) {

        # make sure MH_data is MH data
        data_type <- detect_data_type(MH_data)

        if(data_type != "MH") {
            stop(paste0("MH_data must be MH data"))
        } else {

            # if any of the select stations or sites are not in the data, return a warning
            list_stations <- MH_data %>%
                dplyr::distinct(station_code) %>%
                dplyr::pull()

            list_sites <- MH_data %>%
                dplyr::distinct(site_name) %>%
                dplyr::pull()

            list_parks <- MH_data %>%
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

            plot_df <- MH_data %>%
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

            # plot data
            plot_df %>%
                calc_change_cumu(.) %>%
                ggplot2::ggplot(., ggplot2::aes(x = event_date_UTC, y = mean_cumu)) +
                ggplot2::geom_line(col = 'indianred4') +
                ggplot2::geom_smooth(formula = y~x, se = FALSE, method = 'lm', col = 'tomato4', linewidth = 1) +
                ggplot2::geom_errorbar(aes(x = event_date_UTC, ymin = mean_cumu - se_cumu, ymax = mean_cumu + se_cumu)) +
                ggplot2::geom_point(shape = 21, fill = 'indianred1', col = 'tomato3', size = pointsize, alpha = 0.9) +
                ggplot2::facet_wrap(~station_code, ncol = columns, scales = scales) +
                ggplot2::labs(title = 'Cumulative vertical accretion by station', x = 'Date', y = 'Cumulative vertical accretion (mm)') +
                ggplot2::theme_classic()
        }
    } else if(!is.null(SET_data) & !is.null(MH_data)) {

        # mark sure SET_data is SET data
        data_type_SET <- detect_data_type(SET_data)

        # make sure MH_data is MH data
        data_type_MH <- detect_data_type(MH_data)

        if(data_type_SET != "SET") {
            stop(paste0("must be a valid SET data frame"))
        } else if(data_type_MH != "MH") {
            stop(paste0("must be a valid MH data frame"))
        } else if(data_type_SET != "SET" & data_type_MH != "MH") {
            stop(paste0("SET_data must be a valid SET data frame and MH_data must be a valid MH data frame"))
        } else {

            # if any of the select stations or sites are not in the data, return a warning
            list_stations <- SET_data %>%
                dplyr::distinct(station_code) %>%
                dplyr::pull()

            list_sites <- SET_data %>%
                dplyr::distinct(site_name) %>%
                dplyr::pull()

            list_parks <- SET_data %>%
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
            plot_df_SET <- SET_data %>%
                {
                    if(!is.null(park) & is.null(site) & is.null(station))
                        filter(., park_code %in% !!park)
                    else if(is.null(park) & !is.null(site) & is.null(station))
                        filter(., site_name %in% !!site)
                    else if(is.null(park) & is.null(site) & !is.null(station))
                        filter(., station_code %in% !!station)
                    else # if no selections are made, return plots for all stations in the data
                        .
                } %>%
                calc_change_cumu(.) %>%
                dplyr::mutate(data_type = "SET")

            plot_df_MH <- MH_data %>%
                {
                    if(!is.null(park) & is.null(site) & is.null(station))
                        filter(., park_code %in% !!park)
                    else if(is.null(park) & !is.null(site) & is.null(station))
                        filter(., site_name %in% !!site)
                    else if(is.null(park) & is.null(site) & !is.null(station))
                        filter(., station_code %in% !!station)
                    else # if no selections are made, return plots for all stations in the data
                        .
                } %>%
                calc_change_cumu(.) %>%
                dplyr::select(-established_date) %>%
                dplyr::mutate(data_type = "MH")

            plot_df <- bind_rows(plot_df_SET, plot_df_MH)

            # plot data
            ggplot2::ggplot(plot_df, ggplot2::aes(x = event_date_UTC, y = mean_cumu, group = data_type)) +
                ggplot2::geom_line(aes(color = data_type)) +
                ggplot2::geom_smooth(aes(color = data_type), formula = y~x, se = FALSE, method = 'lm', linewidth = 1) +
                ggplot2::geom_errorbar(aes(x = event_date_UTC, ymin = mean_cumu - se_cumu, ymax = mean_cumu + se_cumu)) +
                ggplot2::geom_point(aes(fill = data_type, color = data_type), shape = 21, size = pointsize, alpha = 0.9) +
                ggplot2::facet_wrap(~station_code, ncol = columns, scales = scales) +
                ggplot2::labs(title = 'Cumulative surface elevation change and vertical accretion by station', x = 'Date', y = 'Cumulative surface elevation change and vertical accretion (mm)') +
                ggplot2::theme_classic()

        }
    }
}
