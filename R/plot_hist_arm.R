#' Generate a histogram of pin readings by arm position
#'
#' @param data a data frame with one row per pin reading, and the following columns, named exactly: network_code, park_code, site_name, station_code, SET_direction, pin_height_mm
#' @param columns number of columns you'd like in the faceted plot
#' @param scales passed to `facet_wrap` - fixed or free?
#'
#' @return a ggplot object
#' @export
#'
#' @examples
#' plot_hist_arm(example_sets)

plot_hist_arm <- function(data, columns = 4, scales = "free_y"){

    ggplot2::ggplot(data) +
        ggplot2::geom_histogram(ggplot2::aes(pin_height_mm, fill = as.factor(SET_direction)), color = 'black') +
        ggplot2::facet_wrap(~station_code, ncol = columns, scales = scales) +
        ggplot2::labs(title = 'Histogram of raw pin heights by SET',
             subtitle = 'colored by arm position; stacked',
             x = 'Pin Height (mm)',
             fill = 'Arm Position') +
        ggplot2::theme_bw() +
        ggplot2::theme(legend.position = 'bottom')
}
