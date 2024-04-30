#' Plot change between readings, by pin
#'
#' @param data data frame (e.g. the `$pin` piece of output from `calc_change_incr()`) with one row per faceting variable, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_positionr, incr. `incr` should be an already-calculated field of change since previous reading.
#' @param set SET ID to graph (required)
#' @param threshold numeric value for red horizontal lines (at +/- this value); this should be a value that would be a meaningful threshold for incremental change.
#' @param columns number of columns for faceted output
#' @param pointsize size of points you want (goes into the `size` argument of `ggplot2::geom_point`)
#' @param scales passed to `facet_wrap`; same fixed/free options as that function
#'
#' @return a ggplot object
#' @export
#'
#' @examples
#' incr_set <- calc_change_incr(example_sets)
#' plot_incr_pin(incr_set, set = "M11-1")
#' plot_incr_pin(incr_set, set = "M11-1", threshold = 5)
#' plot_incr_pin(incr_set, set = "M11-1", threshold = 5, columns = 1)

plot_incr_pin <- function(data, set, threshold = 25, columns = 2, pointsize = 2, scales = "fixed"){

    data <- data$pin

    # data needs to be the $pin piece of the output from calc_change_inc
    # names in arguments default to columns used in SETr project
    # WHY ISN'T IT SCREAMING ABOUT NO GLOBAL BINDING FOR ARM POSITION (in facet)
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
