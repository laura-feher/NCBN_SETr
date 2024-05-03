#' Plot raw pin measurements, first averaged to SET_direction level, by date
#'
#' @param data Data frame with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, and pin_height_mm.
#'
#' @param columns Number of columns you want in the faceted output; defaults to 4.
#'
#' @param pointsize Size of points you want (goes into the `size` argument of `ggplot2::geom_point`); defaults to 2.
#'
#' @param seline logical; Include error bars for +/- one standard error? defaults to TRUE.
#'
#' @param selinesize Size for width of error bars; defaults to 1.
#'
#' @param scales Do you want axis scales to be the same in all facets ("fixed") or to vary between facets "free_x" or "free_y" or "free" - goes into `scales` arg of `facet_wrap`; defaults to "free_y".
#'
#' @return a ggplot object
#'
#' @export
#'
#' @examples
#' plot_raw_arm(example_sets)
#' plot_raw_arm(example_sets, columns = 1, pointsize = 3)
#' plot_raw_arm(example_sets, seline = FALSE)

plot_raw_arm <- function(data, columns = 4, pointsize = 2, seline = TRUE, selinesize = 1, scales = "free_y"){
    data %>%
        dplyr::group_by(network_code, park_code, site_name, station_code, SET_direction, event_date_UTC) %>%
        dplyr::summarize(mean = mean(pin_height_mm, na.rm = TRUE),
                  se = stats::sd(pin_height_mm, na.rm = TRUE)/sqrt(n())) %>%
        ggplot2::ggplot(ggplot2::aes(x = event_date_UTC, y = mean, color = as.factor(SET_direction))) +
        ggplot2::geom_point(size = pointsize) +
        ggplot2::geom_line(alpha = 0.6) +
        {if(seline) ggplot2::geom_errorbar(ggplot2::aes(x = event_date_UTC,
                                      ymin = mean - se,
                                      ymax = mean + se,
                                      color = as.factor(SET_direction)
        ),
        size = selinesize
        )} +
        ggplot2::facet_wrap(~station_code, ncol = columns, scales = scales) +
        ggplot2::labs(title = 'Pin Height (raw measurement; averaged to SET direction level)',
             x = 'Date',
             y = 'Mean pin height (mm)',
             color = 'SET direction') +
        ggplot2::theme_bw() +
        ggplot2::theme(legend.position = 'bottom')
}
