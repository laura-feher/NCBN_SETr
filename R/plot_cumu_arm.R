#' Make a graph of change over time by arm position
#'
#' x-axis is date; y-axis is the average of the 9 pin heights' difference from baseline (first measurement) for each arm. One facet per SET/station id.
#'
#' @param data Data frame with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, and pin_height_mm.
#'
#' @param columns Number of columns you want in the faceted output; defaults to 4.
#'
#' @param pointsize Size of points you want (goes into the `size` argument of `ggplot2::geom_point`); defaults to 2.
#'
#' @param scales Do you want axis scales to be the same in all facets ("fixed") or to vary between facets "free_x" or "free_y" or "free" - goes into `scales` arg of `facet_wrap`; defaults to "free_y".
#'
#' @return a ggplot object
#'
#' @export
#'
#' @examples
#' plot_cumu_arm(example_sets)
#' plot_cumu_arm(example_sets, columns = 1, pointsize = 2)

plot_cumu_arm <- function(data, columns = 4, pointsize = 2, scales = "fixed") {

    # first calculate cumulative change for each SET
    data <- calc_change_cumu(data)
    data <- data$arm

    # data needs to be the $arm piece of the output from calc_change_cumu
    ggplot2::ggplot(data, ggplot2::aes(x = event_date_UTC, y = mean_cumu, col = as.factor(SET_direction))) +
        ggplot2::geom_point(size = pointsize) +
        ggplot2::geom_line() +
        ggplot2::facet_wrap(~station_code, ncol = columns, scales = scales) +
        ggplot2::labs(title = 'Cumulative Change by arm position',
             x = 'Date',
             y = 'Change since first reading (mm)',
             color = "SET direction") +
        ggplot2::theme_bw() +
        ggplot2::theme(legend.position = 'bottom')
}
