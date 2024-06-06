#' Plot raw pin-, arm-, or marker horizon replicate-level values
#'
#' @param data Either a data frame of SET data with 1 row per pin reading or a
#'   data frame of marker horizon data with 1 row per core measurement. For SET
#'   data, the data frame must have the following columns, named exactly:
#'   event_date_UTC, network_code, park_code, site_name, station_code,
#'   SET_direction, pin_position, and pin_height_mm. For MH data, the data frame
#'   must have the following columns, named exactly: event_date_UTC,
#'   network_code, park_code, site_name, marker_horizon_name,
#'   core_measurement_number, core_measurement_depth_mm, and established_date.
#'
#' @param data_level Level of data to plot.
#'
#'   For SET data, either "pin" or "arm". Options "pin" and "arm"
#'   show pin- or arm-level (respectively) interval change by SET direction
#'   (i.e., arm-level) at 1 or more stations.
#'
#'   For MH data, must specify "mh". Option "mh" shows marker horizon
#'   replicate-level (i.e., A, B, or C) interval change by station_code.
#'
#' @param station Station(s) to plot - required for data_level = 'pin' but
#'   optional for data_level = 'arm' or 'mh'. Refers to the 'station_code' column in the SET or marker
#'   horizon data. Can be a single station code (e.g. "M11-1") or vector of
#'   multiple stations (e.g. c("M11-1", "M11-2)).
#'
#' @param columns Number of columns to include in faceted graph
#'
#' @param pointsize Size of points; passed to `geom_point()`
#'
#' @param scales Passed to `facet_wrap`; same fixed/free options as that function
#'
#' @return a ggplot object
#'
#' @export
#'
#' @examples
#' plot_raw_data(example_sets, data_level = "pin", station = "M11-1")
#' plot_raw_data(example_sets, data_level = "arm", station = c("M11-1", "M11-2), columns = 1, pointsize = 4)
#' plot_raw_data(example_sets, data_level = "mh", station = "M11-1", scales = "free_y")

plot_raw_data <- function(data, data_level, station = NULL, columns = 2, pointsize = 2, se_line = TRUE, se_line_size = 1, scales = "fixed"){

    if(data_level == "pin") {

        if(is.null(station)) {
            stop("station must be specified for plotting raw pin data")
        }

        else {
            data %>%
                dplyr::filter(station_code %in% !!station) %>%
                mutate(site_station_arm_id = paste(park_code, site_name, station_code, paste0("arm ", SET_direction), sep = ", ")) %>%
                ggplot2::ggplot(ggplot2::aes(x = event_date_UTC, y = pin_height_mm, col = as.factor(pin_position))) +
                ggplot2::geom_point(size = pointsize) +
                ggplot2::geom_line(alpha = 0.6) +
                ggplot2::facet_wrap(~site_station_arm_id, ncol = columns, scales = scales) +
                ggplot2::labs(title = 'Pin Height (raw measurement)',
                              x = 'Date',
                              y = 'Measured pin height (mm)',
                              color = 'Pin') +
                ggplot2::theme_bw() +
                ggplot2::theme(legend.position = 'bottom')
        }

    }

    else if(data_level == "arm") {

        to_plot <- data %>%
            {
                if(is.null(station))
                    (.)
                else if(!is.null(station))
                    filter(., station_code %in% !!station)
            } %>%
            mutate(site_station_id = paste(park_code, site_name, station_code, sep = ", ")) %>%
            dplyr::group_by(network_code, park_code, site_name, station_code, SET_direction, site_station_id, event_date_UTC) %>%
            dplyr::summarize(mean = mean(pin_height_mm, na.rm = TRUE),
                             se = stats::sd(pin_height_mm, na.rm = TRUE)/sqrt(n()),
                             .groups = "drop")

        to_plot %>%
            ggplot2::ggplot(ggplot2::aes(x = event_date_UTC, y = mean, color = as.factor(SET_direction))) +
            ggplot2::geom_point(size = pointsize) +
            ggplot2::geom_line(alpha = 0.6) +
            {if(se_line) ggplot2::geom_errorbar(ggplot2::aes(x = event_date_UTC,
                                                             ymin = mean - se,
                                                             ymax = mean + se,
                                                             color = as.factor(SET_direction)), size = se_line_size
            )} +
            ggplot2::facet_wrap(~site_station_id, ncol = columns, scales = scales) +
            ggplot2::labs(title = "Pin Height (raw measurement - averaged to SET direction level)",
                          x = 'Date',
                          y = 'Mean pin height (mm)',
                          color = 'SET direction') +
            ggplot2::theme_bw() +
            ggplot2::theme(legend.position = 'bottom')
    }

    else if(data_level == "mh") {

        to_plot <- data %>%
            {
                if(is.null(station))
                    (.)
                else if(!is.null(station))
                    filter(., station_code %in% !!station)
            } %>%
            mutate(site_station_id = paste(park_code, site_name, station_code, sep = ", ")) %>%
            dplyr::group_by(network_code, park_code, site_name, station_code, site_station_id, marker_horizon_name, event_date_UTC) %>%
            dplyr::summarize(mean = mean(core_measurement_depth_mm, na.rm = TRUE),
                             se = stats::sd(core_measurement_depth_mm, na.rm = TRUE)/sqrt(n()),
                             .groups = "drop")

        to_plot %>%
            ggplot2::ggplot(ggplot2::aes(x = event_date_UTC, y = mean, color = as.factor(marker_horizon_name))) +
            ggplot2::geom_point(size = pointsize) +
            ggplot2::geom_line(alpha = 0.6) +
            {if(se_line) ggplot2::geom_errorbar(ggplot2::aes(x = event_date_UTC,
                                                             ymin = mean - se,
                                                             ymax = mean + se), size = se_line_size
            )} +
            ggplot2::facet_wrap(~site_station_id, ncol = columns, scales = scales) +
            ggplot2::labs(title = "Marker horizon depth (raw measurement - averaged to the replicate-level)",
                          x = 'Date',
                          y = 'Mean pin height (mm)',
                          color = "Marker horizon name") +
            ggplot2::theme_bw() +
            ggplot2::theme(legend.position = 'bottom')
    }

}
