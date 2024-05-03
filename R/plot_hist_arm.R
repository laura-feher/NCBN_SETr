#' Generate a histogram of pin readings by arm position
#'
#' @param data Data frame with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, and pin_height_mm.
#'
#' @param columns Number of columns you want in the faceted output; defaults to 4.
#'
#' @param scales Do you want axis scales to be the same in all facets ("fixed") or to vary between facets "free_x" or "free_y" or "free" - goes into `scales` arg of `facet_wrap`; defaults to "free_y".
#'
#' @return a ggplot object
#'
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
