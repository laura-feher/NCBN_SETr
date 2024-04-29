#' Plot raw pin readings for a single SET, faceted by SET direction
#'
#' @param data a data frame with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, station_code, SET_direction, pin_height_mm
#' @param set character string for the SET you wish to examine
#' @param columns number of columns to include in faceted graph
#' @param pointsize size of points; passed to `geom_point()`
#' @param scales passed to `facet_wrap`; same fixed/free options as that function
#'
#' @return a ggplot object
#' @export
#'
#' @examples
#' plot_raw_pin(example_sets, "NCBN_ASIS_M11-1")
#' plot_raw_pin(example_sets, "NCBN_ASIS_M11-1", columns = 1, pointsize = 4)
#' plot_raw_pin(example_sets, "NCBN_ASIS_M11-1", scales = "free_y")

plot_raw_pin <- function(data, set, columns = 2, pointsize = 2, scales = "fixed"){
    data %>%
        dplyr::mutate(set_id = paste(network_code, park_code, station_code, sep = "_")) %>%
        dplyr::filter(set_id == !!set) %>%
        dplyr::group_by(set_id, SET_direction, pin_position, event_date_UTC) %>%
        ggplot2::ggplot(ggplot2::aes(x = event_date_UTC, y = pin_height_mm, col = as.factor(pin_position))) +
        ggplot2::geom_point(size = pointsize) +
        ggplot2::geom_line(alpha = 0.6) +
        ggplot2::facet_wrap(~SET_direction, ncol = columns, scales = scales) +
        ggplot2::labs(title = 'Pin Height (raw measurement)',
             subtitle = rlang::sym(set),
             x = 'Date',
             y = 'Measured pin height (mm)',
             color = 'Pin') +
        ggplot2::theme_bw() +
        ggplot2::theme(legend.position = 'bottom')
}
