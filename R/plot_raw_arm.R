#' Plot raw pin measurements, first averaged to SET_direction level, by date
#'
#' @param data a data frame with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_height_mm
#' @param columns number of columns for the faceted graph
#' @param pointsize size of points for `geom_point()` layer
#' @param sdline logical; include error bars for +/- one standard deviation?
#' @param sdlinesize size for width of error bars
#' @param scales passed to `facet_wrap`; same fixed/free options as that function
#'
#' @return a ggplot object
#' @export
#'
#' @examples
#' plot_raw_arm(example_sets)
#' plot_raw_arm(example_sets, columns = 1, pointsize = 3)
#' plot_raw_arm(example_sets, sdline = FALSE)

plot_raw_arm <- function(data, columns = 4, pointsize = 2, sdline = TRUE, sdlinesize = 1, scales = "free_y"){
    data %>%
        dplyr::group_by(network_code, park_code, site_name, station_code, SET_direction, event_date_UTC) %>%
        dplyr::summarize(mean = mean(pin_height_mm, na.rm = TRUE),
                  sd = stats::sd(pin_height_mm, na.rm = TRUE)) %>%
        ggplot2::ggplot(ggplot2::aes(x = event_date_UTC, y = mean, color = as.factor(SET_direction))) +
        ggplot2::geom_point(size = pointsize) +
        ggplot2::geom_line(alpha = 0.6) +
        {if(sdline) ggplot2::geom_errorbar(ggplot2::aes(x = event_date_UTC,
                                      ymin = mean - sd,
                                      ymax = mean + sd,
                                      color = as.factor(SET_direction)
        ),
        size = sdlinesize
        )} +
        ggplot2::facet_wrap(~station_code, ncol = columns, scales = scales) +
        ggplot2::labs(title = 'Pin Height (raw measurement; averaged to SET direction level)',
             x = 'Date',
             y = 'Mean pin height (mm)',
             color = 'SET direction') +
        ggplot2::theme_bw() +
        ggplot2::theme(legend.position = 'bottom')
}
