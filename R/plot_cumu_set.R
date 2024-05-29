#' Make a graph of change over time by SET (or station)
#'
#' x-axis is date; y-axis is the average of the 36 pin heights' difference from baseline (first measurement). One facet per SET/station id.
#'
#' @param data Data frame with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, and pin_height_mm.
#'
#' @param columns Number of columns you want in the faceted output; defaults to 4.
#'
#' @param pointsize Size of points you want (goes into the `size` argument of `ggplot2::geom_point`); defaults to 3.5.
#'
#' @param scales Do you want axis scales to be the same in all facets ("fixed") or to vary between facets "free_x" or "free_y" or "free" - goes into `scales` arg of `facet_wrap`; defaults to "free_y".
#'
#' @param smooth Do you want a linear regression plotted on top? defaults to TRUE.
#'
#' @param lty_smooth What type of line do you want the linear regression to plot as? 1 = solid; 2 and 5 = dashed; or any of the other line types available in `ggplot2`. defaults to dashed.
#'
#' @return a ggplot object
#'
#' @export
#'
#' @examples
#' plot_cumu_set(example_sets)
#' plot_cumu_set(example_sets, columns = 1, pointsize = 2, smooth = FALSE)

plot_cumu_set <- function(data, set = NULL, columns = 4, pointsize = 3.5, scales = "fixed", smooth = TRUE, lty_smooth = 5){

    if(is.null(set)){
        to_plot <- data
        plot_title <- 'Cumulative Change by arm position'
    }
    else{
        to_plot <- data %>%
            dplyr::filter(station_code == !!set)

        station_lab <- data %>%
            filter(station_code == !!set) %>%
            distinct(park_code, site_name, station_code) %>%
            mutate(lab = paste(park_code, site_name, station_code, sep = ", ")) %>%
            pull(lab)

        plot_title <- paste('Cumulative Change by arm position at\n', station_lab)
    }

    dataf <- calc_change_cumu(to_plot)
    dataf <- dataf$set

    # calculate linear rates of change for each SET/station
    rates <- calc_set_rates(to_plot)

    # data needs to be the $set piece of the output from calc_change_cumu
    ggplot2::ggplot(dataf, ggplot2::aes(x = event_date_UTC, y = mean_cumu)) +
        ggplot2::geom_line(col = 'lightsteelblue4') +
        {if(smooth) ggplot2::geom_smooth(se = FALSE, method = 'lm',
                                col = 'steelblue4', lty = lty_smooth, size = 1)} +
        ggplot2::geom_point(shape = 21,
                   fill = 'lightsteelblue1', col = 'steelblue3',
                   size = pointsize, alpha = 0.9) +
        {if(smooth) ggplot2::geom_text(
            data = rates,
            aes(x = structure(Inf, class = "Date"), y = Inf, label =
                    paste("rate:", format(round(set_rate, 2), nsmall = 2), "+",
                          format(round(se_rate, 2), nsmall = 2), "\n" , "r2:",
                          format(round(set_rate_r2, 2), nsmall = 2), sep = " ")),
            hjust = 1,
            vjust = 2)} +
        ggplot2::facet_wrap(~station_code, ncol = columns, scales = scales) +
        {if(smooth) ggplot2::labs(title = 'Cumulative Change since first reading',
                         x = 'Date',
                         y = 'Change since first reading (mm)')} +
        {if(!smooth) ggplot2::labs(title = 'Cumulative Change since first reading',
                          x = 'Date',
                          y = 'Change since first reading (mm)')} +
        ggplot2::theme_classic()
}
