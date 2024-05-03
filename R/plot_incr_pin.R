#' Plot change between readings, by pin for a single SET/station
#'
#' @param data Data frame with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, and pin_height_mm.
#'
#' @param set SET (aka station) ID to plot (required).
#'
#' @param threshold Numeric value for red horizontal lines (at +/- this value); can be used for QAQC of pin_level incremental change; defaults to 25.
#'
#' @param columns Number of columns you want in the faceted output; defaults to 4.
#'
#' @param pointsize Size of points you want (goes into the `size` argument of `ggplot2::geom_point`); defaults to 2.
#'
#' @param scales Do you want axis scales to be the same in all facets ("fixed") or to vary between facets "free_x" or "free_y" or "free" - goes into `scales` arg of `facet_wrap`; defaults to "fixed".
#'
#' @return a ggplot object
#'
#' @export
#'
#' @examples
#' plot_incr_pin(example_sets, set = "M11-1")
#' plot_incr_pin(example_sets, set = "M11-1", threshold = 5)
#' plot_incr_pin(example_sets, set = "M11-1", threshold = 5, columns = 1)

plot_incr_pin <- function(data, set, threshold = 25, columns = 2, pointsize = 2, scales = "fixed"){

    data <- calc_change_incr(data)
    data <- data$pin

    # data needs to be the $pin piece of the output from calc_change_inc
    ggplot2::ggplot(data = dplyr::filter(data, station_code == !!set),
                    ggplot2::aes(x = event_date_UTC, y = incr,
               color = as.factor(pin_position))) +
        ggplot2::geom_point(size = pointsize) +
        ggplot2::geom_hline(yintercept = threshold, col = "red", size = 1) +
        ggplot2::geom_hline(yintercept = -1*threshold, col = "red", size = 1) +
        ggplot2::facet_wrap(~SET_direction, ncol = columns, scales = scales) +
        ggplot2::labs(title = paste('Incremental Change by pin at', set),
             subtitle = paste('red lines at +/-', threshold, 'mm'),
             x = 'Date',
             y = 'Change since previous reading (mm)',
             color = 'Pin') +
        ggplot2::theme_bw() +
        ggplot2::theme(legend.position = 'bottom')
}
