#' Make a graph of change over time by site
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
#' plot_cumu_site(example_sets)
#' plot_cumu_site(example_sets, columns = 1, pointsize = 2, smooth = FALSE)

plot_cumu_site <- function(data, columns = 2, pointsize = 3.5, scales = "fixed", smooth = TRUE, lty_smooth = 5){

    # calculate linear rates of change for each site
    rates <- calc_site_rates(data)

    # calculate site-level cumulative change points and SEs for plotting
    dataf <- calc_change_cumu(data)
    dataf <- dataf$set %>%
        group_by(network_code, park_code, site_name, event_date_UTC) %>%
        summarise(mean_site = mean(mean_cumu, na.rm = TRUE),
                  se_site = sd(mean_cumu, na.rm = T)/sqrt(n()))

    # data needs to be the $set piece of the output from calc_change_cumu
    ggplot2::ggplot(dataf, ggplot2::aes(x = event_date_UTC, y = mean_site)) +
        ggplot2::geom_line(col = 'lightsteelblue4') +
        {if(smooth) ggplot2::geom_smooth(se = FALSE, method = 'lm',
                                         col = 'steelblue4', lty = lty_smooth, size = 1)} +
        ggplot2::geom_point(shape = 21,
                            fill = 'lightsteelblue1', col = 'steelblue3',
                            size = pointsize, alpha = 0.9) +
        {if(smooth) ggplot2::geom_text(
            data = rates,
            aes(x = structure(Inf, class = "Date"), y = Inf, label =
                    paste("rate:", format(round(site_rate, 2), nsmall = 2), "+",
                          format(round(se_rate, 2), nsmall = 2), "\n" , "r2:",
                          format(round(site_rate_r2, 2), nsmall = 2), sep = " ")),
            hjust = 1,
            vjust = 2)} +
        ggplot2::facet_wrap(~site_name, ncol = columns, scales = scales) +
        ggplot2::labs(title = 'Cumulative Change since first reading',
                                  x = 'Date',
                                  y = 'Surface elevation change (mm)') +
        ggplot2::theme_classic()
}
