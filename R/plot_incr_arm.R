#' Plot change between readings, by SET_direction (i.e., arm)
#'
#' @param data Data frame with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, and pin_height_mm.
#'
#' @param set optional SET (aka station) ID if you only want to look at one SET; default is to graph all SETs.
#'
#' @param threshold Numeric value for red horizontal lines (at +/- this value); can be used for QAQC of arm_level incremental change; defaults to 25.
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
#' plot_incr_arm(example_sets)
#' plot_incr_arm(example_sets, threshold = 5, columns = 1)
#' plot_incr_arm(example_sets, set = "M11-1", threshold = 5)

plot_incr_arm <- function(data, set = NULL, threshold = 25, columns = 4,
                          pointsize = 2, scales = "fixed"){

    data <- calc_change_incr(data)
    data <- data$arm

    # data needs to be the $arm piece of the output from calc_change_inc
    if(is.null(set)){
        to_plot <- data
        plot_title <- 'Incremental Change by arm'
    }
    else{
        to_plot <- data %>%
            dplyr::filter(station_code == !!set)
        plot_title <- paste('Incremental Change by SET direction at', set)
    }

    ggplot2::ggplot(data = to_plot, ggplot2::aes(x = event_date_UTC,
                                          y = mean_incr,
                                          color = as.factor(SET_direction))) +
        ggplot2::geom_point(size = pointsize) +
        ggplot2::geom_hline(yintercept = threshold, col = "red", size = 1) +
        ggplot2::geom_hline(yintercept = -1*threshold, col = "red", size = 1) +
        ggplot2::facet_wrap(~station_code, ncol = columns, scales = scales) +
        ggplot2::labs(title = plot_title,
             subtitle = paste('red lines at +/-', threshold, 'mm'),
             x = 'Date',
             y = 'Change since previous reading (mm)',
             color = 'SET direction') +
        ggplot2::theme_bw() +
        ggplot2::theme(legend.position = 'bottom')
}
